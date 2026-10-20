# Checklist de validação no Mac e no aparelho: Bebômetro (iOS)

Nada abaixo foi executado: este ambiente é Windows sem Xcode. Cada linha tem um critério objetivo; marque Passou/Falhou e anote o resultado. Se qualquer item falhar, não enviar para revisão.

Pré-requisitos: Mac com Xcode atual, Flutter igual ao do `pubspec.yaml`, conta Apple do desenvolvedor, um iPhone real (Live Activity e backup não funcionam bem no simulador), branch `security/store-privacy-audit` baixada, `env.json`/`--dart-define` de produção só no seu Mac (nunca no repositório).

| # | Passo | Critério de aprovação | Resultado |
|---|---|---|---|
| 1 | `flutter pub get` e `cd ios && pod install` | termina sem erro; `pubspec.lock` não muda além de archive/crypto | |
| 2 | Abrir `ios/Runner.xcworkspace` no Xcode | abre sem aviso de arquivo ausente (vermelho no navegador de arquivos) | |
| 3 | Alvo **BebometroLiveActivity** > Build Phases > Copy Bundle Resources | `PrivacyInfo.xcprivacy` está listado; Assets.xcassets também | |
| 4 | Alvo **Runner** > Build Phases > Copy Bundle Resources | `PrivacyInfo.xcprivacy` e os três `InfoPlist.strings` (pt-BR, en, es) listados | |
| 5 | Abrir cada `PrivacyInfo.xcprivacy` no Xcode | o editor de plist mostra as chaves sem erro; 10 tipos no app (Email, Name, UserID, PreciseLocation, PhotosorVideos, OtherUserContent, Health, OtherFinancialInfo, PurchaseHistory, SearchHistory); chave `NSPrivacyCollectedDataTypeLinked`; extensão sem tipos | |
| 6 | `flutter build ipa` (ou Product > Archive) com a assinatura correta | Archive concluído sem erro e sem aviso novo de manifest | |
| 7 | Organizer > Validate App | passa; sem e-mail/aviso ITMS-91053 (API required-reason sem declaração) nem ITMS-91056 (manifest inválido) | |
| 8 | Organizer > Distribute App > TestFlight (envio de teste) | processamento no App Store Connect concluído sem rejeição automática | |
| 9 | Organizer > botão direito no Archive > **Generate Privacy Report** | o PDF lista os tipos de dados e os domínios; **comparar linha a linha** com a seção 1 de `privacy-audit.md` | |
| 10 | No relatório: dados do app | os 10 tipos aparecem, só Search History não vinculado, nenhum com Tracking, nenhum tipo extra | |
| 11 | No relatório: SDKs/plugins | nenhum plugin declara tipo coletado que o app não declarou; google_mlkit (pods do Google) não adiciona tracking | |
| 12 | No relatório: APIs required-reason | UserDefaults com `CA92.1` (app e extensão) e `1C8F.1` (shared_preferences); nenhuma outra categoria sem razão | |
| 13 | Comparar o relatório com as respostas de App Privacy no App Store Connect | idênticos nos tipos, finalidades (App Functionality), vinculado e tracking | |
| 14 | Instalar no iPhone via TestFlight; abrir pela primeira vez | cadastro e login funcionam; nenhum pedido de permissão aparece antes de usar o recurso | |
| 15 | Câmera: tocar para fotografar um rótulo | o texto do diálogo é o novo (foto fica no aparelho até confirmar; confirmadas vão para a área privada da conta), no idioma do sistema (testar pt-BR, en, es) | |
| 16 | Galeria: escolher uma foto | abre o seletor do sistema; texto de permissão novo se pedir acesso | |
| 17 | Localização: "Usar minha localização" | o diálogo cita o envio da posição ao serviço de busca; só "ao usar o app"; nenhuma permissão "sempre" | |
| 18 | Microfone no bafômetro | diálogo no idioma do sistema (a string existe em en/es agora); jogar segurando o botão funciona sem permissão | |
| 19 | Movimento no "Virar o copo" | funciona; nenhum pedido de permissão inesperado | |
| 20 | **Salvar imagem sem a permissão removida**: compartilhar uma imagem do app e tocar "Salvar imagem" no share sheet | a imagem é salva na Fotos sem crash e sem erro de privacidade (a chave `NSPhotoLibraryAddUsageDescription` foi removida) | |
| 21 | Fotos: confirmar uma foto e olhar no painel Supabase (só leitura) com a sua conta de teste | o objeto aparece no bucket `outing-photos` em `<uid>/<rolê>/<foto>.jpg`; bucket continua privado | |
| 22 | Live Activity: iniciar o acompanhamento na tela bloqueada | a atividade aparece; tocar "Mais uma" registra a bebida após abrir o app; sem crash da extensão | |
| 23 | Exportação simples (JSON e CSV) | arquivos abrem, sem fotos, sem tokens | |
| 24 | Exportação completa: ligar o pacote com fotos com 5+ fotos | o ZIP é gerado, compartilhado e abre no Arquivos/Mac; `python tool/verify_export_zip.py bebometro-pacote.zip` imprime `OK`; nomes sem `..` nem `/` iniciais | |
| 25 | Exportação completa com a foto removida do aparelho (apagar o app, reinstalar e entrar) | as fotos são baixadas da conta e entram no pacote; o que falhar aparece no aviso e no `manifest.json` | |
| 26 | Exportação completa com modo avião | aviso de fotos de fora antes de compartilhar; nada falha em silêncio | |
| 27 | Cancelar a exportação durante o progresso | nada é compartilhado e a tela volta ao normal | |
| 28 | **Backup/restauração iOS**: fazer backup cifrado do iPhone (Finder), instalar em outro aparelho de teste | anotar o que volta: sessão (entra sem login?), registros, fotos. Critério: o resultado bate com a tabela da seção 4 de `privacy-audit.md`; qualquer diferença vira bug | |
| 29 | **Backup Android** (aparelho de teste): `adb shell bmgr backupnow com.lucksrei.bebometro`, desinstalar, reinstalar, `adb shell bmgr restore` | após restaurar o app abre **sem sessão** e sem registros locais; após o login o histórico volta da conta; fotos não confirmadas não voltam | |
| 30 | Android: transferência aparelho-a-aparelho | registros locais e fotos passam (device-transfer) | |
| 31 | Configurações > Privacidade e suporte | as 4 linhas abrem as URLs corretas (privacy, terms, support, data-deletion) no navegador | |
| 32 | Resumo de um rolê com bebida alcoólica | aparece "Beba com moderação. Se beber, não dirija." em pt, en e es | |
| 33 | Excluir conta com a conta de teste | conclui; login com a mesma conta falha; objetos do bucket somem | |
| 34 | Consentimento e tracking | nenhuma tela de ATT aparece; nenhuma permissão de rastreamento no sistema | |
| 35 | Metadados no App Store Connect | URLs e copyright conforme a seção 11 de `privacy-audit.md`; contato só marketing@lucksrei.com | |
| 36 | Classificação etária no App Store Connect | questionário preenchido como proposto na seção 2; resultado calculado 18+ (ou superior) | |

Critério geral de aprovação para enviar à revisão: itens 1 a 13 e 20 a 24, 28 a 33 e 35 a 36 todos Passou. Itens 14 a 19, 22, 25 a 27 e 34 sem falha aberta. Qualquer Falhou bloqueia a publicação até ser corrigido ou aceito por escrito pelo dono.
