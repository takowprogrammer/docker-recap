-- Database initialization script for Student Management System
-- This script creates the database, user, and initial data

-- Create database
CREATE DATABASE student_db;

-- Create user
CREATE USER student_user WITH PASSWORD 'student_pass';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE student_db TO student_user;

-- Connect to the database
\c student_db;

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO student_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO student_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO student_user;

-- Create students table
CREATE TABLE IF NOT EXISTS students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    age INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index on name for faster lookups
CREATE INDEX IF NOT EXISTS idx_students_name ON students(name);

-- Insert initial data
INSERT INTO students (name, age) VALUES 
    ('alice', 12),
    ('bob', 13)
ON CONFLICT (name) DO NOTHING;

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_students_updated_at 
    BEFORE UPDATE ON students 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
