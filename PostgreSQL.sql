-- CRIA O BANCO DE DADOS
CREATE DATABASE cityConnect_autenticacao;

-- LOGA NO BANCO DE DADOS
\c cityConnect_autenticacao;

-- TABELA DE USUÁRIOS
CREATE TABLE usuario (
    id_usuario      SERIAL PRIMARY KEY,
    nome            VARCHAR(150) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    senha_hash      VARCHAR(255) NOT NULL,
    data_criacao    TIMESTAMP NOT NULL DEFAULT NOW(),
    ultimo_login    TIMESTAMP,
    status          VARCHAR(20) NOT NULL DEFAULT 'ATIVO',
    
    CONSTRAINT chk_usuario_status
        CHECK (status IN ('ATIVO', 'INATIVO', 'PENDENTE_VERIFICACAO'))
);


-- TABELA DE PAPÉIS (ROLES)
--    Ex.: CIDADÃO, SERVIDOR, MODERADOR, ADMIN
CREATE TABLE papel (
    id_papel    SERIAL PRIMARY KEY,
    nome        VARCHAR(50) NOT NULL UNIQUE,
    descricao   TEXT
);


-- RELAÇÃO N:N ENTRE USUÁRIOS E PAPÉIS
CREATE TABLE usuario_papel (
    id_usuario      INT NOT NULL,
    id_papel        INT NOT NULL,
    data_atribuicao TIMESTAMP NOT NULL DEFAULT NOW(),

    PRIMARY KEY (id_usuario, id_papel),

    CONSTRAINT fk_usuario_papel_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
        ON DELETE CASCADE,

    CONSTRAINT fk_usuario_papel_papel
        FOREIGN KEY (id_papel)
        REFERENCES papel (id_papel)
        ON DELETE RESTRICT
);


-- ENDEREÇOS DE USUÁRIOS (1:N)
CREATE TABLE endereco (
    id_endereco SERIAL PRIMARY KEY,
    id_usuario  INT NOT NULL,
    logradouro  VARCHAR(200) NOT NULL,
    numero      VARCHAR(20),
    complemento VARCHAR(100),
    bairro      VARCHAR(100),
    cidade      VARCHAR(100),
    uf          CHAR(2),
    cep         VARCHAR(10),
    latitude    DECIMAL(9,6),
    longitude   DECIMAL(9,6),

    CONSTRAINT fk_endereco_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
        ON DELETE CASCADE
);


--SESSÕES / TOKENS DE LOGIN
CREATE TABLE sessao (
    id_sessao   SERIAL PRIMARY KEY,
    id_usuario  INT NOT NULL,
    token       VARCHAR(255) NOT NULL UNIQUE,
    criado_em   TIMESTAMP NOT NULL DEFAULT NOW(),
    expira_em   TIMESTAMP NOT NULL,
    ip          VARCHAR(45),
    user_agent  VARCHAR(255),

    CONSTRAINT fk_sessao_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
        ON DELETE CASCADE
);


-- ÍNDICES ÚTEIS

CREATE INDEX idx_endereco_usuario ON endereco(id_usuario);
CREATE INDEX idx_sessao_usuario   ON sessao(id_usuario);
CREATE INDEX idx_sessao_expira_em ON sessao(expira_em);


-- DADOS INICIAIS
-- Papéis padrão do sistema
INSERT INTO papel (nome, descricao) VALUES
('CIDADÃO',  'Usuário cidadão comum do aplicativo CityConnect'),
('SERVIDOR', 'Funcionário da prefeitura com acesso a relatórios'),
('MODERADOR','Responsável por validar relatos de problemas'),
('ADMIN',    'Administrador do sistema');

-- Usuário administrador inicial (trocar "hash_de_senha" por um hash de verdade)
INSERT INTO usuario (nome, email, senha_hash, status)
VALUES ('Administrador Geral', 'admin@cityconnect.gov', 'hash_de_senha', 'ATIVO');

-- Atribui o papel ADMIN para o usuário criado acima
INSERT INTO usuario_papel (id_usuario, id_papel)
SELECT u.id_usuario, p.id_papel
FROM usuario u
JOIN papel p ON p.nome = 'ADMIN'
WHERE u.email = 'admin@cityconnect.gov';

-- FIM DO SCRIPT SQL PARA O SERVIÇO DE AUTENTICAÇÃO - CITYCONNECT
