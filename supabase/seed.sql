insert into public.restaurants (
  id,
  name,
  description,
  image_url,
  cuisine_tags,
  rating_display,
  delivery_fee_estimate,
  eta_min_minutes,
  eta_max_minutes,
  is_open
) values
  (
    '11111111-1111-1111-1111-111111111111',
    'Green Bowl Kitchen',
    'Fresh rice bowls, grilled proteins, and bright sauces.',
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
    array['healthy', 'bowls', 'grill'],
    4.7,
    120,
    20,
    35,
    true
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'Tandoor Street',
    'Comforting kebabs, biryani, naan, and rich curries.',
    'https://images.unsplash.com/photo-1565557623262-b51c2513a641',
    array['indian', 'biryani', 'curry'],
    4.5,
    100,
    25,
    45,
    true
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'Pasta Corner',
    'Weeknight pasta, salads, and warm garlic bread.',
    'https://images.unsplash.com/photo-1551183053-bf91a1d81141',
    array['italian', 'pasta', 'salad'],
    4.4,
    140,
    30,
    50,
    true
  )
on conflict (id) do nothing;

insert into public.menu_items (
  id,
  restaurant_id,
  name,
  description,
  image_url,
  base_price,
  category,
  is_available,
  display_order
) values
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
    '11111111-1111-1111-1111-111111111111',
    'Herb Chicken Rice Bowl',
    'Grilled chicken, herbed rice, roasted vegetables, and yogurt sauce.',
    'https://images.unsplash.com/photo-1512058564366-18510be2db19',
    850,
    'Bowls',
    true,
    10
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
    '11111111-1111-1111-1111-111111111111',
    'Crisp Falafel Bowl',
    'Falafel, greens, cucumber, tomato, tahini, and pickled onion.',
    'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe',
    760,
    'Bowls',
    true,
    20
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1',
    '22222222-2222-2222-2222-222222222222',
    'Chicken Biryani',
    'Aromatic rice, spiced chicken, egg, and raita.',
    'https://images.unsplash.com/photo-1563379091339-03246963d96c',
    920,
    'Biryani',
    true,
    10
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2',
    '22222222-2222-2222-2222-222222222222',
    'Butter Paneer',
    'Paneer in creamy tomato gravy with a side of naan.',
    'https://images.unsplash.com/photo-1631452180519-c014fe946bc7',
    880,
    'Curries',
    true,
    20
  ),
  (
    'cccccccc-cccc-cccc-cccc-ccccccccccc1',
    '33333333-3333-3333-3333-333333333333',
    'Creamy Mushroom Pasta',
    'Penne, mushrooms, parmesan, parsley, and garlic cream.',
    'https://images.unsplash.com/photo-1473093295043-cdd812d0e601',
    980,
    'Pasta',
    true,
    10
  )
on conflict (id) do nothing;

insert into public.menu_modifiers (
  id,
  menu_item_id,
  name,
  type,
  is_required,
  min_select,
  max_select,
  options
) values
  (
    'dddddddd-dddd-dddd-dddd-dddddddddd01',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
    'Protein',
    'single',
    true,
    1,
    1,
    '[{"id":"chicken","name":"Chicken","price_delta":0},{"id":"beef","name":"Beef","price_delta":180},{"id":"tofu","name":"Tofu","price_delta":0}]'
  ),
  (
    'dddddddd-dddd-dddd-dddd-dddddddddd02',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
    'Extra sauce',
    'multiple',
    false,
    0,
    2,
    '[{"id":"garlic-yogurt","name":"Garlic yogurt","price_delta":60},{"id":"chili","name":"Chili","price_delta":40}]'
  ),
  (
    'dddddddd-dddd-dddd-dddd-dddddddddd03',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1',
    'Spice level',
    'single',
    true,
    1,
    1,
    '[{"id":"mild","name":"Mild","price_delta":0},{"id":"medium","name":"Medium","price_delta":0},{"id":"hot","name":"Hot","price_delta":0}]'
  ),
  (
    'dddddddd-dddd-dddd-dddd-dddddddddd04',
    'cccccccc-cccc-cccc-cccc-ccccccccccc1',
    'Add-ons',
    'multiple',
    false,
    0,
    3,
    '[{"id":"chicken","name":"Chicken","price_delta":180},{"id":"mushrooms","name":"Extra mushrooms","price_delta":90},{"id":"garlic-bread","name":"Garlic bread","price_delta":120}]'
  )
on conflict (id) do nothing;
