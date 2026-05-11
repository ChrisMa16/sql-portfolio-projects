-- ======================================================
-- Layoffs Data Cleaning Project
-- ======================================================
-- This script cleans the raw layoffs dataset by:
-- 1. Creating staging tables
-- 2. Removing duplicate records
-- 3. Standardizing text values
-- 4. Converting the date column to a DATE data type
-- 5. Handling NULL and blank values
-- 6. Removing rows with missing layoff information
-- 7. Dropping the helper row_num column
-- ======================================================


-- ======================================================
-- 1. Create a staging table
-- ======================================================

SELECT *
FROM layoffs;

CREATE TABLE layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;


-- ======================================================
-- 2. Check for duplicate records
-- ======================================================

SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`
) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`
    ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Checking a company that appeared in the duplicate results.
SELECT *
FROM layoffs
WHERE company = 'Oda';

-- More complete duplicate check using all columns.
WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >= 2;


-- ======================================================
-- 3. Create a second staging table with a row number column
-- ======================================================
-- MySQL does not allow deleting directly from a CTE in the same way some other databases do.
-- This second staging table stores row numbers so duplicate rows can be removed.

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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2;


-- ======================================================
-- 4. Remove duplicate records
-- ======================================================

SET SQL_SAFE_UPDATES = 0;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Confirm duplicates were removed.
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- ======================================================
-- 5. Standardize company names
-- ======================================================
-- Remove extra spaces from company names.

SELECT company, TRIM(company) AS trimmed_company
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT company
FROM layoffs_staging2;


-- ======================================================
-- 6. Standardize industry values
-- ======================================================

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Standardize all Crypto-related industry values to one name.
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;


-- ======================================================
-- 7. Standardize country values
-- ======================================================
-- Some country values have trailing periods, such as 'United States.'.

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) AS cleaned_country
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;


-- ======================================================
-- 8. Standardize date format
-- ======================================================
-- Convert the date column from text into a real DATE data type.

SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') AS new_date
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT `date`
FROM layoffs_staging2;


-- ======================================================
-- 9. Handle NULL and blank industry values
-- ======================================================
-- First, convert blank industry values to NULL.

SELECT *
FROM layoffs_staging2
WHERE industry = '' OR industry IS NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Populate missing industry values when another row for the same company has an industry value.
SELECT t1.company, t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Check remaining NULL industry values.
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL;


-- ======================================================
-- 10. Remove rows with no layoff information
-- ======================================================
-- If both total_laid_off and percentage_laid_off are NULL,
-- the row does not provide useful layoff information for this analysis.

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;


-- ======================================================
-- 11. Drop helper column
-- ======================================================
-- The row_num column was only needed for duplicate removal.

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- ======================================================
-- 12. Final cleaned table check
-- ======================================================

SELECT *
FROM layoffs_staging2;
