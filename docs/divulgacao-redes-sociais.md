# Divulgação automática nas redes sociais (n8n)

Workflow: [`automacoes/divulgacao-redes-sociais.json`](../automacoes/divulgacao-redes-sociais.json)
Importe em *n8n → Workflows → Import from file*. Depois selecione as credenciais em cada nó.

## O que faz

1. **Agenda:** segunda, quarta e sexta às 10h (fuso de São Paulo). Também há um gatilho manual.
2. **Tema:** escolhe em rodízio entre 8 temas baseados no que o site já afirma (ramal remoto, ligações por valor fixo, Slack + Zoho Desk, monitoramento, consultoria, CRM e mensagens, portaria remota, sistemas sob medida).
3. **Texto:** o Claude escreve uma versão para LinkedIn, Facebook e Instagram, usando só os fatos do tema (sem inventar números, preços ou clientes). Se a IA falhar, entra um texto fixo e seguro.
4. **Link:** acrescenta o site com `utm_source` de cada rede, para medir o retorno no Analytics.
5. **Aprovação (padrão):** envia o rascunho por **Gmail** com o botão "Aprovar e publicar". Só publica depois de clicar. Em 48 h sem aprovação, o post é descartado.
6. **Publicação:** LinkedIn (página da empresa), Facebook (Página) e Instagram (conta profissional, exige imagem).
7. **Resultado:** envia um e-mail dizendo o que foi publicado e o que falhou.

## Variáveis do n8n (Settings → Variables)

| Variável | Para quê |
|---|---|
| `SITE_URL` | endereço do site (padrão `https://conectxip.com`) |
| `SOCIAL_APPROVAL` | `true` pede aprovação por e-mail (padrão); `false` publica direto |
| `SOCIAL_APPROVER_EMAIL` | e-mail de quem aprova e recebe os avisos (vários, separados por vírgula) |
| `SOCIAL_IMAGE_URL` | imagem pública (https) para o Instagram. Sem ela, o Instagram é ignorado |
| `SOCIAL_AI_MODEL` | opcional, modelo do Claude (padrão `claude-sonnet-5-5`) |
| `LINKEDIN_AUTHOR_URN` | quem publica: `urn:li:person:XXXX` (perfil) ou `urn:li:organization:NNNN` (página) |
| `LINKEDIN_API_VERSION` | opcional, versão da API do LinkedIn no formato `AAAAMM` (padrão `202510`) |
| `FACEBOOK_PAGE_ID` | ID da Página do Facebook |
| `INSTAGRAM_USER_ID` | ID da conta profissional do Instagram (Graph API) |

## Credenciais

- **Anthropic:** credencial *Header Auth* com nome `x-api-key` e a chave da API como valor.
- **Gmail:** credencial *Gmail OAuth2* no n8n (Google Cloud: ative a *Gmail API*, crie o cliente OAuth e use a URL de retorno da credencial). O envio usa a conta que fez o login.
- **LinkedIn (HTTP Request + OAuth2 genérica):** o nó usa a API `POST /rest/posts`. Crie uma credencial *OAuth2 API* no n8n com:
  - Authorization URL: `https://www.linkedin.com/oauth/v2/authorization`
  - Access Token URL: `https://www.linkedin.com/oauth/v2/accessToken`
  - Scope: `openid profile w_member_social` (perfil) ou `w_organization_social` (página, só com *Community Management API* aprovado)
  - Authentication: *Body*
  - Copie a *OAuth Redirect URL* para *Authorized redirect URLs* do app no LinkedIn.
  - **Perfil pessoal:** no app, ative os produtos *Share on LinkedIn* e *Sign In with LinkedIn using OpenID Connect*. Para descobrir o seu ID, faça `GET https://api.linkedin.com/v2/userinfo` com a credencial; o campo `sub` é o ID, e a variável fica `urn:li:person:<sub>`.
  - **Página da empresa:** exige o produto *Community Management API* aprovado e que você seja administrador da página. O erro `unauthorized_scope_error` indica que isso ainda não foi liberado.
- **Facebook e Instagram:** crie um app na Meta for Developers e gere um token **de Página** de longa duração com `pages_manage_posts`, `pages_read_engagement`, `instagram_basic` e `instagram_content_publish`. A conta do Instagram precisa ser profissional e estar ligada à Página.

## Antes de ligar

1. Rode o gatilho manual com `SOCIAL_APPROVAL=true` e confira o rascunho no e-mail.
2. Aprove e verifique se os três posts saíram. Corrija credenciais ou IDs se algum falhar.
3. Só então ative o workflow.

## Limites e cuidados

- Os temas e fatos ficam no nó **Escolhe Tema**. Edite ali para incluir novidades, promoções ou cases autorizados.
- O Instagram só publica com imagem. Sem `SOCIAL_IMAGE_URL`, o fluxo pula essa rede.
- Aprovação por link: quem tiver o link do e-mail consegue aprovar, então não o encaminhe. Alguns antivírus de e-mail abrem os links automaticamente e podem aprovar sem querer. Se isso acontecer, mande a aprovação para um e-mail sem varredura de links ou me peça uma página de confirmação.
- Nunca coloque tokens ou chaves no JSON nem no repositório. Eles ficam nas credenciais do n8n.
- O workflow não foi executado em um n8n real. A lógica de escolha do tema e a montagem dos textos foram testadas à parte, mas as chamadas às redes dependem de suas credenciais.
