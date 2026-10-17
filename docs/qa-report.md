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
