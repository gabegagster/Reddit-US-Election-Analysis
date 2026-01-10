# Code to connect to database and fetch data ===================================

# TODO: uncomment to install relevant packages
# install.packages('RPostgres')
# install.packages(DBI)

library("RPostgres")
library(DBI)

username = "YOUR_USERNAME_HERE" # TODO: enter username to connect to database

pw = {
  "YOUR_PASSWORD_HERE"
} # TODO: enter password to connect to database (collabse to hide)

# creates a connection to the postgres database
# Use environment variables for configuration or default to localhost
db_host = Sys.getenv("DB_HOST", "localhost")
db_port = Sys.getenv("DB_PORT", "5432")
db_name = Sys.getenv("DB_NAME", "redditdata")

con = DBI::dbConnect(RPostgres::Postgres(), dbname = db_name, 
                     host = db_host, port = db_port, user = username, 
                     password = pw)

rm(pw) # removes the password

if(!is.null(con)){
  dbListTables(con) # lists tables in database
}

# List of relevant tables:
# (you may need to replace the date for the most up to date version) 
#
# - "US_Election_Subreddits_260924": 
#    all relevant subreddits for US politics
#
# - "US_Election_Posts_By_Subreddits_Year_260924": 
#    includes posts about US politics from the 10 largest subreddits 
#    by subscribers as defined in the table before for the last year
#
# - "US_Election_Posts_Month_260924": 
#    includes posts about US politics for the past month
#    (no specification of subreddits)
#
# - "user_posts": 
#    includes additional information like the number of comments,
#    the username and the score, for posts in tables in which information
#    is missing (create join based on URL-column)
#
# - "posts_by_users": 
#    includes posts from politically active users on Reddit
#    but contains non-political posts as well
#    (includes posts from all time)
#
# - "US_election_posts_by_users": 
#    includes posts from politically active users on Reddit;
#    only contains US political posts
#    (includes posts from all time)

# TODO: enter relevant table name to be fetched
tablename = "US_Election_Subreddits_260924"

# fetch relevant table
# data = dbGetQuery(con, paste('SELECT * FROM "', tablename, '"', sep = ""))