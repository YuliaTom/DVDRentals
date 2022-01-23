-- 1. Query 1:
-- Shows three columns: month of the year, family friendly films and other films.
-- The last two columns summarise number of films that fall into one or another category.--
WITH tbl1 AS
	(SELECT DATE_TRUNC('month', r.rental_date) AS month_of_year,
	COUNT(*) AS family_film_rentals
	FROM film f
	JOIN film_category fc
	ON f.film_id  = fc.film_id
	JOIN category c
	ON c.category_id = fc.category_id
	JOIN inventory i
	ON i.film_id = f.film_id
	JOIN rental r
	ON i.inventory_id = r.inventory_id
	WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
	GROUP BY 1
	ORDER BY 1),
	tbl2 AS
	(SELECT DATE_TRUNC('month', r.rental_date) AS month_of_year,
	COUNT(*) AS nonfamily_film_rentals
	FROM film f
	JOIN film_category fc
	ON f.film_id  = fc.film_id
	JOIN category c
	ON c.category_id = fc.category_id
	JOIN inventory i
	ON i.film_id = f.film_id
	JOIN rental r
	ON i.inventory_id = r.inventory_id
	WHERE c.name NOT IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
	GROUP BY 1
	ORDER BY 1)
SELECT tbl1.month_of_year, tbl1.family_film_rentals, tbl2.nonfamily_film_rentals
FROM tbl1 JOIN tbl2
ON tbl1.month_of_year = tbl2.month_of_year;



-- 2. Query 2:
-- Returns two columns: country and average pament per customer. --
SELECT ctr.country AS country, ROUND((SUM(sub.payment_sum)/COUNT(c.customer_id)),2) AS pay_per_customer
FROM
	(SELECT c.customer_id AS id, CONCAT(c.first_name, ' ', c.last_name) AS customer,
	COUNT(*) AS pay_count, SUM(p.amount) payment_sum
	FROM payment p
	JOIN customer c
	ON p.customer_id = c.customer_id
	WHERE p.payment_date BETWEEN '2007-01-01' AND '2008-01-01'
	GROUP BY 1
	ORDER BY 4 DESC) sub
JOIN customer c
ON sub.id = c.customer_id
JOIN address a
ON c.address_id = a.address_id
JOIN city ct
ON a.city_id = ct.city_id
JOIN country ctr
ON ct.country_id = ctr.country_id
GROUP BY 1
ORDER BY 2 DESC;


-- 3. Query 3:
-- Shows three columns: category/genre, number of rentals and average price. --
SELECT c.name AS category, COUNT(*) as num_of_rentals, ROUND(AVG(p.amount),2) AS avg_price
FROM film f
JOIN film_category fc
ON f.film_id  = fc.film_id
JOIN category c
ON c.category_id = fc.category_id
JOIN inventory i
ON i.film_id = f.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment p
ON p.rental_id = r.rental_id
GROUP BY 1
ORDER BY 2,1 DESC;



-- 4. Query 4:
-- Returns three columns: month of the year, running total store 1 and running total store 2.
-- The latter two columns show accumulated sales for each store. --
SELECT sub1.month, SUM(sub1.amount) OVER (ORDER BY sub1.month) AS run_total_store1,
SUM(sub2.amount) OVER (ORDER BY sub2.month) AS run_total_store2
FROM
	(SELECT DATE_TRUNC('month', p.payment_date) AS month,
	SUM(p.amount) amount
	FROM payment p
	JOIN staff s
	ON p.staff_id = s.staff_id
	JOIN store st
	ON st.store_id = s.store_id
	WHERE st.store_id = 1
	GROUP BY 1
	ORDER BY 1) sub1
JOIN
	(SELECT DATE_TRUNC('month', p.payment_date) AS month,
	SUM(p.amount) amount
	FROM payment p
	JOIN staff s
	ON p.staff_id = s.staff_id
	JOIN store st
	ON st.store_id = s.store_id
	WHERE st.store_id = 2
	GROUP BY 1
	ORDER BY 1
	) sub2
ON sub1.month = sub2.month;
