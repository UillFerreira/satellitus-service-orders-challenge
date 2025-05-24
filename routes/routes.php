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
        require_once __DIR__ . '/../controllers/OsController.php';
        (new OsController())->newOs($_POST['descricao'], $_POST['endereco'], $_POST['lat'], $_POST['lng'], $_POST['data_agendada']);
        break;
    default:
        http_response_code(404);
        echo json_encode(['erro' => 'Rota não encontrada']);
        break;
}
