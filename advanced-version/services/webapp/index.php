<?php
/**
 * Advanced Student Management Web Application
 * Features: Error handling, environment configuration, health checks
 */

// Error reporting for development
if (getenv('DEBUG') === 'true') {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
}

// Configuration from environment
$api_url = getenv('API_URL') ?: 'http://api:5000';
$api_username = getenv('API_USERNAME') ?: 'toto';
$api_password = getenv('API_PASSWORD') ?: 'python';
$app_title = getenv('APP_TITLE') ?: 'POZOS Student Management System';
$app_version = getenv('APP_VERSION') ?: '2.0.0';

// Function to make API calls with error handling
function makeApiCall($url, $username, $password, $method = 'GET') {
    $context = stream_context_create([
        "http" => [
            "method" => $method,
            "header" => "Authorization: Basic " . base64_encode("$username:$password"),
            "timeout" => 10
        ]
    ]);
    
    $response = @file_get_contents($url, false, $context);
    
    if ($response === false) {
        return [
            'success' => false,
            'error' => 'Failed to connect to API server',
            'data' => null
        ];
    }
    
    $data = json_decode($response, true);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        return [
            'success' => false,
            'error' => 'Invalid JSON response from API',
            'data' => null
        ];
    }
    
    return [
        'success' => true,
        'error' => null,
        'data' => $data
    ];
}

// Handle form submission
$students = [];
$error_message = '';
$success_message = '';

if ($_SERVER['REQUEST_METHOD'] == "POST" && isset($_POST['submit'])) {
    $api_response = makeApiCall(
        $api_url . '/pozos/api/v1.0/get_student_ages',
        $api_username,
        $api_password
    );
    
    if ($api_response['success']) {
        $students = $api_response['data']['student_ages'] ?? [];
        $success_message = 'Students retrieved successfully!';
    } else {
        $error_message = $api_response['error'];
    }
}

// Handle student creation
if ($_SERVER['REQUEST_METHOD'] == "POST" && isset($_POST['create_student'])) {
    $name = trim($_POST['student_name'] ?? '');
    $age = intval($_POST['student_age'] ?? 0);
    
    if ($name && $age > 0) {
        $student_data = json_encode(['name' => $name, 'age' => $age]);
        
        $context = stream_context_create([
            "http" => [
                "method" => "POST",
                "header" => [
                    "Authorization: Basic " . base64_encode("$api_username:$api_password"),
                    "Content-Type: application/json"
                ],
                "content" => $student_data,
                "timeout" => 10
            ]
        ]);
        
        $response = @file_get_contents($api_url . '/pozos/api/v1.0/students', false, $context);
        
        if ($response !== false) {
            $data = json_decode($response, true);
            if (isset($data['name'])) {
                $success_message = "Student {$data['name']} created successfully!";
            } else {
                $error_message = 'Failed to create student';
            }
        } else {
            $error_message = 'Failed to connect to API server';
        }
    } else {
        $error_message = 'Please provide valid name and age';
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($app_title); ?></title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
            margin-bottom: 30px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input[type="text"], input[type="number"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
        }
        button {
            background-color: #007bff;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-right: 10px;
        }
        button:hover {
            background-color: #0056b3;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .students-list {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            margin-top: 20px;
        }
        .student-item {
            padding: 10px;
            border-bottom: 1px solid #dee2e6;
        }
        .student-item:last-child {
            border-bottom: none;
        }
        .info {
            background-color: #e7f3ff;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1><?php echo htmlspecialchars($app_title); ?></h1>
        
        <div class="info">
            <strong>Version:</strong> <?php echo htmlspecialchars($app_version); ?> | 
            <strong>API:</strong> <?php echo htmlspecialchars($api_url); ?> | 
            <strong>Debug:</strong> <?php echo getenv('DEBUG') === 'true' ? 'ON' : 'OFF'; ?>
        </div>

        <?php if ($success_message): ?>
            <div class="success"><?php echo htmlspecialchars($success_message); ?></div>
        <?php endif; ?>

        <?php if ($error_message): ?>
            <div class="error"><?php echo htmlspecialchars($error_message); ?></div>
        <?php endif; ?>

        <div class="form-group">
            <h3>Create New Student</h3>
            <form method="POST">
                <label for="student_name">Student Name:</label>
                <input type="text" id="student_name" name="student_name" required>
                
                <label for="student_age">Student Age:</label>
                <input type="number" id="student_age" name="student_age" min="1" max="120" required>
                
                <button type="submit" name="create_student">Create Student</button>
            </form>
        </div>

        <div class="form-group">
            <h3>List Students</h3>
            <form method="POST">
                <button type="submit" name="submit">Get Student List</button>
            </form>
        </div>

        <?php if (!empty($students)): ?>
            <div class="students-list">
                <h3>Student List</h3>
                <?php foreach ($students as $name => $age): ?>
                    <div class="student-item">
                        <strong><?php echo htmlspecialchars($name); ?></strong> is 
                        <strong><?php echo htmlspecialchars($age); ?></strong> years old
                    </div>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </div>
</body>
</html>
