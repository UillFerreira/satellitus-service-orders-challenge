<?php

require_once __DIR__ . '/../config/db.php';

class Usuario
{
    public static function getLogin($login) {
        $pgsql = new pgsql();
        $ret = $pgsql->query("SELECT * FROM usuario WHERE login = :login", array(":login" =>  $login));
        return $ret;
    }
}
