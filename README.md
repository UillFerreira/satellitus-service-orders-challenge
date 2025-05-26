
# Documentação da API de Ordens de Serviço

## 📋 Pré-requisitos
- [PHP](https://www.php.net/) 8.0+
- [PostgreSQL](https://www.postgresql.org/) 12+
- [Docker](https://docs.docker.com/get-docker/) instalado
-  [Docker Compose](https://docs.docker.com/compose/install/) instalado

## 🐳 Execução com Docker

Para rodar a aplicação em ambiente Docker, siga estes passos:

### Passos para execução

1. **Clone o repositório**:
```bash
git clone git@github.com:UillFerreira/satellitus-service-orders-challenge.git
cd satellitus-service-orders-challenge
```

2. Crie uma cópia do arquivo .env de exemplo
```bash
cp .env.example .env
```
3. Iniciar o docker
```bash
docker-compose up -d --build
```
4.  **Serviços disponíveis**:
    

-   API:  [http://localhost:8000](http://localhost:8000/)
    
-   Banco de dados PostgreSQL: porta 5432
    

## 🔐 Autenticação

### 1. Obter Token de Acesso
```http
POST /token
Content-Type: application/json

{
  "username": "seu_usuario",
  "password": "sua_senha"
}
```

**Resposta de Sucesso (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
}
```

**Resposta de Erro (401 Unauthorized):**
```json
{
  "error": "Credenciais inválidas"
}
```
**Exemplo**
```bash
curl -X POST http://localhost8000/token -d "login=root&password=root" -H "Content-Type: application/x-www-form-urlencoded"

```
**Credenciais para testar**
login; root
password: root

## 📡 Endpoints da API

### 2. Criar Ordem de Serviço (POST)
```http
POST /ordens-servico
Authorization: Bearer <token>
Content-Type: application/json

{
  "descricao": "Minha oitava OS",
  "endereco": "rua um",
  "lat": "-22.92367541073393",
  "lng": "-47.07953579624083",
  "data_agendada": "2025-05-23 13:10:10",
  "previsao": "2025-05-23 14:00:00"
}
```

**Resposta de Sucesso (201 Created):**
```json
{
  "id": "54fef83c-6e08-4e67-9838-923058fa252f",
  "nome": "Fulano A",
  "email": "fulanoa@os.com",
  "protocolo": "2505251938250344"
}
```

### 3. Atualizar Status da OS (PATCH)
```http
PATCH /ordens-servico/{id}/status
Authorization: Bearer <token>
Content-Type: application/json

{
  "tecnico_id": "80c6cf92-abe4-4d4d-95b0-4ccc6709c569"
}
```

**Resposta de Sucesso (200 OK):**
```json
{
  "status": "concluida"
}
```

### 4. Listar Ordens de Serviço (GET)
```http
GET /ordens-servico?tecnico_id=40ad0e67-6992-4908-aca5-82a278f91f0a&status=2c5c7397-e49e-4b92-a40f-2c0297dd4386&data_ini=2025-05-20&data_fin=2025-05-22
Authorization: Bearer <token>
```

**Parâmetros Opcionais:**
- `tecnico_id`: UUID do técnico responsável
- `status`: UUID do status desejado
- `data_ini`: Data inicial (YYYY-MM-DD)
- `data_fin`: Data final (YYYY-MM-DD)

**Resposta de Sucesso (200 OK):**
```json
[
   {
      "id":"52514a0b-986c-41cb-9be9-770d6b2542b7",
      "protocolo":"2505251902070881",
      "descricao":"Minha nona OS",
      "endereco":"",
      "lat":"-22.92367541073393",
      "lng":"-47.07953579624083",
      "data_agendada":"2025-05-19 13:10:10",
      "previsao":"2025-05-19 14:00:00",
      "tecnico":"Fulano b",
      "status":"pendente"
   },
   {
      "id":"c6e0080b-a81e-488f-8443-891dd2a15efb",
      "protocolo":"2505251902395689",
      "descricao":"Minha oitava OS",
      "endereco":"rua um",
      "lat":"-22.92367541073393",
      "lng":"-47.07953579624083",
      "data_agendada":"2025-05-20 13:10:10",
      "previsao":"2025-05-20 14:00:00",
      "tecnico":"Fulano b",
      "status":"pendente"
   },
   {
      "id":"8ca5738e-ee03-4074-afec-3821a2f7aae4",
      "protocolo":"2505251930073070",
      "descricao":"Minha oitava OS",
      "endereco":"rua um",
      "lat":"-22.92367541073393",
      "lng":"-47.07953579624083",
      "data_agendada":"2025-05-23 13:10:10",
      "previsao":"2025-05-23 14:00:00",
      "tecnico":"Fulano b",
      "status":"pendente"
   }
]
```

## 🛠 Exemplos de Uso


### Exemplo em cURL
```bash
# Obter token
TOKEN=$(curl -s -X POST http://localhost/token \
  -H "Content-Type: application/json" \
  -d '{"username":"seu_usuario","password":"sua_senha"}' | jq -r '.token')

# Listar OS
curl -X GET "http://localhost/ordens-servico?data_ini=2025-05-20" \
  -H "Authorization: Bearer $TOKEN"
```
