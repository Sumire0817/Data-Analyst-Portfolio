-- Data Cleaning
SELECT *
FROM sales
;
-- Create the table for staging so you dont have to touch the raw data
CREATE TABLE sales_stagging
LIKE sales
;
-- Inserting the same dataa into the stagging
INSERT sales_stagging
SELECT *
FROM sales
;
-- Just to visualize
SELECT *
FROM sales_stagging
;

-- 1. Remove Duplicates using cte
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY "ï»¿Sales Person",Country,`Date`,"Boxes Shipped") AS row_num
FROM sales_stagging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1
;

-- Creating the new clean table with better naming conventions
CREATE TABLE `sales_stagging2` (
  `Sales_person` text,
  `Country` text,
  `Product` text,
  `Date` text,
  `Amount` text,
  `Boxes_shipped` int,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Now inserting the data
INSERT INTO sales_stagging2
SELECT *, ROW_NUMBER() OVER(PARTITION BY "ï»¿Sales Person",Country,`Date`,"Boxes Shipped") AS row_num
FROM sales_stagging
;

-- To visualize
SELECT *
FROM sales_stagging2
;

-- Turning off safe mode cause it wont let me in my preference
SET SQL_SAFE_UPDATES = 0;
-- Can now delete those duplicates based on rows
DELETE 
FROM sales_stagging2
WHERE row_num >1
;

-- 2 Standardized
-- Checking per column (Sales_person first)
SELECT DISTINCT Sales_person
FROM sales_stagging2
ORDER BY Sales_person ASC
;

-- Country
SELECT DISTINCT Country
FROM sales_stagging2
ORDER BY Country ASC
;

-- Product
SELECT DISTINCT Product
FROM sales_stagging2
ORDER BY Product ASC
;

-- Date
SELECT DISTINCT `Date`
FROM sales_stagging2
ORDER BY `Date` ASC
;

-- to change the `date` to date
SELECT `Date`,
STR_TO_DATE(`Date`, '%d-%b-%y') AS converted_date
FROM sales_stagging2
;

-- Now it can change the data type of the table
ALTER TABLE sales_stagging2
MODIFY COLUMN `Date` DATE;

-- Amount
SELECT DISTINCT Amount
FROM sales_stagging2
ORDER BY Amount DESC
;

-- Replacing it instead $ And ,
SELECT DISTINCT Amount, 
	REPLACE(REPLACE(Amount, ',', ''), '$', '')
FROM sales_stagging2
ORDER BY 1;

-- Updating the data
UPDATE sales_stagging2
SET Amount = REPLACE(REPLACE(Amount, ',', ''), '$', '')
;

-- Boxes_shipped
SELECT DISTINCT Boxes_shipped
FROM sales_stagging2
ORDER BY Boxes_shipped DESC
;
-- 3 Null Values or blank values
-- View of all 
SELECT DISTINCT * 
FROM sales_stagging2
WHERE Sales_person IS NULL OR Sales_person = ''
   OR Product IS NULL OR Product = ''
   OR `Date` IS NULL
   OR Amount IS NULL OR Amount = ''
   OR Boxes_shipped IS NULL OR Boxes_shipped = ''
;
-- There are no null or empty columns so you can now continue

-- 4. Remove any columns 
ALTER TABLE sales_stagging2
DROP COLUMN row_num
;
-- Final view
SELECT *
FROM sales_stagging2
;
-- Now a clean data