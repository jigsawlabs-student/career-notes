
### Technology adopted

- PostgreSQL 11.13


### Getting Started

Once PostgreSQL 11.13 is installed, create a database with a name of your choice.  In this project's case, "marwood_analytics".

Clone this project's repo in a local machine.

From the project directory's root level in a terminal, navigate to an individual solution's folder, which includes a dedicated REAMDE.md file with introductions about running the SQL query scripts inside.


### 08/24/2021: summary of the latest solution, in ./08_24_solution_folder.

- Returns correctly Total Revenue, Total Books Sold, and Total Revenue Before Discounts for each author, each month, based on a two-month, two-author, 4-order, 8-order-item test dataset.

- Needs to clarify if the discount_value for "no discount" is represented by NULL or 0 before working out the aggregation result for "Total Number of Discounts Used."

- Work in progress:

Use Streamlit and Pyplot, two Python libraries, to present various charts based on the data that has populated the project database on the backend.

The charts include both time-series trend lines based on the numbers related to the authors' monthly book sales, as well as their cross-sectional comparison, such as:

    - Total monthly revenue by each author, before and after discounts.

    - Total number of books sold each month, by each author.

To see an example with a different dataset, click this [Dashboard](https://docs.google.com/document/d/e/2PACX-1vR32tVoSvUYB9-jgy_jT3-YbqrjJxQw8pXt13lmcwcjT7hfUW-2L4C5LJG5-BooBSDPGmUDvryonoaL/pub).


