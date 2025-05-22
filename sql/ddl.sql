begin transaction;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE tecnicos (
    id uuid primary key default(gen_random_uuid()),
    nome text not null,
    email text not null, 
    lat double precision not null,
    lng double precision not null,
    disponivel boolean not null
);

CREATE TABLE ordens_servico_status (
    id uuid primary key default(gen_random_uuid()),
    nome text not null
);
CREATE TABLE ordens_servico (
    id uuid primary key default(gen_random_uuid()),
    protocolo text unique not null,
    descricao text,
    endereco text,
    lat double precision not null,
    lng double precision not null,
    data_agendada timestamptz not null,
    previsao time not null,
    tecnico_id uuid not null references tecnicos(id),
    status_id uuid not null references ordens_servico_status(id)
);
commit;
