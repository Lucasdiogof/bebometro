# Auditoria de privacidade de loja: Bebômetro

Data: 20/10/2026. Base: `origin/main` bdeb460. Legenda: **CONFIRMADO NO CÓDIGO** (li o código) / **A CONFIRMAR** (depende do dono, de Xcode/aparelho ou de terceiros). Nada foi executado em aparelho; não há Xcode neste ambiente.

Fontes oficiais lidas (WebFetch): Apple App Review Guidelines (1.4.3, 5.1.1, 5.1.2) e "Age ratings values and definitions"; Google Play, "Content ratings". A página "Describing data use in privacy manifests" não carregou pelo fetch (site dinâmico): as constantes `NSPrivacyCollectedDataType*` abaixo vêm de conhecimento prévio e **devem ser conferidas no Xcode**.

## (a) Matriz App Privacy (taxonomia Apple)

"Coletado" segue a definição da Apple: dado que sai do aparelho e fica acessível a nós ou a terceiros além do tempo real da requisição. Todos os itens "sim" vão ao Supabase (conta do usuário), finalidade App Functionality, vinculados à identidade, sem tracking, sem anúncios/analytics.

| Categoria / tipo | Coletado? | Vinculado | Tracking | Opcional | Origem e destino | Evidência | Obs. |
|---|---|---|---|---|---|---|---|
| Contact Info / Email | Sim | Sim | Não | Não (conta obrigatória) | cadastro, Supabase Auth; Resend envia códigos | `lib/account/data/account_service.dart`; docs/auth-emails.md | CONFIRMADO NO CÓDIGO |
| Contact Info / Name | Sim | Sim | Não | Não | nome de exibição, Supabase Auth | `account_service.dart` | apelidos de terceiros: ver User Content |
| Identifiers / User ID | Sim | Sim | Não | Não | uid do Supabase (`owner_id` em todas as tabelas) | `supabase/migrations/*`, `cloud_pull.dart:72` | CONFIRMADO |
| Location / Precise | Sim | Sim | Não | Sim (só ao tocar em "Usar minha localização"; locais salvos têm lat/lng) | `places` (lat/lng) no Supabase; posição/ponto de referência para a Geoapify (busca e mapa) | `lib/places/data/device_location.dart:55`, `geo_search.dart:150,161,175` | Geoapify: retenção A CONFIRMAR. A posição bruta do aparelho não é gravada, só locais que o usuário salva |
| User Content / Photos | Sim | Sim | Não | Sim | foto confirmada, bucket privado `outing-photos` | `lib/scan/data/photo_uploader.dart:76` | antes de confirmar, só local |
| User Content / Other | Sim | Sim | Não | Sim | rolês, notas, bebidas, receitas, apelidos de participantes, comandas, `source_text` (OCR), Supabase | migrações 2026101x; `export_builder.dart` | |
| Health & Fitness / Health | Declarado por cautela | Sim | Não | Sim | humor/ressaca e consumo de álcool informados pelo usuário | chaves `summaryHangover`, `feedbackHangover` em app_pt.arb | **A CONFIRMAR**: a Apple inclui dado de saúde informado pelo usuário; leitura conservadora |
| Financial Info / Other | Declarado por cautela | Sim | Não | Sim | preços pagos, divisão e pagamentos anotados, Supabase | tabelas `outing_tabs`, `drink_entries` | **A CONFIRMAR**: valores digitados, sem dado de pagamento real |
| Search History | Não no nosso backend | n/a | Não | Sim | texto da busca de lugar (3+ letras), Geoapify | `geo_search.dart` | **A CONFIRMAR** se a Geoapify retém; não entrou no manifest |
| Sensitive Info, Contacts, Browsing History, Purchases | Não | | | | | sem acesso a contatos; sem compras no app | |
| Usage Data, Diagnostics | Não pelo app (sem analytics/crash no pubspec) | | | | | `pubspec.yaml` | Logs de infraestrutura (IP) de Supabase/Geoapify/Resend: A CONFIRMAR |
| Audio | Não coletado | | | | microfone processado no aparelho, não gravado | `lib/games/data/breath_input.dart` | |
| Other Data | Não | | | | | | |

Tracking: **NSPrivacyTracking=false**, CONFIRMADO NO CÓDIGO (sem SDK de anúncio/analytics, sem IDFA, sem ATT).

### Manifest x App Store Connect
O `PrivacyInfo.xcprivacy` é lido pelo Xcode para gerar o privacy report e conferir APIs required-reason. As respostas de "App Privacy" no App Store Connect são a declaração pública da loja e devem coincidir com a matriz acima (o dono responde lá; este repositório não toca no App Store Connect). O que a Geoapify possa reter precisa ser respondido no ASC conforme o dono confirmar.

### PrivacyInfo.xcprivacy (estado novo)
- App (`ios/Runner/PrivacyInfo.xcprivacy`): tracking=false; 8 tipos coletados (Email, Name, UserID, PreciseLocation, PhotosorVideos, OtherUserContent, Health, OtherFinancialInfo), todos vinculados, sem tracking, propósito AppFunctionality; API required-reason: UserDefaults `CA92.1` (uso do próprio app: `ios/Runner/TrackingChannel.swift:20`).
- Extensão (`ios/BebometroLiveActivity/PrivacyInfo.xcprivacy`, NOVO e registrado no `project.pbxproj`): nenhum dado coletado; UserDefaults `CA92.1`, porque `AnotherDrinkIntent.swift` (usa `UserDefaults.standard`) é compilado também na extensão. **Não validado sem Xcode**: abrir o projeto e confirmar o arquivo em "Copy Bundle Resources" do alvo BebometroLiveActivity.
- Plugins (pub-cache, versões do `pubspec.lock`): `shared_preferences_foundation` 2.5.7 declara UserDefaults `1C8F.1`; app_links, image_picker_ios, package_info_plus, sensors_plus, share_plus, url_launcher_ios, geolocator_apple e record_ios trazem manifest vazio; path_provider_foundation e google_mlkit_* não trazem `.xcprivacy` no pacote Flutter (os pods nativos do ML Kit/Google têm os seus: A CONFIRMAR no Privacy Report do Xcode). Sem uso de timestamp de arquivo, espaço em disco ou uptime no Dart do app (grep em `lib/`).
- Validação final: Product > Archive > Generate Privacy Report no Xcode.

## (b) Classificação etária: respostas CANDIDATAS (não aplicadas)
Exigência oficial: Apple 1.4.3 proíbe apps que incentivem consumo excessivo de álcool ou consumo por menores; não proíbe conteúdo sobre álcool. Pela tabela da Apple, "Alcohol, tobacco, or drug use or references" infrequente = 13+, frequente = 18+ (Brasil A14/A16). O app registra consumo, então a referência é central: candidata **Frequent = 18+ (A16 no Brasil)**. Leitura mais segura; **a decisão é do dono** (não classifiquei 18+ por conta própria).
Demais candidatas: sem violência, sem conteúdo sexual explícito (modo +18 dos jogos: "flerte e humor para adultos, nada explícito": candidata "mature/suggestive: infrequent"), sem apostas, sem acesso irrestrito à web (só links externos de mapa/site), sem UGC público (dados privados da conta), sem chat entre usuários, sem anúncios.
Google Play (IARC): responder o questionário em "App content" com referência a álcool; resposta inexata pode causar remoção (política de Content ratings).

**Código (CONFIRMADO)**: não há verificação de idade nem data de nascimento. Há declaração só no modo +18 dos jogos (`game_setup_page.dart:261`). O site afirma "destinado a maiores de 18" e "o app não verifica a idade". Bafômetro e "Virar o copo" são brincadeiras sem medição (`bafoDisclaimer`, `resenhaTipBody`); estimativas de álcool trazem aviso (`alcoholExplain`: não é alcoolemia nem indica se pode dirigir). Não encontrei texto que incentive excesso (busquei ranking, recorde, saideira, desafio de beber; `assets/games/cards_v1.json` sem cartas de beber; `gameNoDrinkNote` afirma isso). "Mais uma" é só atalho de registro. Nenhum texto foi alterado. **Proposta** (não implementada): ao decidir pelo 18+, uma linha fixa de redução de riscos na tela de resumo do rolê (ex.: "Beba com moderação. Se beber, não dirija.").

## (c) Permissões
| Plataforma | Permissão | Finalidade | Uso real |
|---|---|---|---|
| iOS | NSCamera | fotografar rótulo/cardápio | `image_capture.dart`; texto corrigido |
| iOS | NSPhotoLibrary | escolher foto da galeria | idem; texto corrigido |
| iOS | NSPhotoLibraryAdd | salvar imagem compartilhada | **Provavelmente desnecessária**: nenhum código grava na galeria (sem pacote de salvar imagem; `share_plus` usa a folha do sistema). Mantida por segurança; A CONFIRMAR em aparelho antes de remover |
| iOS | NSLocationWhenInUse | locais próximos | `device_location.dart`; texto agora informa o envio ao serviço de busca |
| iOS | NSMicrophone | brincadeira do bafômetro | `breath_input.dart`; a string passou a existir também em en/es (antes só o texto em pt) |
| iOS | NSMotion | inclinar o copo | `sensors_plus` |
| iOS | NSSupportsLiveActivities | atividade na tela bloqueada | extensão |
| Android | INTERNET, POST_NOTIFICATIONS, RECORD_AUDIO, ACCESS_COARSE/FINE_LOCATION | idem | uso comprovado; nada removido. CAMERA não declarada (image_picker abre a câmera do sistema) |

## (d) URLs por campo
- Marketing: https://lucksrei.com/projects/bebometro/
- Suporte: https://lucksrei.com/projects/bebometro/support/
- Política de privacidade (ASC e Play): https://lucksrei.com/projects/bebometro/privacy/
- Termos: https://lucksrei.com/projects/bebometro/terms/
- Exclusão de conta/dados (Play "Data deletion"): https://lucksrei.com/projects/bebometro/data-deletion/

No app: Configurações > "Privacidade e suporte" (4 linhas) abre essas URLs (`lib/settings/presentation/legal_links_section.dart`, pt/en/es, teste `test/legal_links_test.dart`).

## Divergências site x código
Corretas (CONFIRMADO): fotos locais até confirmar e depois bucket privado; OCR local; localização só no toque; microfone sem gravação; Geoapify recebe texto e coordenadas; export JSON/CSV; exclusão de conta apaga fotos, tabelas e identidade (`supabase/functions/delete-account/index.ts`), mantendo só `account_deletions` (id, status, tentativas, datas, sem e-mail).

Divergências e omissões:
1. **Backup do SO**: o manifest Android não define `allowBackup`/`dataExtractionRules` (padrão: backup ligado) e o iOS inclui o app no backup do iCloud/iTunes. Preferências, fotos não confirmadas e fila de sincronização podem ir a backups Google/Apple. O site não menciona. Não alterei (pode afetar restauração).
2. **Exportação**: o JSON inclui só metadados das fotos, não os arquivos (`export_builder.dart`). O site diz "seus registros".
3. **Exclusão "marcada como excluída"**: não há purga programada em `supabase/` (nenhum cron/job): linhas com `deleted_at` ficam até a exclusão da conta. O site não diz por quanto tempo.
4. Exclusão de conta exige login recente (10 min); vale citar no site.
5. Região do Supabase: **NÃO CONFIRMADA** (sem `config.toml`/doc no repositório; o CLI desta máquina não enxerga o projeto). O dono deve ler a região no painel.
6. Logs: a Edge Function registra só passo e erro curto (`console.error`); logs de provedores sem prazo definido, já dito no site.
7. "Destinado a maiores de 18": decisão do dono NÃO confirmada.

## (e) Decisões pendentes do dono
1. Classificação etária final (18+? idade mínima nos Termos). 2. Declarar Health e Financial Info no ASC (o manifest já declara por cautela). 3. Retenção da Geoapify (Search History/Location). 4. Região do Supabase. 5. Backup Android/iOS: manter, desligar ou citar no site. 6. Purga/retenção de linhas `deleted_at`. 7. Remover NSPhotoLibraryAddUsageDescription após teste em aparelho. 8. Linha de redução de riscos de álcool no resumo. 9. Incluir arquivos de foto na exportação? 10. Conferir o formulário de exclusão de dados no Play Console.

## (f) Riscos
- Manifest e `.pbxproj` editados sem Xcode: validar ao abrir o projeto.
- Health/Financial podem estar acima do exigido (erro para o lado seguro); subdeclarar é o risco real de rejeição.
- Se a Geoapify retém consultas/coordenadas, o ASC precisa declarar.
- Sem verificação de idade, o "+18" depende de termos e da classificação da loja.
