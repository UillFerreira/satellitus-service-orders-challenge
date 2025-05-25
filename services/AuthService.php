<?php

require_once __DIR__ . '/../models/Usuario.php';
require_once __DIR__ . '/../services/jwt.php';
require_once __DIR__ . '/../config/env.php';

class AuthService {
    public function checkLogin($login, $password) {
        $ret = Usuario::getLogin($login);
        if ($ret && password_verify($password, $ret[0]['password'])) {
            $payload = [
                'sub' => $ret['id'],
                'iat' => time(),
                'exp' => time() + 3600
            ];
            $token = generate_jwt($payload, getenv('JWT_SECRET'));
            return $token;
        }

        return false;
    }
}
