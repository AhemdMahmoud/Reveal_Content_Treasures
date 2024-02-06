create database Netflix
use Netflix

Exec sp_help 'dbo.titles' --to show all thing

-- What were the top 10 movies according to IMDB score?
-- CAST(imdb_score AS decimal(5,2)) AS imdb_score dont work
SELECT TOP 10
    title,
    type,
    TRY_CONVERT(decimal(5,1), imdb_score) AS imdb_score
FROM
    dbo.titles
WHERE
    TRY_CONVERT(decimal(5,1), imdb_score) >= 8.0
    AND type = 'MOVIE'
ORDER BY
    TRY_CONVERT(decimal(5,1), imdb_score) DESC;

-- What were the top 10 show according to IMDB score?
SELECT TOP 10
    title,
    type,
    TRY_CONVERT(decimal(5,1), imdb_score) AS imdb_score
FROM
    dbo.titles
WHERE
   TRY_CONVERT (decimal(5,1),imdb_score) >=8.0 and TRY_CONVERT (decimal(5,1),imdb_score) IS NOT NULL
    AND type = 'show'
ORDER BY
    TRY_CONVERT(decimal(5,1), imdb_score) DESC;

-- What were the down 10 move according to IMDB score?
SELECT TOP 10
    title,
    type,
    TRY_CONVERT(decimal(5,1), imdb_score) as imdb_score
FROM
    dbo.titles
WHERE
    type = 'MOVIE'
    AND TRY_CONVERT(decimal(5,1), imdb_score) IS NOT NULL
ORDER BY
    TRY_CONVERT(decimal(5,1), imdb_score) ASC;

-- What were the down 10 show according to IMDB score?
SELECT TOP 10
    title,
    type,
    TRY_CONVERT(decimal(5,1), imdb_score) as imdb_score
FROM
    dbo.titles
WHERE
    type = 'show'
    AND TRY_CONVERT(decimal(5,1), imdb_score) IS NOT NULL
ORDER BY
    TRY_CONVERT(decimal(5,1), imdb_score) ASC; 

-- What were the average IMDB and TMDB scores for shows and movies? 
select DISTINCT type ,round (AVG (TRY_CONVERT(decimal(5,1), imdb_score)),2) as imdb_score ,round(AVG(TRY_CONVERT(decimal(5,1), TMDB_score)),2) asTMDB_score 
from dbo.titles 
group by  type

-- Count of movies and shows in each decade
SELECT CONCAT(CAST(FLOOR(release_year / 10) * 10 AS VARCHAR), 's') AS decade,
       COUNT(*) AS movies_shows_count
FROM dbo.titles
WHERE release_year >= 1940
GROUP BY CONCAT(CAST(FLOOR(release_year / 10) * 10 AS VARCHAR), 's')
ORDER BY decade;

-- What were the average IMDB and TMDB scores for each production country?
select distinct production_countries,round (AVG (TRY_CONVERT(decimal(5,1), imdb_score)),2) as Avg_imdb_score ,round (AVG (TRY_CONVERT(decimal(5,1),tmdb_score)),2) as Avg_tmdb_score
from dbo.titles
group by production_countries
order by Avg_imdb_score desc

-- What were the average IMDB and TMDB scores for each age certification for shows and movies?
select distinct age_certification,round (AVG (TRY_CONVERT(decimal(5,1), imdb_score)),2) as Avg_imdb_score ,round (AVG (TRY_CONVERT(decimal(5,1),tmdb_score)),2) as Avg_tmdb_score
from dbo.titles 
where age_certification <> ''
group by age_certification
order by Avg_imdb_score desc

-- What were the 5 most common age certifications for movies?
select distinct top 5 age_certification,count (*) as count_age_certification
from dbo.titles
where type ='movie' and age_certification <> '' 
group by age_certification 
order by count_age_certification desc

-- Who were the top 20 actors that appeared the most in movies/shows?
select top 20 ds.name ,count(*) as number_of_appearences 
from dbo.credits as ds
where role='Actor'
group by name
order by number_of_appearences desc

-- Who were the top 20 directors that directed the most movies/shows? 
select top 20 ds.name ,count(*) as number_of_appearences 
from dbo.credits as ds
where role='director'
group by name
order by number_of_appearences desc

-- Calculating the average runtime of movies and TV shows separately
select CONCAT( Avg (try_convert(int ,runtime)),' M') as Avg_runtime ,type  as content_type 
from dbo.titles 
group by  type 
---or  use the bleow
SELECT 
'Movies' AS content_type,
ROUND(AVG(try_convert(int,runtime)),2) AS avg_runtime_min
FROM dbo.titles
WHERE type = 'Movie'
UNION ALL
SELECT 
'Show' AS content_type,
ROUND(AVG(try_convert(int,runtime)),2) AS avg_runtime_min
FROM dbo.titles
WHERE type = 'Show';

-- Finding the titles and  directors of movies released on or after 2010 
select distinct t.title  ,c.name as directors ,t.release_year
from dbo.credits as c
join 
dbo.titles as t
on t.id=c.id 
where  release_year >=2010 and role='director' and type='movie'
order by release_year desc

-- Which shows on Netflix have the most seasons?
SELECT TOP 10
    title,
    SUM(CAST(seasons AS DECIMAL(10,2))) AS most_seasons
FROM 
    dbo.titles
WHERE 
    type = 'show' 
GROUP BY 
    title
ORDER BY 
    most_seasons DESC;

-- Which genres had the most movies? 
--"What are the top movie genres based on the number of movies and the sum of their IMDB scores?
select distinct genres,count(*) as count_movies ,sum(TRY_CONVERT(decimal(5,1), imdb_score)) as Sum_imdb_score
FROM 
    dbo.titles
WHERE 
    type = 'movie' 
GROUP BY 
    genres 
ORDER BY 
    count_movies DESC;
-- Which genres had the most shows? 
select distinct  genres,count(*) as count_shows
FROM 
    dbo.titles
WHERE 
    type = 'show' 
GROUP BY 
    genres 
ORDER BY 
    count_shows DESC;

-- "What are the titles, directors, and genres of movies that have both high IMDB scores (>7.5) and high TMDB popularity scores (>80)?"
select t.title,c.name  as Director,genres
from dbo.titles as t
join 
dbo.credits as c 
on c.id=t.id
where try_convert(decimal(5,1),imdb_score)>7.5 and try_convert(decimal(5,2),tmdb_popularity)>80 and role='director' and type='movie'

-- What were the total number of titles for each year? 
select count (*)as title_count , release_year
from dbo.titles
group by release_year
order by release_year desc 

-- Actors who have starred in the most highly rated movies or shows
SELECT c.name AS actor, 
COUNT(*) AS num_highly_rated_titles
FROM dbo.credits AS c
JOIN dbo.titles AS t 
ON c.id = t.id
WHERE c.role = 'actor'
AND (t.type = 'Movie' OR t.type = 'Show')
AND try_convert(decimal(5,1),t.imdb_score) > 8.0
AND try_convert(decimal(5,2),tmdb_score) > 8.0
GROUP BY c.name
ORDER BY num_highly_rated_titles DESC;

-- Which actors/actresses played the same character in multiple movies or TV shows? 
SELECT c.name AS actor_actress, 
c.character, 
COUNT(DISTINCT t.title) AS num_titles
FROM dbo.credits AS c
JOIN dbo.titles AS t 
ON c.id = t.id
WHERE c.role = 'actor' OR c.role = 'actress'
GROUP BY c.name, c.character
HAVING COUNT(DISTINCT t.title) > 1;

-- What were the top 3 most common genres?
select top 3 genres , count (*) as genre_count
from dbo.titles as t
 WHERE t.type = 'Movie'
group by genres
order by genre_count desc

-- Average IMDB score for leading actors/actresses in movies or shows 
--"What are the average IMDB scores for leading actors/actresses in their respective genres, considering only those credited with a leading role?
--can use this information to make informed decisions about casting leading roles
select c.name,AVG(try_convert(decimal(6,1),t.imdb_score)) as Avg_imdb_score,genres
FROM dbo.credits AS c
JOIN dbo.titles AS t 
ON c.id = t.id
WHERE c.role = 'actor' OR c.role = 'actress' AND c.character = 'leading role'
group by name,genres
order by Avg_imdb_score desc





















