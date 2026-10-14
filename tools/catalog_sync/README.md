# catalog_sync: atualização reproduzível do catálogo

Fluxo: **coletar → normalizar → comparar → proposta → (revisão humana) → `catalog_tool.py merge`**.
Nada aqui escreve em `assets/catalog/catalog_v1.json`: a coleta e a comparação só escrevem em `tools/catalog_sync/work/`
(ignorado pelo git). Quem altera o catálogo é o `scripts/catalog_tool.py merge --write`, que só preenche campos vazios e
nunca sobrescreve nem tira média.

## Como executar
```bash
python -I tools/catalog_sync/catalog_sync.py selftest                       # parsers e regras de comparação
python -I tools/catalog_sync/catalog_sync.py collect heineken               # páginas públicas das marcas HEINEKEN Brasil (3 s entre requisições)
python -I tools/catalog_sync/catalog_sync.py import-off CAMINHO/normalized.jsonl   # só normaliza uma coleta do Open Food Facts já feita (sem rede)
python -I tools/catalog_sync/catalog_sync.py compare                        # gera work/proposal.json, proposal.md e research_safe.json
python -I scripts/catalog_tool.py merge tools/catalog_sync/work/research_safe.json          # simulação
python -I scripts/catalog_tool.py merge --write tools/catalog_sync/work/research_safe.json  # aplica
python -I scripts/catalog_tool.py check && python -I scripts/catalog_tool.py ids HEAD       # validações
```
A coleta guarda o HTML bruto em `work/raw/` e reaproveita esse cache; apague o arquivo para forçar nova leitura.

## Candidato (formato normalizado)
`{id, source{kind: manufacturer|distributor|retailer|collaborative, name, url, retrieved, market, reuse}, licenseHold,
match{catalogId, how}, brand, name, variant, fields{abv{value, unit, exactness, quote}, ingredients{value[]}, presentations[{ml, kind?, documented}], style}}`
- `exactness`: `exact`, `max` (limite máximo, p.ex. "no máximo 0,05%") ou `approx`. Só `exact` pode preencher/confirmar teor.
- `documented`: a fonte nomeia aquele tamanho para aquele produto. Sugestões de tamanho nunca são coletadas.
- Campo que a fonte não declara **não existe** no candidato (desconhecido), nunca vira zero/lista vazia.

## Classes da proposta
`new_product` (sem correspondência, com dado utilizável; só revisão humana) · `filled` (campo vazio no catálogo) · `same`
(igual; se o campo não cita aquela URL, vira entrada de procedência) · `conflict` (valor diferente; nada é alterado) ·
`possible_duplicate` (marca+nome parecidos com item existente) · `uncertain` (limite máximo, texto livre colaborativo,
sem correspondência e sem dado).

## Correspondência
Mapeada à mão em `maps/*.json` (URL → id do catálogo). Não há correspondência por similaridade de nome para aplicar dados:
nome parecido só gera `possible_duplicate`. Ids existentes nunca mudam.

## Licença e reutilização (retenção)
`licenseHold: true` ⇒ o candidato é classificado mas **nunca** entra em `research_safe.json`, exceto como citação
(`citationOnly`: URL, rótulo e data, sem trecho copiado) de um valor que o catálogo já tinha.
- **HEINEKEN Brasil (Eisenbahn, Devassa, Kaiser, Baden Baden):** Termos de Uso da Devassa (HNK BR, 11/06/2024, item 4): "O
  armazenamento ou a reprodução no todo ou em parte do conteúdo disponibilizado no Site não é permitido". Termos dos outros três
  sites não localizados. Por isso: só citação de fonte.
- **Open Food Facts:** ODbL (base) + DbCL (conteúdo) + CC BY-SA (imagens). Atribuição e compartilhamento nas mesmas condições
  para bases derivadas; dados colaborativos sem garantia. Candidatos mantidos separados; decisão sobre ODbL pendente.
  Valores de álcool do OFF vêm de campos nutricionais sem unidade garantida (`approx`).

## Limitações
- Só um coletor (HEINEKEN Brasil). Ambev, Petrópolis, Absolut e outros bloqueiam leitura automática (403/anti-robô); não foi contornado.
- Páginas Eisenbahn publicam "Estilo: Ale/Lager" (família): o estilo dessa fonte é ignorado de propósito.
- O `kind` (lata/garrafa) só é lido quando a página escreve "Lata 350" etc.; senão fica desconhecido e não conflita.
- Varejistas/distribuidores ainda não têm coletor: ao criar um, registrar `source.kind`, as condições de uso e `licenseHold`
  conforme os termos do site, e nunca usar endpoints restritos nem credenciais de terceiros.
