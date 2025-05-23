<?php

require_once __DIR__ . '/../models/Usuario.php';
require_once __DIR__ . '/../services/jwt.php';

class AuthService {
    public function checkLogin($login, $password) {
        $ret = Usuario::getLogin($login);
        if ($ret && password_verify($password, $ret['password'])) {
            $payload = [
                'sub' => $ret['id'],
                'iat' => time(),
                'expires' => time() + 3600
            ];
            $token = generate_jwt($payload, $secret);
            return $token;
        }

        return false;
    }
}
