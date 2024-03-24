SELECT * FROM dbo.Customers;
SELECT * FROM dbo.Products;
SELECT * FROM dbo.Location;
SELECT * FROM dbo.Orders;



ALTER TABLE Products
ALTER COLUMN [Product ID] VARCHAR(50) NOT NULL;

ALTER TABLE Products
ADD CONSTRAINT PK_Products PRIMARY KEY ([Product ID]);

ALTER TABLE Orders
ALTER COLUMN [Customer ID] VARCHAR(255); 

-- Add Foreign Key Constraint to Orders Table referencing Customer Table
ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_CustomerID FOREIGN KEY ([Customer ID]) REFERENCES Customers([Customer ID]);

-- Add Foreign Key Constraint to Orders Table referencing Product Table
ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_ProductID FOREIGN KEY ([Product ID]) REFERENCES Products([Product ID]);

ALTER TABLE Location
ALTER COLUMN [Postal Code] VARCHAR(50) NOT NULL;

ALTER TABLE Location
ADD CONSTRAINT PK_Location PRIMARY KEY ([Postal Code]);

ALTER TABLE Products
ADD CONSTRAINT PK_Products PRIMARY KEY ([Product ID]);
-- Add Foreign Key Constraint to Orders Table referencing Location Table
ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_PostalCode FOREIGN KEY ([Postal Code]) REFERENCES Location([Postal Code]);

SELECT [Product ID], COUNT(*) AS DuplicateCount
FROM Products
GROUP BY [Product ID]
HAVING COUNT(*) > 1;

WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY [Product ID] ORDER BY (SELECT NULL)) AS RowNum
    FROM Products
)
DELETE FROM CTE
WHERE RowNum > 1;


SELECT [Postal Code], COUNT(*) AS DuplicateCount
FROM Location
GROUP BY [Postal Code]
HAVING COUNT(*) > 1;

WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY [Postal Code] ORDER BY (SELECT NULL)) AS RowNum
    FROM Location
)
DELETE FROM CTE
WHERE RowNum > 1;

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


SELECT [Order Date]
FROM Orders
WHERE TRY_CONVERT(DATE, [Order Date]) IS NULL;


UPDATE Orders
SET [Order Date] = CONVERT(DATE, [Order Date], 103); -- 103 is the code for British/French date format (DD/MM/YYYY)

-- Update ShipDate column to the DATE data type with format 'DD/MM/YYYY'
UPDATE Orders
SET [Ship Date] = CONVERT(DATE, [Ship Date], 103);


SELECT 
    YEAR([Order Date]) AS OrderYear,
    MONTH([Order Date]) AS OrderMonth,
    SUM(Sales) AS TotalSalesRevenue
FROM 
    Orders
WHERE 
    [Order Date] >= DATEADD(year, -1, GETDATE()) -- Filter for the past year
GROUP BY 
    YEAR([Order Date]),
    MONTH([Order Date])
ORDER BY 
    YEAR([Order Date]),
    MONTH([Order Date]);



SELECT TOP 10
    p.[Product Name],
    SUM(o.Sales) AS TotalSalesRevenue
FROM 
    Orders o
INNER JOIN 
    Products p ON o.[Product ID] = p.[Product ID]
GROUP BY 
    p.[Product Name]
ORDER BY 
    TotalSalesRevenue DESC;


SELECT 
    o.Segment,
    SUM(o.Sales) AS TotalSalesRevenue
FROM 
    Orders o
INNER JOIN 
    Customers c ON o.[Customer ID] = c.[Customer ID]
GROUP BY 
    o.Segment;


SELECT 
    p.Category,
    AVG(o.Sales / o.Quantity) AS AvgOrderValue
FROM 
    Orders o
INNER JOIN 
    Products p ON o.[Product ID] = p.[Product ID]
GROUP BY 
    p.Category;



SELECT Top 10
    p.[Product Name],
    (SUM(o.Profit) / SUM(o.Sales)) * 100 AS ProfitMarginPercentage
FROM 
    Orders o
INNER JOIN 
    Products p ON o.[Product ID] = p.[Product ID]
GROUP BY 
    p.[Product Name];

SELECT TOP 3 l.City, SUM(o.Sales) AS Total_Sales_Revenue
FROM Orders o
JOIN Location l ON o.[Postal Code] = l.[Postal Code]
GROUP BY l.City
ORDER BY Total_Sales_Revenue DESC;


SELECT TOP 5 p.[Sub-Category], AVG(Discount) AS Avg_Discount_Rate
FROM Orders o
JOIN Products p ON o.[Product ID] = p.[Product ID]
GROUP BY p.[Sub-Category]
ORDER BY Avg_Discount_Rate DESC;

SELECT l.Region, SUM(o.Profit) AS Total_Profit
FROM Orders o
JOIN Location l ON o.[Postal Code] = l.[Postal Code]
GROUP BY l.Region;



WITH MonthlySales AS (
    SELECT 
        FORMAT([Order Date], 'yyyy-MM') AS Month,
        p.Category,
        SUM(Sales) AS Monthly_Sales_Revenue
    FROM 
        Orders o
    JOIN 
        Products p ON o.[Product ID] = p.[Product ID]
    GROUP BY 
        FORMAT([Order Date], 'yyyy-MM'), p.Category
),
CumulativeSales AS (
    SELECT 
        Month,
        Category,
        Monthly_Sales_Revenue,
        SUM(Monthly_Sales_Revenue) OVER (PARTITION BY Category ORDER BY Month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Cumulative_Sales_Revenue
    FROM MonthlySales
)
SELECT 
    Month,
    Category,
    Monthly_Sales_Revenue,
    Cumulative_Sales_Revenue
FROM CumulativeSales
ORDER BY 
    Category, Month;

SELECT 
    p.Category,
    o.[Product ID],
    p.[Product Name],
    SUM(o.Sales) AS Total_Sales,
    RANK() OVER (PARTITION BY p.Category ORDER BY SUM(o.Sales) DESC) AS Sales_Rank
FROM 
    Orders o
JOIN 
    Products p ON o.[Product ID] = p.[Product ID]
GROUP BY 
    p.Category, o.[Product ID], p.[Product Name]
ORDER BY 
    p.Category, Total_Sales DESC;












