CREATE OR REPLACE FUNCTION os__new (p_descricao text, p_endereco text, p_lat DOUBLE PRECISION, p_lng DOUBLE PRECISION, p_data_agendamento timestamp, p_previsao timestamp) returns json as $$
    DECLARE
        v_id uuid       = gen_random_uuid();
        v_status uuid   = 'a8827f04-f26c-4ba7-8593-d3572b22baf9'; -- status para ordem de serviço que ainda está pendente
        v_tecnico_id uuid;
        v_tecnico json;
        v_protocolo text;
        v_tentativas integer = 0;
        v_max_tentativas integer = 100;
    BEGIN
        -- Seleciona o técnico mais perto e disponivel
        v_tecnico = os__tecnico_disponivel(p_lat, p_lng, p_data_agendamento, p_previsao);
        v_tecnico_id = v_tecnico->>'id';
        -- Aqui vou gerar o protocolo e verificar se já existe um protocolo igual, caso haja, ele vai interagir novamente para criar um novo. Isso vai acontecer até a centésima tentativa
        -- A ideia é colocar um limite para não entrar em loop eterno
        LOOP
            -- Gera um protocolo utilizando data hora e números aleatórios
            v_protocolo = 
                TO_CHAR(NOW(), 'DDMMYY') || 
                TO_CHAR(NOW(), 'HH24MISS') || 
                LPAD(FLOOR(RANDOM() * POWER(10, 4))::TEXT, 4, '0');
            
            -- Verifica se o protocolo já existe 
            PERFORM 1 FROM ordens_servico WHERE protocolo = v_protocolo;
            
            -- Se não existir, para o loop
            IF NOT FOUND THEN
                EXIT;
            END IF;
            
            -- Controle de segurança para evitar loop infinito
            v_tentativas = v_tentativas + 1;
            IF v_tentativas >= v_max_tentativas THEN
                RAISE EXCEPTION 'Não foi possível gerar um protocolo único após % de %',  v_tentativas, v_max_tentativas;
            END IF;
        END LOOP;

        INSERT INTO ordens_servico(id, protocolo, descricao, endereco, lat, lng, data_agendada, previsao, tecnico_id, status_id) VALUES(v_id, v_protocolo, p_descricao, p_endereco, p_lat, p_lng, p_data_agendamento, p_previsao, v_tecnico_id, v_status);
        return jsonb_build_object('protocolo', v_protocolo) || v_tecnico::jsonb;
    END;
$$ LANGUAGE plpgsql;
