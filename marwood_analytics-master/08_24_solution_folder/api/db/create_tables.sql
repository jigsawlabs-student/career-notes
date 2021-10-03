create table if not exists authors (
  id integer,
  first_name varchar(256),
  last_name varchar(256)
);

create table if not exists books (
  id integer,
  author_id integer,
  title varchar(256),
  isbn varchar(64),
  price numeric(36,2)
);

create table if not exists discounts (
  id integer,
  title varchar(256),
  applies_to varchar(11), -- enum "orders" or "order_items"
  discount_type varchar(10), -- enum "percentage" or "amount"
  discount_value numeric(36,2)
);

create table if not exists orders (
  id integer,
  ordered_at timestamp,
  discount_id integer
);

create table if not exists order_items (
  id integer,
  order_id integer,
  book_id integer,
  quantity integer,
  discount_id integer
);
