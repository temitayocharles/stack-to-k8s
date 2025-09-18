#!/bin/sh
set -e

echo "🚀 Starting Social Media Platform Backend..."

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
until pg_isready -h "${DATABASE_HOST}" -p "${DATABASE_PORT}" -U "${DATABASE_USERNAME}"; do
  echo "Database is unavailable - sleeping"
  sleep 2
done

echo "✅ Database is ready!"

# Create database if it doesn't exist
echo "📊 Setting up database..."
bundle exec rails db:create

# Run pending migrations
echo "🔄 Running database migrations..."
bundle exec rails db:migrate

# Seed database if in development
if [ "$RAILS_ENV" = "development" ]; then
  echo "🌱 Seeding database..."
  bundle exec rails db:seed || echo "Seeding failed or already done"
fi

# Remove any existing server.pid
rm -f tmp/pids/server.pid

echo "🎯 Starting Rails server..."
exec bundle exec rails server -b 0.0.0.0 -p 3000