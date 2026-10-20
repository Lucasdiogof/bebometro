# Auditoria de privacidade de loja: Bebômetro (rodada 2)

Data: 20/10/2026. Branch `security/store-privacy-audit`. Legenda: **CONFIRMADO NO CÓDIGO** / **A CONFIRMAR** (dono, Xcode, aparelho ou terceiro) / **pendente de Xcode** / **pendente de teste em aparelho**. Nada foi executado em aparelho nem no Xcode.

Fontes oficiais lidas em 20/10/2026 (WebFetch): Apple "App privacy details" (definições, finalidades, "collect"), "Age ratings values and definitions", App Review Guidelines 1.4.3/5.1.1/5.1.2; Google Play "Content ratings"; Geoapify (privacy policy, terms, páginas do Geocoding API). Não foi possível ler: a redação literal do questionário de classificação do App Store Connect (só aparece dentro do ASC) e o formulário IARC do Play Console.

## 1. App Privacy: campos do App Store Connect (resposta recomendada)

Definição Apple de "collect": transmitir o dado para fora do aparelho de modo que nós e/ou parceiros acessem por mais tempo do que o necessário para atender a requisição em tempo real. Todos os itens abaixo: **Tracking = No**, finalidade única **App Functionality** (nome exato da Apple). "Used for tracking" = não: sem SDK de anúncio/analytics, sem IDFA/ATT.

| Categoria > tipo (nome Apple) | Collected | Purposes | Linked to identity | Tracking | Evidência |
|---|---|---|---|---|---|
| Contact Info > Email Address | Yes | App Functionality | Yes | No | `lib/account/data/account_service.dart` (Supabase Auth; Resend envia os códigos) |
| Contact Info > Name | Yes | App Functionality | Yes | No | nome de exibição, `account_service.dart` |
| Health & Fitness > Health | Yes | App Functionality | Yes | No | humor/ressaca informados (`feedbackHangover`, `summaryHangover`), sincronizados no rolê |
| Financial Info > Other Financial Info | Yes (ver 1.1) | App Functionality | Yes | No | orçamento, rateio e pagamentos anotados (`outing_tabs`) |
| Location > Precise Location | Yes | App Functionality | Yes | No | lat/lng de `places` e do rolê no Supabase; ponto de referência à Geoapify (`geo_search.dart:150,161,175`, `device_location.dart:55`) |
| Search History | Yes (ver 1.3) | App Functionality | **No** | No | texto de busca de lugar enviado à Geoapify (`geo_search.dart`); não gravado no nosso backend |
| User Content > Photos or Videos | Yes | App Functionality | Yes | No | `photo_uploader.dart:76`, bucket privado `outing-photos` |
| User Content > Other User Content | Yes | App Functionality | Yes | No | rolês, notas, bebidas, receitas, apelidos de participantes, comandas, `source_text` do OCR |
| Purchases > Purchase History | Yes (ver 1.1) | App Functionality | Yes | No | preços pagos por bebida (`drink_entries`, `outing_drinks`) |
| Identifiers > User ID | Yes | App Functionality | Yes | No | uid do Supabase (`owner_id`) |
| Identifiers > Device ID | No | | | | nenhum ID de aparelho/IDFA |
| Financial Info > Payment Info / Credit Info | No | | | | sem cartão, conta bancária ou serviço de pagamento |
| Contacts, Sensitive Info, Browsing History, Usage Data, Diagnostics, Other Data, Audio, Gameplay Content, Customer Support | No | | | | sem analytics/crash no `pubspec.yaml`; áudio do bafômetro só no aparelho (`breath_input.dart`). Suporte é por e-mail fora do app |

Fora do app (A CONFIRMAR): logs de infraestrutura (IP) de Supabase e Resend, sem controle do app.

### 1.1 Financial Info x Purchases: campo a campo (rodada final)
Definições oficiais (Apple "App privacy details", lidas em 20/10/2026, https://developer.apple.com/app-store/app-privacy-details/): **Payment Info** = forma de pagamento, número de cartão ou conta bancária; **Credit Info** = score; **Other Financial Info** = salary, income, assets, debts, or any other financial information; **Purchase History** = an account's or individual's purchases or purchase tendencies.
Campos realmente armazenados/enviados ao Supabase (migrações) e a decisão por campo:

| Campo (tabela.coluna) | O que é | Categoria Apple | Justificativa | Risco de sub / super declaração |
|---|---|---|---|---|
| `drink_entries.paid_cents` | quanto o usuário pagou por uma bebida | **Purchase History** | é uma compra individual | sub: alto se omitido (é o caso típico da categoria); super: nenhum |
| `drink_entries.price_kind` (`informed`/`complimentary`/`unknown`), `price_source` | se pagou, ganhou ou não informou | **Purchase History** | tendência de compra | sub: baixo (acompanha paid_cents) |
| `drink_entries.bill_total_cents` | total da conta quando dividida | **Purchase History** | valor de uma compra | sub: baixo (mesma categoria) |
| `outings.budget_cents` | teto de gasto que o usuário se impôs para a noite | **Other Financial Info** | informação financeira pessoal ("any other financial information"), não é compra | sub: médio; super: baixo-médio (é a linha mais discutível, pois é um planejamento de gasto de baixo valor) |
| `outing_tabs.data` (jsonb): rateio/divisão, pagamentos anotados ("quem pagou quanto"), extras, serviço, desconto | divisão da conta entre apelidos e quem já pagou | **Other Financial Info** (rateio e pagamentos = quem deve/pagou quanto, próximo de "debts") e **Purchase History** (itens e totais da compra) | valores de dívida entre pessoas e de compra, digitados pelo usuário | sub: médio se omitir Other Financial; super: baixo |
| `outing_drinks.advertised_cents` | preço impresso no cardápio lido por OCR | nenhuma específica: **Other User Content** | é dado do estabelecimento, não compra do usuário; só vira compra quando o usuário registra o pagamento em `paid_cents` | sub e super: baixo |
| `outing_drinks.components`, receitas, `custom_drinks` | composição e teor | **Other User Content** | conteúdo criado pelo usuário | n/a |
| Cartão, conta bancária, serviço de pagamento, score | **não existem no app** | Payment Info / Credit Info: **não declarar** | nada é coletado | super se declarado |

Decisão final sugerida: **declarar Purchase History e Other Financial Info** (os dois, como já está no manifest), com Payment Info e Credit Info marcados como não coletados. Pró: a Apple prefere declaração cautelosa e as duas definições cobrem campos reais (compras e dívidas/orçamento). Contra: o rótulo público mostra "Financial Info" (o usuário pode supor cartão/banco). Ambiguidade que permanece para o dono: se ele entender que `budget_cents` e o rateio são só anotações pessoais sem valor financeiro, pode remover Other Financial Info; a recomendação deste documento é manter.

### 1.2 Manifest x App Store Connect
O `PrivacyInfo.xcprivacy` alimenta o Privacy Report do Xcode; o ASC é a declaração pública e deve repetir a tabela acima. Estado do manifest (`ios/Runner/PrivacyInfo.xcprivacy`): tracking=false; 10 tipos (Email, Name, UserID, PreciseLocation, PhotosorVideos, OtherUserContent, Health, OtherFinancialInfo, PurchaseHistory, SearchHistory) com propósito `NSPrivacyCollectedDataTypePurposeAppFunctionality`; só SearchHistory com `NSPrivacyCollectedDataTypeLinked=false`. Required-reason API: UserDefaults `CA92.1` (`TrackingChannel.swift:20`). Extensão (`ios/BebometroLiveActivity/PrivacyInfo.xcprivacy`, novo, no `project.pbxproj`): sem dados, UserDefaults `CA92.1`. Plugins: `shared_preferences_foundation` declara `1C8F.1`; app_links, image_picker_ios, package_info_plus, sensors_plus, share_plus, url_launcher_ios, geolocator_apple, record_ios trazem manifest vazio; path_provider_foundation e google_mlkit_* não trazem no pacote Flutter.
**Correção da rodada final**: o manifest usava a chave `NSPrivacyCollectedDataTypeLinkedToUser`, que não é a chave documentada; foi trocada por `NSPrivacyCollectedDataTypeLinked` (a que as SDKs publicadas usam; exemplos reais: documentação de manifests da Unity, https://docs.unity.com/authentication/en/manual/ApplePrivacySurvey, consultada em 20/10/2026). **Fonte oficial**: as páginas da Apple sobre o manifest (`describing-data-use-in-privacy-manifests` e `nsprivacycollecteddatatypes`) não carregaram pelo fetch em 20/10/2026 (só o título); as constantes de tipos e finalidades vêm das SDKs publicadas e de conhecimento prévio. As categorias e definições do App Store Connect (seção 1.1) vieram da página oficial `app-privacy-details`, que carregou.
**Pendente de Xcode**: abrir o projeto, conferir o arquivo em "Copy Bundle Resources" do alvo da extensão, rodar Archive e "Generate Privacy Report"; conferir as constantes `NSPrivacyCollectedDataType*` (não consegui ler a página da Apple sobre o manifest). Nenhuma validação iOS está concluída.

### 1.3 Geoapify (fonte: geoapify.com/privacy-policy e /terms-and-conditions, lidos em 20/10/2026)
- **Retém** (política): corpo da requisição, cabeçalhos, endereço IP e horário de cada chamada à API, para controle de acesso, contagem de uso, detecção de problemas e desempenho; guardados só o necessário para estatísticas agregadas e, para requisições com sucesso, "geralmente não mais de 24 horas". Hospedagem em data centers da UE (Hetzner); Cloudflare e Bunny CDN como processadores.
- **Não declarado na política (NÃO CONFIRMADO)**: se a chave de API é registrada, se texto/coordenadas ficam só dentro do "corpo", prazo para requisições com erro, truncamento do IP, e se a regra do IP vale para chamadas anônimas de API. Nossa app envia a chave na URL e as coordenadas/texto como parâmetros; é provável que entrem no log, mas a política não diz literalmente.
- **Conclusão para o ASC**: retenção de até ~24 h, legível, supera "tempo real": por cautela declarar Search History (não vinculado: a Geoapify não recebe conta nem uid) e Precise Location (já declarado, vinculado por causa dos locais salvos no Supabase). Dono pode escrever à Geoapify para obter retenção de requisições com erro e da chave.
- **Armazenar resultados**: os Termos não tratam de cache/armazenamento permanente; a página do produto Geocoding diz que não restringe guardar resultados (dados abertos), desde que se mantenha a atribuição da fonte junto ao dado; a página técnica do Geocoding não diz nada sobre armazenamento. O app guarda em `places` e no rolê `provider`, `provider_place_id`, nome, endereço e coordenadas (migração 20261017000000). Isso é **compatível com o que a Geoapify publica**, com a condição de atribuição: mapa e detalhe do local trazem "Powered by Geoapify" e créditos OSM/OpenMapTiles (`place_map.dart:220`; `place_detail_page.dart` cita Geoapify). Atribuição em todo uso futuro do dado guardado (exportação, compartilhamento): A CONFIRMAR.
- Plano gratuito: uso comercial permitido "com algumas limitações", atribuição obrigatória (Termos). Limites numéricos não lidos.

### 1.4 Região do Supabase (projeto jiisoqkryhmtopaojyyu)
**NÃO CONFIRMADO.** Fontes oficiais tentadas em 20/10/2026, todas sem a região:
- Repositório local principal (somente leitura): `supabase/.temp/` só tem `cli-latest`; não existe `pooler-url` nem `project-ref`. Não há `supabase/config.toml`. Os docs do repo não citam região.
- Variáveis de ambiente da sessão `SUPABASE_*`: nenhuma definida (nenhum token disponível, então não houve chamada à Management API). Nenhum token foi extraído de cofre ou arquivo de configuração.
- `supabase projects list` aqui só enxerga o projeto do OrbiJob.
Indício **não oficial, não usar nas lojas nem no site**: o host de banco resolve para um IPv6 dentro da faixa `2600:1f18::/33`, que a AWS publica como us-east-1. DNS não prova a região do projeto e não deve ser citado como confirmação.
**Passo exato para o dono**: abrir https://supabase.com/dashboard, escolher o projeto do Bebômetro > Project Settings > General > "Region" (ou a seção Infrastructure), tirar um print e enviar. Até lá, o site deve manter "provedores podem tratar dados em outros países".

## 2. Classificação etária: 18+

Decisão do dono: 18+. Não foi criada verificação de idade. Pela tabela oficial da Apple, "Alcohol, tobacco, or drug use or references": infrequente = 13+, **frequente = 18+** (Brasil A16). Os níveis oficiais usam só "Infrequent" e "Frequent" para essa categoria.

### 2.1 Apple (respostas candidatas; redação literal do formulário A CONFIRMAR dentro do ASC)
| Tema do questionário | Resposta |
|---|---|
| Alcohol, Tobacco, or Drug Use or References | **Frequent** (o app registra consumo de bebida alcoólica; resulta 18+, Brasil A16) |
| Profanity or Crude Humor | None |
| Horror/Fear Themes | None |
| Violence (cartoon/fantasy, realistic), Guns/Weapons | None |
| Sexual Content or Nudity | None (modo +18 dos jogos: "flerte e humor para adultos, nada explícito") |
| Mature/Suggestive Themes | Infrequent (modo +18 dos jogos) |
| Medical/Treatment Information; Health or Wellness Topics | Health or Wellness: Infrequent (estimativas de álcool e ressaca, sempre com aviso de que não medem alcoolemia) |
| Gambling, Simulated Gambling, Contests, Loot Boxes | None / No |
| Capabilities: Unrestricted Web Access | No (só abre mapa e site no navegador externo) |
| Capabilities: User-Generated Content | No (dados privados da conta, sem feed ou compartilhamento entre usuários) |
| Capabilities: Messaging and Chat; Advertising | No |
| Capabilities: Parental Controls; Age Assurance | None |
| Override to higher age rating / Made for Kids | Not Applicable / não |
| Age Suitability URL (opcional) | https://lucksrei.com/projects/bebometro/terms/ (A CONFIRMAR que a página cita 18+) |

### 2.2 Google Play (IARC; categorias candidatas, formulário A CONFIRMAR no Play Console)
Categoria do app: utilitário/estilo de vida (não jogo). Respostas: Violence: não; Sexuality: não (conteúdo sugestivo leve só no modo +18); Language: não; **Controlled substances: sim, referência ao consumo de álcool, sem incentivo a excesso** (o app informa e registra); Gambling: não; Users can interact: não; Shares user location with other users: não; Digital purchases: não; Anúncios: não. Resultado esperado: classificação adulta (IARC/PEGI/ESRB a calcular pelo Play). Público-alvo no Play: **18+ apenas**, não marcar crianças (Families policy não se aplica). Resposta inexata pode levar a remoção (política "Content ratings").

### 2.3 Verificação de coerência com 18+
- Nada no app diz "para todas as idades" ou "família/crianças" (grep em pt/en/es, cartas e docs). Único texto ambíguo: `gameLightNote` ("Para qualquer turma"/"For any group"). **Alterado** para "turma adulta"/"any adult group"/"grupo de adultos".
- Não há verificação de idade (decisão: não criar). Existe a confirmação de adultos no modo +18 dos jogos (`game_setup_page.dart:261`).
- Apple 1.4.3: o app não incentiva excesso; "Mais uma" é só atalho de registro. Texto novo de redução de riscos no resumo (item 8).
- A política publicada já diz "destinado a maiores de 18" (alinhado). Os Termos devem dizer o mesmo (A CONFIRMAR no site).

## 3. Permissões
| Plataforma | Permissão | Finalidade | Uso real |
|---|---|---|---|
| iOS | NSCameraUsageDescription | fotografar rótulo/cardápio | `image_capture.dart` |
| iOS | NSPhotoLibraryUsageDescription | escolher foto | idem |
| iOS | NSLocationWhenInUse | locais próximos | `device_location.dart` |
| iOS | NSMicrophone | bafômetro de brincadeira | `breath_input.dart` |
| iOS | NSMotion | inclinar o copo | `sensors_plus` |
| iOS | NSSupportsLiveActivities | atividade na tela bloqueada | extensão |
| iOS | ~~NSPhotoLibraryAddUsageDescription~~ | **removida** | ver abaixo |
| Android | INTERNET, POST_NOTIFICATIONS, RECORD_AUDIO, ACCESS_COARSE/FINE_LOCATION | idem | uso comprovado; nada removido |

**NSPhotoLibraryAdd removida (prova)**: grep no código nativo dos plugins do `pubspec.lock` (image_picker_ios 0.8.13+10, share_plus 10.1.4, url_launcher_ios, sensors_plus, geolocator_apple, record_ios, path_provider_foundation, shared_preferences_foundation, app_links, package_info_plus, google_mlkit_*, supabase_flutter) por `UIImageWriteToSavedPhotosAlbum`, `PHAssetCreationRequest`, `PHAssetChangeRequest`: nenhum. `image_picker_ios` só lê (PHPicker e checagem de status). Nenhum arquivo `.swift` do app usa `PHPhotoLibrary`. O "Salvar imagem" do share sheet é feito pelo sistema. Removida do `Info.plist` e dos três `InfoPlist.strings`. Risco residual: **pendente de teste em aparelho** (salvar imagem pelo share sheet).

## 4. Backups
**O que o app persiste (CONFIRMADO NO CÓDIGO)**: `FlutterSharedPreferences.xml` (Android) / `UserDefaults` (iOS) contém a cópia local dos registros (`local_store.dart`), preferências e **a sessão do Supabase** (supabase_flutter grava o token no mesmo armazenamento); `bebometro_tracking.xml` (estado da tela bloqueada, `TrackingNotifier.kt:31`); fotos em `<documentos>/outing_photos/` (`photo_files_io.dart:19`; Android: `app_flutter/outing_photos/`). Exportações não ficam em disco: vão direto ao share sheet.
**Android** (novo): `android:allowBackup="true"`, `android:dataExtractionRules="@xml/data_extraction_rules"` (Android 12+) e `android:fullBackupContent="@xml/backup_rules"` (Android 11-). Backup em nuvem (Google) **exclui** `FlutterSharedPreferences.xml` (sessão e cópia local), `bebometro_tracking.xml` e `app_flutter/outing_photos/`; a transferência aparelho-a-aparelho (`<device-transfer/>`) mantém tudo no Android 12+. Efeito: ao restaurar de backup na nuvem o usuário entra de novo (a senha ele tem) e o histórico volta da conta; registros ainda não sincronizados e fotos não confirmadas daquele aparelho não vêm. No Android 11-, que não separa nuvem de transferência, as mesmas exclusões valem para ambos. Não desliguei o backup: a restauração continua funcionando.
**iOS: NÃO aprovado.** Evidência (código do app e do pacote `supabase_flutter` 2.18.3, `lib/src/local_storage.dart`): sem `localStorage` customizado em `lib/core/di/injector.dart:87`, a sessão é salva por `SharedPreferencesLocalStorage` e o verificador PKCE por `SharedPreferencesGotrueAsyncStorage`, ambos em `SharedPreferences`, que no iOS é o `UserDefaults.standard` (plist em `Library/Preferences/<bundle>.plist`). Esse plist **entra no backup do iTunes/iCloud** (Library, exceto Caches e tmp). `Documents/outing_photos` também entra (path_provider usa `Documents`).

| Dado | Onde (iOS) | Entra no backup iOS | Sensibilidade | Mitigação possível |
|---|---|---|---|---|
| Sessão Supabase (access e refresh token, uid, e-mail do usuário dentro do JSON da sessão) | UserDefaults plist (chave de sessão do supabase_flutter) | **Sim** | **Alta** (o refresh token permite abrir a conta em outro aparelho) | `LocalStorage` próprio no Keychain com `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` (não migra em backup para outro aparelho). Exige dependência nativa nova (ex.: flutter_secure_storage) e `pod install`; plano de migração: no primeiro start ler a chave antiga do SharedPreferences, gravar no Keychain, apagar a antiga; se falhar, pedir novo login. **Não implementado** (sem Xcode e sem aparelho não dá para testar) |
| Código PKCE (verifier) | UserDefaults | Sim | Média, curta duração | mesma mitigação |
| Registros locais (rolês, bebidas, locais com lat/lng, comandas com apelidos, notas, humor/ressaca, `source_text` do OCR, fila `sync.pending`, cursores) | UserDefaults (`local_store.dart`, chaves `col.*`, `rev.*`, `sync.pending`) | **Sim** | Alta (conteúdo pessoal e dados de saúde informados) | só excluir tudo exigiria sair do UserDefaults (mover para arquivo em Application Support com `isExcludedFromBackup`); mudança grande de armazenamento, **proposta** com migração de dados; benefício limitado porque esses dados também estão na conta |
| `last_uid`, `last_email`, nome de exibição, preferências, favoritos, estado de jogos | UserDefaults (`auth_controller.dart:272-273`, `device_store.dart`) | **Sim** | Média (e-mail) | idem |
| Fotos de rótulo/cardápio ainda não confirmadas e confirmadas | `Documents/outing_photos/*.jpg` | **Sim** | Alta | `NSURLIsExcludedFromBackupKey` no diretório (código nativo, ~15 linhas em Swift via MethodChannel, **proposta**; risco: foto não confirmada fica sem cópia se o aparelho for perdido). Mover para Library/Caches não é recomendado: o sistema pode apagar |
| Estado da tela bloqueada (`tracking.commands`) | UserDefaults (app e extensão) | Sim | Baixa | nenhuma necessária |
| Exportações (JSON/CSV/ZIP) | não ficam em disco (vão direto ao share sheet); a cópia temporária do share_plus fica em tmp | Não | n/a | n/a |

Conclusão: no iOS o backup cifrado do usuário carrega sessão, registros e fotos. A mitigação que realmente importa é o Keychain ThisDeviceOnly para a sessão; ela não foi implementada e **fica como pendência de decisão do dono e de teste no Mac/aparelho**. Até lá o risco é o de qualquer app que usa o armazenamento padrão do supabase_flutter (backup protegido pela conta Apple do usuário).
**Pendente de teste em aparelho (Android)**: `adb shell bmgr backupnow` e `bmgr restore`, e transferência D2D, para ver as regras valendo.

## 5. Retenção de registros com `deleted_at` (política proposta)
### 5.0 Impacto verificado por análise de código (rodada final)
- **Sincronização** (`lib/core/sync/cloud_pull.dart`, `local_store.dart`, `sync_cubit.dart`, migração `20261018000000`): a exclusão é uma linha com `deleted_at` (tombstone) que o servidor carimba com `server_updated_at` e `revision`; os outros aparelhos a recebem no próximo pull incremental (cursor por `server_updated_at`, janela de 2 min). O envio (`_upsert`) só manda linhas com edição pendente, por UUID. Consequências de purgar cedo: (1) um aparelho que ficou offline além da janela nunca recebe o tombstone e continua exibindo o item apagado; (2) se esse aparelho editar o item (ou tiver edição pendente), o upsert **recria** a linha no servidor (revision 1): ressurreição. Não há limite de tempo que o servidor possa impor a um aparelho offline; janela maior só reduz a chance.
- **Exportação**: não inclui apagados (JSON filtra `deleted_at == null`, CSV usa repositórios que filtram, pacote ZIP só fotos sem `deleted_at`). A purga não muda a exportação.
- **Backup**: um backup antigo restaurado depois da purga (iOS, ou Android por transferência aparelho-a-aparelho) traz itens que já foram apagados e não recebe mais o tombstone: o item volta a aparecer e pode ser reenviado se for editado. No backup em nuvem do Android as regras novas excluem os registros locais, então o aparelho restaurado começa do zero e puxa só o que existe.
- **Fotos**: a linha só deve ser purgada com `storage_path` nulo (objeto já removido), senão o arquivo fica órfão no Storage.
- **Cascata**: apagar um `outings` apaga as linhas filhas por `on delete cascade`; a purga de um rolê só vale se não houver filho vivo.
- **Script endurecido (ainda NÃO APLICAR, não executado)**: piso de 90 dias e padrão de **180**; `outing_photos` só com `storage_path` nulo; `outings` só sem filhos vivos. **Proposta de salvaguarda no app (não implementada)**: se o último pull completo for mais antigo que a janela, fazer reconciliação completa (listar ids vivos no servidor e marcar como apagados os locais ausentes e sem edição pendente).

Tabelas com `deleted_at` (CONFIRMADO nas migrações): outings, places, custom_drinks, drink_entries, outing_drinks, outing_photos, outing_tabs. Hoje nada apaga essas linhas; ficam até a exclusão da conta.
- **Proposta do dono (a decidir): purgar 180 dias após a exclusão (piso 90).** Justificativa: a exclusão precisa chegar (tombstone) a todos os aparelhos da pessoa; 180 dias cobre aparelho secundário offline por meses e evita guardar dado "apagado" para sempre. Contra: um aparelho offline por mais que a janela pode reenviar o registro apagado. O texto de privacidade passa a ser mais forte e verificável.
- Fotos: o app remove o objeto do Storage quando a pessoa apaga a foto (o `storage_path` fica nulo depois); linhas marcadas com `storage_path` ainda preenchido têm objeto a remover pela API do Storage antes de qualquer purga SQL.
- **Scripts preparados, NÃO executados, NÃO migração**: `supabase/ops/report_deleted_rows.sql` (somente leitura: contagem por tabela e idade) e `supabase/ops/purge_deleted_rows.DO_NOT_APPLY.sql` (função idempotente, em lotes, por idade, com dry-run, backup em `purge_backup` na mesma transação, plano de rollback e passo A descrito para os arquivos). Não foram rodados contra nenhum banco; a sintaxe não foi validada em Postgres.
- **Texto sugerido para o site, depois da decisão**: "Quando você apaga um item no app, ele some das suas listas e dos seus aparelhos. No servidor ele fica marcado como apagado por até 180 dias, para que a exclusão chegue a todos os seus aparelhos, e depois é removido definitivamente. Fotos apagadas são removidas da área privada na hora da exclusão."

## 6. URLs, contato e textos de loja
- Marketing: https://lucksrei.com/projects/bebometro/
- Suporte: https://lucksrei.com/projects/bebometro/support/
- Privacidade (ASC e Play): https://lucksrei.com/projects/bebometro/privacy/
- Termos: https://lucksrei.com/projects/bebometro/terms/
- Exclusão de conta/dados (Play "Data deletion"): https://lucksrei.com/projects/bebometro/data-deletion/
- Copyright (provisório, sujeito à confirmação do dono): © 2026 LUCAS DIOGO FRANCA
- E-mail de contato público: marketing@lucksrei.com. **Não usar telefone/WhatsApp como contato público nas lojas.**
- No app: Configurações > "Privacidade e suporte" (`legal_links_section.dart`).

## 7. Itens 8 e 9 desta rodada
- Resumo do rolê: texto "Beba com moderação. Se beber, não dirija." (en/es equivalentes) logo após a explicação do álcool, só quando o rolê tem bebida alcoólica (`outing_summary_page.dart`).
- Exportação completa opcional (ZIP) com fotos, `manifest.json` (SHA-256 por arquivo e totais), verificação final de integridade e aviso do que ficou de fora; ver `docs/export-format.md`. Foto só na nuvem pode ocorrer (outro aparelho/reinstalação traz as linhas, não os arquivos) e é baixada com a sessão da própria pessoa. Limites: ZIP em memória (150 MB de fotos); o download usa `storage.download` autenticado, não URL assinada.

## 8. Divergências site x código (para corrigir o site)
1. Região: se confirmar EUA, dizer "tratados nos EUA"; o site hoje só diz "outros países".
2. Backup do sistema: citar backup do Android/iOS e as exclusões desta rodada (depois de testadas).
3. Retenção de apagados: hoje o site diz "marcado como excluído" sem prazo; incluir o prazo escolhido (texto sugerido na seção 5).
4. Exportação: incluir o pacote com fotos; o JSON simples continua só com metadados das fotos.
5. Geoapify: acrescentar que a Geoapify pode reter a requisição (texto, coordenadas, IP) por até cerca de 24 h (política dela) e que isso é declarado como Search History/Location.
6. Saúde e finanças: o site diz o que é guardado, mas vale citar humor/ressaca como dado de saúde informado pelo usuário.
7. 18+: manter igual nos Termos e na política.
8. Exclusão de conta exige login recente (10 min).

## 9. Decisões e perguntas pendentes do dono
1. Declarar Other Financial Info junto com Purchase History, ou só Purchase History? 2. Confirmar a região do Supabase no painel. 3. Aprovar 180 dias (piso 90; ou outro) e autorizar a execução do script de purga (após relatório e backup). 4. Aceitar backup do iOS incluindo a sessão e as fotos. 5. Confirmar copyright e e-mail de loja. 6. Conferir o texto 18+ nos Termos. 7. Escrever à Geoapify sobre retenção de erros e chave (opcional).

## 10. Riscos
- Manifests, `project.pbxproj` e entitlements sem Xcode: pendente de Archive e Privacy Report.
- Regras de backup Android não testadas em aparelho; erro de caminho deixaria o arquivo em backup (falha segura, nunca perda de dado).
- Scripts de purga não rodados; uma purga mal escolhida é irreversível para arquivos do Storage.
- Respostas de classificação etária são candidatas; a redação literal dos formulários ASC e IARC precisa ser conferida lá.

## 11. Campos finais sugeridos para o App Store Connect (propostos, nada submetido)
| Campo | Valor sugerido |
|---|---|
| App Privacy: tipos coletados | Email Address, Name, Health, Other Financial Info, Purchase History, Precise Location, Search History, Photos or Videos, Other User Content, User ID |
| Para cada tipo | Purposes: **App Functionality**; Tracking: **No**; Linked to identity: **Yes**, exceto Search History = **No** |
| Não coletado | Payment Info, Credit Info, Contacts, Sensitive Info, Browsing History, Device ID, Usage Data, Diagnostics, Audio, Gameplay Content, Customer Support, Other Data |
| Classificação etária | proposta **18+** (Alcohol, Tobacco, or Drug Use or References = Frequent; demais conforme 2.1); redação literal do questionário a conferir no ASC |
| Privacy Policy URL | https://lucksrei.com/projects/bebometro/privacy/ |
| Support URL | https://lucksrei.com/projects/bebometro/support/ |
| Marketing URL | https://lucksrei.com/projects/bebometro/ |
| Termos | https://lucksrei.com/projects/bebometro/terms/ |
| Exclusão de conta (Play) | https://lucksrei.com/projects/bebometro/data-deletion/ |
| Copyright (provisório) | © 2026 LUCAS DIOGO FRANCA |
| Contato público | marketing@lucksrei.com (sem telefone nem WhatsApp) |

Coerência 18+ verificada em 20/10/2026: página do app, política, termos (seção 5) e suporte do site dizem "destinado a maiores de 18"; no app o `gameLightNote` foi ajustado para "turma adulta"; nenhum texto fala em crianças/família. Validação iOS completa: ver `docs/app-store/xcode-validation-checklist.md` (pendente de Mac).
