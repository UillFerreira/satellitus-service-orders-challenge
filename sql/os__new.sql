CREATE OR REPLACE FUNCTION os__new (p_descricao, p_endereco, p_lat, p_lng, p_data_agendamento, p_previsao) returns text as $$
    DECLARE
        v_id uuid       = gen_random_uuid();
        v_status uuid   = 'a8827f04-f26c-4ba7-8593-d3572b22baf9'; -- status para ordem de serviço que ainda está pendente
    BEGIN
        INSERT INTO ordens_servico(id, protocolo, descricao, endereco, lat, lng, data_agendada, previsao, tecnico_id, status_id) VALUES(v_id, p_descricao, p_endereco, p_lat, p_lng, p_data_agendamento, p_previsao);
    END;
$$ LANGUAGE plpgsql;
