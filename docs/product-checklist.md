> Estado funcional completo, por funcionalidade: [`functional-audit.md`](functional-audit.md) (19/10/2026).

# Bebômetro: checklist de produto

Quatro estados são mantidos **separados**: **Código** (implementado em código), **Externo** (configurado fora do
repositório), **Execução** (verificado rodando) e a situação (**Parcial**, **Pendente**, **Bloqueado**).
Não há percentual de conclusão. Em 16 e 17/10/2026 houve uma rodada de QA com execução real (emulador Android, navegador
web, `analyze`, 42 testes, builds Android release e web): o que foi observado está em [`qa-report.md`](qa-report.md). A coluna
**Execução** abaixo só diz "Sim" onde esse relatório tem evidência; o resto continua "Não".

Fora de escopo: leitura de código de barras e Pix/cobrança bancária. Monitoramento de erros e ambientes separados ficam
para as últimas etapas e não foram começados.

## Funcionalidades

| Item | Código | Externo | Execução | Situação |
|------|--------|---------|----------|----------|
| Rolê: iniciar, editar, encerrar, feedback, orçamento, preços ausentes | Sim | n/a | Não | Pendente validar |
| Catálogo (v6: 136 produtos, 20 bebidas prontas; sem ampliação nesta rodada), "Sobre estes dados" por campo (procedência por campo: implementada; 55 produtos com `fieldSources`), filtros, favoritos, recentes, "Mais uma", água, desfazer | Sim | Migration `20261019000000` **aplicada** (conferido por consulta ao banco em 17/10: o `check` de categoria de `custom_drinks` e `drink_entries` inclui `ready_to_drink`) | Não | Pendente validar |
| Pipeline de atualização do catálogo (`tools/catalog_sync`: coletar → comparar → proposta → `catalog_tool.py merge`) | Sim (exercitado por script: `selftest`, `check`, `ids HEAD`) | n/a | Não (Flutter) | Parcial: um coletor (HEINEKEN Brasil); fontes adicionais são melhoria futura e não bloqueiam o app |
| Flutter: analyze, testes e builds | n/a | n/a | Sim (analyze sem erros, 42 testes, APK release e web release gerados e executados; ver `qa-report.md`) | iOS não compilado |
| Receitas de referência e próprias, composição, avisos de dado incompleto | Sim | n/a | Não | Pendente validar |
| Bebidas por foto (rótulo/cardápio), itens só do rolê, rascunhos | Sim | Migration `20261015000000` aplicada pelo dono | Não | Heurísticas de OCR não validadas |
| Locais salvos e mapa (Geoapify) | Sim | Chave `GEOAPIFY_KEY` **não configurada**; migration `20261017000000` aplicada | Não | Parcial (depende da chave) |
| Comanda e divisão (equal/item/personalizado, pagamentos manuais) | Sim | Migration `20261016000000` aplicada | Não | Sem testes de unidade do cálculo |
| Histórico, estatísticas, exportação, cartão compartilhável | Sim | n/a | Não | Pendente validar |
| Mesa ilustrada | Sim | n/a | Não | Pendente validar |
| Simulador de cerveja em tela cheia (sensores) | Sim | n/a | Não | Eixos no iOS e desempenho por observar |
| Jogos offline (3 jogos, 134 cartas, Leve/+18, cartas próprias) | Sim | n/a | Não | Pendente validar |
| Rolê na tela bloqueada (Live Activity, Dynamic Island, notificação Android) | Sim (Dart, Swift, Kotlin) | Assinatura (Team) no Xcode **pendente** | Não | `project.pbxproj` editado à mão |
| Internacionalização pt-BR/en/es | Sim | E-mails do Supabase **não aplicados** | Não | Ver `docs/i18n-checklist.md` |

## Visual

| Item | Situação |
|------|----------|
| Design system e telas | Escritos; **nenhuma tela foi renderizada** |
| Textos longos em en/es (botões, chips, rótulos) | Não verificado em tela; en/es costumam ser mais longos que pt |
| Fonte grande, teclado aberto, layout largo na web | Pendente |
| Capturas de tela | Não incluídas (sem execução) |

## Conta e dados

| Item | Código | Externo | Execução |
|------|--------|---------|----------|
| Conta obrigatória (e-mail e senha), cadastro entra direto, perfil | Sim | SMTP aplicado; "Confirm email" desligado de propósito (lido pela API pública em 14/10) | Não |
| Recuperação de senha por código de 6 dígitos | Sim (`verifyOTP` tipo `recovery`) | Template `recovery.html` (só `{{ .Token }}`, sem link) e `mailer_otp_length = 6` **aplicados e lidos de volta em 17/10** com `scripts/apply_recovery_code.py` (o resto da configuração de Auth não mudou). Falta pedir um código com conta própria | Não |
| Sincronização com leitura da nuvem, conflitos, exclusões | Sim | Migration `20261018000000` aplicada pelo dono | Não |
| Excluir conta | Sim | Função `delete-account` **publicada** e **comprovada** em 17/10 (conta de QA apagada: 0 linhas, 0 arquivos, sem usuário, `done`). Exigiu conceder `SELECT/INSERT/UPDATE/DELETE` ao `service_role` nas tabelas do app (aplicado à mão; migration ainda não versionada) | Sim (servidor); pela interface só a falha da 1ª tentativa |
| Persistência local por conta | Sim | n/a | Não |

## Banco e migrations

Todas até `20261018000000_accounts_sync.sql` foram **aplicadas pelo dono** (não verificado daqui). `20261019000000_ready_to_drink_category.sql`, `20261020000000_drink_entry_origin.sql` (colunas `entry_origin`, `origin_command_id`, `origin_tapped_at`) e `20261021000000_service_role_table_grants.sql` (grants do `service_role`) **já estão no banco** (conferido por consulta em 17/10). Detalhes: `docs/development-progress.md`.

## Configurações externas pendentes

Passo a passo e estado real (implementado / configurado / verificado pela API / validado no app): [`external-setup.md`](external-setup.md).
Geoapify: chave dedicada configurada em `env.json` local (verificada por HTTP); mapa e busca ainda **não validados no app**.

1. ~~Template de recuperação por código~~ **aplicado em 17/10**. Falta só pedir um código para uma conta própria e concluir a troca de senha no app.
2. Versionar a migration com as permissões do `service_role` (já aplicada à mão no projeto do Bebômetro).
3. Templates de e-mail trilíngues (`supabase/email-templates/`, ver `docs/auth-emails.md`).
4. Chave Geoapify (`GEOAPIFY_KEY`) e `flutter pub get` dos pacotes novos.
5. Assinatura (Team) do app e da extensão no Xcode.

## Android, iOS e web

| Plataforma | Estado |
|------------|--------|
| Android | Notificação de acompanhamento e sensores escritos; não compilado |
| iOS | Live Activity (iOS 16.2+), `InfoPlist.strings` (en/es/pt-BR, idioma do sistema), extensão no projeto à mão; não compilado |
| Web | Sem OCR automático, sem sensores (arrasto), acompanhamento só dentro do app; não executado |

## Validação (tudo pendente)

`flutter pub get`, `flutter analyze` (esperar erros de compilação), testes (inexistentes para comanda, parser, formatação
e i18n), QA em aparelho Android/iOS e navegador nos três idiomas, conferência da sincronização no painel, e-mails de
autenticação nos três idiomas com conta própria.

## Preparação para as lojas

Não iniciada além do que já existe: ícones/branding presentes; faltam textos de loja em en/es, política de privacidade
publicada, capturas reais, assinatura, descrições de permissão revisadas e revisão de classificação etária (conteúdo
sobre bebidas alcoólicas e modo +18 dos jogos).

## Migrations aplicadas pelo responsável (16/10/2026)
- `20261019000000_ready_to_drink_category.sql` e `20261020000000_drink_entry_origin.sql`: **aplicadas pelo responsável** no SQL Editor (informado em 16/10/2026; não lidas de volta daqui). Sincronização de bebidas prontas e da origem dos registros da tela bloqueada ainda não observada no app.

- `20261021000000_service_role_table_grants.sql`: **versionada no repositório em 17/10/2026**. **Estado do banco:** as mesmas permissões
  (`SELECT/INSERT/UPDATE/DELETE` ao `service_role` nas 8 tabelas que a função toca) foram aplicadas **à mão** no SQL Editor do projeto
  `jiisoqkryhmtopaojyyu` pelo responsável (informado: "Success"; efeito comprovado pela exclusão da conta de QA B). **Histórico de
  migrations:** a execução manual não registra a migration em `supabase_migrations.schema_migrations`; este projeto aplica as migrations à
  mão, então o histórico do painel pode não listar nenhuma delas. Rodar o arquivo de novo é seguro (idempotente). Para conferir o estado real:
  `supabase/queries/diagnose_delete_account.sql` (somente leitura).

## Rodada 19/10/2026 (continuação)

| Item | Implementado | Testes automatizados | Em aparelho/UI |
|---|---|---|---|
| Pessoas em garrafa já registrada | Sim | `bottle_people_test`, `bottle_people_cubit_test` | Não visto |
| Desfazer exclusão de rolê (10 s) | Sim | `outing_undo_delete_test` | Não visto; sincronização entre dois aparelhos não exercitada |
| Links de termos e privacidade | **Não** (sem página do Bebômetro; dependência externa, ver `functional-audit.md`) | — | — |
| Descrição de conflitos de locais/bebidas/receitas | Sim | `conflict_describer_test` | Tela não vista |

## Itens BEB-001 a BEB-007 (estado em 16/10/2026)

Atualizado após a rodada de QA de 16-19/10 (`docs/qa-report.md`). "Validado em execução" só onde há evidência no relatório; BEB-002, BEB-004 e BEB-006 seguem sem validação própria (BEB-004 só existe no iPhone).

| Item | Implementado | Conferido por leitura | Validado em execução | Pendente de aparelho |
|---|---|---|---|---|
| BEB-001 propagação de preço para bebidas iguais | Sim (`bb65e02`) | Sim | **Sim, Android (emulador), 16-17/10:** oferta "2 sem preço e 0 com outro preço", aplicar só aos sem preço, "só este" respeitado, bebida diferente intacta; regra coberta também por `test/price_propagation_test.dart` | Web e iPhone |
| BEB-002 remoção do CTA do Copão | Sim (`623da6a`) | Sim | Não | Conferir o card Copão |
| BEB-003 destaque para Encerrar rolê | Sim (`623da6a`) | Sim | **Parcial, Android:** botão "Encerrar rolê" na Home e ícone de bandeira na barra do rolê vistos em captura; encerrar e resumo exercitados na rodada de QA | Conferir o botão de largura total no fim do rolê |
| BEB-004 Mais uma na tela bloqueada | Sim (`bf29c90`, `c932b0b`, `bbb7698`, `cb4fe29`, revisão de sincronização em 16/10) | Sim | Não | iOS 17+: toque, fila, pendentes, origem (roteiro em `lock-screen-one-tap.md`) |
| BEB-005 taxa de serviço 5/10/20% | Sim (`862e310`) | Sim | **Sim, Android:** 5/10/20% = R$ 5,25 / 10,50 / 21,00 sobre R$ 105, desligar recalcula; cálculo coberto por `test/tab_calc_test.dart` (inclui 12,34%) | iPhone |
| BEB-006 layout do Compartilhar | Sim (`7b986bb`) | Sim | Não | Tela estreita e fonte ampliada |
| BEB-007 falha no compartilhamento | Fragilidades corrigidas (`7b986bb`, `c932b0b`, âncora da folha em 16/10); **causa original não reproduzida** | Sim | **Parcial, Android:** o seletor do sistema abre e cancelar volta sem erro e sem cópia (resumo e exportação JSON) | Compartilhar de verdade no iPhone (e no iPad, se houver) |

## Checklist funcional: pedidos, pagantes e Bafômetro (25/10/2026)
Código = feito e coberto por teste; Execução = só onde há prova rodando (nada disto foi visto em aparelho).

| Item | Código | Execução |
|---|---|---|
| Formulário único (bebida, comida, outro) com nome livre, quantidade, preço (valor/cortesia/não sei), consumidores e pagantes | Sim | Teste de widget |
| Consumir e pagar independentes (nunca um altera o outro) | Sim | Teste de unidade e de widget |
| Heineken 600 (você + Ana, paga você): 1 pedido compartilhado, R$ 20 uma vez, Ana R$ 0 | Sim | Teste de cenário |
| Batata R$ 60, 3 consumidores, 2 pagantes: R$ 30 + R$ 30, terceiro R$ 0 | Sim | Teste |
| Valores digitados dos pagantes somam exato em centavos (inclusive por várias unidades) | Sim | Teste |
| Sem preço: pagantes guardados, valor pendente; cortesia = zero | Sim | Teste |
| Compartilhado não vira unidade inteira por pessoa ("Participou de N pedidos compartilhados") | Sim | Teste |
| Corrigir sem perder pagamentos; mostra saldo antes/depois | Sim | Teste de widget |
| Repetir/"Mais uma" mantém consumidores, pagantes, preço; id e origem novos | Sim | Teste |
| Tela bloqueada: só individual do dono; revisão com o mesmo id/horário do toque | Sim | Teste (builder); aparelho: Não |
| Dados antigos sem pagantes: custo segue quem consumiu | Sim | Teste |
| Técnicos (teor, ml, receita, álcool puro) fora de cadastro, edição, resumo, histórico, estatística, mesa, OCR, conflitos | Sim | Analyze + testes |
| Sincronização não degrada registro com pagantes (aguarda a migration) | Sim | Teste; servidor: Não (migration não aplicada) |
| Bafômetro: participantes do rolê, ~1 s de sopro, medidor n/(n+4), "Simulação", sem números | Sim | Teste de widget; microfone real: Não |
| pt-BR / en / es (1.540 chaves iguais nos três) | Sim | gen-l10n + testes em 3 idiomas |
