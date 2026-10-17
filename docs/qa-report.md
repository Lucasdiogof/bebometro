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
- **Exclusão de conta (B, pela interface web): FALHOU.** A interface mostrou "A exclusão começou mas não terminou. Nada local foi apagado".
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

## Contas de QA
Mantidas: **A** e **B** (a exclusão da B falhou). Nenhuma foi excluída.

## Fora do alcance do ambiente
iPhone/Live Activity/compartilhamento iOS, caixa de e-mail de QA (código de 6 dígitos), sensor físico do simulador, acesso admin ao Supabase.

## Próximo passo exato
1. Responsável: rodar `supabase/queries/check_account_deletions.sql`, corrigir a etapa e republicar `delete-account`.
2. Repetir a exclusão da conta B pela interface (senha da B no cofre de QA local) e conferir que a A permanece.
