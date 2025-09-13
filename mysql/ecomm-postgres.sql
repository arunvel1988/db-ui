-- ======================================
-- E-COMMERCE DATABASE LAB SCRIPT (PostgreSQL)
-- ======================================

-- Create DB first (from terminal):
-- docker exec -i ecommerce-postgres psql -U postgres -c "CREATE DATABASE ecommerce;"

-- Then connect inside script:
\c ecommerce;

-- ===================
-- 1. TABLES (DDL)
-- ===================

DROP TABLE IF EXISTS OrderDetails CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS Products CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;

-- Customers Table
CREATE TABLE Customers (
  CustomerID SERIAL PRIMARY KEY,
  Name VARCHAR(50) NOT NULL,
  Email VARCHAR(100) UNIQUE NOT NULL,
  Phone VARCHAR(15)
);

-- Products Table
CREATE TABLE Products (
  ProductID SERIAL PRIMARY KEY,
  ProductName VARCHAR(100) NOT NULL,
  Price DECIMAL(10,2) NOT NULL
);

-- Orders Table
CREATE TABLE Orders (
  OrderID SERIAL PRIMARY KEY,
  CustomerID INT NOT NULL,
  OrderDate DATE NOT NULL,
  TotalAmount DECIMAL(10,2),
  FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- OrderDetails Table
CREATE TABLE OrderDetails (
  OrderDetailID SERIAL PRIMARY KEY,
  OrderID INT NOT NULL,
  ProductID INT NOT NULL,
  Quantity INT NOT NULL,
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
  FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- ===================
-- 2. SAMPLE DATA (DML)
-- ===================

-- Customers
INSERT INTO Customers (Name, Email, Phone) VALUES
('Arun', 'arun@shop.com', '9876543210'),
('Meena', 'meena@shop.com', '9876543222'),
('Rahul', 'rahul@shop.com', '9876543233');

-- Products
INSERT INTO Products (ProductName, Price) VALUES
('iPhone 15', 70000),
('Dell XPS Laptop', 95000),
('Sony Headphones', 5000);

-- Orders
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES
(1, '2025-09-01', 75000),
(2, '2025-09-02', 5000),
(1, '2025-09-03', 95000);

-- Order Details
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
(1, 1, 1),   -- Arun bought iPhone
(2, 3, 1),   -- Meena bought Headphones
(3, 2, 1),   -- Arun bought Laptop
(3, 3, 2);   -- Arun also bought 2 Headphones

-- ===================
-- 3. DEMO QUERIES
-- ===================

-- DDL
ALTER TABLE Customers ADD COLUMN IF NOT EXISTS Address VARCHAR(200);

-- DML
UPDATE Products SET Price = 68000 WHERE ProductName = 'iPhone 15';
DELETE FROM Customers WHERE Name = 'Rahul';

-- DQL
SELECT Name, Email FROM Customers WHERE CustomerID = 1;

-- Aggregation
SELECT COUNT(*) AS TotalOrders FROM Orders;
SELECT SUM(TotalAmount) AS TotalRevenue FROM Orders;
SELECT AVG(TotalAmount) AS AverageOrderValue FROM Orders;
SELECT MAX(TotalAmount) AS BiggestOrder FROM Orders;

-- Joins
-- Customers with orders
SELECT c.Name, o.OrderID, o.TotalAmount
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID;

-- Customers even without orders
SELECT c.Name, o.OrderID
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID;

-- Orders with product details
SELECT o.OrderID, c.Name AS Customer, p.ProductName, od.Quantity
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID;

-- ===================
-- 4. ACID DEMO
-- ===================

BEGIN;
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
VALUES (2, '2025-09-05', 20000);
ROLLBACK;

BEGIN;
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
VALUES (2, '2025-09-05', 20000);
COMMIT;

-- ===================
-- 5. CHALLENGE QUERIES
-- ===================

-- 1. All orders placed by Arun
SELECT o.OrderID, o.OrderDate, o.TotalAmount
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.Name = 'Arun';

-- 2. Top 1 most expensive product
SELECT ProductName, Price FROM Products
ORDER BY Price DESC LIMIT 1;

-- 3. Customer who spent the most money
SELECT c.Name, SUM(o.TotalAmount) AS TotalSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.Name
ORDER BY TotalSpent DESC LIMIT 1;

-- 4. Products with total quantity sold
SELECT p.ProductName, SUM(od.Quantity) AS TotalSold
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY p.ProductName;

-- 5. Customers with no orders
SELECT c.Name
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;
