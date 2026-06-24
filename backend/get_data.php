<?php
require_once 'db_connect.php';

$action = $_GET['action'] ?? '';

// 1. Get Live Active Cashiers
if ($action === 'active_cashiers') {
    try {
        // Cashiers active in the last 5 minutes
        $stmt = $pdo->prepare("SELECT cashier_name, last_active, 
            (CASE WHEN last_active >= DATE_SUB(NOW(), INTERVAL 5 MINUTE) THEN 'online' ELSE 'offline' END) as status
            FROM cashiers_activity 
            ORDER BY last_active DESC");
        $stmt->execute();
        $cashiers = $stmt->fetchAll();
        echo json_encode(["status" => "success", "data" => $cashiers]);
    } catch (PDOException $e) {
        echo json_encode(["status" => "error", "message" => $e->getMessage()]);
    }
    exit();
}

// 2. Get Sales Reports for Boss
if ($action === 'boss_reports') {
    try {
        // Today's total revenue
        $stmtRev = $pdo->query("SELECT SUM(total) as revenue FROM orders WHERE DATE(created_at) = CURDATE() AND status = 'paid'");
        $revenue = $stmtRev->fetch()['revenue'] ?? 0;

        // Cash vs Mpesa today
        $stmtCash = $pdo->query("SELECT SUM(total) as total FROM orders WHERE DATE(created_at) = CURDATE() AND status = 'paid' AND payment_method = 'cash'");
        $cash = $stmtCash->fetch()['total'] ?? 0;

        $stmtMpesa = $pdo->query("SELECT SUM(total) as total FROM orders WHERE DATE(created_at) = CURDATE() AND status = 'paid' AND payment_method = 'mpesa'");
        $mpesa = $stmtMpesa->fetch()['total'] ?? 0;

        // Sales breakdown by Cashier today
        $stmtCashierSales = $pdo->query("SELECT cashier_name, SUM(total) as total_sales, COUNT(*) as order_count 
            FROM orders 
            WHERE DATE(created_at) = CURDATE() AND status = 'paid' 
            GROUP BY cashier_name 
            ORDER BY total_sales DESC");
        $cashierSales = $stmtCashierSales->fetchAll();

        // Recent orders synced
        $stmtOrders = $pdo->query("SELECT sequence_id, total, status, payment_method, cashier_name, created_at 
            FROM orders 
            ORDER BY created_at DESC 
            LIMIT 30");
        $recentOrders = $stmtOrders->fetchAll();

        echo json_encode([
            "status" => "success",
            "data" => [
                "revenue" => (float)$revenue,
                "cash" => (float)$cash,
                "mpesa" => (float)$mpesa,
                "cashier_sales" => $cashierSales,
                "recent_orders" => $recentOrders
            ]
        ]);
    } catch (PDOException $e) {
        echo json_encode(["status" => "error", "message" => $e->getMessage()]);
    }
    exit();
}

// 3. Pull recent orders to sync status back to devices
if ($action === 'sync_pull') {
    try {
        // Fetch recent orders (e.g. last 1 day) to sync status
        $stmtOrders = $pdo->query("SELECT sequence_id, status, payment_method, checkout_request_id 
            FROM orders 
            WHERE created_at >= DATE_SUB(NOW(), INTERVAL 1 DAY)");
        $orders = $stmtOrders->fetchAll();
        echo json_encode(["status" => "success", "data" => $orders]);
    } catch (PDOException $e) {
        echo json_encode(["status" => "error", "message" => $e->getMessage()]);
    }
    exit();
}

echo json_encode(["status" => "error", "message" => "Unsupported action"]);
?>
