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
  "Virar o copo" é só brincadeira visual, refeita como tela imersiva (ver seção "Virar o copo: cerveja em tela cheia").
- **Compartilhar e exportar** (`lib/share/`, `lib/export/`): cartão do resumo (escolhe-se nome do local, mesa, bebidas, gasto; nunca endereço
  nem relato) via `share_plus` (declarado no pubspec, **não resolvido: rode `flutter pub get`**) com cópia de texto como alternativa;
  exportação JSON (tudo) e CSV (rolês e bebidas; `;`, UTF-8 com BOM, vazio = desconhecido) em Configurações → Exportar meus dados.
- **Sincronização compatível:** a coleção `places` entra na fila (antes dos rolês). Colunas/tabelas novas ausentes no servidor não bloqueiam o
  resto: o rolê é enviado sem os campos novos, a linha continua pendente e o aviso diz que parte dos dados aguarda atualização do servidor.
- **Migration `20261014000000_places_budget_feedback_details.sql`: aplicada pelo dono** no projeto `jiisoqkryhmtopaojyyu`
  (informado por ele em 13/10/2026). Conferido por leitura na API (só consulta de esquema com a chave publicável, sem criar registros): a tabela
  `places` e as colunas `outings.place_id/city/state/budget_cents/feedback_wake/feedback_hangover/feedback_note` existem. Isto **não** é uma
  sincronização observada no Flutter: o envio real dos dados pendentes ainda não foi visto rodando.
- **Reenvio após a migration:** linhas que foram enviadas só com a parte compatível continuam na fila (nunca recebem ack parcial). Na próxima
  rodada (retry de 5 min, mudança local, abertura do app ou "Sincronizar agora") a linha completa é reenviada por upsert com o mesmo `id`:
  sem duplicar, sem perder o vínculo com o local e sem reinstalar. `places` sobe antes de `outings`. Um local ainda não confirmado (vínculo: ver abaixo).
  "Sincronizar agora" zera o recuo.
- **Vínculo rolê↔local (revisado):** `P0001` é código genérico do Postgres (o gatilho `outings_place_same_owner` na migration só levanta uma
  exceção, mas ela cobre local inexistente e local de outro dono) e **não** é tratado como "local não sincronizado". O app decide antes de
  enviar: rolê com `place_id` cujo local ainda não foi confirmado (pendente, recusado ou tabela ausente) **não é enviado** e fica na fila com as
  bebidas dele; os rolês independentes seguem. Se o servidor recusar o vínculo (`23503` ou `P0001`), o rolê e o `place_id` ficam intactos e
  pendentes, as bebidas esperam, e o aviso é de erro ("O servidor não aceitou o vínculo..."): nenhuma validação é contornada. Só coluna
  ausente (`PGRST204`/`42703`) ainda gera envio parcial sem os campos novos, com a linha pendente. Tudo por inspeção; nada executado.
- **Limitações conhecidas:** tudo sem execução (podem existir erros de compilação); share via web depende do navegador; "Virar o copo" com sensor
  nunca observado em aparelho; cenários/recipientes desenhados em código (sem assets); "Resenha" não tem som/vibração; estatísticas não têm gráfico de linha
  (de propósito: dia sem registro não é dia sem beber).

## Bebida por foto, rótulo e cardápio (escopo: só o rolê)

**Regra central: bebidas, fotos e itens de cardápio criados neste fluxo pertencem exclusivamente ao rolê de origem.**

- **Fluxos** (entradas em "Adicionar bebida", no rolê ou fora dele; sem rolê ativo o app oferece iniciar um):
  A. *Ler rótulo* (`lib/scan/presentation/scan_label_page.dart`): foto (câmera/galeria) → ver, girar, trocar → ler o texto → revisão
  (`lib/outing_drinks/presentation/outing_drink_review_page.dart`) → "Confirmar e continuar" (vai ao formulário de registro) ou
  "Salvar só neste rolê".
  B. *Ler cardápio* (`scan_menu_page.dart`): uma ou mais fotos → itens candidatos corrigíveis/descartáveis/adicionáveis → salvar como
  "Bebidas deste rolê". Nada vira consumo; o consumo nasce ao escolher o item e confirmar o formulário de sempre.
  C. *Sem leitura automática* (web/desktop, falha ou recusa): a foto continua visível e o texto pode ser digitado/colado, ou o item
  é preenchido à mão. Nunca se simula resultado de OCR.
  Cadastro manual dentro de um rolê usa a mesma tela de revisão (sem foto) e também fica só no rolê. Fora do rolê, "Cadastrar bebida"
  continua gravando em "Minhas bebidas" (bebidas próprias antigas preservadas, sem migração).
- **Como o isolamento funciona:**
  - Coleção própria `outing_drinks` (+ `outing_photos`), sempre com `outing_id`. Não entram em `DrinkRepository.catalog()`, nem em
    "Minhas bebidas", favoritos ou recentes (`recentItemIds` ignora ids `outing:`), nem na busca do catálogo.
  - `OutingDrink.toCatalogItem()` usa o id `outing:<uuid>` (`CatalogItem.outingPrefix`). Todo registro feito dele leva esse
    `catalog_item_id`; `isPriceComparable` (price_history) exclui esses registros de sugestões e do "Seu histórico" por local.
  - O vínculo é pelo id do rolê, nunca pela data (rolê que passa da meia-noite segue sendo o mesmo). A lista "Bebidas deste rolê" filtra
    por `outing_id`; consultar/corrigir o histórico não as mostra em outro rolê.
  - Ao encerrar, itens e fotos ficam no detalhe do rolê (`OutingScanSection` no resumo). Excluir um item da lista ou uma foto não apaga
    consumos já registrados (que guardam o próprio snapshot).
  - Rascunhos (`ScanDraftStore`, chave `scan.draft.<outingId>.<kind>`) ficam presos ao rolê de origem. Se o rolê é encerrado com leitura
    aberta, aparece aviso e o rascunho segue no resumo desse rolê ("Continuar"/"Descartar"); nunca é movido para outro.
- **Teor e origem:** `AbvSource` (rótulo/cardápio/informado/catálogo) fica no item e no snapshot do consumo (`drink_entries.abv_source`,
  coluna opcional). O produto do catálogo nunca é alterado; a correspondência (`catalog_matcher.dart`) só mostra diferenças (tamanho,
  teor, marca, categoria) e o usuário escolhe "usar como referência" ou "preencher campos vazios". Sem percentual de confiança.
- **Interpretação** (`lib/scan/domain/`): `label_parser.dart` (nome/marca por destaque, volume `350 ml`/`600 mL`/`1 L`, teor `4,5% vol`;
  ignora tabela nutricional e porção; só "Ingredientes:" declarados; ambiguidade vira aviso e o campo fica vazio) e `menu_parser.dart`
  (colunas, preço inline/linha seguinte, tamanho+preço por linha, descrição em várias linhas, promoção, preço incerto com trecho para
  escolha, repetidos entre imagens marcados). Coberto só por leitura de código; **nenhum teste ou foto real foi usado**.
- **Preço:** `advertisedCents` é só sugestão no formulário ("Usar como o que paguei/total da conta"); o valor pago continua confirmado
  pelo usuário (valor/cortesia/não sei, compartilhado, etc.). Sem tabela permanente do local nem média pública.
- **Drinks de cardápio:** ingredientes ficam como citados, sem quantidades; receitas parecidas só como referência ("pode ser diferente"),
  com opção de copiar apenas os nomes dos ingredientes; álcool só com volume e teor conhecidos (regra já existente do editor).
- **OCR local:** `google_mlkit_text_recognition` (Google ML Kit, no aparelho, sem cobrança), só Android e iOS. Isolado por import
  condicional (`dart.library.io`) em `lib/scan/data/text_recognizer_*.dart`; na web usa um stub "não suportado". Plataformas
  (conforme a documentação do pacote na pub.dev): Android minSdk 21 (o app usa `flutter.minSdkVersion`; `image_picker` pede 24), iOS 15.5+
  (o projeto foi ajustado de 15.0 para 15.5) com Xcode 15.3+; sem arm 32 bits. Leitura de código de barras **não** existe.
- **Imagens:** `image_picker` (câmera/galeria, também na web), `image` (girar), `path_provider` (pasta do app; sem web). Arquivos em
  `<documentos>/outing_photos/<id>.jpg` (`lib/scan/data/photo_files_io.dart`); na web só em memória (`photo_files_web.dart`), com aviso.
  Nunca base64 em linha. iOS: `NSCameraUsageDescription` e `NSPhotoLibraryUsageDescription` adicionadas ao Info.plist.
- **Nuvem:** linhas `outing_drinks`/`outing_photos` seguem a fila de sincronização existente (mesma tolerância a tabela ausente). Fotos
  sobem para o bucket **privado** `outing-photos` em `<owner>/<outing>/<foto>.jpg` (`PhotoUploader`, rodado após as linhas; mesmo caminho =
  sem duplicar; `uploaded_at` só após confirmação; falha não impede o envio dos dados estruturados nem das outras fotos). Enquanto isso a
  tela mostra "ainda só neste aparelho".
- **Migration:** `supabase/migrations/20261015000000_outing_drinks_and_photos.sql` (tabelas, RLS, gatilho de mesmo dono,
  `drink_entries.abv_source`, bucket privado e policies) **aplicada pelo responsável** no projeto `jiisoqkryhmtopaojyyu`. Isso não
  foi verificado por este ambiente (sem acesso administrativo) nem pela sincronização rodando no Flutter.
- **Revisão de integração (por leitura, 13/10/2026) e correções feitas:**
  - *Rascunhos:* gravar ao sair da tela dentro da janela do atraso (500 ms) agora salva a última edição; rascunho concluído ou
    descartado não é regravado por um salvamento atrasado (`_done`); trocar a foto grava o rascunho antes de apagar o arquivo antigo;
    foto do rascunho ausente (web, arquivo removido) avisa e mantém o texto; no cardápio, itens apontam para a foto pela posição e
    agora são reindexados quando alguma foto sumiu (antes ficavam trocados); rolê encerrado durante a leitura mostra aviso nas telas
    de leitura (o item continua no rolê de origem).
  - *Duplicação:* revisão do rótulo não abre duas vezes com toque repetido; "Continuar" de rascunho idem; abrir formulário/leitura
    a partir do catálogo é um fluxo por vez (evita dois registros por toque duplo). Ids continuam estáveis (formulário, itens do
    cardápio por sessão+item).
  - *Fotos:* foto descartada de uma leitura retomada depois de confirmação parcial passa a ser excluída pelo caminho completo
    (`discardPhoto`), sem deixar linha viva sem arquivo; linhas de foto só nascem se o arquivo existe; o item só aponta para fotos
    que existem; imagens da galeria que não são JPEG (PNG/WebP) são reencodadas para JPEG (o bucket só aceita `image/jpeg`).
  - *Envio:* uma foto que falha não bloqueia as outras (antes o primeiro erro encerrava o envio); foto excluída enquanto o envio
    estava em andamento tem o objeto removido do servidor ao fim (resposta atrasada não a ressuscita); `uploaded_at` segue só após
    confirmação; o contador "aguardando envio" e o estado "Sincronizado" agora incluem fotos pendentes (`PendingUploads.waiting`),
    e foto sem arquivo não conta.
  - *Preço:* o aviso do preço do cardápio deixa explícito que é sugestão e que garrafa/jarra dividida deve ser "Compartilhada" (o valor
    vira total da conta, não a parcela). Preço desconhecido, cortesia e valor informado continuam distintos; a sugestão exige toque.
  - *Verificado por leitura e sem alteração:* itens `outing:` fora de catálogo/Minhas bebidas/recentes/favoritos/sugestões de preço;
    "Mais uma" copia composição, porção, origem do teor e preço; salvar item não cria consumo (só o formulário cria `drink_entries`);
    imports condicionais para web (OCR stub, fotos em memória).
  - *Janela conhecida:* se o app morrer entre o envio do arquivo e o registro de `uploaded_at`, e a foto for excluída antes do
    próximo envio, o objeto pode ficar órfão no bucket (caminho derivado de ids; sem limpeza automática).
- **Limitações:** nada compilado nem executado; pacotes novos não resolvidos (`flutter pub get`); heurísticas de OCR não validadas em
  fotos reais; na web não há leitura automática nem foto durável; leitura só de alfabeto latino; foto de rótulo curvo pode precisar de
  mais de uma imagem (o fluxo aceita uma por leitura de rótulo); `retrieveLostData` do Android não foi exercitado.

## Virar o copo: cerveja em tela cheia (refeito em 13/10/2026)

A tela inteira é o copo. Rota exclusiva (`TipGlassPage`, `lib/glass/presentation/tip_glass_page.dart`): sem AppBar, barra
inferior, cards ou moldura; modo imersivo (`SystemUiMode.immersiveSticky`), retrato travado enquanto aberta; ao sair restaura
`edgeToEdge` e todas as orientações. Controles em sobreposição (fechar, reencher, opções) dentro de `SafeArea`, sobre círculos
escuros translúcidos. Sem som. O simulador tem nível próprio (começa em 78% da tela, deixando ar acima da espuma): **não lê nem
grava registros, estatísticas ou metas**, e não há número de volume na tela.

Camadas:
- **Entrada** (`lib/glass/data/tilt_source.dart`): `sensors_plus` `accelerometerEventStream(SensorInterval.gameInterval)`, o
  acelerômetro **com gravidade** (nunca o linear). Gravidade na tela = `(-ax, +ay)` (convenção Android; a documentação do pacote
  não compara iOS, então o sinal no iOS precisa ser conferido em aparelho). Passa-baixa exponencial (τ = 0,09 s, com tempo real),
  ignora leituras com |a| < 3 m/s² (queda livre/chacoalhão), segura o último ângulo estável e o leva a "nivelado" com `smoothstep`
  quando a projeção da gravidade no plano da tela cai abaixo de 12–32% (aparelho quase deitado); entrada suavizada em 0,9 s.
  Sem leitura em 1,5 s ou erro do stream → cai para o arrasto e avisa.
- **Simulação** (`lib/glass/domain/beer_sim.dart`, sem Flutter além de `ChangeNotifier`): `angle` é a direção de "baixo" na tela;
  mola amortecida angular (ζ ≈ 0,32, oscilação que se acomoda; crítica com redução de movimento) segue o alvo pelo caminho mais
  curto (cruzar ±π não dá salto). O nível é achado por bisseção sobre a **área exata** do semiplano `n·p ≥ s` recortado na
  tela, então o volume se conserva em qualquer ângulo, sem buracos nem retângulo girado. Ondas: amplitude excitada pela velocidade
  angular e amortecida (`exp(-1,7 t)`), duas senoides ao longo da superfície. Bolhas: 40 (13 em modo calmo), arrays
  `Float32List`, sobem contra a gravidade com leve ondulação, são recortadas dentro do líquido e renascem ao tocar a superfície.
  Passo com tempo real entre quadros, limitado a 50 ms (retomada de segundo plano) e 2 subpassos.
- **Escoamento:** a boca do copo é a borda superior da tela. Capacidade = área de `n·p ≥ max(0, nx·W)` (a superfície não pode
  passar do ponto mais baixo da borda). Se `volume > capacidade`, sai por `min(excesso, taxa·dt + 1,5·excesso·dt)` com
  `taxa = 0,05 + 0,55·inclinação` (maior inclinação, maior vazão); volume nunca fica negativo; ao voltar, a capacidade sobe e o
  escoamento para sozinho. Com 78% de enchimento começa a derramar por volta de 40° de inclinação; de cabeça para baixo esvazia.
  Ao esvaziar aparece "Encher novamente" (e o botão de reencher; enche com animação a 0,4/s).
- **Desenho** (`beer_painter.dart`): `CustomPainter` com `repaint: sim` (sem rebuild da árvore por quadro), paints/paths
  reaproveitados. Corpo em gradiente dourado→âmbar ao longo da gravidade, espuma como faixa na face de ar da superfície (espessura
  ~3,4% da altura, borda irregular, contas pequenas), bolhas, leve escurecimento no fundo. O canvas não é girado.
- **Tela** (`tip_glass_page.dart`): `Ticker` + `WidgetsBindingObserver` + `TickerMode`: ticker e sensor pausam em segundo plano
  ou com a rota coberta e são cancelados no `dispose`. Dica "Incline o celular para mexer a cerveja." só na primeira abertura
  (`glass.motion_hint_seen` no `LocalStore`), depois sem texto grande. Opções: reagir ao movimento, bolhas e ondas, nivelar.
- **Sem sensor / web:** na web o sensor nem é assinado (nenhuma autorização). Arrastar gira o copo em torno do centro como um
  disco (`dAngle = (p × delta)/|p|²`) e alimenta **a mesma simulação**; dica "Arraste para inclinar." O mesmo vale se o aparelho não
  entregar leituras, se "Reagir ao movimento" for desligado ou com redução de movimento do sistema (padrão estático/manual,
  ondas e partículas reduzidas).
- **Dependência/configuração:** `sensors_plus: ^7.1.1` no `pubspec.yaml` (`pub get` não rodado; `pubspec.lock` intocado).
  7.x exige AGP ≥ 8.12.1, Gradle ≥ 8.13 e Kotlin 2.2 (o projeto usa AGP 9.1.0, Gradle 9.3.1, Kotlin 2.4.0); iOS ≥ 12 (projeto: 15.5);
  `NSMotionUsageDescription` adicionada ao `Info.plist`; Android sem permissão.
- **A observar em aparelho (nada disso foi executado):** sinal dos eixos no iOS; direção da inclinação; sensação das constantes
  (mola, ondas, taxa de escoamento, ângulo de início do derramamento); aparência das cores e da espuma; desempenho; tablets cuja
  orientação natural é paisagem (eixos do sensor trocados com retrato travado, não tratado); o escoamento não tem
  gota/fio visível (a borda do copo é a borda da tela, o líquido apenas recua); comportamento do modo imersivo e de restauração
  das barras em cada versão do sistema.

## Revisão visual (estado real)
Tudo desta etapa foi escrito e revisado por leitura do código; **nenhuma tela foi renderizada nem
executada**. Pendente de olho humano em aparelho: contraste, espaçamentos, textos longos, escala de
fonte grande, teclado aberto nas telas de formulário, layout largo na web.

## Próximo passo recomendado
`flutter pub get`, `flutter analyze` e corrigir o que aparecer; rodar o cenário completo (Bar MELT)
em aparelho e conferir no painel do Supabase que as linhas chegam. Depois: testes de unidade para
`DrinkDraft`, `OutingSummary`, parsing e `SyncCubit`.
