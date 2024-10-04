
-- Solutions of 15 business problems
--1. Count the number of Movies vs TV Show
SELECT 
	type,
	COUNT(*)
FROM netflix_3
GROUP BY 1
--query ended 

--2. Find the most common rating for movies and TV shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix_3
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;
--query ended

--3. List all movies released in a specific year (e.g 2020) 
SELECT * 
FROM netflix_3
WHERE release_year = 2020
--query ended


--4. Find the top 5 countries with the most content on Netflix
SELECT * 
FROM
(
	SELECT 
		 
		UNNEST(STRING_TO_ARRAY(country, ', ')) as country,
		COUNT(*) as total_content
	FROM netflix_3
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5
--query ended

--5. Identify the longest movie
SELECT 
	*
FROM netflix_3
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
--query ended 

--6. Find content added in the last 5 years
SELECT
*
FROM netflix_3
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'
--query ended

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM
(

SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
FROM 
netflix_3
)
WHERE 
	director_name = 'Rajiv Chilaka'
	--query ended

--8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix_3
WHERE 
	TYPE = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5
    --query ended 

--9. Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix_3
--query ended 
GROUP BY 1;
--query ended

-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
select extract(year from to_date(date_added,'month dd, yyyy')) as year,
round( count(*):: numeric /( select count(*) from netflix_3
where country ='India')::numeric*100 ,2)
from netflix_3
where country='India'
group by 1
order by 2 desc
limit 5;
--query ended

--11. List all movies that are documentaries
with cte as (select title,unnest( string_to_array(listed_in,', ')) as genre
from netflix_3)
select * from cte 
where genre = 'Documentaries';
--query ended

--12. Find all content without a director
select title, director
from netflix_3
where director is null;
--query ended

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
with cte as (select release_year,type,title, unnest(string_to_array(casts,', ')) as unnest_cast from netflix_3 where type='Movie')
select title, unnest_cast from cte
where unnest_cast like'Salman Khan%'
and 
release_year >= extract(year from current_date)-10;
--query ended

--14 Find the top 10 actors who have appeared in the highest number of movies produced in India.
with cte as ( select *, unnest (string_to_array(casts,', ')) as unnest_cast from  netflix_3
where  country = 'India'
)

select unnest_cast, count(*) from cte 
group by unnest_cast 
order by 2 desc
limit 10;
--query ended

/*15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2

 




