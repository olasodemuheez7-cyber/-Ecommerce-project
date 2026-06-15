/*1. Total Sales by Employee:  
   - Write a query to calculate the total sales (in dollars) made by each employee, considering the quantity and unit price of products sold. 
 
2. Top 5 Customers by Sales: 
   - Identify the top 5 customers who have generated the most revenue. Show the customer’s name and the total amount they’ve spent. 
 
3. Monthly Sales Trend: 
   - Write a query to display the total sales amount for each month in the year 1997. 
 
4. Order Fulfilment Time: 
   - Calculate the average time (in days) taken to fulfil an order for each employee. Assuming shipping takes 3 or 5 days respectively depending on if the item was ordered in 1996 or 1997. 
 
5. Products by Category with No Sales: 
   - List the customers operating in London and total sales for each.  
 
6. Customers with Multiple Orders on the Same Date: 
   - Write a query to find customers who have placed more than one order on the same date. 
 
7. Average Discount per Product: 
   - Calculate the average discount given per product across all orders. Round to 2 decimal places. 
 
8. Products Ordered by Each Customer: 
   - For each customer, list the products they have ordered along with the total quantity of each product ordered. 
 
9. Employee Sales Ranking: 
   - Rank employees based on their total sales. Show the employeename, total sales, and their rank. 
 
10. Sales by Country and Category: 
    - Write a query to display the total sales amount for each product category, grouped by country. 
 
11. Year-over-Year Sales Growth: 
    - Calculate the percentage growth in sales from one year to the next for each product. 
 
12. Order Quantity Percentile: 
    - Calculate the percentile rank of each order based on the total quantity of products in the order.  
 
13. Products Never Reordered: 
    - Identify products that have been sold but have never been reordered (ordered only once).  
 
14. Most Valuable Product by Revenue: 
    - Write a query to find the product that has generated the most revenue in each category. 
 
15. Complex Order Details: 
    - Identify orders where the total price of all items exceeds $100 and contains at least one product with a discount of 5% or more. */
 

USE ECOMMERCE;

-- Question 1:
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY TotalSales DESC;

DESCRIBE CUSTOMERS;

-- Qyestion 2:
SELECT 
    c.CUSTOMERName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY c.CUSTOMERName
ORDER BY TotalSpent DESC;

-- Question 3:
SELECT 
    MONTH(o.OrderDate) AS SalesMonth,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS MonthlySales
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = 1997
GROUP BY MONTH(o.OrderDate)
ORDER BY SalesMonth;

-- Question 4:
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    AVG(
        CASE 
            WHEN YEAR(o.OrderDate) = 1996 THEN 3
            WHEN YEAR(o.OrderDate) = 1997 THEN 5
        END
    ) AS AvgFulfilmentDays
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName;

-- Question 5:
SELECT 
    c.CUSTOMERName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE c.City = 'London'
GROUP BY c.CUSTOMERName;

-- Question 6:
SELECT 
    CustomerID,
    OrderDate,
    COUNT(OrderID) AS OrderCount
FROM Orders
GROUP BY CustomerID, OrderDate
HAVING COUNT(OrderID) > 1;

-- Question 7:
SELECT 
    p.ProductName,
    ROUND(AVG(od.Discount), 2) AS AvgDiscount
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductName;

-- Question 8:
SELECT 
    c.CustomerName,
    p.ProductName,
    SUM(od.Quantity) AS TotalQuantity
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY c.CustomerName, p.ProductName
ORDER BY c.CustomerName;


-- question 9:
SELECT 
    EmployeeName,
    TotalSales,
    RANK() OVER (ORDER BY TotalSales DESC) AS SalesRank
FROM (
    SELECT 
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
    FROM Employees e
    JOIN Orders o ON e.EmployeeID = o.EmployeeID
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    GROUP BY e.FirstName, e.LastName
) AS SalesData;

-- Question 10:
SELECT 
    c.Country,
    cat.CategoryName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories cat ON p.CategoryID = cat.CategoryID
GROUP BY c.Country, cat.CategoryName
ORDER BY c.Country;

-- Question 11:
WITH YearlySales AS (
    SELECT 
        p.ProductName,
        YEAR(o.OrderDate) AS SalesYear,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY p.ProductName, YEAR(o.OrderDate)
)
SELECT 
    ProductName,
    SalesYear,
    TotalSales,
    LAG(TotalSales) OVER (PARTITION BY ProductName ORDER BY SalesYear) AS PreviousYearSales,
    ROUND(
        ((TotalSales - LAG(TotalSales) OVER (PARTITION BY ProductName ORDER BY SalesYear)) 
        / LAG(TotalSales) OVER (PARTITION BY ProductName ORDER BY SalesYear)) * 100, 2
    ) AS GrowthPercent
FROM YearlySales;

-- Question 12:
SELECT 
    OrderID,
    SUM(Quantity) AS TotalQuantity,
    PERCENT_RANK() OVER (ORDER BY SUM(Quantity)) AS PercentileRank
FROM OrderDetails
GROUP BY OrderID;

-- Question 13:
SELECT 
    p.ProductName
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductName
HAVING COUNT(DISTINCT od.OrderID) = 1;

-- Question 14:
WITH ProductRevenue AS (
    SELECT 
        cat.CategoryName,
        p.ProductName,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS Revenue
    FROM Products p
    JOIN Categories cat ON p.CategoryID = cat.CategoryID
    JOIN OrderDetails od ON p.ProductID = od.ProductID
    GROUP BY cat.CategoryName, p.ProductName
)
SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY CategoryName ORDER BY Revenue DESC) AS RankNum
    FROM ProductRevenue
) Ranked
WHERE RankNum = 1;

-- Question 15:
SELECT o.OrderID
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY o.OrderID
HAVING 
    SUM(od.UnitPrice * od.Quantity) > 100
    AND MAX(od.Discount) >= 0.05;
    AND MAX(od.Discount) >= 0.05;
    
    
     

