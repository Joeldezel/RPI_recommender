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
ADD IF NOT EXISTS lexemesStarring tsvector;

-- Set lexemesSummary column to tsvector representation
UPDATE movies 
SET lexemesStarring = to_tsvector(Starring);

-- Add column rank classified as a float variable
ALTER TABLE movies 
ADD IF NOT EXISTS rank float4;

-- Set column rank to text search function based on the starring field (lexemesSummary)
UPDATE movies
SET rank = ts_rank(lexemesStarring, plainto_tsquery((
SELECT Starring FROM movies WHERE url='fight-club'))); 

-- Create a new table that stores a top 50 of recommended movies based on the starring of the movie url and save as a csv in the RSL folder
CREATE TABLE IF NOT EXISTS recommendationsBasedOnStarringField AS
SELECT url, rank FROM movies WHERE rank > 0.0001 ORDER BY rank DESC LIMIT 50;
\copy (SELECT * FROM recommendationsBasedOnStarringField) to '/home/pi/RSL/StarringTop50Recommendations.csv' WITH csv;

-- Interpretation of results: recommender shows movies in which Brad Pitt is starring, in that sense the recommendation works good. I find it curious that Fight Club only get's a 0.46 ranking, because this is the movie that it is based on and therefore a rank of 1.00 is expected. 