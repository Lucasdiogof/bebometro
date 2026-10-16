# "Mais uma" na tela bloqueada com um toque (BEB-004) e compartilhamento (BEB-007): validação no iPhone

**Nada disto foi compilado nem executado** (sem Xcode, sem iPhone, sem `flutter build` nesta rodada). O que segue descreve o que o código faz,
o que depende do iOS e o roteiro para validar em aparelho.

## O que foi feito
- **iOS 17+:** o chip "Mais uma" da Live Activity (tela bloqueada e Dynamic Island expandida) virou um **botão de verdade** (`AnotherDrinkIntent`,
  um `LiveActivityIntent`, em `ios/BebometroLiveActivity/AnotherDrinkIntent.swift`). Um toque não abre o app e não pergunta nada.
  - O sistema roda `perform()` no processo do **app** (não da extensão), possivelmente em segundo plano. Ele só **enfileira** um comando
    (`UserDefaults`, chave `tracking.commands`, id único por toque) e atualiza a própria Live Activity com um aviso discreto **"✓ +N"** ao lado da contagem.
  - O Flutter lê a fila (`peekCommands`) ao abrir/voltar ao primeiro plano, ao iniciar a conta e quando o nativo avisa (`commandsAvailable`). Para cada
    comando, `TrackingCoordinator.processCommands()` repete a última bebida alcoólica do rolê **como foi registrada** (mesma composição, porção/"Sua parte",
    origem do teor e preço), com o horário do toque, e só então confirma (`ackCommands`). Preço, teor e bebida nunca vêm do comando.
  - **Idempotência:** o id do registro é derivado do id do comando (`DrinkRepository.entryIdForCommand`, UUID v5): reprocessar o mesmo comando regrava a mesma
    linha. Dois toques são dois comandos (ids diferentes) e viram dois registros.
  - Comando de rolê encerrado, sem bebida para repetir, ou desconhecido é descartado; comando de rolê que esta conta não tem fica até 24 h (pode ser de outra conta).
  - O registro cai na fila de sincronização normal (funciona offline).
- **iOS 16.2 a 16.x:** o botão continua sendo um **link** que abre o app; a diferença é que agora o app **registra direto**, sem o diálogo "Pedido da tela bloqueada",
  e mostra o aviso com "Desfazer". "Água" segue o mesmo caminho.
- Projeto Xcode: `AnotherDrinkIntent.swift` entrou nos dois alvos (app e extensão) em `project.pbxproj`; `OutingActivityAttributes.ContentState` ganhou
  `quickLogged: Int?` (opcional, compatível com atividades já em andamento).

## Limitações reais (não resolvidas por código)
- Botão interativo exige **iOS 17**. Abaixo disso o app precisa abrir.
- Se o iOS iniciar o app só para executar o intent, **o Dart pode não estar rodando**: o registro (e os totais corretos) só entram quando o app roda de novo. Até lá,
  o "✓ +N" é a confirmação. Quando o Dart roda, o estado real da atividade substitui o "✓ +N".
- Live Activity só é *iniciada* com o app em primeiro plano (já era assim); o botão só existe com ela ativa.
- `perform()` não tem confirmação do registro final: se o comando for descartado (rolê encerrado), o "✓ +N" some na próxima atualização real.

## Roteiro de validação no iPhone (iOS 17+)
1. Compilar no Xcode (alvos Runner e BebometroLiveActivity). Esperado: sem erro de `AppIntents`/`LiveActivityIntent`; se o compilador reclamar de
   `static let title`/`isDiscoverable`, ajustar a assinatura conforme o SDK.
2. Ligar o acompanhamento na tela bloqueada, iniciar um rolê, registrar uma bebida alcoólica com preço (ex.: chope R$ 10).
3. Bloquear o aparelho, tocar **Mais uma**. Esperado: nada abre; aparece "✓ +1"; ao desbloquear e abrir o app, o rolê tem +1 registro igual (mesmo preço) e a contagem da atividade é a real.
4. Repetir 3 toques seguidos (rápidos e espaçados): esperado 3 registros (nenhum perdido, nenhum duplicado).
5. Modo avião: repetir 3 e conferir que o registro entra e sincroniza depois.
6. Matar o app (deslizar para cima), bloquear, tocar **Mais uma**: anotar se o "✓ +1" aparece e se o registro entra ao abrir o app.
7. Encerrar o rolê, tocar um botão velho (se ainda visível): esperado nenhum registro novo.
8. iPhone com iOS 16.2–16.x (se houver): o toque abre o app e registra com "Desfazer", sem diálogo.
Logs úteis: Console do aparelho filtrando `bebometro`/`tracking`; no Xcode, `[tracking]` em debug.

## Compartilhar resumo (BEB-006/007)
O erro da captura de tela não mostra mensagem, então a causa **não foi reproduzida**. O que o código tinha de frágil e foi tratado:
captura da imagem sem `catch` (qualquer falha escapava sem mensagem), `ShareResultStatus.unavailable` tratado como sucesso (nenhum aviso, nenhum texto copiado), nome de
arquivo com acento (`rolê`) virando caminho temporário. Agora: a captura nunca lança; sem imagem, ou com a folha de compartilhamento indisponível/falhando, o texto do resumo é copiado e a mensagem diz o
que aconteceu (imagem x compartilhamento); o arquivo é `bebometro-role.png` com `fileNameOverrides`. A causa real, se continuar, fica em `ShareService.lastFailure`
(visível no log de debug como `[share] ... failed`).
Validar: tocar **Compartilhar** no resumo com o switch do nome ligado e desligado, com o local sem conexão, e com o texto grande (Ajustes > Tamanho do texto). Se ainda falhar, enviar a linha `[share]` do log.
