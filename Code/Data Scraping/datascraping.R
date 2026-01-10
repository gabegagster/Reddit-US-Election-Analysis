# !!! Relevant code for all following sections =================================

library(RedditExtractoR)
library(dplyr)
library(stringr)
library(RPostgres)
library(DBI)

# Define a vector of related keywords for the US election
keywords <- c("US Election", "Election 2024", "Presidential Election", 
              "Republican", "Democrat",
              "Kamala", "Trump", "Biden", "Vance", "Walz")

narrow_pattern <- paste(keywords, collapse="|")

# Define the keywords for searching and filtering
broad_keywords <- c("Election", "Vote", "President", "Candidate", "Biden", "Trump",
                    "Republican", "Democrat",
                    "Harris", "Kamala", "Vance", "Walz", "Debate", "Policy", 
                    "Government", "Campaign")

# Create a regex pattern for these keywords (case-insensitive)
pattern <- paste(broad_keywords, collapse = "|")

# Define exclusion keywords to filter out non-US political subreddits
exclusion_keywords <- c("Canada", "UK", "Australia", "India", "Europe", 
                        "Brazil", "Germany", "France", "Japan", "Russia", 
                        "Africa", "China", "Mexico", "Spain", "Italy", "Netherlands")

# Create a regex pattern for the exclusion (case-insensitive)
exclusion_pattern <- paste(exclusion_keywords, collapse = "|")

# dbconnect function removed - usage replaced by source("../dbconnect.R")

# Get Posts (and respective comments) about US Election ========================

# Initialize an empty data frame to store all results
all_posts <- data.frame()

# Loop over keywords to retrieve posts for each one
for (keyword in keywords) {
  # Retrieve posts for each keyword and append to the all_urls_df
  posts = find_thread_urls(keywords = keyword, sort_by = "top", period = "month")
  
  # Combine results into one data frame
  all_posts = rbind(all_posts, posts)
}

filtered_posts <- all_posts %>%
  distinct(url, .keep_all = TRUE) %>%  # Remove duplicates based on the title column
  
  # filter based on positive and negative keywords
  filter(str_detect(tolower(title), tolower(pattern)) & 
           !str_detect(tolower(title), tolower(exclusion_pattern))) %>%
  
  arrange(desc(comments))  # Order entries by number of subscribers

# Save the posts to a CSV file
write.csv(filtered_posts, "US_Election_Posts_Month_260924.csv", row.names = FALSE)

# Get subreddits which are relevant to US Election =============================

# Initialize an empty data frame to store all results
all_subreddits <- data.frame()

# Search for subreddits related to US politics
for (keyword in keywords) {
  subreddits <- find_subreddits(keyword)
  
  # Combine results into one data frame
  all_subreddits = rbind(all_subreddits, subreddits)
}

filtered_subreddits <- all_subreddits %>%
  distinct(subreddit, .keep_all = TRUE) %>%  # Remove duplicates based on the subreddit column
  
  # filter based on postive and negative keywords as well as 0 subscribers
  filter(str_detect(tolower(description), tolower(narrow_pattern)) & 
           str_detect(tolower(description), tolower(narrow_pattern)) &  
           !str_detect(tolower(description), tolower(exclusion_pattern)) &
           subscribers > 0) %>%
  
  arrange(desc(subscribers))  # Order entries by number of subscribers

# Save the final dataframe to a CSV file
write.csv(filtered_subreddits, "US_Election_Subreddits_260924.csv", 
          row.names = FALSE)

# Find US election posts based on subreddits ===================================

# Define the subreddits of interest
int_subreddits = head(filtered_subreddits, 10)$subreddit

# Initialize an empty data frame to store the results
posts_by_subreddit <- data.frame()

# Loop through each subreddit
for (subreddit in int_subreddits) {
  
  # Fetch the top posts from the subreddit
  posts <- find_thread_urls(subreddit = subreddit, sort_by = "top", period = "month")
  
  # Add the subreddit name to the data
  posts$subreddit <- subreddit
  
  # Combine the results into the main data frame
  posts_by_subreddit <- rbind(posts_by_subreddit, posts)
}

filtered_posts_by_subreddit <- posts_by_subreddit %>%
  distinct(url, .keep_all = TRUE) %>%  # Remove duplicates based on the url column
  
  # filter based on positive and negative keywords
  filter(str_detect(tolower(title), tolower(pattern)) & 
           !str_detect(tolower(title), tolower(exclusion_pattern))) %>%
  
  arrange(desc(comments))  # Order entries by number of subscribers

# Save the final dataframe to a CSV file
write.csv(filtered_posts_by_subreddit, "US_Election_Posts_By_Subreddits_Month_260924.csv", 
          row.names = FALSE)

# Append username, score, up-ratio, get comments  ==============================

source("../dbconnect.R") # connect to database
dbListTables(con) # list tables in database

# Get relevant table from database
tablename = "posts"
df = dbGetQuery(con, paste('SELECT * FROM "', tablename, '"', sep = ""))

df = head(df,5)

# Initialize columns in dataframe for additional data
df$username = NA
df$score = NA
df$up_ratio = NA

# Initialize an empty DataFrame to store all comments
all_comments <- data.frame()

# Iterate over each post
for (i in 1:nrow(df)) {
  tryCatch({
    content <- get_thread_content(df$url[i])  # Extract content from the Reddit URL
    
    df$username[i] <- content$threads$author
    df$score[i] <- content$threads$score
    df$up_ratio[i] <- content$threads$up_ratio
    
    # Extract comments as a DataFrame
    comments_df <- as.data.frame(content$comments)
    
    # Add a column to associate the comments with the original post URL
    comments_df$post_url <- df$url[i]
    
    # Combine the new comments with the overall comments DataFrame
    all_comments <- bind_rows(all_comments, comments_df)
  
  }, error = function(e) {
    # Handle errors and assign NA if there are issues with the Reddit URL or content extraction
    df$username[i] <- NA
    df$score[i] <- NA 
    df$up_ratio[i] <- NA  
    
    # If there's an error, just skip the comments for this post
  })
}

# Filter existing table in database ============================================

tablename = 'posts_by_users'

data = dbGetQuery(con, paste('SELECT * FROM "', tablename, '"', sep = ""))

filtered_posts <- data %>%
  distinct(url, .keep_all = TRUE) %>%  # Remove duplicates based on the title column
  
  # filter based on positive and negative keywords
  filter(str_detect(tolower(title), tolower(narrow_pattern)) & 
           str_detect(tolower(title), tolower(pattern)) & 
           !str_detect(tolower(title), tolower(exclusion_pattern)))

# Save the final dataframe to a CSV file
write.csv(filtered_posts, "US_election_posts_by_users.csv", row.names = FALSE)

# Save dataframes to database ==================================================

source("../dbconnect.R") # connect to database
dbListTables(con) # list tables in database

tablename = "US_election_posts_by_users"

data = read.csv(paste(tablename, ".csv", sep=""), header = TRUE, sep = ",")

# Write the dataframe to the PostgreSQL table
dbWriteTable(
  con,
  tablename,  # table name
  data,  # dataframe
  overwrite = TRUE,  # overwrite existing table (default is FALSE)
  append = FALSE  # append to existing table (default is FALSE)
)

table = dbGetQuery(con, paste('SELECT * FROM "', tablename, '"', sep = ""))