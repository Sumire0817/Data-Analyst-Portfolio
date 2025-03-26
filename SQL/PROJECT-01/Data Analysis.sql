-- Exploratory data analysis
SELECT *
FROM layoffs_staging2
;
-- Checking on percentage_laid_off and the  (1 actually means 100% has been layed off)
SELECT MAX(percentage_laid_off) AS most_percentage_laid_off , MAX(total_laid_off) AS most_total_laid_off
FROM layoffs_staging2
;
-- Date range check
SELECT MIN(`date`),MAX(`date`)
FROM layoffs_staging2
;
-- (2020-03-11 - 2023-03-06) 
-- Checking Per company laid off
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2 AS sum_laid_off
GROUP BY company
ORDER BY 2 DESC
;
-- Per Industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2 AS sum_laid_off
GROUP BY industry
ORDER BY 2 DESC
;
-- Per Country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2 AS sum_laid_off
GROUP BY country
ORDER BY 2 DESC
;
-- Per date
SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging2 AS sum_laid_off
GROUP BY `date`
ORDER BY 2 DESC
;
-- Per year
SELECT SUBSTRING(`date`,1,4) AS year, SUM(total_laid_off) 
FROM layoffs_staging2 AS sum_laid_off
GROUP BY year
ORDER BY 1 DESC
;
-- Or can also use Year() function
SELECT YEAR(`date`) AS year, SUM(total_laid_off) 
FROM layoffs_staging2 AS sum_laid_off
GROUP BY year
ORDER BY 1 DESC
;
-- By stage
SELECT stage AS year, SUM(total_laid_off) 
FROM layoffs_staging2 AS sum_laid_off
GROUP BY stage
ORDER BY 2 DESC
;


-- Doesnt actually help visually cause we dont have the number of employees in the sql table
SELECT country, SUM(percentage_laid_off) 
FROM layoffs_staging2
GROUP BY country 
ORDER BY 2 DESC
;

-- PER MONTH
SELECT MONTH(`date`) AS month , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY month
ORDER BY month DESC
;
-- Per month and date
SELECT SUBSTRING(`date`,1,7) AS date_year_month , SUM(total_laid_off) AS sum_totl_laid
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY date_year_month
ORDER BY 1 ASC
;
-- Rolling sum meaning it totals the entire thing
WITH Rolling_total AS (
SELECT SUBSTRING(`date`,1,7) AS date_year_month , SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY date_year_month
ORDER BY 1 ASC
)
SELECT date_year_month,total_off, SUM(total_off) OVER(ORDER BY date_year_month) as rolling_total
FROM rolling_total
;

-- Per company per year
SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, `date`
ORDER BY 1 ASC
;

-- more complex ones
WITH Company_year (company,years, total_laid_off) AS (
SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)

), Company_Year_Rank AS(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE ranking <=5
ORDER BY ranking ASC
;