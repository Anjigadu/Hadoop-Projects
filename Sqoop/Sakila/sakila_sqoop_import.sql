-- [MYSQL]
show databases;
show schemas;

-- Query to create a view for film display. Later used as a table by hive

CREATE VIEW v_film
AS
SELECT f.film_id,title,description,release_year,f.language_id,original_language_id,rental_duration,rental_rate,length,
       replacement_cost,rating,
FROM film f
JOIN language l
ON l.language_id = f.language_id
JOIN film_category fc
ON fc.film_id = f.film_id
JOIN category c
ON c.category_id = fc.category_id
LEFT JOIN film_actor fa 
ON fa.film_id = f.film_id
LEFT JOIN actor a
ON a.actor_id = fa.actor_id
GROUP BY f.film_id;

replace(special_features, ',','|') special_features, 
f.last_update, l.name language,
concat(fc.category_id, '=',c.name) category, 
group_concat(distinct concat(a.actor_id, '=',a.first_name, ' ', a.last_name) order by a.first_name, a.last_name separator '|') actors

-- a query to be used as is by sqoop
SELECT p.payment_id, p.rental_id, p.amount, p.payment_date, p.last_update, c.customer_id, 
       concat(c.first_name, ' ', c.last_name) customer_name,
       s.staff_id, concat(s.first_name, ' ', s.last_name) staff_name
FROM payment p  
join customer c 
on c.customer_id = p.customer_id  
join staff s 
on s.staff_id = p.staff_id
join rental r 
on r.rental_id = p.rental_id;
