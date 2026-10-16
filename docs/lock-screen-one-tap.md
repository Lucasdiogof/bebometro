# "Mais uma" na tela bloqueada com um toque (BEB-004) e compartilhamento (BEB-007): validação no iPhone

**Nada disto foi compilado nem executado** (sem Xcode, sem iPhone, sem `flutter build` nesta rodada). O que segue descreve o que o código faz,
o que depende do iOS e o roteiro para validar em aparelho.

## O que foi feito
- **iOS 17+:** o chip "Mais uma" da Live Activity (tela bloqueada e Dynamic Island expandida) virou um **botão de verdade** (`AnotherDrinkIntent`,
  um `LiveActivityIntent`, em `ios/BebometroLiveActivity/AnotherDrinkIntent.swift`). Um toque não abre o app e não pergunta nada.
  - O sistema roda `perform()` no processo do **app** (não da extensão), possivelmente em segundo plano. Ele só **enfileira** um comando
    (`UserDefaults`, chave `tracking.commands`) com, **no momento do toque**: id único, conta (`accountId`), rolê, horário real e o registro que o botão
    mostrava (`entryId` + `label`), lidos do estado da própria atividade (o Flutter publica `repeatEntryId` e `accountId` em cada atualização). A fila não
    tem limite nem descarte: só a confirmação do Flutter remove um comando. A atividade mostra **"+N aguardando registro"** (pt/en/es, texto enviado pelo app):
    comando recebido, **não** registro salvo.
  - O Flutter lê a fila (`peekCommands`) ao abrir/voltar ao primeiro plano, ao iniciar a conta e quando o nativo avisa (`commandsAvailable`). Para cada
    comando, `TrackingCoordinator.processCommands()` repete **o registro gravado no comando** (não a última bebida no momento do processamento), com a mesma
    composição, porção/"Sua parte", origem do teor e preço, **no horário do toque** (nunca o da abertura do app), e só então confirma (`ackCommands`).
  - **Idempotência:** o id do registro é derivado do id do comando (`DrinkRepository.entryIdForCommand`, UUID v5): reprocessar o mesmo comando regrava a mesma
    linha. Dois toques são dois comandos (ids diferentes) e viram dois registros.
  - Se o registro já existe (inclusive se a pessoa apagou depois), o comando só é confirmado: nada é gravado de novo.
  - **Incompatibilidade nunca vira registro no lugar errado nem descarte:** conta diferente da aberta, rolê que esta conta não tem, comando sem `entryId`
    (feito por versão anterior), registro de origem ausente ou de outro rolê, horário antes do início/depois do fim do rolê (ou mais de 5 min no futuro) ou tipo
    desconhecido → o comando **fica na fila**, sem confirmação, contado em `TrackingCoordinator.unresolvedCommands` e mostrado na atividade daquele rolê como
    "+N aguardando registro". Um toque feito com o rolê aberto entra mesmo que o rolê tenha sido encerrado antes do processamento.
  - Resolução pela tela **"Registros pendentes"** (ver seção abaixo, 16/10/2026).
  - O registro cai na fila de sincronização normal (funciona offline).
- **iOS 16.2 a 16.x:** o botão continua sendo um **link** que abre o app; a diferença é que agora o app **registra direto**, sem o diálogo "Pedido da tela bloqueada",
  e mostra o aviso com "Desfazer". "Água" segue o mesmo caminho.
- Projeto Xcode: `AnotherDrinkIntent.swift` entrou nos dois alvos (app e extensão) em `project.pbxproj`; `OutingActivityAttributes.ContentState` ganhou
  `quickLogged: Int?` (opcional, compatível com atividades já em andamento).

## Limitações reais (não resolvidas por código)
- Botão interativo exige **iOS 17**. Abaixo disso o app precisa abrir.
- Se o iOS iniciar o app só para executar o intent, **o Dart pode não estar rodando**: o registro (e os totais corretos) só entram quando o app roda de novo. Até lá,
  a atividade mostra "+N aguardando registro" (recebido, não salvo). A fila e esse contador estão em armazenamento durável (`UserDefaults` e estado da atividade) e
  sobrevivem ao encerramento do processo; quando o Dart roda, salva, confirma e substitui o estado pelos totais reais.
- Live Activity só é *iniciada* com o app em primeiro plano (já era assim); o botão só existe com ela ativa.
- `perform()` não sabe se o registro será salvo; por isso o aviso diz "aguardando registro", nunca "registrado".

## Roteiro de validação no iPhone (iOS 17+)
1. Compilar no Xcode (alvos Runner e BebometroLiveActivity). Esperado: sem erro de `AppIntents`/`LiveActivityIntent`; se o compilador reclamar de
   `static let title`/`isDiscoverable`, ajustar a assinatura conforme o SDK.
2. Ligar o acompanhamento na tela bloqueada, iniciar um rolê, registrar uma bebida alcoólica com preço (ex.: chope R$ 10).
3. Bloquear o aparelho, tocar **Mais uma**. Esperado: nada abre; aparece "+1 aguardando registro"; ao desbloquear e abrir o app, o rolê tem +1 registro igual (mesmo preço) e a contagem da atividade é a real.
4. Repetir 3 toques seguidos (rápidos e espaçados): esperado 3 registros (nenhum perdido, nenhum duplicado).
5. Modo avião: repetir 3 e conferir que o registro entra e sincroniza depois.
6. Matar o app (deslizar para cima), bloquear, tocar **Mais uma**: anotar se o "+1 aguardando registro" aparece e se o registro entra ao abrir o app, com o horário do toque.
7. Registrar outra bebida depois de tocar e antes de abrir o app: esperado que o toque repita a bebida que o botão mostrava, não a nova.
8. Sair da conta, entrar em outra e abrir o app com um comando antigo na fila: esperado nenhum registro na outra conta; o comando continua pendente.
9. iPhone com iOS 16.2–16.x (se houver): o toque abre o app e registra com "Desfazer", sem diálogo.
Logs úteis: Console do aparelho filtrando `bebometro`/`tracking`; no Xcode, `[tracking]` em debug.

## Compartilhar resumo (BEB-006/007)
O erro da captura de tela não mostra mensagem, então a causa **não foi reproduzida**. O que o código tinha de frágil e foi tratado:
captura da imagem sem `catch` (qualquer falha escapava sem mensagem), `ShareResultStatus.unavailable` tratado como sucesso (nenhum aviso, nenhum texto copiado), nome de
arquivo com acento (`rolê`) virando caminho temporário. Agora: a captura nunca lança; sem imagem, ou com a folha de compartilhamento indisponível/falhando, a mensagem diz o
que aconteceu (imagem x compartilhamento) e oferece **"Copiar texto"**: nada vai para a área de transferência sem esse toque (a cópia automática foi removida em 16/10/2026,
também na exportação). Fechar a folha sem compartilhar não é erro; o arquivo é `bebometro-role.png` com `fileNameOverrides`. A causa real, se continuar, fica em `ShareService.lastFailure`
(visível no log de debug como `[share] ... failed`).
Validar: tocar **Compartilhar** no resumo com o switch do nome ligado e desligado, com o local sem conexão, e com o texto grande (Ajustes > Tamanho do texto). Se ainda falhar, enviar a linha `[share]` do log.

## Registros pendentes (16/10/2026) — implementado, **não validado em aparelho**
- **Quando registra sozinho:** comando desta conta, rolê **em andamento**, registro de origem presente no mesmo rolê e horário do toque dentro do período.
  Qualquer outro caso vira pendência com motivo (`PendingReason`):
  - `outingEnded`: rolê encerrado antes do registro (antes entrava sozinho; agora exige ação explícita).
  - `outsidePeriod`: horário do toque fora do período do rolê.
  - `missingDrink`: comando de versão antiga (sem `entryId`) ou registro de origem que não existe mais nesse rolê.
  - `saveFailed`: a gravação falhou; uma falha não interrompe os demais comandos.
  - `unsupported`: tipo de comando desconhecido.
  - `inReview`: aberto num formulário de revisão agora.
- **Outra conta / rolê que esta conta não tem:** fica na fila, **não aparece nem conta** nesta conta.
- **Acesso:** card discreto na Home ("N toques da tela bloqueada aguardam você"), só quando há pendências da conta atual; nada abre sozinho.
  A tela `PendingCommandsPage` mostra bebida, local (apelido/nome do lugar ou data do rolê), horário original do toque e motivo, sem IDs.
- **Ações:**
  - "Tentar novamente" (`saveFailed`) roda o mesmo processamento idempotente.
  - "Revisar e adicionar" (encerrado, fora do período, falha) abre o **formulário normal** já preenchido com o registro de origem, no rolê original e no
    horário do toque. O formulário só aceita horário dentro do período do rolê (validação já existente); o horário original aparece no topo
    ("Toque original na tela bloqueada: …"). O rolê nunca é reaberto nem tem o período alterado.
  - "Escolher bebida" (`missingDrink`) lista as bebidas alcoólicas distintas daquele rolê e abre a mesma revisão.
  - "Descartar" pede confirmação e só remove o comando da fila: **nunca apaga um registro** já salvo.
- **Consistência:**
  - A revisão salva com o mesmo id derivado do comando (`entryIdFor`).
  - O comando só é confirmado depois que o registro existe no disco (`acknowledgeSaved`).
  - Enquanto a revisão está aberta o processamento automático pula aquele comando (`beginReview`/`endReview`); mesmo numa corrida, o id é o mesmo, então
    não há dois registros.
  - Todas as operações da fila rodam em série (`_serial`).
  - Lista e contador da Live Activity ("+N aguardando registro") são recalculados depois de registrar ou descartar.
- **Validar no iPhone:** (a) tocar com o rolê aberto, encerrar o rolê antes de abrir o app → card na Home, "Revisar e adicionar" registra no horário do toque;
  (b) apagar a bebida de origem antes de abrir o app → "Escolher bebida"; (c) descartar → some da lista e do selo, nada apagado; (d) trocar de conta → a
  pendência da outra conta não aparece; (e) matar o app durante a revisão → ao voltar, a pendência continua e não há registro duplicado.
