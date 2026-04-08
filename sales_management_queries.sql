CREATE DATABASE Customer;
USE Customer;

-- 1 Display all customers who are from India.

SELECT 
CustomerID,
CustomerName,
City,
Country
FROM 
customers
WHERE Country = 'India';

-- 2 List all products under the Accessories category.

SELECT 
ProductID,
ProductName,
Category,
Price
FROM 
Products
WHERE Category = 'Accessories';

-- 3 Show all orders placed in April 2024.

SELECT 
OrderID,
CustomerID,
ProductID,
OrderDate,
Quantity
FROM 
Orders
WHERE MONTH(OrderDate) = 4 AND YEAR(OrderDate) = 2024;

-- 4 Display customer names and product names for all orders.

SELECT 
c.CustomerName, 
p.ProductName
FROM 
Orders AS o
JOIN Customers AS c 
	ON o.CustomerID = c.CustomerID
JOIN Products AS p 
	ON o.ProductID = p.ProductID;

-- 5 Show all products priced above ₹10,000 sorted by price descending.

SELECT
ProductID,
ProductName,
Category,
Price
FROM 
Products
WHERE Price > 10000
ORDER BY Price DESC;



-- 6 Find the total quantity ordered by each customer.

SELECT 
CustomerID, 
SUM(Quantity) AS TotalQty
FROM Orders
GROUP BY CustomerID;

-- 7 Calculate total sales amount (Price × Quantity) for each order.

SELECT 
o.OrderID, 
(p.Price * o.Quantity) AS TotalAmount
FROM 
Orders AS o
JOIN Products AS p 
	ON o.ProductID = p.ProductID;

-- 8 Find total revenue generated per product category.

SELECT 
p.Category, 
SUM(p.Price * o.Quantity) AS Revenue
FROM 
Orders AS o
JOIN Products AS p 
	ON o.ProductID = p.ProductID
GROUP BY p.Category;

-- 9 Identify the customer who placed the maximum total orders.

SELECT TOP 1 
CustomerID, 
COUNT(*) AS TotalOrders
FROM 
Orders
GROUP BY CustomerID
ORDER BY TotalOrders DESC;

-- 10 Show average price of products in each category.

SELECT 
Category, 
AVG(Price) AS AvgPrice
FROM 
Products
GROUP BY Category;



-- 11 Write a query to show CustomerName, ProductName, Quantity, and OrderDate.

SELECT 
c.CustomerName, 
p.ProductName, 
o.Quantity, 
o.OrderDate
FROM 
Orders AS o
JOIN Customers AS c 
	ON o.CustomerID = c.CustomerID
JOIN Products AS p 
	ON o.ProductID = p.ProductID;

-- 12 Display a list of customers who purchased “Electronics” items only.
SELECT DISTINCT 
c.CustomerName,
p.Category
FROM 
Orders AS o
JOIN Customers AS c 
	ON o.CustomerID = c.CustomerID
JOIN Products AS p 
	ON o.ProductID = p.ProductID
WHERE p.Category = 'Electronics';

-- 13 Find customers who have not placed any orders.

SELECT 
c.CustomerName
FROM 
Customers AS c
LEFT JOIN Orders AS o 
	ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;

-- 14 Display total sales for each customer along with their city and country.

SELECT 
c.CustomerName, 
c.City, 
c.Country,
SUM(p.Price * o.Quantity) AS TotalSales
FROM 
Orders AS o
JOIN Customers AS c 
	ON o.CustomerID = c.CustomerID
JOIN Products AS p 
	ON o.ProductID = p.ProductID
GROUP BY c.CustomerName, c.City, c.Country;



-- 15 Display customers who have purchased products costing more than ₹25,000.

SELECT DISTINCT 
c.CustomerName
FROM 
Customers c
WHERE c.CustomerID IN (
    SELECT 
	o.CustomerID
    FROM 
	Orders AS o
    JOIN Products AS p 
		ON o.ProductID = p.ProductID
    WHERE p.Price > 25000
);

-- 16  Find the product(s) whose price is greater than the average price of all products.

SELECT *
FROM 
Products
WHERE Price > (SELECT AVG(Price) FROM Products);

-- 17  Show all orders where the quantity is greater than the average quantity ordered.

SELECT *
FROM 
Orders
WHERE Quantity > (SELECT AVG(Quantity) FROM Orders);

-- 18 Display the product with the highest total sales amount using a subquery.

SELECT TOP 1 
p.ProductName
FROM 
Orders AS o
JOIN Products AS p 
	ON o.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY SUM(p.Price * o.Quantity) DESC;



-- 19 Using a CTE, calculate total sales (Price × Quantity) for each customer.

WITH CustomerSales AS (
    SELECT 
	o.CustomerID, 
	SUM(p.Price * o.Quantity) AS TotalSales
    FROM 
	Orders AS o
    JOIN Products AS p 
		ON o.ProductID = p.ProductID
    GROUP BY o.CustomerID
)
SELECT * 
FROM 
CustomerSales;

-- 20 (Recursive) Use a recursive CTE to generate a sequence of numbers from 1 to 10.

WITH Numbers AS (
    SELECT 
	1 AS num
    UNION ALL
    SELECT 
	num + 1 
	FROM 
	Numbers 
	WHERE num < 10
)
SELECT * 
FROM 
Numbers;

-- 21 Using a CTE, find top 3 products by total revenue.

WITH ProductRevenue AS (
    SELECT 
	p.ProductName, 
	SUM(p.Price * o.Quantity) AS Revenue
    FROM 
	Orders AS o
    JOIN Products AS p 
		ON o.ProductID = p.ProductID
    GROUP BY p.ProductName
)
SELECT TOP 3 * 
FROM 
ProductRevenue
ORDER BY Revenue DESC;




-- 22 Create a UDF named TotalOrderAmount(OrderID) that returns total amount for that order.

CREATE FUNCTION TotalOrderAmount (@OrderID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Total INT;

    SELECT @Total = SUM(p.Price * o.Quantity)
    FROM Orders o
    JOIN Products p ON o.ProductID = p.ProductID
    WHERE o.OrderID = @OrderID;

    RETURN @Total;
END;

-- 23 Use this function to display OrderID and TotalAmount for all orders.

SELECT 
OrderID, 
dbo.TotalOrderAmount(OrderID) AS TotalAmount
FROM 
Orders;


-- 24 Create a Stored Procedure named GetCustomerOrders(CustomerID) to list all orders placed by that customer.

CREATE PROCEDURE GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SELECT * 
	FROM 
	Orders
    WHERE CustomerID = @CustomerID;
END;

-- 25 Execute the stored procedure for CustomerID = 101.

EXEC GetCustomerOrders @CustomerID = 101;




-- 26 Show each customer’s total purchase value and their rank based on total purchase (highest to lowest).

SELECT 
c.CustomerName,
SUM(p.Price * o.Quantity) AS TotalPurchase,
RANK() OVER (ORDER BY SUM(p.Price * o.Quantity) DESC) AS Rank
FROM 
Orders AS o
JOIN Customers AS c 
	ON o.CustomerID = c.CustomerID
JOIN Products AS p 
	ON o.ProductID = p.ProductID
GROUP BY c.CustomerName;

-- 27  For each order, display the running total of quantity ordered by date.

SELECT 
OrderDate, 
Quantity,
SUM(Quantity) OVER (ORDER BY OrderDate) AS RunningTotal
FROM 
Orders;

-- 28 Display product-wise average price and deviation of each product’s price from its category average.

SELECT 
ProductName, 
Price,
AVG(Price) OVER (PARTITION BY Category) AS AvgCategoryPrice,
Price - AVG(Price) OVER (PARTITION BY Category) AS Deviation
FROM 
Products;

-- 29 Display order details along with ROW_NUMBER() to show the sequence of orders by date.


SELECT * FROM customers;


-- 30 Add a new customer.

INSERT INTO Customers (CustomerID, CustomerName, City, Country)
VALUES (121, 'Nitesh', 'Indore', 'India');

-- 31 Update the price of “Pen Drive” to ₹1500.

UPDATE Products
SET Price = 1500
WHERE ProductName = 'Pen Drive';

-- 32 Delete all orders placed before 2024-04-01.

DELETE FROM Orders
WHERE OrderDate < '2024-04-01';



-- 33 Write a query to display the Top 3 Customers by Total Revenue using RANK() window function.

SELECT TOP 3
CustomerID,
SUM(p.Price * o.Quantity) AS Revenue,
RANK() OVER (ORDER BY SUM(p.Price * o.Quantity) DESC) AS Rank
FROM 
Orders AS o
JOIN Products AS p 
	ON o.ProductID = p.ProductID
GROUP BY CustomerID;

-- 34 Create a stored procedure to return monthly sales summary (Month, Total_Orders, Total_Revenue).

CREATE PROCEDURE MonthlySalesSummary
AS
BEGIN
    SELECT 
    FORMAT(OrderDate, 'yyyy-MM') AS Month,
    COUNT(OrderID) AS TotalOrders,
    SUM(p.Price * o.Quantity) AS TotalRevenue
    FROM 
	Orders AS o
    JOIN Products AS p 
		ON o.ProductID = p.ProductID
    GROUP BY FORMAT(OrderDate, 'yyyy-MM');
END;
