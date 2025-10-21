# Social Media Platform - Multi-Stage Dockerfile
# Ruby on Rails API + React Native Web Frontend
# Optimized for massive scale and performance

# Frontend Build Stage
FROM node:18-alpine AS frontend-builder
WORKDIR /app/frontend

# Install Python for node-gyp (needed for some React Native dependencies)
RUN apk add --no-cache python3 make g++

COPY frontend/package*.json ./
RUN npm install --legacy-peer-deps
COPY frontend/ ./
RUN npm run build

# Backend Build Stage
FROM ruby:3.2-alpine AS backend-builder
WORKDIR /app/backend

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    nodejs \
    npm \
    git \
    curl

# Copy Gemfile
COPY backend/Gemfile backend/Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install

# Copy source code
COPY backend/ ./

# Precompile assets (if any)
RUN RAILS_ENV=production bundle exec rake assets:precompile 2>/dev/null || true

# Production Runtime Stage
FROM ruby:3.2-alpine AS production
WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache \
    postgresql-client \
    curl \
    ca-certificates \
    tzdata

# Create non-root user
RUN addgroup -g 1001 -S socialuser && \
    adduser -S socialuser -u 1001 -G socialuser

# Copy gems from builder
COPY --from=backend-builder /usr/local/bundle /usr/local/bundle

# Copy backend application
COPY --from=backend-builder /app/backend ./

    # Copy frontend build
    COPY --from=frontend-builder /app/frontend/web-build ./public
    
    # Create necessary directories
RUN mkdir -p log tmp/pids uploads && \
    chown -R socialuser:socialuser /app

# Switch to non-root user
USER socialuser

# Environment variables
ENV RAILS_ENV=production
ENV RACK_ENV=production
ENV PORT=3000
ENV RAILS_SERVE_STATIC_FILES=true

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Expose port
EXPOSE 3000

# Start application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]