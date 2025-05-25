CREATE OR REPLACE FUNCTION os__update_status (p_id uuid, p_tecnico_id uuid) returns json as $$
    DECLARE
        p_pendente uuid     = 'a8827f04-f26c-4ba7-8593-d3572b22baf9';
        p_em_andamento uuid = '2b704832-ffd9-4d38-b99d-043943b9e278';
        p_concluida uuid    = '2c5c7397-e49e-4b92-a40f-2c0297dd4386';
        p_status_atual uuid;
        p_status text;
    BEGIN
        -- Validar se a OS existe
        PERFORM 1 FROM ordens_servico as os inner join ordens_servico_status AS s on (s.id = os.status_id) WHERE os.id = p_id;
        IF NOT FOUND THEN
            RAISE 'Não há ordem de serviço registrada para o ID (%) ', p_id;
        END IF;
        -- Se a OS existe, valida se o técnico que foi passado pelo parâmetro, pode alterar o status
        SELECT os.status_id, s.nome INTO p_status_atual, p_status FROM ordens_servico as os inner join ordens_servico_status AS s on (s.id = os.status_id) WHERE os.id = p_id AND tecnico_id = p_tecnico_id;
        IF NOT FOUND THEN
            RAISE 'Não há ordem de serviço registrada para tecnico (%) ', p_tecnico_id;
        END IF;
        -- Caso possa mudar, faz a troca dos status, caso esteja no ultimo status, só retorna o status atual 
        CASE WHEN p_status_atual = 'a8827f04-f26c-4ba7-8593-d3572b22baf9' THEN
            UPDATE ordens_servico SET status_id = p_em_andamento WHERE id = p_id AND tecnico_id = p_tecnico_id;
            -- Busca o nome do status no banco de dados para evitar inconsistências nos nomes
            SELECT nome INTO p_status FROM ordens_servico_status WHERE id = p_em_andamento;
            -- Retorno o valor atualizado do status
            RETURN json_build_object('status', p_status);
        WHEN p_status_atual = '2b704832-ffd9-4d38-b99d-043943b9e278' THEN
            UPDATE ordens_servico SET status_id = p_concluida WHERE id = p_id AND tecnico_id = p_tecnico_id;
            SELECT nome INTO p_status FROM ordens_servico_status WHERE id = p_concluida;
            RETURN json_build_object('status', 'concluida');
        ELSE
            RETURN json_build_object('status', p_status);
        END CASE; 
        
    END;
$$ LANGUAGE plpgsql;
