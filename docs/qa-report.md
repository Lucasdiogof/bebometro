# Bebômetro: relatório de QA (rodada de 16 a 17/10/2026)

Checkpoint para outra sessão continuar. Sem senhas, tokens ou dados sensíveis. As credenciais das contas de QA ficam
fora do Git (pasta temporária local da máquina de QA).

## Ambiente
- Emulador Android 17 (API 37) `emulator-5554`, app `com.lucksrei.bebometro`, build **release** instalado por cima (mesma
  chave de debug: sessão e dados preservados). Idioma do aparelho: inglês. Fuso do emulador: UTC (a web mostra UTC-3).
- Web: `flutter build web --release` servido localmente (`build/web`, porta própria por teste para ter armazenamento limpo).
- Contas de QA (domínio `example.com`): **A** `qa.bebometro.a.fc6438` (rolê "QA Bar MELT", 6 bebidas, encerrado) e
  **B** `qa.bebometro.b.50eb5f` (rolê "Bar do B" com 1 água). Nenhuma excluída ainda.
- O projeto Supabase do Bebômetro não é acessível pelas ferramentas desta máquina; a verificação do servidor é feita pelo app
  (uma instalação independente lendo a nuvem com a sessão da própria conta).

## Aprovado (observado em execução)
| Cenário | Evidência |
|---|---|
| analyze (sem erros, 10 avisos de estilo antigos), 42 testes | saída do analyze/test |
| Reconexão após offline (Android) | "Synced", fila vazia, 6 registros mantidos após "Sync now" |
| Recuperação da nuvem em instalação independente (web, 2 origens limpas + emulador) | mesmo rolê, 6 bebidas, 2.200 ml, R$ 85, sem duplicar após 3 leituras |
| Senha incorreta | erro no campo, sem entrar |
| Cadastro da B pela interface | entra direto (sem confirmação) e não vê dados da A |
| Logout e novo login; troca B → A na mesma origem | A só vê o que é dela; B só o que é dela |
| Rolê: Mais uma, Desfazer, água, cortesia (soma R$ 0, sem aviso de "sem preço"), Repetir (mantém cortesia), excluir, encerrar, resumo | contagens e totais conferidos no aparelho |
| Propagação de preço (BEB-001) | oferta "4 iguais com outro preço", escolha "Só este registro" respeitada, Brahma intacta |
| Comanda: incluir bebidas (garrafa pelo total R$ 30; subtotal R$ 105 ≠ meu gasto R$ 85), serviço 5/10/20% (R$ 5,25/10,50/21,00), desligar recalcula | valores na tela |
| Divisão igual entre 3 (R$ 35 cada), por item, valores personalizados ("falta distribuir"), pagamento parcial (35 − 20 = deve 15) | valores na tela |
| Comanda e preço corrigido sincronizam entre dispositivos | web mostrou R$ 105/35 e depois R$ 106/35,34 |
| Compartilhar resumo (Android): seletor do sistema abre, cancelar volta sem erro e sem cópia | tela do aparelho |
| Exportação JSON (Android): seletor abre, cancelar sem erro | tela do aparelho |
| Conflito entre duas sessões (emulador offline edita R$ 17; web edita R$ 16) | após reconectar, o app sozinho mostrou "1 a resolver"; tela de resolução; "usar a nuvem" zerou o conflito |
| Build Android release | após corrigir regras do R8: APK de 100 MB gerado, instalado e aberto com dados |
| Build web release | gerado e executado no navegador |
| Catálogo: busca (sem acento), filtros, favoritar; receita criada com ingrediente sem teor (aceita, aparece no catálogo "Criada por ti") | emulador |
| OCR por galeria com imagem própria (Android release, após correção): nome, 350 ml e 4,8% lidos; item "só desta saída" (não vira consumo, não entra no catálogo global; aparece em "Bebidas desta saída") | emulador |
| Notificação Android: silenciosa, ES, conta só bebida alcoólica, ação "Água" registra 300 ml, some ao encerrar | `dumpsys notification` + tela |
| Jogos: carta em ES, retomada após fechar o app ("Partida em curso") | emulador |
| Relato pós-rolê (humor + "acordou") salvo e sincronizado para a web | emulador + web |
| Histórico e estatísticas coerentes (R$ 86 após a correção, 81,7 g) | emulador (ES) |
| Espanhol + fonte 1,6x + teclado: sem estouro (botões quebram em 2 linhas) | captura do aparelho |
| Exclusão sincronizada: registro apagado no emulador chegou à web | web |
| Web: acompanhamento na tela bloqueada indicado como indisponível no navegador | web |

## Defeitos encontrados e corrigidos
1. **Web: aviso "link expirou" ao abrir o app sem sessão** — o predicado de detecção de callback retornava `true` para qualquer URL.
   Corrigido (`hasAuthCallbackParams`, `fixWebCallbackNoticeAndStaleSnackbar`) com testes.
2. **Aviso "Desfazer" de uma sessão ficava sobre a tela de entrada, cobrindo o botão Entrar** — o `AccessGate` agora limpa os avisos ao
   mudar de sessão.
3. **Avisos com ação nunca sumiam** (Material 3 ignora `duration` com ação) e cobriam botões como "Dividir a conta" — `persist: false`
   nos cinco pontos (`fixUndoSnackbarPersisting`); verificado: some em 5 s.
4. **Build Android release falhava no R8** (classes opcionais do ML Kit) — `android/app/proguard-rules.pro` (`fixAndroidReleaseR8MissingRules`).
5. Texto do cadastro e selo de origem no catálogo (herdados da rodada anterior) publicados.
6. **OCR não funcionava no APK release** (R8 removia classes do ML Kit; mensagem "não foi possível ler o texto", sem causa visível). Regras
   `-keep` em `proguard-rules.pro` e log só em debug no reconhecedor (`fixMlkitOcrKeepRulesInRelease`). Verificado no release.
7. Texto da tela de Jogos ainda dizia "sem conta" (conta é obrigatória) nos três idiomas.

## Observações (sem alteração; decisão de produto)
- A água registrada pelo botão "Água" entra em "Bebidas", soma volume e aparece como "1 sem preço" (regra: desconhecido ≠ zero).
  Se a água deve ficar fora de "sem preço", é decisão de produto.
- O indicador diz "Sync failed" enquanto o aparelho está offline (e não "pendente"); a retentativa automática levou alguns minutos
  após a rede voltar (backoff de 30 s a 5 min). "Sync now" não foi necessário.
- O app web em uma janela de largura variável: validar o layout em telas estreitas no aparelho.

## Reprovado / bloqueado
- **Exclusão de conta (B): falhou na 1ª tentativa e FOI CORRIGIDA e comprovada (17/10).** Causa: o `service_role` do projeto só tinha
  `REFERENCES`, `TRIGGER` e `TRUNCATE` nas tabelas (sem `SELECT/INSERT/UPDATE/DELETE`), então a função não conseguia ler, apagar nem gravar o
  progresso. O responsável concedeu as permissões no SQL Editor; a repetição respondeu 200 `{ok:true}`, o login da B passou a dar
  `invalid_credentials` e a consulta ao banco mostrou 0 linhas, 0 arquivos, 0 usuário de autenticação e `account_deletions = done`, com a A intacta
  (`a_still_there = 1`). A migration com as permissões **ainda não está versionada no repositório** (pendente de autorização). Histórico da falha: A interface mostrou "A exclusão começou mas não terminou. Nada local foi apagado".
  Chamando a função com a sessão da própria B: HTTP 500 `{"error":"partial_failure","retry":true}`. A função **está publicada**
  (sem sessão: 401). As linhas da B continuaram no servidor (1 rolê, 2 registros, 1 local), então parou na etapa 1 (arquivos) ou ao apagar
  `drink_entries`. A causa exata está em `account_deletions.last_error`, que só se lê com acesso ao projeto. A função do repositório agora devolve
  `step` (republicar) e há `supabase/queries/check_account_deletions.sql` para o responsável ler o erro. A A seguiu intacta (3 rolês, 14 registros
  incluindo apagados, 1 item de foto, 1 receita, 1 comanda, 3 locais).
- Recuperação por código de 6 dígitos: bloqueado (sem caixa de e-mail de QA).
- iPhone/Live Activity/compartilhar no iOS, sensor físico do simulador: bloqueado (sem Mac/aparelho).

## Não executado
Locais/mapa (rede e permissão negada), simulador em modo manual na web, rascunho de OCR recuperado após fechar o app, receita incompleta
com aviso de total, importação de CSV (não existe), restauração após exclusão (depende da exclusão funcionar), duas instalações do mesmo
usuário com exclusão de conta.

## Rodada 3 (17/10/2026, a partir de `824afc0`)

### Migration das permissões do `service_role`
- Versionada: `supabase/migrations/20261021000000_service_role_table_grants.sql` (8 tabelas, só `service_role`, sem tocar em `anon`/`authenticated`
  nem em RLS; idempotente). Commit `2e87ca5`.
- **Estado do banco:** o mesmo GRANT foi aplicado à mão no projeto pelo responsável (informado "Success"; efeito comprovado). **Histórico de
  migrations:** a execução manual não registra a migration em `supabase_migrations.schema_migrations`; não se presume que o painel a liste.
- Consulta de conferência, somente leitura e sem dados fixos: `supabase/queries/diagnose_delete_account.sql` (versionada).

### Exclusão de conta pela interface (QA C, Android release, espanhol)
| Passo | Resultado observado |
|---|---|
| Cadastro da C pela interface; dados: rolê, 2 registros (Heineken R$ 12 + água sem preço), comanda com os 2 itens, item de foto lido por OCR salvo "só desta saída" | Aprovado. Antes de excluir, a sessão da própria C via REST mostrou 1 rolê, 2 registros, 1 item, 1 foto, 1 comanda, 1 local e 1 pasta no Storage |
| Identidade conferida na tela de conta (nome e e-mail da C) | Aprovado |
| Confirmação exigida | Sem marcar: "Marca la confirmación para continuar." |
| Senha exigida | Vazia: "Confirma tu contraseña."; errada: "Correo o contraseña incorrectos." (nada excluído) |
| Estado de carregamento e toque duplo | Dois toques seguidos: o botão virou cinza, desabilitado, com indicador de progresso (captura); uma única exclusão |
| Sucesso e retorno | Voltou à tela de acesso, sem erro residual e com o e-mail vazio |
| Reabrir o app (fechar à força) | Continua na tela de acesso |
| Dados da C no aparelho | Não verificável por arquivo (release não depurável); a tela de acesso e o login da A mostram só dados da A |
| **Servidor e Storage da C** | **Aprovado**, lido no banco pelo responsável após a exclusão pela interface: 0 registros, 0 rolês, 0 itens, 0 fotos, 0 comandas, 0 locais, 0 usuário de autenticação, 0 arquivos no Storage, `account_deletions = done attempts=1`, e a A preservada. Diagnóstico por API (não valida a interface): login da C devolve `invalid_credentials`; a A manteve 3 rolês, 14 registros, 1 item, 1 comanda, 1 receita, 3 locais |

### Demais cenários desta rodada
| Cenário | Resultado |
|---|---|
| Locais: busca por endereço (Geoapify, atribuições visíveis); permissão de localização negada (mensagem e busca manual continuam); sem internet ("Sin internet ahora" com "Intentar de nuevo") | Aprovado (emulador) |
| Cálculo incompleto: "Caipirinha" de referência gera "volume desconhecido · álcool incompleto" e o total do rolê "1 con alcohol incompleto" | Aprovado |
| Receita própria sem teor e sem "contém álcool": o registro só acusa volume desconhecido | Observação: coerente com a regra, o aviso de álcool depende de marcar o ingrediente como alcoólico |
| Simulador na web, modo manual ("Arraste para inclinar"): o líquido inclina com o arrasto | Aprovado (navegador) |
| Texto de Jogos corrigido ("funcionam sem internet") já na web | Aprovado |
| Login da A em instalação nova da web e depois no emulador após sair e entrar | Aprovado: mesmos totais, sem duplicar |

### Builds e testes desta rodada
`flutter analyze`: sem erros (10 avisos de estilo antigos). `flutter test`: 42 passaram. `flutter build web --release` (duas vezes) e `flutter build apk --release`/`--debug`: gerados.
O build release foi reinstalado no emulador e usado nos testes acima.

### Contas de QA restantes
**A** (`qa.bebometro.a.fc6438`) mantida. **B** e **C** excluídas (B pela função com a sessão dela; C pela interface).

| Rascunho de OCR recuperado: leitura interpretada, app fechado à força antes de salvar; ao reabrir "Leer etiqueta" a foto e o texto lido voltaram (com "Descartar lectura") | Aprovado (emulador). O aviso "leitura aberta" aparece só ao encerrar o rolê |

### Ainda não executado
Restauração após exclusão (o app não tem esse fluxo de restauração de conta); iPhone, Live Activity e sensor físico (bloqueados); código de 6 dígitos (sem caixa de QA).

## Rodada 4 (17/10/2026, Mac mini, Xcode 27.0, iOS 26.5, a partir de `768a2ef`)

### Ambiente e preparo
- O projeto exige Dart ^3.13.3; os SDKs locais não atendiam (master 3.50-dev traz Dart 3.13.0-dev, fvm ia até 3.44.1). Instalado Flutter **3.47.7**
  (Dart 3.13.5) via fvm e `flutter precache --ios` (sem o precache o `pod install` falha no post-install).
- `pod install` precisa de `LANG=en_US.UTF-8` neste Mac (sem isso o Ruby 4 quebra com `Unicode Normalization not appropriate for ASCII-8BIT`).
- O disco interno chegou a 106 MB livres (ENOSPC até para o shell); liberado apagando `~/Library/Developer/Xcode/DerivedData` (cache).
- `pubspec.lock` não mudou com `pub get`. `flutter analyze`: sem erros, 10 avisos de estilo antigos. `flutter test`: **42 passaram**.

### A. Compilação iOS (aprovado)
| Build | Resultado |
|---|---|
| `flutter build ios --simulator --debug` | Gerado; a extensão `BebometroLiveActivity.appex` (mínimo iOS 16.2) vem embutida. O `project.pbxproj` editado à mão compilou sem correção |
| `xcodebuild` Release, `generic/platform=iOS`, `DEVELOPMENT_TEAM=HALJMW29DC`, `-allowProvisioningUpdates` | **BUILD SUCCEEDED**; instalado e aberto no iPhone 15 Pro real (`devicectl install` + `process launch`) |
| `xcodebuild` Debug, mesmo destino | **BUILD SUCCEEDED** (não foi arquivado pela interface do Xcode) |

### B. Live Activity na tela bloqueada (evidência visual enviada pelo responsável)
- **Plataforma:** iPhone físico, rodada 4. Duas capturas de tela reais enviadas pelo responsável em 17/10/2026; **não** são execução comandada por esta sessão.
- **Passos observáveis:** iniciar rolê; iOS apresenta a pergunta "Permitir Atividades ao Vivo do app Bebômetro?"; após a autorização, o card aparece na tela bloqueada.
- **Esperado / observado:** card com logo, cronômetro e ações "Abrir"/"Água"; visível em 0:11 e novamente em 2:09. O cronômetro progrediu e os textos estão em pt-BR.
- **Sem bebida alcoólica registrada:** botão "Mais uma" ausente, coerente com a regra de só mostrá-lo quando há bebida alcoólica elegível. Isso **não** valida o botão interativo.
- **Observação de layout (pendente):** título truncado "Rolê em andam..." e subtítulo "Nenhum registro de be...". Avaliar possível texto mais curto, prioridade e truncamento em tela bloqueada, sem comprometer legibilidade.
- **Ainda não validado:** tocar "Abrir"/"Água"; Live Activity expandida na Dynamic Island; tocar "Mais uma" em iOS 17+; fila persistente, horário e origem, idempotência, pendências, encerramento e desaparecimento da atividade.

### D. Permissões do iOS (verificação estática do app compilado)
`InfoPlist.strings` de pt-BR, en e es estão no `.app` com câmera, localização, movimento, galeria e salvar na galeria; `CFBundleLocalizations` =
pt-BR, en, es. O iOS escolhe o idioma pelo **sistema**, não pela escolha do app (documentado em `docs/i18n-checklist.md`). Falta ver o diálogo real em
cada idioma do sistema no aparelho.

### Bloqueio: simulador iOS
O build de simulador sai **só x86_64** porque o ML Kit (`GoogleMLKit`, `MLImage`, `MLKitCommon`, `MLKitVision`) não tem slice arm64 de simulador. O
runtime instalado é o iOS 26.5, que exige arm64: `simctl install` recusa o app ("needs to be updated by the developer", `Failed to find matching arch`).
Consequência: **nenhum cenário iOS deste relatório pôde ser exercitado no simulador**; tudo depende do iPhone físico, que a ferramenta de automação
desta sessão não consegue tocar (ela só controla simuladores). Os cenários interativos de B, C, E, F, G e H permanecem **não executados no simulador**; B tem agora evidência visual parcial em iPhone físico, registrada acima.

### B. Live Activity (iPhone 15 Pro real, iOS, pt-BR) — parcial
- Atividade aparece na tela bloqueada (título, cronômetro, "Abrir", "Água"); o iOS pede "Permitir Atividades ao Vivo" na primeira vez.
- Com o rolê **sem bebida**, o botão "Mais uma" não aparece (esperado: `nextLabel` vazio, nada a repetir). Observação de produto: pode confundir.
- Após registrar uma bebida, "Mais uma" apareceu e funcionou (relato do responsável, sem captura). **Não confirmados ainda:** toques rápidos/espaçados sem
  duplicar, horário original do toque, tela de pendentes, textos em en/es, Dynamic Island, remoção ao encerrar.

### Próximo passo exato
1. Com o build Release já instalado no iPhone, executar à mão os roteiros de B (`docs/lock-screen-one-tap.md`), C, E, F, G e H e registrar o resultado aqui.
2. Decidir se vale ter caminho de simulador (ex.: carregar o ML Kit só em dispositivo) para permitir automação no iOS.

## Contas de QA
Mantida: **A** (`qa.bebometro.a.fc6438`). **B excluída** pela função `delete-account` em 17/10 (comprovado no banco).

## Fora do alcance do ambiente
iPhone/Live Activity/compartilhamento iOS, caixa de e-mail de QA (código de 6 dígitos), sensor físico do simulador, acesso admin ao Supabase.

## Próximo passo exato
1. Versionar a migration de permissões do `service_role` (hoje só aplicada à mão no projeto) para novos ambientes.
2. Repetir a exclusão **pela interface** com uma conta nova (esta rodada comprovou o servidor, chamando a função com a sessão da própria conta; a tela já havia mostrado a falha corretamente) e excluir também a A quando o QA terminar.

## Rodada 5 (19/10/2026, Android emulador, build debug)
- **Sem conexão agora aparece como "pendente", não "falhou":** com a rede desligada e um registro novo, o indicador de nuvem passou a **âmbar com seta de envio**
  (antes: vermelho "nuvem cortada"); ao religar a rede voltou sozinho para "sincronizado" (cerca de 90 s, backoff). Só erros de rede entram nesse caso;
  falhas reais do servidor continuam "falhou". Sem nada a enviar, o rótulo é "Sem conexão". Textos pt/en/es (`syncLabelOffline`).
- **Layout corrigido (capturas):** na Home, "57 h 49 min" encostava no número de bebidas ("min2"); no rolê, "300 ml (+2 sem volume)" encostava em "R$ 0,00".
  Folga à direita no `StatTile` e tempo da Home com `FittedBox`.
- Verificado depois da correção no mesmo emulador. `flutter analyze` sem erros/avisos; 42 testes passaram.
- **Live Activity (iOS), observação de truncamento:** título com `minimumScaleFactor(0.7)` e contagem com até 2 linhas na tela bloqueada (`OutingLiveActivity.swift`). **Não compilado nem visto**: depende de reconferência no iPhone.

### Rodada 5, continuação (19/10/2026)
- **Defeito encontrado e corrigido: tela vermelha ao sair da conta pela tela "Minha conta" (build debug).** Passos: entrar, Configurações → Minha conta → Sair →
  Sair. Esperado: voltar à tela de entrada. Observado: erro `'_dependents.isEmpty': is not true` (framework.dart:6281), tela vermelha. Causa (console do
  `flutter run`): `app.dart` removia o provedor do `SyncCubit` ao fechar o escopo da conta enquanto a tela "Minha conta" ainda saía da tela (a transição de saída
  do Android leva cerca de 800 ms) e se reconstruía → `ProviderNotFoundException` e, em seguida, a asserção. Em release a asserção não existe, mas o erro de build
  continuava. Correção: o último `SyncCubit` (já fechado) fica no lugar até a próxima conta entrar, com a mesma chave; e `account_page.dart` não lê o
  armazenamento da conta depois que o escopo fechou. Um primeiro palpite (esperar 450 ms antes de fechar o escopo) **não resolveu** e foi desfeito.
  Verificado no emulador: entrar → sair → entrar de novo, sem exceção no console; água registrada depois.
- **Recuperação por código, parte observável sem e-mail:** "Já tenho um código" + código errado: erro no campo, e a tela de nova senha **não** abre. Não foi pedido
  envio de código (não há caixa de QA). A mensagem de erro aparecia cortada ("…ask for a ne…"); agora admite 2 linhas.
- `flutter analyze`: sem erros/avisos; 42 testes passaram.

### Conferência independente da correção de saída da conta (19/10, `adddc56`, Android release)
Em outro ambiente (emulador Android 17, APK release gerado do `main`): Ajustes → Minha conta → Sair → confirmar levou à tela de entrada sem tela de
erro; entrar de novo trouxe o rolê em andamento e os totais (4 bebidas), sem exceção de provedor no log (os `SIGABRT` repetidos são do processo do
sistema `android.hardwar`). `flutter analyze`: 18 itens, todos `info` de estilo (sem erros nem avisos); 42 testes passando. iPhone continua sem validação.

### Recuperação de senha por código: e-mail real recebido (19/10/2026)
Observado pelo responsável (captura da caixa de entrada, sem o código nem o endereço aqui): o e-mail de recuperação chegou com o assunto
trilíngue "Redefinir senha · Reset password · Restablecer contraseña", remetente "Bebômetro", **código de 6 dígitos** e **nenhum link**, corpo em
português (idioma da conta) e a frase de validade curta. Template e `mailer_otp_length = 6` já estavam aplicados (dry run de 19/10).
Observação de layout: na captura em janela larga o cartão do código aparece deslocado para a direita (não centrado); conferir em outros clientes de e-mail.
**Ainda não observado:** digitar o código no app, definir a nova senha e entrar com ela; e-mail em English e Español.

### Recuperação de senha: fluxo completo concluído (19/10/2026)
Informado pelo responsável após receber o e-mail real: digitou o código de 6 dígitos no app, definiu a nova senha e entrou com ela, **tudo certo**.
Decisão posterior: o e-mail de recuperação passa a ser só em pt-BR e centralizado (`recovery.html` e assunto "Redefinir senha" alterados no
repositório; **aplicados no servidor em 19/10/2026** com `scripts/apply_recovery_code.py --apply` e conferidos por um segundo dry run: "Would change: nothing", template idêntico ao repositório; o script confirmou que SMTP, `site_url`, template de confirmação, `mailer_otp_exp` e `mailer_autoconfirm` não mudaram). Código errado já fora validado em 17/10; código antigo e
e-mail em English e Español deixam de se aplicar (e-mail só em pt-BR).
**Concluído (19/10/2026):** novo código pedido e e-mail conferido pelo responsável ("ta show, tudo pronto"): cartão centralizado, assunto novo, 6 dígitos, sem link. O fluxo de recuperação de senha por código está aprovado.

## Rodada 19/10/2026: mesa, pessoas, resenha, catálogo (web, `flutter run -d web-server`, Chrome embutido, conta de QA do responsável)

Plataforma: **web debug** (Android: emulador não sobe nesta máquina, `WHPX hr=80070005`, não contornado; iOS: sem ambiente). Larguras ~640 px e 360 px. Capturas só ficam na sessão; as medições estão abaixo. Rolê de QA: "Bar QA Mesa" (Você, Ana, "Maria Eduarda Albuquerqu", nome cortado em 24 caracteres pelo limite do campo).

### Aprovado pela interface
| Cenário | Resultado visto |
|---|---|
| Iniciar rolê com pessoa (Ana) | Você e Ana na tela; abas Pedidos / Por pessoa / Conta |
| Pedido de catálogo: "chopp heineken" | Sugestão compacta em uma fileira ("Heineken Lager (chope)"), formulário não é escondido |
| Spritzgerald | Só ele aparece (nem Fitzgerald nem Spritz); "Do catálogo"; sem volume nem teor exigidos |
| Você 4 × Chopp 400 ml R$ 15 | "4 × R$ 15,00 = R$ 60,00"; sugestões de copo 200/300/400/500 ml marcadas como editáveis |
| Ana 2 × Spritzgerald R$ 32 sem volume | Mesa R$ 124, "2 sem volume", consumo da Ana "desconhecido" |
| Batata R$ 60 dividida | Subtotal R$ 184,00; sua parte R$ 90,00 |
| Serviço 10% | R$ 18,40; **total R$ 202,40; Você R$ 99,00; Ana R$ 103,40**; "Divisão completa" |
| Consumo conhecido do Você | 4 bebidas · **1.600 ml**; nenhuma bebida da Ana entra |
| Você paga R$ 202,40 | Bar quitado; Você "pagou R$ 103,40 acima da parcela"; Ana **"Coberto por outro pagamento: o bar está quitado"** (defeito encontrado e corrigido, abaixo); parcelas e consumos intactos |
| Recarregar a página | Rolê, pedidos, serviço, pagamento e partida de jogo preservados; Home mostra só 4 bebidas e R$ 60,00 (as da Ana não entram) |
| "Mais uma para Ana" | 3× Spritzgerald; sua parte continua R$ 99 (defeito encontrado e corrigido, abaixo) |
| Passar para outra pessoa | Os 3 Spritzgerald para Você: sua parte R$ 99 → R$ 204,60, total da mesa igual; **Desfazer** restaurou |
| Excluir um | 3× → 2× (R$ 64,00) |
| Cortesia | "Cortesia", total não muda |
| Preço desconhecido | Total vira "R$ 237,60+" e "1 sem preço" (parcial) |
| Adicionar pessoa depois | Aparece na barra; pedidos anteriores continuam só "Você, Ana" |
| Inglês, 360 px | Botões "Drink / Food / Other item" em uma linha; turno do jogo, textos traduzidos |
| Resenha (Truth or dare) | **Sem pontos** (a seção sumiu); "Ana, read the question" com avatar e "Your turn to read"; "Answers: You · Truth"; Next gira o leitor ("You, read the question" / "Ana's turn"); Pass the turn e Change reader; "People from the outing" importa por escolha; **retomada após recarregar** mantém leitor, vez e 23 cartas |

### Defeitos encontrados e corrigidos (commits na main)
1. **Bar quitado por outra pessoa, mas a Ana aparecia com "falta pagar R$ 103,40"** (aba Por pessoa, tela Dividir conta e texto compartilhado): agora "coberto por outro pagamento". `showCoveredShareWhenVenueSettled`.
2. **"Mais uma para Ana" não fazia nada quando havia comida mais recente que a bebida** (`TableOrders.rows(...).first` pegava a linha da comida): `TableOrders.rowOfEntry`; teste `table_calc_test.dart` "repeat button targets the drink". `fixRepeatButtonPickedLaterDish`.
3. Em inglês, "You's turn" (Resenha): agora "Turn: You" / "Turno: …".
4. "Entered spen…" cortado na Home a 360 px: rótulo do `StatTile` encolhe em vez de cortar. "Valor pago ao estabele…" no diálogo de pagamento: rótulos curtos (pt/en/es).
(2, 3 e 4 corrigidos no código e cobertos por teste ou análise; **4 não foi revisto na tela depois da correção**.)

### Não verificado pela interface
- Desfazer da **exclusão** (o snackbar expirou antes do toque; o toque seguinte abriu "Outro item"). Desfazer de "passar para outra pessoa" foi verificado.
- Fonte ampliada do sistema (o painel do navegador não altera a escala de texto), espanhol na tela (só inglês e português vistos), teclado, nomes longos além do limite de 24 caracteres do campo.
- Offline (criar sem rede, fechar, reabrir, reconectar), segunda instalação/conta, conflito de mesma comanda, comando da tela bloqueada, exclusão de conta: **não executados**.
- Android e iOS: bloqueados (emulador/Mac).

### Sincronização observada (servidor, consulta ao banco, projeto `jiisoqkryhmtopaojyyu`)
- Migration `20261022000000` aplicada e verificada (colunas, constraints, gatilho; reaplicada sem erro).
- Rolê "Bar QA Mesa": 4 Chopp do Você (sem consumidor, 400 ml, R$ 15), Spritzgerald da Ana com `consumer_id`, volume nulo preservado, preço R$ 32; a exclusão chegou como **tombstone** (`deleted_at`); mover para Você e voltar terminou com a Ana como consumidora.
- Comanda `outing_tabs`: `schema_version` 2, `auto_link` verdadeiro, serviço ligado, pessoas, itens (Batata, Couvert cortesia, Sobremesa sem preço) e 1 pagamento de R$ 202,40.

### Complemento (19/10/2026, mesma sessão web, build com as correções)
Aprovado pela interface depois das correções:
- **Rótulo "Entered spending" a 360 px** aparece inteiro (escala em vez de cortar).
- **Espanhol a 360 px:** "Bebida / Comida / Otro ítem" em uma linha, "Uno más para Ana", "Eliminar uno", "Registro eliminado / Deshacer".
- **Desfazer da exclusão:** 2× Spritzgerald → "Eliminar uno" → 1× → Desfazer → 2× (R$ 64,00).
- **Offline → reabrir → reconectar** (rede do Supabase bloqueada por script na página, não é teste de aparelho): "Uno más para Ana" criou o 3º Spritzgerald **só no aparelho**, o ícone de nuvem foi para "pendente de envio" e o servidor continuou com 2 vivas; depois de recarregar a página (app fechado e reaberto, sem o bloqueio) o servidor passou a ter **3 vivas, 4 linhas e 4 ids distintos**: uma linha nova, nenhuma duplicada.

Continuam **não executados**: segunda instalação/conta (exige digitar senha numa instalação nova, que a sessão não faz), conflito de mesma comanda entre dois aparelhos, fonte ampliada do sistema, comando da tela bloqueada (só Android/iOS), Android e iOS.

## Fechamento da entrega (19/10/2026)

### Correções de clareza e layout
- **Contagens:** o resumo "Pedidos 9" somava registros de bebida e itens extras (unidades), enquanto "5 PEDIDOS" na lista contava **linhas agrupadas** ("4× Chopp" é uma linha e quatro itens). Eram métricas diferentes com o mesmo nome. Agora o resumo da mesa se chama **"Itens"** (pt) / **"Items"** / **"Ítems"** e soma unidades (bebidas vivas + quantidade de cada extra, via `TableOrders.itemCount`); a lista continua "N pedidos" (linhas). Com uma pessoa selecionada o resumo mostra **"Bebidas"** daquela pessoa e a lista, as linhas dela (o mesmo filtro nos dois). Visto na tela: "Ítems 10" com "5 PEDIDOS". Testes: `itemCount` (4 chopp + 2 spritz + 1 prato = 7 itens, 3 linhas; registro excluído não conta; prato com quantidade 3 vale 3).
- **Área inferior (360 px, espanhol):** rolando até o fim, o último pedido ("4× Chopp") e "Terminar salida" ficam **inteiros acima** da barra fixa; a barra (destinatário em "Uno más para Ana" e Bebida/Comida/Otro ítem) é um filho da coluna abaixo da lista rolável, não uma sobreposição. **Teclado:** esta tela não tem campo de texto (os campos ficam em folhas e diálogos que tratam o teclado por conta própria); o teclado virtual não pôde ser exercitado no navegador (só em aparelho).
- **Fonte ampliada (teste automatizado, não é validação em aparelho):** `test/table_text_scale_test.dart` monta barra de pessoas, pedidos, pessoas e conta a **360 px** com `TextScaler` 1,0 / 1,3 / 2,0 nos três idiomas e com nome de 42 caracteres, e falha em qualquer overflow. A 2,0 havia dois estouros (preço na linha do pedido e valor das linhas da conta, ~11 e ~36 px): agora o texto **quebra em duas linhas** (sem reduzir a fonte) e os 9 testes passam. Os botões inferiores de Bebida/Comida/Outro item e a faixa "Uno más" continuam com rótulo que encolhe (já era assim) e **não** estão cobertos por teste de widget (são privados da tela do rolê).

### Cenário principal: evidência na interface (web, 360 px, espanhol)
Aba **Cuenta** com o rolê no estado do cenário (3º Spritzgerald e sobremesa removidos): **Subtotal 184,00; Servicio 10% 18,40; Total 202,40; Tu parte 99,00; Pagado al local 202,40; "Local saldado"**. Antes, na tela Dividir e em Por pessoa: Você 99,00 (1.600 ml, 4 bebidas), Ana 103,40 (2 bebidas, volume desconhecido; "coberto por outro pagamento"). Registrar o pagamento não alterou consumos nem parcelas. Tudo isso tem evidência; nada precisou ser repetido além da aba Cuenta.

### Alcance da evidência offline (correção)
- **Teste anterior (sessão anterior desta rodada):** o bloqueio de rede foi um patch em JavaScript injetado na página; **o reload o removeu**. Portanto aquele teste comprova: criação offline com indicador de pendência, e sincronização **depois de recarregar já com conexão**, sem duplicar. **Não** comprova reabertura ainda offline, e recarregar a página **não equivale** a encerrar um processo Android/iOS.
- **Teste novo, com o bloqueio mantido através do reload** (trecho temporário no `index.html` lido de uma flag do `localStorage`, não commitado, desfeito com `git checkout`): app **aberto offline** com a sessão restaurada; "Uno más para Ana" criou o 3º Spritzgerald local (Ítems 9, total 237,60, ícone de pendência); servidor continuou com 2 vivas; **reload ainda bloqueado**: o pedido continua na tela, com pendência; flag removida e novo reload: servidor com **3 vivas, 5 linhas, 5 ids distintos** (exatamente uma linha nova). É uma simulação na web (o navegador embutido não registra service workers); não substitui o teste em aparelho.

### Checklist (separado por tipo de prova)
**Aprovado na web (interface):** cenário do casal completo e conta quitada; chopp/Spritzgerald/catálogo; repetir; mover com Desfazer; excluir com Desfazer; cortesia; preço desconhecido; pessoa depois; inglês e espanhol a 360 px; Resenha sem pontos com leitor e retomada; offline: criar, reabrir offline, reconectar sem duplicar (simulado); servidor conferido por consulta ao banco.

**Aprovado por teste automatizado:** 111 testes (cenários A-E do plano no domínio, migração de fixture antiga lida/salva/relida, busca chop/Spritzgerald/Fitzgerald, sessão de jogo antiga com pontos, `itemCount`, botão de repetir com prato mais novo, layout a 360 px com fonte 1,0/1,3/2,0 × pt/en/es); `flutter analyze` sem erros; `flutter build web --release` OK.

**Pendente em Android/iOS:** emulador Android não sobe (WHPX negado; não contornado); iOS sem ambiente. Inclui teclado virtual, fonte do sistema real, processo encerrado e reaberto, comando da tela bloqueada (um toque e fila de pendentes), Live Activity.

**Pendente em segunda instalação e conflito entre aparelhos:** segunda instalação/conta (precisa de um login manual numa instalação limpa) e a mesma comanda editada em dois aparelhos. Nada disso foi executado.
