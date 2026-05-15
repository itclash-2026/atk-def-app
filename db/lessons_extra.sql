-- Additional 25 lessons (Web Dev theme, lessons 6-30)
INSERT INTO lessons (title, description, content) VALUES
(
    'Git & Version Control',
    'Track changes in your code with Git.',
    '## Git — Version Control for Developers

Git helps you **track changes**, collaborate with others, and revert mistakes.

### Basic Commands
```bash
git init          # initialize a repo
git add .         # stage all changes
git commit -m "message"  # save a snapshot
git status        # check current state
git log --oneline # view history
```

### Branching
```bash
git branch feature-login   # create branch
git checkout feature-login # switch to it
git merge feature-login    # merge back to main
```

### Remote (GitHub)
```bash
git remote add origin https://github.com/user/repo.git
git push -u origin main
git pull origin main
```

### Exercise
Create a repo, make 3 commits, then create and merge a branch!'
),
(
    'Command Line Basics',
    'Navigate and manage files with the terminal.',
    '## Command Line — Power at Your Fingertips

The terminal lets you control your computer with text commands — much faster than clicking!

### Navigation
```bash
pwd          # print working directory
ls -la       # list files (with hidden)
cd folder    # change directory
cd ..        # go up one level
```

### File Operations
```bash
mkdir my-project    # create folder
touch index.html    # create file
cp file1 file2      # copy
mv file1 dest/      # move / rename
rm -rf folder       # delete (careful!)
```

### Useful Tricks
- `Tab` → autocomplete
- `Ctrl+C` → cancel command
- `!!` → repeat last command
- `grep "text" file` → search in file

### Exercise
Create a folder structure `project/src/` and `project/dist/` using only the terminal!'
),
(
    'HTTP & REST APIs',
    'Understand how the web communicates.',
    '## HTTP & REST APIs

HTTP (HyperText Transfer Protocol) is how browsers and servers talk to each other.

### HTTP Methods
| Method | Purpose |
|--------|---------|
| GET | Fetch data |
| POST | Create new data |
| PUT | Update existing data |
| DELETE | Remove data |

### Status Codes
| Code | Meaning |
|------|---------|
| 200 | OK |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 404 | Not Found |
| 500 | Server Error |

### REST API Example
```bash
# Get all users
GET /api/users

# Get one user
GET /api/users/42

# Create user
POST /api/users
Content-Type: application/json
{"name": "Alice", "email": "alice@example.com"}

# Delete user
DELETE /api/users/42
```

### Exercise
Use `curl` or a browser to call a public API like `https://jsonplaceholder.typicode.com/posts`!'
),
(
    'Introduction to Python',
    'Learn the basics of Python programming.',
    '## Python — Simple and Powerful

Python is a beginner-friendly language used in web development, data science, and automation.

### Hello World
```python
print("Hello, World!")
```

### Variables & Types
```python
name = "Alice"
age = 20
gpa = 3.85
is_student = True
```

### Control Flow
```python
if age >= 18:
    print("Adult")
elif age >= 13:
    print("Teenager")
else:
    print("Child")
```

### Loops
```python
for i in range(5):
    print(i)

fruits = ["apple", "banana", "mango"]
for fruit in fruits:
    print(fruit)
```

### Functions
```python
def greet(name):
    return f"Hello, {name}!"

print(greet("Alice"))
```

### Exercise
Write a Python function that takes a list of numbers and returns the average!'
),
(
    'Python Lists & Dictionaries',
    'Work with Python''s most useful data structures.',
    '## Lists & Dictionaries in Python

### Lists
```python
fruits = ["apple", "banana", "mango"]
fruits.append("grape")     # add item
fruits.remove("banana")    # remove item
print(fruits[0])           # access by index
print(len(fruits))         # length
```

### List Comprehension
```python
squares = [x**2 for x in range(10)]
evens   = [x for x in range(20) if x % 2 == 0]
```

### Dictionaries
```python
student = {
    "name": "Alice",
    "age": 20,
    "gpa": 3.85
}
print(student["name"])     # access value
student["major"] = "CS"    # add key
del student["age"]         # remove key
```

### Looping Dictionaries
```python
for key, value in student.items():
    print(f"{key}: {value}")
```

### Exercise
Create a dictionary of 5 students with their GPAs, then print only those with GPA above 3.5!'
),
(
    'Python File I/O',
    'Read and write files using Python.',
    '## File I/O in Python

### Reading a File
```python
with open("data.txt", "r") as f:
    content = f.read()
    print(content)

# Read line by line
with open("data.txt", "r") as f:
    for line in f:
        print(line.strip())
```

### Writing a File
```python
with open("output.txt", "w") as f:
    f.write("Hello, File!\n")
    f.write("Second line\n")

# Append mode
with open("log.txt", "a") as f:
    f.write("New log entry\n")
```

### Working with CSV
```python
import csv

with open("students.csv", "r") as f:
    reader = csv.DictReader(f)
    for row in reader:
        print(row["name"], row["gpa"])
```

### Exercise
Write a Python script that reads a text file, counts the number of words, and writes the result to a new file!'
),
(
    'Introduction to Go',
    'Learn the basics of the Go programming language.',
    '## Go — Fast, Simple, Reliable

Go (Golang) is a compiled language by Google — great for web backends, tools, and systems programming.

### Hello World
```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
```

### Variables
```go
name := "Alice"      // short declaration
var age int = 20
const PI = 3.14159
```

### Functions
```go
func add(a, b int) int {
    return a + b
}

func divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, fmt.Errorf("cannot divide by zero")
    }
    return a / b, nil
}
```

### Loops (Go only has `for`)
```go
for i := 0; i < 5; i++ {
    fmt.Println(i)
}

// while-style
n := 0
for n < 10 {
    n++
}
```

### Exercise
Write a Go program that calculates the factorial of a number using a loop!'
),
(
    'Go Structs & Interfaces',
    'Model real-world data with Go structs.',
    '## Structs & Interfaces in Go

### Defining a Struct
```go
type Student struct {
    Name  string
    Age   int
    GPA   float64
}

s := Student{Name: "Alice", Age: 20, GPA: 3.85}
fmt.Println(s.Name)
```

### Methods on Structs
```go
func (s Student) IsHonors() bool {
    return s.GPA >= 3.5
}

fmt.Println(s.IsHonors()) // true
```

### Interfaces
```go
type Greeter interface {
    Greet() string
}

func (s Student) Greet() string {
    return "Hi, I am " + s.Name
}

func SayHello(g Greeter) {
    fmt.Println(g.Greet())
}

SayHello(s) // works!
```

### Exercise
Create a `Shape` interface with an `Area()` method, then implement it for `Circle` and `Rectangle`!'
),
(
    'SQL & Databases',
    'Store and query data with SQL.',
    '## SQL — Structured Query Language

SQL is used to create, read, update, and delete data in relational databases.

### Create a Table
```sql
CREATE TABLE students (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    gpa  DECIMAL(3,2)
);
```

### CRUD Operations
```sql
-- Create
INSERT INTO students (name, gpa) VALUES (''Alice'', 3.85);

-- Read
SELECT * FROM students WHERE gpa > 3.5 ORDER BY gpa DESC;

-- Update
UPDATE students SET gpa = 3.90 WHERE name = ''Alice'';

-- Delete
DELETE FROM students WHERE id = 1;
```

### Joins
```sql
SELECT s.name, c.title
FROM students s
JOIN enrollments e ON s.id = e.student_id
JOIN courses c ON e.course_id = c.id;
```

### Aggregate Functions
```sql
SELECT COUNT(*), AVG(gpa), MAX(gpa) FROM students;
```

### Exercise
Design a database schema for a simple library system with books, members, and loans!'
),
(
    'Node.js Fundamentals',
    'Run JavaScript on the server with Node.js.',
    '## Node.js — JavaScript on the Server

Node.js lets you run JavaScript outside the browser, enabling backend development.

### Hello World Server
```javascript
const http = require("http");

const server = http.createServer((req, res) => {
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end("Hello from Node.js!");
});

server.listen(3000, () => {
    console.log("Server running on port 3000");
});
```

### File System
```javascript
const fs = require("fs");

// Read file
fs.readFile("data.txt", "utf8", (err, data) => {
    if (err) throw err;
    console.log(data);
});

// Write file
fs.writeFileSync("output.txt", "Hello, File!");
```

### npm Packages
```bash
npm init -y
npm install express
```

### Exercise
Build a simple Node.js server that returns different responses for `/`, `/about`, and `/contact`!'
),
(
    'Express.js Web Framework',
    'Build web applications quickly with Express.',
    '## Express.js — Minimal Node.js Framework

### Setup
```bash
npm install express
```

### Basic Server
```javascript
const express = require("express");
const app = express();

app.use(express.json());

app.get("/", (req, res) => {
    res.send("Welcome!");
});

app.get("/users/:id", (req, res) => {
    const { id } = req.params;
    res.json({ id, name: "Alice" });
});

app.post("/users", (req, res) => {
    const { name, email } = req.body;
    // save to DB...
    res.status(201).json({ message: "User created", name });
});

app.listen(8080, () => console.log("Running on :8080"));
```

### Middleware
```javascript
// Logging middleware
app.use((req, res, next) => {
    console.log(`${req.method} ${req.url}`);
    next();
});
```

### Exercise
Build a REST API with Express that manages a to-do list (CRUD) stored in memory!'
),
(
    'Authentication & JWT',
    'Secure your APIs with JSON Web Tokens.',
    '## Authentication with JWT

JWT (JSON Web Token) is a compact way to securely transmit user identity between client and server.

### JWT Structure
```
header.payload.signature

eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiQWxpY2UifQ.xxx
```

### Login Flow
1. User sends `username` + `password`
2. Server verifies credentials
3. Server returns a **JWT token**
4. Client stores the token (localStorage)
5. Client sends token in every request header:
```
Authorization: Bearer <token>
```

### Go Example
```go
import "github.com/golang-jwt/jwt/v5"

token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
    "user": "Alice",
    "exp":  time.Now().Add(24 * time.Hour).Unix(),
})
signed, _ := token.SignedString([]byte("secret"))
```

### Security Rules
- Never store secrets in JWT payload
- Always use HTTPS
- Set short expiration times
- Use refresh tokens for long sessions

### Exercise
Add JWT authentication to your Express API from the previous lesson!'
),
(
    'Docker Basics',
    'Package and run apps in containers.',
    '## Docker — Ship Your App Anywhere

Docker packages your application and all its dependencies into a **container** — works the same everywhere.

### Key Concepts
- **Image**: Blueprint for a container (like a class)
- **Container**: Running instance of an image (like an object)
- **Dockerfile**: Instructions to build an image

### Dockerfile Example
```dockerfile
FROM node:22-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

### Common Commands
```bash
docker build -t my-app .       # build image
docker run -p 3000:3000 my-app # run container
docker ps                      # list running containers
docker stop <id>               # stop container
docker logs <id>               # view logs
```

### Docker Compose
```yaml
services:
  app:
    build: .
    ports:
      - "3000:3000"
  db:
    image: postgres:15-alpine
```

### Exercise
Containerize your Node.js/Express app from previous lessons using Docker!'
),
(
    'CSS Flexbox In Depth',
    'Master layout with CSS Flexbox.',
    '## CSS Flexbox — Complete Guide

Flexbox makes it easy to align and distribute items in a container.

### Flex Container Properties
```css
.container {
    display: flex;
    flex-direction: row;       /* row | column */
    justify-content: center;   /* main axis alignment */
    align-items: center;       /* cross axis alignment */
    flex-wrap: wrap;           /* allow wrapping */
    gap: 1rem;                 /* spacing between items */
}
```

### Justify Content Values
| Value | Effect |
|-------|--------|
| `flex-start` | Pack to start |
| `flex-end` | Pack to end |
| `center` | Center all |
| `space-between` | Equal gaps between |
| `space-around` | Equal gaps around |

### Flex Item Properties
```css
.item {
    flex: 1;          /* grow to fill space */
    flex-shrink: 0;   /* do not shrink */
    align-self: flex-end; /* override parent alignment */
    order: 2;         /* change visual order */
}
```

### Exercise
Build a navbar with logo on the left and links on the right using only Flexbox!'
),
(
    'CSS Grid In Depth',
    'Create complex layouts with CSS Grid.',
    '## CSS Grid — 2D Layout System

Grid is perfect for complex, two-dimensional layouts.

### Define a Grid
```css
.grid {
    display: grid;
    grid-template-columns: 250px 1fr 1fr;
    grid-template-rows: auto;
    gap: 1.5rem;
}
```

### Named Areas
```css
.layout {
    display: grid;
    grid-template-areas:
        "header header"
        "sidebar main"
        "footer footer";
    grid-template-columns: 200px 1fr;
}

header { grid-area: header; }
aside  { grid-area: sidebar; }
main   { grid-area: main; }
footer { grid-area: footer; }
```

### Responsive Grid
```css
.cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1rem;
}
```

### Exercise
Build a full page layout with header, sidebar, main content, and footer using CSS Grid!'
),
(
    'JavaScript ES6+ Features',
    'Modern JavaScript syntax every developer should know.',
    '## Modern JavaScript (ES6+)

### Destructuring
```javascript
const { name, age } = user;
const [first, second, ...rest] = array;
```

### Spread & Rest
```javascript
const merged = { ...obj1, ...obj2 };
const combined = [...arr1, ...arr2];

function sum(...nums) {
    return nums.reduce((a, b) => a + b, 0);
}
```

### Optional Chaining & Nullish Coalescing
```javascript
const city = user?.address?.city ?? "Unknown";
```

### Promises & Async/Await
```javascript
async function fetchUser(id) {
    try {
        const res = await fetch(`/api/users/${id}`);
        const data = await res.json();
        return data;
    } catch (err) {
        console.error(err);
    }
}
```

### Array Methods
```javascript
const doubled = nums.map(n => n * 2);
const evens   = nums.filter(n => n % 2 === 0);
const sum     = nums.reduce((acc, n) => acc + n, 0);
const found   = nums.find(n => n > 10);
```

### Exercise
Refactor a callback-based function into async/await style!'
),
(
    'Web Security Fundamentals',
    'Protect your web applications from common attacks.',
    '## Web Security — Protect Your App

### XSS (Cross-Site Scripting)
An attacker injects malicious scripts into your page.

**Prevention:**
- Always escape user input before displaying
- Use `Content-Security-Policy` header
- Never use `innerHTML` with untrusted data

```javascript
// BAD
element.innerHTML = userInput;

// GOOD
element.textContent = userInput;
```

### SQL Injection
Attacker injects SQL into your query.

```sql
-- VULNERABLE
"SELECT * FROM users WHERE name = '" + input + "'"

-- SAFE (parameterized query)
db.Query("SELECT * FROM users WHERE name = $1", input)
```

### CSRF (Cross-Site Request Forgery)
Tricks users into making unwanted requests.

**Prevention:** Use CSRF tokens in forms.

### Common Security Headers
```
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
Strict-Transport-Security: max-age=31536000
Content-Security-Policy: default-src ''self''
```

### Exercise
Audit your previous projects for XSS and SQL injection vulnerabilities!'
),
(
    'Fetch API & AJAX',
    'Load data without refreshing the page.',
    '## Fetch API — Async Data Loading

The Fetch API lets you load data from a server without refreshing the page.

### Basic GET Request
```javascript
fetch("/api/users")
    .then(res => res.json())
    .then(data => console.log(data))
    .catch(err => console.error(err));
```

### With Async/Await
```javascript
async function loadUsers() {
    const res  = await fetch("/api/users");
    const data = await res.json();
    return data;
}
```

### POST Request
```javascript
const res = await fetch("/api/users", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name: "Alice", email: "alice@example.com" })
});
const result = await res.json();
```

### Error Handling
```javascript
if (!res.ok) {
    throw new Error(`HTTP error! status: ${res.status}`);
}
```

### Exercise
Build a page that fetches and displays a list of users from an API, with a loading spinner while waiting!'
),
(
    'Introduction to React',
    'Build dynamic UIs with React components.',
    '## React — Component-Based UI

React is a JavaScript library for building user interfaces using reusable **components**.

### Your First Component
```javascript
function Greeting({ name }) {
    return <h1>Hello, {name}!</h1>;
}

// Usage
<Greeting name="Alice" />
```

### useState Hook
```javascript
import { useState } from "react";

function Counter() {
    const [count, setCount] = useState(0);

    return (
        <div>
            <p>Count: {count}</p>
            <button onClick={() => setCount(count + 1)}>+</button>
        </div>
    );
}
```

### useEffect Hook
```javascript
import { useEffect } from "react";

useEffect(() => {
    fetch("/api/data")
        .then(r => r.json())
        .then(setData);
}, []); // [] = run once on mount
```

### Conditional Rendering
```javascript
{isLoggedIn ? <Dashboard /> : <Login />}
{error && <p className="error">{error}</p>}
```

### Exercise
Build a simple React app that fetches and displays a list of posts from a public API!'
),
(
    'TypeScript Basics',
    'Add type safety to your JavaScript projects.',
    '## TypeScript — Typed JavaScript

TypeScript adds **static types** to JavaScript, catching errors before they reach production.

### Basic Types
```typescript
let name: string = "Alice";
let age: number = 20;
let active: boolean = true;
let scores: number[] = [95, 87, 92];
```

### Interfaces
```typescript
interface Student {
    id: number;
    name: string;
    gpa?: number; // optional
}

const s: Student = { id: 1, name: "Alice", gpa: 3.85 };
```

### Functions
```typescript
function greet(name: string): string {
    return `Hello, ${name}!`;
}

const add = (a: number, b: number): number => a + b;
```

### Union & Generic Types
```typescript
type ID = string | number;

function identity<T>(value: T): T {
    return value;
}
```

### Exercise
Convert a JavaScript project from a previous lesson into TypeScript!'
),
(
    'Svelte Fundamentals',
    'Build reactive UIs with minimal code using Svelte.',
    '## Svelte — Write Less, Do More

Svelte compiles your components at build time — no virtual DOM, blazing fast.

### Component Structure
```svelte
<script>
    let name = "World";
    let count = 0;
</script>

<h1>Hello, {name}!</h1>
<button on:click={() => count++}>
    Clicked {count} times
</button>

<style>
    h1 { color: steelblue; }
</style>
```

### Reactive Declarations
```svelte
<script>
    let width = 5;
    let height = 10;
    $: area = width * height;
</script>

<p>Area: {area}</p>
```

### Each & If Blocks
```svelte
{#each items as item}
    <li>{item.name}</li>
{/each}

{#if user}
    <Dashboard {user} />
{:else}
    <Login />
{/if}
```

### Exercise
Build a Svelte component that lets users add and remove items from a shopping list!'
),
(
    'CI/CD with GitHub Actions',
    'Automate testing and deployment with GitHub Actions.',
    '## CI/CD — Automate Your Workflow

CI/CD (Continuous Integration / Continuous Deployment) automates building, testing, and deploying your code.

### Basic Workflow
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 22

      - name: Install dependencies
        run: npm install

      - name: Run tests
        run: npm test

      - name: Build
        run: npm run build
```

### Deploy to Server
```yaml
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: deploy
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /app
            git pull
            docker compose up -d --build
```

### Exercise
Set up a GitHub Actions workflow that lints and tests your code on every pull request!'
),
(
    'Performance Optimization',
    'Make your web applications load and run faster.',
    '## Web Performance Optimization

Fast sites have better SEO, lower bounce rates, and happier users.

### Measuring Performance
Use **Lighthouse** in Chrome DevTools — gives you scores for:
- Performance
- Accessibility
- SEO
- Best Practices

### Core Web Vitals
| Metric | Meaning | Good |
|--------|---------|------|
| LCP | Largest Contentful Paint | < 2.5s |
| FID | First Input Delay | < 100ms |
| CLS | Cumulative Layout Shift | < 0.1 |

### Techniques
**Images:**
```html
<img src="photo.webp" loading="lazy" width="800" height="600">
```

**JavaScript:**
```javascript
// Code splitting — load only what is needed
const Chart = await import("./Chart.js");
```

**CSS:**
```css
/* Critical CSS inline, rest deferred */
@font-display: swap; /* prevent invisible text */
```

**Caching:**
```
Cache-Control: public, max-age=31536000, immutable
```

### Exercise
Run Lighthouse on your project and fix the top 3 issues it reports!'
),
(
    'Deployment & Cloud Hosting',
    'Get your web application live on the internet.',
    '## Deploying Your Web App

### Popular Hosting Options
| Platform | Best For | Free Tier |
|----------|---------|-----------|
| Vercel | Frontend / Next.js | Yes |
| Railway | Full stack / Docker | Yes |
| Fly.io | Docker apps | Yes |
| AWS EC2 | Full control | Limited |
| DigitalOcean | VPS / Docker | No |

### Deploy with Docker Compose (VPS)
```bash
# On your server
git clone https://github.com/you/project.git
cd project
docker compose up -d --build

# Check status
docker compose ps
docker compose logs -f
```

### Environment Variables
Never hard-code secrets. Use a `.env` file:
```
DATABASE_URL=postgres://user:pass@host/db
JWT_SECRET=supersecretkey
```

```yaml
# docker-compose.yml
services:
  app:
    env_file: .env
```

### Reverse Proxy with Nginx
```nginx
server {
    listen 80;
    server_name example.com;
    location / {
        proxy_pass http://localhost:3000;
    }
}
```

### Exercise
Deploy your project to a free cloud platform and share the live URL!'
),
(
    'Capstone: Full-Stack Web App',
    'Build a complete web application from scratch.',
    '## Capstone Project — Full-Stack Web App

You now have all the skills to build a **complete web application**!

### Project Requirements
Build a web app that includes:

1. **Frontend** — HTML, CSS, JavaScript (or Svelte/React)
2. **Backend** — REST API (Go, Node.js, or Python)
3. **Database** — PostgreSQL or SQLite
4. **Authentication** — JWT login/register
5. **Docker** — Containerized with docker-compose
6. **Deployment** — Live on a cloud platform

### Suggested Project Ideas
- **Study Tracker**: Log subjects, hours studied, and progress
- **Expense Tracker**: Record income/expenses with charts
- **Recipe Manager**: Store and search recipes with images
- **Task Manager**: Kanban board with drag-and-drop

### Recommended Stack
```
Frontend:  Svelte / React
Backend:   Go / Express.js
Database:  PostgreSQL
Deploy:    Docker + Railway / Fly.io
```

### Evaluation Criteria
- Does the app work end-to-end?
- Is the code clean and well-organized?
- Is the UI responsive and user-friendly?
- Is the API secure (auth, input validation)?

### Exercise
Start building your capstone project! Plan the database schema and API routes first, then implement feature by feature.'
)
ON CONFLICT (title) DO UPDATE SET content = EXCLUDED.content;
