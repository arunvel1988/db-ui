-- ======================================
-- E-COMMERCE DATABASE LAB SCRIPT
-- Works with MySQL / PostgreSQL
-- ======================================

-- Create Database
CREATE DATABASE IF NOT EXISTS ecommerce;
\c ecommerce;   -- (Postgres) connect to ecommerce
-- USE ecommerce; -- (MySQL) switch to ecommerce

-- ===================
-- 1. TABLES (DDL)
-- ===================

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


#########################################################################################################
-- ===================
-- 3. DEMO QUERIES
-- ===================

-- View Tables (RDBMS Concepts)
SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;

-- DDL Example
ALTER TABLE Customers ADD COLUMN Address VARCHAR(200);

-- DML Example
UPDATE Products SET Price = 68000 WHERE ProductName = 'iPhone 15';
DELETE FROM Customers WHERE Name = 'Rahul';

-- DQL Example
SELECT Name, Email FROM Customers WHERE CustomerID = 1;

-- Aggregation Examples
SELECT COUNT(*) AS TotalOrders FROM Orders;
SELECT SUM(TotalAmount) AS TotalRevenue FROM Orders;
SELECT AVG(TotalAmount) AS AverageOrderValue FROM Orders;
SELECT MAX(TotalAmount) AS BiggestOrder FROM Orders;

-- Joins Examples
-- 1. Customers with their orders
SELECT Customers.Name, Orders.OrderID, Orders.TotalAmount
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID;

-- 2. All customers, even without orders
SELECT Customers.Name, Orders.OrderID
FROM Customers
LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID;

-- ===================
-- 4. ACID Demo
-- ===================
BEGIN;
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES (2, '2025-09-05', 20000);
ROLLBACK;   -- undo transaction
COMMIT;     -- (if you want to save instead)
