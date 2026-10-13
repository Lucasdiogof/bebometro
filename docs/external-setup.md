# Configuração externa do Bebômetro (guia central)

Projeto Supabase: `jiisoqkryhmtopaojyyu`. Este é o **único** guia de configuração externa; os outros documentos
(`accounts-sync-checklist.md`, `auth-emails.md`, `product-checklist.md`, HANDOFF, READMEs) apontam para cá.

Rodada de 13/10/2026 (reconferida numa segunda rodada no mesmo dia: a CLI continua sem o projeto na lista, o Claude in Chrome não
estava conectado e o painel no navegador embutido pedia login — não entrei com credenciais). O ambiente de desenvolvimento **não tem acesso administrativo** ao projeto do Bebômetro (a CLI do
Supabase daqui enxerga só outros projetos; o conector Supabase é de outro app e não foi tocado). Por isso nada abaixo foi
aplicado por mim: o que existe é código/arquivos prontos, mais leituras públicas e sem efeito feitas pela API.

Legenda das colunas de estado: **Implementado** (código no repositório) · **Configurado** (aplicado no serviço externo) ·
**Verificado pela API** (lido de fora, sem login, sem criar nada) · **Validado no app** (visto funcionando no Flutter —
**nenhum item abaixo está**) · **Pendente**.

## Resumo

| Configuração | Implementado | Configurado | Verificado pela API (13/10/2026) | O que falta |
|---|---|---|---|---|
| Função `delete-account` | Sim (revisada, corrigida, com `dry_run` para teste) | **Não** | `POST /functions/v1/delete-account` sem sessão responde **404 NOT_FOUND**: não está publicada | Publicar e rodar o teste `dry_run` com sessão real (seção 1) |
| Redirects de Auth | Sim (app, manifest, Info.plist coerentes) | Não confirmado | Não há leitura pública da lista | Cadastrar as URLs (seção 2) |
| Conversão das sessões anônimas | Sim (`updateUser(email)`) | Não confirmado | `anonymous_users: true` (sessões antigas continuam válidas) | Ligar *Manual linking* (seção 3) |
| Confirmação de e-mail | Sim (o app trata os dois casos) | — | `mailer_autoconfirm: true` = **"Confirm email" está desligado** | Ligar quando o SMTP existir (seção 4) |
| SMTP | n/a | Não confirmado | Não legível | Configurar remetente autorizado (seção 4) |
| Templates PT-BR/EN/ES | Sim (4 arquivos revisados) | **Não** | Não legível | Colar no painel (seção 5) |
| Geoapify | Sim | **Não** (sem chave) | Sem chave, nada a verificar | Obter a chave (seção 6) |
| Assinatura iOS | Alvos coerentes | **Não** (sem Team) | n/a | Escolher o Team nos dois alvos (seção 7) |
| Migrations até `20261018000000` | Sim | Aplicadas pelo responsável | Colunas/tabelas existem (`revision`, `server_updated_at`, `deleted_at`, `account_deletions`, `outing_tabs`, `outing_photos`) | Nada |

## 1. Função `delete-account`

**Revisão (código em `supabase/functions/delete-account/index.ts`):**
- O usuário vem do JWT (`admin.auth.getUser(token)`), nunca do corpo. Sessão anônima é recusada (403).
- Exige login recente (até 10 min; o app pede a senha antes). Resposta `reauthentication_needed`.
- Ordem: arquivos do bucket privado `outing-photos/<uid>/…` → linhas (filhos antes dos pais) → identidade por último. Progresso em
  `account_deletions`; chamar de novo continua de onde parou. Sem service role no Flutter (a chave vem do ambiente da função).
- **Defeito corrigido:** a listagem de pastas do bucket pegava só as primeiras 1000 e ignorava arquivos soltos na raiz; quem
  tivesse mais de 1000 rolês com foto deixaria arquivos órfãos após excluir a conta. Agora repete até esvaziar (com guarda contra
  laço infinito).
- Limitação conhecida: se a identidade for apagada mas a resposta se perder, a nova tentativa chega com um token de usuário que não
  existe mais e a função responde 401; o app trata como "entre de novo". Não há como distinguir isso sem expor se o e-mail existe.

**`verify_jwt` com as chaves atuais:** a API pública (`/auth/v1/.well-known/jwks.json`) mostra que o projeto assina os tokens de
usuário com **uma chave assimétrica ES256** (JWKS com 1 chave EC P-256). Documentação oficial (conferida em 13/10/2026):
- *Authorization headers* (Edge Functions): a checagem da plataforma "valida JWTs HS256 legados e JWTs assinados com as novas chaves
  assimétricas"; o JWT da sessão vai em `Authorization` e a chave publicável em `apikey` — exatamente o que o `supabase_flutter`
  envia em `functions.invoke`. Funções chamadas por usuário devem manter `verify_jwt` ligado.
- A página *JWT Signing Keys* contém um aviso mais antigo de que funções com *Verify JWT* podem quebrar numa **rotação** de chaves
  e que o remédio é desligar a checagem e verificar no código. Há, portanto, texto oficial divergente; o que vale para o projeto é
  testar com uma sessão real (abaixo), não presumir.
- Dentro da função, `admin.auth.getUser(token)` valida o token no servidor de Auth, qualquer que seja o algoritmo — esta checagem
  independe do gateway e já existe.
Decisão: manter o padrão (`verify_jwt` ligado). **Não** desligar por tentativa. Se o teste com sessão real falhar com 401 do gateway
(`Invalid JWT`) mesmo com login válido, aí sim o caminho documentado é publicar com `--no-verify-jwt` (a função já autentica por
dentro com `getUser`) — decisão a tomar com esse resultado na mão.

**Um 401 sem sessão só prova que o acesso anônimo é recusado.** Para provar que **uma sessão válida chega** à função, a função aceita
`{"dry_run": true}`: depois de autenticar o chamador (e recusar sessão anônima) ela responde `{"ok":true,"dry_run":true,...}` **sem
apagar nada**. Rode com a **sua** conta (a senha é pedida na hora, só vai ao login do projeto e não é gravada):

```bash
powershell -File scripts/check-delete-account.ps1
```

Resultado esperado: `Function answered: {"ok":true,"dry_run":true,"reauthentication_needed":false}`. Um `HTTP 401` aqui, com login
válido, indica o problema do gateway acima. **Enquanto esse teste não for feito com sessão real, a exclusão de conta NÃO está
declarada funcional**, mesmo depois do deploy.

**Publicar** (quem tem acesso à organização do projeto; a CLI precisa estar logada nela):

```bash
supabase functions deploy delete-account --project-ref jiisoqkryhmtopaojyyu
```

Sem secrets extras: `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` são injetados pelo Supabase.
**Verificação sem efeito destrutivo** depois do deploy: (1) `POST` sem sessão deve deixar de dar 404 e passar a dar **401** (só prova
que o acesso anônimo é recusado); (2) o teste com sessão real descrito acima (`dry_run`).

```bash
curl -s -o /dev/null -w "%{http_code}\n" -X POST https://jiisoqkryhmtopaojyyu.supabase.co/functions/v1/delete-account
```

## 2. Redirects e links

O app usa `bebometro://auth-callback` (`Env.authRedirectUrl`, ajustável com `--dart-define=AUTH_REDIRECT_URL`).
Conferido por leitura: `AndroidManifest.xml` (intent-filter `bebometro`/`auth-callback`), `Info.plist` (esquema `bebometro`),
`injector.dart` (PKCE; só links cujo host é `auth-callback` são links de autenticação) e `AuthController` (evento de
recuperação abre a tela de nova senha, inclusive em partida a frio; link inválido/expirado vira aviso, sem expor a URL).
Na web o app usa a **origem da página** (`Uri.base.origin`).

Em **Auth → URL Configuration → Redirect URLs**, **acrescentar** (sem apagar as que já existem):

| Ambiente | URL |
|---|---|
| Android/iOS | `bebometro://auth-callback` |
| Web em desenvolvimento | `http://localhost:PORTA` (a porta do `flutter run -d chrome --web-port PORTA`; `http://localhost:PORTA/**` não é necessário, o app usa só a origem) |
| Web em produção | **indefinida**: o app web ainda não tem endereço publicado. Cadastrar a origem exata (`https://…`) quando existir. Não use o domínio de outro projeto. |

*Site URL*: pode continuar como está; não há página de destino do Bebômetro na web ainda.
A documentação oficial de Redirect URLs (conferida) manda usar URLs exatas em produção e `**` só em desenvolvimento.

## 3. Conversão das sessões anônimas antigas

O código (`AuthController.convertAnonymous` → `updateUser(email)` + senha depois da confirmação) é o fluxo documentado de
"Convert an anonymous user to a permanent user", que exige **Manual linking** (Auth → Sign In / Providers → *Allow manual
linking*) — também para o caso de e-mail. Conferido no código atual: o app não usa `linkIdentity`, só `updateUser`.
**Ligar *Manual linking*** e **manter *Allow anonymous sign-ins* ligado** enquanto houver sessões antigas (hoje a API mostra
`anonymous_users: true`). O app não cria mais sessões anônimas. Nenhuma conversão foi executada.

## 4. SMTP e confirmação de e-mail

Estado lido pela API: `mailer_autoconfirm: true`, ou seja, hoje **ninguém precisa confirmar o e-mail** e nenhum e-mail de
confirmação é enviado. O SMTP padrão do Supabase só entrega para endereços da equipe do projeto e tem limite baixo por hora, então
não serve para usuários reais. Nada foi enviado nesta rodada.

Campos a preencher em **Auth → SMTP Settings** (com um provedor e domínio **seus e já autorizados**):

- Remetente (*Sender email*) e nome (*Sender name* = `Bebômetro`): um endereço que o provedor autoriza para envio transacional.
  Não foi escolhido nenhum: não presumi o endereço do site nem de outro app.
- Host, porta (465 TLS implícito ou 587 STARTTLS) e usuário/senha **do provedor** (a credencial é do provedor, não do Supabase).
- Domínio do remetente verificado no provedor (SPF/DKIM) antes de ligar.
- Conferir o limite de envios por hora do provedor e o *rate limit* de e-mails em Auth → Rate Limits.

Depois de o SMTP funcionar, **ligar "Confirm email"** (Auth → Sign In / Providers → Email). O app já trata as duas situações.

## 5. Templates de e-mail (PT-BR, EN, ES)

Quatro arquivos em `supabase/email-templates/` (revisados nesta rodada: HTML simples e responsivo, marca Bebômetro, botão com
link de ação, código numérico como alternativa, sem links fictícios). Variáveis usadas, todas documentadas pelo Supabase:
`{{ .ConfirmationURL }}`, `{{ .Token }}`, `{{ .Data }}` (= `user_metadata`). O idioma vem de `user_metadata.language`
(`pt`, `en` ou `es`, gravado pelo app no cadastro/conversão e atualizado ao trocar o idioma); qualquer outro valor, ou conta
sem o campo, cai em **português**. O teste de idioma agora é protegido (`and .Data .Data.language (eq …)`) para não falhar
quando o campo não existe.

| Tipo no painel (Auth → Email Templates) | Arquivo | Assunto (colar no campo *Subject*) |
|---|---|---|
| Confirm signup | `confirmation.html` | `Confirme seu e-mail · Confirm your email · Confirma tu correo` |
| Reset password | `recovery.html` | `Redefinir senha · Reset password · Restablecer contraseña` |
| Change email address | `email_change.html` | `Confirme o novo e-mail · Confirm your new email · Confirma tu nuevo correo` |
| Reauthentication | `reauthentication.html` | `Código de verificação · Verification code · Código de verificación` |

Magic link e Invite não são usados. **Limites que não dá para contornar:** só existe um template (e um assunto) por tipo; o idioma
é o **gravado na conta**, não o do aparelho de quem pede a recuperação de senha; quem nunca gravou o idioma recebe português.
Depois de colar, ler a configuração de volta no painel e conferir os *Auth Logs*. Nenhum e-mail de teste foi enviado.

## 6. Geoapify (busca de lugares e mapa)

Sem a chave (`GEOAPIFY_KEY`), busca e mapa ficam desligados e o resto funciona. **Não há chave específica do Bebômetro
disponível** e não criei conta nem aceitei termos. Único passo seu: criar um projeto no plano gratuito em geoapify.com, gerar
**uma chave só para o Bebômetro** e passá-la no build (`env.example.json` → `env.json`, que está no `.gitignore`):

```bash
flutter run --dart-define-from-file=env.json
```

Documentação oficial (conferida em 13/10/2026): plano gratuito com 3.000 créditos/dia e 5 requisições/s, uso comercial permitido
dentro da cota; é **obrigatório** exibir "Powered by Geoapify" (link) e a atribuição do OpenStreetMap — o app já mostra ambos
(`MapAttribution`). Os termos pedem OSM em todos os usos.

- **Restrições da chave:** a documentação consultada não descreve restrição por domínio/IP/app, então não afirmo que existam. Em app
  nativo a chave fica no binário (como a publicável do Supabase). Use uma chave dedicada, acompanhe o consumo no painel e troque a
  chave se houver abuso. Não consegui confirmar restrição por origem para a web.
- **Armazenar resultados:** a documentação da **Places API** diz textualmente "Cache/store results with no limits". A documentação
  de **geocodificação (autocomplete e reverse)** e os termos **não dizem nada** sobre armazenar. **Dúvida delimitada:** o app grava,
  para um local que a pessoa **confirmou** (e pode editar), coordenadas, endereço, cidade/UF, nome e identificador do provedor.
  Esses campos vêm da busca de lugares próximos (permitido, documentado) ou da busca por texto/ponto no mapa (não documentado).
  O apelido e qualquer endereço digitado à mão são da pessoa e não dependem disso. Pergunta única a fazer ao suporte da Geoapify
  antes de publicar: "resultados de autocomplete e reverse geocoding podem ser armazenados no plano gratuito?". Enquanto isso, nada
  foi alterado no comportamento de gravação (e o comentário de código que afirmava que os termos permitiam foi corrigido).
- Chamadas só sob demanda (digitar com mínimo de 3 letras, tocar em "perto de mim"/no mapa); nenhuma chamada foi feita nesta
  rodada, pois não há chave.

## 7. Assinatura iOS

O projeto tem o app (`com.lucksrei.bebometro`) e a extensão `BebometroLiveActivity`
(`com.lucksrei.bebometro.BebometroLiveActivity`, incorporada em *Embed Foundation Extensions*), ambos com assinatura automática e
**sem `DEVELOPMENT_TEAM`** em nenhum alvo. Não inventei Team ID. No Xcode (Mac): abrir `ios/Runner.xcworkspace` → alvos **Runner**
e **BebometroLiveActivity** → *Signing & Capabilities* → escolher o **mesmo Team** nos dois (e em RunnerTests se for rodar testes).
Live Activities usam `NSSupportsLiveActivities` já presente no Info.plist do app. Nada foi compilado nem assinado.

## 8. Rodar o app

`env.example.json` traz só o que **não** tem padrão no código: `GEOAPIFY_KEY`. Copie para `env.json` (ignorado pelo Git) e rode
`flutter pub get` e `flutter run --dart-define-from-file=env.json`. `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` e
`AUTH_REDIRECT_URL` têm padrão de desenvolvimento em `lib/core/config/env.dart`; **não os deixe vazios** no arquivo (um valor vazio
substitui o padrão) — inclua-os só para apontar para outro projeto. Nunca coloque service role nem senha de SMTP nesse arquivo.
