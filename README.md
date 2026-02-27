# Online_Food_Delivery_App_Project
Analyzing data of food delivery app using MySQL and integrating AI to automate tasks

Online Food Delivery Data Analytics Project Report

1. Introduction
This project analyzes operational and business data from an online food delivery platform using
MySQL. It focuses on revenue analytics, customer behavior, restaurant performance, delivery
efficiency, automation, and database optimization.

3. Problem Statement
Food delivery platforms generate large volumes of data. Without structured analysis, businesses
cannot identify high-value customers, optimize restaurant performance, monitor delays, or control
revenue leakage due to discounts.

5. Business Objectives
- Calculate total revenue and monthly revenue
- Identify top customers and segment them
- Rank restaurants by performance
- Monitor delivery efficiency
- Analyze discount and payment impact
- Automate business rules using triggers
  
4. Dataset Overview
The database contains the following tables:
- Restaurants
- Customers
- Orders
- Order Items
- Delivery Agents
  
Key attributes include order_amount, discount, order_date, delivery_time, rating, and payment_method.

5. Exploratory Data Analysis (EDA)
EDA included total revenue calculation, total orders per city, and top 10 customers by spending.
These metrics provide a foundation for deeper business insights.

7. Customer Segmentation
Customers were categorized as:
- Gold (Spending ≥ 1000)
- Silver (Spending ≥ 500)
- Bronze (Below 500)
This helps design targeted loyalty programs.

7. Restaurant Performance Analysis
Restaurants were ranked by total revenue using window functions. Revenue and average rating
were analyzed to evaluate performance quality.

9. Delivery Performance Analysis
Average delivery time per city was calculated. Orders exceeding 45 minutes were logged to monitor service delays.

11. Views
A reusable revenue view was created to simplify reporting and ensure consistent calculations.

13. Stored Procedures
A stored procedure was developed to dynamically retrieve Top N restaurants by revenue.

15. Indexing Strategy
Indexes were created on order_date, customer name, and restaurant name to improve query performance.

17. Triggers Implementation
- Log high value orders (>1000)
- Prevent negative discounts
- Log delivery delays (>45 mins)
These automate data validation and monitoring.

13. Dashboard & Visualization
Suggested dashboards include revenue trends, customer segmentation charts, restaurant ranking
charts, and delivery performance KPIs.

15. Business Insights & Recommendations
- Gold customers contribute major revenue
- Few restaurants generate majority revenue (Pareto effect)
- Late deliveries impact satisfaction
- Discounts reduce profit margins
Recommendations:
- Launch loyalty programs
- Optimize delivery routing
- Control discount policies
- Promote high-rated restaurants
  
15. Conclusion
The project demonstrates advanced SQL analytics, automation, optimization, and business
intelligence for an online food delivery system.

17. Future Enhancements
- Predict delivery delays using ML
- Customer churn prediction
- Real-time dashboards
- Dynamic pricing strategies
