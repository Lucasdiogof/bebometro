# Cobertura do catálogo (v5, 14/10/2026)

Gerada por `python -I scripts/catalog_tool.py coverage` (colunas: total, com teor, com teor variável por fonte, com ingredientes declarados, com tamanhos documentados, com estilo).

## Antes (catalog v3, 12/10)
```
TOTAL            82  abv  71  abv-variants   3  ingred  30  sizes  26  style  53
beer             55  abv  50  abv-variants   2  ingred  29  sizes  21  style  33
draft             7  abv   7  abv-variants   0  ingred   1  sizes   0  style   3
nonAlcoholic      3  abv   2  abv-variants   0  ingred   0  sizes   2  style   0
spirit           17  abv  12  abv-variants   1  ingred   0  sizes   3  style  17
brands: 39
```

## Depois (catalog v4, 14/10)
```
TOTAL           112  abv 101  abv-variants   3  ingred  35  sizes  45  style  84
beer             73  abv  68  abv-variants   2  ingred  29  sizes  32  style  52
draft             7  abv   7  abv-variants   0  ingred   1  sizes   0  style   3
nonAlcoholic      3  abv   2  abv-variants   0  ingred   1  sizes   2  style   0
spirit           29  abv  24  abv-variants   1  ingred   4  sizes  11  style  29
brands: 53
```

## O que mudou
- 30 produtos novos (IPAs e linhas regionais: Lohn Bier, Opa Bier, Dogma, Way Beer, Cervejaria Nacional; destilados e aperitivos: Johnnie Walker Double Black/Gold Label, Smirnoff, Cointreau, Cîroc, Captain Morgan, Cynar, cachaças Salinas/Weber Haus/Pitú/Leblon). 6 produtos existentes preencheram lacunas (Heineken 0.0 ingredientes, Heineken estilo, Johnnie Walker tamanhos, Patrón, Bombay).
- Cada produto novo ou atualizado traz `retrieved` (data da consulta) e `market`; o carregador usa essa data na fonte exibida. Entradas com `market: "US"` vêm de página fora do Brasil e dizem isso na nota.
- Nenhum ID existente mudou. Valores já presentes nunca são sobrescritos pelo script; conflito só é listado. Nenhuma média de teores.

## Limites encontrados (nada foi inventado para cobrir)
- Sites oficiais da Ambev, Brahma, Skol, Budweiser, Stella, Wäls, Petra e Grupo Petrópolis respondem com verificação anti-robô (403); não foi contornada. Por isso Skol, Brahma, Antarctica, Bohemia, Colorado, Itaipava, Petra e Black Princess **continuam com as lacunas anteriores**. Colorado e Patagonia não resolvem DNS; amstel.com.br tem erro de certificado.
- Páginas de varejistas foram **descartadas** (Stella Pure Gold e Budweiser Zero não entraram): não são fonte oficial nem rótulo.
- Heineken 0.0: a página oficial diz "no máximo 0,03%"; `abv` ficou nulo, não 0.
- Michelob Ultra: 3,5% (imprensa 2021, já no catálogo) vs 4,2% (varejistas); sem fonte oficial, nada mudou.
- Brahma Duplo Malte (Trigo/Tostada/Black): teor só em matéria de imprensa; não aplicado.
- Não consultados nem copiados: AlcoLog, AlcoStat, Untappd, Wikipédia (para números).
- Para continuar: precisa de acesso às páginas oficiais bloqueadas (por exemplo, o responsável copiar teor/ingredientes/tamanhos do rótulo ou da ficha) ou de fotos de rótulos via o fluxo de rótulo do próprio app.

## Depois (catalog v5, 14/10, segunda rodada)
```
TOTAL           116  abv 104  abv-variants   3  ingred  36  sizes  61  style  85  field-sourced  27
beer             76  abv  70  abv-variants   2  ingred  30  sizes  46  style  52  field-sourced  23
draft             7  abv   7  abv-variants   0  ingred   1  sizes   0  style   3  field-sourced   0
nonAlcoholic      3  abv   2  abv-variants   0  ingred   1  sizes   2  style   0  field-sourced   1
spirit           30  abv  25  abv-variants   1  ingred   4  sizes  13  style  30  field-sourced   3
brands: 55
```
Comparação v4 → v5: produtos 112 → 116; marcas 53 → 55; com teor 101 → 104; com ingredientes 35 → 36; com apresentações
documentadas 45 → 61; **23 produtos existentes tiveram lacunas preenchidas** (todas de embalagem), nenhum valor existente foi
sobrescrito (conferido comparando com o `HEAD` anterior) e nenhum ID mudou.

### Procedência por campo (`fieldSources`)
Cada campo preenchido nesta rodada tem `{url, label, retrieved, market, evidence (primary/secondary), variant, note}`.
`catalog_tool.py check` exige esses campos; o `merge` só registra a fonte das embalagens que de fato entraram. O carregador do
app ignora `fieldSources`; por isso os 22 produtos que receberam tamanhos de cadastro de código de barras ganharam uma frase na
nota (pt/en/es) dizendo isso.

### Fontes usadas
- **Primárias (site oficial, Brasil):** Devassa (`devassa.com.br/produtos/devassa-garrafa|lata`: 4,7%, "Água, malte, milho e
  lúpulo", 300/600/1000 ml garrafa e 269/350/473 lata), Kaiser (`kaiser.com.br/produtos/`: lata 473, garrafa 600), Licor 43
  (`licor43.com/pt-br/perguntas-frequentes/`: Original 31%), Itaipava (`cervejaitaipava.com.br/produto/...`, sem `www`:
  confirmou o que já estava no catálogo).
- **Secundárias:** cadastros GTIN no Systax (`systax.com.br/ean/<código>`, dados fiscais de NF-e; prefixo 789 = GS1 Brasil)
  só para **embalagem** (volume + tipo explícitos na descrição padronizada; kits, packs, barris, promoções e edições especiais
  descartados). Comprovam que a embalagem existiu no mercado brasileiro, não que ainda esteja à venda. Imprensa (SuperVarejo,
  lançamento da Petra Ultra: 4%, lata 269 e long neck 275).
- **Descartadas:** Open Food Facts (itens brasileiros sem teor/ingredientes; os com ingredientes eram rótulos do Chile/Paraguai,
  em espanhol), Zé Delivery (exige endereço e JavaScript), varejistas, blog com teor 4,95% da Bohemia (diverge de outra fonte).

### Produtos novos (v5)
Devassa Tropical (oficial), Licor 43 Original (oficial), Petra Ultra (imprensa, `evidence: secondary`), Bohemia Puro Malte (só
embalagens por GTIN; teor em branco porque as fontes secundárias divergem).

### Lacunas preenchidas (só embalagens, por GTIN, salvo indicação)
Skol Pilsen, Brahma Chopp, Brahma Duplo Malte, Duplo Malte Trigo, Brahma Zero, Budweiser, Stella Artois, Bohemia Magna Pils,
Bohemia 14-Weiss, Antarctica Original, Colorado Appia, Colorado Indica, Itaipava Pilsen, Premium, Malzbier e 100% Malte, Petra
Origem, Petra Stark Bier, Patagonia Bohemian Pilsener, Spaten, Beck's, Corona, Cachaça 51, Absolut, Kaiser (oficial).

### Lacunas que continuam (sem fonte aceitável)
- **Teor e ingredientes de Skol, Brahma (Duplo Malte Tostada/Black incluídos), Antarctica, Bohemia, Budweiser e Stella:**
  sites da Ambev com verificação anti-robô (403 / Incapsula); não contornado. Skol Pilsen segue com as duas variantes oficiais
  (4,6% e 4,7%), sem média.
- **Petra e Black Princess:** `cervejapetra.com.br` e `grupopetropolis.com.br` 403; `blackprincess.com.br` não responde. Achados de
  imprensa da Black Princess (Bohemian Pilsner 5,2%, FemAle 7,4%) não entraram: rótulos sazonais pouco relevantes.
- **Colorado:** domínio não resolve; Appia/Indica só ganharam a lata de 350 ml.
- **Itaipava Fest Drinks** (7,9%, drinks prontos) e **Go Draft** (sem teor) não entraram: o modelo não tem categoria de drink pronto.
- **Destilados:** embalagens de Beefeater, Jack Daniel's, Chivas, Bacardi, Campari, Martini e outros; o catálogo de marcas da
  Heineken (`catalogodemarcas.heineken.com.br`) carrega por JavaScript atrás de confirmação de idade e não foi usado.
- **Heineken 0.0:** continua "no máximo 0,03%" na nota, `abv` nulo (o modelo não tem limite superior).

## Catálogo v6 (14/10/2026, terceira rodada): bebidas prontas e procedência
```
TOTAL           136  abv 112  abv-variants   3  ingred  36  sizes  78  style  86  field-sourced  47
beer             76  abv  70  abv-variants   2  ingred  30  sizes  46  style  53  field-sourced  23
draft             7  abv   7  abv-variants   0  ingred   1  sizes   0  style   3  field-sourced   0
nonAlcoholic      3  abv   2  abv-variants   0  ingred   1  sizes   2  style   0  field-sourced   1
readyToDrink     20  abv   8  abv-variants   0  ingred   0  sizes  17  style   0  field-sourced  20
spirit           30  abv  25  abv-variants   1  ingred   4  sizes  13  style  30  field-sourced   3
brands: 62
```
v5 → v6: produtos 116 → 136; marcas 55 → 62; com teor 104 → 112; com ingredientes 36 → 36; com apresentações 61 → 78;
**bebidas prontas (RTD): 0 → 20**. Produtos existentes: 1 lacuna preenchida (Spaten, estilo "Munich Helles" pelo rótulo) e 5 valores
confirmados por foto de rótulo brasileiro (Spaten 5,2%, Corona 4,6% na lata de 269 ml, Stella 5,0%, Skol 4,7% na lata de 269 ml) ou
contraditos (Antarctica Original: lata de 350 ml diz 5,0%, catálogo tem 4,9%; mantido, divergência na nota e na procedência).

### RTDs (categoria `readyToDrink`, código salvo `ready_to_drink`)
- **Com teor:** Fest Drinks Gin Tônica 7,9%, Intense Citrus 7,9% e Spritz 5,0% (site oficial da Itaipava); 51 Ice Gin Tônica 7,9%
  (lata 269) e Açaí com Guaraná 5,5% (275 ml) (GiroNews, imprensa); Skol Beats GT 7,9% (lata 269; Tribuna de Jundiaí, 2020);
  Skol Beats Mint Mojito 7,9% (descrição do cadastro GTIN); Smirnoff Ice Tropical 5% (foto do rótulo brasileiro, Open Food Facts).
- **Só embalagens (teor em branco, sem fonte aceitável):** Skol Beats Senses (o 8% de 2014 não foi confirmado), Red Mix, Green Mix,
  Tropical, Caipi Beats; Smirnoff Ice Original e Green Apple; 51 Ice Limão; Tanqueray, Gordon's e Beefeater Gin Tônica prontos; Isla
  Hard Seltzer Framboesa e Amora.
- Cada sabor é um produto: nenhum teor foi herdado de outro sabor da linha; ingredientes não foram deduzidos do nome.
- Não entraram: Corote (teores de linha em imprensa e varejo, divergentes), 51 Ice XVT (fonte não lida), Tanqueray 6,5% (foto ilegível),
  Smirnoff Ice com 5% só em varejistas, linhas sem nenhum dado além do nome.

### Fontes novas desta rodada
- Fotos de rótulos do Open Food Facts (CC BY-SA), lidas uma a uma; só valem rótulos em português com código 789. Um contrarrótulo da
  Budweiser 330 ml com código brasileiro era **chileno** (budweiser.cl) e foi descartado.
- Tipo de fonte por campo (`type`): `official`, `label`, `packagingRegistry`, `secondary`.

### Lacunas que continuam
- Ingredientes: nenhuma fonte nova legível (os versos fotografados estavam cortados). Ambev/Petrópolis seguem bloqueados.
- Teor de Bohemia, Budweiser (BR), Brahma Duplo Malte Tostada/Black, Petra Origem, Black Princess; embalagens de vários destilados.

## Atualização reproduzível (`tools/catalog_sync`, 14/10/2026)
Processo: `collect` → `import-off` → `compare` → revisão de `proposal.md` → `catalog_tool.py merge`. Ver `tools/catalog_sync/README.md`.

**Cobertura de dados antes/depois: sem mudança** (136 produtos; teor 112; teor variável 3; ingredientes 36; apresentações 78; estilo 86).
Nenhum campo vazio foi preenchido: as 17 páginas das marcas HEINEKEN Brasil (Eisenbahn, Devassa, Kaiser, Baden Baden) trouxeram os mesmos
valores que o catálogo já tinha (9 de 9 teores iguais; ingredientes da Devassa e tamanhos iguais).
**Procedência por campo: 10 produtos alterados, 15 entradas novas em `fieldSources`, nenhum valor novo.** IDs: `eisenbahn-pilsen`, `eisenbahn-american-ipa`, `eisenbahn-pale-ale`, `eisenbahn-weizenbier` (teor), `baden-baden-cristal`, `baden-baden-golden`, `baden-baden-ipa`, `baden-baden-witbier` (teor e tamanhos), `kaiser-lager` (tamanhos 350 ml e 1 L) e `devassa-tropical` (ingredientes).
Desses 10, **8 não tinham `fieldSources` e passaram a ter** (47 → 55 produtos com procedência por campo: 4 Eisenbahn + 4 Baden Baden);
`kaiser-lager` e `devassa-tropical` já tinham e ganharam entradas (2 + 1). Conferido por diff contra `1dc870e`: nenhum outro campo mudou.
Entradas só com URL, rótulo e data (sem trecho copiado), por cautela com os termos de uso (abaixo).

### Candidatos retidos (não aplicados)
- **Open Food Facts (14 registros do cache, mapeados à mão a 9 produtos):** 4 tamanhos que o catálogo não tem (Heineken 350 e 250 ml,
  Heineken 0.0 350 ml, Colorado Appia 600 ml) ficam **pendentes** (não incorporados nesta rodada, sem bloquear o app): ODbL exige atribuição
  e compartilhamento nas mesmas condições, o dado é colaborativo e a unidade do campo de álcool não é garantida. Nenhum teor ou ingrediente
  do OFF foi proposto como exato.
- **Páginas HEINEKEN Brasil, evidência por domínio:**
  - `devassa.com.br`: restrição **encontrada**. Termos de Uso (HNK BR Indústria de Bebidas Ltda, atualizado em 11/06/2024), item 4: o armazenamento
    ou a reprodução, no todo ou em parte, do conteúdo do site não é permitido.
  - `eisenbahn.com.br` e `badenbaden.com.br`: termos **não localizados** (as URLs testadas, `/termos-de-uso/`, deram 404; não procurei por outros caminhos).
  - `kaiser.com.br`: a página `/informacoes-legais/termos-de-uso/` existe, mas o texto não veio na leitura (conteúdo vazio no HTML); **não lido**.
  - Não há demonstração de que os termos da Devassa se apliquem aos outros domínios. Por cautela (sem evidência em contrário), os quatro foram tratados
    igual no processo: nenhum dado novo é incorporado por eles e só se cita a fonte de valores que o catálogo já tinha. Nenhum dado novo apareceu de qualquer forma.
- Sem teor na página (ficam desconhecidos): Kaiser (todas), Eisenbahn Session IPA e Unfiltered.

### Pesquisa de fontes (resumo)
- MAPA/SIPEAGRO "Vinhos e Bebidas": só estabelecimentos (UF, município, registro, status, CNPJ mascarado, razão social, área, atividade,
  classificação); sem produto, teor ou ingrediente.
- Sem fonte gratuita pública com teor + ingredientes + apresentações para o mercado brasileiro: GS1 Brasil (contrato) e Cosmos (25 consultas/dia)
  não foram contratados; FatSecret/USDA/LCBO não cobrem o Brasil. Amostra de 35 produtos no OFF: 16 com tag Brasil, 4 com teor, 6 com ingredientes.
- Aviso sobre o passado: valores já presentes que vieram de rótulos transcritos no OFF (p.ex. Itaipava Pilsen, Smirnoff Ice Tropical) são
  fotos lidas à mão, não dados importados; seguem com a procedência de cada campo.


## Rodada 19/10/2026: pesquisa de mesa (catalog v6 + 170 itens)

Fonte: apêndice A do plano "Bebômetro: rolê, pessoas e conta da mesa" (195 candidatos). **Não são 195 novos**: o diff contra o catálogo real
deu **24 já existentes** (13 drinks que já tinham receita ou produto, 3 chopes que são formas de serviço de produtos já cadastrados,
8 cervejas), **1 não importado** (Petra Ultra Puro Malte Sem Glúten: possível duplicata de `petra-ultra`, não provada) e **170 novos**:
91 drinks (inclui Spritzgerald e Fitzgerald), 46 vinhos e espumantes, 23 cervejas, 10 chopes. Nenhum ID existente mudou ou sumiu
(`catalog_tool.py ids`: lost none, renamed none, values changed none).

Contagem de **produtos** (`assets/catalog/catalog_v1.json`): antes 136 produtos, 62 marcas; depois **306 produtos** (136 + 170: 91 drinks + 46 vinhos/espumantes + 23 cervejas + 10 chopes), 72 marcas; 15 receitas de referência inalteradas. Aliases de busca: `chope spaten`/`chopp spaten`
e equivalentes para Patagonia Weisse e Amber Lager (6 aliases). **Fora dos 306**: 13 atalhos genéricos novos, que vivem no código (`CatalogSource`, não no JSON) e não contam como produtos, sem teor nem volume: Chope IPA, Chope de
trigo, Vinho rosé, Espumante brut, Espumante moscatel, Sangria, Clericot, Batida, Caipirinha de fruta, Cozumel, Dose de destilado,
Energético, Drink sem álcool (+ alias "drink da casa").

Campos conhecidos nos novos: só os que a pesquisa trouxe com fonte: Amstel Ultra (4%, garrafa 275 ml e lata 269 ml), Baden Baden Peach
(4,9%, lata 350 ml), Lagunitas IPA (6,2%, lata 350 ml), Colombina Romaria (9%), Praya Receita Clássica (355 long neck, 269 lata, 600 garrafa),
Praya Lager (330 long neck). Todo o resto: teor, volume, ingredientes e estilo **desconhecidos** (vinhos e espumantes: nenhum teor).
O chope Lagunitas não herda o teor da lata; o chope Heineken não herda nada da garrafa. Chope e cerveja da mesma marca são itens
distintos (forma de serviço): `heineken-lager-chope` x `heineken-heineken`, `brahma-claro-chope`/`black`/`escuro` x `brahma-chopp` (lata/garrafa).

Spritzgerald (`drink-spritzgerald`) é um drink com nome, preço e pessoa e **composição desconhecida**; a nota cita a versão da Monin (EUA)
como referência, sem importar receita nem teor. Fitzgerald (`drink-fitzgerald`) é outro item (Difford's Guide), não sinônimo.

Procedência: nomes de coquetéis (IBA, Monin, Difford's) e de Petra (índice de busca, página bloqueada) ficam como `evidence: secondary`;
produtos de fabricantes e das lojas oficiais do grupo ficam como dado do fabricante, mas **só o nome** consta (nota explícita).
Sugestões de copo (nunca tamanho oficial): chope 200/300/400/500 ml; vinho por taça 100/125/150 ml e garrafa 750 ml.
Busca: "chop", "chopp" e "chope" são a mesma palavra (`searchKey`); com "chop" na busca o chope servido vem antes da lata/garrafa.

Cobertura depois (`catalog_tool.py coverage`):
```
TOTAL           306  abv 116  abv-variants   3  ingred  36  sizes  83  style 103  field-sourced  61
beer             99  abv  74  abv-variants   2  ingred  30  sizes  51  style  53  field-sourced  37
cocktail         91  abv   0  abv-variants   0  ingred   0  sizes   0  style   0  field-sourced   0
draft            17  abv   7  abv-variants   0  ingred   1  sizes   0  style   3  field-sourced   0
nonAlcoholic      3  abv   2  abv-variants   0  ingred   1  sizes   2  style   0  field-sourced   1
readyToDrink     20  abv   8  abv-variants   0  ingred   0  sizes  17  style   0  field-sourced  20
spirit           30  abv  25  abv-variants   1  ingred   4  sizes  13  style  30  field-sourced   3
wine             46  abv   0  abv-variants   0  ingred   0  sizes   0  style  17  field-sourced   0
brands: 72
```
