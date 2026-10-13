# Internacionalização (pt-BR, en, es): checklist

Rodada iniciada em 13/10/2026. Retome por aqui se o contexto for compactado.
Estados: **Pendente**, **Feito no código** (escrito, não compilado nem executado), **Bloqueado** (motivo).

## Decisões

- Mecanismo oficial: `flutter_localizations` + `gen-l10n` (`l10n.yaml`), ARB em `lib/l10n/app_{pt,en,es}.arb`,
  código gerado e versionado em `lib/l10n/generated/`. `pt` é o template e o fallback final.
- Acesso: `tr.chave` (`lib/l10n/l10n.dart`), lido na hora de montar o texto. Nenhuma frase traduzida vira dado
  persistido; códigos de enum, IDs e valores salvos não mudam.
- Idioma: preferência do aparelho (`DeviceStore`, chave `app.language`): sistema, pt-BR, en, es. "Sistema" segue o
  telefone quando é pt/en/es; outros idiomas → pt-BR. Troca sem reiniciar: `LocaleController` troca `tr` e o app
  reconstrói todos os elementos mantendo o estado (formulários, rolê, partida).
- Formatos por idioma (`formatters.dart`); dinheiro sempre em reais (BRL), em centavos. Parser numérico único que
  recusa entrada ambígua ("1.500") pedindo correção no campo.
- Catálogo, receitas e cartas: traduções editoriais dentro dos próprios JSON (`i18n`), IDs intactos; marcas e nomes
  comerciais preservados; texto do usuário nunca é traduzido.
- Superfícies nativas: o Flutter manda os textos já no idioma escolhido junto com o estado do rolê (iOS ContentState,
  Android extras); descrições de permissão do iOS em `InfoPlist.strings` por idioma.

## Blocos

| # | Bloco | Estado |
|---|-------|--------|
| 0 | Base: gen-l10n, `tr`, `LocaleController`, seletor em Configurações, formatadores, parser | Em andamento |
| 1 | Conta: login, cadastro, e-mail, senha, dados antigos, recuperação, conflitos, Minha conta | Pendente |
| 2 | Home, navegação, rolê (iniciar/editar/encerrar), orçamento, feedback | Pendente |
| 3 | Bebidas: catálogo, filtros, formulário, "Mais uma", receitas, minhas bebidas | Pendente |
| 4 | Locais, busca e mapa | Pendente |
| 5 | Foto: OCR, rótulo, cardápio, bebidas do rolê | Pendente |
| 6 | Comanda: itens, serviço, desconto, divisão, pagamentos, compartilhar | Pendente |
| 7 | Histórico, estatísticas, mesa, simulador | Pendente |
| 8 | Jogos (telas + 134 cartas) | Pendente |
| 9 | Compartilhar, exportar, tela bloqueada (Flutter), sync | Pendente |
| 10 | Conteúdo: catálogo e receitas (JSON) + busca nos 3 idiomas | Pendente |
| 11 | Nativo: Live Activity, notificação Android, InfoPlist.strings | Pendente |
| 12 | E-mails de autenticação (templates/limites) + guia único de configuração | Pendente |
| 13 | Geração (`flutter gen-l10n`) | Pendente |
| 14 | Documentação (HANDOFF, progresso, READMEs, product-checklist) | Pendente |
