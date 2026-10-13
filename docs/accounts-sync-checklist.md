# Conta obrigatória, perfil e sincronização com recuperação: checklist

Rodada de 13/10/2026. Retome por aqui (e pelo `HANDOFF.md`) se o contexto for compactado.
Estados: **Pendente**, **Feito no código** (escrito, não compilado nem executado), **Bloqueado** (motivo).
Nada desta rodada foi compilado, analisado, testado nem executado. As APIs usadas foram conferidas no código-fonte
das versões instaladas (`supabase_flutter 2.18.3`, `gotrue 2.27.3`, `functions_client 2.7.1`, `get_it 8.3.0`, no cache
do pub), não em execução.

## Decisões

1. **Conta permanente obrigatória, só e-mail e senha.** Sem "continuar como visitante" e sem `signInAnonymously` (nem
   como fallback). Sessão anônima antiga vira o estado "dados antigos aguardando conversão/importação".
2. **Sessão local manda offline.** A sessão persistida pelo SDK continua valendo sem rede. Só `signedOut` com
   `signOutReason` diferente de `userInitiated` (o SDK emite isso quando o servidor recusa o refresh) vira "entre de
   novo", sem apagar nada. Erros de rede no refresh (`AuthRetryableFetchException`) são ignorados.
3. **Armazenamento por conta.** `LocalStore` com namespace `acct.<userId>.`; preferências do aparelho em `DeviceStore`
   (chaves sem prefixo). O formato antigo (sem prefixo) é o **espaço legado**, nunca apagado: é a cópia recuperável.
4. **Escopo `account` no get_it.** Repositórios, sync, comanda, tela bloqueada e links vivem nele. Fechar o escopo para a
   sincronização (o store recusa gravações depois de fechado, então respostas atrasadas não repovoam nada), encerra a
   Live Activity/notificação e descarta o toque pendente da tela bloqueada. A navegação volta à raiz.
5. **Dados antigos:** caso A (sessão anônima atual) = conversão oficial (`updateUser(email)` → confirmar → senha), mesmo
   user ID, espaço legado **adotado** (cópia; marcado só depois de gravado). Casos B/C = dados separados; a pessoa
   **importa** (cópia com IDs novos, vínculos remapeados, fotos copiadas e reenviadas, origem registrada), **mantém
   separados** ou **exporta**. Sem transferência de dono no servidor: o que a conta anônima já tinha enviado fica nela.
6. **Sincronização envio + leitura.** `revision` e `server_updated_at` mantidos por gatilho. Leitura por chave
   `(server_updated_at, id)`, 500 por página até página curta, janela de 2 min para trás (reler é idempotente), cursor
   salvo só depois da página gravada.
7. **Conflito por revisão do servidor.** O app envia `base_revision`; o gatilho recusa com `PT409` se a linha mudou. A
   versão local sai da fila e vai para "Alterações para resolver" (manter a deste aparelho ou usar a da nuvem; com
   exclusão remota: restaurar ou aceitar a exclusão). Leitura nunca sobrescreve linha local pendente.
8. **Dois rolês ativos:** o servidor recusa o segundo (`23505`); os dois ficam no aparelho e a pessoa escolhe qual
   encerrar. Nada é encerrado sozinho, bebidas não se misturam.
9. **Comanda:** documento único; conflito = escolher a versão inteira, com participantes e pagamentos das duas à vista.
10. **Exclusão de conta:** Edge Function `delete-account` (usuário do JWT, nunca do corpo; login de no máximo 10 min),
    progresso em `account_deletions`, ordem arquivos → linhas → identidade, nova chamada continua de onde parou.

## Etapas

| # | Etapa | Estado |
|---|-------|--------|
| 1 | Modelo de sessão (`AuthController`/`AccessState`) e controle central (`AccessGate`) | Feito no código |
| 2 | Telas: entrar, criar conta, conferir e-mail/reenviar, esqueci a senha, nova senha | Feito no código |
| 3 | Links de autenticação (PKCE, Android/iOS/web) | Feito no código; depende da configuração do painel (abaixo) |
| 4 | Dados antigos: dono, cópia, adoção (A), importação/exportação (B/C) | Feito no código |
| 5 | Armazenamento isolado por conta + escopo de dependências | Feito no código |
| 6 | Leitura/recuperação da nuvem (paginação, progresso, nova tentativa, fotos sob demanda) | Feito no código; depende da migration `20261018000000` |
| 7 | Conflitos e exclusões (revisão, tombstones, tela de resolução, dois rolês ativos) | Feito no código; depende da migration `20261018000000` |
| 8 | Minha conta | Feito no código |
| 9 | Sair da conta | Feito no código |
| 10 | Excluir conta (Edge Function + cliente) | Feito no código; **função não publicada** |
| 11 | Documentação (HANDOFF, progresso, READMEs) | Feito |

## Pendências externas (para o responsável)

> **Guia central: [`external-setup.md`](external-setup.md)** (estado real, comandos e campos exatos). Leitura pública da API em
> 13/10/2026: `delete-account` responde 404 (não publicada); `mailer_autoconfirm: true` (confirmação de e-mail desligada);
> `anonymous_users: true`; as colunas/tabelas da migration `20261018000000` existem. Nada foi aplicado daqui.
> Teste de sessão real da função (sem apagar): `scripts/check-delete-account.ps1` (modo `dry_run`).
> Atualização 13/10/2026: a função **foi publicada** (v1, `verify_jwt` ligado), `bebometro://auth-callback` está na lista de redirects
> e o *Manual linking* está ligado (itens 2, 3 e 5 abaixo). Templates e SMTP seguem pendentes; ver `external-setup.md`.

Este ambiente não tem acesso administrativo ao projeto `jiisoqkryhmtopaojyyu` (o Supabase acessível daqui é de outro
projeto e não foi tocado).

1. **Migration** `supabase/migrations/20261018000000_accounts_sync.sql`: **aplicada pelo responsável** (informado em
   13/10/2026; não verificada daqui). Sem ela, o app envia como antes e a leitura da nuvem fica desligada.
2. **Publicar a função:** `supabase functions deploy delete-account --project-ref jiisoqkryhmtopaojyyu` (com
   verificação de JWT ligada, o padrão). Sem ela, "Excluir conta" avisa que ainda não está disponível e não apaga nada.
3. **Auth > URL Configuration:** em *Redirect URLs*, incluir `bebometro://auth-callback` e a origem web usada (ex.:
   `http://localhost:PORTA` em desenvolvimento e o domínio de produção quando existir; nenhum domínio foi inventado).
4. **Auth > Providers > Email:** manter "Confirm email" ligado (o app trata os dois casos).
5. **Auth:** ligar **Manual linking**. A exigência está **confirmada** no guia oficial "Anonymous Sign-Ins → Convert an
   anonymous user to a permanent user" (vale também para `updateUser(email)`), conferido em 13/10/2026 (detalhes em
   `docs/auth-emails.md`). Sem isso a conversão mostra o erro e a pessoa pode criar conta nova e importar.
6. **E-mails em pt-BR/en/es:** colar os templates de `supabase/email-templates/` (ver `docs/auth-emails.md`). Só então os
   e-mails ficam traduzidos; as telas já estão.
6b. **SMTP próprio:** o SMTP padrão do Supabase só entrega para endereços da equipe do projeto e tem limite baixo por
   hora. Para usuários reais é preciso configurar SMTP (Auth > SMTP Settings). Nenhum e-mail foi enviado daqui.
7. **Opcional:** "Secure password change" (o app já pede o código por e-mail quando o servidor exigir).
8. **Login anônimo:** o app não cria mais sessões anônimas. Antes de desligar "Allow anonymous sign-ins", conferir no
   painel se isso afeta a renovação das sessões anônimas já existentes (não verificado daqui); elas são necessárias
   para a conversão do caso A.
