# 🚀 CityConnect

![status](https://img.shields.io/badge/status-Planning-blue) ![docker](https://img.shields.io/badge/docker-ready-blueviolet) ![language](https://img.shields.io/badge/lang-PT--BR-orange)

> *Plataforma de cidade inteligente para reporte cívico, notícias oficiais e consultas de transporte público.*

---
## 📋 Sobre o Trabalho

Disciplina: Ciência de Dados I - 25/2

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
    - Redis/MongoDB/Firebase: Não oferecem garantias transacionais ACID tão robustas por padrão nesse contexto. São "overkill" para dados tão simples e fixos.

    - Neo4j: A relação entre usuários não é o foco principal deste microsserviço.
  
####  Sistema de Reportes de Problemas
  - Tecnologia: MongoDB (NoSQL - Documentos)
  - Porque MongoDB?
    - Os reportes são dados não semiestruturados. Buracos, postes queimados, lixo acumulado podem ter atributos comuns (titulo, descrição,localização, fotos), mas tambem podem ter atributos especificos (profundidade do buraco, numero do poste). O MongoDB armazena arquivos JSON, permitindo flexibilidade sem alterar o schema do banco.
       - Tem como vantagem a escalabilidade horizontal para lidar com grande volume de reportes. Estrutura de documentos é natural para armazenar arrays de fotos(URLs) e objetos de geolocalização (coordenadas lat/long)
   
  - Porque não as outras?
    - SQL: Um schema rígido seria limitante. Para adicionar um novo tipo de problema, seria necessário alterar a tabela, o que é mais lento e complexo.

    - Neo4j/Firebase/Redis: Não são otimizados para armazenar e consultar uma grande coleção de documentos semiestruturados com essa natureza.
    
####  Feed de Notícias da Prefeitura
  - Tecnologia: Firebase Realtime Database ou Firestore
  - Porque Firebase?
    - O feed de noticias precisa ser compartilhado em tempo real para inumeros usuários, ao mesmo tempo. O firebase tem como especialização a sincronização em tempo real entre servidor e usuários conectados.
      - Tem como vantagema baixa latência, escalabilidade gerenciada pelo Google, e facilidade de desenvolvimento(SDKs naivo para mobile). Ideal para fluxo de  dados que é mais "lido" e não "escrito"
  
  - Porque não as outras?
    - SQL/MongoDB: São bancos "pull-based" (o app precisa consultar para buscar atualizações), não "push-based" (o servidor envia as atualizações). Implementar notificações em tempo real com eles é mais complexo.

    - Redis: Poderia ser usado como uma camada de cache/pub-sub, mas não como banco principal para persistência de longo prazo das notícias.

    - Neo4j: A estrutura de dados (notícias lineares com timestamp) não é um grafo.
    
####  Base de Conhecimento de Rotas de Transporte Público
  - Tecnologia: Neo4j (NoSQL - Grafos)
  - Porque Neo4j?
    - O sistema de transporte público é, por natureza, um grafo. As paradas são nós, as linhas de onibus/metrô que se conectam são arestas. Fazer uma consulta de trajeto em grafos é extremamente eficiente.
    - Performance superior para consulta de relacionamentos complexos e múltiplos saltos(ex: rota da UFSM até o shopping royal, via faixa nova).
    
  - Porque não as outras?
    - SQL: Requer junções complexas de múltiplas tabelas (estações, rotas, conexões), que se tornam muito lentas à medida que o número de conexões aumenta (problema do "JOIN bomb").

    - MongoDB/Firebase: Não são projetados para consultas de relacionamentos profundos. A lógica de navegação teria que ser implementada na aplicação, o que é ineficiente.

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

## 🗂️ Modelos de Dados

#### 1) SQL (Postgres + PostGIS) — trecho DDL (Auth)

---

#### 2) MongoDB — documento `reports`



---

#### 3) Neo4j - criação de nós e relações


---

## 📚 Recursos e Referências

* Documentação oficial: PostgreSQL, MongoDB, Firebase, Neo4j
* Padrões de persistência poliglota
* Melhores práticas para arquitetura de microsserviços

---
