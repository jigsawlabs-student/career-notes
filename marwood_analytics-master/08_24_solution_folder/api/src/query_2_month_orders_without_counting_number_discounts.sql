    WITH order_item_stats
    AS (
        SELECT
                order_id,
                order_items.id as order_item_id,
                author_id,
                books.id as book_id,
                books.price * order_items.quantity AS item_rev_before_discount,
                order_items.quantity as num_books_per_item,
                CASE
                    WHEN discount_type = 'percentage'
                        THEN books.price * (1 - discount_value) * quantity
                    WHEN discount_type = 'amount'
                        THEN (books.price - discount_value) * quantity
                END 
                    item_revenue_after_item_discount
        FROM order_items
        JOIN books
        ON order_items.book_id = books.id
        JOIN discounts
        ON discounts.id = order_items.discount_id
        ),
        
    order_stats_by_month_after_item_discounts
    AS(
        SELECT EXTRACT(year from ordered_at::date) * 100
                    + EXTRACT(month from ordered_at::date) as year_month,
                order_id,
                SUM(item_rev_before_discount) AS order_rev_before_discount,
                SUM(num_books_per_item) AS num_books_per_order,
                SUM(item_revenue_after_item_discount) as order_revenue_after_item_discounts
        FROM order_item_stats
        JOIN orders
        ON order_item_stats.order_id = orders.id
        GROUP BY year_month, order_id),
    
    -- order-level and order-item level stats by month
    order_n_item_stats_by_month
    AS (
        SELECT 
            order_stats_by_month_after_item_discounts
                                                    .year_month,
            order_stats_by_month_after_item_discounts
                                                    .order_id as order_id,
            order_item_stats.order_item_id,
            books.author_id as author_id,
            order_stats_by_month_after_item_discounts
                                    .num_books_per_order,
            order_stats_by_month_after_item_discounts
                                                .order_rev_before_discount,
            order_stats_by_month_after_item_discounts
                                                .order_revenue_after_item_discounts,
            order_item_stats.num_books_per_item,
            order_item_stats
                        .item_rev_before_discount,
            order_item_stats
                        .item_revenue_after_item_discount
        FROM order_stats_by_month_after_item_discounts
        INNER JOIN order_item_stats
        ON order_stats_by_month_after_item_discounts.order_id
            = order_item_stats.order_id
        JOIN books
        ON books.id = order_item_stats.book_id
        JOIN authors
        ON authors.id = books.author_id),

    -- order-level and order-item level stats, incl. discounts, by month
    order_level_discounts
    AS (
        SELECT
                order_n_item_stats_by_month.year_month,
                orders.id AS order_id,
                num_books_per_order,
                order_item_stats.order_item_id as order_item_id,
                order_n_item_stats_by_month
                                        .num_books_per_item,
                order_n_item_stats_by_month
                                        .item_rev_before_discount,
                order_n_item_stats_by_month
                                        .item_revenue_after_item_discount,
                authors.first_name,
                authors.last_name,
                order_rev_before_discount,
                CASE
                    WHEN discounts.discount_type = 'percentage'
                        THEN order_item_stats
                                    .item_revenue_after_item_discount * (1 - discounts.discount_value)
                    WHEN discounts.discount_type = 'amount'
                        THEN (order_item_stats
                                .item_revenue_after_item_discount 
                                    - discounts.discount_value 
                                            * (order_item_stats
                                                    .item_revenue_after_item_discount
                                                            / order_revenue_after_item_discounts))
                END order_item_revenue_after_both_discounts  
        FROM order_n_item_stats_by_month
        JOIN order_item_stats
        ON order_n_item_stats_by_month.order_item_id
            = order_item_stats.order_item_id
        JOIN books
        ON books.id = order_item_stats.book_id
        JOIN authors
        ON books.author_id = authors.id
        JOIN orders
        ON order_item_stats.order_id = orders.id
        JOIN discounts
        ON discounts.id = orders.discount_id),

    /* SELECT * FROM order_level_discounts; */
    
    final_query
    AS (
        SELECT  year_month,
                authors.first_name,
                authors.last_name,
                SUM(order_level_discounts
                                        .num_books_per_item) AS total_books_sold,
                ROUND(SUM(order_item_revenue_after_both_discounts), 2)
                                                                    AS total_revenue,
                ROUND(SUM(order_level_discounts
                                            .item_rev_before_discount), 2) 
                                                        AS total_revenue_before_discounts
        FROM order_level_discounts
        JOIN order_item_stats
        ON order_level_discounts.order_item_id 
            = order_item_stats.order_item_id
        JOIN books
        ON order_item_stats.book_id = books.id
        JOIN authors
        ON books.author_id = authors.id
        GROUP BY year_month, authors.first_name, authors.last_name
        ORDER by year_month, total_revenue)

    SELECT * from final_query;


