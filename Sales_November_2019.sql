USE Kubra

---- check the data type of the each COLUMN
SELECT
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH AS MAX_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Sales_November_2019' 

--- check the overall look of the data
SELECT * FROM Sales_November_2019

-----1.ORDER_ID

----Observed around 45 rows being NULL 
SELECT * FROM Sales_November_2019
WHERE  Order_ID IS NULL

DELETE FROM Sales_November_2019
WHERE  Order_ID IS NULL

---There are COLUMN headers that are present multiple times IN the data SET, so we need to eliminate them 
SELECT * FROM Sales_November_2019
WHERE Order_ID NOT LIKE '%[0-9]%'

DELETE FROM Sales_November_2019
WHERE Order_ID NOT LIKE '%[0-9]%'

--- Cross check with COUNT function if I stil lhave rows that has Order_ID other than 
SELECT COUNT(*) FROM Sales_November_2019
WHERE Order_ID LIKE '%[0-9]%'
SELECT COUNT(*) FROM Sales_November_2019

--- change the data type AS interger
ALTER TABLE Sales_November_2019
ALTER COLUMN Order_ID INT

--- there are some repeat order_IDs, lets explore them
SELECT
COUNT(Order_ID) AS 'Total COUNT', 
COUNT(DISTINCT Order_ID) AS 'Distinct COUNT'
FROM Sales_November_2019

--- check for duplicated data and if any, DELETE them
SELECT * FROM Sales_November_2019
WHERE Order_ID IN 
	(SELECT Order_ID FROM 
			(SELECT *,ROW_NUMBER()  OVER (PARTITION BY order_ID, Order_Date, Purchase_Address ORDER BY Order_ID) AS rn 
			FROM Sales_November_2019) x
	WHERE x.rn>1)
/*This confirm that there are no repeat orders IN the TABLE */

----2. Product 

--- product COLUMN doesn't have NULL values
SELECT COUNT(*)  FROM Sales_November_2019
WHERE Product IS NULL

--- There around 19 DISTINCT products 
SELECT DISTINCT Product FROM Sales_November_2019

-----3. Quantity


---Quantity _Ordered
ALTER TABLE Sales_November_2019
ALTER COLUMN Quantity_Ordered INT

---- check if there are any orders with NULL/zero or negative qty(negative qty would mean an order return)

SELECT * FROM Sales_November_2019
WHERE Quantity_Ordered <=0 OR Quantity_Ordered IS NULL

---- check if there are any orders with abnormal values that may be suspecious 
SELECT * FROM Sales_November_2019
ORDER BY Quantity_Ordered Desc

-----4. Price Each

---- change data type Price_Each to FLOAT
ALTER TABLE Sales_November_2019
ALTER COLUMN Price_Each FLOAT

----- check for price coulmns if there are any NULL values and price AS '0'
SELECT * FROM Sales_November_2019
WHERE Price_Each <=0 OR Price_Each IS NULL

---- products are NOT sold for different prices
SELECT Product, MIN(Price_Each) Max_Price, 
	MAX(Price_Each) AS Min_Price FROM Sales_November_2019
	group by Product


----5. Order Value


--- ADD COLUMN for the total order value
ALTER TABLE Sales_November_2019
ADD Order_Value FLOAT

----Calculate the order value for each orders
UPDATE Sales_November_2019
SET Order_Value = Quantity_Ordered * Price_Each 

----6. Order_Date


--- change the data type of order date
UPDATE Sales_November_2019
SET Order_Date = CAST(Order_Date AS smalldatetime) FROM Sales_November_2019

-----7. Month_Number
---- extract MONTH number FROM the data
ALTER TABLE Sales_November_2019
ADD Month_Number INT

UPDATE Sales_November_2019
SET Month_Number = MONTH(Order_Date) FROM Sales_November_2019

--- explore to know the months
SELECT Month_Number AS MONTH FROM Sales_November_2019
group by Month_Number
/* Found  data to contain for the november month too, so these records needs to be kept as we need to perform analytics for entire quarter*/

SELECT * FROM Sales_November_2019
WHERE month_number =11

----7. Purchase Address

---- ADD the columns to hold the values FROM the address COLUMN AS defined
ALTER TABLE Sales_November_2019
ADD City_Name VARCHAR(20),
State_Name VARCHAR(10),
Pincode VARCHAR(10)

-----8.City Name
-----9.State_Name
-----10. Pincode

----- split the address COLUMN so that we can mine the data by city sataes and so on 
UPDATE Sales_November_2019 
SET
	City_Name = TRIM(REVERSE(PARSENAME(REPLACE(REVERSE(Purchase_Address), ',', '.'), 2)))
   ,State_Name = TRIM(REVERSE(PARSENAME(REPLACE(REVERSE(Purchase_Address), ',', '.'), 3)))
FROM Sales_November_2019

SELECT * FROM Sales_November_2019

UPDATE Sales_November_2019 
SET
   Pincode = right(State_Name, 5),
   State_Name =LEFT(State_Name,2)
FROM Sales_November_2019


--- check if there are any abnormal state names IN the COLUMN
SELECT DISTINCT State_Name FROM Sales_November_2019

----  check if the pincode IS neat and clean
SELECT Pincode FROM Sales_November_2019
WHERE Pincode NOT LIKE '%[0-9]%' OR Pincode IS NULL

ALTER TABLE  Sales_November_2019
DROP COLUMN Purchase_Address 

SELECT * FROM Sales_November_2019

