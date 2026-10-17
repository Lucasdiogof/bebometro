# Bebômetro: progresso do desenvolvimento

Checklist da rodada longa. Estados: **Pendente**, **Em andamento**, **Implementado, ainda não executado**,
**Bloqueado** (com motivo). Nada aqui foi compilado, analisado, testado nem visto em tela.

Se o contexto for compactado, retome por este arquivo e pelo `HANDOFF.md`; não refaça o que já está
implementado.

| # | Bloco | Estado |
|---|-------|--------|
| 1a | Unidades dos ingredientes (ml, g, unidade, colher de chá/sopa, folha, gota, a gosto) | Implementado, ainda não executado |
| 1b | Mesa do rolê: mesa/lista, cenários, recipientes, animação ilustrativa, muitos registros, preferências, retrospectiva | Implementado, ainda não executado |
| 2 | Navegação principal (Início, Catálogo, Histórico, Resenha) + catálogo sem rolê ativo | Implementado, ainda não executado |
| 3 | Locais salvos (+ migration de `places`/`place_id`) | Implementado, ainda não executado; migration `20261014000000` aplicada pelo dono (tabela e colunas conferidas pela API) |
| 4 | Orçamento e gastos, edição rápida de preços ausentes | Implementado, ainda não executado (`budget_cents` na migration `20261014000000`, aplicada pelo dono) |
| 5 | Preços do próprio histórico | Implementado, ainda não executado |
| 6 | Estatísticas pessoais | Implementado, ainda não executado |
| 7 | Feedback detalhado e "rolê esquecido" | Implementado, ainda não executado (campos novos na migration `20261014000000`, aplicada pelo dono) |
| 8 | Resenha: jogos locais (Eu nunca, Quem é mais provável, Verdade ou desafio) | Implementado, ainda não executado |
| 9 | Copão e "virar o copo" | Copão: implementado, ainda não executado. "Virar o copo" refeito em 13/10/2026 como cerveja em tela cheia com acelerômetro (`sensors_plus`), arrasto na web/sem sensor; implementado, **não executado** (física, cores, sinal dos eixos no iOS e desempenho por observar em aparelho; ver HANDOFF) |
| 10 | Cartão compartilhável e exportação JSON/CSV | Implementado, ainda não executado (depende de `share_plus`, declarado no pubspec e ainda não resolvido; falta `pub get`) |
| 11 | Revisão dirigida e acabamento | Implementado (revisão por leitura; nada executado) |
| 17 | Internacionalização pt-BR/en/es (ARBs oficiais, seletor, formatos, campo de dinheiro, catálogo/receitas/cartas traduzidos, textos nativos, exportação estável, templates de e-mail) | Implementado em código, **não compilado, analisado nem executado**; templates de e-mail **não aplicados**; ver `docs/i18n-checklist.md` |
| 16 | Conta obrigatória (e-mail e senha), perfil, sincronização com leitura da nuvem, conflitos, sair e excluir conta (dados antigos/conversão removidos em 14/10) | Implementado, **não executado, não compilado nem analisado**; migration `20261018000000` **pendente**, Edge Function `delete-account` publicada (v1) e **comprovada na exclusão real** (17/10, após conceder permissões ao `service_role`), configuração de Auth/SMTP pendente (ver `docs/accounts-sync-checklist.md`) |
| 15 | Locais e mapa: seletor reutilizável (busca de estabelecimento/endereço na Geoapify, localização atual sob demanda, confirmação e ajuste no mapa, só apelido, locais salvos), correção do local de um rolê, detalhes com mapa, "Abrir no mapa", "Iniciar rolê aqui" | Implementado, **não executado, não compilado nem analisado**; pacotes novos sem `pub get`; chave `GEOAPIFY_KEY` **não configurada**; migration `20261017000000` **pendente** |
| 14 | Rolê na tela bloqueada (Live Activity/Dynamic Island no iOS 16.2+, notificação silenciosa no Android, só dentro do app na web; ativação e preferências, ocultar por rolê, ações que abrem o app e pedem confirmação) | Implementado em Dart, Swift e Kotlin, **não executado, não compilado nem analisado**; a extensão iOS foi adicionada ao `project.pbxproj` à mão (ver HANDOFF) |
| 13 | Comanda e divisão da conta (itens agrupados, extras, serviço/desconto, participantes, 3 modos de divisão, pagamentos, compartilhamento em texto) | Implementado, **não executado nem analisado**; migration `20261016000000` aplicada pelo responsável |
| 12 | Bebida por foto: rótulo, cardápio e cadastro do rolê (OCR local, revisão, "Bebidas deste rolê", fotos privadas) | Implementado, ainda não executado; migration `20261015000000` aplicada pelo responsável. Revisão de integração por leitura feita em 13/10/2026 (ver HANDOFF) |

**Regra central do bloco 12:** Bebidas, fotos e itens de cardápio criados neste fluxo pertencem exclusivamente ao rolê de origem.

## Migrations

| Arquivo | Estado |
|---------|--------|
| `20261012000000_initial_schema.sql` | Aplicada pelo dono |
| `20261013000000_recipes_and_unknown_volume.sql` | Aplicada pelo dono (campos confirmados pela API) |
| `20261014000000_places_budget_feedback_details.sql` | Aplicada pelo dono (13/10/2026); `places` e colunas novas de `outings` confirmadas pela API. Envio pelo Flutter ainda não observado |
| `20261015000000_outing_drinks_and_photos.sql` | Aplicada pelo responsável (tabelas `outing_drinks`/`outing_photos`, `drink_entries.abv_source`, bucket privado `outing-photos`). Não verificada daqui nem pela sincronização rodando no Flutter |
| `20261016000000_outing_tabs.sql` | Aplicada pelo responsável (tabela `outing_tabs`: a comanda inteira como um documento jsonb por rolê). Não verificada daqui nem pela sincronização rodando no Flutter |
| `20261017000000_places_map.sql` | Aplicada pelo responsável (colunas de mapa em `places` e `outings`). Não verificada daqui |
| `20261018000000_accounts_sync.sql` | Aplicada pelo responsável (informado em 13/10/2026; não verificada daqui). `revision`/`server_updated_at`/`base_revision` com gatilho, `deleted_at` em `outings` e `places`, tabela `account_deletions` |

## Revisão de integração do bloco 12 (13/10/2026)

Feita só por leitura do código; nada compilado, analisado nem executado. Corrigido: salvamento do rascunho ao sair rápido e
rascunho que renascia depois de concluído; reindexação dos itens do cardápio quando uma foto do rascunho sumiu; avisos de foto
ausente e de rolê encerrado; toque repetido (revisão do rótulo, "Continuar", abertura de formulário); foto descartada após
confirmação parcial; linhas de foto só com arquivo existente; conversão para JPEG; envio de fotos que não para na primeira falha,
remove o objeto de foto excluída durante o envio e entra na contagem de pendências; texto do preço do cardápio como sugestão.

Ainda pendente (exige execução): `flutter pub get`, analyze, testes, QA em aparelho Android/iOS (câmera, galeria, permissões
negadas, OCR em fotos reais, upload para o bucket, exclusão de foto enviada, retomada após fechar o app) e conferência no painel
do Supabase de que as linhas e os arquivos chegam. Heurísticas dos leitores de rótulo e cardápio não foram validadas.

## Configuração externa (13/10/2026)

Guia: [`external-setup.md`](external-setup.md). Sem acesso administrativo ao projeto do Bebômetro, nada foi aplicado no painel.
Feito: revisão e correção da função `delete-account` (esvaziamento completo do bucket do usuário), templates de e-mail revisados,
geoapify/redirects/SMTP/iOS documentados, `env.example.json`. Verificado pela API pública: função **não publicada** (404),
"Confirm email" desligado, login anônimo ligado, colunas/tabelas da migration `20261018000000` existentes. Pendente (responsável):
deploy da função, redirects, *Manual linking*, SMTP e confirmação de e-mail, templates, chave Geoapify, Team no Xcode.
Nada foi validado no app.
Segunda rodada (mesmo dia): ainda sem acesso administrativo (CLI sem o projeto; painel pedia login). Apurado: o projeto assina
tokens com ES256 (JWKS público); a documentação da plataforma diz que `verify_jwt` valida esses tokens, mas outra página oficial
traz aviso divergente; por isso a função ganhou o modo `dry_run` e o script `scripts/check-delete-account.ps1` para provar com
uma sessão real, sem apagar nada. Exclusão de conta **não** declarada funcional.
Terceira rodada (token pessoal fornecido): `delete-account` **publicada** (v1, ACTIVE, `verify_jwt` ligado, 401 sem sessão);
`uri_allow_list` agora tem `bebometro://auth-callback`; *Manual linking* **ligado**; templates **recusados pela plataforma** até haver
SMTP próprio; SMTP, Geoapify e Team iOS seguem pendentes. Nada validado no app.
Quarta rodada: corpo publicado de `delete-account` conferido pela API (contém `dry_run` e o esvaziamento do bucket); `dry_run` retorna
antes de qualquer escrita (revisão do código); sem sessão válida de usuário fornecida, o teste autenticado segue pendente. SMTP:
nenhuma credencial acessível (secret do Resend do site não é legível; ler outro projeto foi negado); `scripts/apply_auth_email.py`
aplica SMTP + templates com uma credencial fornecida. Geoapify: armazenamento permitido pela doc oficial desde que a atribuição
fique visível (adicionada ao detalhe do local); sem chave. Redirect web: aguarda hospedagem. iOS: sem Mac/Team.
Quinta rodada: chave Geoapify dedicada recebida; gravada em `env.json` (fora do Git); aceita pela API (autocomplete, reverse, places,
tile = 200). Mapa/busca não validados no Flutter.
Sexta rodada: SMTP do Resend (`smtp.resend.com:465`, remetente `Bebômetro <marketing@lucksrei.com>`) **configurado** e lido de volta;
4 templates + 4 assuntos trilíngues **aplicados** e lidos de volta; confirmação de e-mail **continua desligada** até um envio real ser
conferido. Entrega de e-mail não verificada.

Sétima rodada: e-mail de teste entregue na caixa de entrada; "Confirm email" **ligado**. **Dados antigos removidos (13/10/2026):** o app nunca foi usado por ninguém, então não existem registros antigos nem contas a converter. As telas "Dados antigos" (importar/manter/exportar, "criar conta com meus registros"), o aviso na entrada, o aviso em Minha conta e o convite ao abrir foram **retirados**. Uma sessão anônima que sobrar num aparelho de teste é encerrada localmente na abertura e a pessoa cai na tela normal de entrar/criar conta. O código de dados antigos (`legacy_data.dart`, conversão em `AuthController`) ficou sem tela e pode ser apagado depois; as telas de entrar/criar conta/recuperar não mudaram. Nada compilado.

**Confirmação de e-mail removida (13/10/2026):** o Supabase passou a confirmar contas automaticamente (`mailer_autoconfirm: true`, lido de volta) e o app não tem mais a tela "confira seu e-mail" (`CheckEmailPage` apagada). O cadastro entra direto. O e-mail de **recuperação de senha** continua existindo (SMTP e template aplicados). O template de confirmação segue aplicado, mas não é disparado. Nada compilado.

Rodada de 17/10 (token do Supabase fornecido): migrations `20261019`, `20261020` e `20261021` conferidas **já aplicadas** por consulta ao banco; template de recuperação por código aplicado e lido de volta; `flutter analyze` sem erros (10 avisos de estilo antigos) e 42 testes passando.

## Bloqueios conhecidos

- Sem acesso administrativo ao Supabase neste ambiente: novas migrations são preparadas e aplicadas pelo dono.
- Nada pode ser executado nesta rodada (sem `pub get`, analyze, testes ou builds).

## Rodada 14/10/2026 (recuperação, limpeza, catálogo v5)

| Item | Implementado | Configurado no servidor | Verificado pela API | Validado no app |
|---|---|---|---|---|
| Recuperação por código (pedir, verificar `recovery`, nova senha, reenvio, erros) | Sim; reforçado: nova senha só no estado de recuperação, sessão de recuperação velha é encerrada, logout limpa o marcador, falha de rede não abre a tela | **Não** (sem token administrativo): template `recovery.html` e `mailer_otp_length = 6` pendentes, `scripts/apply_recovery_code.py` pronto | Só `mailer_autoconfirm: true` (API pública) | Não |
| Remoção do fluxo cancelado (`legacy_data.dart`, conversão anônima, `emailPending`/`needsPassword`/`legacyAnonymous`, reenvio de confirmação, `openLegacy`/`isAccountKey`, 54 textos sem uso nos 3 idiomas) | Sim (`33543b0`) | n/a | n/a | Não (nada compilado) |
| Catálogo v5 (116 produtos, 55 marcas, 23 lacunas de embalagem preenchidas, `fieldSources`) | Sim (`b1cf676`) | n/a | `catalog_tool.py check`: 0 problemas | Não |

Conferido por leitura (não é teste): a recuperação e a limpeza. Executados só scripts de dados (`catalog_tool.py check/coverage/merge`,
conferência de referências/intervalos/traduções) e `flutter gen-l10n`.

## Rodada 14/10/2026 (bebidas prontas, procedência por campo, catálogo v6)

| Item | Implementado | Servidor | Verificado | Validado no app |
|---|---|---|---|---|
| Categoria `ready_to_drink` (enum, textos pt/en/es, filtros/busca por `values`, OCR por palavras do rótulo, tamanhos sugeridos 269/275/350, mesa = lata, estatísticas, exportação pelo código) | Sim (`4356c90`) | Migration `20261019000000` **pendente** (amplia os `check` de `custom_drinks` e `drink_entries`); até lá a sincronização mantém essas linhas pendentes com o aviso "aguarda atualização do servidor" | n/a | Não |
| "Sobre estes dados" no detalhe (fonte por campo, tipo, mercado, data de consulta, endereço que abre/copia, aviso de divergência sempre visível) | Sim (`4356c90`) | n/a | n/a | Não |
| Catálogo v6 (136 produtos, 20 RTDs) | Sim (`d678cd5`) | n/a | `catalog_tool.py check`: 0 problemas | Não |
