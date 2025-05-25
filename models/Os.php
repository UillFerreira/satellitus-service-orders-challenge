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
    // Atualização dos status está sendo feita por uma procedure, lá é validado se a OS existe e se pertence ao técnico que envio
    // Faz a troca dos status e retorn um json com o status atual
    public static function updateStatusOs($id, $tecnico_id) {
        $pgsql = new pgsql();
        $ret = $pgsql->query(
            "SELECT os__update_status(:id, :tecnico_id)", 
            array(":id" => $id, ":tecnico_id" => $tecnico_id)
        );
        return $ret;

    }
}
