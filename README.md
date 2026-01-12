# Reddit US Election Analysis
### A Network and Content Analysis Approach

## 📖 Overview

This project analyzes user activity and content on Reddit during the US Election period 2024. Utilizing clustering and network analysis techniques, we aim to understand community structures, topic prevalence, and user engagement patterns within political discourse.

**View the full documentation:** \
[Project Report](Documentation/Documentation.pdf)

## 🏗️ Repository Structure

```
├── Code/              # Scripts for scraping, clustering, network analysis, and hypothesis testing
├── Datasets/          # Local CSV datasets (posts, users, subreddits) for reproducible analysis
├── Documentation/     # RMarkdown source and generated PDF report
├── requirements.txt   # R package dependencies
└── README.md          # Project documentation
```

## 📊 Dataset & Features

The dataset is derived from prominent US-focused subreddits and posts, capturing both short-term (past month) and long-term (past year) trends. It includes metadata, user activity, and engagement metrics to facilitate a nuanced investigation into online political conversations.

## 🚀 Methodology

The project employs a multi-faceted approach to analyze the data:

### 1. Hypothesis Testing
Statistical tests to validate hypotheses about the relationship between electoral timelines and user engagement spikes.

### 2. Cluster Analysis (K-Means)
Identifying common themes and topics by clustering posts. We compared recent discussions (past month) which showed a narrowing of topics, versus historical data (past year) which exhibited broader diversity.

### 3. Network Analysis
Constructing user interaction networks to identify distinct communities. The study found that while some groups operate as isolated "bubbles," others show significant cross-community interaction facilitated by influential connector users.

## 🏆 Results

*   **Hypothesis Testing**: Analysis confirmed a significant relationship between electoral timelines and user engagement, with notable spikes in activity around major events like legal developments involving Donald Trump.
*   **Cluster Analysis**: Recent discussions (past month) showed a narrowing of topics, heavily dominated by prominent figures like Donald Trump, whereas historical data (past year) exhibited a broader thematic diversity.
*   **Network Analysis**: The study identified distinct communities within the political discourse. While some groups operate as isolated "bubbles," others show significant cross-community interaction, with key influential users acting as connectors between them.
*   **Data Insight**: The dataset captures both short-term and long-term trends from prominent US-focused subreddits, though it reflects the specific demographic and moderation biases inherent to Reddit.
*   **Observation on Share of Voice**: Despite Reddit's historically left-leaning user base, Cluster Analysis revealed that opposition figures (e.g., Donald Trump) dominated the thematic landscape. This suggests that total engagement and 'share of voice', regardless of sentiment, may be a stronger signal of candidate prominence than platform alignment.

## 🛠️ Getting Started

### Prerequisites

To regenerate the documentation locally, you need **R** installed.

### Installation

The project dependencies are listed in `requirements.txt`. Install them by running the following in your R console:

```r
install.packages(readLines("requirements.txt"))
```

### Running the Analysis

The project has been configured to use the local datasets provided in the `Datasets/` directory, ensuring reproducibility without requiring access to the original PostgreSQL database.

**Note**: The `Documentation/Documentation.rmd` file is self-contained and includes all necessary code for analysis and plotting. It operates independently of the scripts located in the `Code/` directory.

To generate the PDF report:

```bash
Rscript -e "rmarkdown::render('Documentation/Documentation.rmd')"
```

## 👥 Authors

| Team Member | Role | Responsibilities |
| :--- | :--- | :--- |
| **Gabriel Himmelein** | **Data Engineer** | • Data scraping and preprocessing |
| **Tom Finke** | **Network Analyst** | • Database provision<br>• Network analysis |
| **Luke Dickson** | **Data Analyst** | • Hypothesis testing |
| **Margarette Mendoza** | **Data Analyst** | • Cluster analysis |

## 📄 License

This project is licensed under the MIT License.
