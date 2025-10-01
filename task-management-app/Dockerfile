# Task Management App - Multi-Stage Dockerfile
# Go Backend + Svelte Frontend + CouchDB
# Optimized for concurrent task processing

# Frontend Build Stage
FROM node:18-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# Backend Build Stage
FROM golang:1.23-alpine AS backend-builder
WORKDIR /app/backend

# Install build dependencies
RUN apk add --no-cache git ca-certificates

# Copy go mod files
COPY backend/go.mod backend/go.sum ./
RUN go mod download

# Copy source code
COPY backend/ ./

# Build the application
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o main .

# Production Runtime Stage
FROM alpine:3.18 AS production
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S taskuser && \
    adduser -S taskuser -u 1001 -G taskuser && \
    apk add --no-cache ca-certificates curl

# Copy backend binary
COPY --from=backend-builder /app/backend/main ./

# Copy frontend build
COPY --from=frontend-builder /app/frontend/build ./static

# Create necessary directories
RUN mkdir -p logs uploads && \
    chown -R taskuser:taskuser /app

# Switch to non-root user
USER taskuser

# Environment variables
ENV GIN_MODE=release
ENV PORT=8080
ENV STATIC_DIR=/app/static

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Expose port
EXPOSE 8080

# Start application
CMD ["./main"]