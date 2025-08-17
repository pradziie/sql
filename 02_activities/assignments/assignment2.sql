/* ASSIGNMENT 2 */
/* SECTION 2 */

-- COALESCE
/* 1. Our favourite manager wants a detailed long list of products, but is afraid of tables! 
We tell them, no problem! We can produce a list with all of the appropriate details. 

Using the following syntax you create our super cool and not at all needy manager a list:

SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')'
FROM product

But wait! The product table has some bad data (a few NULL values). 
Find the NULLs and then using COALESCE, replace the NULL with a 
blank for the first problem, and 'unit' for the second problem. 

HINT: keep the syntax the same, but edited the correct components with the string. 
The `||` values concatenate the columns into strings. 
Edit the appropriate columns -- you're making two edits -- and the NULL rows will be fixed. 
All the other rows will remain the same.) */

SELECT 
COALESCE(product_name,'') || ', ' || COALESCE(product_size,'') || ' (' || COALESCE(product_qty_type,'unit') || ')' AS product_display
FROM product;

/* I had to use COALESCE on all columns to make sure there were no nulls */

--Windowed Functions
/* 1. Write a query that selects from the customer_purchases table and numbers each customer’s  
visits to the farmer’s market (labeling each market date with a different number). 
Each customer’s first visit is labeled 1, second visit is labeled 2, etc. 

You can either display all rows in the customer_purchases table, with the counter changing on
each new market date for each customer, or select only the unique market dates per customer 
(without purchase details) and number those visits. 
HINT: One of these approaches uses ROW_NUMBER() and one uses DENSE_RANK(). */

SELECT 
cp.*, 
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER by market_date, transaction_time) as visit_row_sequence
FROM customer_purchases cp;

/* I went with a simple row number. While I like the idea of dense rank and of keeping as much info as possible, 
at this point the DENSE_RANK approach was too comlicated for me to understand how to make it work correctly :( */

/* 2. Reverse the numbering of the query from a part so each customer’s most recent visit is labeled 1, 
then write another query that uses this one as a subquery (or temp table) and filters the results to 
only the customer’s most recent visit. */


/* Reverse numbering part below */

WITH customer_dates as (
SELECT DISTINCT customer_id, market_date FROM customer_purchases), rev_numbered 
as (
SELECT 
customer_id,
market_date,
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER by market_date DESC) as reverse_visit_number
FROM customer_dates)
SELECT * FROM rev_numbered ORDER by customer_id, reverse_visit_number;

/* step 2 with a subquery; this includes first query again. 
I used temp table first then reverted to CTE instead after finally making it work
I avoided adding visit times as I barely got this one */

WITH customer_dates as (
SELECT DISTINCT customer_id, market_date FROM customer_purchases
), rev_numbered as (
SELECT 
customer_id,
market_date,
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER by market_date DESC) AS reverse_visit_number
FROM customer_dates
)
SELECT customer_id, market_date as most_recent_market_date
FROM rev_numbered
WHERE reverse_visit_number = 1
ORDER by customer_id;


/* 3. Using a COUNT() window function, include a value along with each row of the 
customer_purchases table that indicates how many different times that customer has purchased that product_id. */

/* The below gives number of times purchased, not distinct market days when they did. 
Not sure if that's what was required instead */

SELECT 
cp.*,
cnt.times_purchased
FROM customer_purchases cp
JOIN (
SELECT 
customer_id,
product_id,
COUNT(*) as times_purchased
FROM customer_purchases
GROUP by customer_id, product_id
) cnt
ON cp.customer_id = cnt.customer_id
AND cp.product_id = cnt.product_id;

/* Future me researched OVER and PARTITION. Asked for... help how to use it. The code came out so much shorter: */

SELECT 
	cp.*,
	COUNT(*) OVER (PARTITION BY customer_id, product_id) as times_purchased
FROM customer_purchases cp;

/* note to self: use tabulation more to be able to collapse the code for readability */

-- String manipulations
/* 1. Some product names in the product table have descriptions like "Jar" or "Organic". 
These are separated from the product name with a hyphen. 
Create a column using SUBSTR (and a couple of other commands) that captures these, but is otherwise NULL. 
Remove any trailing or leading whitespaces. Don't just use a case statement for each product! 

| product_name               | description |
|----------------------------|-------------|
| Habanero Peppers - Organic | Organic     |

Hint: you might need to use INSTR(product_name,'-') to find the hyphens. INSTR will help split the column. */

SELECT 
	product_name,
	CASE 
	WHEN INSTR(product_name,'-') > 0 THEN
	TRIM(SUBSTR(product_name, INSTR(product_name,'-') + 1))
	ELSE NULL
	END as description
FROM product;

/* Note to self: practice INSTR more later. I will not retain this ._. */

/* 2. Filter the query to show any product_size value that contain a number with REGEXP. */

-- UNION
/* 1. Using a UNION, write a query that displays the market dates with the highest and lowest total sales.

HINT: There are a possibly a few ways to do this query, but if you're struggling, try the following: 
1) Create a CTE/Temp Table to find sales values grouped dates; 
2) Create another CTE/Temp table with a rank windowed function on the previous query to create 
"best day" and "worst day"; 
3) Query the second temp table twice, once for the best day, once for the worst day, 
with a UNION binding them. */

WITH sales_by_day as (
	SELECT 
	market_date,
	SUM(quantity * cost_to_customer_per_qty) as total_sales
	FROM customer_purchases
	GROUP by market_date
	), ranked as (
	SELECT 
	market_date,
	total_sales,
	RANK() OVER (ORDER by total_sales DESC) as r_desc,
	RANK() OVER (ORDER by total_sales ASC)  as r_asc
	FROM sales_by_day
	)
SELECT 'highest' as label, market_date, total_sales
FROM ranked WHERE r_desc = 1
UNION
SELECT 'lowest' as label, market_date, total_sales
FROM ranked WHERE r_asc = 1
ORDER by label, market_date;




/* SECTION 3 */

-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */


/* *** I did not figure this answer out on my own. Please do not mark this question as completed.***

I had to use Google and ChatGPT here to ask how to do the subquery, and it worked too well. Sapped the learning out of me. 
Please do not mark this part as completed.

However, the code it helped me write worked just fine, for reference:

WITH latest_price as (
SELECT 
	vi.vendor_id,
	vi.product_id,
	vi.original_price,
	ROW_NUMBER() OVER (PARTITION BY vi.vendor_id, vi.product_id ORDER by vi.market_date DESC) as rn
	FROM vendor_inventory vi ), 
	base as (
SELECT vendor_id, product_id, original_price FROM latest_price WHERE rn = 1), 
	v as (
SELECT vendor_id, vendor_name FROM vendor), 
	p as (
SELECT product_id, product_name FROM product), 
	c as (
SELECT COUNT(DISTINCT customer_id) as customer_count FROM customer)
SELECT 
	v.vendor_name,
	p.product_name,
	5 * c.customer_count * b.original_price as hypothetical_revenue
FROM base b
JOIN v on b.vendor_id = v.vendor_id
JOIN p on b.product_id = p.product_id
CROSS JOIN c
ORDER by v.vendor_name, p.product_name;

Note to self: review CROSS JOIN and PARTITION BY again to recreate a case like this.
*/

-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

DROP TABLE if EXISTS product_units;
CREATE TABLE product_units as
SELECT
	p.*,
	DATETIME('now','localtime') as snapshot_timestamp
FROM product p
WHERE p.product_qty_type = 'unit';


/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

INSERT INTO product_units (
	product_id,
	product_name,
	product_size,
	product_category_id,
	product_qty_type,
	snapshot_timestamp
)
SELECT
	MAX(product_id) + 1 as product_id,
	'Apple Pie - Seasonal',
	'1 pc',
	(SELECT product_category_id FROM product ORDER by product_category_id LIMIT 1),
	'unit',
	DATETIME('now','localtime')
FROM product;

/* Note to self: ask and research about this product_id assignment method reliability. 
Can I use COALESCE? 
Also, that CURRENT_TIMESTAMP, would it be better? */

-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/

DELETE FROM product_units
WHERE (product_id = 24) 
OR (product_id = 1 AND product_name = 'Apple Pie - Seasonal')

/* Added this under product_id = 1 in the database so had to come up with a way to delete it.
Otherwise, would've tried to use the MAX calculation there.
Note to self: need to ask and think about a less specified way to delete these based on the product_id */

-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */

/* ***Did not figure the answer out on my own. Please do not mark this part as completed.***

(However, ChatGPT helped with the following solution when I asked, and it kinda worked and handled nulls:

ALTER TABLE product_units
ADD current_quantity INT;

UPDATE product_units
SET current_quantity = COALESCE((
	SELECT quantity
	FROM vendor_inventory vi
	WHERE vi.product_id = product_units.product_id
	ORDER BY vi.market_date DESC
	LIMIT 1
), 0);)

This should not count towards my answer to the question
*/