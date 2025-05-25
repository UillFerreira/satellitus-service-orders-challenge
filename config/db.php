<?php

require_once __DIR__ . '/env.php';
class pgsql {
    private function conn () {
        $pg = "pgsql:host=" . getenv('DB_HOST') . ";dbname=" . getenv('DB_NAME');
        return new PDO($pg, getenv('DB_USER'), getenv('DB_PASS'), [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
        ]);
    }
    public function query ($query, $param) {
        try {
            $pdo = $this->conn();
            $pdo->beginTransaction();
            $stmt = $pdo->prepare($query);
            $stmt->execute($param);
            $pdo->commit();
            return $stmt->fetch(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            // Captura RAISE EXCEPTION (incluindo RAISE 'mensagem' sem código)
            $errorMessage = $e->getMessage();
            
            // Extrai apenas a mensagem personalizada (remove informações do PDO)
            if (preg_match('/SQLSTATE\[.*\]: (.*)/', $errorMessage, $matches)) {
                $errorMessage = $matches[1];
            }
            http_response_code(500);
            echo json_encode(['erro' => $errorMessage]);
            exit;
                
        }
    }
}
