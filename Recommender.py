# To start the assignment go to the VE folder and the type "python Recommender.py"

# Importing libraries
import csv
from itertools import islice

# Opening the csv file
with open('userReviews all three parts.csv', 'r') as UserReviews:
	csv_reader = csv.reader(UserReviews, delimiter=';')

	
# First printing the header and first row to see what the data looks like (optional)
	print("Printing the header and the first row to see what the data looks like")
	for line in islice(csv_reader,2):
		print(line)

# Part 1: If the first columns equals <your favorite movie>, add the userscore to the sum of score and count per instance. 

	favoritemovie = 'fight-club'
	sum = 0
	count = 0
	avg = 0
	
	for line in csv_reader:
		if (line[0]) == favoritemovie:
			sum+=float(line[1])
			count = count+1

	avg = sum/count
	print("The average user score for " +str(favoritemovie) +  " is: " + str(avg) + ", based on " +str(count)+ " reviews")
# Interpretation of result: a user score of 9.15 is very high, I liked the movie a lot and part of this high score is due to the rise of a cult based on this movie and a strong fan base

# Second part of the assignment: store movies in a csv that 1) have a higher user score than my favorite movies average (9.15) and 2) have been reviewed by author that also reviewed my favorite movie
# Storing authors that reviewed my favorite movie in a new list called authorlist
with open('userReviews all three parts.csv', 'r') as UserReviews:
	csv_reader = csv.reader(UserReviews, delimiter=';')

	authorlist = []

	for line in csv_reader:
		if (line[0]) == favoritemovie:
			authorlist.append(line[2])
	
# Storing information of the author, movie name and score if the user score is above my favorite movie and the movie has been seen by the reviewer of my favorite movie and printing the results
with open('userReviews all three parts.csv', 'r') as UserReviews:
	csv_reader = csv.reader(UserReviews, delimiter=';')

	author = []
	moviename = []
	userscore = []

	for line in csv_reader:
		if (line[2]) in authorlist and float(line[1]) > float(avg):
			author.append(line[2])
			moviename.append(str(line[0]))
			userscore.append(line[1])

			print("Author: " + line[2] + ", Movie name: " + str(line[0]) + ", User score: " + str(line[1]))

# Printing only the list of movies and removing duplicates
listofrecommendedmovies = list(dict.fromkeys(moviename))
print("List of only movie titles" +str(listofrecommendedmovies))

# Using the zip function to merge multiple lists together
recommendations = list(zip(author, moviename, userscore))            

with open('RecommendationsBasedOnUserReviews.csv', 'w') as recommendationoutput:
	rec = csv.writer(recommendationoutput, delimiter=';')
	rec.writerow([recommendations])
