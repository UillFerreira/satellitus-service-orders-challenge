<?php

require_once __DIR__ . '/../config/db.php';

class Os
{
    public static function insertOs($descricao, $endereco, $lat, $lng, $data_agendamento, $previsao) {
        $pgsql = new pgsql();
        // Chamando uma procedure para tratar do insert da OS. A procedure retornará o número do protocolo
        // O caminho de utilizar a procedure foi para evitar fazer duas perguntas par ao banco de dados, tendo em vista que será necessário verificar o protocólo, pois não pode ter colisão.
        // Ainda que na tabela o protocólo esteja com um constraint unique, dentro da procedure posso validar isso em uma unica conexão e evitar o erro da constraint que daria no caso da colisão
        $ret = $pgsql->query(
            "SELECT os__new(:descricao, :endereco, :lat, :lng, :data_agendamento, :previsao)", 
            array(":descricao" => $descricao, ":endereco" => $endereco, ":lat" => $lat, ":lng" => $lng, ":data_agendamento" => $data_agendamento, ":previsao" => $previsao)
        );
        return $ret;
    }
}
