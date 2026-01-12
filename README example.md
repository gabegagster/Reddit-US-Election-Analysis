# Predicting Injury Severity in Road Accidents
### A Real-Time Classification Approach

## 📖 Overview

This project was developed by students at the **University of Mannheim** as part of the Data Mining I curriculum. The goal is to enhance modern vehicle telematics (such as the European **eCall** system) by integrating a machine learning classifier capable of predicting injury severity immediately after an accident.

Current eCall systems transmit location and passenger count but lack injury severity data: a critical gap for emergency triage. Using historical data from the **French National Interministerial Observatory for Road Safety (ONISR)**, we developed a pipeline to classify accidents into three severity levels: *Uninjured*, *Lightly Injured*, and *Severe (Hospitalized/Dead)* based solely on real-time variables.

**Read the full detailed analysis:** \
[Project Report](https://www.google.com/search?q=https://raw.githubusercontent.com/Humble2782/Data_Mining_I_Project/main/documents/project_report.pdf) \
[Project Presentation](https://www.google.com/search?q=https://raw.githubusercontent.com/Humble2782/Data_Mining_I_Project/main/documents/Project%2520Presentation.pdf)

**View live demo:** \
[eCall Real-Time Prediction Dashboard](https://ecall.gabrielhimmelein.com) (hosted by [@gabegagster](https://github.com/gabegagster))


## 🏗️ Repository Structure

```
├── ETL/               # Modularized pipeline merging yearly tables (characteristics, locations, vehicles, users)
├── dashboard/         # Real-time Streamlit dashboard
├── data/              # Dataset in different preprocessing stages and final training/testing sets
├── documents/         # Project report and presentation
├── exploration/       # Notebooks for EDA and Clustering (K-Prototypes)
├── models/            # Training scripts for CatBoost, Balanced Random Forest, and Ridge
└── .gitignore         # Git ignore configuration
```


## 📊 Dataset & Feature Engineering

We utilized the **ONISR "Bulletins d’Analyse des Accidents Corporels" (BAAC)** dataset (2019-2023), processing over **600,000 records**. The final unit of analysis is the *individual user*.


### Key Engineering Challenges

To convert raw database dumps into a model-ready format, we implemented complex preprocessing logic:



* **Vehicle Antagonist Resolution:** In multi-vehicle accidents, we developed an algorithm to identify the specific "opposing" vehicle (antagonist) that caused the injury, calculating an impact_delta based on the mass difference between vehicles (e.g., bicycle vs. heavy goods vehicle).
* **Location Deduplication:** Implemented a completeness_score to resolve duplicate location entries, prioritizing records with rich metadata (road category, speed limit).
* **Road Complexity Index:** A composite score (0-10) aggregating intersection type, lane count, and traffic regime to quantify environmental risk.
* **Cyclical Time Features:** sine/cosine transformations for hours and months to capture temporal patterns.


## 🚀 Methodology

The project follows the CRISP-DM lifecycle, focusing on handling the significant class imbalance (only 16% severe injuries).


### 1. Clustering (Accident Personas)

We used **K-Prototypes** (handling mixed categorical/numerical data) to identify 5 distinct accident personas, such as:



* *Cluster 1:* Night-time accidents involving young adults (18-30) in low visibility.
* *Cluster 3:* High-complexity urban intersection accidents.


### 2. Classification Models

We evaluated three distinct architectures against a speed-limit baseline:



1. **Ridge Classifier (RC):** A linear baseline with L2 regularization and random undersampling.
2. **Balanced Random Forest (BRF):** An ensemble method that undersamples the majority class during bootstrapping.
3. **CatBoost (CB):** A gradient boosting algorithm chosen for its native handling of high-cardinality categorical features.


## 🏆 Results

**CatBoost** was selected as the optimal model, achieving the highest F1-Macro score and Cohen's Kappa.


<table>
  <tr>
   <td><strong>Model</strong>
   </td>
   <td><strong>Precision (Severe)</strong>
   </td>
   <td><strong>Recall (Severe)</strong>
   </td>
   <td><strong>F1-Macro</strong>
   </td>
  </tr>
  <tr>
   <td><strong>CatBoost</strong>
   </td>
   <td><strong>0.46</strong>
   </td>
   <td><strong>0.73</strong>
   </td>
   <td><strong>0.66</strong>
   </td>
  </tr>
  <tr>
   <td>Balanced RF
   </td>
   <td>0.47
   </td>
   <td>0.70
   </td>
   <td>0.66
   </td>
  </tr>
  <tr>
   <td>Ridge Classifier
   </td>
   <td>0.40
   </td>
   <td>0.77
   </td>
   <td>0.61
   </td>
  </tr>
  <tr>
   <td>Baseline
   </td>
   <td>0.16
   </td>
   <td>0.08
   </td>
   <td>0.33
   </td>
  </tr>
</table>




* **Critical Success:** The system successfully identifies **~96% of severe cases** as at least injured, meeting the primary safety objective of not missing critical cases.
* **Key Predictors:** The most important features identified were _mobile_obstacle_struck_, _impact_delta_, and _type_of_collision_.


## 🛠️ Getting Started


### Prerequisites



* Python 3.8+
* pip


### Installation & Usage

This project is built to run as a **dashboard application**.

**Clone the repository:**
```
git clone https://github.com/Humble2782/Data_Mining_I_Project
```

**Install the dependencies:**\
Navigate to the dashboard folder and run the application. Dependencies should be installed from this directory.
```
cd Data_Mining_I_Project/dashboard
pip install -r requirements.txt
```

**Run the application:**
```
streamlit run app.py
```


## 👥 Authors

| Team Member | Role | Responsibilities |
| :--- | :--- | :--- |
| **[Gabriel Himmelein](https://gabrielhimmelein.com/)** | **Technical Lead** | • Preprocessing pipeline architecture<br>• Deployment & Streamlit dashboard<br>• System integration |
| **[David Cebulla](https://github.com/Humble2782)** | **ML Engineer** | • Data integration (merging)<br>• Model training |
| **[Lukas Ott](https://github.com/lukasmichaelott)** | **Data Engineer** | • Handling missing data (imputation)<br>• Clustering analysis |
| **[Aaron Niemesch](https://github.com/AroNiem)** | **ML Engineer** | • Model training<br>• Project reporting & documentation |
| **[Artur Loreit](https://github.com/ALoreit)** | **Data Analyst** | • Use case definition<br>• Exploratory Data Analysis (EDA)<br>• Project presentation |

*Submitted to the **Data and Web Science Group** at the University of Mannheim.*


## 📄 License

This project is licensed under the MIT License.
