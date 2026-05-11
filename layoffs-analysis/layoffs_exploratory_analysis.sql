-- Exploratory data analysis

SELECT *
FROM layoffs_staging2;

-- we take a look at companies with the most total laid off and the highest percentage of people laid off

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1 -- 1 being 100% of the company
ORDER BY total_laid_off DESC;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- looking at companies with the highest sum of laid off

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- looking at when the layoffs started and what the most recent date of layoffs was

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- looking at what industries had the most layoffs

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- looking at which countries had the highest layoffs

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- looking at total layoffs grouped by year

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;


-- creating a cte to use it to produce a rolling total

WITH Rolling_total AS (
	SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`,1,7) IS NOT NULL
    GROUP BY `MONTH`
    ORDER BY `MONTH` ASC
)
SELECT `MONTH`,
 total_off,
 SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_total;


SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;  

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;  

WITH Company_Year (company, years, total_laid_off) AS (
	SELECT company, YEAR(`date`), SUM(total_laid_off)
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS (
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE ranking <=5;