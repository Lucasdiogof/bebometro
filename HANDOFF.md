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

## Identidade (logos)
`assets/branding/logo_cap.png` (tampinha "B": ícone do app, splash, loadings via `BrandLoader`) e
`logo_wordmark.png` ("Bebômetro" escrito: cabeçalho da home; reservado para as telas de login/cadastro
quando existirem, via `BrandWordmark`). Ícones Android/iOS/web e splash nativa foram gerados a partir da
tampinha (fundo preto). Os originais enviados no chat tinham fundo preto; os PNGs foram recortados por
máscara, então vale conferir as bordas em aparelho.

## Catálogo (etapa de produtos reais)
- **Dados:** `assets/catalog/catalog_v1.json` (versionado, `consultedOn: 2026-10-12`), lido por
  `CatalogLoader` e entregue ao `DrinkRepository`. IDs estáveis (`marca-produto`). Atualizar o arquivo não
  apaga favoritos, bebidas próprias nem registros (cada registro guarda a própria cópia). Não há
  distribuição pelo Supabase e **nenhuma migration nova** foi necessária.
- **Modelo:** `CatalogItem` (marca, nome, categoria, estilo, teor, ingredientes declarados, apresentações
  com tipo e volume, aliases, fonte `SourceRef`). Um produto tem várias apresentações; versão sem álcool é
  produto à parte. Origem exibida: "Dados do fabricante", "Genérico" ou "Criada por você" (sem selos de
  certificação). Produto sem tamanhos verificados usa "tamanhos comuns da categoria" no formulário, avisado
  na tela.
- **Cobertura:** 65 produtos distintos de 24 marcas (55 cervejas, 7 chopps, 3 sem álcool), 56 apresentações
  em 19 produtos, 36 com estilo, 61 com teor, 30 com ingredientes. Estilos: Lager/Pilsen, IPA (inclui
  Imperial, Session, English), Pale Ale, Weiss/Weizen, Witbier, Porter, Imperial Stout, Tripel, Golden
  Strong, Honey Wheat Ale, Malzbier e outros, como a fonte declara.
- **Fontes:** páginas de produto dos fabricantes (Ambev e marcas: brahma/skol/ambev.com.br; Heineken Brasil
  e Sol; Eisenbahn; Baden Baden; Itaipava e Grupo Petrópolis; Kaiser) lidas via buscas restritas ao domínio
  (várias páginas bloqueiam leitura automática, então o texto veio dos resultados indexados). Exceção: o teor
  da Itaipava Pilsen vem do rótulo da lata de 350 ml transcrito no Open Food Facts (código 7897395020101).
  Cada produto guarda o endereço da fonte, visível em "Fonte dos dados" no detalhe.
- **Campos incompletos:** sem teor: Heineken 0.0, Kaiser, Itaipava Premium e Malzbier; ingredientes ausentes
  na maioria (só entram listas declaradas completas); tamanhos verificados só em 19 produtos; estilo
  ausente quando o fabricante não declara (nada foi inferido pelo nome). Divergências ficam em `note`
  (ex.: Skol Pilsen 4,6% na página vs 4,7% nas embalagens). Dados podem variar por versão/mercado/data.
- **Busca/filtros:** sem acento/maiúscula, por marca, produto, estilo, aliases e apresentações; filtros de
  categoria, marca, estilo (família), apresentação e "só sem álcool", filtros ativos removíveis e "Limpar
  filtros"; recentes e favoritos; um cartão por produto (nunca por tamanho).
- **Detalhe:** nome/marca, categoria, estilo, teor, ingredientes, apresentações, fonte discreta (copiável),
  favoritar e registrar. Bebida própria: criar, **editar**, excluir (soft) e reutilizar, com ingredientes.
- **Receitas de drinks: NÃO feitas.** Exigem modelo de componentes (ingrediente, quantidade, teor) e edição
  na hora do registro, e as fontes encontradas não trazem teor dos componentes (sem eles não se calcula
  álcool). Etapa delimitada para depois: receita de referência (com fonte) separada do drink servido,
  ingredientes/quantidades editáveis, álcool só com quantidades e teores conhecidos, gelo e volume do copo
  fora do consumo, sem calorias/açúcar inventados. Os drinks genéricos atuais continuam como estão.
- **Ainda não coberto:** chopps/marcas regionais, mais artesanais, vinhos e destilados de marca.

## Revisão visual (estado real)
Tudo desta etapa foi escrito e revisado por leitura do código; **nenhuma tela foi renderizada nem
executada**. Pendente de olho humano em aparelho: contraste, espaçamentos, textos longos, escala de
fonte grande, teclado aberto nas telas de formulário, layout largo na web.

## Próximo passo recomendado
`flutter pub get`, `flutter analyze` e corrigir o que aparecer; rodar o cenário completo (Bar MELT)
em aparelho e conferir no painel do Supabase que as linhas chegam. Depois: testes de unidade para
`DrinkDraft`, `OutingSummary`, parsing e `SyncCubit`.
