--Instruction to run code: 
--1. Start run on RPI
--2. Move to directory RSL with the code 'cd RSL'
--3. Run the .sql file with the code 'psql test -f <filename>.sql'

-- (Re)starting assignment by dropping all tables needed for the recommender system if they exist
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS recommendationsBasedOnSummaryField;
DROP TABLE IF EXISTS recommendationsBasedOnTitleField;
DROP TABLE IF EXISTS recommendationsBasedOnStarringField;
