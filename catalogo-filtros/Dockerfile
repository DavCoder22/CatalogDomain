FROM golang:1.23-alpine AS builder

# Instalar git para go mod download
RUN apk add --no-cache git

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o main .

FROM alpine:latest

# Instalar curl para health checks
RUN apk add --no-cache curl

WORKDIR /app

COPY --from=builder /app/main .

EXPOSE 8084

CMD ["./main"]
