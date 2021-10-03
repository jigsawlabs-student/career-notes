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
                    WHEN discounts.discount_type = 'amount'
                        THEN (books.price - discount_value) * quantity
                END 
                    item_total_revenue_with_item_discount
        FROM order_items
        JOIN books
        ON order_items.book_id = books.id
        JOIN discounts
        ON discounts.id = order_items.discount_id
        ),
        
        /* SELECT * FROM order_item_stats; */
        
    order_stats_by_month_after_item_discounts
    AS(
        SELECT EXTRACT(year from orders.ordered_at::date) * 100
                    + EXTRACT(month from orders.ordered_at::date) as year_month,
                order_id,
                SUM(item_rev_before_discount) AS order_total_rev_before_discount,
                SUM(num_books_per_item) AS num_books_per_order,
                SUM(item_total_revenue_with_item_discount) as order_total_revenue_with_item_discounts
        FROM order_item_stats
        JOIN orders
        ON order_item_stats.order_id = orders.id
        GROUP BY year_month, order_id),
    
    /* SELECT * from order_stats_by_month_after_item_discounts; */

    aggregates_by_order
    AS (
        SELECT 
            order_stats_by_month_after_item_discounts.order_id as order_id,
            order_item_stats.order_item_id,
            book_id, /* 'print to screen'; may not be needed in the final script*/
            books.author_id as author_id,
            order_stats_by_month_after_item_discounts
                                                .order_total_rev_before_discount,
            order_stats_by_month_after_item_discounts
                                                .num_books_per_order,
            order_stats_by_month_after_item_discounts
                                                .order_total_revenue_with_item_discounts,
            order_item_stats
                                            .item_rev_before_discount,
            order_item_stats
                                            .item_total_revenue_with_item_discount
        FROM order_stats_by_month_after_item_discounts
        INNER JOIN order_item_stats
        ON order_stats_by_month_after_item_discounts.order_id
            = order_item_stats.order_id
        INNER JOIN orders
        ON orders.id
            = order_item_stats.order_id
        JOIN books
        ON books.id = order_item_stats.book_id
        JOIN authors
        ON authors.id = books.author_id),   

    /* SELECT * FROM aggregates_by_order; */


    aggragates_by_author_month
    AS
        (SELECT EXTRACT(year from orders.ordered_at::date) * 100
                    + EXTRACT(month from orders.ordered_at::date) as year_month,
                author_id,
                SUM(num_books_per_item) AS num_books_per_author_month,
                SUM(item_rev_before_discount) 
                                                AS author_total_revenue_before_discount,
                SUM(item_total_revenue_with_item_discount) 
                                                AS author_total_revenue_with_item_discount
        FROM order_item_stats
        JOIN orders
        ON order_item_stats
                                            .order_id = orders.id
        GROUP BY author_id, year_month),
    
    /* SELECT * from aggragates_by_author_month; */

    aggragates_by_author_month_order
    AS (
        SELECT * 
        FROM aggregates_by_order
        INNER JOIN aggragates_by_author_month
        ON aggragates_by_author_month.author_id
                = aggregates_by_order.author_id
        ), 
    
    /* SELECT * from aggragates_by_author_month_order; */

    order_rev_total_w_disc_author_rev_total_w_item_disc 
    AS (
        SELECT
                orders.id AS order_id,
                order_item_stats.order_item_id as order_item_id,
                aggragates_by_author_month_order.book_id as book_id,
                books.author_id as author_id,
                num_books_per_order,
                aggragates_by_author_month_order
                                        .num_books_per_author_month AS num_books_per_author_month,
                author_total_revenue_before_discount,
                author_total_revenue_with_item_discount,
                order_total_rev_before_discount,
                CASE
                    WHEN discounts.discount_type = 'percentage'
                        THEN order_item_stats
                                    .item_total_revenue_with_item_discount * (1 - discounts.discount_value)
                    WHEN discounts.discount_type = 'amount'
                        THEN (order_item_stats
                                .item_total_revenue_with_item_discount 
                                    - discounts.discount_value 
                                            * (order_item_stats
                                                    .item_total_revenue_with_item_discount
                                                            / order_total_revenue_with_item_discounts))
                END order_item_total_revenue_with_item_n_order_discount  
        FROM aggragates_by_author_month_order
        JOIN order_item_stats
        ON aggragates_by_author_month_order.order_item_id
            = order_item_stats.order_item_id
        JOIN books
        ON books.id = order_item_stats.book_id
        JOIN orders
        ON order_item_stats.order_id = orders.id
        JOIN discounts
        ON discounts.id = orders.discount_id),

    /* SELECT * FROM 
                order_rev_total_w_disc_author_rev_total_w_item_disc; */

    chronological_stats
    AS (
        SELECT 
                EXTRACT(year from orders.ordered_at::date) * 100
                    + EXTRACT(month from orders.ordered_at::date) as year_month,
                order_rev_total_w_disc_author_rev_total_w_item_disc
                                                                .order_id AS order_id,
                order_item_stats
                                                    .order_item_id as order_item_id,
                order_item_stats.author_id as author_id,
                order_rev_total_w_disc_author_rev_total_w_item_disc
                                                        .num_books_per_order 
                                                                as num_books_per_order,
                order_rev_total_w_disc_author_rev_total_w_item_disc
                                                        .num_books_per_author_month
                                                                as num_books_per_author_month,
                order_rev_total_w_disc_author_rev_total_w_item_disc
                            .author_total_revenue_before_discount as author_total_revenue_before_discount,
                order_rev_total_w_disc_author_rev_total_w_item_disc
                        .author_total_revenue_with_item_discount as author_total_revenue_with_item_discount,
                order_rev_total_w_disc_author_rev_total_w_item_disc
                        .order_total_rev_before_discount as order_total_rev_before_discount,
                order_rev_total_w_disc_author_rev_total_w_item_disc
                        .order_item_total_revenue_with_item_n_order_discount
                                                            as order_total_rev_after_discount
                
        FROM order_rev_total_w_disc_author_rev_total_w_item_disc
        JOIN order_item_stats
        ON order_item_stats.order_item_id 
            = order_rev_total_w_disc_author_rev_total_w_item_disc.order_item_id
        JOIN orders
        ON order_rev_total_w_disc_author_rev_total_w_item_disc
                                                        .order_id = orders.id
        ),
    
    /* SELECT * from chronological_stats; */

    total_revenues_by_month_author
    AS (
        SELECT year_month,
            author_id,
            ROUND(SUM(order_total_rev_after_discount), 2) 
                                                    AS total_rev_by_month_author
        FROM chronological_stats
        GROUP BY year_month, author_id
        ),

    /* SELECT * from total_revenues_by_month_author; */

    stats_by_month_author
    AS (
        SELECT  chronological_stats.year_month as year_month,
                total_revenues_by_month_author.author_id,
                chronological_stats.num_books_per_order
                                                as total_books_sold,
                chronological_stats
                                .author_total_revenue_before_discount
                                                        as total_revenue_before_discount,
                total_revenues_by_month_author
                                        .total_rev_by_month_author
                                                        as total_revenue
        FROM total_revenues_by_month_author
        JOIN chronological_stats
        ON total_revenues_by_month_author.author_id 
            = chronological_stats.author_id
        GROUP BY chronological_stats.year_month,
                total_revenues_by_month_author.author_id,
                chronological_stats
                                .num_books_per_order,
                chronological_stats
                                .author_total_revenue_before_discount,
                total_revenues_by_month_author
                                            .total_rev_by_month_author),

    /* SELECT * from stats_by_month_author; */
    
    solution_query
    AS (
        SELECT authors.first_name,
            authors.last_name,
            stats_by_month_author.total_books_sold,
            stats_by_month_author.total_revenue_before_discount,
            stats_by_month_author.total_revenue
        FROM stats_by_month_author
        JOIN authors
        ON stats_by_month_author.author_id = authors.id)

    SELECT * FROM solution_query;
