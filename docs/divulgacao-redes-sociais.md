# Divulgação automática nas redes sociais (n8n)

Workflow: [`automacoes/divulgacao-redes-sociais.json`](../automacoes/divulgacao-redes-sociais.json)
Importe em *n8n → Workflows → Import from file*. Depois selecione as credenciais em cada nó.

## O que faz

1. **Agenda:** segunda, quarta e sexta às 10h (fuso de São Paulo). Também há um gatilho manual.
2. **Tema:** escolhe em rodízio entre 8 temas baseados no que o site já afirma (ramal remoto, ligações por valor fixo, Slack + Zoho Desk, monitoramento, consultoria, CRM e mensagens, portaria remota, sistemas sob medida).
3. **Texto:** o Claude escreve uma versão para LinkedIn, Facebook e Instagram, usando só os fatos do tema (sem inventar números, preços ou clientes). Se a IA falhar, entra um texto fixo e seguro.
4. **Link:** acrescenta o site com `utm_source` de cada rede, para medir o retorno no Analytics.
5. **Imagem:** o Claude descreve a imagem, o **FLUX.1-schnell (Cloudflare Workers AI)** a gera e o **imgbb** a hospeda numa URL pública. Se a Cloudflare ou o imgbb falharem, o fluxo usa a imagem fixa de reserva (`SOCIAL_IMAGE_URL`) ou segue sem imagem.
6. **Aprovação (padrão):** envia o rascunho por **Gmail** com o botão "Aprovar e publicar". Só publica depois de clicar. Em 48 h sem aprovação, o post é descartado.
7. **Publicação:** LinkedIn (página da empresa), Facebook (Página) e Instagram (conta profissional, exige imagem).
8. **Resultado:** envia um e-mail dizendo o que foi publicado e o que falhou.

## Configuração (nó "Configuração — Edite Aqui")

Todas as configurações ficam em um único nó de código no início do fluxo, sem depender do recurso *Variables* do n8n (que não existe em algumas edições). Abra o nó e preencha:

| Campo | Para quê |
|---|---|
| `SITE_URL` | endereço do site |
| `SOCIAL_APPROVAL` | `'true'` pede aprovação por e-mail; `'false'` publica direto |
| `SOCIAL_APPROVER_EMAIL` | e-mail de quem aprova e recebe os avisos (vários, separados por vírgula) |
| `GERAR_IMAGEM` | `'true'` gera a imagem com o Cloudflare Workers AI; `'false'` usa só a imagem fixa |
| `CLOUDFLARE_ACCOUNT_ID` | ID da conta Cloudflare (32 caracteres), no painel em *Workers & Pages* |
| `CLOUDFLARE_IMAGE_MODEL` | modelo de imagem (padrão `@cf/black-forest-labs/flux-1-schnell`) |
| `IMGBB_EXPIRA_DIAS` | por quantos dias a imagem fica no imgbb (1 a 180) |
| `SOCIAL_IMAGE_URL` | imagem fixa de reserva (https), usada se a geração falhar. Vazio = sem reserva |
| `SOCIAL_AI_MODEL` | modelo do Claude |
| `LINKEDIN_AUTHOR_URN` | vazio = publica no seu perfil automaticamente; ou `urn:li:organization:NNNN` para a página |
| `LINKEDIN_API_VERSION` | versão da API do LinkedIn (`AAAAMM`). O LinkedIn desativa cada versão após cerca de 1 ano, então atualize a cada 6 meses. Erro "version is not active" = versão antiga demais |
| `FACEBOOK_PAGE_ID` | ID da Página do Facebook |
| `INSTAGRAM_USER_ID` | ID da conta profissional do Instagram |

Não coloque tokens nem senhas nesse nó. Eles ficam nas credenciais do n8n.

## Credenciais

- **Anthropic:** credencial *Header Auth* com nome `x-api-key` e a chave da API como valor.
- **Gmail:** credencial *Gmail OAuth2* no n8n (Google Cloud: ative a *Gmail API*, crie o cliente OAuth e use a URL de retorno da credencial). O envio usa a conta que fez o login.
- **LinkedIn (HTTP Request + OAuth2 genérica):** o nó usa a API `POST /rest/posts`. Crie uma credencial *OAuth2 API* no n8n com:
  - Authorization URL: `https://www.linkedin.com/oauth/v2/authorization`
  - Access Token URL: `https://www.linkedin.com/oauth/v2/accessToken`
  - Scope: `openid profile w_member_social` (perfil) ou `w_organization_social` (página, só com *Community Management API* aprovado)
  - Authentication: *Body*
  - Copie a *OAuth Redirect URL* para *Authorized redirect URLs* do app no LinkedIn.
  - **Perfil pessoal:** no app, ative os produtos *Share on LinkedIn* e *Sign In with LinkedIn using OpenID Connect*. O workflow descobre o seu ID sozinho (`GET /v2/userinfo`), então `LINKEDIN_AUTHOR_URN` pode ficar vazio.
  - **Página da empresa:** exige o produto *Community Management API* aprovado e que você seja administrador da página. O erro `unauthorized_scope_error` indica que isso ainda não foi liberado.
- **Cloudflare (imagens):** crie um *API Token* com permissão **Workers AI** (My Profile → API Tokens). No n8n, crie uma credencial *Header Auth* com nome `Authorization` e valor `Bearer <token>`. O ID da conta vai no nó de configuração. A imagem sai em JPEG, formato aceito pelo Instagram.
- **imgbb:** credencial *Query Auth* com nome `key` e a chave de API do imgbb (api.imgbb.com).
- **Facebook e Instagram:** crie um app na Meta for Developers e gere um token **de Página** de longa duração com `pages_manage_posts`, `pages_read_engagement`, `instagram_basic` e `instagram_content_publish`. A conta do Instagram precisa ser profissional e estar ligada à Página.

## Antes de ligar

1. Rode o gatilho manual com `SOCIAL_APPROVAL=true` e confira o rascunho no e-mail.
2. Aprove e verifique se os três posts saíram. Corrija credenciais ou IDs se algum falhar.
3. Só então ative o workflow.

## Imagens

Para trocar de provedor de imagem no futuro, basta substituir o nó **Cloudflare — Gerar Imagem**: o **Extrai Imagem** entrega o resultado ao resto do fluxo.

- O prompt pede ilustração quadrada, sem texto, sem logotipos e sem pessoas, em azul-marinho com laranja. Texto dentro de imagens gerada por IA pode vir com letras erradas, por isso o texto fica no post.
- A imagem aparece no e-mail de aprovação. Se não gostar, não aprove e rode o fluxo de novo.
- Considere indicar nas redes que as imagens são geradas por IA.
- O FLUX.1-schnell segue os termos da Black Forest Labs. A Cloudflare informa retenção zero de dados no modelo. Confira os termos e os limites gratuitos do Workers AI no painel antes de ativar em produção.
- O imgbb é um serviço gratuito de terceiros: as imagens ficam acessíveis por link público. Use apenas conteúdo que pode ser público. A chave da API é pessoal.
- Facebook: com imagem, o post sai como foto com legenda e o link do site. Sem imagem, sai como texto com link.
- Instagram: a API documenta imagens em JPEG, e o FLUX.1-schnell na Cloudflare devolve JPEG.
- LinkedIn: por enquanto o post sai só com texto e link. O envio de imagem no LinkedIn é uma segunda etapa.

## Limites e cuidados

- Os temas e fatos ficam no nó **Escolhe Tema**. Edite ali para incluir novidades, promoções ou cases autorizados.
- O Instagram só publica com imagem. Sem `SOCIAL_IMAGE_URL`, o fluxo pula essa rede.
- Aprovação por link: quem tiver o link do e-mail consegue aprovar, então não o encaminhe. Alguns antivírus de e-mail abrem os links automaticamente e podem aprovar sem querer. Se isso acontecer, mande a aprovação para um e-mail sem varredura de links ou me peça uma página de confirmação.
- Nunca coloque tokens ou chaves no JSON nem no repositório. Eles ficam nas credenciais do n8n.
- O workflow não foi executado em um n8n real. A lógica de escolha do tema e a montagem dos textos foram testadas à parte, mas as chamadas às redes dependem de suas credenciais.
