# Bebômetro: relatório de QA (rodada de 16/10/2026)

Checkpoint para outra sessão continuar. Sem senhas, tokens ou dados sensíveis.

## Ambiente
- Commit de partida: `2b46926`; depois `fixSignUpNoteAndCatalogBadgeWrap` (Wrap do selo de origem no catálogo, texto do cadastro sem "link de confirmação"). `main` = `origin/main`.
- Emulador Android 17 (API 37) `emulator-5554`, app `com.lucksrei.bebometro` instalado. Idioma do aparelho: inglês.
- Conta de QA em uso: "QA Bebometro A" (domínio `example.com`). Segunda conta de QA: **ainda não criada**.
- Projeto Supabase do Bebômetro (`jiisoqkryhmtopaojyyu`) **não é acessível** pelas ferramentas desta máquina (só La Pelve e Aura); verificação do servidor é feita pelo app.

## Resultados observados em execução
| Cenário | Resultado | Evidência |
|---|---|---|
| `flutter analyze` | Sem erros nem warnings; 10 infos de estilo antigas (`prefer_initializing_formals`, `use_build_context_synchronously` em `tracking_links.dart`) | saída do analyze |
| `flutter test` | 34 testes passaram (propagação de preço, origem da tela bloqueada, store local, comanda/serviço/centavos) | saída do test |
| Garrafa compartilhada (400 ml + 200 ml, R$ 25) | Aprovado (sessão anterior) | relato da sessão anterior |
| Propagação de preço (BEB-001) | Aprovado: 4 chopes R$ 15 + parcela R$ 10 = R$ 70; Brahma intacta | sessão anterior |
| Persistência offline | Aprovado: 6 bebidas, R$ 85, envio pendente após matar o app sem rede | sessão anterior |
| Reconexão e sincronização | **Aprovado**: rede do emulador confirmada (ping 0% perda, Wi-Fi validado). Status "Synced", última sincronização 00:43, 6 registros locais, fila vazia; "Sync now" respondeu "Everything is synced" e manteve 6 registros | UI do aparelho |

## Sobre `_probeRevisions`
Por leitura (`lib/core/sync/sync_cubit.dart`): só trata falta de coluna; erro de rede é relançado e cai no tratamento do `_run` com backoff (30 s, até 5 min). Depois da reconexão o app recuperou sozinho, então o log vermelho era do período offline. **Não há defeito confirmado.** Não foi medido o tempo até o retry automático.

## Limitações
- Não foi possível conferir as linhas no servidor (sem acesso ao projeto); "sem duplicação" está confirmado só pela contagem local (6) após reconectar e sincronizar.

## Não executado ainda (próximo passo)
B (duas contas, duas instalações, conflitos, exclusão/restauração), C (Desfazer, água, cortesia, encerrar/corrigir), D na interface (os cálculos têm teste de unidade), E (catálogo, receitas, OCR), F (compartilhar, exportar, fonte grande, pt/en/es), G (histórico, locais, jogos, simulador, notificação), H (excluir a conta de QA, por último), builds Android/web.
Próximo passo exato: criar a conta de QA B, repetir cadastro/login/senha errada/logout, e conferir isolamento entre A e B.
