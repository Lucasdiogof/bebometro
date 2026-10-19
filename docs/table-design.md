# Rolê, pessoas e conta da mesa: desenho e decisões

Rodada de 19/10/2026. Fonte do pedido: plano "Bebômetro: rolê, pessoas e conta da mesa". Este documento registra a escolha de arquitetura **antes** da implementação e é
atualizado com o que foi feito de fato (ver `docs/qa-report.md` para as provas).

## Auditoria do que já existia
- **Comanda (`lib/tab`)**: um documento por rolê (`outing_tabs.data`, jsonb) com participantes (apelido), extras (comida, entrada, transporte...), vínculos
  com registros de bebida (`TabLink`, só o id), desconto, serviço, modos de divisão (igual, por item, valores), pagamentos e cálculo em centavos
  (`TabCalculator`, desconto → serviço sobre itens elegíveis → total, `allocate` determinístico). Já resolve a parte financeira.
- **Registro de bebida (`DrinkEntry`)**: uma unidade servida por registro; preço (`paidCents`, `billTotalCents` para garrafa compartilhada), volume
  (`personalMl`, `containerMl`), composição, origem de tela bloqueada. **Não tem noção de quem consumiu**: tudo era do dono.
- **O que faltava**: atribuição de consumo por pessoa, pedido por pessoa, comida por quem vai comer, visões por pessoa, estatística pessoal só do "Você",
  jogos sem ponto e leitor, e catálogo para achar e lançar.

## Decisão: adaptar o modelo existente (sem segunda comanda)
1. **Consumo** continua sendo o registro de bebida (uma unidade por registro). Ganha dois campos opcionais:
   - `consumerId` (texto): participante que consumiu. **`null` = o próprio dono ("Você")**. Isso preserva todos os registros antigos sem migrar dados
     e é exatamente a regra "consumo pessoal antigo conhecido é do Você".
   - `portions` (mapa `participante → ml`, valor nulo = desconhecido): só para garrafa/jarra compartilhada. A chave `me` representa o dono. Sem o campo,
     o registro compartilhado antigo continua com `personalMl` do dono e `peopleCount`.
2. **Quem divide o custo** continua sendo `TabLink.assign` (pesos por participante), independente de `portions`. Se não houver vínculo explícito, o rateio
   padrão é **derivado**: registro individual → o consumidor; garrafa → quem divide, em partes iguais. Trocar o rateio **não** altera volumes.
3. **Quem pagou ao bar** continua sendo `TabPayment` (independente dos dois anteriores).
4. **Fonte única de valor**: o preço vive no registro (bebida) ou no extra (comida/outros). A comanda **lê** esses valores. Para rolês novos a comanda inclui
   **automaticamente** todos os registros vivos do rolê (`TabDoc.autoLink`), então salvar um pedido já o coloca na conta, sem segunda escrita: não existe o
   estado "consumo confirmado sem conta correspondente". Rolês antigos (`autoLink = false`) mantêm o vínculo explícito de antes.
5. **Pessoas**: `Participant` ganha `left` (saiu) e ordem pela posição. Mesmo nome pode repetir; a identidade é o id; a inicial/cor diferencia.
   Pessoa que saiu continua nos pedidos antigos e não entra em "Todos" por padrão em itens novos. Adicionar alguém não redistribui nada.
6. **Comida** é um `TabExtra` (categoria comida) com `assign` explícito de quem vai comer (ids selecionados no momento; "Todos" grava a lista, nunca "todo
   mundo dinamicamente"). Quantidade, valor unitário ou total, serviço elegível por padrão.
7. **Quantidade** de bebida = N registros (um por unidade) com a distribuição por pessoa explícita; "preço total do pedido" é rateado em centavos
   (`allocate`). Agrupamento na lista é só apresentação.
8. **Estatísticas pessoais** filtram `isMine` (consumidor nulo, ou `me` nas porções). Mesa e Você são visões diferentes; orçamento antigo continua
   sendo de bebidas do "Você".

## Sincronização, compatibilidade e migração
- **Servidor (migration aditiva `20261022000000`)**: `drink_entries.consumer_id text`, `drink_entries.portions jsonb` (validado como objeto) e um gatilho em
  `outing_tabs` que **recusa atualização com `schema_version` menor** que a já gravada (cliente antigo não sobrescreve a comanda nova). A pertença do
  participante ao rolê não vira chave estrangeira: participantes vivem no documento da comanda (mesmo dono por RLS e mesmo `outing_id` como chave), e o app
  trata `consumer_id` desconhecido como "não atribuído" (nunca como Você).
- **Cliente**: enquanto o servidor não tem as colunas, um registro **com atribuição** não é enviado em forma degradada (outro aparelho leria como bebida do
  dono): fica pendente com aviso. Registro sem atribuição segue o caminho de antes.
- **Cliente antigo** continua lendo e editando preço sem apagar atribuições (o upsert só envia as colunas que conhece); a comanda nova v2 é protegida pelo gatilho.
- **Migração local**: não há reescrita de dados. Registros antigos (consumidor nulo) = "Você"; comandas antigas mantêm `autoLink = false`, modo e pesos;
  participantes financeiros antigos não viram consumidores. Idempotência: a leitura é tolerante (campos novos ausentes = comportamento antigo).
- **Exclusão de conta**: sem tabela nova; as colunas novas saem junto com as linhas de `drink_entries` e `outing_tabs` já apagadas pela função.

## Fora de escopo (confirmado)
Pix/reembolso entre pessoas, agenda de amigos, rede social, convites, ficha nutricional, conta obrigatória para convidados.

## Implementado em 19/10/2026 (resumo; provas em `docs/qa-report.md`)
- **Domínio:** atribuição de consumo, rateio por pedido, comida, serviço e pagamentos (`tab_calc.dart`, testes `table_calc_test.dart`, cenários A-E do plano).
- **Interface:** pessoas no início e durante o rolê, abas Pedidos / Por pessoa / Conta, novo pedido por pessoa (`lib/table/presentation`).
- **Sincronização/migração:** migration `20261022000000_table_attribution.sql`, envio sem forma degradada, exportação, estatística pessoal só do "Você";
  fixture de dados antigos lida, salva e relida sem mudar totais, IDs nem atribuição (`test/migration_fixture_test.dart`).
- **Tela bloqueada:** o atalho só repete pedido individual do "Você"; se o registro virar de outra pessoa/garrafa compartilhada antes do
  processamento, o comando fica pendente (`PendingReason.notPersonal`), nunca atribuído ao dono.
- **Resenha:** sem pontos (opção, placar, contadores removidos; partidas antigas abrem e ignoram a pontuação), leitor em destaque separado de quem
  responde, "Passar a vez", "Trocar leitor", rotação persistida, importação das pessoas do rolê por escolha (`test/game_session_test.dart`).
- **Catálogo:** ver `docs/catalog-coverage.md` (170 itens, busca chop/chopp/chope, atalhos genéricos).
