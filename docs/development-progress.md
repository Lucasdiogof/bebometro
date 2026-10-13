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
| 9 | Copão e "virar o copo" | Implementado, ainda não executado (inclinação por sensor: não implementada, exigiria o pacote `sensors_plus`) |
| 10 | Cartão compartilhável e exportação JSON/CSV | Implementado, ainda não executado (depende de `share_plus`, declarado no pubspec e ainda não resolvido; falta `pub get`) |
| 11 | Revisão dirigida e acabamento | Implementado (revisão por leitura; nada executado) |

## Migrations

| Arquivo | Estado |
|---------|--------|
| `20261012000000_initial_schema.sql` | Aplicada pelo dono |
| `20261013000000_recipes_and_unknown_volume.sql` | Aplicada pelo dono (campos confirmados pela API) |
| `20261014000000_places_budget_feedback_details.sql` | Aplicada pelo dono (13/10/2026); `places` e colunas novas de `outings` confirmadas pela API. Envio pelo Flutter ainda não observado |

## Bloqueios conhecidos

- Sem acesso administrativo ao Supabase neste ambiente: novas migrations são preparadas e aplicadas pelo dono.
- Nada pode ser executado nesta rodada (sem `pub get`, analyze, testes ou builds).
