USE Kubra

---Made sure of the data consistancy to perform union operation

SELECT * FROM Sales_October_2019
UNION 
SELECT * FROM Sales_November_2019
UNION 
SELECT * FROM Sales_December_2019

---explore order details and revenue over all
WITH CTE AS 
(SELECT * FROM Sales_October_2019
UNION 
SELECT * FROM Sales_November_2019
UNION 
SELECT * FROM Sales_December_2019)
SELECT 
	COUNT( DISTINCT order_ID) 'Total Orders', 
	COUNT(order_ID) 'Total line of Orders',
	CAST(SUM(Order_Value) as decimal(10,2)) as 'Total order Value',
	SUM(Quantity_Ordered) as 'Total Number of items Sold',
	MAX(Quantity_Ordered) as 'Highest number of Product in a order',
	MIN(Quantity_Ordered) as 'Lowest number of Product in a order'
FROM CTE

-----product wise Sales Revenue
WITH CTE AS 
(SELECT * FROM Sales_October_2019
UNION 
SELECT * FROM Sales_November_2019
UNION
SELECT * FROM Sales_December_2019)
select 
	Product,
	SUM(Quantity_Ordered) 'Total quatity ordered',
	CAST(SUM(Order_Value) as decimal(10,2)) as 'Total Revenue',
	CAST(CAST((SUM(Order_Value)/(select SUM(Order_Value) from CTE)*100) as decimal(10,2))  as varchar(15)) + '%' as 'Revenue in Percentage'
from CTE
group by Product 
Order by [Total Revenue] Desc

-----product wise Qty sold
WITH CTE AS 
(SELECT * FROM Sales_October_2019
UNION 
SELECT * FROM Sales_November_2019
UNION
SELECT * FROM Sales_December_2019)
select 
	Product, 
	City_Name,
	SUM(Quantity_Ordered) AS 'Total quatity ordered'
from CTE
group by Product,City_Name 
Order by SUM(Quantity_Ordered) Desc


------ State wise orders and revenue
WITH CTE AS 
(SELECT * FROM Sales_October_2019
UNION 
SELECT * FROM Sales_November_2019
UNION
SELECT * FROM Sales_December_2019)
select 
	State_Name,
	(CASE 
	WHEN State_Name ='MA' THEN 'Massachusetts'
	WHEN State_Name ='GA' THEN 'Georgia'
	WHEN State_Name ='OR' THEN 'Oregon'
	WHEN State_Name ='TX' THEN 'Texas'
	WHEN State_Name ='ME' THEN 'Maine'
	WHEN State_Name ='CA' THEN 'California'
	WHEN State_Name ='NY' THEN 'New York'
	WHEN State_Name ='WA' THEN 'Washington'
	END ) as 'Full State Name',
	City_Name,
	SUM(Quantity_Ordered) 'Total quatity ordered',
	CAST(SUM(Order_Value) as decimal(10,2)) as 'Total Revenue',
	CAST(CAST((SUM(Order_Value)/(select SUM(Order_Value) from CTE)*100) as decimal(10,2))  as varchar(15)) + '%' as 'Revenue in Percentage'
from CTE
group by State_Name,City_Name
Order by [Total Revenue] Desc

----- How many orders do we see on each month and the revenue earned
WITH CTE AS 
(SELECT * FROM Sales_October_2019
UNION 
SELECT * FROM Sales_November_2019
UNION
SELECT * FROM Sales_December_2019)

select 
	Month_Number,
	SUM(Quantity_Ordered) 'Total quatity ordered',
	CAST(SUM(Order_Value) as decimal(10,2)) as 'Total Revenue',
	CAST(CAST((SUM(Order_Value)/(select SUM(Order_Value) from CTE)*100) as decimal(10,2))  as varchar(15)) + '%' as 'Revenue in Percentage'
	from CTE
group by Month_Number 
Order by [Total Revenue] Desc



----- How many orders do we see on each day of the week and the revenue earned
WITH CTE AS 
(SELECT * FROM Sales_October_2019
UNION 
SELECT * FROM Sales_November_2019
UNION
SELECT * FROM Sales_December_2019)
select 
	DATENAME(WEEKDAY,Order_Date) as 'Day Name',
	SUM(Quantity_Ordered) 'Total quatity ordered',
	CAST(SUM(Order_Value) as decimal(10,2)) as 'Total Revenue',
	CAST(CAST((SUM(Order_Value)/(select SUM(Order_Value) from CTE)*100) as decimal(10,2)) as varchar(15)) + '%' as 'Revenue in Percentage'
from CTE
group by DATENAME(WEEKDAY,Order_Date) 
Order by [Total Revenue] Desc


----- Top two revenue earned products in each state 
WITH CTE AS 
		(
			SELECT * FROM Sales_October_2019
			UNION 
			SELECT * FROM Sales_November_2019
			UNION
			SELECT * FROM Sales_December_2019
		)
	select * from (
	select 
	(CASE 
	WHEN State_Name ='MA' THEN 'Massachusetts'
	WHEN State_Name ='GA' THEN 'Georgia'
	WHEN State_Name ='OR' THEN 'Oregon'
	WHEN State_Name ='TX' THEN 'Texas'
	WHEN State_Name ='ME' THEN 'Maine'
	WHEN State_Name ='CA' THEN 'California'
	WHEN State_Name ='NY' THEN 'New York'
	WHEN State_Name ='WA' THEN 'Washington'
	END ) as 'Full State Name',
	Product,cast(Sum(Order_Value) as decimal(10,2)) as 'Total Sales',
	Rank() over(partition by State_name order by Sum(Order_Value) Desc) as Rnk
	from CTE 
	group by State_name,Product)x
	where x.Rnk <3
		