# ConectPbx — Site institucional

Site de uma página da **ConectPbx**, empresa de telefonia IP e TI de São Paulo (desde 2018).
Apresenta os serviços, a plataforma **ConnectX** (PABX IP na nuvem), integrações entre CRMs e
aplicativos de mensagens corporativas, portfólio e contato.

## O que tem no site

| Seção | Conteúdo |
|---|---|
| Início | Hero, números da empresa e **softphone de demonstração** do ConnectX (simulado) |
| Serviços | Telecom, TI, monitoramento e desenvolvimento |
| ConnectX | Recursos do PABX IP e exemplo de fluxo de chamada (URA, fila, desvio, registro) |
| Integrações | Demonstração interativa **Slack → Zoho Desk** e lista de outras integrações |
| Como trabalhamos | Diagnóstico, implantação e acompanhamento |
| Portfólio | Projetos com filtro (App, Pabx IP, Web, Integrações) |
| Dúvidas | Perguntas frequentes (FAQ) |
| Contato | Telefone, e-mail, WhatsApp e formulário |

Tema claro e escuro automáticos (seguem o do aparelho), menu para celular, botão fixo de WhatsApp, alvos de toque de pelo menos 44 px, foco visível por teclado e redução de animações para quem prefere. Layout responsivo.

## Estrutura

```
index.html        página completa (HTML, CSS e JS num único arquivo)
assets/img/       logos de clientes e imagens do portfólio (adicionar)
docs/             documentação adicional
```

O site em si não tem build nem dependências; o Docker só empacota os arquivos. As fontes (Bricolage Grotesque, IBM Plex) vêm do Google Fonts.

## Como publicar

1. Faça backup do site atual.
2. Envie `index.html` e a pasta `assets/` para a raiz do servidor (ou ative o GitHub Pages em
   *Settings → Pages → Branch: main*).
3. Para testar localmente: `python3 -m http.server 8080` e abra `http://localhost:8080`.

## Deploy automático

Um push na `main` constrói a imagem Docker, testa, publica no GitHub Container Registry e atualiza o container no servidor por SSH. Passo a passo e secrets em [docs/deploy.md](docs/deploy.md).

```
Dockerfile, nginx.conf   imagem do site (Nginx)
.github/workflows/       pipeline de build, teste e deploy
deploy/docker-compose.yml  referência para o servidor
```

## Divulgação nas redes sociais

Workflow n8n que gera posts com IA, pede aprovação no Slack e publica no LinkedIn, Facebook e Instagram. Arquivo em `automacoes/` e guia em [docs/divulgacao-redes-sociais.md](docs/divulgacao-redes-sociais.md).

## Demonstrações

### Softphone ConnectX (simulado)
Funciona só no navegador, sem ligação real. Ramais fictícios 201 a 204 com estados livre, ocupado
e ausente; suporta ligar, mudo, espera, transferir e registro de chamadas.
Para uma demonstração real, escolha uma destas opções e substitua o bloco `#demo` do `index.html`:

- **Softphone WebRTC** num `<iframe>`, com um ramal de demonstração sem saída para números externos.
- **Vídeo gravado** da tela do ConnectX, incorporado do YouTube.
- **Ambiente de teste** com login e dados fictícios.

### Integração Slack → Zoho Desk (simulada)
Mostra a regra do fluxo de automação:

- Mensagens normais de um canal viram **um ticket por canal por dia**, com cada mensagem como comentário.
- Cada comentário cita a mensagem anterior.
- Uma **thread** abre um ticket próprio, com o título da mensagem que a iniciou, e as respostas viram comentários dele.
- Imagens e arquivos viram anexos do ticket.

Ver [docs/automacoes.md](docs/automacoes.md).

## Pendências

- [ ] Adicionar logos de clientes e imagens do portfólio em `assets/img/`.
- [ ] Ligar o formulário de contato a um servidor ou serviço de e-mail (hoje é só prévia).
- [ ] Preencher CNPJ e razão social no rodapé e revisar as perguntas frequentes e os números da faixa de destaque.
- [ ] Informar links reais de redes sociais, termos de serviço e política de privacidade.
- [ ] Confirmar a lista de integrações oferecidas (Teams, WhatsApp Business, Zoho CRM, HubSpot, Pipedrive).
- [ ] Trocar os números fictícios do exemplo de fluxo de chamada pelos reais.

## Contato

Av. Aricanduva, São Paulo, SP · +55 11 96948-9493 · conectpbx@gmail.com
