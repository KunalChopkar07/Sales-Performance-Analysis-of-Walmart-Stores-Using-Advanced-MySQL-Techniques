--  Task 1: Identifying the Top Branch by Sales Growth Rate (6 Marks)
--  Walmart wants to identify which branch has exhibited the highest sales growth over time. Analyze the total sales
--  for each branch and compare the growth rate across months to find the top performer.

select branch, 
       date_format(str_to_date(date, '%d-%m-%Y'), '%Y-%m') as month,
       sum(total) as total_sales,
       (sum(total) - lag(sum(total)) over (partition by branch order by date_format(str_to_date(date, '%d-%m-%Y'), '%Y-%m'))) / lag(sum(total)) over (partition by branch order by date_format(str_to_date(date, '%d-%m-%Y'), '%Y-%m')) as growth_rate
from walmartsales_dataset
group by branch, month
order by growth_rate desc
limit 1;

--  Task 2: Finding the Most Profitable Product Line for Each Branch (6 Marks)
--  Walmart needs to determine which product line contributes the highest profit to each branch.The profit margin
--  should be calculated based on the difference between the gross income and cost of goods sold.

select branch, 
       product_line, 
       sum(gross_income - cogs) as total_profit
from walmartsales_dataset
group by branch, product_line
order by branch, total_profit desc;

--  Task 3: Analyzing Customer Segmentation Based on Spending (6 Marks)
--  Walmart wants to segment customers based on their average spending behavior. Classify customers into three
--  tiers: High, Medium, and Low spenders based on their total purchase amounts.

select customer_id,
       sum(total) as total_spending,
       case 
           when sum(total) >= 1000 then 'High Spender'
           when sum(total) between 500 and 999 then 'Medium Spender'
           else 'Low Spender'
       end as spending_tier
from walmartsales_dataset
group by customer_id;

--  Task 4: Detecting Anomalies in Sales Transactions (6 Marks)
-- Walmart suspects that some transactions have unusually high or low sales compared to the average for the
--  product line. Identify these anomalies.

with product_stats as (
    select product_line, 
           avg(total) as avg_sales,
           stddev(total) as stddev_sales
    from walmartsales_dataset
    group by product_line
)
select t.*, 
       ps.avg_sales, 
       ps.stddev_sales
from walmartsales_dataset t
join product_stats ps on t.product_line = ps.product_line
where abs(t.total - ps.avg_sales) > 2 * ps.stddev_sales;

--  Task 5: Most Popular Payment Method by City (6 Marks)
--  Walmart needs to determine the most popular payment method in each city to tailor marketing strategies.

select city, 
       payment as payment_method, 
       count(*) as method_count
from walmartsales_dataset
group by city, payment
order by city, method_count desc;

--  Task 6: Monthly Sales Distribution by Gender (6 Marks)
--  Walmart wants to understand the sales distribution between male and female customers on a monthly basis.

select date_format(str_to_date(date, '%d-%m-%Y'), '%Y-%m') as month,
       gender,
       sum(total) as total_sales
from walmartsales_dataset
group by month, gender
order by month;

--  Task 7: Best Product Line by Customer Type (6 Marks)
--  Walmart wants to know which product lines are preferred by different customer types(Member vs. Normal).

select customer_type, 
       product_line, 
       sum(total) as total_sales
from walmartsales_dataset
group by customer_type, product_line
order by customer_type, total_sales desc;

--  Task 8: Identifying Repeat Customers (6 Marks)
--  Walmart needs to identify customers who made repeat purchases within a specific time frame (e.g., within 30
--  days).

with purchases as (
    select customer_id, 
           str_to_date(date, '%d-%m-%Y') as purchase_date, 
           lag(str_to_date(date, '%d-%m-%Y')) over (partition by customer_id order by str_to_date(date, '%d-%m-%Y')) as previous_purchase
    from walmartsales_dataset
)
select customer_id, 
       count(*) as repeat_purchases
from purchases
where datediff(purchase_date, previous_purchase) <= 30
group by customer_id
having repeat_purchases > 1;

--  Task 9: Finding Top 5 Customers by Sales Volume (6 Marks)
--  Walmart wants to reward its top 5 customers who have generated the most sales Revenue.

select customer_id, 
       sum(total) as total_sales
from walmartsales_dataset
group by customer_id
order by total_sales desc
limit 5;

--  Task 10: Analyzing Sales Trends by Day of the Week (6 Marks)
--  Walmart wants to analyze the sales patterns to determine which day of the week
--  brings the highest sales.

select dayname(str_to_date(date, '%d-%m-%Y')) as day_of_week,
       sum(total) as total_sales
from walmartsales_dataset
group by day_of_week
order by total_sales desc;
