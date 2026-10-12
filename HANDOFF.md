# Bebômetro: HANDOFF

## Arquitetura
Flutter, Cubit/BLoC, get_it. Organização por funcionalidade, com `domain` / `data` / `presentation`:

- `core/`: `config` (Supabase URL e publishable key), `di`, `theme`, `utils/formatters.dart`
  (reais, ml, parsing pt-BR), `data/local_store.dart`, `sync/sync_cubit.dart`, `widgets`.
- `outings/`: rolê, resumo (`OutingSummary`), repositório, telas iniciar / rolê / resumo.
- `drinks/`: catálogo embutido (`CatalogSource`), `DrinkEntry` (cópia dos dados da bebida),
  `DrinkDraft` (regras do formulário: divisão, pagamento, horários), repositório, telas.
- `history/`, `home/` (inclui o prompt de feedback), `settings/`.

Persistência: `LocalStore` (SharedPreferences, funciona em Android/iOS/web) grava a linha **e** a
marca de "pendente de envio" (com versão) no mesmo passo. `SyncCubit` esvazia essa fila.

## Sincronização (como funciona)
- Uma execução por vez; chamadas simultâneas compartilham a execução em andamento.
- Autentica com `signInAnonymously` quando não há sessão; registros feitos antes disso ficam
  pendentes e vão com o `owner_id` do usuário anônimo quando a conexão existir.
- Ordem: `outings` (encerrados antes do ativo) → `custom_drinks` → `drink_entries`. Upsert por UUID
  do cliente (repetir não duplica). Exclusão é soft (`deleted_at`) e sincroniza igual.
- A marca de pendência só sai após confirmação do servidor **e** se a linha não foi editada de novo
  (comparação de versão), então uma resposta antiga nunca esconde uma edição mais nova.
- "Sincronizado" só aparece com a fila vazia. Falhas: backoff (30 s a 5 min); `localOnly` quando o
  login anônimo é recusado (nova tentativa a cada 5 min ou por "Sincronizar agora").
- Linha recusada pelo servidor (ex.: conflito de rolê ativo, código 23505) não apaga nada: fica
  pendente, as demais seguem, e as bebidas dela esperam o rolê.
- Não há leitura da nuvem (pull): cada instalação é um usuário anônimo próprio.

## Design system (core/theme + core/widgets)
- Tokens em `app_tokens.dart`: `AppSpace`, `AppRadius`, `AppText` (headline > title > subtitle > body >
  caption > overline), `kTouchTarget`. Cores em `app_colors.dart` (carvão, âmbar, branco quente; paleta
  provisória, logo ainda indefinida: `BeerGlass` é só um marcador).
- Componentes em `core/widgets/common.dart`: `SurfaceCard` (highlight/selected), `StatTile`,
  `SectionTitle`, `InfoPill`, `BottomActionBar` (SafeArea + sobe com o teclado), `showToast`,
  `SyncBadge` (só ícone, discreto), `reduceMotion(context)`. Novas telas devem usar esses blocos.

## Funcionalidades
- **Home:** "Bora de rolê?" + Iniciar rolê; com rolê ativo, card com local/tempo/bebidas/gasto + Continuar;
  último rolê; resumo do mês (dados reais); atalhos para histórico e configurações; sync só como ícone.
- **Iniciar rolê:** tipos em grade com ícone, apelido OU endereço (erro no campo), horário editável,
  botão fixo acima do teclado.
- **Tela do rolê:** cabeçalho compacto, resumo, lista de registros (menu Corrigir/Excluir), barra inferior
  com "Mais uma · <bebida tamanho>" (só se houver bebida alcoólica elegível), Adicionar bebida e Água;
  "Encerrar rolê" no menu e como ação discreta no fim da lista; desfazer em snackbar.
- **Catálogo:** busca em destaque, chips de categoria, atalhos Recentes/Favoritas, lista geral, vazio com
  "Cadastrar bebida" (já abre com o termo buscado e volta direto ao registro da bebida criada).
- **Formulário da bebida:** tamanhos rápidos + volume livre, teor opcional, Só minha/Compartilhada com
  "Sua parte: X ml" imediato, pessoas incluindo o usuário, parcela/sobra em seção recolhida, preço
  (valor / cortesia / não sei), horário validado contra o período do rolê, aviso ao sair com alterações,
  botão bloqueado enquanto salva, erro de gravação mantém o formulário.
- **Resumo:** local e data em destaque, início/fim/duração, bebidas agrupadas, gastos, avisos de preço e
  teor ausentes, álcool puro declarado (nunca alcoolemia), registros corrigíveis com recálculo.
- **Histórico:** agrupado por mês, busca por local, filtros de período e tipo, estados vazios distintos.
- **Feedback pós-rolê:** sheet com rolê avaliado, quatro opções selecionáveis + "Salvar relato",
  Depois / Não perguntar; fechar = adiar 24 h; uma vez por abertura do app (não após o resumo).
- **Configurações:** armazenamento local, estado da sincronização, última sincronização, "Sincronizar agora".
- Já existentes: bebida própria reutilizável, favoritos, correção de registros em rolês encerrados.

## Supabase (projeto jiisoqkryhmtopaojyyu)
- Migration `supabase/migrations/20261012000000_initial_schema.sql`: **aplicada pelo dono no SQL
  Editor**; login anônimo **ligado pelo dono**.
- Verificado por API com a publishable key (sessão anônima real): login anônimo ativo; insert de rolê
  e de bebida aceitos; reenvio do mesmo id não duplica; leitura só das próprias linhas; delete em
  cascata. **Não** verificado: lista de políticas/constraints (exige acesso administrativo).
- Este ambiente não tem token/MCP do projeto (o CLI só vê OrbiJob e BusãoGyn, que não foram tocados).
  Para inspecionar/aplicar daqui é preciso um `SUPABASE_ACCESS_TOKEN` da organização dona do projeto.
- Nada disso prova a sincronização rodando no app: o app nunca foi compilado nem executado.

## Limitações conhecidas
- Nada compilado, analisado ou testado (restrição da etapa): podem existir erros de compilação.
- Se a sessão anônima mudar (reinstalação com dados locais preservados é impossível; limpar só a
  sessão é raro), linhas já enviadas ficam presas ao usuário antigo e seriam recusadas pelo RLS.
- Catálogo só embutido; nada de marcas oficiais, OCR, Maps, estimativas de preço ou alcoolemia.
- Sem pull da nuvem, sem login permanente, sem recuperar dados em outro aparelho.
- Favoritos e a data da última sincronização ficam só no aparelho.

## Revisão visual (estado real)
Tudo desta etapa foi escrito e revisado por leitura do código; **nenhuma tela foi renderizada nem
executada**. Pendente de olho humano em aparelho: contraste, espaçamentos, textos longos, escala de
fonte grande, teclado aberto nas telas de formulário, layout largo na web.

## Próximo passo recomendado
`flutter pub get`, `flutter analyze` e corrigir o que aparecer; rodar o cenário completo (Bar MELT)
em aparelho e conferir no painel do Supabase que as linhas chegam. Depois: testes de unidade para
`DrinkDraft`, `OutingSummary`, parsing e `SyncCubit`.
