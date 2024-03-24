-- Query 1: Yearly Sales Trend
SELECT 
    YEAR([Order Date]) AS OrderYear,
    MONTH([Order Date]) AS OrderMonth,
    SUM(Sales) AS TotalSalesRevenue -- What is the total sales revenue for each month over the past year?
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

-- Query 2: Top Selling Products
SELECT TOP 10
    p.[Product Name],
    SUM(o.Sales) AS TotalSalesRevenue -- Which are the top 10 best-selling products by total sales revenue?
FROM 
    Orders o
INNER JOIN 
    Products p ON o.[Product ID] = p.[Product ID]
GROUP BY 
    p.[Product Name]
ORDER BY 
    TotalSalesRevenue DESC;

-- Query 3: Customer Segmentation
SELECT 
    o.Segment,
    SUM(o.Sales) AS TotalSalesRevenue -- How does sales revenue vary across different customer segments?
FROM 
    Orders o
INNER JOIN 
    Customers c ON o.[Customer ID] = c.[Customer ID]
GROUP BY 
    o.Segment;

-- Query 4: Average Order Value by Product Category
SELECT 
    p.Category,
    AVG(o.Sales / o.Quantity) AS AvgOrderValue -- What is the average order value for each product category?
FROM 
    Orders o
INNER JOIN 
    Products p ON o.[Product ID] = p.[Product ID]
GROUP BY 
    p.Category;

-- Query 5: Profit Margin Analysis
SELECT Top 10
    p.[Product Name],
    (SUM(o.Profit) / SUM(o.Sales)) * 100 AS ProfitMarginPercentage -- Which products have the highest and lowest profit margins?
FROM 
    Orders o
INNER JOIN 
    Products p ON o.[Product ID] = p.[Product ID]
GROUP BY 
    p.[Product Name];

-- Query 6: Regional Sales Performance
SELECT TOP 3 
    l.City, 
    SUM(o.Sales) AS Total_Sales_Revenue -- What are the top three cities by total sales revenue?
FROM 
    Orders o
JOIN 
    Location l ON o.[Postal Code] = l.[Postal Code]
GROUP BY 
    l.City
ORDER BY 
    Total_Sales_Revenue DESC;

-- Query 7: Discount Rates by Product Sub-Category
SELECT TOP 5 
    p.[Sub-Category], 
    AVG(Discount) AS Avg_Discount_Rate -- Which product sub-categories have the highest and lowest average discount rates?
FROM 
    Orders o
JOIN 
    Products p ON o.[Product ID] = p.[Product ID]
GROUP BY 
    p.[Sub-Category]
ORDER BY 
    Avg_Discount_Rate DESC;

-- Query 8: Total Profit by Region
SELECT 
    l.Region, 
    SUM(o.Profit) AS Total_Profit -- Which region has generated the highest total profit?
FROM 
    Orders o
JOIN 
    Location l ON o.[Postal Code] = l.[Postal Code]
GROUP BY 
    l.Region;

-- Query 9: Cumulative Sales Analysis
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

-- Query 10: Product Sales Ranking
SELECT 
    p.Category,
    o.[Product ID],
    p.[Product Name],
    SUM(o.Sales) AS Total_Sales,
    RANK() OVER (PARTITION BY p.Category ORDER BY SUM(o.Sales) DESC) AS Sales_Rank -- What is the sales rank of each product within its category?
FROM 
    Orders o
JOIN 
    Products p ON o.[Product ID] = p.[Product ID]
GROUP BY 
    p.Category, o.[Product ID], p.[Product Name]
ORDER BY 
    p.Category, Total_Sales DESC;
