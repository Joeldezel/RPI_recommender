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
ADD IF NOT EXISTS lexemesSummary tsvector;

-- Set lexemesSummary column to tsvector representation
UPDATE movies 
SET lexemesSummary = to_tsvector(Summary);

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
