# E-commerce Platform - Multi-Stage Docker Build
# This Dockerfile creates an optimized production image

# Stage 1: Build Frontend
FROM node:18-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# Stage 2: Build Backend
FROM node:18-alpine AS backend-builder
WORKDIR /app/backend
COPY backend/package*.json ./
RUN npm install
COPY backend/ ./

# Stage 3: Production Runtime
FROM node:18-alpine AS production
WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Install curl for health checks
RUN apk add --no-cache curl

# Copy backend application
COPY --from=backend-builder --chown=nodejs:nodejs /app/backend ./

# Copy built frontend
COPY --from=frontend-builder --chown=nodejs:nodejs /app/frontend/build ./public

# Install production dependencies only
RUN npm install --only=production && npm cache clean --force

# Security: Remove npm cache
RUN rm -rf ~/.npm

# Health check for backend
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 5000

# Environment variables
ENV NODE_ENV=production
ENV PORT=5000

# Start application
CMD ["node", "server.js"]
