# this is an idempotent script used to add usernames data to reddit threads that are already in the database

# data is added to seperate table
# foreign key is thread url


library(RedditExtractoR)
library(dplyr)
library(stringr)
library("RPostgres")
library(DBI)

# Database connection handled by dbconnect.R
source("../dbconnect.R") # connect to database


# user_table_name = "users" # user info with username and score. Need this later if we want to add additional info to a user (karm etc)

user_posts_table_name = "user_posts" # which user authored which post


# Get all threads where the user is yet unknown
posts_table_name = "US_Election_Posts_By_Subreddits_Year_260924"
df = dbGetQuery(con, paste('SELECT p.url FROM "', posts_table_name, '" p left outer join "', user_posts_table_name, '" u on p.url = u.url where u.username is null', sep = ""))


# Initialize columns in dataframe for additional data
df$username = NA
df$score = NA
df$up_ratio = NA
# when the script is interrupted, we dont want to loose all data we fetched
# but we also dont want to connect to the db for every thread
# write data to DB after every x fetches
data_write_interval = 1

# Iterate over each post
last_i_written = 0
for (i in 1:nrow(df)) {
    tryCatch({
      content <- get_thread_content(df$url[i])  # Extract content from the Reddit URL 
    }, 
      error = function(e) {
        print(e)
      }
    )
    df$username[i] <- content$threads$author
    df$score[i] <- content$threads$score
    df$up_ratio[i] <- content$threads$up_ratio
    if(i %% data_write_interval == 0 | i == nrow(df)){
      print(paste(last_i_written, i, nrow(df), df$username[i], sep=" "))
      data_to_write = df[i,]# df[last_i_written+1:i, ]
      print(data_to_write)
      data_to_write = data_to_write[(!is.null(data_to_write$username)), ]
      print(data_to_write)
      tryCatch({
        dbWriteTable(
          con,
          user_posts_table_name,  # table name
          data_to_write,
          overwrite = FALSE,  # overwrite existing table (default is FALSE)
          append = TRUE  # append to existing table (default is FALSE)
        )
        last_i_written = i
      }, 
      error = function(e) {
        print(e)
      })
    }
}

