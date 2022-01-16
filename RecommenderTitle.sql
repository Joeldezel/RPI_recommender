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

-- Add lexemesSummary column to table
-- Lexemes are useful for text search and uses text cleaning, stopword removal etc.
ALTER TABLE movies
ADD IF NOT EXISTS lexemesTitle tsvector;

-- Set lexemesSummary column to tsvector representation
UPDATE movies 
SET lexemesTitle = to_tsvector(title);

-- Add column rank classified as a float variable
ALTER TABLE movies 
ADD IF NOT EXISTS rank float4;

-- Set column rank to text search function based on the title field (lexemesSummary)
UPDATE movies
SET rank = ts_rank(lexemesTitle, plainto_tsquery((
SELECT title FROM movies WHERE url='titanic'))); 

-- Create a new table that stores a top 50 of recommended movies based on the title of the movie url and save as a csv in the RSL folder
CREATE TABLE IF NOT EXISTS recommendationsBasedOnTitleField AS
SELECT url, rank FROM movies WHERE rank > 0.0001 ORDER BY rank DESC LIMIT 50;
\copy (SELECT * FROM recommendationsBasedOnTitleField) to '/home/pi/RSL/TitleTop50Recommendations.csv'

-- Interpretation of results: unfortunately there is not a movie showing with a similar title to Fight Club, therefore changing it to another movie "Titanic" to show some results, which shows 5 results of movies with some form of Titan in the title.
