<img width="1180" height="660" alt="image" src="https://github.com/user-attachments/assets/072afa74-e75f-4cda-94f5-869446a17d2c" /># End-End-Fintech-Incentive-Optimization-Analysis
Overview

This project analyzes a fintech platform's incentive programs — specifically cashback and referral rewards — to evaluate their impact on platform profitability, user activity, and transaction success rates.

The goal is to determine whether incentive programs actually generate value for the business or simply increase operational costs.

The project demonstrates a complete data workflow from data generation to business intelligence visualization.

Project Pipeline

The project follows a structured data workflow:

Python → Excel → SQL → Power BI
1. Data Generation (Python)

Synthetic fintech data was generated using Python to simulate a real payment platform.

The dataset includes:

Users

Transactions

Referral programs

Cashback incentives

Python was used to simulate:

Transaction success and failure patterns

Referral-based user acquisition

Monthly cashback rewards

Multiple payment methods (UPI / Card)

This creates a realistic dataset for business analysis.

2. Data Cleaning (Excel)

The raw dataset was cleaned and structured in Excel.

Key steps included:

Removing inconsistencies

Standardizing column formats

Handling missing values

Validating transaction records

Excel was used as an intermediate layer to ensure clean structured data before database processing.

3. Data Modeling & Business Logic (SQL)

SQL was used to transform the dataset and apply business logic.

Key transformations included:

Calculating monthly cashback payouts

Aggregating transaction statistics

Computing transaction success rates

Deriving referral bonus distributions

Preparing structured tables for analytics

Final SQL tables used for analysis:

users
transactions
referral_rewards
final_monthly_cashback
4. Data Visualization (Power BI)

Power BI was used to build an interactive dashboard that analyzes the impact of incentives on business performance.

Key techniques used:

Data modeling

DAX measures

KPI calculations

Time-based analysis

Relationship modeling

Key Metrics

The dashboard calculates important business metrics:

Total Revenue

Total Incentive Cost

Net Profit

Profit Margin

Transaction Success Rate

Referral Performance

User Acquisition via Referral

Dashboard Structure
Page 1 — Business Performance Overview

Provides a high-level view of platform performance.

Visuals include:

Revenue vs Incentive Cost trend

Transaction success vs failure analysis

Revenue by payment method

Incentive cost breakdown

Profit margin trend

Page 2 — Incentive Optimization Analysis

Evaluates the effectiveness of cashback and referral programs.

Insights include:

Referral effectiveness

Incentive distribution analysis

Relationship between incentives and revenue

Cost structure of incentive programs

Page 3 — Executive Summary

High-level KPIs designed for quick business decision making.

Metrics include:

Total Revenue

Total Incentive Cost

Net Profit

Transaction Success Rate

Total Transactions

Key Insight

Despite a high transaction success rate (~90%), the current incentive strategy leads to negative net profit, indicating that cashback and referral rewards are not optimized.

This highlights the importance of balancing user incentives with sustainable revenue models.

Tools Used
Python
Excel
SQL
Power BI
GitHub
Project Structure
Fintech-Incentive-Optimization-Dashboard
│
├── dashboard
│   └── Incentive_Optimization.pbix
│
├── dataset
│   └── fintech_dataset.csv
│
├── screenshots
│   ├──<img width="1251" height="703" alt="image" src="https://github.com/user-attachments/assets/851d3fee-5cec-4612-86f3-18a77f11047e" />
│   ├── <img width="1250" height="699" alt="image" src="https://github.com/user-attachments/assets/be2b4d0f-47f4-4aa7-b039-d88a8819a583" />
│   └── <img width="1251" height="702" alt="image" src="https://github.com/user-attachments/assets/91a627d5-990d-4b5c-91f9-e65e02acd6e5" />

│
└── README.md
Dashboard Preview

Author

Suraj Thakur
Computer Science Student | Data Analytics Enthusiast
