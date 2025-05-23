<?php

// Passa por todoas as linhas do .env para colocar em variaveis de ambiente
function loadEnv($path)
{
    if (!file_exists($path)) {
        return;
    }
    $rows = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($rows as $row) {
        [$key, $value] = explode('=', $row, 2);
        putenv(trim("$key=$value"));
        $_ENV[trim($key)] = trim($value);
    }
}

loadEnv(__DIR__ . '/../.env');
