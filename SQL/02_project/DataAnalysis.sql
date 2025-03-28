-- Exploration Data Analysis
SELECT *
FROM sales_stagging2
;

-- TOTAL of Sales_person AND boxes shipped per country
SELECT 
    Country,  
    COUNT(DISTINCT Sales_person) AS person_count, 
    SUM(Boxes_shipped) AS total_shipped
FROM sales_stagging2
GROUP BY Country
;

-- Total ammount per sales person for the entirety of 2022 (Top 5)
SELECT DISTINCT Sales_person,Country, SUM(Amount) AS total_amount, SUM(Boxes_shipped) AS total_shipped
FROM sales_stagging2
GROUP BY Sales_person, Country
ORDER BY total_amount DESC LIMIT 5
;

-- Per Country 
SELECT DISTINCT Country, SUM(Amount) AS total_amount, SUM(Boxes_shipped) AS total_shipped
FROM sales_stagging2
GROUP BY Country
ORDER BY 2 DESC
;


-- Per product total ammount and shipped
SELECT DISTINCT Product, SUM(Amount) AS total_amount, SUM(Boxes_shipped) AS total_shipped
FROM sales_stagging2
GROUP BY Product
ORDER BY total_amount DESC
;

-- Most sales per month
SELECT DISTINCT MONTH(`Date`) AS `month`, SUM(Amount) AS total_amount, SUM(Boxes_shipped) AS total_shipped
FROM sales_stagging2
GROUP BY `month`
ORDER BY total_amount DESC
;

-- Per Month Per country
SELECT DISTINCT 
    Country, 
    MONTH(`Date`) AS `month`, 
    SUM(Amount) AS total_amount, 
    SUM(Boxes_shipped) AS total_shipped
FROM sales_stagging2
GROUP BY Country, `month`
ORDER BY Country, `month` ASC;
