<?php
/**
 * Health check endpoint for the web application
 */

header('Content-Type: application/json');

// Check if API is reachable
$api_url = getenv('API_URL') ?: 'http://api:5000';
$api_username = getenv('API_USERNAME') ?: 'toto';
$api_password = getenv('API_PASSWORD') ?: 'python';

$api_healthy = false;
$api_error = '';

try {
    $context = stream_context_create([
        "http" => [
            "method" => "GET",
            "header" => "Authorization: Basic " . base64_encode("$api_username:$api_password"),
            "timeout" => 5
        ]
    ]);
    
    $response = @file_get_contents($api_url . '/health', false, $context);
    
    if ($response !== false) {
        $data = json_decode($response, true);
        $api_healthy = isset($data['status']) && $data['status'] === 'healthy';
    } else {
        $api_error = 'API not reachable';
    }
} catch (Exception $e) {
    $api_error = $e->getMessage();
}

// Overall health status
$overall_healthy = $api_healthy;

$health_data = [
    'status' => $overall_healthy ? 'healthy' : 'unhealthy',
    'timestamp' => date('c'),
    'version' => getenv('APP_VERSION') ?: '2.0.0',
    'services' => [
        'webapp' => [
            'status' => 'healthy',
            'uptime' => 'running'
        ],
        'api' => [
            'status' => $api_healthy ? 'healthy' : 'unhealthy',
            'error' => $api_error ?: null
        ]
    ]
];

http_response_code($overall_healthy ? 200 : 503);
echo json_encode($health_data, JSON_PRETTY_PRINT);
?>
