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
- **Cobertura (v2):** 82 produtos distintos (55 cervejas, 7 chopps, 3 sem álcool, 17 destilados/aperitivos),
  98 apresentações em 26 produtos, 71 com teor, 30 com ingredientes. Estilos: Lager/Pilsen, IPA (inclui
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
- **Receitas de drinks (feitas na etapa seguinte, ver seção abaixo).**
- **Ainda não coberto:** chopps/marcas regionais, mais artesanais, vinhos e destilados de marca.

## Drinks, doses e procedência (etapa atual)
- **Receitas de referência** (`assets/catalog/recipes_v1.json`, 15): Caipirinha, Caipiroska, Mojito, Negroni,
  Aperol Spritz, Moscow Mule, Margarita, Cuba Libre, Piña Colada, Daiquiri, Cosmopolitan, Old Fashioned, Dry
  Martini, Whiskey Sour (todas de iba-world.com/iba-cocktail/, consultadas em 2026-10-12) e Gin Tônica
  (Bombay Sapphire, pois a IBA não publica). Atenção à atribuição: **Caipiroska** não é receita própria da IBA
  (a página da Caipirinha manda trocar a cachaça por vodka); **Aperol Spritz** é a receita "Spritz" (New Era)
  da IBA, que usa Aperol. Cada receita guarda componentes (ml só quando a fonte dá ml; colheres, folhas,
  gotas e "completar" ficam como texto), papel alcoólico, fonte, preparo, decoração e observações.
- **Registro:** o item de receita abre o formulário em modo drink: composição recolhida ("Ver e ajustar"),
  quantidade e teor por componente, marca/produto do destilado (quando há no catálogo), volume servido
  opcional, preço e horário como sempre. "Drink personalizado" começa vazio; "Salvar como minha receita" cria
  uma receita própria reutilizável. "Mais uma" repete a composição **como foi registrada**, com os ajustes.
  O registro guarda uma cópia (`composition`) com receita de origem, fonte, se foi ajustada e todos os
  componentes.
- **Cálculos honestos** (`recipe.dart`, `DrinkEntry.alcohol`): álcool puro só por componente com ml e teor
  conhecidos; soma dos conhecidos + lista do que falta. Nunca: volume do copo como consumido, gelo como volume,
  colher/folha/fruta em ml, teor padrão por categoria. Volume final desconhecido é aceito e gravado como NULL.
  Aparece como: "pelo menos X g" + "Faltam teor ou quantidade de: ..." no formulário; no resumo, "N registros
  com teor ou quantidade desconhecidos: o total é um mínimo", "N registros sem volume informado" e o volume
  como "120 ml+" ou "desconhecido"; no registro, "volume desconhecido" e "álcool incompleto". Sem alcoolemia.
- **Destilados (17):** Absolut Original, Bombay Sapphire, Beefeater, Johnnie Walker Red e Black Label, Jack
  Daniel's Old No. 7, Chivas Regal 12, Cachaça 51, Velho Barreiro Gold, Patrón Silver, Olmeca Silver, Bacardí
  Superior, Havana Club 3 Años, Aperol, Campari, Martini Rosso e Extra Dry, cada um com fonte. Várias páginas
  são de mercados fora do Brasil (anotado em cada produto). Sem teor: Olmeca, Havana Club, Martini (x2).
  Garrafa comercial é apresentação do produto; dose é sugestão editável (30/50/100 ml, não medida oficial);
  escolher uma garrafa marca como compartilhada. Destilado genérico continua com teor desconhecido.
- **Procedência (campo a campo):** `verified` = fabricante; `mixed` = fabricante + algum campo (teor) só de
  rótulo em fonte secundária (Itaipava Pilsen: Open Food Facts, com a fonte do teor visível); `secondary`
  (Velho Barreiro: guia de bebidas); `generic`; `user`; `recipe`. O selo "Dados do fabricante" não aparece
  para dado cuja única evidência é o Open Food Facts.
- **Divergência de teor** vira `abvVariants` com o escopo de cada valor e o produto fica sem teor único:
  Skol Pilsen (4,6% página × 4,7% embalagens), Colorado Cauim (4,5% × 4,2% edição 016), Johnnie Walker Black
  Label (40% EUA/CA/UK × 43% África do Sul). O formulário mostra os valores como opções, sem escolher um.
- **Embalagens completadas** (páginas dos fabricantes): Budweiser, Stella Artois, Brahma Chopp, Antarctica
  Pilsen/Original/Subzero, Heineken (long neck 330 ml), Corona (330/355 ml e Coronita 210 ml), além de
  destilados (Patrón, Bombay Sapphire, Aperol). Quando a página só lista volumes, a embalagem fica só com o
  volume. **Sugestões de tamanho** (`isSuggestion`) têm rótulo só de volume ("600 ml"), não viram a
  apresentação do registro e **não entram** na busca/filtro de embalagem (só apresentações documentadas).
- **Persistência:** `DrinkEntry.containerMl/personalMl` agora são anuláveis; `composition` (jsonb) só vai na
  sincronização quando há composição, e `custom_drinks.components` só em receitas próprias, então bebidas
  simples seguem sincronizando mesmo sem a migration. Registros antigos leem normalmente.
- **Migration `20261013000000_recipes_and_unknown_volume.sql`: APLICADA pelo dono** (confirmado por leitura/escrita
  de teste pela API: registro com volume nulo + `composition` e receita própria com `components` aceitos).
  Registros de drinks/receitas que ficaram pendentes no aparelho são reenviados automaticamente: a fila
  guarda a linha enquanto o servidor não confirma, tenta de novo com espera crescente, ao abrir/voltar ao app
  (`didChangeAppLifecycleState`) e em "Sincronizar agora". Ainda não foi observado no app rodando.
- **Minhas bebidas e receitas** (Configurações → Minhas bebidas e receitas): lista as bebidas e receitas do
  usuário e permite registrar (no rolê ativo), editar, duplicar e excluir (soft). Edição de bebida simples usa
  `CustomDrinkPage`; receitas usam o **editor completo** (`RecipeEditorPage`): nome, ingredientes
  (adicionar/remover/reordenar), quantidade em ml, "tem álcool", teor, tipo do ingrediente (para escolher marca
  ao registrar) e prévia do álcool com o que falta. "Criar minha versão" no detalhe de uma receita de
  referência abre o editor já preenchido. Nada disso altera registros antigos (cada um guarda o snapshot).
- **Destilado: garrafa x dose.** O formulário de destilado só oferece doses sugeridas (30/50/100 ml, editáveis);
  as garrafas documentadas aparecem como informação e só viram chips (para preencher o volume da garrafa)
  depois que o usuário marca "Compartilhada". Nada marca compartilhamento automaticamente.
- **Totais incompletos:** além do resumo, o card do rolê em andamento mostra pílulas "N sem preço", "N sem
  volume" e "N com álcool incompleto"; o volume aparece como "120 ml (+2 sem volume)" ou "desconhecido".
- **Arquivos temporários:** scripts auxiliares ficam fora do repositório (pasta de scratch da sessão). O
  `pubspec.lock`, `.dart_tool/` e `build/` apareceram no diretório sem ter sido gerados por esta sessão
  (alguém rodou `pub get`/build); `pubspec.lock` foi deixado **intocado e não commitado**: se for o lock
  oficial, commite-o à parte.
- **Pendências reais:** nada foi compilado/executado por esta sessão; marcas de destilados sem fonte confiável
  no Brasil (Smirnoff, Tanqueray, Gordon's, Ypióca, Sagatiba, Cointreau, Jameson, Cuervo) não entraram; licores
  e vinhos de marca ainda vazios; o editor de bebida simples não tem ingredientes por componente (use receita).

## Mesa do rolê (`lib/table/`)
- **Unidades das receitas:** `RecipeUnit` (ml, g, unidade, colher de chá/sopa, folha, gota, a gosto + `other`, o texto original da
  receita). Só ml entra no cálculo de álcool; nada é convertido para ml. Snapshots antigos (`amount_ml`/`amount_text`) são lidos como
  ml/`other`; novos snapshots gravam `amount` + `unit` e ainda `amount_ml` por compatibilidade. Editor e formulário têm campo de
  quantidade + seletor de unidade; receitas de referência preservam a unidade original (barspoon, ramos, gomos, "completar" ficam como texto).
- **Mesa/Lista** na tela do rolê (`SegmentedButton`), menu da mesa: "Trocar cenário" e "Animação ilustrativa das bebidas registradas".
  Preferências (só no aparelho, `TablePrefsCubit`, chaves `table.view`, `table.animations`, `table.scenarios`): mesa como padrão e
  animações (Configurações), e o cenário por rolê. Nenhuma migration.
- **Cenários** (`ScenePainter`): bar/boteco, balada, churrasco, casa, praia, restaurante; o tipo do rolê sugere o inicial; trocar não muda
  local, tipo nem registros. **Recipientes** (`VesselPainter`): lata, long neck, garrafa, copo de cerveja, copo de chopp, dose, taça,
  copo de drink, água e copo genérico; escolhidos pelo rótulo da apresentação e pela categoria (desconhecido = copo genérico coerente).
- **Esvaziamento ilustrativo** (`vesselFill`): só pelo tempo decorrido desde o horário do registro; relógio de 3 s só enquanto a tela está
  visível, app em primeiro plano, animações ligadas e sem "reduzir movimento"; senão, imagem estática do instante da reconstrução.
  Garrafa compartilhada só esvazia a parcela pessoal e mostra "N ml seus". Retrospectiva (rolê encerrado/resumo): recipientes vazios.
- **Muitos registros** (`planTable`): 2 fileiras, slots fixos por ordem; acima da capacidade agrupa iguais ("×N", abre a lista) e,
  se ainda faltar espaço, o último slot vira "+N". Tocar abre detalhes com Corrigir/Excluir existentes; "Desfazer" continua removendo o
  registro certo. Nada de recompensas por quantidade.

## Rodada longa (navegação, locais, orçamento, estatísticas, jogos, compartilhar)
Checklist por bloco em `docs/development-progress.md`. Nada foi compilado, analisado, testado nem visto em tela.
- **Navegação** (`lib/shell/main_shell.dart`): abas Início, Catálogo, Histórico e Resenha (`NavigationBar` + `IndexedStack`, estado e filtros
  preservados); Configurações pelo cabeçalho (`SettingsAction`); barra discreta "Rolê em andamento" nas outras abas; voltar de uma aba
  volta ao Início; `OutingFlow`/`AppRoutes` evitam empilhar a mesma rota. O Catálogo funciona sem rolê (detalhes, busca, filtros, favoritos,
  Minhas bebidas); registrar a partir dele inicia (ou reutiliza) um rolê.
- **Locais salvos** (`lib/places/`): apelido OU endereço, cidade/UF opcionais, tipo, favorito, arquivar; escolher/criar ao iniciar o rolê;
  detalhe com rolês, gastos informados e "Seu histórico de preços". O rolê guarda a própria cópia do local (`nickname/address/city/state`) e
  só o `place_id` liga ao local salvo: editar o local nunca reescreve rolês antigos. Locais nunca são unidos por nome parecido. Sem busca de
  mapas (integração externa fica para depois).
- **Orçamento e preços:** orçamento opcional (ao iniciar ou durante), barra com gasto informado × orçamento e texto honesto quando faltam preços
  (`BudgetStatus`); avisos a 80%/100% uma vez por patamar (`AppPrefs`, pode desligar em Configurações). "Preencher preços ausentes" no resumo:
  um a um ou em lote com prévia; valores já informados só mudam se incluídos e selecionados; em bebida compartilhada vale a parcela paga.
- **Preços do próprio histórico** (`price_history.dart`): sugere o último preço do próprio usuário para o mesmo produto, apresentação e local
  (por `place_id`) ou, sem local salvo, no mesmo rolê; só vira preço ao confirmar; parcela e total da garrafa nunca se misturam; rotulado
  "Seu histórico", nunca média de mercado.
- **Estatísticas** (`lib/stats/`, Histórico → ícone): 7/30/90 dias ou período personalizado; rolês, bebidas por categoria (água/sem álcool à
  parte), volume informado, álcool dos dados conhecidos (mínimo quando incompleto), gastos, locais mais visitados, relatos; comparação só com
  período anterior de mesma duração e só se houver base; toque abre os registros. Sem pontuação, ranking ou limite.
- **Feedback:** após a resposta rápida, detalhes opcionais (como acordou, ressaca, nota, revisar bebidas esquecidas); editável no resumo.
  "Esse rolê ainda está acontecendo?" para rolê aberto há 8 h sem registros: Continuar (não pergunta por 24 h) ou Encerrar com horário
  ajustável; nunca encerra sozinho. Bebida adicionada depois a um rolê encerrado assume o horário final como padrão.
- **Resenha** (`lib/games/`): Eu nunca, Quem é mais provável, Verdade ou desafio; offline, sem conta, sem rolê ativo. Apelidos, Leve ou +18
  (confirmação de adultos; +18 mistura as leves com flerte/humor, tudo opcional), pontos opcionais, pular sem punição, sem repetir cartas até
  acabar (depois pode reembaralhar), partida salva e retomável, cartas próprias (criar/excluir). 134 cartas originais em
  `assets/games/cards_v1.json` com ids estáveis; nenhuma carta pede para beber nem registra bebida.
- **Copão e virar o copo** (`lib/glass/`): copão opcional no rolê (volume conhecido somado, escala explícita, "+N sem volume", sem metas);
  "Virar o copo" é só brincadeira visual (arrastar ou slider; sensores não implementados, exigiriam `sensors_plus`).
- **Compartilhar e exportar** (`lib/share/`, `lib/export/`): cartão do resumo (escolhe-se nome do local, mesa, bebidas, gasto; nunca endereço
  nem relato) via `share_plus` (declarado no pubspec, **não resolvido: rode `flutter pub get`**) com cópia de texto como alternativa;
  exportação JSON (tudo) e CSV (rolês e bebidas; `;`, UTF-8 com BOM, vazio = desconhecido) em Configurações → Exportar meus dados.
- **Sincronização compatível:** a coleção `places` entra na fila (antes dos rolês). Colunas/tabelas novas ausentes no servidor não bloqueiam o
  resto: o rolê é enviado sem os campos novos, a linha continua pendente e o aviso diz que parte dos dados aguarda atualização do servidor.
- **Migration nova, NÃO aplicada (sem acesso administrativo):** `supabase/migrations/20261014000000_places_budget_feedback_details.sql`
  (tabela `places` + RLS, `outings.place_id/city/state/budget_cents/feedback_wake/feedback_hangover/feedback_note`). Ação: rodar no SQL Editor
  do projeto `jiisoqkryhmtopaojyyu`. Até lá locais, orçamento e detalhes do relato ficam só no aparelho (pendentes).
- **Limitações conhecidas:** tudo sem execução (podem existir erros de compilação); share via web depende do navegador; sem inclinação por
  sensor; cenários/recipientes desenhados em código (sem assets); "Resenha" não tem som/vibração; estatísticas não têm gráfico de linha
  (de propósito: dia sem registro não é dia sem beber).

## Revisão visual (estado real)
Tudo desta etapa foi escrito e revisado por leitura do código; **nenhuma tela foi renderizada nem
executada**. Pendente de olho humano em aparelho: contraste, espaçamentos, textos longos, escala de
fonte grande, teclado aberto nas telas de formulário, layout largo na web.

## Próximo passo recomendado
`flutter pub get`, `flutter analyze` e corrigir o que aparecer; rodar o cenário completo (Bar MELT)
em aparelho e conferir no painel do Supabase que as linhas chegam. Depois: testes de unidade para
`DrinkDraft`, `OutingSummary`, parsing e `SyncCubit`.
