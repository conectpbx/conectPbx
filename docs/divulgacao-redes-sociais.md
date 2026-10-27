# Divulgação automática nas redes sociais (n8n)

Workflow: [`automacoes/divulgacao-redes-sociais.json`](../automacoes/divulgacao-redes-sociais.json)
Importe em *n8n → Workflows → Import from file*. Depois selecione as credenciais em cada nó.

## O que faz

1. **Agenda:** segunda, quarta e sexta às 10h (fuso de São Paulo). Também há um gatilho manual.
2. **Tema:** escolhe em rodízio entre 8 temas baseados no que o site já afirma (ramal remoto, ligações por valor fixo, Slack + Zoho Desk, monitoramento, consultoria, CRM e mensagens, portaria remota, sistemas sob medida).
3. **Texto:** o Claude escreve uma versão para LinkedIn, Facebook e Instagram, usando só os fatos do tema (sem inventar números, preços ou clientes). Se a IA falhar, entra um texto fixo e seguro.
4. **Link:** acrescenta o site com `utm_source` de cada rede, para medir o retorno no Analytics.
5. **Aprovação (padrão):** envia o rascunho ao Slack com um link para aprovar. Só publica depois de clicar. Em 48 h sem aprovação, o post é descartado.
6. **Publicação:** LinkedIn (página da empresa), Facebook (Página) e Instagram (conta profissional, exige imagem).
7. **Resultado:** avisa no Slack o que foi publicado e o que falhou.

## Variáveis do n8n (Settings → Variables)

| Variável | Para quê |
|---|---|
| `SITE_URL` | endereço do site (padrão `https://conectxip.com`) |
| `SOCIAL_APPROVAL` | `true` pede aprovação no Slack (padrão); `false` publica direto |
| `SOCIAL_SLACK_CHANNEL` | ID do canal do Slack para aprovação e avisos |
| `SOCIAL_IMAGE_URL` | imagem pública (https) para o Instagram. Sem ela, o Instagram é ignorado |
| `SOCIAL_AI_MODEL` | opcional, modelo do Claude (padrão `claude-sonnet-5-5`) |
| `LINKEDIN_ORG_ID` | ID numérico da página da empresa no LinkedIn |
| `FACEBOOK_PAGE_ID` | ID da Página do Facebook |
| `INSTAGRAM_USER_ID` | ID da conta profissional do Instagram (Graph API) |

## Credenciais

- **Anthropic:** credencial *Header Auth* com nome `x-api-key` e a chave da API como valor.
- **Slack:** a mesma do workflow de tickets. O app precisa do escopo `chat:write` e estar no canal.
- **LinkedIn:** OAuth2 com permissão `w_organization_social`. Postar como página exige aprovação do produto *Community Management API* no LinkedIn Developers e que o usuário seja administrador da página.
- **Facebook e Instagram:** crie um app na Meta for Developers e gere um token **de Página** de longa duração com `pages_manage_posts`, `pages_read_engagement`, `instagram_basic` e `instagram_content_publish`. A conta do Instagram precisa ser profissional e estar ligada à Página.

## Antes de ligar

1. Rode o gatilho manual com `SOCIAL_APPROVAL=true` e confira o rascunho no Slack.
2. Aprove e verifique se os três posts saíram. Corrija credenciais ou IDs se algum falhar.
3. Só então ative o workflow.

## Limites e cuidados

- Os temas e fatos ficam no nó **Escolhe Tema**. Edite ali para incluir novidades, promoções ou cases autorizados.
- O Instagram só publica com imagem. Sem `SOCIAL_IMAGE_URL`, o fluxo pula essa rede.
- Aprovação por link: quem tiver o link no Slack consegue aprovar. Use um canal restrito.
- Nunca coloque tokens ou chaves no JSON nem no repositório. Eles ficam nas credenciais do n8n.
- O workflow não foi executado em um n8n real. A lógica de escolha do tema e a montagem dos textos foram testadas à parte, mas as chamadas às redes dependem de suas credenciais.
