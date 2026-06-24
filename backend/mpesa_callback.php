<?php
require_once 'db_connect.php';

// Retrieve the callback JSON from Safaricom
$callbackJSON = file_get_contents('php://input');
$callbackData = json_decode($callbackJSON, true);

if (!$callbackData) {
    echo json_encode(["status" => "error", "message" => "Invalid callback payload"]);
    exit();
}

// Log callback for debugging/reference
file_put_contents('mpesa_callback_log.txt', date('[Y-m-d H:i:s] ') . $callbackJSON . PHP_EOL, FILE_APPEND);

try {
    $stkCallback = $callbackData['Body']['stkCallback'] ?? null;
    if ($stkCallback) {
        $checkoutRequestID = $stkCallback['CheckoutRequestID'] ?? '';
        $resultCode = $stkCallback['ResultCode'] ?? -1;
        $resultDesc = $stkCallback['ResultDesc'] ?? '';

        if ($resultCode === 0 && !empty($checkoutRequestID)) {
            // Payment was successful!
            // Update order status to paid
            $stmt = $pdo->prepare("UPDATE orders 
                SET status = 'paid', payment_method = 'mpesa' 
                WHERE checkout_request_id = :checkout_id");
            $stmt->execute(['checkout_id' => $checkoutRequestID]);

            echo json_encode(["status" => "success", "message" => "Order updated successfully"]);
            exit();
        } else {
            // Payment failed or was cancelled
            echo json_encode(["status" => "ignored", "message" => "Payment failed with code $resultCode: $resultDesc"]);
            exit();
        }
    }
} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
    exit();
}

echo json_encode(["status" => "error", "message" => "Invalid STK Callback structure"]);
?>
