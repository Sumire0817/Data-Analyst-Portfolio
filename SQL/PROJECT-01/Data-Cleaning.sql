-- Data cleaning

SELECT *
FROM layoffs
;

-- 1. Remove Duplicates
-- 2 Standardized
-- 3 Null Values or blank values
-- 4. Remove any columns 

-- Copies it like schema like the layoff
CREATE TABLE layoffs_staging
LIKE layoffs
;
-- Just to visualize
SELECT *
FROM layoffs_staging
;

-- Insert it into the new staging so that you shouldnt work in the raw data
INSERT layoffs_staging
SELECT *
FROM layoffs
;
-- Now we have our data clone
-- 1. Remove Duplicates

-- Checking of duplicates
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,industry,total_laid_off,percentage_laid_off,`date`,stage,country) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1
;
-- Creating an extra column but without the row_num
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- INSERTINGF THHE DAATA IN THE NEW TABLE
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,industry,total_laid_off,percentage_laid_off,`date`,stage,country) AS row_num
FROM layoffs_staging
;
-- Select first to identify
SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;
-- Now you can delete it
DELETE FROM layoffs_staging2 WHERE row_num > 1;

-- 2 Standardized Data

SELECT company,TRIM(company)
FROM layoffs_staging2
;
-- Updating company from removed spaces
UPDATE layoffs_staging2
SET company = TRIM(company)
;

-- For the industry
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1
;

SELECT*
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'
;

-- Now to update the existing data to update
UPDATE layoffs_staging2
SET industry = 'CRYPTO'
WHERE industry LIKE 'Crypto%'
;

-- Check everything else to clean
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1
;
-- For country
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1
;
SELECT  DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%'
;
UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%'
;
-- Another thing you can do called trailing
SELECT DISTINCT country,TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1
;
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
;

-- to change the `date` to date
SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y')
;
-- Now it can change the data type of the table
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3 Null Values or blank values

-- Now for total lay offs (USE IS IF NULL)
SELECT COUNT(*) AS null_count
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

-- SELECTING FROM industry to populate
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';
;
-- AIRbnb (industry = travel, percentage_laid_off = 0.25
SELECT * 
FROM layoffs_staging2
WHERE company LIKE 'Airbnb';
-- Updating 
UPDATE layoffs_staging2
SET industry = 'Travel'
WHERE industry IS NULL
OR industry = '' 
AND company LIKE 'Airbnb';
-- Carvana
UPDATE layoffs_staging2
SET industry = 'Transportation'
WHERE industry IS NULL
OR industry = '' 
AND company LIKE 'Carvana';
-- Juul Consumer
UPDATE layoffs_staging2
SET industry = 'Consumer'
WHERE industry IS NULL
OR industry = '' 
AND company LIKE 'Juul';
-- aNOTHER WAY TO DO THIS in order to see the data (see the null and not null at the same time)
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company 
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


-- 4. Remove any columns 
-- Now remove the data that no longer needed (Just be confident)
-- checking other nulls
SELECT DISTINCT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
; 

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
; 

-- NOW TO REMOVE THE row_num which was used to check the dfta earlier
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2
;

-- Now a clean data