<?php

class OsController
{
    public function newOs($descricao = null, $endereco = null, $lat = null, $lng = null, $data_agendamento = null)
    {
        if (!$descricao || (!$endereco && (!$lat && !$lng)) || !$data_agendamento) {
            http_response_code(400);
            echo json_encode(['erro' => 'Faltando parâmetros']);
            return;
        }

        //$auth = new AuthService();
        //$token = $auth->checkLogin($login, $password);

    }
}
