## Windows Function

-- this section is created using Mavenmovies database 
---------------------------------------------------------------------------------
USE mavenmovies;
---------------------------------------------------------------------------------

-- Question 1: Rank the customers based on the total amount they've spent on rentals
SELECT customer_id, first_name, last_name, SUM(amount) AS total_spent,
       RANK() OVER (ORDER BY SUM(amount) DESC) AS ranking
FROM payment
JOIN customer USING (customer_id)
GROUP BY customer_id, first_name, last_name
ORDER BY ranking;
---------------------------------------------------------------------------------
-- Question 2: Calculate the cumulative revenue generated by each film over time
SELECT f.film_id, f.title, p.payment_date, SUM(p.amount) 
       OVER (PARTITION BY f.film_id ORDER BY p.payment_date) AS cumulative_revenue
FROM payment p
JOIN rental r USING (rental_id)
JOIN inventory i USING (inventory_id)
JOIN film f USING (film_id);
---------------------------------------------------------------------------------
-- Question 3: Determine the average rental duration for each film, considering films with similar lengths
SELECT film_id, title, length, AVG(rental_duration) 
       OVER (PARTITION BY length) AS avg_rental_duration
FROM film;
---------------------------------------------------------------------------------
-- Question 4: Identify the top 3 films in each category based on their rental counts
SELECT c.name AS category, f.title, COUNT(r.rental_id) AS rental_count,
       RANK() OVER (PARTITION BY c.name ORDER BY COUNT(r.rental_id) DESC) AS ranking
FROM rental r
JOIN inventory i USING (inventory_id)
JOIN film f USING (film_id)
JOIN film_category fc USING (film_id)
JOIN category c USING (category_id)
GROUP BY c.name, f.title
HAVING ranking <= 3;
---------------------------------------------------------------------------------
-- Question 5: Calculate the difference in rental counts between each customer's total rentals and the average rentals across all customers
SELECT customer_id, first_name, last_name, COUNT(r.rental_id) AS total_rentals,
       COUNT(r.rental_id) - AVG(COUNT(r.rental_id)) 
       OVER () AS rental_difference
FROM rental r
JOIN customer c USING (customer_id)
GROUP BY customer_id, first_name, last_name;
---------------------------------------------------------------------------------
-- Question 6: Find the monthly revenue trend for the entire rental store over time
SELECT YEAR(payment_date) AS year, MONTH(payment_date) AS month, SUM(amount) AS total_revenue,
       SUM(SUM(amount)) OVER (ORDER BY YEAR(payment_date), MONTH(payment_date)) AS cumulative_revenue
FROM payment
GROUP BY YEAR(payment_date), MONTH(payment_date);
---------------------------------------------------------------------------------
-- Question 7: Identify the customers whose total spending on rentals falls within the top 20% of all customers
WITH CustomerSpending AS (
    SELECT customer_id, SUM(amount) AS total_spent,
           NTILE(5) OVER (ORDER BY SUM(amount) DESC) AS spending_group
    FROM payment
    GROUP BY customer_id
)
SELECT customer_id, total_spent FROM CustomerSpending WHERE spending_group = 1;
---------------------------------------------------------------------------------
-- Question 8: Calculate the running total of rentals per category, ordered by rental count
SELECT c.name AS category, COUNT(r.rental_id) AS rental_count,
       SUM(COUNT(r.rental_id)) OVER (PARTITION BY c.name ORDER BY COUNT(r.rental_id) DESC) AS running_total
FROM rental r
JOIN inventory i USING (inventory_id)
JOIN film f USING (film_id)
JOIN film_category fc USING (film_id)
JOIN category c USING (category_id)
GROUP BY c.name, f.title;
---------------------------------------------------------------------------------
-- Question 9: Find the films that have been rented less than the average rental count for their respective categories
WITH AvgCategoryRentals AS (
    SELECT c.name AS category, f.film_id, f.title, COUNT(r.rental_id) AS rental_count,
           AVG(COUNT(r.rental_id)) OVER (PARTITION BY c.name) AS avg_rental_count
    FROM rental r
    JOIN inventory i USING (inventory_id)
    JOIN film f USING (film_id)
    JOIN film_category fc USING (film_id)
    JOIN category c USING (category_id)
    GROUP BY c.name, f.film_id, f.title
)
SELECT film_id, title, rental_count FROM AvgCategoryRentals 
WHERE rental_count < avg_rental_count;
---------------------------------------------------------------------------------
-- Question 10: Identify the top 5 months with the highest revenue and display the revenue generated in each month
SELECT YEAR(payment_date) AS year, MONTH(payment_date) AS month, SUM(amount) AS total_revenue
FROM payment
GROUP BY YEAR(payment_date), MONTH(payment_date)
ORDER BY total_revenue DESC
LIMIT 5;