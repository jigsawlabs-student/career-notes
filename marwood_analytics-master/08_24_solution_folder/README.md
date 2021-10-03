08/24/2021


### Implement a project directory structure with 3 components:


1. Flask app with RESTful API

A Flask app with various endpoints that allows users to enter such parameters as author, month; then queries a PostgreSQL server on the backend; and renders the result in JSON format in a web browser.


2. Frontend dashboard

Use Streamlit and Pyplot, two Python libraries, to present various plots based on SQL queries of the backend Postgres db, as described above.

The plots include both time-series trend lines and cross-sectional comparison, such as:

    - Total monthly revenue by each author, before and after discounts.

    - Total number of books sold each month, by each author.


3. Tests

Use PyTest to test the various SQL query scripts, Python class and instance methods, in both the api and frontend folders.


### Single- and multi-month datasets included in /api/db folder.

These datasets further test the SQL query script's ability, as required by the take-home exam, to aggregate the data by month, author, order, and discount_type.

To create all the tables in the database, navigate to the directory level shown below, then execute:

/api/db $ psql -U postgres marwood_analytics -f create_tables.sql

Populate the database with this test dataset:

/api/db $ psql -U postgres marwood_analytics -f seed_2_month_orders.sql


### SQL query script: 

Navigate to the directory level indicated below, then execute:

/api/src $ psql -U postgres marwood_analytics -f query_2_month_orders_without_counting_number_discounts.sql

The query returns correctly Total Revenue, Total Books Sold, and Total Revenue Before Discounts for each author, each month, based on a two-month, two-author, 4-order, 8-order-item test dataset.


### A question:

Needs to clarify if the discount_value for "no discount" is represented by NULL or 0 before working out the aggregation result for "Total Number of Discounts Used."



