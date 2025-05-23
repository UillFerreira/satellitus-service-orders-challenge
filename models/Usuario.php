<?php

require_once __DIR__ . '/../config/db.php';

class Usuario
{
    public static function getLogin($login)
    {
        $pdo = psqlConn();
        $stmt = $pdo->prepare("SELECT * FROM usuario WHERE login = :login");
        $stmt->bindParam(':login', $login);
        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
}
