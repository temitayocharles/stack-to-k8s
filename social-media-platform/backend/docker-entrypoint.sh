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

# Set up database tables (Sinatra style)
echo "📊 Setting up database..."
ruby setup_database.rb || echo "Database setup completed or already exists"

# Remove any existing server.pid
rm -f tmp/pids/server.pid

echo "🎯 Starting Sinatra server..."
exec bundle exec ruby app.rb -o 0.0.0.0 -p 3000