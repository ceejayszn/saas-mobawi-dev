<?php
require_once 'db_connect.php';

// Retrieve post data
$raw_input = file_get_contents('php://input');
$data = json_decode($raw_input, true);

if (!$data) {
    echo json_encode(["status" => "error", "message" => "Invalid JSON payload"]);
    exit();
}

// Auto-create Tables if they don't exist
try {
    // 1. Orders table
    $pdo->exec("CREATE TABLE IF NOT EXISTS orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        sequence_id VARCHAR(50) UNIQUE NOT NULL,
        total DECIMAL(10,2) NOT NULL,
        status VARCHAR(20) DEFAULT 'unpaid',
        is_modified INT DEFAULT 0,
        payment_method VARCHAR(20) DEFAULT 'cash',
        cashier_name VARCHAR(100) DEFAULT 'unknown',
        checkout_request_id VARCHAR(100) DEFAULT '',
        created_at DATETIME NOT NULL
    )");

    // 2. Sales table
    $pdo->exec("CREATE TABLE IF NOT EXISTS sales (
        id INT AUTO_INCREMENT PRIMARY KEY,
        sequence_id VARCHAR(50) NOT NULL,
        item_id INT NOT NULL,
        quantity INT NOT NULL,
        total DECIMAL(10,2) NOT NULL,
        created_at DATETIME NOT NULL,
        INDEX(sequence_id)
    )");

    // 3. Active Cashiers/Heartbeat table
    $pdo->exec("CREATE TABLE IF NOT EXISTS cashiers_activity (
        id INT AUTO_INCREMENT PRIMARY KEY,
        cashier_name VARCHAR(100) UNIQUE NOT NULL,
        last_active DATETIME NOT NULL
    )");
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "Table initialization failed: " . $e->getMessage()]);
    exit();
}

$action = $data['action'] ?? '';

// Handle Heartbeat (Ping)
if ($action === 'heartbeat') {
    $cashier_name = $data['cashier_name'] ?? '';
    if (empty($cashier_name)) {
        echo json_encode(["status" => "error", "message" => "Cashier name is required"]);
        exit();
    }
    try {
        $stmt = $pdo->prepare("INSERT INTO cashiers_activity (cashier_name, last_active) 
            VALUES (:name, NOW()) 
            ON DUPLICATE KEY UPDATE last_active = NOW()");
        $stmt->execute(['name' => $cashier_name]);
        echo json_encode(["status" => "success", "message" => "Heartbeat registered"]);
    } catch (PDOException $e) {
        echo json_encode(["status" => "error", "message" => $e->getMessage()]);
    }
    exit();
}

// Handle Sync (Orders & Sales)
if ($action === 'sync') {
    $orders = $data['orders'] ?? [];
    $sales = $data['sales'] ?? [];

    $pdo->beginTransaction();
    try {
        // Sync orders
        if (!empty($orders)) {
            $stmtOrder = $pdo->prepare("INSERT INTO orders 
                (sequence_id, total, status, is_modified, payment_method, cashier_name, checkout_request_id, created_at) 
                VALUES (:seq, :total, :status, :modified, :method, :cashier, :checkout_id, :created)
                ON DUPLICATE KEY UPDATE 
                    total = VALUES(total), 
                    status = VALUES(status), 
                    is_modified = VALUES(is_modified), 
                    payment_method = VALUES(payment_method), 
                    cashier_name = VALUES(cashier_name),
                    checkout_request_id = VALUES(checkout_request_id)");

            foreach ($orders as $order) {
                $stmtOrder->execute([
                    'seq' => $order['sequence_id'],
                    'total' => $order['total'],
                    'status' => $order['status'],
                    'modified' => $order['is_modified'],
                    'method' => $order['payment_method'] ?? 'cash',
                    'cashier' => $order['cashier_name'] ?? 'unknown',
                    'checkout_id' => $order['checkout_request_id'] ?? '',
                    'created' => $order['created_at']
                ]);
            }
        }

        // Sync sales
        if (!empty($sales)) {
            // Clear existing sales for these sequences first to avoid duplicates on modification
            $seqsToClear = array_unique(array_column($sales, 'sequence_id'));
            if (!empty($seqsToClear)) {
                $inQuery = implode(',', array_fill(0, count($seqsToClear), '?'));
                $stmtClear = $pdo->prepare("DELETE FROM sales WHERE sequence_id IN ($inQuery)");
                $stmtClear->execute(array_values($seqsToClear));
            }

            $stmtSale = $pdo->prepare("INSERT INTO sales 
                (sequence_id, item_id, quantity, total, created_at) 
                VALUES (:seq, :item_id, :qty, :total, :created)");

            foreach ($sales as $sale) {
                $stmtSale->execute([
                    'seq' => $sale['sequence_id'],
                    'item_id' => $sale['item_id'],
                    'qty' => $sale['quantity'],
                    'total' => $sale['total'],
                    'created' => $sale['created_at']
                ]);
            }
        }

        $pdo->commit();
        echo json_encode(["status" => "success", "message" => "Sync completed successfully"]);
    } catch (Exception $e) {
        $pdo->rollBack();
        echo json_encode(["status" => "error", "message" => "Sync transaction failed: " . $e->getMessage()]);
    }
    exit();
}

echo json_encode(["status" => "error", "message" => "Unsupported action"]);
?>
