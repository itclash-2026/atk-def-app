package main

import (
	"archive/zip"
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	_ "github.com/lib/pq"
)

var db *sql.DB
var jwtKey []byte

type Credentials struct {
	Password string `json:"password"`
	Email    string `json:"email"`
	Username string `json:"username"`
}

type Claims struct {
	Username string `json:"username"`
	jwt.RegisteredClaims
}

func initDB() {
	var err error
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "user=kmitl_user password=kmitl_password dbname=kmitl_web sslmode=disable"
	}

	db, err = sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatal(err)
	}

	err = db.Ping()
	if err != nil {
		log.Fatal(err)
	}
	log.Println("Connected to Database")
}

func setupCORS(w *http.ResponseWriter, req *http.Request) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
	(*w).Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
	(*w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
}

func main() {
	initDB()

	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		secret = "supersecretjwtkey_for_kmitl"
	}
	jwtKey = []byte(secret)

	http.Handle("/preview/", http.StripPrefix("/preview/", http.FileServer(http.Dir("uploads/previews"))))

	http.HandleFunc("/api/register", Register)
	http.HandleFunc("/api/login", Login)
	http.HandleFunc("/api/lessons", AuthMiddleware(Lessons))
	http.HandleFunc("/api/lessons/", AuthMiddleware(GetLesson))
	http.HandleFunc("/api/lessons/search", AuthMiddleware(SearchLesson))
	http.HandleFunc("/api/execute", AuthMiddleware(ExecuteCode))
	http.HandleFunc("/api/homeworks", AuthMiddleware(GetHomeworks))
	http.HandleFunc("/api/homeworks/", AuthMiddleware(HandleHomeworksResource))
	http.HandleFunc("/api/files", AuthMiddleware(HandleFiles))
	http.HandleFunc("/api/files/", AuthMiddleware(HandleFileDelete))
	http.HandleFunc("/api/db/execute", AuthMiddleware(ExecuteSQL))

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func ExecuteSQL(w http.ResponseWriter, r *http.Request) {
	setupCORS(&w, r)
	if r.Method == "OPTIONS" {
		return
	}
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	username := extractUsername(r)
	if username == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	type executeSQLRequest struct {
		SQL string `json:"sql"`
	}

	var req executeSQLRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "Invalid request payload"})
		return
	}

	sqlText := strings.TrimSpace(req.SQL)
	if sqlText == "" {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "Missing sql"})
		return
	}
	if len(sqlText) > 200_000 {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "SQL too large"})
		return
	}

	statements := splitSQLStatements(sqlText)
	var cleaned []string
	for _, st := range statements {
		st = strings.TrimSpace(st)
		st = stripLeadingSQLComments(st)
		st = strings.TrimSpace(st)
		if st == "" {
			continue
		}
		cleaned = append(cleaned, st)
	}
	if len(cleaned) == 0 {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "No executable SQL found"})
		return
	}
	if len(cleaned) > 50 {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "Too many statements"})
		return
	}

	tx, err := db.Begin()
	if err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{"error": "Database error"})
		return
	}
	defer tx.Rollback()

	type statementResult struct {
		Statement    string                   `json:"statement"`
		Kind         string                   `json:"kind"`
		RowsAffected int64                    `json:"rowsAffected,omitempty"`
		Columns      []string                 `json:"columns,omitempty"`
		Rows         []map[string]interface{} `json:"rows,omitempty"`
		RowCount     int                      `json:"rowCount,omitempty"`
	}

	results := make([]statementResult, 0, len(cleaned))
	var totalRowsAffected int64 = 0

	for _, st := range cleaned {
		kind := classifySQLKind(st)
		if kind == "query" {
			cols, rows, qErr := runQuery(tx, st, 200)
			if qErr != nil {
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusBadRequest)
				json.NewEncoder(w).Encode(map[string]string{"error": qErr.Error()})
				return
			}
			results = append(results, statementResult{
				Statement: st,
				Kind:      "query",
				Columns:   cols,
				Rows:      rows,
				RowCount:  len(rows),
			})
			continue
		}

		execRes, execErr := tx.Exec(st)
		if execErr != nil {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(map[string]string{"error": execErr.Error()})
			return
		}
		ra, _ := execRes.RowsAffected()
		totalRowsAffected += ra
		results = append(results, statementResult{
			Statement:    st,
			Kind:         "exec",
			RowsAffected: ra,
		})
	}

	if err := tx.Commit(); err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{"error": "Database commit failed"})
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message":           "ok",
		"statements":        len(results),
		"rowsAffectedTotal": totalRowsAffected,
		"results":           results,
	})
}

var dollarQuoteStartRe = regexp.MustCompile(`^\$[A-Za-z0-9_]*\$`)

func splitSQLStatements(sqlText string) []string {
	var out []string
	var sb strings.Builder

	inSingle := false
	inDouble := false
	dollarTag := ""

	for i := 0; i < len(sqlText); i++ {
		ch := sqlText[i]

		if dollarTag != "" {
			if i+len(dollarTag) <= len(sqlText) && sqlText[i:i+len(dollarTag)] == dollarTag {
				sb.WriteString(dollarTag)
				i += len(dollarTag) - 1
				dollarTag = ""
				continue
			}
			sb.WriteByte(ch)
			continue
		}

		if inSingle {
			if ch == '\'' {
				if i+1 < len(sqlText) && sqlText[i+1] == '\'' {
					sb.WriteByte(ch)
					sb.WriteByte(sqlText[i+1])
					i++
					continue
				}
				inSingle = false
			}
			sb.WriteByte(ch)
			continue
		}

		if inDouble {
			if ch == '"' {
				if i+1 < len(sqlText) && sqlText[i+1] == '"' {
					sb.WriteByte(ch)
					sb.WriteByte(sqlText[i+1])
					i++
					continue
				}
				inDouble = false
			}
			sb.WriteByte(ch)
			continue
		}

		if ch == '\'' {
			inSingle = true
			sb.WriteByte(ch)
			continue
		}
		if ch == '"' {
			inDouble = true
			sb.WriteByte(ch)
			continue
		}

		if ch == '$' {
			m := dollarQuoteStartRe.FindString(sqlText[i:])
			if m != "" {
				dollarTag = m
				sb.WriteString(m)
				i += len(m) - 1
				continue
			}
		}

		if ch == ';' {
			out = append(out, sb.String())
			sb.Reset()
			continue
		}

		sb.WriteByte(ch)
	}

	if sb.Len() > 0 {
		out = append(out, sb.String())
	}
	return out
}

func stripLeadingSQLComments(s string) string {
	for {
		t := strings.TrimLeft(s, "\t\r\n ")
		if strings.HasPrefix(t, "--") {
			if idx := strings.IndexByte(t, '\n'); idx >= 0 {
				s = t[idx+1:]
				continue
			}
			return ""
		}
		if strings.HasPrefix(t, "/*") {
			end := strings.Index(t, "*/")
			if end >= 0 {
				s = t[end+2:]
				continue
			}
			return ""
		}
		return s
	}
}

func classifySQLKind(statement string) string {
	s := strings.TrimSpace(stripLeadingSQLComments(statement))
	upper := strings.ToUpper(s)
	if strings.HasPrefix(upper, "SELECT") || strings.HasPrefix(upper, "WITH") || strings.HasPrefix(upper, "SHOW") {
		return "query"
	}
	return "exec"
}

func runQuery(tx *sql.Tx, statement string, maxRows int) ([]string, []map[string]interface{}, error) {
	rows, err := tx.Query(statement)
	if err != nil {
		return nil, nil, err
	}
	defer rows.Close()

	cols, err := rows.Columns()
	if err != nil {
		return nil, nil, err
	}

	results := make([]map[string]interface{}, 0)
	for rows.Next() {
		if len(results) >= maxRows {
			break
		}
		values := make([]interface{}, len(cols))
		valuePtrs := make([]interface{}, len(cols))
		for i := range values {
			valuePtrs[i] = &values[i]
		}
		if err := rows.Scan(valuePtrs...); err != nil {
			return cols, nil, err
		}
		m := make(map[string]interface{}, len(cols))
		for i, c := range cols {
			v := values[i]
			if b, ok := v.([]byte); ok {
				m[c] = string(b)
			} else {
				m[c] = v
			}
		}
		results = append(results, m)
	}
	if err := rows.Err(); err != nil {
		return cols, nil, err
	}
	return cols, results, nil
}

func SearchLesson(w http.ResponseWriter, r *http.Request) {
	setupCORS(&w, r)
	if r.Method == "OPTIONS" {
		return
	}
	if r.Method != "GET" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	query := r.URL.Query().Get("search")
	baseQuery := `
		SELECT id, title, description, content
		FROM lessons
		WHERE 1=1
	`

	if query != "" {
		baseQuery += fmt.Sprintf(" AND title LIKE '%%%s%%'", query)
	}

	rows, err := db.Query(baseQuery)

	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{"error": "Database error"})
		return
	}
	defer rows.Close()

	var lessons []Lesson
	for rows.Next() {
		var l Lesson
		if err := rows.Scan(&l.ID, &l.Title, &l.Description, &l.Content); err != nil {
			log.Println("Error scanning lesson:", err)
			continue
		}
		lessons = append(lessons, l)
	}

	if lessons == nil {
		lessons = []Lesson{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(lessons)
}

func Register(w http.ResponseWriter, r *http.Request) {
	setupCORS(&w, r)
	if r.Method == "OPTIONS" {
		return
	}
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var creds Credentials
	err := json.NewDecoder(r.Body).Decode(&creds)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	_, err = db.Exec("INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3)", creds.Username, creds.Email, creds.Password)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{"error": "User already exists or DB error"})
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]string{"message": "User registered successfully"})
}

func Login(w http.ResponseWriter, r *http.Request) {
	setupCORS(&w, r)
	if r.Method == "OPTIONS" {
		return
	}
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var creds Credentials
	err := json.NewDecoder(r.Body).Decode(&creds)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	var storedPassword string
	var username string
	err = db.QueryRow("SELECT username, password_hash FROM users WHERE email=$1", creds.Email).Scan(&username, &storedPassword)
	if err != nil {
		if err == sql.ErrNoRows {
			w.WriteHeader(http.StatusUnauthorized)
			json.NewEncoder(w).Encode(map[string]string{"error": "Invalid credentials"})
			return
		}
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	if storedPassword != creds.Password {
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(map[string]string{"error": "Invalid credentials"})
		return
	}

	expirationTime := time.Now().Add(24 * time.Hour)
	claims := &Claims{
		Username: username,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]string{"token": tokenString, "username": username})
}

func AuthMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		setupCORS(&w, r)
		if r.Method == "OPTIONS" {
			return
		}

		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}

		bearerToken := strings.Split(authHeader, " ")
		if len(bearerToken) != 2 {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}

		claims := &Claims{}
		tkn, err := jwt.ParseWithClaims(bearerToken[1], claims, func(token *jwt.Token) (interface{}, error) {
			return jwtKey, nil
		})

		if err != nil || !tkn.Valid {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}

		next(w, r)
	}
}

type Lesson struct {
	ID          int    `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Content     string `json:"content"`
}

func Lessons(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		var l Lesson
		err := json.NewDecoder(r.Body).Decode(&l)
		if err != nil || l.Title == "" || l.Description == "" {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(map[string]string{"error": "Invalid request payload"})
			return
		}

		err = db.QueryRow("INSERT INTO lessons (title, description, content) VALUES ($1, $2, $3) RETURNING id", l.Title, l.Description, l.Content).Scan(&l.ID)
		if err != nil {
			log.Println("Error inserting lesson:", err)
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(map[string]string{"error": "Could not create lesson"})
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(l)
		return
	}

	if r.Method != "GET" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	rows, err := db.Query("SELECT id, title, description FROM lessons ORDER BY id ASC")
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{"error": "Database error"})
		return
	}
	defer rows.Close()

	var lessons []Lesson
	for rows.Next() {
		var l Lesson
		if err := rows.Scan(&l.ID, &l.Title, &l.Description); err != nil {
			log.Println("Error scanning lesson:", err)
			continue
		}
		lessons = append(lessons, l)
	}

	if lessons == nil {
		lessons = []Lesson{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(lessons)
}

func GetLesson(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" && r.Method != "PUT" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	parts := strings.Split(strings.TrimSuffix(r.URL.Path, "/"), "/")
	if len(parts) < 4 {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "Missing lesson ID"})
		return
	}
	idStr := parts[len(parts)-1]

	if r.Method == "PUT" {
		var l Lesson
		err := json.NewDecoder(r.Body).Decode(&l)
		if err != nil || l.Title == "" || l.Description == "" {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(map[string]string{"error": "Invalid request payload"})
			return
		}

		result, err := db.Exec("UPDATE lessons SET title=$1, description=$2, content=$3 WHERE id=$4", l.Title, l.Description, l.Content, idStr)
		if err != nil {
			log.Println("Error updating lesson:", err)
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(map[string]string{"error": "Could not update lesson"})
			return
		}

		rowsAffected, err := result.RowsAffected()
		if err != nil || rowsAffected == 0 {
			w.WriteHeader(http.StatusNotFound)
			json.NewEncoder(w).Encode(map[string]string{"error": "Lesson not found or no changes made"})
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"message": "Lesson updated successfully"})
		return
	}

	var l Lesson
	err := db.QueryRow("SELECT id, title, description, content FROM lessons WHERE id = $1", idStr).Scan(&l.ID, &l.Title, &l.Description, &l.Content)
	if err != nil {
		if err == sql.ErrNoRows {
			w.WriteHeader(http.StatusNotFound)
			json.NewEncoder(w).Encode(map[string]string{"error": "Lesson not found"})
			return
		}
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{"error": "Database error"})
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(l)
}

type CodeExecutionRequest struct {
	Language string `json:"language"`
	Code     string `json:"code"`
}

type CodeExecutionResponse struct {
	Output string `json:"output"`
	Error  string `json:"error,omitempty"`
}

func ExecuteCode(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req CodeExecutionRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "Invalid request payload"})
		return
	}

	var cmd *exec.Cmd

	switch req.Language {
	case "python":
		cmd = exec.Command("bash", "-c", "python3 -c '"+req.Code+"'")
	case "php":
		cmd = exec.Command("bash", "-c", "php -r '"+req.Code+"'")
	case "go":
		cmd = exec.Command("bash", "-c", "echo '"+req.Code+"' > temp.go && go run temp.go ; rm -f temp.go")
	case "bash", "sh":
		cmd = exec.Command("bash", "-c", req.Code)
	default:
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "Unsupported language."})
		return
	}

	outputBytes, err := cmd.CombinedOutput()
	outputStr := string(outputBytes)

	resp := CodeExecutionResponse{
		Output: outputStr,
	}

	if err != nil {
		resp.Error = err.Error()
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

type Homework struct {
	ID          int        `json:"id"`
	Title       string     `json:"title"`
	Description string     `json:"description"`
	DueDate     *time.Time `json:"due_date"`
	CreatedAt   time.Time  `json:"created_at"`
}

type HomeworkSubmission struct {
	ID            int       `json:"id"`
	HomeworkID    int       `json:"homework_id"`
	FilePath      string    `json:"file_path"`
	ExtractedPath *string   `json:"extracted_path"`
	SubmittedAt   time.Time `json:"submitted_at"`
	PreviewURL    *string   `json:"preview_url,omitempty"`
}

func GetHomeworks(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		var h Homework
		err := json.NewDecoder(r.Body).Decode(&h)
		if err != nil || h.Title == "" || h.Description == "" {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		err = db.QueryRow("INSERT INTO homeworks (title, description, due_date) VALUES ($1, $2, $3) RETURNING id", h.Title, h.Description, h.DueDate).Scan(&h.ID)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(h)
		return
	}

	if r.Method != "GET" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	rows, err := db.Query("SELECT id, title, description, due_date, created_at FROM homeworks ORDER BY due_date ASC")
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var homeworks []Homework
	for rows.Next() {
		var h Homework
		if err := rows.Scan(&h.ID, &h.Title, &h.Description, &h.DueDate, &h.CreatedAt); err == nil {
			homeworks = append(homeworks, h)
		}
	}
	if homeworks == nil {
		homeworks = []Homework{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(homeworks)
}

func HandleHomeworksResource(w http.ResponseWriter, r *http.Request) {
	if r.Method == "OPTIONS" {
		return
	}
	parts := strings.Split(strings.TrimSuffix(r.URL.Path, "/"), "/")
	if len(parts) < 4 {
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	idStr := parts[3]

	if len(parts) == 5 && parts[4] == "submit" {
		if r.Method != "POST" {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}
		SubmitHomework(w, r, idStr)
		return
	}

	if len(parts) == 5 && parts[4] == "submission" {
		if r.Method != "GET" {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}
		GetHomeworkSubmission(w, r, idStr)
		return
	}

	if r.Method == "GET" {
		var h Homework
		err := db.QueryRow("SELECT id, title, description, due_date, created_at FROM homeworks WHERE id = $1", idStr).Scan(&h.ID, &h.Title, &h.Description, &h.DueDate, &h.CreatedAt)
		if err != nil {
			w.WriteHeader(http.StatusNotFound)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(h)
		return
	}

	http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
}

func GetHomeworkSubmission(w http.ResponseWriter, r *http.Request, homeworkID string) {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}
	bearerToken := strings.Split(authHeader, " ")
	if len(bearerToken) != 2 {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	claims := &Claims{}
	_, err := jwt.ParseWithClaims(bearerToken[1], claims, func(token *jwt.Token) (interface{}, error) {
		return jwtKey, nil
	})
	if err != nil || claims.Username == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	var userID int
	err = db.QueryRow("SELECT id FROM users WHERE username = $1", claims.Username).Scan(&userID)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	var sub HomeworkSubmission
	err = db.QueryRow(
		"SELECT id, homework_id, file_path, extracted_path, submitted_at FROM homework_submissions WHERE homework_id = $1 AND user_id = $2 ORDER BY submitted_at DESC LIMIT 1",
		homeworkID, userID,
	).Scan(&sub.ID, &sub.HomeworkID, &sub.FilePath, &sub.ExtractedPath, &sub.SubmittedAt)
	if err == sql.ErrNoRows {
		w.WriteHeader(http.StatusNotFound)
		return
	}
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	if sub.ExtractedPath != nil {
		previewURL := fmt.Sprintf("/preview/%d/", sub.ID)
		sub.PreviewURL = &previewURL
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(sub)
}

func extractZip(src, dest string) error {
	r, err := zip.OpenReader(src)
	if err != nil {
		return err
	}
	defer r.Close()

	for _, f := range r.File {
		fpath := filepath.Join(dest, f.Name)

		if f.FileInfo().IsDir() {
			os.MkdirAll(fpath, os.ModePerm)
			continue
		}

		if err := os.MkdirAll(filepath.Dir(fpath), os.ModePerm); err != nil {
			return err
		}

		outFile, err := os.Create(fpath)
		if err != nil {
			return err
		}
		rc, err := f.Open()
		if err != nil {
			outFile.Close()
			return err
		}
		_, err = io.Copy(outFile, rc)
		outFile.Close()
		rc.Close()
		if err != nil {
			return err
		}
	}
	return nil
}

func SubmitHomework(w http.ResponseWriter, r *http.Request, homeworkID string) {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}
	bearerToken := strings.Split(authHeader, " ")
	if len(bearerToken) != 2 {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	claims := &Claims{}
	_, err := jwt.ParseWithClaims(bearerToken[1], claims, func(token *jwt.Token) (interface{}, error) {
		return jwtKey, nil
	})
	if err != nil || claims.Username == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	var userID int
	err = db.QueryRow("SELECT id FROM users WHERE username = $1", claims.Username).Scan(&userID)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	err = r.ParseMultipartForm(10 << 20)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "Failed to parse form"})
		return
	}

	file, handler, err := r.FormFile("file")
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "Missing file"})
		return
	}
	defer file.Close()

	err = os.MkdirAll("uploads", os.ModePerm)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	fileName := filepath.Base(handler.Filename)
	filePath := filepath.Join("uploads", claims.Username+"_"+homeworkID+"_"+fileName)

	dest, err := os.Create(filePath)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	defer dest.Close()

	_, err = io.Copy(dest, file)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	var submissionID int
	err = db.QueryRow(
		"INSERT INTO homework_submissions (homework_id, user_id, file_path) VALUES ($1, $2, $3) RETURNING id",
		homeworkID, userID, filePath,
	).Scan(&submissionID)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{"error": "Database error"})
		return
	}

	ext := strings.ToLower(filepath.Ext(fileName))

	previewURL := ""
	if ext == ".zip" {
		extractDir := fmt.Sprintf("uploads/previews/%d", submissionID)
		if err := os.MkdirAll(extractDir, os.ModePerm); err == nil {
			if err := extractZip(filePath, extractDir); err == nil {
				db.Exec(
					"UPDATE homework_submissions SET extracted_path = $1 WHERE id = $2",
					extractDir, submissionID,
				)
				previewURL = fmt.Sprintf("/preview/%d/", submissionID)
			}
		}
	}

	var cmdStr string

	switch ext {
	case ".py":
		cmdStr = "python3 " + filePath
	case ".php":
		cmdStr = "php " + filePath
	case ".js":
		cmdStr = "node " + filePath
	case ".sh":
		cmdStr = "bash " + filePath
	case ".go":
		cmdStr = "go run " + filePath
	default:
		cmdStr = "file " + filePath
	}

	cmd := exec.Command("bash", "-c", cmdStr)
	outputBytes, cmdErr := cmd.CombinedOutput()
	outputStr := string(outputBytes)

	if cmdErr != nil {
		outputStr += "\n[Error executing auto-grader: " + cmdErr.Error() + "]"
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message":          "File uploaded successfully",
		"auto_compile_log": outputStr,
		"preview_url":      previewURL,
	})
}

type FileInfo struct {
	Name     string `json:"name"`
	Size     int64  `json:"size"`
	Modified string `json:"modified"`
	ExecLog  string `json:"exec_log,omitempty"`
}

func extractUsername(r *http.Request) string {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		return ""
	}
	bearerToken := strings.Split(authHeader, " ")
	if len(bearerToken) != 2 {
		return ""
	}
	claims := &Claims{}
	_, err := jwt.ParseWithClaims(bearerToken[1], claims, func(token *jwt.Token) (interface{}, error) {
		return jwtKey, nil
	})
	if err != nil {
		return ""
	}
	return claims.Username
}

func HandleFiles(w http.ResponseWriter, r *http.Request) {
	username := extractUsername(r)
	if username == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	userDir := filepath.Join("uploads", "userfiles", username)
	os.MkdirAll(userDir, os.ModePerm)

	switch r.Method {
	case "GET":
		entries, err := os.ReadDir(userDir)
		if err != nil {
			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode([]FileInfo{})
			return
		}

		var files []FileInfo
		for _, e := range entries {
			if e.IsDir() {
				continue
			}
			info, err := e.Info()
			if err != nil {
				continue
			}
			files = append(files, FileInfo{
				Name:     e.Name(),
				Size:     info.Size(),
				Modified: info.ModTime().Format(time.RFC3339),
			})
		}
		if files == nil {
			files = []FileInfo{}
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(files)

	case "POST":
		err := r.ParseMultipartForm(10 << 20)
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(map[string]string{"error": "File too large or invalid form"})
			return
		}

		file, handler, err := r.FormFile("file")
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(map[string]string{"error": "Missing file"})
			return
		}
		defer file.Close()

		fileName := filepath.Base(handler.Filename)
		destPath := filepath.Join(userDir, fileName)

		dest, err := os.Create(destPath)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		defer dest.Close()

		_, err = io.Copy(dest, file)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}

		result := map[string]interface{}{
			"message": fmt.Sprintf("File '%s' uploaded successfully", fileName),
		}

		ext := strings.ToLower(filepath.Ext(fileName))
		if ext == ".sh" {
			os.Chmod(destPath, 0755)
			cmd := exec.Command("bash", "-c", "bash "+destPath)
			outputBytes, cmdErr := cmd.CombinedOutput()
			execOutput := string(outputBytes)
			if cmdErr != nil {
				execOutput += "\n[exit: " + cmdErr.Error() + "]"
			}
			result["exec_log"] = execOutput
			result["message"] = fmt.Sprintf("Script '%s' was auto-executed by the system", fileName)
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(result)

	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func HandleFileDelete(w http.ResponseWriter, r *http.Request) {
	setupCORS(&w, r)
	if r.Method == "OPTIONS" {
		return
	}
	if r.Method != "DELETE" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	username := extractUsername(r)
	if username == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}
	parts := strings.Split(strings.TrimSuffix(r.URL.Path, "/"), "/")
	if len(parts) < 4 {
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	fileName := parts[3]

	userDir := filepath.Join("uploads", "userfiles", username)
	filePath := filepath.Join(userDir, fileName)

	err := os.Remove(filePath)
	if err != nil {
		w.WriteHeader(http.StatusNotFound)
		json.NewEncoder(w).Encode(map[string]string{"error": "File not found"})
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "File deleted"})
}
