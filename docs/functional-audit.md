# Auditoria funcional do app (19/10/2026)

Feita por **leitura de código, rotas e documentos** (quatro leituras independentes, com as afirmações conflitantes conferidas à mão no código), não pelo que
o HANDOFF diz. Separa **falta de implementação** de **falta de validação em aparelho**.

Estados: **Implementada** · **Parcial** · **Não implementada** · **Implementada, sem validação em aparelho** · **Fora do escopo**.
"Validação em aparelho" = Android/iOS reais. Só a web foi exercitada pela interface (ver `docs/qa-report.md`).

| Funcionalidade | O que o usuário consegue fazer hoje | O que falta implementar | Estado |
|---|---|---|---|
| Cadastro e login | Criar conta (nome, e-mail, senha, confirmação) e entrar; sair em Minha conta (avisa pendências) | Troca de e-mail; link de termos/privacidade | Parcial |
| Recuperação de senha | Pedir o código de 6 dígitos, digitar e-mail + código, nova senha, reenviar com espera, erros claros | — | Implementada (fluxo real aprovado pelo dono em 19/10) |
| Alterar senha | Em Minha conta; se o projeto exige código por e-mail, **ele agora é enviado sozinho** no primeiro erro (antes era preciso achar "Reenviar") | — | Implementada, sem validação em aparelho |
| Perfil | Editar o nome | E-mail, foto; o nome só vive em `user_metadata` | Parcial |
| Exclusão de conta | Senha + confirmação; função `delete-account` (exclusão comprovada no banco em 17/10) | Botão de exportar dentro da tela (hoje só texto) | Implementada |
| Iniciar rolê | Tipo, local (busca, mapa, apelido, endereço), horário, pessoas na mesa, orçamento; aviso ao voltar com campos preenchidos | — | Implementada |
| Editar rolê | **Novo:** trocar tipo e horário de início (validado: não no futuro, não depois do fim nem do primeiro registro); corrigir local; orçamento | — | Implementada |
| Encerrar rolê | Horário ajustável, resumo, relato pós-rolê | — | Implementada |
| Excluir rolê | **Novo:** exclusão com confirmação (rolê e registros viram tombstones sincronizados) | Desfazer a exclusão | Implementada |
| Consultar rolê / resumo | Consumo e gasto **seus** (rotulados), pessoas e conta (parcela, pago, bebidas), registros da mesa com o dono de cada um, comanda, fotos, "esqueci uma bebida" (pergunta quem) | — | Implementada |
| Pessoas e atribuição | Adicionar/renomear/marcar que saiu/remover (bloqueia se há vínculos); filtro Mesa/Você/convidado; "Todos" grava quem estava presente | — | Implementada |
| Bebidas individuais | Novo pedido por pessoa e quantidade; "Mais uma para X" (mantém a pessoa); passar para outra pessoa; excluir; Desfazer; aviso ao sair com dados | — | Implementada |
| Bebidas compartilhadas | Criar garrafa/jarra com porção por pessoa (Novo pedido); **Novo:** corrigir as porções depois (em branco = desconhecido) e garrafa só de convidados deixa de ficar bloqueada | Adicionar ou tirar pessoas de uma garrafa já criada | Parcial |
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
| Offline, nuvem e conflitos | Fila durável, reenvio sem duplicar, restauração da nuvem, tela de conflitos | Sincronizar favoritos, partida de jogo e cartas próprias; descrições específicas de conflito para locais e bebidas próprias | Parcial |
| Tela bloqueada, notificação, pendentes | Live Activity (iOS), notificação (Android); "Mais uma" **só repete pedido individual do Você**; pendentes (inclui "foi para outra pessoa") | — | Implementada, sem validação em aparelho |
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
