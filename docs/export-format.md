# Formato dos arquivos exportados

A exportação (Configurações → Exportar meus dados) gera arquivos que **não dependem do idioma do app**, para que uma
importação futura leia sempre o mesmo formato.

## JSON (`bebometro-dados.json`)

- Chaves em inglês/snake_case, estáveis (`format_version: 1`).
- `language` (código do idioma do app no momento da exportação) e `note` (texto humano) são os únicos campos que
  acompanham o idioma; ninguém deve depender deles.
- Valores monetários em **centavos** (BRL), volumes em **ml**, horários em **UTC** (ISO 8601). Campo nulo = desconhecido,
  nunca zero.
- Códigos de enum (`type`, `category`, `price_kind`, ...) são os valores salvos; não são traduzidos.
- `presentation` é o texto canônico salvo no registro (forma pt-BR, ex.: "Lata 350 ml").

## CSV (`bebometro-roles.csv`, `bebometro-bebidas.csv`)

- Separador `;`, UTF-8 com BOM, texto entre aspas (`""` escapa aspas), número com **vírgula decimal**, vazio = desconhecido.
  Esse formato é fixo (pensado para planilhas pt-BR) e **não muda com o idioma do app**.
- Nomes das colunas fixos (`id`, `inicio_utc`, `tipo`, `categoria`, `preco_tipo`, ...), em português, como nas primeiras
  versões: são identificadores, não texto de tela.
- Valores de categorias são **códigos**, não rótulos:
  - `tipo`: `bar`, `club`, `barbecue`, `home`, `restaurant`, `beach`, `other`.
  - `relato`: `smooth`, `cheerful`, `drunk`, `wasted`. `acordou`: `great`, `ok`, `tired`, `bad`.
    `ressaca`: `none`, `mild`, `moderate`, `strong`.
  - `categoria`: `beer`, `draft`, `cocktail`, `spirit`, `wine`, `non_alcoholic`, `water`.
  - `preco_tipo`: `informado`, `cortesia`, `nao_informado`. Booleanos: `sim`/`nao`.
- Mudança desta rodada: antes, `tipo`, `categoria`, `relato`, `acordou` e `ressaca` saíam com o rótulo em português;
  agora saem com o código. Arquivos exportados antes disso têm rótulos em português.
