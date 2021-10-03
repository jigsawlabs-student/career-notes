### Technology adopted

- PostgreSQL 11.13

### Getting Started

Once PostgreSQL 11.13 is installed, create a database by the name of your choice.In this project's case, "marwood_analytics".

Clone this project's repo in a local machine.

Navigate to the project directory's root level in a terminal, then run the following command to populate the sample dataset in the various db tables:

$ psql -U postgres marwood_analytics -f seed_single_month_orders.sql

Then, run the solution query:

$ psql -U postgres marwood_analytics -f solution_query_single_month_orders.sql


### 08/23/2021: Description of first-phase solution (and its inadequacies):

- Task 1

The query script in the current repo only works with a single-month, multiple-order, multiple-order-item dataset (see seed_single_month_orders.sql for details).

It does not yet identify which 'total_books_sold' value corresponds to which author, nor does it count the number of discounts used.

The challenge posed by the many-to-many relationships between the orders and authors tables, especially in the context of multiple-month aggregation, is yet to be solved.

- Task 2

To be worked on.

- Task 3

Just signed up for a Tableau account, connected the Tableau Desktop to the Postgres server on a local computer, and identified the order_items as the fact table.

Still working on the dashboard.  

