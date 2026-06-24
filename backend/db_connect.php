<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// MySQL Credentials (replace with actual values from InfinityFree)
define('DB_HOST', 'sql113.infinityfree.com'); // Put your InfinityFree DB Hostname
define('DB_USER', 'if0_42237431');              // Put your InfinityFree DB Username
define('DB_PASS', 'xD7FyXLSbki');          // Put your InfinityFree DB Password
define('DB_NAME', 'if0_42237431_pos_db');          // Put your InfinityFree DB Name

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "Database connection failed: " . $e->getMessage()]);
    exit();
}
?>
