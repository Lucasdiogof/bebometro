<p align="center">
  <img src="assets/branding/logo_cap.png" width="112" alt="Bebômetro">
</p>

<h1 align="center">Bebômetro</h1>

<p align="center">Track your drinks, spending and nights out — with a table that tells the story.</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Supabase-3FCF8E?logo=supabase&logoColor=white" alt="Supabase">
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/platforms-Android_·_iOS_·_Web-555555" alt="Android · iOS · Web">
</p>

<p align="center"><b>English</b> · <a href="README.pt-BR.md">Português</a> · <a href="README.es.md">Español</a></p>

---

Bebômetro is a Brazil-focused app for recording a *rolê*: an outing at a bar, a barbecue, a party or an evening with friends. Start a session, add drinks, repeat your last order with **Mais uma** (“One more”), and finish with a breakdown of what you recorded and spent.

## Availability

- **Platforms:** Android and iOS are the priority; the project also targets Flutter web.
- **App language:** Portuguese (Brazil). These READMEs are available in English, Portuguese and Spanish; this does not imply a multilingual app.
- **Appearance:** dark theme, amber accents, a bottle-cap **B** icon and a separate wordmark.
- **Stage:** active development; no store release is documented in this repository.

> **Validation status — October 13, 2026:** the features below are implemented in source code. The development handoff reports no Flutter compilation, device execution or visual validation for this delivery. Supabase API checks do not establish end-to-end app synchronization. See the [development checklist](docs/development-progress.md).

## The outing flow

1. Start an outing with a nickname or address and a setting.
2. Choose a product, recipe or custom drink; enter your portion and an optional price.
3. Repeat an order with **Mais uma**, or record water separately.
4. Follow the list or illustrated table, with spending and budget information.
5. End the outing, review the summary and revisit it in your history.
6. On a later app opening, optionally describe how the outing went.

## Features

**Outings and quick logging**

- One active outing, restored from local storage; editable times and entries.
- One-tap repetition with undo, preserving the recorded recipe and portion. Water does not replace the last alcoholic-drink shortcut.
- Shared bottles with equal or custom portions and leftovers. A 600 ml bottle split equally between three people records 200 ml for the user.
- Consumption and payment are separate: paying for a bottle does not mean drinking it all.

**Catalog and recipes**

- Bundled, versioned catalog of beers, draft beers, alcohol-free products, spirits and aperitifs, plus cocktail reference recipes.
- Search by product, brand, style and aliases; category, brand, style and presentation filters, favorites and recents.
- Product details include available presentations, declared ingredients, alcohol content and source information where known.
- Editable recipe components and units; personal drinks and recipes can currently be edited, duplicated and deleted without changing past entries.
- Each consumption entry keeps a snapshot. Later catalog or recipe edits do not rewrite history.

**Drinks from photos (outing only)**

- *Label:* camera or gallery photo, rotate/replace, local text reading, review, then either “Confirm and continue” (opens the normal consumption form) or “Save only in this outing” (no consumption is recorded).
- *Menu:* one or more photos produce reviewable candidates; fix, discard or add items by hand. Saving items does not record consumption, and the advertised price is only a suggestion: you confirm what was actually paid.
- *Reading unavailable* (web, denied permission, empty result): the photo stays visible and you type or paste the text, or fill the item in by hand. Results are never simulated.
- *Manual sign-up inside an outing* uses the same review screen. Outside an outing, “My drinks” works as before.
- Everything created this way belongs to that outing's ID: it is not in the global catalog, “My drinks”, favorites, recents, other outings or future price suggestions, and it stays in that outing's history, also past midnight. Unfinished readings stay tied to their original outing.
- Photos are local files (not base64) and can be deleted without losing the confirmed drink data. A private cloud bucket receives them when synchronization works.

**Your table**

- Table/list switch and six settings: bar, nightclub, barbecue, home, beach and restaurant.
- Illustrated cans, bottles, glasses and other vessels, grouped when the table gets crowded.
- Optional decorative emptying animation, reduced-motion support and an empty-vessel recap.
- Accumulated-volume glass and a separate full-screen “tip the glass” beer: the phone itself is the glass, driven by the accelerometer on Android/iOS and by dragging on the web or without a sensor. It is visual only and changes no consumption records.

**Places and spending**

- Saved places with nickname or address, optional city/state, favorites and archiving.
- Optional budget, configurable threshold notices, and individual or batch correction of missing prices.
- Price suggestions from comparable entries in the user's own history, accepted explicitly. These are not public market averages.
- Paid amount, complimentary drinks and unknown prices remain distinct.

**Tab and bill splitting (optional)**

- A “Comanda” inside the outing and its summary (no extra navigation tab): equivalent orders grouped (“Draft 400 ml · 12 × R$ 15 = R$ 180”), extras such as snacks, cover, transport or a drink that exists only on the tab.
- Registered drinks are linked by id, never copied: correcting the record corrects the tab. A shared bottle counts once; if only the personal share is known, the table total stays unknown.
- Optional service (10% shortcut, editable) and discount (R$ or %), always in the same order: subtotal → discount → service on eligible items → total. Missing prices make the bill and the split partial.
- Nickname-only participants, split equally, by item (with weights) or with custom amounts; cents are distributed deterministically and always add up to the total.
- Payments are recorded per person and only affect the balance. There is no Pix, bank or charge, and the app never says who should transfer to whom. A text summary can be previewed, copied or shared on request.
- Consumption, assigned cost and payment stay separate: the tab never creates drink records or alcohol statistics for anyone.

**History and personal statistics**

- Monthly history with place, period and outing-type filters.
- Statistics for 7, 30 or 90 days or a custom period: outings, categories, known volumes, calculated alcohol, recorded spending and places.
- Optional post-outing feedback, morning-after notes and hangover report; an unfinished-outing reminder never ends a session automatically.
- Missing information stays visible. A day without records does not mean an alcohol-free day.

**Resenha: offline party games**

- Never Have I Ever, Most Likely To and Truth or Dare.
- Player nicknames, light/adult modes, optional points, custom cards and resumable games.
- Skipping has no penalty. Games do not require drinking or automatically add drinks to an outing.

**Sharing and export**

- A configurable summary card; full addresses and intoxication reports are excluded from the card.
- JSON export of personal records and CSV exports of outings and drinks.
- System sharing where supported, with text-copy alternatives. Browser support varies.

## Data and calculation rules

Unknown volume, price or alcohol content is not zero. Alcohol totals use only components with sufficient declared data and identify incomplete records; recipe quantities in leaves, spoons or other unsupported units are not silently converted to ml.

The app records consumption; it does **not** measure blood or breath alcohol, certify sobriety or establish a safe personal drinking limit. The table animation is illustrative, not a measurement of drinking speed or alcohol elimination.

## Architecture and synchronization

Feature-based organization separates domain, data and presentation, with Cubits for UI state and `get_it` for dependency injection.

- **Local first:** SharedPreferences stores records and a durable, versioned pending-upload queue.
- **Supabase:** anonymous authentication and PostgreSQL with versioned RLS migrations.
- **Uploads:** stable client UUIDs, upserts, retries and a manual synchronization action. A pending marker is cleared only after server confirmation for that version.
- **Dependencies:** saved places upload before dependent outings, and outings before their drink entries. Rejected links remain pending rather than being silently removed.
- **Current limitation:** there is no cloud pull or permanent-account recovery flow. Uploading data does not yet provide restoration on another device. Some preferences remain local.

## Tech stack

| Layer | Technology |
| --- | --- |
| App | Flutter / Dart |
| State | `flutter_bloc` / Cubit |
| Dependency injection | `get_it` |
| Local persistence | `shared_preferences`, local photo files (`path_provider`) |
| Photos and text reading | `image_picker`, `image`, `google_mlkit_text_recognition` (on-device, Android/iOS) |
| Backend | Supabase Auth, PostgreSQL, RLS |
| Graphics | Flutter widgets and custom painters |
| Sharing | `share_plus` |
| Device motion | `sensors_plus` |
| Formatting / IDs | `intl`, `uuid` |

Cloudflare is part of the planned infrastructure, not a deployed dependency of the current app.

## Project structure

```text
lib/
  core/                  configuration, DI, theme, local storage, sync
  shell/                 main navigation
  home/  outings/        home and outing lifecycle
  drinks/                catalog, recipes, portions and entries
  scan/  outing_drinks/  label/menu reading, photos and outing-only drinks
  tab/                   tab (comanda), bill splitting and payments
  places/  history/      saved places and past outings
  stats/  settings/      statistics and preferences
  table/  glass/         scenes, vessels and glass interactions
  games/                 offline party games
  share/  export/        summary cards and personal exports
assets/
  branding/              bottle-cap icon and wordmark
  catalog/               products and reference recipes
  games/                 card decks
supabase/migrations/     versioned database schema
docs/                    development checklist
```

## Running locally

Use a Flutter SDK whose bundled Dart satisfies the constraint in [`pubspec.yaml`](pubspec.yaml), currently `^3.13.3`. Android and iOS require their respective platform toolchains; iOS requires macOS/Xcode.

For your own Supabase project, apply the [migrations](supabase/migrations/) in order and enable anonymous sign-ins. Configuration is read from [`Env`](lib/core/config/env.dart); override the bundled development defaults to point to your own project.

```bash
git clone https://github.com/Lucasdiogof/bebometro.git
cd bebometro
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

For web, add `-d chrome` to the run command. These are setup instructions, not evidence that the commands were executed for this documentation update. When backend access fails, the implemented flow keeps records locally and shows pending synchronization.

## Roadmap and current limits

- **Implemented in code, not yet validated in execution:** label and menu photos with on-device text reading (Android/iOS only), manual review, outing-only drinks and photos, private photo upload and the manual alternative used on the web. The web has no automatic reading and keeps photos only for the current session. There is no barcode reader.
- **Tab (comanda):** written in code, not executed or analyzed after this feature; the `20261016000000` migration is delivered but **not applied**, so the tab stays on the device until then. No unit tests cover the calculation yet.
- **Not verified:** the label and menu parsers are heuristic and were not tested on real photos, so no accuracy is claimed. The `20261015000000` migration was applied by the maintainer; synchronization of these tables and photos from the app has not been observed.
- **Scope rule (implemented):** custom items, photos and menu prices belong to the outing ID, even across midnight. They do not enter the global catalog, do not automatically become reusable personal items and do not feed future-visit price suggestions.
- **Later:** map/place search, opt-in lock-screen activities, regional prices backed by real observations and additional catalog coverage.
- **Pending validation:** dependency resolution, compilation, device/browser flows, visual review and end-to-end synchronization. The full-screen beer physics and sensor axes are implemented in code but have not been observed on a device.

The reusable personal drinks created before this scope were preserved; inside an outing, new manual drinks are outing-only.

## Documentation

- [Technical handoff](HANDOFF.md)
- [Development progress](docs/development-progress.md)
- [Product catalog and recipe data](assets/catalog/)
- [Database migrations](supabase/migrations/)

Screenshots are not included yet: this delivery has no verified runtime captures. Branding assets are not presented as app screenshots.

## License

No open-source license is granted. Source visibility does not grant permission to reuse the code. All rights reserved. Beverage trademarks belong to their respective owners; the app is not affiliated with those brands.

## About

A **Lucksrei** product, developed by **Lucas Diogo França**. [lucksrei.com](https://lucksrei.com/)
