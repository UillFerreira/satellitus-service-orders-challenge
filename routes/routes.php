<?php

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];

if ($uri === '/token' && $method === 'POST') {
    require_once __DIR__ . '/../controllers/AuthController.php';
    (new AuthController())->genToken($_POST['login'], $_POST['password']);
} else {
    http_response_code(404);
    echo json_encode(['erro' => 'Rota não encontrada']);
}
