<?php

require_once '../config/env.php';
require_once 'jwt.php';

function checkAuth()
{
    $secret = getEnv('JWT_SECRET');

    $headers = getallheaders();
    if (!isset($headers['Authorization'])) {
        http_response_code(401);
        echo json_encode(['erro' => 'Token não foi enviado']);
        exit;
    }

    [$typo, $token] = explode(' ', $headers['Authorization'], 2);
    if (strtolower($typo) !== 'bearer') {
        http_response_code(401);
        echo json_encode(['erro' => 'Formato inválido']);
        exit;
    }
    $payload = verify_jwt($token, $secret);
    if (!$payload) {
        http_response_code(401);
        echo json_encode(['erro' => 'Token inválido ou expirado']);
        exit;
    }

    return $payload;
}
