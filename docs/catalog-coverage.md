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
