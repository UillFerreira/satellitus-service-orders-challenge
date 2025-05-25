<?php

//require_once __DIR__ . '/../models/Os.php';

class OsService {
    private function defaultError ($status, $msg) {
        http_response_code($status);
        echo json_encode(['erro' => $msg]);
        exit;
    }
    // Verificar os dados antes de enviar para o banco de dados
    private function dataCheck($descricao, $endereco, $lat, $lng, $data_agendamento, $previsao) {

        // Validar se o formato dos campos data estãorespeitando o paddrão definido
        $date_format = "Y-m-d H:i:s";
        // Data de agendamento
        $d = DateTime::createFromFormat($date_format, $data_agendamento);
        if (!$d) {
            $this->defaultError(400, "O formato para o parâmetro \"data_agendamento\" tem que ser \"Y-m-d H:i:s\"");
        }
        // Data da previsão
        $d = DateTime::createFromFormat($date_format, $previsao);
        if (!$d) {
            $this->defaultError(400, "O formato para o parâmetro \"previsao\" tem que ser \"Y-m-d H:i:s\"");
        }
        if ($data_agendamento > $previsao) {
            $this->defaultError(400, "data_agendada não pode ser maior que a previsao");
        }
        // Trata se lat e lng são floats
        if ($lat && !(floatval($lat) >= -90 && floatval($lat) <= 90)) {

            $this->defaultError(400, "O parâmetro \"lat\" tem que ser um dado do tipo \"float\" e entre -90 e 90");
        }
        if ($lng && !(floatval($lng) >= -180 && floatval($lng) <= 180)) {
            $this->defaultError(400, "O parâmetro \"lng\" tem que ser um dado do tipo \"float\" e entre -180 e 180");
        }
    }
    // Valida as informações e manda para inserir no banco de dados
    public function createOs($descricao, $endereco, $lat, $lng, $data_agendamento, $previsao) {
        // Vallidar os dados enviados
        $this->dataCheck($descricao, $endereco, $lat, $lng, $data_agendamento, $previsao);

        //$ret = Os::saveOs();

    }
}
