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
insert into tecnicos (id, nome, email, lat, lng, disponivel) values ('54fef83c-6e08-4e67-9838-923058fa252f', 'Fulano A', 'fulanoa@os.com', -22.92046657314744, -47.075578680404945, true) on conflict (id) do nothing;
insert into tecnicos (id, nome, email, lat, lng, disponivel) values ('40ad0e67-6992-4908-aca5-82a278f91f0a', 'Fulano b', 'fulanob@os.com', -22.923490356481985, -47.079269399975345, true) on conflict (id) do nothing;
insert into tecnicos (id, nome, email, lat, lng, disponivel) values ('80c6cf92-abe4-4d4d-95b0-4ccc6709c569', 'Fulano c', 'fulanoa@os.com', -22.739187043911983, -47.31063136770589, true) on conflict (id) do nothing;
CREATE TABLE ordens_servico_status (
    id uuid primary key default(gen_random_uuid()),
    nome text not null
);
CREATE TABLE ordens_servico (
    id uuid primary key default(gen_random_uuid()),
    protocolo text unique not null,
    descricao text,
    endereco text,
    lat double precision,
    lng double precision,
    data_agendada timestamptz not null,
    previsao time not null,
    tecnico_id uuid not null references tecnicos(id),
    status_id uuid not null references ordens_servico_status(id)
);
create table usuario (id uuid primary key default(gen_random_uuid()), login text not null, password text not null);
insert into usuario (id, login, password) values ('77334473-f2aa-4906-bdac-e8e7778e0824', 'root', crypt('root', gen_salt('bf'))) on conflict(id) do nothing;

INSERT INTO ordens_servico_status (id, nome) VALUES ('a8827f04-f26c-4ba7-8593-d3572b22baf9', 'pendente') on conflict (id) do nothing;
INSERT INTO ordens_servico_status (id, nome) VALUES ('2b704832-ffd9-4d38-b99d-043943b9e278', 'em_andamento') on conflict (id) do nothing;
INSERT INTO ordens_servico_status (id, nome) VALUES ('2c5c7397-e49e-4b92-a40f-2c0297dd4386', 'concluida') on conflict (id) do nothing;
commit;
