# Bebômetro: checklist de produto

Quatro estados são mantidos **separados**: **Código** (implementado em código), **Externo** (configurado fora do
repositório), **Execução** (verificado rodando) e a situação (**Parcial**, **Pendente**, **Bloqueado**).
Não há percentual de conclusão: nada foi compilado, analisado nem executado até aqui (sem `pub get`, `analyze`, testes
ou builds por decisão da rodada), então a coluna **Execução** está vazia em todo o documento.

Fora de escopo: leitura de código de barras e Pix/cobrança bancária. Monitoramento de erros e ambientes separados ficam
para as últimas etapas e não foram começados.

## Funcionalidades

| Item | Código | Externo | Execução | Situação |
|------|--------|---------|----------|----------|
| Rolê: iniciar, editar, encerrar, feedback, orçamento, preços ausentes | Sim | n/a | Não | Pendente validar |
| Catálogo (v6: 136 produtos, 20 bebidas prontas; sem ampliação nesta rodada), "Sobre estes dados" por campo (procedência por campo: implementada; 55 produtos com `fieldSources`), filtros, favoritos, recentes, "Mais uma", água, desfazer | Sim | Migration `20261019000000` (categoria nova) **pendente** | Não | Pendente validar |
| Pipeline de atualização do catálogo (`tools/catalog_sync`: coletar → comparar → proposta → `catalog_tool.py merge`) | Sim (exercitado por script: `selftest`, `check`, `ids HEAD`) | n/a | Não (Flutter) | Parcial: um coletor (HEINEKEN Brasil); fontes adicionais são melhoria futura e não bloqueiam o app |
| Flutter nesta rodada | n/a | n/a | Não validado (sem `pub get`, `analyze`, testes ou builds) | Pendente validar |
| Receitas de referência e próprias, composição, avisos de dado incompleto | Sim | n/a | Não | Pendente validar |
| Bebidas por foto (rótulo/cardápio), itens só do rolê, rascunhos | Sim | Migration `20261015000000` aplicada pelo dono | Não | Heurísticas de OCR não validadas |
| Locais salvos e mapa (Geoapify) | Sim | Chave `GEOAPIFY_KEY` **não configurada**; migration `20261017000000` aplicada | Não | Parcial (depende da chave) |
| Comanda e divisão (equal/item/personalizado, pagamentos manuais) | Sim | Migration `20261016000000` aplicada | Não | Sem testes de unidade do cálculo |
| Histórico, estatísticas, exportação, cartão compartilhável | Sim | n/a | Não | Pendente validar |
| Mesa ilustrada | Sim | n/a | Não | Pendente validar |
| Simulador de cerveja em tela cheia (sensores) | Sim | n/a | Não | Eixos no iOS e desempenho por observar |
| Jogos offline (3 jogos, 134 cartas, Leve/+18, cartas próprias) | Sim | n/a | Não | Pendente validar |
| Rolê na tela bloqueada (Live Activity, Dynamic Island, notificação Android) | Sim (Dart, Swift, Kotlin) | Assinatura (Team) no Xcode **pendente** | Não | `project.pbxproj` editado à mão |
| Internacionalização pt-BR/en/es | Sim | E-mails do Supabase **não aplicados** | Não | Ver `docs/i18n-checklist.md` |

## Visual

| Item | Situação |
|------|----------|
| Design system e telas | Escritos; **nenhuma tela foi renderizada** |
| Textos longos em en/es (botões, chips, rótulos) | Não verificado em tela; en/es costumam ser mais longos que pt |
| Fonte grande, teclado aberto, layout largo na web | Pendente |
| Capturas de tela | Não incluídas (sem execução) |

## Conta e dados

| Item | Código | Externo | Execução |
|------|--------|---------|----------|
| Conta obrigatória (e-mail e senha), cadastro entra direto, perfil | Sim | SMTP aplicado; "Confirm email" desligado de propósito (lido pela API pública em 14/10) | Não |
| Recuperação de senha por código de 6 dígitos | Sim (`verifyOTP` tipo `recovery`) | Template `recovery.html` com `{{ .Token }}` e `mailer_otp_length = 6` **não aplicados/lidos daqui** (sem token administrativo): `scripts/apply_recovery_code.py` | Não |
| Sincronização com leitura da nuvem, conflitos, exclusões | Sim | Migration `20261018000000` aplicada pelo dono | Não |
| Excluir conta | Sim | Função `delete-account` **não publicada** | Não |
| Persistência local por conta | Sim | n/a | Não |

## Banco e migrations

Todas até `20261018000000_accounts_sync.sql` foram **aplicadas pelo dono** (não verificado daqui). **Nova e pendente:**
`20261019000000_ready_to_drink_category.sql` (idempotente; só amplia os `check` de categoria). Detalhes: `docs/development-progress.md`.

## Configurações externas pendentes

Passo a passo e estado real (implementado / configurado / verificado pela API / validado no app): [`external-setup.md`](external-setup.md).
Geoapify: chave dedicada configurada em `env.json` local (verificada por HTTP); mapa e busca ainda **não validados no app**.

1. Aplicar o template de recuperação por código e conferir `mailer_otp_length = 6`: `SUPABASE_ACCESS_TOKEN=... python -I scripts/apply_recovery_code.py --apply` (só mexe nesses campos e confere que o resto não mudou). Depois, pedir um código para uma conta própria e concluir a troca de senha no app.
2. Deploy de `delete-account`.
3. Templates de e-mail trilíngues (`supabase/email-templates/`, ver `docs/auth-emails.md`).
4. Chave Geoapify (`GEOAPIFY_KEY`) e `flutter pub get` dos pacotes novos.
5. Assinatura (Team) do app e da extensão no Xcode.

## Android, iOS e web

| Plataforma | Estado |
|------------|--------|
| Android | Notificação de acompanhamento e sensores escritos; não compilado |
| iOS | Live Activity (iOS 16.2+), `InfoPlist.strings` (en/es/pt-BR, idioma do sistema), extensão no projeto à mão; não compilado |
| Web | Sem OCR automático, sem sensores (arrasto), acompanhamento só dentro do app; não executado |

## Validação (tudo pendente)

`flutter pub get`, `flutter analyze` (esperar erros de compilação), testes (inexistentes para comanda, parser, formatação
e i18n), QA em aparelho Android/iOS e navegador nos três idiomas, conferência da sincronização no painel, e-mails de
autenticação nos três idiomas com conta própria.

## Preparação para as lojas

Não iniciada além do que já existe: ícones/branding presentes; faltam textos de loja em en/es, política de privacidade
publicada, capturas reais, assinatura, descrições de permissão revisadas e revisão de classificação etária (conteúdo
sobre bebidas alcoólicas e modo +18 dos jogos).
