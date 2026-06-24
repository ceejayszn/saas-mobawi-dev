<?php
require_once 'db_connect.php';

$raw_input = file_get_contents('php://input');
$data = json_decode($raw_input, true);

if (!$data) {
    echo json_encode(["status" => "error", "message" => "Invalid JSON payload"]);
    exit();
}

$checkoutRequestID = $data['checkout_request_id'] ?? '';

if (empty($checkoutRequestID)) {
    echo json_encode(["status" => "error", "message" => "Missing checkout_request_id"]);
    exit();
}

try {
    $stmt = $pdo->prepare("SELECT status FROM orders WHERE checkout_request_id = :checkout_id");
    $stmt->execute(['checkout_id' => $checkoutRequestID]);
    $row = $stmt->fetch();

    if ($row) {
        echo json_encode(["status" => "success", "payment_status" => $row['status']]);
    } else {
        echo json_encode(["status" => "error", "message" => "Order not found"]);
    }
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
