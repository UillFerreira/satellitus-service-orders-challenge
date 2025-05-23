<?php

require_once __DIR__ . '/../services/AuthService.php';

class AuthController
{
    public function genToken($login = null, $password = null)
    {
        if (!$login || !$password) {
            http_response_code(400);
            echo json_encode(['erro' => 'Necessário parametros de login e senha']);
            return;
        }

        $auth = new AuthService();
        $token = $auth->checkLogin($login, $password);

        if ($token) {
            echo json_encode(['token' => $token]);
        } else {
            http_response_code(401);
            echo json_encode(['erro' => 'Credenciais inválidas']);
        }
    }
}
