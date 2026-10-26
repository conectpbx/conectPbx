#!/usr/bin/env bash
# Executado no servidor pelo GitHub Actions. Variáveis esperadas: GHCR_USER, GHCR_TOKEN, IMAGE, DEPLOY_PATH (opcional).
set -Eeuo pipefail
trap 'echo "ERRO na linha $LINENO: $BASH_COMMAND (codigo $?)"' ERR

echo "Usuario: $(whoami) | Host: $(hostname)"

DEST="${DEPLOY_PATH:-}"
if [ -z "$DEST" ]; then DEST="$HOME/conectpbx"; fi
case "$DEST" in "~"*) DEST="$HOME${DEST#\~}" ;; esac
echo "Pasta de deploy: $DEST"

if ! command -v docker >/dev/null 2>&1; then
  echo "ERRO: docker nao encontrado no PATH do usuario $(whoami)."; exit 1
fi
if ! docker info >/dev/null 2>&1; then
  echo "ERRO: o usuario $(whoami) nao tem permissao no Docker. Rode: sudo usermod -aG docker $(whoami) e reconecte."; exit 1
fi
if [ ! -d "$DEST" ]; then
  echo "ERRO: a pasta $DEST nao existe. Crie-a e copie deploy/docker-compose.yml para ela."; exit 1
fi
cd "$DEST"

COMPOSE=""
for f in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
  if [ -z "$COMPOSE" ] && [ -f "$f" ]; then COMPOSE="$f"; fi
done
if [ -z "$COMPOSE" ]; then
  echo "ERRO: nenhum arquivo compose em $DEST. Conteudo:"; ls -la; exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "ERRO: plugin 'docker compose' nao instalado."; exit 1
fi

echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USER" --password-stdin >/dev/null
docker pull "$IMAGE:latest"
echo "Usando $COMPOSE"
docker compose -f "$COMPOSE" up -d --remove-orphans
docker compose -f "$COMPOSE" ps
docker image prune -f >/dev/null
docker logout ghcr.io >/dev/null
echo "Deploy concluido."
