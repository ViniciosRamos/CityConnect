# 🚀 CityConnect

![status](https://img.shields.io/badge/status-Planning-blue) ![docker](https://img.shields.io/badge/docker-ready-blueviolet) ![language](https://img.shields.io/badge/lang-PT--BR-orange)

> *Plataforma de cidade inteligente para reporte cívico, notícias oficiais e consultas de transporte público.*

---
## 📋 Sobre o Trabalho

Disciplina: Ciência de Dados I / 25-2

Professor: Dr. Gabriel Machado Lunardi

Curso: Engenharia de Computação - Universidade Federal de Santa Maria

---

## 👥 Integrantes

- Arthur Portella 
- Lucas Rocha
- Luis Zorzi
- Vinicios Ramos

---

## 🏙️ Visão Geral

Utilizando uma abordagem de persistência poliglota, o CityConnect é uma combinação de informações aos cidadãos, disponibilizando consultas ao transpote público, informações de noticias municipais e reports de problemas na cidade.

---

## 🎯 Tarefas

### Microsserviços: 

####  Autenticação e Gerenciamento de Usuários
  - Tecnologia: PostgreSQL(SQL)
  - Porque SQL?
    - Os dados dos usuários(ID, nome, e-mail, hash de senha, tipo de usuário - cidadão ou funcionário) são estruturaos e relcionais, a nessecidade de ACID(Atomicidade, Consistência, Isolamento, Durabilidade) é critica para a garantia de integridade e segurança das contas.
      - Tem como vantagem uma melhor consistência e suporte a transações, garantindo integridade, segurança e prevenindo dados inconsistentes.
  
  - Por que não as outras?
  
####  Sistema de Reportes de Problemas
  - Tecnologia: MongoDB (NoSQL - Documentos)
  - Porque MongoDB?
 
####  Feed de Notícias da Prefeitura
  - Tecnologia: Firebase Realtime Database ou Firestore
  - Porque Firebase?
   
####  Base de Conhecimento de Rotas de Transporte Público
  - Tecnologia: Neo4j (NoSQL - Grafos)
  - Porque Neo4j?
    
---

## ✨ Principais Funcionalidades

* ✅ Sistema de autenticação para cidadãos e funcionários
* 🚧 Reportes de problemas urbanos com geolocalização e fotos
* 📢 Feed de notícias da prefeitura em tempo real
* 🚌 Base de conhecimento das rotas de transporte público

---

## 🧭 Arquitetura (resumo)


|Microsserviço |	Tecnologia |	Tipo de Dados |	Justificativa Principal |
| :--- | :---: | :---: | :---: |
|Autenticação |	PostgreSQL |	Dados Estruturados |	Consistência e ACID |
|Reportes	|MongoDB |	Dados Semiestruturados |	Flexibilidade de Schema e Escalabilidade |
|Feed de Notícias |	Firebase |	Dados em Tempo Real |	Sincronização Instantânea |
|Transporte Público |	Neo4j |	Dados de Relacionamento | 	Consultas Eficientes em Grafos |

---

## 🛠️ Tech Stack (recomendado)

* Linguagens: Node.js / Python / Go (por serviço, conforme necessidade)
* Datastores: PostgreSQL (+ PostGIS), MongoDB, Neo4j, Redis, S3/MinIO
* Mensageria: Kafka ou Redis Streams
* Deploy: Docker Compose (dev) → Kubernetes (produção)
* Observability: Prometheus + Grafana, logs centralizados (ELK)

---

## 📦 Quickstart — Execução Local (dev)

**Requisitos:** Docker, Docker Compose

1. Clone o repositório:

```bash
git clone https://github.com/SEU-ORGANIZACAO/cityconnect.git
cd cityconnect
```

2. Iniciar infraestrutura mínima (Postgres+PostGIS, MongoDB, Neo4j, Redis, MinIO):

```bash
# Exemplo: docker-compose.yml incluído em /deploy/docker-compose.yml
docker compose -f deploy/docker-compose.yml up -d
```

3. Criar schemas e dados de exemplo:

```bash
# SQL DDL para Auth/Postgres
psql -h localhost -U postgres -d cityconnect -f scripts/sql/ddl_auth.sql
# Exemplo Mongo: carregar reports de amostra
mongoimport --uri "mongodb://localhost:27017/cityconnect" --collection reports --file scripts/mongo/sample_reports.json --jsonArray
# Cypher: popular Neo4j com estações
cypher-shell -u neo4j -p neo4j "CALL apoc.periodic.iterate(... )"  # ou rodar scripts/cypher/import.cypher
```

4. Rodar serviços (em containers separados) ou executar localmente em modo desenvolvimento.

> Para conveniência, há um `Makefile` com comandos úteis (`make up`, `make down`, `make seed`).

---

## 🔐 Configuração e Segurança

* Todas as comunicações devem usar HTTPS em produção.
* Senhas e segredos em variáveis de ambiente; use um vault (HashiCorp Vault, AWS Secrets Manager).
* Hashing de senhas: ARGON2 ou BCRYPT.
* Limites de upload e validação de arquivos para prevenir uploads maliciosos.
* Política de CORS restritiva e rate-limits por cliente.

---

## 🗂️ Modelos de Dados (exemplos)

### 1) SQL (Postgres + PostGIS) — trecho DDL (Auth)

```sql
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE municipalities (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  code TEXT UNIQUE
);

CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  full_name TEXT,
  municipality_id INT REFERENCES municipalities(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
```

---

### 2) MongoDB — exemplo de documento `reports`

```json
{
  "title": "Buraco profundo na Av. Central",
  "description": "Veículos desviando, risco de acidente.",
  "category": "infrastructure",
  "status": "submitted",
  "reporter": { "user_id": 12345, "name": "João Silva" },
  "location": { "type": "Point", "coordinates": [-53.8, -29.6] },
  "photos": [ { "url": "https://minio.local/cityconnect/...." } ],
  "created_at": "2025-11-01T12:30:00Z"
}
```

---

### 3) Neo4j (Cypher) — exemplo de criação de nós e relações

```cypher
CREATE (s1:Station {id: 'S001', name: 'Central', lat:-29.6, lon:-53.8});
CREATE (s2:Station {id: 'S002', name: 'Sete de Setembro', lat:-29.601, lon:-53.805});
CREATE (s1)-[:CONNECTS_TO {travel_time: 3, distance: 400}]->(s2);
```

---

## 📡 Endpoints Principais (exemplos)

* `POST /api/v1/auth/register` — registrar usuário
* `POST /api/v1/auth/login` — obter JWT
* `POST /api/v1/reports` — criar report (multipart/form-data com fotos)
* `GET /api/v1/reports?near=lat,lon&radius=500` — reports próximos
* `GET /api/v1/transport/route?from=ID1&to=ID2` — obter rota entre estações

> Uma collection Postman / Insomnia está disponível em `/tools/postman/cityconnect.postman_collection.json`.

---

## ✅ Testes e Qualidade

* Testes unitários por serviço (pytest / jest / go test)
* Testes de integração contra containers (docker-compose)
* CI: pipeline para lint, testes e build de imagens (GitHub Actions / GitLab CI)

---

## 📈 Observability

* Métricas: Prometheus + Grafana
* Tracing distribuído: OpenTelemetry
* Logs centralizados: ELK (Elasticsearch / Logstash / Kibana) ou Loki + Grafana

---

## ♻️ Estratégia de Deploy

* Ambiente dev: Docker Compose (scripts em `deploy/`)
* Produção: Kubernetes (Helm charts), usar serviços gerenciados para bancos (RDS, Mongo Atlas, Neo4j Aura)
* CI/CD: pipelines para build, testes, imagem e deploy automático em staging/production

---

## 📚 Recursos e Referências


* Documentação oficial: PostgreSQL, MongoDB, Firebase, Neo4j
* Padrões de persistência poliglota
* Melhores práticas para arquitetura de microsserviços
---
