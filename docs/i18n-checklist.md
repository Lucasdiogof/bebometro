# Internacionalização (pt-BR, en, es): checklist

Rodada de 13/10/2026. Estados usados (separados de propósito):

- **Implementado em código**: escrito e revisado por leitura. Nada foi compilado, analisado nem executado.
- **Configurado externamente**: feito num painel/serviço fora do repositório.
- **Verificado em execução**: observado rodando (nada desta rodada está neste estado).
- **Parcial**, **Pendente**, **Bloqueado** (com motivo).

## Decisões

- **Mecanismo oficial:** `flutter_localizations` + `gen-l10n` (`l10n.yaml`). ARBs em `lib/l10n/app_{pt,en,es}.arb`;
  `pt` é o template e o fallback final. O código gerado fica **versionado** em `lib/l10n/generated/` (gerado com
  `flutter gen-l10n`, que roda sem resolver dependências).
- **Acesso:** `tr.chave` (`lib/l10n/l10n.dart`), lido na hora de montar o texto. Nenhuma frase traduzida vira dado
  persistido: códigos de enum, IDs e chaves salvas não mudam com o idioma.
- **Idioma:** preferência do aparelho (`DeviceStore`, chave `app.language`): sistema, pt-BR, English, Español. "Sistema"
  segue o telefone quando é pt/en/es; qualquer outro → pt-BR. Disponível antes do login. A troca não reinicia o app
  (`LocaleController` + reconstrução dos elementos preservando o estado: formulários, rolê, partida).
- **Plurais e placeholders** em ICU dentro dos ARBs; sem frases montadas por concatenação (restam só listas separadas
  por vírgula e rótulos de acessibilidade com partes).
- **Formatos por idioma** (`lib/core/utils/formatters.dart`): datas, horas, números, percentuais e distâncias seguem o
  idioma. **Moeda não muda**: tudo em reais (BRL), guardado em centavos.
- **Campo de dinheiro** (`MoneyField`) e parser numérico único (`parseCents`/`parseDecimal`/`numberInputError`): aceita
  "15", "15,5", "15.50", "1.500,00", "1,500.00"; recusa e **mostra erro no campo** para entrada ambígua ("1.500",
  "1,500") em vez de adivinhar. Inteiros de ml continuam com `parseInteger` (só dígitos).
- **Rótulos de embalagem:** o texto salvo no registro (`DrinkEntry.presentation`) continua na forma canônica pt-BR
  ("Lata 350 ml", "Garrafa 1.000 ml"); a tela traduz na exibição (`localizePresentation`). Assim chips de comparação,
  detecção de recipiente da mesa e exportações não dependem do idioma, e nada salvo foi migrado.
- **Conteúdo editorial:** catálogo e receitas têm blocos `i18n` (en, es) nos próprios JSON (notas, nomes das fontes,
  escopos de teor, método/decoração/ingredientes das receitas, apelidos de busca). Cartas dos jogos têm `i18n` por carta.
  Marcas e nomes de produtos não são traduzidos. **Ingredientes declarados pelo fabricante ficam no original** (sem
  tradução inventada); a tela rotula "texto original".
- **Texto reconhecido por OCR e cardápios** permanece original. As palavras-chave do leitor de rótulo ganharam
  equivalentes em inglês e espanhol (aditivo; heurística, não validada em fotos reais).
- **Conteúdo do usuário** (apelidos, nomes de bebidas próprias, receitas próprias, cartas próprias, observações) nunca é
  traduzido.
- **Superfícies nativas:** o Flutter manda os textos já no idioma do app (`texts` no payload); Swift/Kotlin só exibem e
  mantêm o português como fallback. Descrições de permissão do iOS em `InfoPlist.strings`, que o iOS escolhe pelo
  **idioma do sistema** (limite do iOS: não segue a escolha manual do app).
- **Exportação:** chaves JSON estáveis; CSV com colunas e códigos fixos, independentes do idioma (ver
  `docs/export-format.md`). Texto compartilhado para pessoas (comanda, cartão) segue o idioma do app.
- **E-mails de autenticação:** telas nos três idiomas; templates do Supabase preparados no repositório e **ainda não
  aplicados** (ver `docs/auth-emails.md`).

## Blocos

| # | Bloco | Estado |
|---|-------|--------|
| 0 | Base: gen-l10n, `tr`, `LocaleController`, seletor em Configurações, formatadores, parser, `MoneyField` | Implementado em código |
| 1 | Conta: login, cadastro, e-mail, senha, dados antigos, recuperação, conflitos, Minha conta | Implementado em código |
| 2 | Home, navegação, rolê (iniciar/editar/encerrar), orçamento, correção de preços, feedback | Implementado em código |
| 3 | Bebidas: catálogo, filtros, formulários, "Mais uma", receitas, minhas bebidas, busca nos 3 idiomas | Implementado em código |
| 4 | Foto: rótulo, cardápio, revisão, rascunhos, bebidas do rolê | Implementado em código |
| 5 | Locais, busca e mapa | Implementado em código |
| 6 | Comanda: itens, extras, serviço, desconto, divisão, pagamentos, compartilhar | Implementado em código |
| 7 | Histórico, estatísticas, exportação, compartilhamento, configurações, sincronização | Implementado em código |
| 8 | Mesa e simulador (textos, acessibilidade) | Implementado em código (física e desenho intocados) |
| 9 | Jogos: telas e 134 cartas em en/es | Implementado em código |
| 10 | Nativo: Live Activity, Dynamic Island, notificação Android, `InfoPlist.strings` | Implementado em código; permissões do iOS seguem o idioma do sistema |
| 11 | Compartilhamento e exportação | Implementado em código |
| 12 | E-mails de autenticação | Parcial: telas prontas; templates no repositório, **não aplicados no painel** |
| 13 | Geração (`flutter gen-l10n`) | Feita (código gerado versionado) |
| 14 | Documentação | Feita |

## Limites conhecidos (reais)

- **Nada foi compilado, analisado nem executado.** Conferências feitas: `flutter gen-l10n` (valida os ARBs), e scripts
  de leitura (chaves usadas × existentes, número de argumentos e ordem dos placeholders, uso de `tr.` em contexto
  `const`, imports). Pode haver erros de compilação que só `flutter analyze` mostra.
- **Snapshots de nome:** registros guardam o nome da bebida do momento do registro (inclusive composições e ingredientes de
  receita de referência). Um item genérico registrado em inglês continua em inglês no histórico depois de trocar o
  idioma. O mesmo vale para o nome "Você" do participante criado automaticamente na comanda (esse exibe no idioma atual
  até ser renomeado).
- Dicas temporárias da tela "Inclinar o copo" não se retraduzem enquanto estão visíveis (somem em segundos).
- O título e a descrição do `index.html`/manifest web e o nome do app são a marca "Bebômetro" nos três idiomas.
- A palavra "UF" foi mantida como rótulo curto do estado nos formulários de local brasileiros (com "State" em inglês).
- Traduções de espanhol/inglês das cartas, receitas e notas são editoriais, escritas sem revisão de falante nativo.
- Leitura de rótulo/cardápio em en/es: palavras-chave acrescentadas, sem teste em fotos reais.

## Como trocar o idioma

Configurações → Idioma: Sistema, Português (Brasil), English, Español. A escolha fica no aparelho e vale antes do login.
