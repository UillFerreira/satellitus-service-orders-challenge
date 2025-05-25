<?php

require_once __DIR__ . '/../services/AuthMiddleware.php';
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];

function defaultErrors ($status, $msg) {
    http_response_code($status);
    echo json_encode(['erro' => $msg]);
    exit;
}
// Validar o json na entrada dos dados
function checkJson ($json) {
    $data = json_decode($json, true);

    // Verifica se o JSON foi decodificado corretamente
    if (json_last_error() !== JSON_ERROR_NONE) {
        defaultErrors(404, "JSON malformado");
        exit;
    }
    return $data;
}

switch ($uri) {
    case '/token':
        if ($method != 'POST') {
            defaultErrors(405, "Método não permitido. Use POST");
            exit;
        }
        require_once __DIR__ . '/../controllers/AuthController.php';
        (new AuthController())->genToken($_POST['login'], $_POST['password']);
        break;
    // Captura todos os endpoints que comecem em /ordens-servico
    case strpos($uri, '/ordens-servico') === 0:
        // Valida a conexão
        $payload = checkAuth();
        require_once __DIR__ . '/../controllers/OsController.php';
        // Pega os dados do POST e valida o JSON
        $post_json = file_get_contents('php://input');
        $json = checkJson($post_json);
        $os = new OsController();
        // Separa pelos metodos
        if ($method == 'POST') {
            $os->newOs($json);
            exit;
        }
        // No patch, preciso pegar o ID e qual o endpoint, no caso só tem o de status
        if ($method == 'PATCH') {
            $segments = explode('/', trim($uri, '/'));
            $id = $segments[1];
            if ($segments[2] == 'status') {
                $os->updateOs($id, $json);
                exit;
            }
        }
        http_response_code(404);
        echo json_encode(['erro' => 'Rota não encontrada para a uri /ordens-servico']);
        break;
    default:
        http_response_code(404);
        echo json_encode(['erro' => 'Rota não encontrada']);
        break;
}
