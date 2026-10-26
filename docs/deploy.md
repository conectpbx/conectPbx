# Deploy automático (GitHub Actions + Docker)

A cada push na `main`, o GitHub Actions faz:

1. **Build** da imagem Docker (Nginx servindo o `index.html` e a pasta `assets/`).
2. **Teste**: sobe o container e confere o endereço `/healthz` e a presença de "ConectPbx" na página.
3. **Push** da imagem para o GitHub Container Registry (`ghcr.io/conectpbx/conectpbx`), com as tags `latest` e o hash do commit.
4. **Deploy**: conecta por SSH no servidor, baixa a imagem nova e recria o container com `docker compose up -d`.

Alterações só em arquivos `.md` ou na pasta `docs/` não disparam o deploy.

## Configuração única

### No servidor
1. Instale Docker e o plugin Compose.
2. Crie a pasta `~/conectpbx` e copie para ela o arquivo `deploy/docker-compose.yml`.
3. Descubra a rede Docker do Nginx Proxy Manager: `docker inspect <container-do-npm> --format '{{json .NetworkSettings.Networks}}'`.
   No `docker-compose.yml`, troque `npm_default` pelo nome dessa rede (ou crie um arquivo `.env` ao lado com `NPM_NETWORK=nome_da_rede`).
4. Crie um usuário só para o deploy, no grupo `docker`, e uma chave SSH exclusiva para ele:
   `ssh-keygen -t ed25519 -f deploy_key -C "github-actions"`
   Instale a chave pública (`deploy_key.pub`) em `~/.ssh/authorized_keys` desse usuário.

### No GitHub (Settings → Secrets and variables → Actions)
| Secret | Valor |
|---|---|
| `SSH_HOST` | IP ou domínio do servidor |
| `SSH_USER` | usuário do deploy |
| `SSH_KEY` | conteúdo da chave **privada** (`deploy_key`) |
| `SSH_PORT` | opcional, padrão 22 |
| `DEPLOY_PATH` | opcional, padrão `~/conectpbx` |

Crie também o ambiente **producao** (Settings → Environments). Se quiser aprovação manual antes de cada deploy, marque *Required reviewers*.

O login do servidor no registry usa o `GITHUB_TOKEN` da própria execução, então não é preciso criar token pessoal.

## Nginx Proxy Manager (primeira vez)
O container do site não publica porta. O NPM o acessa pelo nome, dentro da rede compartilhada.

1. Pare o container antigo do site (ou anote a configuração dele antes).
2. Faça o primeiro deploy (push na `main` ou *Run workflow* na aba Actions).
3. No NPM, abra o *Proxy Host* do domínio (conectxip.com) e altere:
   - **Forward Hostname / IP:** `conectpbx-site`
   - **Forward Port:** `80`
   - **Scheme:** `http`
4. Mantenha o SSL (Let's Encrypt) e ative *Force SSL* e *HTTP/2*, se ainda não estiverem ativos.
5. Teste o domínio. O NPM e o site precisam estar na mesma rede Docker, senão o NPM mostra 502.

Se o NPM mostrar **502 Bad Gateway**: confirme que o container está de pé (`docker ps`), que a rede do compose é a mesma do NPM e que o nome no Proxy Host é exatamente `conectpbx-site`.

## Voltar para uma versão anterior
Toda imagem fica com a tag do commit. No servidor, edite o `docker-compose.yml` para
`image: ghcr.io/conectpbx/conectpbx:<hash-do-commit>` e rode `docker compose up -d`.
Ou reverta o commit na `main`, e o fluxo faz o deploy da versão anterior.

## Segurança
- Nunca coloque senhas, tokens ou chaves no repositório. Use somente *Secrets*.
- A chave SSH deve ser exclusiva do deploy e de um usuário sem acesso de administrador.
- Se algum token foi exposto antes em conversa ou commit, revogue e gere outro.
