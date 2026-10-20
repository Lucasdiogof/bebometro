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

### 1.1 Financial Info x Purchases (decisão e dúvida)
Definições Apple: Payment Info = forma/cartão/conta bancária (não se aplica: nada disso existe no app); Credit Info = score (não); **Other Financial Info = "salary, income, assets, debts, or any other financial information"**; **Purchase History = "an account's or individual's purchases or purchase tendencies"**.
- Preços pagos por bebida e histórico de gastos = compras/tendências de compra, então **Purchase History: declarar**.
- Orçamento do rolê, divisão da conta e "pagamentos anotados" (quem pagou/deve quanto) = valores digitados pelo usuário que se aproximam de "debts / any other financial information": **Other Financial Info: declarar com cautela**.
- Pró de declarar os dois: a Apple costuma preferir declaração cautelosa; omitir o que um revisor entende como coletado arrisca rejeição ou correção forçada. Contra: o rótulo público fica mais carregado ("Financial Info" parece cartão/banco ao usuário, embora aqui seja só anotação). **Ambiguidade explícita**: é defensável tirar Other Financial Info (argumento: são anotações pessoais de rateio, sem valor financeiro real do usuário) e manter só Purchase History. Decisão atual do manifest e desta tabela: declarar ambos; o dono pode reduzir.

### 1.2 Manifest x App Store Connect
O `PrivacyInfo.xcprivacy` alimenta o Privacy Report do Xcode; o ASC é a declaração pública e deve repetir a tabela acima. Estado do manifest (`ios/Runner/PrivacyInfo.xcprivacy`): tracking=false; 10 tipos (Email, Name, UserID, PreciseLocation, PhotosorVideos, OtherUserContent, Health, OtherFinancialInfo, PurchaseHistory, SearchHistory) com propósito `NSPrivacyCollectedDataTypePurposeAppFunctionality`; só SearchHistory com `LinkedToUser=false`. Required-reason API: UserDefaults `CA92.1` (`TrackingChannel.swift:20`). Extensão (`ios/BebometroLiveActivity/PrivacyInfo.xcprivacy`, novo, no `project.pbxproj`): sem dados, UserDefaults `CA92.1`. Plugins: `shared_preferences_foundation` declara `1C8F.1`; app_links, image_picker_ios, package_info_plus, sensors_plus, share_plus, url_launcher_ios, geolocator_apple, record_ios trazem manifest vazio; path_provider_foundation e google_mlkit_* não trazem no pacote Flutter.
**Pendente de Xcode**: abrir o projeto, conferir o arquivo em "Copy Bundle Resources" do alvo da extensão, rodar Archive e "Generate Privacy Report"; conferir as constantes `NSPrivacyCollectedDataType*` (não consegui ler a página da Apple sobre o manifest). Nenhuma validação iOS está concluída.

### 1.3 Geoapify (fonte: geoapify.com/privacy-policy e /terms-and-conditions, lidos em 20/10/2026)
- **Retém** (política): corpo da requisição, cabeçalhos, endereço IP e horário de cada chamada à API, para controle de acesso, contagem de uso, detecção de problemas e desempenho; guardados só o necessário para estatísticas agregadas e, para requisições com sucesso, "geralmente não mais de 24 horas". Hospedagem em data centers da UE (Hetzner); Cloudflare e Bunny CDN como processadores.
- **Não declarado na política (NÃO CONFIRMADO)**: se a chave de API é registrada, se texto/coordenadas ficam só dentro do "corpo", prazo para requisições com erro, truncamento do IP, e se a regra do IP vale para chamadas anônimas de API. Nossa app envia a chave na URL e as coordenadas/texto como parâmetros; é provável que entrem no log, mas a política não diz literalmente.
- **Conclusão para o ASC**: retenção de até ~24 h, legível, supera "tempo real": por cautela declarar Search History (não vinculado: a Geoapify não recebe conta nem uid) e Precise Location (já declarado, vinculado por causa dos locais salvos no Supabase). Dono pode escrever à Geoapify para obter retenção de requisições com erro e da chave.
- **Armazenar resultados**: os Termos não tratam de cache/armazenamento permanente; a página do produto Geocoding diz que não restringe guardar resultados (dados abertos), desde que se mantenha a atribuição da fonte junto ao dado; a página técnica do Geocoding não diz nada sobre armazenamento. O app guarda em `places` e no rolê `provider`, `provider_place_id`, nome, endereço e coordenadas (migração 20261017000000). Isso é **compatível com o que a Geoapify publica**, com a condição de atribuição: mapa e detalhe do local trazem "Powered by Geoapify" e créditos OSM/OpenMapTiles (`place_map.dart:220`; `place_detail_page.dart` cita Geoapify). Atribuição em todo uso futuro do dado guardado (exportação, compartilhamento): A CONFIRMAR.
- Plano gratuito: uso comercial permitido "com algumas limitações", atribuição obrigatória (Termos). Limites numéricos não lidos.

### 1.4 Região do Supabase (projeto jiisoqkryhmtopaojyyu)
- `supabase/config.toml` e documentos do repo: não trazem a região. `supabase projects list` aqui só enxerga o OrbiJob. Nenhum token foi extraído.
- Evidência pública, sem credenciais: `db.jiisoqkryhmtopaojyyu.supabase.co` resolve (DNS) para o IPv6 `2600:1f18:5b28:203:5f27:76bc:24fc:5d18`, que está dentro de `2600:1f18::/33`, publicado pela AWS em `ip-ranges.json` como **us-east-1** (EC2). O host da API (`<ref>.supabase.co`) está atrás da Cloudflare e não revela região.
- Conclusão: **indício forte de AWS us-east-1 (Norte da Virgínia, EUA), NÃO CONFIRMADO oficialmente**. Passo do dono: painel Supabase > Project Settings > General > Region (ou Infrastructure). Implicação: se for EUA, a política deve dizer que os dados são tratados nos EUA (transferência internacional, LGPD art. 33).

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
**iOS**: `UserDefaults` não permite excluir uma chave do backup do iCloud/iTunes, então a sessão acompanha o backup do aparelho (o backup do iOS é criptografado quando o usuário o cifra). Fotos em `Documents/outing_photos` entram no backup; **decisão: manter** (protege fotos ainda não confirmadas contra perda; `NSURLIsExcludedFromBackupKey` exigiria código nativo não testável aqui). **Risco aceito e pendente de decisão do dono**.
**Pendente de teste em aparelho**: `adb shell bmgr backupnow` / `bmgr restore` e transferência D2D, para ver as regras valendo.

## 5. Retenção de registros com `deleted_at` (política proposta)
Tabelas com `deleted_at` (CONFIRMADO nas migrações): outings, places, custom_drinks, drink_entries, outing_drinks, outing_photos, outing_tabs. Hoje nada apaga essas linhas; ficam até a exclusão da conta.
- **Proposta do dono (a decidir): purgar 90 dias após a exclusão.** Justificativa: a exclusão precisa chegar (tombstone) a todos os aparelhos da pessoa; 90 dias cobre aparelho secundário offline por meses e evita guardar dado "apagado" para sempre. Contra: um aparelho offline por mais de 90 dias pode reenviar o registro apagado. O texto de privacidade passa a ser mais forte e verificável.
- Fotos: o app remove o objeto do Storage quando a pessoa apaga a foto (o `storage_path` fica nulo depois); linhas marcadas com `storage_path` ainda preenchido têm objeto a remover pela API do Storage antes de qualquer purga SQL.
- **Scripts preparados, NÃO executados, NÃO migração**: `supabase/ops/report_deleted_rows.sql` (somente leitura: contagem por tabela e idade) e `supabase/ops/purge_deleted_rows.DO_NOT_APPLY.sql` (função idempotente, em lotes, por idade, com dry-run, backup em `purge_backup` na mesma transação, plano de rollback e passo A descrito para os arquivos). Não foram rodados contra nenhum banco; a sintaxe não foi validada em Postgres.
- **Texto sugerido para o site, depois da decisão**: "Quando você apaga um item no app, ele some das suas listas e dos seus aparelhos. No servidor ele fica marcado como apagado por até 90 dias, para que a exclusão chegue a todos os seus aparelhos, e depois é removido definitivamente. Fotos apagadas são removidas da área privada na hora da exclusão."

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
1. Declarar Other Financial Info junto com Purchase History, ou só Purchase History? 2. Confirmar a região do Supabase no painel. 3. Aprovar 90 dias (ou outro) e autorizar a execução do script de purga (após relatório e backup). 4. Aceitar backup do iOS incluindo a sessão e as fotos. 5. Confirmar copyright e e-mail de loja. 6. Conferir o texto 18+ nos Termos. 7. Escrever à Geoapify sobre retenção de erros e chave (opcional).

## 10. Riscos
- Manifests, `project.pbxproj` e entitlements sem Xcode: pendente de Archive e Privacy Report.
- Regras de backup Android não testadas em aparelho; erro de caminho deixaria o arquivo em backup (falha segura, nunca perda de dado).
- Scripts de purga não rodados; uma purga mal escolhida é irreversível para arquivos do Storage.
- Respostas de classificação etária são candidatas; a redação literal dos formulários ASC e IARC precisa ser conferida lá.
