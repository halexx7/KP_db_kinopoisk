USE kinopoisk;

-- Сегодня в кино
DROP VIEW IF EXISTS sinema_today;
CREATE VIEW sinema_today
AS
SELECT 
	c.name AS сinemas,
	f.name AS film,
	p.sessions AS sessions,
	p.price AS price
	
FROM 
	poster AS p
JOIN cinemas AS c ON p.cinemas_id = c.id
JOIN film AS f ON p.film_id = f.id
WHERE and p.sessions > '2019-09-01 00:00:00';

SELECT 
	c.name AS cinemas,
	city_id AS city_id,
	city AS city
FROM
	cinemas AS c
LEFT JOIN address ON c.address_id = address.city_id;
LEFT JOIN city ON 

SELECT * FROM genre
UNION
SELECT id FROM profession