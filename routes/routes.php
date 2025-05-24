<?php
require_once __DIR__ . '/../services/AuthMiddleware.php';
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];

switch($uri) {
    case '/token':
        if ($method != 'POST') {
            http_response_code(405);
            echo json_encode(['erro' => 'Método não permitido. Use POST']);
            exit;
        }
        require_once __DIR__ . '/../controllers/AuthController.php';
        (new AuthController())->genToken($_POST['login'], $_POST['password']);
        break;
    case '/ordens-servico':
        $payload = checkAuth();
        echo '{"ok", "ok"}';
        break;
    default:
        http_response_code(404);
        echo json_encode(['erro' => 'Rota não encontrada']);
        break;
}
