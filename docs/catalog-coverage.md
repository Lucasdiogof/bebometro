# Cobertura do catálogo (14/10/2026)

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
