# E-commerce Backend - Production Ready Dockerfile
FROM node:18-alpine AS production

WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Install curl for health checks
RUN apk add --no-cache curl

# Copy package files first for better layer caching
COPY package*.json ./

# Install production dependencies
RUN npm install --omit=dev && npm cache clean --force

# Copy application code
COPY . .

# Change ownership to nodejs user
RUN chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 5000

# Environment variables
ENV NODE_ENV=production
ENV PORT=5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

# Start application
CMD ["node", "server.js"]