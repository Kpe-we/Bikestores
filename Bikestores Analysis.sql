USE bikestores

-- Using Joins to select the columns needed for the analysis --
SELECT o.order_id, c.first_name, c.last_name, c.city, c.state, o.order_date, s.store_id, s.city as store_city, 
		s.store_name, st.staff_id, st.first_name as rep, st.last_name as rep2,  oi.list_price, oi.product_id, oi.discount, oi.quantity, 
		p.product_name, cat.category_name, b.brand_name
	INTO total_column
	FROM sales.orders as o
	LEFT JOIN sales.customers as c
	ON o.customer_id = c.customer_id 
	LEFT JOIN sales.stores as s
	ON o.store_id = s.store_id
	LEFT JOIN sales.staffs as st
	ON o.staff_id = st.staff_id
	LEFT JOIN sales.order_items as oi
	ON o.order_id = oi.order_id
	LEFT JOIN production.products as p
	ON oi.product_id = p.product_id
	LEFT JOIN production.categories as cat
	ON p.category_id = cat.category_id
	LEFT JOIN production.brands as b
	ON p.brand_id = b.brand_id

SELECT *
FROM total_column;

-- Creating our final table for analysis --
SELECT 
		Order_id,
		CONCAT(first_name, ' ', last_name) as CustomerName,
		City,
		State,
		Order_date,
		CAST(MONTH(order_date) AS varchar) Month,
		YEAR(order_date) Year,
		List_price,
		Quantity,
		Discount,
		list_price * quantity * (1 - discount) as Sales,
		Product_Name,
		Category_Name,
		Brand_Name,
		Store_Name,
		Store_City,
		CONCAT(rep, ' ', rep2) as SalesRep
INTO bikestore_dataset
FROM total_column

-- RENAMING THE MONTH COLUMN VALUES --
UPDATE bikestore_dataset
SET Month = CASE Month
		WHEN 1 THEN 'January'
		WHEN 2 THEN 'Febuary'
		WHEN 3 THEN 'March'
		WHEN 4 THEN 'April'
		WHEN 5 THEN 'May'
		WHEN 6 THEN 'June'
		WHEN 7 THEN 'July'
		WHEN 8 THEN 'August'
		WHEN 9 THEN 'September'
		WHEN 10 THEN 'October'
		WHEN 11 THEN 'November'
		WHEN 12 THEN 'December'
		ELSE Month
	END;

update bikestore_dataset
set cast(Month as date)

-- SHOW NEW TABLE -- 
SELECT * 
FROM bikestore_dataset

-- OVERALL OVERVIEW OF THE DATA --

SELECT COUNT(DISTINCT State) as State,
	COUNT(DISTINCT city) City,
	COUNT(DISTINCT store_city) StoreCity,
	COUNT(DISTINCT SalesRep) NumOfSalesReps,
	COUNT(DISTINCT store_name) NumOfStores,
	COUNT(DISTINCT CustomerName) NumOfCustomers,
	COUNT(DISTINCT brand_name) NumOfBrands,
	COUNT(DISTINCT category_name) NumOfCategories,
	COUNT(DISTINCT product_name) NumOfProducts,
	COUNT(order_id) TotalTransactions,
	COUNT(DISTINCT order_id) TotalOrders,
	SUM(quantity) TotalQuatity,
	SUM(sales) Revenue
FROM bikestore_dataset


-- EXPLORATORY DATA ANALYSIS --

-- Total Number of Orders -- 
SELECT count(distinct order_id) Total_Num_of_Orders
FROM bikestore_dataset

-- Total Transactions --
SELECT count(order_id) TotalTransaction
FROM bikestore_dataset

SELECT count(order_id) TotalTransaction,
	YEAR
FROM bikestore_dataset
GROUP BY Year

SELECT count(order_id) TotalTransaction,
	Month
FROM bikestore_dataset
GROUP BY Month, MONTH(Order_date)
ORDER BY MONTH(Order_date)


-- Number of Orders, Revenue, Quantities -- 
SELECT count(order_id) AS Num_of_order, sum(sales) revenue, sum(quantity) as Total_Num_of_quantity
FROM bikestore_dataset


-- Sales by Stores --
SELECT store_name, count(store_name) Total_Num_of_Orders, SUM(sales) Total_Revenue 
FROM bikestore_dataset
GROUP BY store_name

-- Number of City -
SELECT COUNT (DISTINCT city) Cities
FROM bikestore_dataset

-- Sales by City --
SELECT TOP (10) city, state, SUM(sales) TotalSales
FROM bikestore_dataset
GROUP BY city, state
ORDER BY TotalSales DESC

-- Sales by State --
SELECT state, store_name, SUM(sales) TotalSales
FROM bikestore_dataset
GROUP BY state, Store_Name
ORDER by TotalSales DESC


-- Over View --
SELECT state, city, store_city, SUM(sales) TotalSales
FROM bikestore_dataset
GROUP BY state, city, store_city
ORDER BY TotalSales


-- Sales by Produts --
SELECT TOP (10) Product_Name, SUM(sales) TotalSales
FROM bikestore_dataset
GROUP BY Product_Name
ORDER BY TotalSales DESC

-- Sales by Category --
SELECT category_name, SUM(sales) TotalSales
FROM bikestore_dataset
GROUP BY category_name
ORDER BY TotalSales DESC

-- Sales by BrandName --
SELECT brand_name, SUM(sales) TotalSales
FROM bikestore_dataset
GROUP BY brand_name
ORDER BY TotalSales DESC


-- Sales by Customers --
SELECT CustomerName, SUM(sales) TotalAmountSpent
FROM bikestore_dataset
GROUP BY CustomerName
ORDER BY TotalAmountSpent DESC

-- Total Order by Customers --
SELECT CustomerName, COUNT(*) OrdersPerCustomer 
FROM bikestore_dataset
GROUP BY CustomerName
ORDER BY OrdersPerCustomer DESC

-- Total Numbers of Customers --
SELECT count(DISTINCT CustomerName) TotalCustomers
FROM bikestore_dataset


-- Sales Made by SalesRep --
SELECT SalesRep, COUNT(*) TotalTransantions, store_name, SUM(sales) TotalAmountSold
FROM bikestore_dataset
GROUP BY SalesRep, store_name
ORDER BY TotalAmountSold DESC


-- Sales by Year --
SELECT DISTINCT Year, SUM(sales) Revenue
FROM bikestore_dataset
GROUP BY Year
ORDER BY Year ASC

-- Sales by Month --
SELECT DISTINCT Month, SUM(Sales) Revenue
FROM bikestore_dataset
GROUP BY Month 
ORDER BY Revenue DESC
