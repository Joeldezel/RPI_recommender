--Instruction to run code: 
--1. Start run on RPI
--2. Move to directory RSL with the code 'cd RSL'
--3. Run the .sql file with the code 'psql test -f <filename>.sql'

-- (Re)starting the assignment by dropping the movies table if it already exists so there will be no errors when importing the data form the csv file
DROP TABLE IF EXISTS movies;

-- Create table for movie database
CREATE TABLE movies (
url text,
title text,
ReleaseDate text,
Distributor text,
Starring text,
Summary text,
Director text,
Genre text,
Rating text,
Runtime text,
Userscore text,
Metascore text,
scoreCounts text
);

-- Copy Metacritic data from RSL folder to table movies
\copy movies FROM '/home/pi/RSL/moviesFromMetacritic.csv' delimiter ';' csv header;

-- Show movies with url Fight Club (left out because not relevant to show in this script)
--SELECT * FROM movies where url='fight-club';
--\q

-- Add lexemesSummary column to table
-- Lexemes are useful for text search and uses text cleaning, stopword removal etc.
ALTER TABLE movies
ADD IF NOT EXISTS lexemesSummary tsvector;

-- Set lexemesSummary column to tsvector representation
UPDATE movies 
SET lexemesSummary = to_tsvector(Summary);

-- Show movies with fight in lexemesSummary column (left out because not relevant to show in this script)
--SELECT url FROM movies 
--WHERE lexemesSummary @@ to_tsquery('fight')

-- Add column rank classified as a float variable
ALTER TABLE movies 
ADD IF NOT EXISTS rank float4;

-- Set column rank to text search function based on the summary field (lexemesSummary)
UPDATE movies 
SET rank = ts_rank(lexemesSummary, plainto_tsquery((
SELECT Summary FROM movies WHERE url='fight-club'))); 

-- Create a new table that stores a top 50 of recommended movies based on the summary of the movie url and save as a csv in the RSL folder
CREATE TABLE IF NOT EXISTS recommendationsBasedOnSummaryField AS
SELECT url, rank FROM movies WHERE rank > 0.40 ORDER BY rank DESC LIMIT 50;
\copy (SELECT * FROM recommendationsBasedOnSummaryField) to '/home/pi/RSL/SummaryTop50Recommendations.csv' WITH csv;

-- Interpretation of results: Setting the results to have a rank higher than >0.99 only results in 1 movie to be recommended, namely Fight Club itself. Therefore a lower value of 0.40 was selected and it now shows 50 results. The results show mostly results of movies that I am not familiar with, however reading the summaries of the top recommended movies in the list, they have some similarities to Fight Club such as the movie being a thriler with some aspects of violence.

-- Continuing with the assignment: adding recommendations based on 1) title field and 2) starring field to see if there will be more realistic results. The decision is made to keep the same rank column and change what it ranks on.
ALTER TABLE movies
ADD IF NOT EXISTS lexemesTitle tsvector;

UPDATE movies 
SET lexemesTitle = to_tsvector(title);

UPDATE movies
SET rank = ts_rank(lexemesTitle, plainto_tsquery((
SELECT title FROM movies WHERE url='titanic'))); 

CREATE TABLE IF NOT EXISTS recommendationsBasedOnTitleField AS
SELECT url, rank FROM movies WHERE rank > 0.0001 ORDER BY rank DESC LIMIT 50;
\copy (SELECT * FROM recommendationsBasedOnTitleField) to '/home/pi/RSL/TitleTop50Recommendations.csv' WITH csv;

-- Interpretation of results: unfortunately there is not a movie showing with a similar title to Fight Club, therefore changing it to another movie "Titanic" to show some results, which shows 5 results of movies with some form of Titan in the title.

ALTER TABLE movies
ADD IF NOT EXISTS lexemesStarring tsvector;

UPDATE movies 
SET lexemesStarring = to_tsvector(Starring);

UPDATE movies
SET rank = ts_rank(lexemesStarring, plainto_tsquery((
SELECT Starring FROM movies WHERE url='fight-club'))); 

CREATE TABLE IF NOT EXISTS recommendationsBasedOnStarringField AS
SELECT url, rank FROM movies WHERE rank > 0.0001 ORDER BY rank DESC LIMIT 50;
\copy (SELECT * FROM recommendationsBasedOnStarringField) to '/home/pi/RSL/StarringTop50Recommendations.csv' WITH csv;

-- Interpretation of results: recommender shows movies in which Brad Pitt is starring, in that sense the recommendation works good. I find it curious that Fight Club only get's a 0.46 ranking, because this is the movie that it is based on and therefore a rank of 1.00 is expected. 

