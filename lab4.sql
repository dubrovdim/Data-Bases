-- 1.1 Підрахунок загальної кількості зареєстрованих клієнтів
SELECT COUNT(*) AS total_customers
FROM customers;

-- 1.2 Статистика цін на фільми в каталозі
SELECT 
    AVG(price) AS average_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM movies;

-- 1.3 Підрахунок загальної суми, яку витратив кожен клієнт
SELECT 
    r.customer_id, 
    SUM(p.amount) AS total_spent
FROM rentals r
JOIN payments p ON r.rental_id = p.rental_id
GROUP BY r.customer_id;

-- 1.4 Знайти клієнтів (їх ID), які оформили більше ніж 1 прокат
SELECT 
    customer_id, 
    COUNT(rental_id) AS total_rentals
FROM rentals
GROUP BY customer_id
HAVING COUNT(rental_id) > 1;


-- 2.1 Отримати список усіх прокатiв з іменами клієнтів та назвами фільмів
SELECT 
    r.rental_id, 
    c.name AS customer_name, 
    m.title AS movie_title, 
    r.rental_date
FROM rentals r
INNER JOIN customers c ON r.customer_id = c.customer_id
INNER JOIN movies m ON r.movie_id = m.movie_id;

-- 2.2 Показати всі фільми та інформацію про їх прокат
SELECT 
    m.title, 
    r.rental_date
FROM movies m
LEFT JOIN rentals r ON m.movie_id = r.movie_id;

-- 2.3 Показати всіх клієнтів та суми їхніх платежів
SELECT 
    c.name, 
    p.amount
FROM payments p
INNER JOIN rentals r ON p.rental_id = r.rental_id
RIGHT JOIN customers c ON r.customer_id = c.customer_id;


-- 3.1 Знайти імена клієнтів, які брали в прокат найдорожчий фільм у каталозі
SELECT DISTINCT c.name
FROM customers c
JOIN rentals r ON c.customer_id = r.customer_id
JOIN movies m ON r.movie_id = m.movie_id
WHERE m.price = (SELECT MAX(price) FROM movies);

-- 3.2 Для кожного фільму показати, наскільки його ціна відрізняється від середньої
SELECT 
    title, 
    price,
    (SELECT AVG(price) FROM movies) AS avg_catalog_price,
    price - (SELECT AVG(price) FROM movies) AS price_difference
FROM movies;

-- 3.3 Знайти клієнтів, які витратили на прокат більше, ніж в середньому витрачає один клієнт
SELECT 
    r.customer_id, 
    SUM(p.amount) AS total_spent
FROM rentals r
JOIN payments p ON r.rental_id = p.rental_id
GROUP BY r.customer_id
HAVING SUM(p.amount) > (
    SELECT AVG(total) FROM (
        SELECT SUM(amount) AS total 
        FROM rentals r2 
        JOIN payments p2 ON r2.rental_id = p2.rental_id 
        GROUP BY r2.customer_id
    ) AS avg_spending
);