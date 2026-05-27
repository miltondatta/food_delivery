# Luick Supabase Local Setup

This folder contains the Phase 1 local Supabase backend for Luick.

## Run Locally

```powershell
supabase start
supabase db reset
supabase status
```

Copy the local API URL and anon key from `supabase status`, then run Flutter with:

```powershell
flutter run --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_ANON_KEY=<local-anon-key>
```

## Phase 1 Scope

- Supabase Auth enabled.
- User-owned profile, address, cart, order, order item, and order status data.
- Readable restaurant, menu item, and menu modifier data.
- RLS enabled on every app table.
- Seeded restaurant/menu catalog for simulator smoke testing.

Out of scope for this phase: real payments, refunds, support, reviews, subscriptions, maps, driver dispatch, restaurant admin, and production marketplace operations.
