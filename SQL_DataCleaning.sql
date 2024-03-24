-- Step 1: Ensure Products Table Structure

-- Make 'Product ID' column NOT NULL
ALTER TABLE Products
ALTER COLUMN [Product ID] VARCHAR(50) NOT NULL;

-- Add PRIMARY KEY constraint to 'Product ID' column
ALTER TABLE Products
ADD CONSTRAINT PK_Products PRIMARY KEY ([Product ID]);

-- Step 2: Ensure Orders Table Structure

-- Change data types for sales, profit, and discount columns from VARCHAR to FLOAT
ALTER TABLE Orders
ALTER COLUMN Sales FLOAT;

ALTER TABLE Orders
ALTER COLUMN Profit FLOAT;

ALTER TABLE Orders
ALTER COLUMN Discount FLOAT;

-- Change data type for quantity column from VARCHAR to INT
ALTER TABLE Orders
ALTER COLUMN Quantity INT;

-- Change data type for OrderDate column from VARCHAR to DATE
ALTER TABLE Orders
ALTER COLUMN [Order Date] DATE;

-- Change data type for ShipDate column from VARCHAR to DATE
ALTER TABLE Orders
ALTER COLUMN [Ship Date] DATE;

-- Add Foreign Key Constraint to Orders Table referencing Customer Table
ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_CustomerID FOREIGN KEY ([Customer ID]) REFERENCES Customers([Customer ID]);

-- Add Foreign Key Constraint to Orders Table referencing Product Table
ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_ProductID FOREIGN KEY ([Product ID]) REFERENCES Products([Product ID]);

-- Add Foreign Key Constraint to Orders Table referencing Location Table
ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_PostalCode FOREIGN KEY ([Postal Code]) REFERENCES Location([Postal Code]);

-- Step 3: Ensure Location Table Structure

-- Make 'Postal Code' column NOT NULL
ALTER TABLE Location
ALTER COLUMN [Postal Code] VARCHAR(50) NOT NULL;

-- Add PRIMARY KEY constraint to 'Postal Code' column
ALTER TABLE Location
ADD CONSTRAINT PK_Location PRIMARY KEY ([Postal Code]);

-- Step 4: Data Cleaning for Products Table

-- Identify and remove duplicates in Products table
WITH CTE_Products AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY [Product ID] ORDER BY (SELECT NULL)) AS RowNum
    FROM Products
)
DELETE FROM CTE_Products
WHERE RowNum > 1;

-- Step 5: Data Cleaning for Location Table

-- Identify and remove duplicates in Location table
WITH CTE_Location AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY [Postal Code] ORDER BY (SELECT NULL)) AS RowNum
    FROM Location
)
DELETE FROM CTE_Location
WHERE RowNum > 1;

-- Step 6: Data Cleaning and Data Type Conversion for Orders Table

-- Identify rows with invalid date values in Order Date column
SELECT [Order Date]
FROM Orders
WHERE TRY_CONVERT(DATE, [Order Date], 103) IS NULL;

-- Update Order Date column to the DATE data type with format 'DD/MM/YYYY'
UPDATE Orders
SET [Order Date] = CONVERT(DATE, [Order Date], 103);

-- Identify rows with invalid date values in Ship Date column
SELECT [Ship Date]
FROM Orders
WHERE TRY_CONVERT(DATE, [Ship Date], 103) IS NULL;

-- Update Ship Date column to the DATE data type with format 'DD/MM/YYYY'
UPDATE Orders
SET [Ship Date] = CONVERT(DATE, [Ship Date], 103);
