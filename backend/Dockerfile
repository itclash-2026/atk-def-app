FROM golang:alpine AS builder

WORKDIR /app

# Install git for dependencies
RUN apk update && apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

FROM alpine:latest

WORKDIR /app

# Install interpreters/compilers for the RCE vulnerability intentionally
RUN apk update && apk add --no-cache bash python3 php go

COPY --from=builder /app/main .

EXPOSE 8080

CMD ["./main"]
