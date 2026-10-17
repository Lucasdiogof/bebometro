# Bebômetro Web (Cloudflare Workers + Static Assets)

Padrão: `Lucasdiogof/lucksrei-web-template`. O Bebômetro não tinha Worker nem deploy web antes deste documento.

- Worker proposto: `bebometro` (`wrangler.jsonc`, ainda **não publicado**; nenhum Worker foi criado na Cloudflare).
- Domínio proposto: `bebometro.lucksrei.com`. A rota está comentada em `wrangler.jsonc` até o dono autorizar DNS.
- Build local: `bash scripts/build-web.sh` (usa `env.json`, gitignored). Deploy manual: `bash scripts/deploy-web.sh`.
- Smoke test: `bash scripts/smoke-test.sh <url> /conta`.
- Headers e cache: `web/_headers`. `scripts/check-bundle-secrets.sh` falha o build se houver `service_role`/`sb_secret_`.
- Rollback: `npx wrangler rollback <version-id> --name bebometro`.
- Sem workflow de deploy automático ainda: não foram criados secrets no GitHub. Para ativar, copiar
  `templates/deploy-web.yml` do template e cadastrar os 4 secrets (decisão do dono).

## Validado (2026-10-17)
`flutter build web --release --dart-define-from-file=env.json` (Flutter 3.47.4) compila. Bundle sem chaves privilegiadas.
`wrangler dev --local`: `/`, `/conta`, manifest e scripts respondem 200 (rota profunda cai no `index.html`); headers de segurança presentes.
**Não validado**: execução do app no navegador (login, rolê, mapa), idiomas, teclado, nem em aparelho. O HANDOFF do app já registra que ele nunca foi executado.

## Diferenças web x mobile (já tratadas no código, conferir ao testar)
- Leitura de rótulo por câmera/ML Kit: sem suporte na web (fábricas `*_web.dart`/`*_factory.dart` existem).
- Localização: depende da permissão do navegador (HTTPS é obrigatório; o domínio da Cloudflare atende).
- "Virar o copo": sem acelerômetro confiável, usa arrasto.
- Rolê na tela bloqueada: na web só dentro do app (sem Live Activity).
- Compartilhar: `share_plus` usa Web Share quando o navegador permite; senão copia o texto.

## Autenticação
Recuperação por código de 6 dígitos (`resetPasswordForEmail` sem `redirectTo` + `verifyOTP(recovery)`), inalterada.
`docs/external-setup.md` já registra que o *Redirect URL* web do Supabase só deve ser cadastrado quando houver fluxo por link
na web (ex.: confirmação de cadastro): nada foi alterado no Supabase. Se for ativado, cadastrar apenas
`https://bebometro.lucksrei.com/` para este projeto.
Pendência externa: confirmar SMTP custom no projeto Supabase (embutido = 2 e-mails/hora).

## Conteúdo
App sobre bebidas alcoólicas: definir classificação etária e aviso de 18+ antes de divulgar a URL pública. Os cálculos
mostram álcool puro declarado, nunca alcoolemia nem recomendação médica.


## QA local no navegador (2026-10-17, build servido por wrangler dev em localhost)
Carregamento, tela inicial, ausência de erros de console, mobile (375x812) e desktop verificados. Sem chaves privilegiadas no bundle.
**Não testado por mim**: login/logout/persistência, recuperação por código, isolamento entre usuários (exigem conta de QA e caixa de e-mail de QA, que não tenho; digitar senhas fora de localhost também é vedado).
Deploy de teste em workers.dev: **bloqueado** (login do wrangler expirou e não há `CLOUDFLARE_API_TOKEN`). Workflow `deploy-web.yml` pronto, desativado até existir o token e a variável `AUTO_DEPLOY=true`.
