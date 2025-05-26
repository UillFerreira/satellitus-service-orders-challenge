--
-- PostgreSQL database dump
--

-- Dumped from database version 12.22 (Ubuntu 12.22-0ubuntu0.20.04.4)
-- Dumped by pg_dump version 12.22 (Ubuntu 12.22-0ubuntu0.20.04.4)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: os__list(uuid, uuid, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.os__list(p_tecnico_id uuid, p_status uuid, p_data_ini timestamp without time zone, p_data_fin timestamp without time zone) RETURNS TABLE(id uuid, protocolo text, descricao text, endereco text, lat double precision, lng double precision, data_agendada text, previsao text, tecnico text, status text)
    LANGUAGE plpgsql
    AS $$
    DECLARE
    BEGIN
        RETURN QUERY
            SELECT os.id, os.protocolo, os.descricao, os.endereco, os.lat, os.lng, TO_CHAR(os.data_agendada, 'YYYY-MM-DD HH24:MI:SS'), TO_CHAR(os.previsao, 'YYYY-MM-DD HH24:MI:SS'), t.nome, s.nome FROM ordens_servico os
            INNER JOIN tecnicos t on (t.id = os.tecnico_id)
            INNER JOIN ordens_servico_status s on (s.id = os.status_id)
            WHERE (p_tecnico_id IS NULL OR tecnico_id = p_tecnico_id) AND (p_status IS NULL OR os.status_id = p_status) AND (p_data_ini IS NULL OR os.data_agendada >= p_data_ini) AND (p_data_fin IS NULL OR os.data_agendada <= p_data_fin)
            ORDER BY os.data_agendada ASC;
    END;
$$;


--
-- Name: os__new(text, text, double precision, double precision, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.os__new(p_descricao text, p_endereco text, p_lat double precision, p_lng double precision, p_data_agendamento timestamp without time zone, p_previsao timestamp without time zone) RETURNS json
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: os__pontos_km(double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.os__pontos_km(os_lat double precision, os_lon double precision, tec_lat double precision, tec_lon double precision) RETURNS double precision
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    r INTEGER := 6371; -- Raio da Terra em km
    dlat DOUBLE PRECISION;
    dlon DOUBLE PRECISION;
    a DOUBLE PRECISION;
    c DOUBLE PRECISION;
BEGIN
    dlat := radians(tec_lat - os_lat);
    dlon := radians(tec_lon - os_lon);

    a := sin(dlat / 2)^2 + cos(radians(os_lat)) * cos(radians(tec_lat)) * sin(dlon / 2)^2;
    c := 2 * atan2(sqrt(a), sqrt(1 - a));

    RETURN r * c;
END;
$$;


--
-- Name: os__tecnico_disponivel(double precision, double precision, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.os__tecnico_disponivel(p_lat double precision, p_lng double precision, p_data_agendada timestamp without time zone, p_previsao timestamp without time zone) RETURNS json
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: os__update_status(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.os__update_status(p_id uuid, p_tecnico_id uuid) RETURNS json
    LANGUAGE plpgsql
    AS $$
    DECLARE
        p_pendente uuid     = 'a8827f04-f26c-4ba7-8593-d3572b22baf9';
        p_em_andamento uuid = '2b704832-ffd9-4d38-b99d-043943b9e278';
        p_concluida uuid    = '2c5c7397-e49e-4b92-a40f-2c0297dd4386';
        p_status_atual uuid;
        p_status text;
    BEGIN
        PERFORM 1 FROM ordens_servico as os inner join ordens_servico_status AS s on (s.id = os.status_id) WHERE os.id = p_id;
        IF NOT FOUND THEN
            RAISE 'Não há ordem de serviço registrada para o ID (%) ', p_id;
        END IF;

        SELECT os.status_id, s.nome INTO p_status_atual, p_status FROM ordens_servico as os inner join ordens_servico_status AS s on (s.id = os.status_id) WHERE os.id = p_id AND tecnico_id = p_tecnico_id;
        IF NOT FOUND THEN
            RAISE 'Não há ordem de serviço registrada para tecnico (%) ', p_tecnico_id;
        END IF;
         
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
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ordens_servico; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ordens_servico (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    protocolo text NOT NULL,
    descricao text,
    endereco text,
    lat double precision,
    lng double precision,
    data_agendada timestamp with time zone NOT NULL,
    previsao timestamp with time zone NOT NULL,
    tecnico_id uuid NOT NULL,
    status_id uuid NOT NULL
);


--
-- Name: ordens_servico_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ordens_servico_status (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    nome text NOT NULL
);


--
-- Name: tecnicos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tecnicos (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    email text NOT NULL,
    lat double precision NOT NULL,
    lng double precision NOT NULL,
    disponivel boolean NOT NULL
);


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    login text NOT NULL,
    password text NOT NULL
);


--
-- Data for Name: ordens_servico; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ordens_servico (id, protocolo, descricao, endereco, lat, lng, data_agendada, previsao, tecnico_id, status_id) FROM stdin;
52514a0b-986c-41cb-9be9-770d6b2542b7	2505251902070881	Minha nona OS		-22.92367541073393	-47.07953579624083	2025-05-19 13:10:10-03	2025-05-19 14:00:00-03	40ad0e67-6992-4908-aca5-82a278f91f0a	a8827f04-f26c-4ba7-8593-d3572b22baf9
db3aea88-ab8c-44d9-8cd2-6c27f2b6df8f	2505251902096297	Minha nona OS		-22.92367541073393	-47.07953579624083	2025-05-19 13:10:10-03	2025-05-19 14:00:00-03	54fef83c-6e08-4e67-9838-923058fa252f	a8827f04-f26c-4ba7-8593-d3572b22baf9
7abe9e97-ef04-441b-a881-2b5c75d4e5cd	2505251902106526	Minha nona OS		-22.92367541073393	-47.07953579624083	2025-05-19 13:10:10-03	2025-05-19 14:00:00-03	80c6cf92-abe4-4d4d-95b0-4ccc6709c569	a8827f04-f26c-4ba7-8593-d3572b22baf9
c6e0080b-a81e-488f-8443-891dd2a15efb	2505251902395689	Minha oitava OS	rua um	-22.92367541073393	-47.07953579624083	2025-05-20 13:10:10-03	2025-05-20 14:00:00-03	40ad0e67-6992-4908-aca5-82a278f91f0a	a8827f04-f26c-4ba7-8593-d3572b22baf9
e1369cc7-3b95-4693-87f8-c4258ab2886e	2505251902401418	Minha oitava OS	rua um	-22.92367541073393	-47.07953579624083	2025-05-20 13:10:10-03	2025-05-20 14:00:00-03	54fef83c-6e08-4e67-9838-923058fa252f	a8827f04-f26c-4ba7-8593-d3572b22baf9
f17f709b-6e78-4458-8ea6-bd773c9a9a29	2505251902410102	Minha oitava OS	rua um	-22.92367541073393	-47.07953579624083	2025-05-20 13:10:10-03	2025-05-20 14:00:00-03	80c6cf92-abe4-4d4d-95b0-4ccc6709c569	2b704832-ffd9-4d38-b99d-043943b9e278
\.


--
-- Data for Name: ordens_servico_status; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ordens_servico_status (id, nome) FROM stdin;
a8827f04-f26c-4ba7-8593-d3572b22baf9	pendente
2b704832-ffd9-4d38-b99d-043943b9e278	em_andamento
2c5c7397-e49e-4b92-a40f-2c0297dd4386	concluida
\.


--
-- Data for Name: tecnicos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tecnicos (id, nome, email, lat, lng, disponivel) FROM stdin;
54fef83c-6e08-4e67-9838-923058fa252f	Fulano A	fulanoa@os.com	-22.92046657314744	-47.075578680404945	t
40ad0e67-6992-4908-aca5-82a278f91f0a	Fulano b	fulanob@os.com	-22.923490356481985	-47.079269399975345	t
80c6cf92-abe4-4d4d-95b0-4ccc6709c569	Fulano c	fulanoa@os.com	-22.739187043911983	-47.31063136770589	t
\.


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.usuario (id, login, password) FROM stdin;
77334473-f2aa-4906-bdac-e8e7778e0824	root	$2a$06$ptCCBd7qPwtcJGGkOI68M.jSxeliaYlGr6Xn/px7tyddvQhYsbaAe
\.


--
-- Name: ordens_servico ordens_servico_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordens_servico
    ADD CONSTRAINT ordens_servico_pkey PRIMARY KEY (id);


--
-- Name: ordens_servico ordens_servico_protocolo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordens_servico
    ADD CONSTRAINT ordens_servico_protocolo_key UNIQUE (protocolo);


--
-- Name: ordens_servico_status ordens_servico_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordens_servico_status
    ADD CONSTRAINT ordens_servico_status_pkey PRIMARY KEY (id);


--
-- Name: tecnicos tecnicos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tecnicos
    ADD CONSTRAINT tecnicos_pkey PRIMARY KEY (id);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- Name: ordens_servico ordens_servico_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordens_servico
    ADD CONSTRAINT ordens_servico_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.ordens_servico_status(id);


--
-- Name: ordens_servico ordens_servico_tecnico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ordens_servico
    ADD CONSTRAINT ordens_servico_tecnico_id_fkey FOREIGN KEY (tecnico_id) REFERENCES public.tecnicos(id);


--
-- PostgreSQL database dump complete
--

