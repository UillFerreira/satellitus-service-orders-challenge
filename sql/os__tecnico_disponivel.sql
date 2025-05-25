CREATE OR REPLACE FUNCTION os__tecnico_disponivel (p_lat DOUBLE PRECISION, p_lng DOUBLE PRECISION, p_data_agendada timestamp, p_previsao timestamp) returns uuid  as $$
    DECLARE
        tecnico RECORD;
        distancia DOUBLE PRECISION;
        nova_dis DOUBLE PRECISION;
        tecnico_uuid uuid;

    BEGIN
        FOR tecnico IN SELECT id, lat, lng FROM tecnicos WHERE disponivel = true LOOP
        raise notice 'Distancia: % - tecnico: %', os__pontos_km(p_lat, p_lng, tecnico.lat, tecnico.lng), tecnico.id;
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
        return tecnico_uuid;
    END;
$$ LANGUAGE plpgsql;
