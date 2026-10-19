# Auditoria funcional do app (19/10/2026)

Feita por **leitura de código, rotas e documentos** (quatro leituras independentes, com as afirmações conflitantes conferidas à mão no código), não pelo que
o HANDOFF diz. Separa **falta de implementação** de **falta de validação em aparelho**.

Estados: **Implementada** · **Parcial** · **Não implementada** · **Implementada, sem validação em aparelho** · **Fora do escopo**.
"Validação em aparelho" = Android/iOS reais. Só a web foi exercitada pela interface (ver `docs/qa-report.md`).

| Funcionalidade | O que o usuário consegue fazer hoje | O que falta implementar | Estado |
|---|---|---|---|
| Cadastro e login | Criar conta (nome, e-mail, senha, confirmação) e entrar; sair em Minha conta (avisa pendências) | Troca de e-mail; **links de termos e privacidade: bloqueado por dependência externa** (não existe página do Bebômetro; ver "Termos e privacidade" abaixo) | Parcial |
| Recuperação de senha | Pedir o código de 6 dígitos, digitar e-mail + código, nova senha, reenviar com espera, erros claros | — | Implementada (fluxo real aprovado pelo dono em 19/10) |
| Alterar senha | Em Minha conta; se o projeto exige código por e-mail, **ele agora é enviado sozinho** no primeiro erro (antes era preciso achar "Reenviar") | — | Implementada, sem validação em aparelho |
| Perfil | Editar o nome | E-mail, foto; o nome só vive em `user_metadata` | Parcial |
| Exclusão de conta | Senha + confirmação; função `delete-account` (exclusão comprovada no banco em 17/10) | Botão de exportar dentro da tela (hoje só texto) | Implementada |
| Iniciar rolê | Tipo, local (busca, mapa, apelido, endereço), horário, pessoas na mesa, orçamento; aviso ao voltar com campos preenchidos | — | Implementada |
| Editar rolê | **Novo:** trocar tipo e horário de início (validado: não no futuro, não depois do fim nem do primeiro registro); corrigir local; orçamento | — | Implementada |
| Encerrar rolê | Horário ajustável, resumo, relato pós-rolê | — | Implementada |
| Excluir rolê | Exclusão com confirmação (rolê e registros viram tombstones sincronizados) e **Desfazer por 10 s** (ver "Desfazer exclusão de rolê" abaixo) | — | Implementada, sem validação em aparelho |
| Consultar rolê / resumo | Consumo e gasto **seus** (rotulados), pessoas e conta (parcela, pago, bebidas), registros da mesa com o dono de cada um, comanda, fotos, "esqueci uma bebida" (pergunta quem) | — | Implementada |
| Pessoas e atribuição | Adicionar/renomear/marcar que saiu/remover (bloqueia se há vínculos); filtro Mesa/Você/convidado; "Todos" grava quem estava presente | — | Implementada |
| Bebidas individuais | Novo pedido por pessoa e quantidade; "Mais uma para X" (mantém a pessoa); passar para outra pessoa; excluir; Desfazer; aviso ao sair com dados | — | Implementada |
| Bebidas compartilhadas | Criar garrafa/jarra com porção por pessoa (Novo pedido); corrigir as porções depois (em branco = desconhecido); **Novo:** adicionar/tirar pessoas da garrafa já registrada, com volume e divisão do valor independentes, resolução explícita ao tirar e prévia do impacto antes de salvar; garrafa só de convidados segue editável | — | Implementada (testes automatizados; sem validação em aparelho) |
| Comida, extras, preços | Nome livre, quantidade, preço unitário ou total (rótulo explícito), cortesia ≠ não sei, quem divide | — | Implementada |
| Comanda, serviço, desconto, divisão, pagamentos | Serviço 5/10/20%/livre, desconto, divisão igual/por item/valores, pagamentos (quem pagou ≠ quem consumiu), "coberto por outro pagamento", compartilhar prévia | Cobrança/Pix | Implementada (cobrança é Fora do escopo) |
| Catálogo, busca, favoritos, recentes | 306 produtos (+13 atalhos genéricos), busca com acento e chop/chopp/chope, filtros, favoritos, recentes, "adicionar 'texto' neste rolê" | Dados completos dos itens novos (a maioria só tem nome: teor/volume/ingredientes desconhecidos por desenho) | Implementada |
| Bebidas próprias e receitas | Criar/editar/duplicar/excluir bebida própria; editor de receita; registrar a partir de Minhas bebidas (pergunta quem) | — | Implementada, sem validação em aparelho |
| Fotos, OCR de rótulo e cardápio | Ler rótulo/cardápio (ML Kit, Android/iOS), digitar à mão (web), itens só do rolê, fotos no bucket privado | OCR na web; leitura de código de barras (limitações documentadas) | Implementada, sem validação em aparelho (nunca testado com fotos reais) |
| Histórico | Lista por mês, **busca por local, bebida ou pessoa**, filtros de período e tipo; cartões dizem "suas bebidas" quando há mesa | — | Implementada |
| Estatísticas | 7/30/90 dias ou período; só as bebidas do "Você", rotuladas | Estatística da mesa (decisão: fora, para não virar ranking) | Implementada |
| Orçamento | Pessoal (só o que foi informado nas suas bebidas), avisos 80%/100%; o texto agora diz que a mesa fica na comanda | Orçamento da mesa | Implementada |
| Relato pós-rolê | Resposta rápida + detalhes opcionais, editável no resumo | — | Implementada |
| Locais, busca e mapa | Locais salvos, busca (Geoapify), mapa, "Abrir no mapa", "Iniciar rolê aqui" | — | Implementada, sem validação em aparelho (busca/mapa só conferidos por API) |
| Compartilhamento e exportação | Cartão do resumo (aviso se o rolê não existe), texto da divisão, JSON (tudo, **sem rolês/locais excluídos**) e CSV (coluna de consumidor) | Arquivos de foto na exportação | Implementada; compartilhar no iOS sem validação |
| Offline, nuvem e conflitos | Fila durável, reenvio sem duplicar, restauração da nuvem, tela de conflitos **com descrição por nome e campos de locais, bebidas e receitas próprias** (versão daqui x da nuvem, o que muda em cada escolha, edição x exclusão) | Sincronizar favoritos, partida de jogo e cartas próprias | Parcial |
| Tela bloqueada, notificação, pendentes | Live Activity (iOS), notificação (Android); "Mais uma" **só repete pedido individual do Você**; pendentes (inclui "foi para outra pessoa"). Android e iOS 16: o toque abre o app e ele salva quando está na tela; iOS 17+: o toque vira comando na fila e o app salva quando roda ("+N aguardando registro" = recebido, não salvo) | — | Implementada; iOS compilado e aberto em iPhone real (Live Activity e "Mais uma" vistos pelo responsável); fila/horário/pendentes/Android sem validação |
| Jogos da Resenha | Eu nunca, Quem é mais provável, Verdade ou desafio **sem pontos**; leitor em destaque, passar a vez, trocar leitor, importar pessoas do rolê, cartas próprias, retomada | — | Implementada |
| Simulador de cerveja | "Virar o copo" (sensor com arrasto de reserva) e copão no rolê | — | Implementada, sem validação em aparelho (sensor nunca visto) |
| **Bafômetro de brincadeira** | **Novo:** tela própria na Resenha; microfone só após "Começar" (só intensidade, local, sem gravar/enviar, liberado ao sair/segundo plano) ou "Segurar para brincar"; resultado sorteado, sem número nem veredito; reduz movimento | — | Implementada, sem validação em aparelho (microfone/permissão nunca vistos em aparelho) |
| Idiomas e configurações | pt-BR/en/es com paridade de chaves (verificada); idioma do sistema ou escolhido | — | Implementada |
| Pix/cobrança, bafômetro físico, contas para convidados, ranking | — | — | Fora do escopo |

## Caminhos que criam registro de bebida e a pessoa (conferido no código)
Novo pedido (pessoa explícita), "Mais uma"/menu Repetir (copia consumidor e porções), formulário antigo (pergunta quem quando há 2+ pessoas; **a partir desta
rodada não cria garrafa compartilhada em mesa**, e aponta para Novo pedido), Minhas bebidas e leitura de rótulo (perguntam quem), "esqueci uma bebida" (pergunta
quem), água (pessoa escolhida; o atalho da tela bloqueada é do Você), comandos da tela bloqueada (só pedido individual do Você; senão vão para revisão).
Nenhum caminho atribui ao dono sem que a pessoa esteja visível.

## Contradições entre telas (corrigidas nesta rodada)
Home, histórico, estatísticas, detalhe do local e orçamento são **do Você** e agora dizem isso nos rótulos; o resumo tem "Pessoas e conta" e "Registros da mesa
(N)" com o dono de cada registro; "Preencher preços" agrupa por pessoa e alcança registros de convidados; o JSON não exporta mais rolês/locais excluídos.

## Rodada 19/10/2026 (continuação): os quatro itens

### Pessoas em garrafa já registrada
`lib/drinks/domain/bottle_people.dart` (regras puras), `BottlePeopleEditor` em `lib/drinks/presentation/bottle_people_editor.dart` e `DrinkFormCubit`.
- **Adicionar:** só gente do mesmo rolê (a comanda do rolê) que ainda não está na garrafa; entra com volume **desconhecido** e uma parte do valor. O volume dos outros não muda.
- **Tirar:** se a pessoa tem volume, ele só sai com escolha explícita (para a sobra da garrafa ou para outra pessoa); se tem parte do valor, escolha explícita (dividir entre quem
  continua pagando ou passar a uma pessoa). Sem escolha, o domínio recusa (`ArgumentError`). A garrafa pode ficar com **uma só pessoa** (ex.: Você e Ana → Você): ao tirar Ana, volume e valor dela vão para Você por escolha explícita; a sobra continua sobra (nunca vira consumo) e o registro segue o mesmo (id, total, composição, pagamentos). Ele continua marcado como compartilhado, com uma porção, para não transformar sobra em consumo. Enquanto houver valor a distribuir, alguém precisa receber: sem destinatário o domínio recusa e o botão Salvar não grava.
- **Volume x valor:** o volume fica no registro (`portions`); a divisão do valor fica no vínculo da comanda (`TabLink.assign`, partes por pessoa; "todos igual" continua sendo `null`). Nenhum muda o outro.
- **Soma:** porções conhecidas + sobra nunca passam do tamanho da garrafa (mesmo erro de antes); o rateio sempre soma o valor do pedido (`TabCalculator.allocate`).
- **Antes de salvar:** diálogo "O que muda ao salvar" por pessoa (volume antes → depois; valor na comanda antes → depois, com serviço e desconto, calculados pelo mesmo `TabCalculator`).
- **Preserva:** id, composição, origem, horário, valor total, vínculos; pagamentos não são tocados (são por pessoa, não por garrafa). Nada cria outra garrafa/cobrança.
- **Persistência:** a comanda (um documento por rolê) é gravada primeiro e o registro depois; se o app parar entre os dois, a garrafa mantém as pessoas antigas e a divisão nova só menciona o mesmo total.
  A atualização do `paidCents` do dono acompanha a divisão (zera se ele deixa de pagar).
- Testes: `test/bottle_people_test.dart`, `test/bottle_people_cubit_test.dart` (repositórios reais em memória).

### Desfazer exclusão de rolê
`lib/outings/data/outing_deletion.dart` (`OutingDeletion`), UI em `confirmDeleteOuting`.
- Ao excluir, o rolê e os registros **vivos** recebem o **mesmo carimbo** de exclusão. Desfazer devolve o mesmo rolê (mesmo id) e só os registros com esse carimbo; o que já estava excluído antes
  continua excluído; uma exclusão feita depois (outro carimbo) não é revivida por um Desfazer antigo.
- **Janela:** 10 s (`OutingDeletion.undoWindow`), em um aviso com "Desfazer" no app aberto. Depois disso, ou se o app fechar, a exclusão é definitiva na prática (os dados seguem como tombstones sincronizados; não há tela de lixeira).
- Comanda (pessoas, pagamentos, divisão), itens exclusivos e fotos **não são apagados** pela exclusão do rolê (nenhum arquivo é removido), então voltam junto.
- Repetir o toque ou chamar depois não duplica nem revive nada (`nothingToRestore`). Ordem: rolê primeiro, registros depois (uma interrupção deixa um rolê vivo com menos bebidas, nunca bebidas vivas sob rolê excluído).
- **Conflito de rolê ativo:** se o excluído estava em andamento e outro está em andamento, o Desfazer pergunta; a única opção de restaurar é **encerrado** no horário da exclusão. O outro rolê nunca é encerrado sozinho.
- Live Activity/notificação: a restauração só altera o rolê; o coordenador de acompanhamento já respeita "removido pelo usuário" e "oculto" por rolê, então não reinicia o que foi dispensado.
- Sincronização: a restauração é uma nova escrita (revisão mais nova) do mesmo registro; vale o mesmo mecanismo de fila/versão de qualquer edição. **Não exercitado com dois aparelhos.**
- Testes: `test/outing_undo_delete_test.dart`.

### Termos e privacidade
**Não implementado, por dependência externa.** Conferido em 19/10/2026: `https://lucksrei.com/privacy/` existe, mas é a política **do site institucional** (diz que cada app pode ter a sua, cita só o Match Queue e
não menciona o Bebômetro); `lucksrei.com/bebometro`, `/bebometro/privacy(idade)`, `/termos` retornam 404; `bebometro.lucksrei.com` é o próprio app web (qualquer rota devolve 200, então não prova que há página).
Nenhum link foi adicionado (não há URL oficial do Bebômetro, e usar a do site ou a de outro app seria incorreto). Para fechar: publicar as páginas de termos e de privacidade **do Bebômetro** no site `lucksrei.com`
(Worker `lucksrei-site`, outro projeto, que não alterei sem autorização) e então acrescentar os links na tela de cadastro e em Configurações (pt-BR/en/es, com tratamento de falha ao abrir).

### Conflitos de locais e bebidas/receitas próprias
`lib/core/sync/conflict_describer.dart` + `ConflictsPage`. O cartão mostra o nome do item, se é edição nos dois lados, exclusão na nuvem ou exclusão aqui; as duas versões com campos legíveis
(local: nome, tipo, endereço, cidade, favorito, situação, ponto no mapa; bebida: categoria, marca, estilo, volume, teor, ingredientes; receita: cada ingrediente com quantidade e teor), "não informado" para o desconhecido,
"≠ diferente" nos campos que divergem e uma frase do que cada botão faz. Sem JSON bruto nem ids. Nada de mesclagem; revisão, tombstones, edição pendente e isolamento por conta seguem do mecanismo anterior.
Testes: `test/conflict_describer_test.dart` (a tela em si não foi vista rodando).
