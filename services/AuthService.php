<?php

require_once __DIR__ . '/../models/Usuario.php';

class AuthService {
    public function checkLogin($login, $password) {
        $usuario = Usuario::getLogin($login);

        if ($usuario && password_verify($password, $usuario['senha'])) {
            return bin2hex(random_bytes(16)); // token simples para teste
        }

        return false;
    }
}
