# Reddit US Election Analysis

A data analysis project examining Reddit posts related to the US Election.

## Description

This project analyzes user activity and content on Reddit during the US Election period 2024, utilizing clustering and network analysis techniques to understand community structures and topic prevalence.

## Main Findings

- **Hypothesis Testing**: Analysis confirmed a significant relationship between electoral timelines and user engagement, with notable spikes in activity around major events like legal developments involving Donald Trump.
- **Cluster Analysis**: Recent discussions (past month) showed a narrowing of topics, heavily dominated by prominent figures like Donald Trump, whereas historical data (past year) exhibited a broader thematic diversity.
- **Network Analysis**: The study identified distinct communities within the political discourse. While some groups operate as isolated "bubbles," others show significant cross-community interaction, with key influential users acting as connectors between them.
- **Data Insight**: The dataset captures both short-term and long-term trends from prominent US-focused subreddits, though it reflects the specific demographic and moderation biases inherent to Reddit.
- **Observation on Share of Voice**: Despite Reddit's historically left-leaning user base, Cluster Analysis revealed that opposition figures (e.g., Donald Trump) dominated the thematic landscape. This suggests that total engagement and 'share of voice', regardless of sentiment, may be a stronger signal of candidate prominence than platform alignment.

## Code Overview

- **Code/Data Scraping**: Scripts to scrape data from Reddit and store it in a PostgreSQL database.
- **Code/Cluster Analysis**: K-means clustering of posts to identify common themes and topics.
- **Code/Network Analysis**: Construction and analysis of user interaction networks.
- **Code/Hypothesis Testing**: Statistical tests to valid hypothesis about online activity trends.
- **Code/dbconnect.R**: Central configuration for database connection.

## Project Presentation

[Watch the Project Presentation](LINK_TO_YOUTUBE_VIDEO)

## Authors

- **Luke Dickson**
- **Tom Finke**
- **Gabriel Himmelein**
- **Margarette Mendozza**
