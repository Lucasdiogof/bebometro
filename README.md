# Bebômetro

App brasileiro para registrar bebidas, gastos e o histórico dos seus rolês.

Fluxo principal: Home → iniciar rolê → registrar bebida → **Mais uma** → encerrar → resumo → histórico.

## Stack

- Flutter (Android e iOS; web suportado), Cubit/BLoC + get_it.
- Supabase (autenticação anônima + Postgres com RLS).

## Estrutura

```
lib/
  core/      config, DI, tema, formatação, armazenamento local, sincronização
  home/      tela inicial e prompt de feedback pós-rolê
  outings/   rolê: domínio, repositório, telas (iniciar, rolê, resumo)
  drinks/    catálogo, registro de bebida, garrafa compartilhada
  history/   lista de rolês encerrados
supabase/migrations/   esquema versionado
```

## Dados e sincronização

Tudo é gravado primeiro no aparelho (SharedPreferences) e então enviado ao Supabase com
IDs UUID gerados no cliente, o que torna repetições idempotentes. Se a nuvem estiver
indisponível, o app segue funcionando e mostra o estado de sincronização.

Para a sincronização funcionar, habilite **Authentication → Providers → Allow anonymous
sign-ins** no projeto e aplique `supabase/migrations/`.

Valores monetários ficam em centavos; horários em UTC (exibidos no horário local).

## Rodando

```
flutter pub get
flutter run
```

A URL e a publishable key do Supabase têm padrão em `lib/core/config/env.dart` e podem ser
sobrescritas com `--dart-define=SUPABASE_URL=...` e `--dart-define=SUPABASE_PUBLISHABLE_KEY=...`.
