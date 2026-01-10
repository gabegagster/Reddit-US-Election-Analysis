# !!! Relevant code for all following sections =================================

library(RedditExtractoR)
library(dplyr)
library(stringr)
library("RPostgres")
library(DBI)

# dbconnect logic replaced
source("../dbconnect.R") # connect to database

users_table_name = "user_posts" # table with all relevant usernames

# Name of table with posts by users in database
tablename = "posts_by_users"

# Add data for first username in table =========================================

# fetch relevent usernames and pick one
data = dbGetQuery(con, paste('SELECT * FROM "', users_table_name, '"', sep = ""))
content = get_user_content(data[2,]$username)

# Extract posts as a DataFrame
posts_df <- as.data.frame(content[[1]]$threads)

# # Write the table to database
# tryCatch({
#   dbWriteTable(
#     con,
#     tablename,
#     posts_df,
#     overwrite = FALSE # must be set to TRUE for first posts in table
#   )
# }, 
# error = function(e) {
#   print(e)
# })

# Show progress of writing data ================================================

# Get number of usernames for which posts have been fetched
number_written = dbGetQuery(con, paste('SELECT COUNT(DISTINCT(author)) FROM "', tablename, '"', sep = ""))
number_written = as.integer(number_written[1,1])

# Get usernames for which posts have not been fetched yet
remaining_usernames = dbGetQuery(con, 
                                 paste('SELECT u.username FROM "', users_table_name, 
                                       '" u left outer join "', tablename, 
                                       '" p on u.username = p.author where p.url is null', 
                                       sep = ""))
number_remaining = length(unique(remaining_usernames$username))

# Get number of posts fetched
number_posts = dbGetQuery(con, paste('SELECT count(*) FROM', tablename))
number_posts = as.integer(number_posts[1,1])

cat("# usernames in database:", number_written, "\n", 
    "Remaining # of usernames:", 
    number_remaining, '\n',
    "% complete:", number_written/(number_written + number_remaining) * 100, "\n",
    "# posts fetched:", number_posts, '\n')

# Add remaining user posts in table ============================================

# Get usernames for which posts have not been specifically fetched yet
remaining_usernames = dbGetQuery(con, 
                                 paste('SELECT u.username FROM "', users_table_name, 
                                       '" u left outer join "', tablename, 
                                       '" p on u.username = p.author where p.url is null', 
                                       sep = ""))
remaining_usernames = unique(remaining_usernames$username)

for (i in 1:length(remaining_usernames)) {
  tryCatch({
    content <- get_user_content(remaining_usernames[i])  # Extract content from the Reddit URL

    # Extract posts as a DataFrame
    posts <- as.data.frame(content[[1]]$threads)

    # Write the new posts in database
    dbWriteTable(
      con,
      tablename,  # name of table in database
      posts, # posts to be appended
      overwrite = FALSE,
      append = TRUE
    )
    cat("Posts have been written for user", remaining_usernames[i], "\n")
  },
  error = function(e) {
    print(e)
  })
}
