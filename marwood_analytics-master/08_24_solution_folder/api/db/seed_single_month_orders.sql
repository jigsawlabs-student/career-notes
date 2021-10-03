TRUNCATE TABLE books, authors, orders, order_items, discounts;

INSERT INTO books (id, author_id, title, isbn, price)
VALUES
    (1, 1, 'Tufts', 'isbn-1', 10),
    (2, 1, 'Swarthmore', 'isbn-2', 30),
    (3, 2, 'American Pastoral', 'isbn-3', 100),
    (4, 2, 'Human Stain', 'isbn-4', 300);

INSERT INTO authors (id, first_name, last_name)
VALUES
    (1, 'College', 'Review'),
    (2, 'Philip', 'Roth');

INSERT INTO discounts (id, title, applies_to, discount_type, discount_value)
VALUES
    (1, 'College Review Sale', 'order_items', 'percentage', 0.20),
    (2, 'Philip Roth American Trilogy', 'order_items', 'amount', 50),
    (3, 'Labor Day Sale', 'orders', 'percentage', 0.10),
    (4, 'Back to School Sale', 'orders', 'amount', 10),
    (5, 'No discount on individual book purchase', 'order_items', 'amount', 0),
    (6, 'No discount on individual order', 'orders', 'amount', 0);

INSERT INTO order_items (id, order_id, book_id, quantity, discount_id)
VALUES
    (1, 1, 1, 2, 1),
    (2, 1, 3, 1, 5),
    (3, 2, 4, 3, 2),
    (4, 2, 2, 1, 1);

INSERT INTO orders (id, ordered_at, discount_id)
VALUES
    (1, '2016-06-22 19:10:25-07', 4),
    (2, '2016-06-12 19:10:25-07', 6);