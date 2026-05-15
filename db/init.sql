CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (username, email, password_hash) VALUES
    ('admin',     'admin@kmitl.ac.th',     'admin123'),
    ('student01', 'student01@kmitl.ac.th', 'student123'),
    ('student02', 'student02@kmitl.ac.th', 'student123'),
    ('student03', 'student03@kmitl.ac.th', 'student123'),
    ('student04', 'student04@kmitl.ac.th', 'student123'),
    ('student05', 'student05@kmitl.ac.th', 'student123')
ON CONFLICT (username) DO NOTHING;

CREATE TABLE IF NOT EXISTS lessons (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    content TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO lessons (title, description, content) VALUES
(
    'Introduction to Internet',
    'Learn the basics of how the internet works.',
    '## What is the Internet?

The Internet is a global network of interconnected computers that communicate using standardized protocols such as **TCP/IP**.

### How it works
1. Your device sends a request through your **ISP** (Internet Service Provider).
2. The request travels through routers and switches across the network.
3. It reaches the destination **server**, which processes the request.
4. The server sends back a **response** with the requested data.

### Key Concepts
- **IP Address**: A unique identifier for every device on the network (e.g. `192.168.1.1`).
- **DNS**: Domain Name System translates human-readable domain names (like `google.com`) into IP addresses.
- **HTTP/HTTPS**: Protocols used for transferring web pages. HTTPS adds encryption for security.
- **TCP/IP**: The foundational communication protocol of the Internet.

### Try it yourself
Open your terminal and type:
```
ping google.com
```
This sends small packets to Google''s server and measures the response time!'
),
(
    'HTML5 Foundation',
    'Structure your web pages with semantic HTML.',
    '## HTML5 — The Backbone of the Web

HTML (HyperText Markup Language) defines the **structure** of web pages using elements and tags.

### Basic Structure
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My First Page</title>
</head>
<body>
    <h1>Hello, World!</h1>
    <p>This is my first web page.</p>
</body>
</html>
```

### Semantic HTML5 Elements
Use meaningful tags instead of generic `<div>`:
- `<header>` — Top section of a page
- `<nav>` — Navigation links
- `<main>` — Primary content area
- `<article>` — Self-contained content
- `<section>` — Thematic grouping
- `<footer>` — Bottom section of a page

### Common Tags
| Tag | Purpose |
|-----|---------|
| `<h1>` to `<h6>` | Headings (h1 is biggest) |
| `<p>` | Paragraph |
| `<a>` | Hyperlink |
| `<img>` | Image |
| `<ul>`, `<ol>` | Lists |
| `<form>` | User input form |

### Exercise
Create a simple HTML page with a heading, a paragraph, and a link to your favorite website!'
),
(
    'CSS3 Styling',
    'Make your web pages beautiful with CSS.',
    '## CSS3 — Making the Web Beautiful

CSS (Cascading Style Sheets) controls the **visual presentation** of HTML elements.

### Three Ways to Add CSS
1. **Inline**: `<p style="color: red;">Hello</p>`
2. **Internal**: `<style>` tag in the `<head>`
3. **External**: Separate `.css` file (recommended!)

### CSS Selectors
```css
/* Element selector */
p { color: blue; }

/* Class selector */
.highlight { background-color: yellow; }

/* ID selector */
#main-title { font-size: 2rem; }
```

### The Box Model
Every HTML element is a box with:
- **Content** — The actual text/image
- **Padding** — Space between content and border
- **Border** — The edge of the element
- **Margin** — Space outside the border

### Flexbox Layout
```css
.container {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 1rem;
}
```

### CSS Grid
```css
.grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
}
```

### Exercise
Style your HTML page from the previous lesson with colors, fonts, and a flexbox layout!'
),
(
    'JavaScript Basics',
    'Add interactivity to your projects.',
    '## JavaScript — Bringing Pages to Life

JavaScript is a programming language that adds **interactivity** and **dynamic behavior** to websites.

### Variables
```javascript
let name = "Student";        // can be reassigned
const PI = 3.14159;          // cannot be reassigned
```

### Data Types
- **String**: `"Hello, World!"`
- **Number**: `42`, `3.14`
- **Boolean**: `true`, `false`
- **Array**: `[1, 2, 3]`
- **Object**: `{ name: "John", age: 20 }`

### Functions
```javascript
function greet(name) {
    return `Hello, ${name}!`;
}

// Arrow function
const add = (a, b) => a + b;
```

### DOM Manipulation
```javascript
// Select an element
const title = document.querySelector("h1");

// Change its content
title.textContent = "New Title!";

// Add an event listener
const btn = document.querySelector("#myBtn");
btn.addEventListener("click", () => {
    alert("Button clicked!");
});
```

### Exercise
Create a button that changes the background color of the page when clicked!'
),
(
    'Responsive Web Design',
    'Ensure your sites look good on all devices.',
    '## Responsive Web Design

Responsive design ensures your website looks great on **all screen sizes** — from phones to desktops.

### The Viewport Meta Tag
Always include this in your `<head>`:
```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

### Media Queries
```css
/* Default styles (mobile first) */
.container {
    padding: 1rem;
}

/* Tablet (768px and up) */
@media (min-width: 768px) {
    .container {
        padding: 2rem;
        max-width: 720px;
    }
}

/* Desktop (1024px and up) */
@media (min-width: 1024px) {
    .container {
        max-width: 960px;
    }
}
```

### Responsive Images
```css
img {
    max-width: 100%;
    height: auto;
}
```

### Responsive Units
| Unit | Description |
|------|-------------|
| `%` | Relative to parent |
| `vw` | Viewport width |
| `vh` | Viewport height |
| `rem` | Relative to root font size |
| `em` | Relative to parent font size |

### Mobile-First Approach
1. Design for the smallest screen first
2. Add complexity as the screen gets larger
3. Use `min-width` media queries (not `max-width`)

### Exercise
Take your previous project and make it fully responsive using media queries and flexible units!'
)
ON CONFLICT (title) DO UPDATE SET content = EXCLUDED.content;

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

### REST Example
```bash
GET /api/users
GET /api/users/42
POST /api/users
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
fruits.append("grape")
fruits.remove("banana")
print(fruits[0])
```

### List Comprehension
```python
squares = [x**2 for x in range(10)]
evens   = [x for x in range(20) if x % 2 == 0]
```

### Dictionaries
```python
student = {"name": "Alice", "age": 20, "gpa": 3.85}
print(student["name"])
student["major"] = "CS"
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
    for line in f:
        print(line.strip())
```

### Writing a File
```python
with open("output.txt", "w") as f:
    f.write("Hello, File!\n")

# Append
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
Write a script that reads a text file, counts words, and writes the result to a new file!'
),
(
    'Introduction to Go',
    'Learn the basics of the Go programming language.',
    '## Go — Fast, Simple, Reliable

Go (Golang) is a compiled language by Google — great for backends and systems.

### Hello World
```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
```

### Variables & Functions
```go
name := "Alice"
var age int = 20

func add(a, b int) int {
    return a + b
}
```

### Loops
```go
for i := 0; i < 5; i++ {
    fmt.Println(i)
}
```

### Error Handling
```go
result, err := divide(10, 0)
if err != nil {
    fmt.Println("Error:", err)
}
```

### Exercise
Write a Go program that calculates the factorial of a number!'
),
(
    'Go Structs & Interfaces',
    'Model real-world data with Go structs.',
    '## Structs & Interfaces in Go

### Defining a Struct
```go
type Student struct {
    Name string
    Age  int
    GPA  float64
}

s := Student{Name: "Alice", Age: 20, GPA: 3.85}
fmt.Println(s.Name)
```

### Methods
```go
func (s Student) IsHonors() bool {
    return s.GPA >= 3.5
}
```

### Interfaces
```go
type Greeter interface {
    Greet() string
}

func (s Student) Greet() string {
    return "Hi, I am " + s.Name
}
```

### Exercise
Create a `Shape` interface with `Area()` method, then implement it for `Circle` and `Rectangle`!'
),
(
    'SQL & Databases',
    'Store and query data with SQL.',
    '## SQL — Structured Query Language

### Create Table
```sql
CREATE TABLE students (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    gpa  DECIMAL(3,2)
);
```

### CRUD
```sql
INSERT INTO students (name, gpa) VALUES (''Alice'', 3.85);
SELECT * FROM students WHERE gpa > 3.5 ORDER BY gpa DESC;
UPDATE students SET gpa = 3.90 WHERE name = ''Alice'';
DELETE FROM students WHERE id = 1;
```

### Joins
```sql
SELECT s.name, c.title
FROM students s
JOIN enrollments e ON s.id = e.student_id
JOIN courses c ON e.course_id = c.id;
```

### Exercise
Design a schema for a library system with books, members, and loans!'
),
(
    'Node.js Fundamentals',
    'Run JavaScript on the server with Node.js.',
    '## Node.js — JavaScript on the Server

### Hello World Server
```javascript
const http = require("http");

const server = http.createServer((req, res) => {
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end("Hello from Node.js!");
});

server.listen(3000, () => console.log("Running on :3000"));
```

### File System
```javascript
const fs = require("fs");
const data = fs.readFileSync("file.txt", "utf8");
fs.writeFileSync("output.txt", "Hello!");
```

### npm
```bash
npm init -y
npm install express
```

### Exercise
Build a server that returns different responses for `/`, `/about`, `/contact`!'
),
(
    'Express.js Web Framework',
    'Build web applications quickly with Express.',
    '## Express.js — Minimal Node.js Framework

### Basic Server
```javascript
const express = require("express");
const app = express();
app.use(express.json());

app.get("/users/:id", (req, res) => {
    res.json({ id: req.params.id, name: "Alice" });
});

app.post("/users", (req, res) => {
    const { name } = req.body;
    res.status(201).json({ message: "Created", name });
});

app.listen(8080, () => console.log("Running on :8080"));
```

### Middleware
```javascript
app.use((req, res, next) => {
    console.log(`${req.method} ${req.url}`);
    next();
});
```

### Exercise
Build a CRUD REST API for a to-do list stored in memory!'
),
(
    'Authentication & JWT',
    'Secure your APIs with JSON Web Tokens.',
    '## Authentication with JWT

### Login Flow
1. Client sends `username` + `password`
2. Server verifies → returns **JWT**
3. Client stores token → sends in every request:
```
Authorization: Bearer <token>
```

### JWT Structure
```
header.payload.signature
```

### Go Example
```go
token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
    "user": "Alice",
    "exp":  time.Now().Add(24 * time.Hour).Unix(),
})
signed, _ := token.SignedString([]byte("secret"))
```

### Security Rules
- Never store secrets in payload
- Always use HTTPS
- Set short expiration times

### Exercise
Add JWT authentication to your Express API!'
),
(
    'Docker Basics',
    'Package and run apps in containers.',
    '## Docker — Ship Your App Anywhere

### Dockerfile
```dockerfile
FROM node:22-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

### Commands
```bash
docker build -t my-app .
docker run -p 3000:3000 my-app
docker ps
docker stop <id>
docker logs <id>
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
Containerize your Express app using Docker!'
),
(
    'CSS Flexbox In Depth',
    'Master layout with CSS Flexbox.',
    '## CSS Flexbox — Complete Guide

### Container
```css
.container {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 1rem;
}
```

### Justify-Content Values
| Value | Effect |
|-------|--------|
| `flex-start` | Pack to start |
| `center` | Center all |
| `space-between` | Gaps between items |
| `space-around` | Gaps around items |

### Item Properties
```css
.item {
    flex: 1;
    align-self: flex-end;
    order: 2;
}
```

### Exercise
Build a navbar with logo on the left and links on the right using Flexbox!'
),
(
    'CSS Grid In Depth',
    'Create complex layouts with CSS Grid.',
    '## CSS Grid — 2D Layout System

### Define a Grid
```css
.grid {
    display: grid;
    grid-template-columns: 250px 1fr 1fr;
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
Build a full page layout with header, sidebar, main content, and footer using Grid!'
),
(
    'JavaScript ES6+ Features',
    'Modern JavaScript syntax every developer should know.',
    '## Modern JavaScript (ES6+)

### Destructuring
```javascript
const { name, age } = user;
const [first, ...rest] = array;
```

### Spread & Rest
```javascript
const merged = { ...obj1, ...obj2 };
const combined = [...arr1, ...arr2];
```

### Optional Chaining
```javascript
const city = user?.address?.city ?? "Unknown";
```

### Async/Await
```javascript
async function fetchUser(id) {
    const res  = await fetch(`/api/users/${id}`);
    const data = await res.json();
    return data;
}
```

### Array Methods
```javascript
const doubled = nums.map(n => n * 2);
const evens   = nums.filter(n => n % 2 === 0);
const sum     = nums.reduce((acc, n) => acc + n, 0);
```

### Exercise
Refactor a callback-based function into async/await style!'
),
(
    'Web Security Fundamentals',
    'Protect your web applications from common attacks.',
    '## Web Security — Protect Your App

### XSS (Cross-Site Scripting)
Always escape user input:
```javascript
// BAD
element.innerHTML = userInput;
// GOOD
element.textContent = userInput;
```

### SQL Injection
Use parameterized queries:
```go
// SAFE
db.Query("SELECT * FROM users WHERE name = $1", input)
```

### Security Headers
```
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
Strict-Transport-Security: max-age=31536000
Content-Security-Policy: default-src ''self''
```

### CSRF
Use CSRF tokens in all state-changing forms.

### Exercise
Audit your previous projects for XSS and SQL injection vulnerabilities!'
),
(
    'Fetch API & AJAX',
    'Load data without refreshing the page.',
    '## Fetch API — Async Data Loading

### GET Request
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
    body: JSON.stringify({ name: "Alice" })
});
```

### Error Handling
```javascript
if (!res.ok) {
    throw new Error(`HTTP error ${res.status}`);
}
```

### Exercise
Build a page that fetches and displays users from an API with a loading spinner!'
),
(
    'Introduction to React',
    'Build dynamic UIs with React components.',
    '## React — Component-Based UI

### Component & Props
```javascript
function Greeting({ name }) {
    return <h1>Hello, {name}!</h1>;
}
```

### useState
```javascript
const [count, setCount] = useState(0);
<button onClick={() => setCount(count + 1)}>+</button>
```

### useEffect
```javascript
useEffect(() => {
    fetch("/api/data").then(r => r.json()).then(setData);
}, []);
```

### Conditional Rendering
```javascript
{isLoggedIn ? <Dashboard /> : <Login />}
{error && <p>{error}</p>}
```

### Exercise
Build a React app that fetches and displays posts from a public API!'
),
(
    'TypeScript Basics',
    'Add type safety to your JavaScript projects.',
    '## TypeScript — Typed JavaScript

### Basic Types
```typescript
let name: string = "Alice";
let age: number = 20;
let scores: number[] = [95, 87, 92];
```

### Interfaces
```typescript
interface Student {
    id: number;
    name: string;
    gpa?: number;
}
```

### Functions
```typescript
function greet(name: string): string {
    return `Hello, ${name}!`;
}
```

### Generics
```typescript
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

### Component
```svelte
<script>
    let count = 0;
</script>

<button on:click={() => count++}>
    Clicked {count} times
</button>
```

### Reactive Declarations
```svelte
<script>
    let w = 5, h = 10;
    $: area = w * h;
</script>
<p>Area: {area}</p>
```

### Each & If
```svelte
{#each items as item}
    <li>{item.name}</li>
{/each}

{#if user}
    <Dashboard />
{:else}
    <Login />
{/if}
```

### Exercise
Build a Svelte shopping list where users can add and remove items!'
),
(
    'CI/CD with GitHub Actions',
    'Automate testing and deployment with GitHub Actions.',
    '## CI/CD — Automate Your Workflow

### Basic Workflow
```yaml
name: CI
on:
  push:
    branches: [main]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      - run: npm install
      - run: npm test
      - run: npm run build
```

### Deploy via SSH
```yaml
      - uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.SERVER_HOST }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /app && git pull
            docker compose up -d --build
```

### Exercise
Set up a workflow that lints and tests your code on every pull request!'
),
(
    'Performance Optimization',
    'Make your web applications load and run faster.',
    '## Web Performance Optimization

### Core Web Vitals
| Metric | Meaning | Good |
|--------|---------|------|
| LCP | Largest Contentful Paint | < 2.5s |
| FID | First Input Delay | < 100ms |
| CLS | Cumulative Layout Shift | < 0.1 |

### Techniques
**Lazy load images:**
```html
<img src="photo.webp" loading="lazy">
```

**Code splitting:**
```javascript
const Chart = await import("./Chart.js");
```

**Caching:**
```
Cache-Control: public, max-age=31536000, immutable
```

**Font display:**
```css
@font-face {
    font-display: swap;
}
```

### Exercise
Run Lighthouse on your project and fix the top 3 performance issues!'
),
(
    'Deployment & Cloud Hosting',
    'Get your web application live on the internet.',
    '## Deploying Your Web App

### Hosting Options
| Platform | Best For | Free Tier |
|----------|---------|-----------|
| Vercel | Frontend / Next.js | Yes |
| Railway | Full stack / Docker | Yes |
| Fly.io | Docker apps | Yes |
| DigitalOcean | VPS | No |

### Deploy with Docker (VPS)
```bash
git clone https://github.com/you/project.git
cd project
docker compose up -d --build
docker compose ps
docker compose logs -f
```

### Nginx Reverse Proxy
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
Deploy your project to Railway or Fly.io and share the live URL!'
),
(
    'Capstone: Full-Stack Web App',
    'Build a complete web application from scratch.',
    '## Capstone Project — Full-Stack Web App

### Requirements
1. **Frontend** — HTML/CSS/JS or Svelte/React
2. **Backend** — REST API (Go, Node.js, or Python)
3. **Database** — PostgreSQL or SQLite
4. **Authentication** — JWT login/register
5. **Docker** — docker-compose setup
6. **Deployment** — Live on cloud

### Project Ideas
- Study Tracker
- Expense Tracker
- Recipe Manager
- Task/Kanban Board

### Recommended Stack
```
Frontend:  Svelte / React
Backend:   Go / Express.js
Database:  PostgreSQL
Deploy:    Docker + Railway
```

### Checklist
- [ ] Database schema designed
- [ ] API routes planned
- [ ] Auth working (login/register)
- [ ] Frontend connected to API
- [ ] Deployed and accessible

### Exercise
Start building! Plan the schema and API routes first, then implement feature by feature.'
)
ON CONFLICT (title) DO UPDATE SET content = EXCLUDED.content;


CREATE TABLE IF NOT EXISTS homeworks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    due_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS homework_submissions (
    id SERIAL PRIMARY KEY,
    homework_id INT REFERENCES homeworks(id) ON DELETE CASCADE,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    file_path VARCHAR(255) NOT NULL,
    extracted_path VARCHAR(255),
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO homeworks (title, description, due_date) VALUES 
('การบ้าน 1: สร้างหน้าเว็บประวัติส่วนตัว', 'ให้นักศึกษาสร้างหน้าเว็บประวัติส่วนตัว (Portfolio) ด้วย HTML และ CSS ให้มีความสวยงามและนำเสนอตัวตนของคุณได้อย่างชัดเจน บีบอัดไฟล์ทั้งหมดเป็น .zip แล้วส่ง', '2026-05-01 23:59:59'),
('การบ้าน 2: เขียนโปรแกรมคำนวณเกรด', 'ให้นักศึกษาเขียนโปรแกรมคำนวณเกรดด้วย JavaScript หรือ Go จากคะแนนที่รับเข้ามา โดยส่งเป็นไฟล์ Source Code', '2026-05-15 23:59:59');
