# satellitus-service-orders-challenge
Gestão de ordem de serviços teste da Satellitus

Exemplo da chamada para receber um token
curl -X POST http://os.localhost/token -d "login=root&password=root" -H "Content-Type: application/x-www-form-urlencoded"



---

### 📤 Parâmetros esperados (JSON no corpo da requisição)

| Nome             | Tipo    | Obrigatório | Descrição                                          |
|------------------|---------|-------------|---------------------------------------------------|
| cliente_id       | integer | sim         | ID do cliente                                     |
| descricao        | string  | sim         | Descrição da ordem de serviço                     |
| data_agendamento | string  | sim         | Data/hora no formato `YYYY-MM-DD HH:MM:SS`        |
| tecnico_id       | integer | não         | ID do técnico responsável (opcional)              |

---

### 🧪 Exemplo com `curl`

```bash
curl -X POST http://localhost/ordens-servico \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -d '{
        "cliente_id": 1,
        "descricao": "Troca de componente X",
        "data_agendamento": "2025-05-22 10:00:00",
        "tecnico_id": 5
      }'
```
curl -X POST http://os.localhost/ordens-servico -d '{"descricao":"Minha oitava OS","endereco":"","lat":"-22.92367541073393","lng":"-47.07953579624083","data_agendada":"2025-05-20 13:10:10","previsao":"2025-05-20 14:00:00"}' -H "Content-Type: application/json" -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI3NzMzNDQ3My1mMmFhLTQ5MDYtYmRhYy1lOGU3Nzc4ZTA4MjQiLCJpYXQiOjE3NDgxOTUzMjcsImV4cCI6MTc0ODE5ODkyN30.2Dh4_GY4QDKvdxlCp9-86LppaZv3Uyic580eq6BRngI"
