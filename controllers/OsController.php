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
            exit;
        }
        $os = new OsService();
        $ret = $os->createOs($descricao, $endereco, $lat, $lng, $data_agendada, $previsao);
        echo json_encode($ret);

    }

    public function updateOs ($id=null, $json=null) {
        if (!isset($id) && !isset($json)) {
            http_response_code(400);
            echo json_encode(['erro' => 'Não foi enviado o ID ou JSON']);
            exit;
        }
        if (!isset($json["tecnico_id"])) {
            http_response_code(400);
            echo json_encode(['erro' => 'Não foi enviado o ID do técnico no JSON']);
            exit;
        }
        $tecnico_id = $json["tecnico_id"];
        $os = new OsService();
        $ret = $os->alterOs($id, $tecnico_id);
        echo json_encode($ret);
    }
    public function listOs ($tecnico_id=null, $status=null, $data_ini=null, $data_fin=null) {
        $os = new OsService();
        echo json_encode($os->selectOs($tecnico_id, $status, $data_ini, $data_fin));
    }
}
