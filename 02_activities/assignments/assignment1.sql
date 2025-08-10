/* ASSIGNMENT 1 */
/* SECTION 2 */


--SELECT
/* 1. Write a query that returns everything in the customer table. */

SELECT * 
FROM customer;

/* 2. Write a query that displays all of the columns and 10 rows from the cus- tomer table, 
sorted by customer_last_name, then customer_first_ name. */

SELECT * 
FROM customer
ORDER BY customer_last_name, customer_first_name
LIMIT 10;

--WHERE
/* 1. Write a query that returns all customer purchases of product IDs 4 and 9. */
-- option 1
SELECT *
FROM customer_purchases
WHERE product_id = 4 OR product_id = 9;
/* was thinking about aliasing but decided against it for simplicity */
-- option 2

/* chose option 1 as it's the way I would've done it */

/*2. Write a query that returns all customer purchases and a new calculated column 'price' (quantity * cost_to_customer_per_qty), 
filtered by vendor IDs between 8 and 10 (inclusive) using either:
	1.  two conditions using AND
	2.  one condition using BETWEEN
*/
-- option 1


-- option 2

SELECT *, 
(quantity * cost_to_customer_per_qty) AS price
FROM customer_purchases
WHERE vendor_id BETWEEN 8 AND 10;
/* chose option 2 as what if for some magical reason some vendor_ids were not integers? 
We wouldn't even want to just cast them like that */

--CASE
/* 1. Products can be sold by the individual unit or by bulk measures like lbs. or oz. 
Using the product table, write a query that outputs the product_id and product_name
columns and add a column called prod_qty_type_condensed that displays the word “unit” 
if the product_qty_type is “unit,” and otherwise displays the word “bulk.” */

SELECT product_id, product_name,
CASE
WHEN product_qty_type = 'unit' THEN 'unit'
ELSE 'bulk'
END AS prod_qty_type_condensed
FROM product;
/* does this mean "includes "unit", is always "unit", is it case-sensitive? 
Decided against overthinking it, so left it as is */

/* 2. We want to flag all of the different types of pepper products that are sold at the market. 
add a column to the previous query called pepper_flag that outputs a 1 if the product_name 
contains the word “pepper” (regardless of capitalization), and otherwise outputs 0. */

SELECT product_id, product_name,
CASE
WHEN product_name LIKE '%pepper%' THEN 1
ELSE 0
END AS pepper_flag
FROM product;
/* to make it portable across browsers, it may be better to do:
WHEN LOWER(product_name) LIKE '%pepper%' THEN 1
LOWER makes this LIKE command case-insensitive and parenthesis are not required but may be needed if other stuff is added
I left it without LOWER as SQLite ran it just fine like that, and because I didn't know this at the time */

--JOIN
/* 1. Write a query that INNER JOINs the vendor table to the vendor_booth_assignments table on the 
vendor_id field they both have in common, and sorts the result by vendor_name, then market_date. */

SELECT *
FROM vendor AS v
JOIN vendor_booth_assignments AS vba
ON v.vendor_id = vba.vendor_id
ORDER BY v.vendor_name, vba.market_date;
/* started using aliases as I got scared of JOINS. Not stating INNER JOIN as no LEFT/RIGHT here.
Will also have to check later if the order always matters */

/* SECTION 3 */

-- AGGREGATE
/* 1. Write a query that determines how many times each vendor has rented a booth 
at the farmer’s market by counting the vendor booth assignments per vendor_id. */

SELECT v.vendor_id AS vendor_id, v.vendor_name AS vendor_name, 
COUNT(vba.vendor_id) AS booth_rent_count
FROM vendor AS v
LEFT JOIN vendor_booth_assignments AS vba
ON v.vendor_id = vba.vendor_id
GROUP BY v.vendor_id;
/* LEFT JOIN included 0 assignment vendors after research. 
Not updating JOIN to INNER JOIN in the other query
Added vendor_name to SELECT for readability */

/* 2. The Farmer’s Market Customer Appreciation Committee wants to give a bumper 
sticker to everyone who has ever spent more than $2000 at the market. Write a query that generates a list 
of customers for them to give stickers to, sorted by last name, then first name. 

HINT: This query requires you to join two tables, use an aggregate function, and use the HAVING keyword. */


SELECT c.customer_id, c.customer_first_name, c.customer_last_name,
ROUND(SUM(cp.quantity * cp.cost_to_customer_per_qty), 2) AS total_spent
/* in the above line I decided to ask how to round prices up the way currency would look;
I guess printf is not an option as it doesn't round anything up */
FROM customer AS c
JOIN customer_purchases AS cp
ON c.customer_id = cp.customer_id
GROUP BY c.customer_id
HAVING SUM(cp.quantity * cp.cost_to_customer_per_qty) > 2000
ORDER BY c.customer_last_name, c.customer_first_name;

--Temp Table
/* 1. Insert the original vendor table into a temp.new_vendor and then add a 10th vendor: 
Thomass Superfood Store, a Fresh Focused store, owned by Thomas Rosenthal

HINT: This is two total queries -- first create the table from the original, then insert the new 10th vendor. 
When inserting the new vendor, you need to appropriately align the columns to be inserted 
(there are five columns to be inserted, I've given you the details, but not the syntax) 

-> To insert the new row use VALUES, specifying the value you want for each column:
VALUES(col1,col2,col3,col4,col5) 
*/

CREATE TEMP TABLE new_vendor AS
SELECT * FROM vendor;

INSERT INTO new_vendor (vendor_id, vendor_name, vendor_type, vendor_owner_first_name, vendor_owner_last_name)
VALUES (10, 'Thomass Superfood Store', 'Fresh Focused', 'Thomas', 'Rosenthal');
/* had to iterate and create 4 tables until I got it right;
dropped temp tables and created the new_vendor again;
got deleted after closing SQLite anyway */

-- Date
/*1. Get the customer_id, month, and year (in separate columns) of every purchase in the customer_purchases table.

HINT: you might need to search for strfrtime modifers sqlite on the web to know what the modifers for month 
and year are! */



/* 2. Using the previous query as a base, determine how much money each customer spent in April 2022. 
Remember that money spent is quantity*cost_to_customer_per_qty. 

HINTS: you will need to AGGREGATE, GROUP BY, and filter...
but remember, STRFTIME returns a STRING for your WHERE statement!! */

