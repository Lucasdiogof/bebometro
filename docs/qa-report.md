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
| analyze (sem erros), 42 testes | saída do analyze/test |
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

## Defeitos encontrados e corrigidos
1. **Web: aviso "link expirou" ao abrir o app sem sessão** — o predicado de detecção de callback retornava `true` para qualquer URL.
   Corrigido (`hasAuthCallbackParams`, `fixWebCallbackNoticeAndStaleSnackbar`) com testes.
2. **Aviso "Desfazer" de uma sessão ficava sobre a tela de entrada, cobrindo o botão Entrar** — o `AccessGate` agora limpa os avisos ao
   mudar de sessão.
3. **Avisos com ação nunca sumiam** (Material 3 ignora `duration` com ação) e cobriam botões como "Dividir a conta" — `persist: false`
   nos cinco pontos (`fixUndoSnackbarPersisting`); verificado: some em 5 s.
4. **Build Android release falhava no R8** (classes opcionais do ML Kit) — `android/app/proguard-rules.pro` (`fixAndroidReleaseR8MissingRules`).
5. Texto do cadastro e selo de origem no catálogo (herdados da rodada anterior) publicados.

## Observações (sem alteração; decisão de produto)
- A água registrada pelo botão "Água" entra em "Bebidas", soma volume e aparece como "1 sem preço" (regra: desconhecido ≠ zero).
  Se a água deve ficar fora de "sem preço", é decisão de produto.
- O indicador diz "Sync failed" enquanto o aparelho está offline (e não "pendente"); a retentativa automática levou alguns minutos
  após a rede voltar (backoff de 30 s a 5 min). "Sync now" não foi necessário.
- O app web em uma janela de largura variável: validar o layout em telas estreitas no aparelho.

## Não executado ainda
Catálogo/receitas/OCR na interface, rascunhos, fonte ampliada, EN/ES na interface, histórico/estatísticas, locais/mapa, jogos, simulador,
notificação Android e ações, exclusão e restauração sincronizadas, duas instalações do mesmo usuário com exclusão, exclusão da conta de QA.

## Fora do alcance do ambiente
iPhone/Live Activity/compartilhamento iOS, caixa de e-mail de QA (código de 6 dígitos), sensor físico do simulador, acesso admin ao Supabase.
