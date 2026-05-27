# Luick

Luick is a Flutter native food delivery app foundation. This repo currently contains only Phase 0 and Phase 1:

- Native Flutter scaffold for Android/iOS.
- Minimal Luick shell screen.
- Feature-first source layout.
- Supabase local backend config, migration, RLS policies, and seed data.

It intentionally does not implement the complete delivery app screens yet.

## Project Structure

```text
lib/
├─ app/                  # App root, theme, router
├─ core/                 # Config, errors, shared widgets, utilities
├─ data/                 # Models, repositories, Supabase data layer
└─ features/             # Feature-first modules
   ├─ auth/
   ├─ restaurants/
   ├─ menu/
   ├─ cart/
   ├─ checkout/
   ├─ addresses/
   ├─ orders/
   └─ shell/

supabase/
├─ config.toml
├─ migrations/
└─ seed.sql
```

## Flutter Verification

```powershell
flutter pub get
flutter analyze
flutter test
```

For Android debug builds:

```powershell
$env:ANDROID_HOME="D:\Android_SDK\Sdk"
flutter build apk --debug
```

## Simulator Verification

Start the Android simulator:

```powershell
emulator @test_avd_01
```

If `emulator` is not on `PATH`, use:

```powershell
D:\Android_SDK\Sdk\emulator\emulator.exe @test_avd_01
```

Then run:

```powershell
flutter run `
  --dart-define=SUPABASE_URL=http://127.0.0.1:54321 `
  --dart-define=SUPABASE_ANON_KEY=<local-anon-key>
```

## Supabase Verification

```powershell
supabase start
supabase db reset
supabase status
```

Use the anon key from `supabase status` for Flutter's `SUPABASE_ANON_KEY`.

The local schema includes:

- `profiles`
- `addresses`
- `restaurants`
- `menu_items`
- `menu_modifiers`
- `carts`
- `cart_items`
- `orders`
- `order_items`
- `order_status_events`

RLS is enabled for all app tables. Restaurant/menu catalog data is readable, while profile, address, cart, order, order item, and status event records are scoped to the authenticated user.

## Current Guardrails

Out of scope for this foundation: web deployment, restaurant admin, driver dispatch, real payments, refunds, support, reviews, subscriptions, maps, and production marketplace operations.
