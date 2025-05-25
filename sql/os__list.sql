CREATE OR REPLACE FUNCTION os__list (p_tecnico_id uuid, p_status uuid, p_data_ini timestamp, p_data_fin timestamp) RETURNS
    TABLE (
        id uuid,
        protocolo text,
        descricao text,
        endereco text,
        lat double precision,
        lng double precision,
        data_agendada text,
        previsao text,
        tecnico text,
        status text
    ) AS $$
    DECLARE
    BEGIN
        RETURN QUERY
            SELECT os.id, os.protocolo, os.descricao, os.endereco, os.lat, os.lng, TO_CHAR(os.data_agendada, 'YYYY-MM-DD HH24:MI:SS'), TO_CHAR(os.previsao, 'YYYY-MM-DD HH24:MI:SS'), t.nome, s.nome FROM ordens_servico os
            INNER JOIN tecnicos t on (t.id = os.tecnico_id)
            INNER JOIN ordens_servico_status s on (s.id = os.status_id)
            WHERE (p_tecnico_id IS NULL OR tecnico_id = p_tecnico_id) AND (p_status IS NULL OR os.status_id = p_status) AND (p_data_ini IS NULL OR os.data_agendada >= p_data_ini) AND (p_data_fin IS NULL OR os.data_agendada <= p_data_fin)
            ORDER BY os.data_agendada ASC;
    END;
$$ LANGUAGE plpgsql;

