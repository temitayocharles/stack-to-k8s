# Social Media Platform - Ruby on Rails Backend
FROM ruby:3.2-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    postgresql-client \
    nodejs \
    npm \
    git \
    curl \
    yaml-dev

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock (if exists)
COPY Gemfile* ./

# Install gems
RUN bundle install

# Copy application code
COPY . .

# Make startup script executable  
RUN chmod +x docker-entrypoint.sh

# Create necessary directories
RUN mkdir -p tmp/pids log

# Precompile assets (if any)
# RUN RAILS_ENV=production bundle exec rails assets:precompile

# Create non-root user
RUN adduser -D -s /bin/sh railsuser && \
    chown -R railsuser:railsuser /app
USER railsuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start the Rails server
CMD ["sh", "docker-entrypoint.sh"]