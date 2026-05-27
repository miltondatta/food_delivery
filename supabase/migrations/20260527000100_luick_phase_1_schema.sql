create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  phone text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  label text not null,
  recipient_name text,
  phone text,
  line1 text not null,
  line2 text,
  area text not null,
  city text not null,
  postal_code text,
  delivery_instructions text,
  lat numeric(9, 6),
  lng numeric(9, 6),
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.restaurants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  image_url text,
  cuisine_tags text[] not null default '{}',
  rating_display numeric(2, 1),
  delivery_fee_estimate integer not null default 0,
  eta_min_minutes integer not null default 20,
  eta_max_minutes integer not null default 40,
  is_open boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint restaurants_eta_check check (eta_min_minutes > 0 and eta_max_minutes >= eta_min_minutes),
  constraint restaurants_rating_check check (rating_display is null or rating_display between 0 and 5)
);

create table public.menu_items (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants(id) on delete cascade,
  name text not null,
  description text,
  image_url text,
  base_price integer not null,
  category text not null,
  is_available boolean not null default true,
  display_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint menu_items_base_price_check check (base_price >= 0)
);

create table public.menu_modifiers (
  id uuid primary key default gen_random_uuid(),
  menu_item_id uuid not null references public.menu_items(id) on delete cascade,
  name text not null,
  type text not null,
  is_required boolean not null default false,
  min_select integer not null default 0,
  max_select integer not null default 1,
  options jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint menu_modifiers_type_check check (type in ('single', 'multiple')),
  constraint menu_modifiers_select_check check (min_select >= 0 and max_select >= min_select)
);

create table public.carts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  restaurant_id uuid references public.restaurants(id) on delete set null,
  address_id uuid references public.addresses(id) on delete set null,
  status text not null default 'active',
  delivery_instructions text,
  subtotal integer not null default 0,
  fees_estimate integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint carts_status_check check (status in ('active', 'converted', 'abandoned')),
  constraint carts_totals_check check (subtotal >= 0 and fees_estimate >= 0)
);

create table public.cart_items (
  id uuid primary key default gen_random_uuid(),
  cart_id uuid not null references public.carts(id) on delete cascade,
  menu_item_id uuid references public.menu_items(id) on delete set null,
  quantity integer not null default 1,
  unit_price integer not null,
  selected_modifiers jsonb not null default '[]'::jsonb,
  special_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint cart_items_quantity_check check (quantity > 0),
  constraint cart_items_unit_price_check check (unit_price >= 0)
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  restaurant_id uuid references public.restaurants(id) on delete set null,
  address_id uuid references public.addresses(id) on delete set null,
  status text not null default 'placed',
  subtotal integer not null default 0,
  fees_estimate integer not null default 0,
  total integer not null default 0,
  delivery_instructions text,
  cart_snapshot jsonb not null default '{}'::jsonb,
  placed_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint orders_status_check check (status in ('placed', 'accepted', 'preparing', 'on_the_way', 'delivered', 'cancelled')),
  constraint orders_totals_check check (subtotal >= 0 and fees_estimate >= 0 and total >= 0)
);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  menu_item_id uuid references public.menu_items(id) on delete set null,
  name_snapshot text not null,
  quantity integer not null,
  unit_price integer not null,
  modifiers_snapshot jsonb not null default '[]'::jsonb,
  line_total integer not null,
  created_at timestamptz not null default now(),
  constraint order_items_quantity_check check (quantity > 0),
  constraint order_items_price_check check (unit_price >= 0 and line_total >= 0)
);

create table public.order_status_events (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  status text not null,
  message text,
  actor text not null default 'system',
  created_at timestamptz not null default now(),
  constraint order_status_events_status_check check (status in ('placed', 'accepted', 'preparing', 'on_the_way', 'delivered', 'cancelled')),
  constraint order_status_events_actor_check check (actor in ('system', 'restaurant_placeholder', 'user'))
);

create index addresses_user_id_idx on public.addresses(user_id);
create unique index addresses_one_default_per_user_idx on public.addresses(user_id) where is_default;
create index menu_items_restaurant_id_idx on public.menu_items(restaurant_id);
create index menu_modifiers_menu_item_id_idx on public.menu_modifiers(menu_item_id);
create index carts_user_id_idx on public.carts(user_id);
create unique index carts_one_active_per_user_idx on public.carts(user_id) where status = 'active';
create index cart_items_cart_id_idx on public.cart_items(cart_id);
create index orders_user_id_idx on public.orders(user_id);
create index order_items_order_id_idx on public.order_items(order_id);
create index order_status_events_order_id_created_at_idx on public.order_status_events(order_id, created_at);

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create trigger addresses_set_updated_at
before update on public.addresses
for each row execute function public.set_updated_at();

create trigger restaurants_set_updated_at
before update on public.restaurants
for each row execute function public.set_updated_at();

create trigger menu_items_set_updated_at
before update on public.menu_items
for each row execute function public.set_updated_at();

create trigger menu_modifiers_set_updated_at
before update on public.menu_modifiers
for each row execute function public.set_updated_at();

create trigger carts_set_updated_at
before update on public.carts
for each row execute function public.set_updated_at();

create trigger cart_items_set_updated_at
before update on public.cart_items
for each row execute function public.set_updated_at();

create trigger orders_set_updated_at
before update on public.orders
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.addresses enable row level security;
alter table public.restaurants enable row level security;
alter table public.menu_items enable row level security;
alter table public.menu_modifiers enable row level security;
alter table public.carts enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.order_status_events enable row level security;

create policy "Users can read their profile"
on public.profiles for select
to authenticated
using (id = auth.uid());

create policy "Users can insert their profile"
on public.profiles for insert
to authenticated
with check (id = auth.uid());

create policy "Users can update their profile"
on public.profiles for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

create policy "Users manage their addresses"
on public.addresses for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "Restaurants are readable"
on public.restaurants for select
to anon, authenticated
using (true);

create policy "Menu items are readable"
on public.menu_items for select
to anon, authenticated
using (true);

create policy "Menu modifiers are readable"
on public.menu_modifiers for select
to anon, authenticated
using (true);

create policy "Users manage their carts"
on public.carts for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "Users manage items in their carts"
on public.cart_items for all
to authenticated
using (
  exists (
    select 1
    from public.carts
    where carts.id = cart_items.cart_id
      and carts.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.carts
    where carts.id = cart_items.cart_id
      and carts.user_id = auth.uid()
  )
);

create policy "Users read their orders"
on public.orders for select
to authenticated
using (user_id = auth.uid());

create policy "Users create their orders"
on public.orders for insert
to authenticated
with check (user_id = auth.uid());

create policy "Users read their order items"
on public.order_items for select
to authenticated
using (
  exists (
    select 1
    from public.orders
    where orders.id = order_items.order_id
      and orders.user_id = auth.uid()
  )
);

create policy "Users create their order items"
on public.order_items for insert
to authenticated
with check (
  exists (
    select 1
    from public.orders
    where orders.id = order_items.order_id
      and orders.user_id = auth.uid()
  )
);

create policy "Users read their order status events"
on public.order_status_events for select
to authenticated
using (
  exists (
    select 1
    from public.orders
    where orders.id = order_status_events.order_id
      and orders.user_id = auth.uid()
  )
);

create policy "Users create initial order status events"
on public.order_status_events for insert
to authenticated
with check (
  actor in ('system', 'user')
  and exists (
    select 1
    from public.orders
    where orders.id = order_status_events.order_id
      and orders.user_id = auth.uid()
  )
);
