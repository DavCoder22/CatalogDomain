FROM golang:1.21-alpine

WORKDIR /app

# Copiar go.mod y go.sum
COPY go.mod go.sum ./
RUN go mod download

# Copiar el resto del código
COPY . .

# Construir el ejecutable
RUN go build -o main .

# Ejecutar el servicio
CMD ["./main"]
