# Stage 1: Build
FROM golang:1.25-alpine AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Stage 2: Distroless Runtime
FROM gcr.io/distroless/static-debian12
WORKDIR /
COPY --from=builder /app/main .
EXPOSE 8080
ENTRYPOINT ["/main"]
