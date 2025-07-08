-- Netflix Project
drop table if exists netlix;
create table netlix
(
	show_id	varchar(6),
	type varchar(10),
	title varchar(150),
	director varchar(208),
	casts varchar(1000),
	country	varchar(150),
	date_added varchar(50),
	release_year int,
	rating	varchar(10),
	duration varchar(15),
	listed_in varchar(100),
	description varchar(250)
);

select * from netlix;

select count(*) as total_count from netlix;

select distinct(type)as unique_types from netlix;

-- 15 Business Problems.
--1. Count the number of Movies vs TV Shows
select type, count(*) as total_content
from netlix
group by type;

select count(type) as Movie_count from netlix
where type='Movie';
select count(type) as TV_shows_count from netlix
where type='TV Show';

-- 2. Find the most common rating for movies and TV shows
select type,
rating
from
(
	select type,rating,count(*) as total_count,
	rank() over(partition by type order by count(*) desc)as ranking
	from netlix
	group by 1,2
) as t1
where t1.ranking = 1
--order by 1,3 desc

-- 3. List all movies released in a specific year (e.g., 2020)
select title,type,release_year from netlix
where type='Movie' and release_year=2020 
order by release_year asc;

select date_added from netlix
where date_added like '%2020%';

-- 4. Find the top 5 countries with the most content on Netflix
select unnest(string_to_array(country,','))as new_country_name,
count(show_id) as total_content
from netlix
group by 1
order by 2 desc
limit 5;

-- 5. Identify the longest movie
select title,duration from netlix
where type='Movie' and duration = (select max(duration) from netlix);

-- 6. Find content added in the last 5 years
select * from netlix
where to_date(date_added,'Month DD, YYYY') >= current_date - interval '5 years';

select current_date - interval '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from netlix
where director ilike '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
select * from netlix
where type='TV Show' and split_part(duration,' ',1)::numeric > 5;

-- 9. Count the number of content items in each genre
select unnest(string_to_array(listed_in,',')) as genre,
count(show_id) as total_count from netlix
group by 1;

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
select 
extract(year from to_date(date_added,'Month DD YYYY')) as year,
count(*) as yearly_content,
round(count(*)::numeric/(select count(*) from netlix where country='India')::numeric*100,2) 
as avg_content_per_year
from netlix 
where country='India'
group by 1;

-- 11. List all movies that are documentaries
select * from netlix
where listed_in ilike '%documentaries%';

-- 12. Find all content without a director
select * from netlix
where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netlix
where casts ilike '%salman khan%'
and release_year > extract(year from current_date) -10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select 
unnest(string_to_array(casts,','))as actors, 
count(*) as total_content 
from netlix 
where country ilike '%india%'
group by 1
order by 2 desc
limit 10

-- 15.
--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
with new_table as
(
select *, 
case
when description ilike '%kill%' or description like '%violence%' then 'Bad_Content'
else 'Good Content'
end category
from netlix
)
select category,count(*) as total_content from new_table group by 1;
