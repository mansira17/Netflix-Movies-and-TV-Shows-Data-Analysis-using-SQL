-- Netflix Project

DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix
(
	show_id	VARCHAR(6),
	type VARCHAR(10),	
	title VARCHAR(150),	
	director VARCHAR(250),	
	casts VARCHAR(1000),	
	country	VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,	
	rating VARCHAR(20),
	duration VARCHAR(20),	
	listed_in VARCHAR(100),	
	description VARCHAR(300)
);

select * from netflix

-- 1. Count the number of Movies vs. TV Shows

select 
	type, 
	count(*) as total_content
from netflix
group by type

-- 2. Find the most common rating for Movies and TV Shows

select
	type,
	rating
from(
select
	type,
	rating,
	count(*),
	rank() over(partition by type
				order by count(*) desc) as ranking
from netflix
group by type, rating
) as t1
where ranking = 1

-- 3. List all movies released in a specific year(eg:- 2020)

select * 
from netflix
where type = 'Movie' and release_year = '2020'

-- 4. Find the top 5 countries with the most content on Netflix

select 
	unnest(string_to_array(country, ',')) as new_country,
	count(*) as total_content
from netflix
group by new_country
order by total_content desc
limit 5

-- 5. Identify the longest movie

select  title, duration
from netflix
where type = 'Movie' and
	  duration = (select max(duration)
	  			  from netflix)

-- 6. Find the content added in last 5 years

select *
from netflix
where 
	to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years'

-- 7. Find all the movies / tv shows by director 'Rajiv Chilaka'

select *
from netflix
where director like '%Rajiv Chilaka%'

-- 8. List all TV Shows with more than 5 seasons

select *
from netflix
where type = 'TV Show' and
      split_part(duration, ' ', 1)::numeric > 5

-- 9. Count the number of content item in each genre

select 
	unnest(string_to_array(listed_in, ',')) as new_genre,
	count(*) as total_content
from netflix
group by new_genre

-- 10. Find each year and the average number of content released by India on netflix.
-- Return the top 5 years with highest average content release

select 
	extract(year from to_date(date_added, 'Month DD, YYYY')) as year,
	count(*),
	round(
		count(*)::numeric / (select count(*)
							 from netflix
				             where country = 'India')::numeric * 100, 
		2)as avg_content
from netflix
where country = 'India'
group by year
order by avg_content desc
limit 5

-- 11. List all movies that are documentaries

select *
from netflix
where listed_in ilike '%documentaries%'

-- 12. Find all content without a director

select *
from netflix
where director is null

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years

select *
from netflix
where 
	casts like '%Salman Khan%' and
	release_year > extract(year from current_date) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
	unnest(string_to_array(casts, ',')) as actor,
	count(*)
from netflix
where country = 'India'
group by actor
order by count(*) desc
limit 10

-- 15. Categorize content based on the presence of 'kill' and 'violence' keywords in the description field.
-- Label content containing these keywords as 'Bad' and all other content as 'Good'.
-- Count how many fall into each category.

select 
	category,
	count(*) as total_content
from(
select
	case 
		when description ilike '%kill%' or
		     description ilike '%violence%' then 'Bad'
		else 'Good'
	end as category
from netflix) as categorized_content
group by category

