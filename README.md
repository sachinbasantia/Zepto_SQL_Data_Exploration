# 🛒 Zepto Quick Commerce SQL Data Exploration 

## 📌 Project Overview
This project is a comprehensive SQL data exploration of real-world e-commerce inventory data from Zepto (a quick-commerce platform). The objective of this project is to clean, transform, and analyze product stock, pricing, and discount strategies to uncover actionable business insights.

*Note: This project was inspired by [Amlan Mohanty's Data Analyst Portfolio Project](https://www.youtube.com/watch?v=x8dfQkKTyP0), but significantly upgraded to handle realistic dirty data scenarios, including advanced null-value imputation and statistical categorization methods not covered in the original tutorial.*

## 🛠️ Tech Stack
* **Database:** PostgreSQL
* **Query Language:** SQL (DML, DDL, Aggregate Functions, Subqueries, Window Functions)
* **Dataset:** Zepto Product Listings (Scraped from Kaggle)

## 🚀 Key Improvements & Unique Features
While the base dataset was standard, my exploration features advanced handling of real-world data anomalies:
1. **Dynamic Null Value Handling:** * Instead of dropping rows with missing pricing metrics, I used mathematical formulas within SQL `COALESCE` statements to back-calculate missing MRPs, Selling Prices, or Discount Percentages.
   * For missing weights and available quantities, I used correlated subqueries to impute the nulls with the **average value of their specific product category**.
2. **Statistical Weight Categorization:** * Rather than hard-coding static boundaries (e.g., < 1000g) to group products into "Low", "Medium", and "Bulk" packages, I utilized statistical measures to dynamically segment the products based on the data distribution.

## 📊 Business Insights Uncovered
* **Revenue Opportunities:** Identified high-ticket premium items (MRP > ₹300) currently out of stock, representing immediate restock priorities to prevent revenue leakage.
* **Discount Strategies:** Found that "Fruits & Vegetables" have the highest average discount (15%), while premium household items rely on strong brand pull with <10% discounts.
* **Warehouse Logistics:** Calculated the total physical weight of available inventory per category to assist in dark-store space allocation and delivery planning.
* **Value Analytics:** Engineered a `price_per_gram` metric to identify the highest value-for-money products for consumers.

## 📁 Repository Structure
* `zepto_data_cleaning.sql`: Queries used to fix null values, correct pricing units (paise to rupees), and clean the raw data.
* `zepto_business_analysis.sql`: Queries answering the core business and revenue questions.
* `Project_Documentation.md`: A step-by-step walkthrough of the queries with output screenshots.

## ⚙️ How to Run
1. Download the Zepto CSV dataset (ensure it is saved with UTF-8 Encoding).
2. Set up a PostgreSQL database and execute the `CREATE TABLE` script.
3. Import the CSV.
4. Run the scripts in the `sql/` folder sequentially (Cleaning first, Analysis second).
