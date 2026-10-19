<p align="center">
  <img src="assets/branding/logo_cap.png" width="112" alt="Bebômetro">
</p>

<h1 align="center">Bebômetro</h1>

<p align="center">Suas bebidas, seus gastos e seus rolês — com uma mesa que conta a história.</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Supabase-3FCF8E?logo=supabase&logoColor=white" alt="Supabase">
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/platforms-Android_·_iOS_·_Web-555555" alt="Android · iOS · Web">
</p>

<p align="center"><a href="README.md">English</a> · <b>Português</b> · <a href="README.es.md">Español</a></p>

---

O Bebômetro é um app brasileiro para registrar um **rolê**: bar, churrasco, festa ou uma noite com amigos. Inicie a sessão, registre as bebidas, repita o pedido com **Mais uma** e encerre com um resumo do que registrou e gastou.

## Disponibilidade

- **Plataformas:** Android e iOS são prioridade; o projeto também contempla Flutter web.
- **Idioma do app:** português do Brasil. Os READMEs têm versões em português, inglês e espanhol; isso não significa que a interface esteja traduzida.
- **Aparência:** tema escuro, destaques âmbar, ícone com **B** na tampinha e marca escrita separada.
- **Estágio:** desenvolvimento ativo; não há lançamento em lojas documentado neste repositório.

> **Estado da validação — 13/10/2026:** os recursos abaixo estão implementados em código. O handoff registra que esta entrega não foi compilada, executada no Flutter nem validada visualmente. Consultas à API do Supabase não comprovam a sincronização ponta a ponta pelo app. Consulte o [checklist](docs/development-progress.md).

## Como funciona o rolê

1. Inicie com apelido ou endereço e um tipo de ambiente.
2. Escolha um produto, receita ou bebida própria; informe sua porção e, opcionalmente, o preço.
3. Repita o pedido com **Mais uma** ou registre água separadamente.
4. Acompanhe a lista ou a mesa ilustrada, com gastos e orçamento.
5. Encerre, confira o resumo e consulte depois no histórico.
6. Em outra abertura do app, conte como foi, se quiser.

## Funcionalidades

**Rolês e registro rápido**

- Um rolê ativo por vez, recuperado do armazenamento local; horários e registros editáveis.
- Repetição com um toque e opção de desfazer, preservando receita e porção. Água não substitui o atalho da última bebida alcoólica.
- Garrafas compartilhadas com divisão igual ou personalizada e sobras. Uma garrafa de 600 ml dividida igualmente entre três pessoas registra 200 ml para o usuário.
- Consumo separado de pagamento: pagar a garrafa não significa beber tudo.

**Catálogo e receitas**

- Catálogo embarcado e versionado de cervejas, chopps, produtos sem álcool, destilados e aperitivos, bebidas prontas (drinks em lata/garrafa, ice, hard seltzers), além de receitas de referência.
- **Sobre estes dados:** o detalhe de cada produto tem uma seção recolhida que mostra, campo a campo, de onde vêm teor, ingredientes, tamanhos e estilo (fabricante, rótulo em fonte secundária, cadastro público de embalagem, imprensa, receita de referência, informação sua ou volume sugerido), com mercado, data de consulta e endereço que abre ao tocar e pode ser copiado. Campo sem fonte própria avisa isso. Tamanho vindo de cadastro de código de barras prova que a embalagem existiu, não que esteja à venda.
- Busca por produto, marca, estilo e apelidos; filtros por categoria, marca, estilo e apresentação, favoritos e recentes.
- Detalhes com apresentações, ingredientes declarados, teor alcoólico e fontes, quando conhecidos.
- Componentes e unidades editáveis; bebidas e receitas pessoais atualmente podem ser editadas, duplicadas e excluídas sem modificar registros passados.
- Cada consumo guarda uma cópia dos dados. Atualizações do catálogo ou da receita não reescrevem o histórico.

**Bebidas por foto (só no rolê)**

- *Rótulo:* foto pela câmera ou galeria, girar/trocar, leitura local do texto, revisão e então “Confirmar e continuar” (abre o formulário normal de consumo) ou “Salvar só neste rolê” (nenhum consumo é registrado).
- *Cardápio:* uma ou mais fotos geram candidatos revisáveis; corrija, descarte ou adicione itens à mão. Salvar os itens não registra consumo, e o preço anunciado é só sugestão: você confirma o valor efetivamente pago.
- *Leitura indisponível* (web, permissão negada, resultado vazio): a foto continua visível e você digita ou cola o texto, ou preenche o item à mão. Resultados nunca são simulados.
- *Cadastro manual dentro do rolê* usa a mesma tela de revisão. Fora do rolê, “Minhas bebidas” segue como antes.
- Tudo o que nasce assim pertence ao ID daquele rolê: não entra no catálogo global, em “Minhas bebidas”, favoritos, recentes, outros rolês nem em sugestões futuras de preço, e permanece no histórico do rolê, inclusive após a meia-noite. Leituras inacabadas continuam ligadas ao rolê de origem.
- As fotos são arquivos locais (não base64) e podem ser excluídas sem perder os dados confirmados da bebida. Um bucket privado na nuvem as recebe quando a sincronização funciona.

**Mesa do rolê**

- Alternância Mesa/Lista e seis cenários: bar, balada, churrasco, casa, praia e restaurante.
- Latas, garrafas, copos e outros recipientes ilustrados, com agrupamento quando há muitos registros.
- Esvaziamento decorativo opcional, redução de movimento e retrospectiva com recipientes vazios.
- Copão de volume acumulado e brincadeira separada de “virar o copo” em tela cheia: o próprio celular é o copo, movido pelo acelerômetro no Android/iOS e por arrasto na web ou sem sensor. É só visual e não altera os consumos.

**Locais e gastos**

- Locais salvos com apelido ou endereço, cidade/UF opcionais, favoritos e arquivamento.
- Ao iniciar um rolê: buscar um bar ou um endereço, usar a localização atual (só depois do toque), conferir e ajustar o ponto no mapa, dar um apelido ("Casa da Samara"), escolher um local salvo ou informar só um apelido. O apelido aparece como nome; o endereço fica nos detalhes. Cada rolê guarda a própria cópia do local, e corrigir o local de um rolê muda só aquele rolê.
- Detalhes do local com mapa, "Abrir no mapa" (coordenadas ou endereço, nunca o apelido), "Iniciar rolê aqui", visitas, última visita e gasto informado nas suas bebidas (separado do total da mesa da comanda).
- Busca e mapa pela Geoapify (dados do OpenStreetMap, com atribuição), configurados pela chave `GEOAPIFY_KEY`. Sem a chave, apelido, endereço digitado e locais salvos continuam funcionando.
- Orçamento opcional, avisos configuráveis e preenchimento de preços ausentes individualmente ou em lote.
- Sugestões de preços com base em registros comparáveis do próprio usuário, confirmadas antes de usar. Não são médias públicas de mercado.
- Valor pago, cortesia e preço desconhecido tratados separadamente.

**Comanda e divisão da conta (opcional)**

- Uma “Comanda” dentro do rolê e do resumo (sem nova aba): pedidos equivalentes agrupados (“Chopp 400 ml · 12 × R$ 15 = R$ 180”), extras como petiscos, couvert, transporte ou uma bebida que existe só na comanda.
- Bebidas registradas são ligadas por id, nunca copiadas: corrigir o registro corrige a comanda. Garrafa compartilhada conta uma vez; se só a parcela pessoal é conhecida, o total da mesa continua desconhecido.
- Serviço opcional (atalho de 10%, editável) e desconto (R$ ou %), sempre na mesma ordem: subtotal → desconto → serviço sobre itens elegíveis → total. Preços ausentes deixam a conta e a divisão parciais.
- Participantes só por apelido, divisão igual, por item (com pesos) ou com valores personalizados; os centavos são distribuídos de forma determinística e sempre somam o total.
- Pagamentos são registrados por pessoa e só afetam o saldo. Não há Pix, banco nem cobrança, e o app nunca diz quem deve transferir para quem. Um resumo em texto pode ser visto, copiado ou compartilhado a pedido.
- Consumo, custo atribuído e pagamento ficam separados: a comanda nunca cria registros de bebida nem estatísticas de álcool de ninguém.

**Histórico e estatísticas pessoais**

- Histórico agrupado por mês, com filtros por local, período e tipo de rolê.
- Estatísticas de 7, 30 ou 90 dias ou período personalizado: rolês, categorias, volumes conhecidos, álcool calculado, gastos informados e locais.
- Relato pós-rolê opcional, informações de como acordou e ressaca; lembrete de rolê aberto sem encerramento automático.
- Dados ausentes continuam identificados. Dia sem registro não significa dia sem beber.

**Rolê na tela bloqueada (opcional)**

- iOS 16.2+: uma Live Activity na tela bloqueada e, nos iPhones compatíveis, na Dynamic Island, com o tempo e a quantidade de registros de bebida alcoólica. Android: uma notificação silenciosa, de baixa importância, atualizada no lugar, com cronômetro nativo (sem foreground service). Web: sem superfície nativa; o acompanhamento fica dentro do app.
- Desligado até você ativar (oferecido uma vez, no primeiro rolê, e em Configurações). Gastos e apelido do local ficam ocultos por padrão; o endereço nunca aparece. Dá para ocultar por rolê e remover a qualquer momento, e o que você removeu não volta naquele rolê.
- “Abrir”, “Mais uma” e “Água” abrem o app no rolê certo e pedem confirmação; nada é registrado só por tocar. O contador conta registros, não doses-padrão, e uma garrafa compartilhada é um registro.

**Resenha: jogos offline**

- Eu nunca, Quem é mais provável e Verdade ou desafio.
- Apelidos (ou as pessoas do rolê), modos Leve/+18, sem pontos: quem lê a pergunta fica em destaque e a leitura gira; cartas próprias e retomada da partida.
- Pular não gera punição. Os jogos não exigem consumo nem registram bebidas automaticamente.

**Compartilhamento e exportação**

- Cartão de resumo configurável; endereço completo e relato de embriaguez não entram no cartão.
- Exportação dos registros pessoais em JSON e dos rolês e bebidas em CSV.
- Compartilhamento do sistema quando disponível, com alternativas de copiar texto. O suporte na web depende do navegador.

## Regras dos dados e cálculos

Volume, preço ou teor desconhecido não é zero. O cálculo de álcool usa somente componentes com dados declarados suficientes e indica registros incompletos; folhas, colheres e outras unidades não suportadas não são convertidas silenciosamente em ml.

O app registra consumo; **não** mede álcool no sangue ou no sopro, certifica sobriedade ou estabelece um limite pessoal seguro. A animação da mesa é ilustrativa e não mede ritmo de consumo ou eliminação de álcool.

## Arquitetura e sincronização

Organização por funcionalidade com separação entre domínio, dados e apresentação, Cubits para estado e `get_it` para injeção de dependências.

- **Gravação local primeiro:** SharedPreferences mantém os registros e uma fila durável de envios pendentes, com versões.
- **Conta:** obrigatória, com e-mail e senha (Supabase Auth). O cadastro entra direto, sem confirmação de e-mail. Senha esquecida é redefinida com um código de 6 dígitos enviado por e-mail e digitado no app, em qualquer aparelho. Os dados ficam separados por conta no aparelho e funcionam offline para quem já entrou.
- **Supabase:** PostgreSQL com migrations de RLS versionadas.
- **Envios e leitura:** UUIDs estáveis no cliente, upserts, novas tentativas e sincronização manual. Uma pendência só sai após confirmação do servidor para aquela versão. A leitura da nuvem recupera o histórico em outro aparelho (paginada, retomável); edições concorrentes são detectadas pela revisão do servidor e vão para "Alterações para resolver".
- **Dependências:** locais sobem antes dos rolês vinculados; rolês antes das bebidas. Vínculos recusados ficam pendentes, sem remoção silenciosa.
- **Limitação atual:** algumas preferências (idioma, mesa e tela bloqueada) ficam no aparelho e não são sincronizadas.

## Stack

| Camada | Tecnologia |
| --- | --- |
| App | Flutter / Dart |
| Estado | `flutter_bloc` / Cubit |
| Injeção de dependências | `get_it` |
| Persistência local | `shared_preferences`, arquivos locais de foto (`path_provider`) |
| Fotos e leitura de texto | `image_picker`, `image`, `google_mlkit_text_recognition` (no aparelho, Android/iOS) |
| Backend | Supabase Auth, PostgreSQL, RLS |
| Gráficos | Widgets Flutter e custom painters |
| Compartilhamento | `share_plus` |
| Movimento do aparelho | `sensors_plus` |
| Formatação / IDs | `intl`, `uuid` |

Cloudflare faz parte da infraestrutura planejada, não de uma dependência implantada do app atual.

## Estrutura do projeto

```text
lib/
  core/                  configuração, DI, tema, armazenamento local, sync
  shell/                 navegação principal
  home/  outings/        início e ciclo do rolê
  drinks/                catálogo, receitas, porções e registros
  scan/  outing_drinks/  leitura de rótulo/cardápio, fotos e bebidas só do rolê
  tab/                   comanda, divisão da conta e pagamentos
  tracking/              acompanhamento na tela bloqueada (Live Activity / notificação)
  places/  history/      locais salvos e rolês anteriores
  stats/  settings/      estatísticas e preferências
  table/  glass/         cenários, recipientes e interações com o copo
  games/                 jogos offline
  share/  export/        cartões de resumo e exportação pessoal
assets/
  branding/              tampinha e marca escrita
  catalog/               produtos e receitas de referência
  games/                 cartas dos jogos
supabase/migrations/     esquema versionado do banco
docs/                    checklist de desenvolvimento
```

## Executar localmente

Use um SDK Flutter cujo Dart atenda à restrição do [`pubspec.yaml`](pubspec.yaml), atualmente `^3.13.3`. Android e iOS precisam das ferramentas das respectivas plataformas; iOS exige macOS/Xcode.

Para um projeto Supabase próprio, aplique as [migrations](supabase/migrations/) em ordem, publique a função `supabase/functions/delete-account` e configure o Auth por e-mail (redirect `bebometro://auth-callback`, SMTP próprio para usuários reais; ver `docs/accounts-sync-checklist.md`). A configuração vem de [`Env`](lib/core/config/env.dart); sobrescreva os valores de desenvolvimento embarcados para usar seu projeto.

```bash
git clone https://github.com/Lucasdiogof/bebometro.git
cd bebometro
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://SEU_PROJETO.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=SUA_CHAVE_PUBLICAVEL --dart-define=GEOAPIFY_KEY=SUA_CHAVE_GEOAPIFY
```

`GEOAPIFY_KEY` é opcional: sem ela, a busca de lugares e o mapa ficam desligados e o resto do app funciona. Veja a configuração da chave no [HANDOFF](HANDOFF.md). Toda a configuração externa (função, redirects de Auth, SMTP, templates de e-mail, Geoapify, assinatura iOS) está em [docs/external-setup.md](docs/external-setup.md); **ainda não foi aplicada**.

Na web, acrescente `-d chrome` ao comando de execução. São instruções de configuração, não evidência de comandos executados nesta atualização da documentação. Quando o backend falha, o fluxo implementado mantém os registros locais e mostra a sincronização pendente.

## Roadmap e limitações atuais

- **Implementado no código, ainda não validado em execução:** fotos de rótulo e cardápio com leitura de texto no aparelho (só Android/iOS), revisão manual, bebidas e fotos só do rolê, envio privado das fotos e a alternativa manual usada na web. A web não tem leitura automática e guarda as fotos só durante a sessão. Não há leitor de código de barras.
- **Comanda:** escrita no código, não executada nem analisada depois desta funcionalidade; a migration `20261016000000` foi aplicada pelo responsável, mas a sincronização da comanda pelo app ainda não foi observada. Ainda não há testes unitários do cálculo.
- **Tela bloqueada:** escrita em Dart, Swift e Kotlin, não compilada nem executada em aparelho. A extensão de widget do iOS foi adicionada ao projeto Xcode à mão e precisa do Team de assinatura escolhido no Xcode. As ações rápidas abrem o app para confirmação; não registram em segundo plano. O sistema limita Live Activities (cerca de 8 horas, mais até 4 na tela bloqueada).
- **Não verificado:** os interpretadores de rótulo e cardápio são heurísticos e não foram testados com fotos reais, então não se promete precisão. A migration `20261015000000` foi aplicada pelo responsável; a sincronização dessas tabelas e fotos pelo app ainda não foi observada.
- **Regra de escopo (implementada):** itens personalizados, fotos e preços de cardápio pertencem ao ID do rolê, inclusive após a meia-noite. Não entram no catálogo global, não viram itens pessoais reutilizáveis automaticamente e não alimentam sugestões em visitas futuras.
- **Locais e mapa:** escritos no código, não executados; busca, mapa e GPS nunca foram observados funcionando. Dependem da chave Geoapify (ainda não configurada) e de `flutter pub get` (pacotes novos). A migration `20261017000000` foi aplicada pelo responsável.
- **Conta e sincronização:** escritas no código, não executadas. A migration `20261018000000` foi aplicada pelo responsável; o SMTP está configurado; faltam aplicar o template de recuperação por código e o comprimento de 6 dígitos (`scripts/apply_recovery_code.py`) e conferir a `delete-account` por completo. Nada disso foi observado funcionando no app.
- **Idiomas (pt-BR, en, es):** localização oficial do Flutter com arquivos ARB, escolha manual do idioma em Configurações (preferência do aparelho, disponível antes do login, troca sem reiniciar), conteúdo de catálogo/receitas/cartas traduzido, textos nativos da tela bloqueada enviados pelo app e exportações independentes do idioma. Escrito em código, não compilado nem executado. Os templates de e-mail do Supabase nos três idiomas estão preparados em `supabase/email-templates/`, mas **não foram aplicados**; os textos de permissão do iOS seguem o idioma do sistema. Veja o [checklist de i18n](docs/i18n-checklist.md).
- **Depois:** preços regionais sustentados por observações reais e ampliação do catálogo.
- **Validação pendente:** resolução de dependências, compilação, fluxos em aparelho/navegador, revisão visual e sincronização ponta a ponta. A física da cerveja em tela cheia e os eixos do sensor estão implementados no código, mas nunca foram observados em aparelho.

As bebidas pessoais reutilizáveis criadas antes desse escopo foram preservadas; dentro de um rolê, novos cadastros manuais ficam só nele.

## Documentação

- [Handoff técnico](HANDOFF.md)
- [Progresso do desenvolvimento](docs/development-progress.md)
- [Checklist de produto](docs/product-checklist.md)
- [Checklist de internacionalização](docs/i18n-checklist.md), [formato de exportação](docs/export-format.md), [e-mails de autenticação](docs/auth-emails.md)
- [Dados do catálogo e receitas](assets/catalog/)
- [Migrations do banco](supabase/migrations/)

Ainda não há screenshots nesta apresentação: a entrega não tem capturas verificadas do app em execução. Os assets de marca não são apresentados como telas do aplicativo.

## Licença

Não é concedida licença de código aberto. A visibilidade do código não concede autorização de reutilização. Todos os direitos reservados. As marcas de bebidas pertencem aos respectivos titulares; o app não é afiliado a elas.

## Sobre

Um produto **Lucksrei**, desenvolvido por **Lucas Diogo França**. [lucksrei.com](https://lucksrei.com/)
