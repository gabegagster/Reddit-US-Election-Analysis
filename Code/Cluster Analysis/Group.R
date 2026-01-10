#Group Project 
# Load necessary libraries
# install.packages("tm")  # Text Mining
# install.packages("RPostgres")  # PostgreSQL Database
# install.packages("DBI")  # Database Interface
# install.packages("wordcloud")  # For creating word clouds
# install.packages("RColorBrewer")  # For color palettes
# install.packages("cluster")  # For clustering

library(tm)  # For Corpus, TermDocumentMatrix
library(RPostgres)  # PostgreSQL Database Connectivity
library(DBI)  # Database Interface
library(Matrix)  # For matrix operations, if needed
library(wordcloud)  # For creating word clouds
library(RColorBrewer)  # For color palettes
library(cluster)  # For clustering

# Database connection setup
source("../dbconnect.R")
# con is now available from dbconnect.R

# Fetch data from database
tablename_year <- "US_Election_Posts_Year_260924"
tablename_month <- "US_Election_Posts_Month_260924"

data_year <- dbGetQuery(con, paste('SELECT * FROM "', tablename_year, '"', sep = ""))
data_month <- dbGetQuery(con, paste('SELECT * FROM "', tablename_month, '"', sep = ""))

# Ensure text data is not empty
if (is.null(data_year$text) | is.null(data_month$text)) {
  stop("Text data is missing in one of the datasets.")
}

# Text preprocessing function
preprocess_text <- function(text_data) {
  corpus <- Corpus(VectorSource(text_data))
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removeWords, stopwords("en"))
  corpus <- tm_map(corpus, stripWhitespace)
  
  # Create Term Document Matrix
  tdm <- TermDocumentMatrix(corpus)
  dtm <- as.matrix(tdm)  # Convert to matrix
  return(dtm)
}

# Preprocess year data
tdm_year <- preprocess_text(data_year$text)
cat("Year DTM Dimensions:", dim(tdm_year), "\n")

# Preprocess month data
tdm_month <- preprocess_text(data_month$text)
cat("Month DTM Dimensions:", dim(tdm_month), "\n")

# Check for NA values in DTM
if (any(is.na(tdm_year))) {
  stop("There are NA values in the year DTM.")
}
if (any(is.na(tdm_month))) {
  stop("There are NA values in the month DTM.")
}

# Remove empty rows and columns for year DTM
tdm_year <- tdm_year[rowSums(tdm_year) > 0, colSums(tdm_year) > 0]

# Remove empty rows and columns for month DTM
tdm_month <- tdm_month[rowSums(tdm_month) > 0, colSums(tdm_month) > 0]

# Normalize DTM for clustering
norm_tdm_year <- scale(tdm_year)
norm_tdm_month <- scale(tdm_month)

# Check for NA values after normalization
if (any(is.na(norm_tdm_year))) {
  stop("There are NA values in the normalized year DTM.")
}
if (any(is.na(norm_tdm_month))) {
  stop("There are NA values in the normalized month DTM.")
}

# Create K-means clustering
set.seed(1)
k_year <- 9  # Number of clusters for year data
k_month <- 6 # Number of clusters for month data

# Perform k-means clustering
kmeans_year <- kmeans(norm_tdm_year, centers = k_year, nstart = 50)
kmeans_month <- kmeans(norm_tdm_month, centers = k_month, nstart = 50)

# Print clustering results
cat("K-means Clustering Results for Year Data:\n")
print(table(kmeans_year$cluster))
cat("K-means Clustering Results for Month Data:\n")
print(table(kmeans_month$cluster))

# Create word clouds for year and month data
library(RColorBrewer)

# Word cloud for year data
freqsw_year <- rowSums(tdm_year)
wordcloud(names(freqsw_year),
          freqsw_year,
          random.order = FALSE,
          max.words = 45,
          colors = brewer.pal(8, "Dark2"),
          main = "Word Cloud for Year Data")

# Word cloud for month data
freqsw_month <- rowSums(tdm_month)
wordcloud(names(freqsw_month),
          freqsw_month,
          random.order = FALSE,
          max.words = 45,
          colors = brewer.pal(8, "Dark2"),
          main = "Word Cloud for Month Data")


# Preprocess year data
tdm_year <- preprocess_text(data_year$text)
cat("Year DTM Dimensions:", dim(tdm_year), "\n")

# Preprocess month data
tdm_month <- preprocess_text(data_month$text)
cat("Month DTM Dimensions:", dim(tdm_month), "\n")

# Remove empty rows and columns for year DTM
tdm_year <- tdm_year[rowSums(tdm_year) > 0, colSums(tdm_year) > 0]

# Remove empty rows and columns for month DTM
tdm_month <- tdm_month[rowSums(tdm_month) > 0, colSums(tdm_month) > 0]

# Normalize DTM for clustering
norm_tdm_year <- scale(tdm_year)
norm_tdm_month <- scale(tdm_month)

# Check for NA values after normalization
if (any(is.na(norm_tdm_year))) {
  stop("There are NA values in the normalized year DTM.")
}
if (any(is.na(norm_tdm_month))) {
  stop("There are NA values in the normalized month DTM.")
}

# maximum number of clusters
max_clusters <- 15

# Create empty vectors to store SSW and SSB values
SSW_year <- rep(0, max_clusters)
SSB_year <- rep(0, max_clusters)
SSW_month <- rep(0, max_clusters)
SSB_month <- rep(0, max_clusters)


# Compute SSW and SSB for Year Data
for (k in 1:max_clusters) {
  set.seed(1)  # For reproducibility
  kmeans_year <- kmeans(norm_tdm_year, centers = k, nstart = 50)
  
  # Store within-cluster sum of squares
  SSW_year[k] <- kmeans_year$tot.withinss
  
  # Store between-cluster sum of squares
  SSB_year[k] <- kmeans_year$betweenss
}

# Compute SSW and SSB for Month Data
for (k in 1:max_clusters) {
  set.seed(1)  # For reproducibility
  kmeans_month <- kmeans(norm_tdm_month, centers = k, nstart = 50)
  
  # Store within-cluster sum of squares
  SSW_month[k] <- kmeans_month$tot.withinss
  
  # Store between-cluster sum of squares
  SSB_month[k] <- kmeans_month$betweenss
}

# Plot the results for Year Data (Elbow Method)
plot(1:max_clusters, SSW_year, type = 'b', col = 'darkgreen',
     xlab = 'Number of Clusters', ylab = 'Within-Cluster Sum of Squares (SSW)',
     main = 'SSW for Year Data')

# Plot the results for Month Data (Elbow Method)
plot(1:max_clusters, SSW_month, type = 'b', col = 'blue',
     xlab = 'Number of Clusters', ylab = 'Within-Cluster Sum of Squares (SSW)',
     main = 'SSW for Month Data')

#=================================

# Install and load necessary packages
install.packages("ggplot2")
install.packages("MASS")  # For MDS
library(ggplot2)
library(MASS)  # For MDS

# Apply MDS to reduce the dimensionality of the normalized year TDM
set.seed(1)  # For reproducibility
mds_year <- cmdscale(dist(norm_tdm_year), k = 2)  # Reduce to 2 dimensions

# Apply MDS to reduce the dimensionality of the normalized month TDM
mds_month <- cmdscale(dist(norm_tdm_month), k = 2)  # Reduce to 2 dimensions


# Create data frame for year data with MDS results and cluster labels
df_year <- data.frame(
  x = mds_year[,1],
  y = mds_year[,2],
  cluster = factor(kmeans_year$cluster)
)

# Create data frame for month data with MDS results and cluster labels
df_month <- data.frame(
  x = mds_month[,1],
  y = mds_month[,2],
  cluster = factor(kmeans_month$cluster)
)

# Base R visualization for Year Data
plot(mds_year, col = kmeans_year$cluster, pch = 16, 
     xlab = "MDS Dimension 1", ylab = "MDS Dimension 2", 
     main = "K-means Clustering of Year Data in 2D")
points(kmeans_year$centers, col = 1:k_year, pch = 3, cex = 2, lwd = 2)  # Add cluster centers

# Base R visualization for Month Data
plot(mds_month, col = kmeans_month$cluster, pch = 16, 
     xlab = "MDS Dimension 1", ylab = "MDS Dimension 2", 
     main = "K-means Clustering of Month Data in 2D")
points(kmeans_month$centers, col = 1:k_month, pch = 3, cex = 2, lwd = 2)  # Add cluster centers


#===============================
