#!/usr/bin/env python3
"""
Advanced Student API with health checks, database integration, and environment configuration
"""
import os
import json
import logging
from flask import Flask, jsonify, request
from flask_httpauth import HTTPBasicAuth
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import psycopg2
from psycopg2.extras import RealDictCursor

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)

# Database configuration from environment
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'postgresql://student_user:student_pass@database:5432/student_db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize database
db = SQLAlchemy(app)

# Authentication
auth = HTTPBasicAuth()

# Database Models
class Student(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True)
    age = db.Column(db.Integer, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'age': self.age,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }

# Authentication
@auth.get_password
def get_password(username):
    if username == os.getenv('API_USERNAME', 'toto'):
        return os.getenv('API_PASSWORD', 'python')
    return None

@auth.error_handler
def unauthorized():
    return jsonify({'error': 'Unauthorized access'}), 401

# Health check endpoint
@app.route('/health')
def health_check():
    """Health check endpoint for Docker health monitoring"""
    try:
        # Check database connection
        db.session.execute('SELECT 1')
        return jsonify({
            'status': 'healthy',
            'timestamp': datetime.utcnow().isoformat(),
            'database': 'connected',
            'version': os.getenv('APP_VERSION', '1.0.0')
        }), 200
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        return jsonify({
            'status': 'unhealthy',
            'timestamp': datetime.utcnow().isoformat(),
            'error': str(e)
        }), 503

# API Routes
@app.route('/pozos/api/v1.0/get_student_ages', methods=['GET'])
@auth.login_required
def get_student_ages():
    """Get all students with their ages"""
    try:
        students = Student.query.all()
        student_ages = {student.name: str(student.age) for student in students}
        
        logger.info(f"Retrieved {len(students)} students")
        return jsonify({'student_ages': student_ages}), 200
    except Exception as e:
        logger.error(f"Error retrieving students: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/pozos/api/v1.0/get_student_ages/<student_name>', methods=['GET'])
@auth.login_required
def get_student_age(student_name):
    """Get specific student age and remove from database"""
    try:
        student = Student.query.filter_by(name=student_name).first()
        if not student:
            return jsonify({'error': 'Student not found'}), 404
        
        age = student.age
        db.session.delete(student)
        db.session.commit()
        
        logger.info(f"Retrieved and deleted student: {student_name}")
        return jsonify({'name': student_name, 'age': age}), 200
    except Exception as e:
        logger.error(f"Error processing student {student_name}: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/pozos/api/v1.0/students', methods=['POST'])
@auth.login_required
def create_student():
    """Create a new student"""
    try:
        data = request.get_json()
        if not data or 'name' not in data or 'age' not in data:
            return jsonify({'error': 'Name and age are required'}), 400
        
        # Check if student already exists
        existing_student = Student.query.filter_by(name=data['name']).first()
        if existing_student:
            return jsonify({'error': 'Student already exists'}), 409
        
        student = Student(name=data['name'], age=data['age'])
        db.session.add(student)
        db.session.commit()
        
        logger.info(f"Created new student: {data['name']}")
        return jsonify(student.to_dict()), 201
    except Exception as e:
        logger.error(f"Error creating student: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/pozos/api/v1.0/students', methods=['GET'])
@auth.login_required
def get_all_students():
    """Get all students with full details"""
    try:
        students = Student.query.all()
        return jsonify({
            'students': [student.to_dict() for student in students],
            'count': len(students)
        }), 200
    except Exception as e:
        logger.error(f"Error retrieving all students: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

# Error handlers
@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

# Initialize database tables
def init_db():
    """Initialize database tables"""
    try:
        with app.app_context():
            db.create_all()
            logger.info("Database tables created successfully")
    except Exception as e:
        logger.error(f"Error initializing database: {str(e)}")

if __name__ == '__main__':
    # Initialize database
    init_db()
    
    # Run the application
    app.run(
        debug=os.getenv('DEBUG', 'False').lower() == 'true',
        host='0.0.0.0',
        port=int(os.getenv('PORT', 5000))
    )
