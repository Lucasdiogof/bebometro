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
| 16 | Conta obrigatória (e-mail e senha), perfil, sincronização com leitura da nuvem, conflitos, dados antigos, sair e excluir conta | Implementado, **não executado, não compilado nem analisado**; migration `20261018000000` **pendente**, Edge Function `delete-account` **não publicada**, configuração de Auth/SMTP pendente (ver `docs/accounts-sync-checklist.md`) |
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

## Bloqueios conhecidos

- Sem acesso administrativo ao Supabase neste ambiente: novas migrations são preparadas e aplicadas pelo dono.
- Nada pode ser executado nesta rodada (sem `pub get`, analyze, testes ou builds).
