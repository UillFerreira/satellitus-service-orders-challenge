<?php

require_once __DIR__ . '/../services/OsService.php';
class OsController {
    public function newOs($json) {
        $descricao          = isset($json['descricao']) ? $json['descricao'] : null;
        $endereco           = isset($json['endereco']) ? $json['endereco'] : null;
        $lat                = isset($json['lat']) ? $json['lat'] : null;
        $lng                = isset($json['lng']) ? $json['lng'] : null;
        $data_agendada      = isset($json['data_agendada']) ? $json['data_agendada'] : null;
        $previsao           = isset($json['previsao']) ? $json['previsao'] : null;
                               
        if (!$descricao || (!$lat || !$lng) || !$data_agendada || !$previsao) {
            http_response_code(400);
            echo json_encode(['erro' => 'Faltando parâmetros']);
            return;
        }
        $os = new OsService();
        $ret = $os->createOs($descricao, $endereco, $lat, $lng, $data_agendada, $previsao);
        echo json_encode($ret);

    }
}
