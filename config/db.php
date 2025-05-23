<?php

require_once __DIR__ . '/env.php';

function psqlConn()
{
    $pg = "pgsql:host=" . getenv('DB_HOST') . ";dbname=" . getenv('DB_NAME');
    return new PDO($pg, getenv('DB_USER'), getenv('DB_PASS'), [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
}
