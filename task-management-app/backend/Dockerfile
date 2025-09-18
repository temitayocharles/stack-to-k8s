# Single-stage build for debugging
FROM golang:1.23-alpine

# Install build dependencies and file command
RUN apk add --no-cache git ca-certificates tzdata file

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application with correct architecture for ARM64
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -installsuffix cgo -o main . && \
    file main && \
    ls -la main

# Create non-root user
RUN addgroup -g 1001 -S appuser && \
    adduser -S appuser -u 1001 -G appuser

# Change ownership to non-root user
RUN chown appuser:appuser main

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Set environment variables
ENV PORT=8080

# Start application
CMD ["./main"]
