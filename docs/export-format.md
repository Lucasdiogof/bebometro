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
- `bebometro-bebidas.csv` ganhou, **no fim**, `consumidor` (`voce` = o dono da conta; senão o id do participante; vazio quando há porções) e
  `porcoes_json` (garrafa compartilhada: `{"me": ml, "<id>": ml}`; `null` = volume desconhecido). Registros antigos saem como `voce`.
- Valores de categorias são **códigos**, não rótulos:
  - `tipo`: `bar`, `club`, `barbecue`, `home`, `restaurant`, `beach`, `other`.
  - `relato`: `smooth`, `cheerful`, `drunk`, `wasted`. `acordou`: `great`, `ok`, `tired`, `bad`.
    `ressaca`: `none`, `mild`, `moderate`, `strong`.
  - `categoria`: `beer`, `draft`, `cocktail`, `spirit`, `wine`, `non_alcoholic`, `water`.
  - `preco_tipo`: `informado`, `cortesia`, `nao_informado`. Booleanos: `sim`/`nao`.
- Mudança desta rodada: antes, `tipo`, `categoria`, `relato`, `acordou` e `ressaca` saíam com o rótulo em português;
  agora saem com o código. Arquivos exportados antes disso têm rótulos em português.

## Pacote completo com fotos (`bebometro-pacote.zip`, opcional)

Botão separado em Configurações → Exportar meus dados. As exportações simples (JSON/CSV) continuam iguais e não incluem fotos.

- Conteúdo: `data/bebometro-dados.json`, `data/bebometro-roles.csv`, `data/bebometro-bebidas.csv` (mesmos formatos acima), `photos/<id_do_rolê>/<id_da_foto>.jpg` e `manifest.json`.
- `manifest.json`: `manifest_version`, `exported_at` (UTC), `hash: "sha256"`, `files[]` (`path`, `bytes`, `sha256`), `totals` (`files`, `bytes`, `photos_included`, `photos_requested`, `photos_omitted`), `omitted[]` (`path`, `reason`) e, quando há pendência de sincronização, `note: "not_fully_synced"`.
- Motivos em `omitted[].reason`: `file_missing` (sem arquivo no aparelho e sem cópia na nuvem), `unreadable`, `download_failed` (a foto só existe na nuvem e o download falhou), `size_limit` (limite de 150 MB de fotos por pacote).
- Fotos só na nuvem (outro aparelho, reinstalação): baixadas da área privada da própria conta, com a sessão da pessoa. Se não houver sessão ou rede, entram em `omitted`.
- Ao final o app lê o ZIP pronto e recalcula o SHA-256 de cada arquivo; se algo não bater, nada é compartilhado. Se houver fotos de fora, a tela avisa antes de compartilhar. Cancelar a qualquer momento não compartilha nada.
- Limite conhecido: o ZIP é montado em memória (por isso o teto de 150 MB).
