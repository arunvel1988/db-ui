-- =========================================
-- E-commerce PL/pgSQL Demo
-- =========================================
\c ecommerce;

-- 1. IF-ELSE Example (Apply Discount)
DO $$
DECLARE
    order_amount DECIMAL := 60000;
    discount DECIMAL := 0;
BEGIN
    IF order_amount > 50000 THEN
        discount := order_amount * 0.10;
        RAISE NOTICE 'Discount applied: %', discount;
    ELSE
        RAISE NOTICE 'No discount applied';
    END IF;
END $$;

-- =========================================
-- 2. Cursor Example (List Products in Orders)
-- =========================================
DO $$
DECLARE
    rec RECORD;
    cur CURSOR FOR SELECT ProductName, Price FROM Products;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Product: %, Price: %', rec.ProductName, rec.Price;
    END LOOP;
    CLOSE cur;
END $$;

-- =========================================
-- 3. Exception Handling (Customer Not Found)
-- =========================================
DO $$
DECLARE
    cname VARCHAR(50);
    cid INT := 999;  -- Non-existent customer
BEGIN
    SELECT Name INTO cname FROM Customers WHERE CustomerID = cid;
    RAISE NOTICE 'Customer Name: %', cname;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE NOTICE 'Customer % does not exist', cid;
END $$;

-- =========================================
-- 4. Stored Procedure: PlaceOrder
-- =========================================
CREATE OR REPLACE PROCEDURE PlaceOrder(
    in_customer_id INT,
    in_product_id INT,
    in_quantity INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    prod_price DECIMAL;
    total DECIMAL;
    new_order_id INT;
BEGIN
    -- Get product price
    SELECT Price INTO prod_price FROM Products WHERE ProductID = in_product_id;

    total := prod_price * in_quantity;

    -- Insert into Orders
    INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
    VALUES (in_customer_id, CURRENT_DATE, total)
    RETURNING OrderID INTO new_order_id;

    -- Insert into OrderDetails
    INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
    VALUES (new_order_id, in_product_id, in_quantity);

    RAISE NOTICE 'Order % placed, total %', new_order_id, total;
END $$;

-- Test PlaceOrder
CALL PlaceOrder(1, 3, 2);

-- =========================================
-- 5. Function: GetCustomerTotal
-- =========================================
CREATE OR REPLACE FUNCTION GetCustomerTotal(cid INT)
RETURNS DECIMAL
LANGUAGE plpgsql
AS $$
DECLARE
    total DECIMAL;
BEGIN
    SELECT SUM(TotalAmount) INTO total FROM Orders WHERE CustomerID = cid;
    IF total IS NULL THEN
        total := 0;
    END IF;
    RETURN total;
END $$;

-- Test Function
SELECT GetCustomerTotal(1);

-- =========================================
-- 6. Trigger: Auto-update Stock
-- =========================================
-- Add stock column if not present
ALTER TABLE Products ADD COLUMN IF NOT EXISTS Stock INT DEFAULT 10;

CREATE OR REPLACE FUNCTION update_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Products
    SET Stock = Stock - NEW.Quantity
    WHERE ProductID = NEW.ProductID;
    RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_update_stock ON OrderDetails;

CREATE TRIGGER trg_update_stock
AFTER INSERT ON OrderDetails
FOR EACH ROW
EXECUTE FUNCTION update_stock();

-- Test Trigger
CALL PlaceOrder(2, 1, 1);
SELECT ProductName, Stock FROM Products WHERE ProductID = 1;
