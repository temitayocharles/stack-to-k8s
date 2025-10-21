#!/usr/bin/env ruby
# Database setup for Social Media Platform

require 'pg'

# Database configuration
DB_HOST = ENV['DATABASE_HOST'] || 'social-media-db'
DB_PORT = ENV['DATABASE_PORT'] || '5432'
DB_NAME = ENV['DATABASE_NAME'] || 'social_media'
DB_USER = ENV['DATABASE_USERNAME'] || 'postgres'
DB_PASSWORD = ENV['DATABASE_PASSWORD'] || 'postgres'

begin
  # Connect to PostgreSQL
  conn = PG.connect(
    host: DB_HOST,
    port: DB_PORT,
    dbname: DB_NAME,
    user: DB_USER,
    password: DB_PASSWORD
  )

  puts "✅ Connected to database successfully"

  # Create posts table if it doesn't exist
  conn.exec <<-SQL
    CREATE TABLE IF NOT EXISTS posts (
      id SERIAL PRIMARY KEY,
      content TEXT NOT NULL,
      author VARCHAR(255) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      likes INTEGER DEFAULT 0,
      shares INTEGER DEFAULT 0
    );
  SQL

  # Create users table if it doesn't exist
  conn.exec <<-SQL
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      username VARCHAR(255) UNIQUE NOT NULL,
      email VARCHAR(255) UNIQUE NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  SQL

  # Create comments table if it doesn't exist
  conn.exec <<-SQL
    CREATE TABLE IF NOT EXISTS comments (
      id SERIAL PRIMARY KEY,
      post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE,
      content TEXT NOT NULL,
      author VARCHAR(255) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  SQL

  puts "✅ Database tables created successfully"

  # Insert sample data if tables are empty
  result = conn.exec("SELECT COUNT(*) FROM posts")
  post_count = result[0]['count'].to_i

  if post_count == 0
    conn.exec <<-SQL
      INSERT INTO posts (content, author, likes, shares) VALUES
      ('Welcome to our Social Media Platform! 🎉', 'admin', 15, 3),
      ('Building amazing full-stack applications with Ruby and React! 💻', 'developer', 8, 2),
      ('Just deployed our social media platform to production! 🚀', 'devops', 12, 5);
    SQL

    conn.exec <<-SQL
      INSERT INTO users (username, email) VALUES
      ('admin', 'admin@socialmedia.com'),
      ('developer', 'dev@socialmedia.com'),
      ('devops', 'devops@socialmedia.com');
    SQL

    puts "✅ Sample data inserted successfully"
  else
    puts "✅ Database already contains data"
  end

  conn.close
  puts "🎯 Database setup completed successfully"

rescue PG::Error => e
  puts "❌ Database error: #{e.message}"
  exit 1
rescue => e
  puts "❌ Setup error: #{e.message}"
  exit 1
end