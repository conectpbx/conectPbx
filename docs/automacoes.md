# Automação Slack → Zoho Desk

Fluxo em n8n que transforma mensagens de canais do Slack em tickets e comentários no Zoho Desk.

## Regras

1. **Sem thread:** um ticket por canal por dia. Mensagens seguintes viram comentários nele.
2. **Com thread:** a thread abre um ticket novo. O título e a descrição vêm da mensagem que a iniciou, e as respostas viram comentários.
3. **Citação:** cada comentário cita a mensagem anterior (o Zoho não tem encadeamento nativo).
4. **Anexos:** até 10 arquivos por mensagem são baixados do Slack e anexados ao ticket.
5. **Ticket fechado ou inexistente:** o fluxo cria um ticket novo e limpa o controle no Redis.
6. **Duplicidade:** trava de criação e deduplicação por mensagem no Redis.

## Componentes

Slack Trigger (escuta o workspace; os canais permitidos vêm da variável `ALLOWED_CHANNELS`), Redis, API do Zoho Desk (OAuth2) e n8n.

## Variáveis do n8n

`ZOHO_ORG_ID`, `ZOHO_DEPT_ID`, `TIMEZONE`, `ALLOWED_CHANNELS`, `ZOHO_PRIORITY`.

## Permissões do Slack

`channels:history`, `groups:history`, `channels:read`, `groups:read`, `users:read`, `users:read.email`, `files:read`.
Convide o app em cada canal (`/invite`).

## Segurança

Nunca versione tokens, chaves de API ou credenciais. Use as credenciais do n8n e variáveis de ambiente.
O workflow exportado do n8n não deve conter segredos antes de ser adicionado ao repositório.
