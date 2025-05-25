CREATE OR REPLACE FUNCTION os__tecnico_disponivel (p_lat DOUBLE PRECISION, p_lng DOUBLE PRECISION, p_data_agendada timestamp, p_previsao timestamp) returns json as $$
    DECLARE
        tecnico RECORD;
        distancia DOUBLE PRECISION;
        nova_dis DOUBLE PRECISION;
        tecnico_uuid uuid;
        v_nome text;
        v_email text;

    BEGIN
        -- Verifica se existe técnico disponível
        PERFORM 1 FROM tecnicos WHERE disponivel = true;
        IF NOT FOUND THEN
            RAISE 'Não há técnicos dispóniveis';
        END IF;
        
        FOR tecnico IN SELECT id, lat, lng FROM tecnicos WHERE disponivel = true LOOP
        raise notice 'Distancia: % - tecnico: %', os__pontos_km(p_lat, p_lng, tecnico.lat, tecnico.lng), tecnico.id;
            PERFORM 1 FROM ordens_servico WHERE tecnico_id = tecnico.id AND data_agendada BETWEEN p_data_agendada AND p_previsao;
            IF FOUND THEN
                CONTINUE;
            END IF;
            IF (distancia is null) THEN
                nova_dis = os__pontos_km(p_lat, p_lng, tecnico.lat, tecnico.lng);
                distancia = nova_dis;
                tecnico_uuid = tecnico.id;
                CONTINUE;
            END IF;
            nova_dis = os__pontos_km(p_lat, p_lng, tecnico.lat, tecnico.lng);
            IF (distancia > nova_dis) THEN
                distancia = nova_dis;
                tecnico_uuid = tecnico.id;
            END IF;
        END LOOP;
        -- Caso não haja tecnicos disponivies por conta do periodo, retona um erro e
        IF (tecnico_uuid IS NULL) THEN
            RAISE 'Não há técnicos disponívies para o período escolhido';
        END IF;
        SELECT nome, email INTO v_nome, v_email FROM tecnicos WHERE id = tecnico_uuid;
        return json_build_object('id', tecnico_uuid, 'nome', v_nome, 'email', v_email);
    END;
$$ LANGUAGE plpgsql;
