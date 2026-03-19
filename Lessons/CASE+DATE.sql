--PART 1 : CASE EXERCISES

SELECT 
job_title_short,
salary_year_avg,
CASE WHEN (salary_year_avg IS NULL) THEN 'missing'
     WHEN (salary_year_avg < 60000) THEN 'low'
     WHEN (salary_year_avg <120000) THEN 'medium'
     WHEN (salary_year_avg >= 120000) THEN 'high'
END AS salary_level
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 20;


--EXERCISE 2

SELECT 
job_title_short,
salary_year_avg,
salary_hour_avg,
CASE WHEN ((salary_year_avg IS NULL ) AND (salary_hour_avg IS NOT NULL)) THEN 'hourly'
    WHEN ((salary_year_avg IS NOT NULL ) AND (salary_hour_avg IS NULL)) THEN 'yearly'
    WHEN ((salary_year_avg IS NOT NULL ) AND (salary_hour_avg IS NOT NULL)) THEN 'Yearly+Hourly'
    ELSE 'no salary listed'
END AS pay_type
FROM job_postings_fact
ORDER BY salary_year_avg DESC
LIMIT 20;

--EXERCISE 3

SELECT 
job_title_short,
salary_year_avg,
salary_hour_avg,
CASE 
    WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
    WHEN salary_hour_avg IS NOT NULL THEN salary_hour_avg * 2080
    WHEN salary_year_avg IS NOT NULL 
     AND salary_hour_avg IS NOT NULL THEN salary_year_avg
    ELSE NULL
END AS standarlized_salary
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 90;



-- Exercise 4 — Advanced Logic

-- Create salary_comment:

-- If salary > 200k → 'Unusually High'

-- If salary between 30k–40k → 'Possibly Part-Time'

-- If salary is NULL → 'Needs Review'

-- Else → 'Normal Range'

WITH s AS (
  SELECT
    job_title_short,
    salary_year_avg,
    salary_hour_avg,
    CASE
      WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
      WHEN salary_hour_avg IS NOT NULL THEN salary_hour_avg * 2080
      ELSE NULL
    END AS standardized_salary
  FROM job_postings_fact
)
SELECT
  job_title_short,
  salary_year_avg,
  standardized_salary,
  CASE
    WHEN standardized_salary IS NULL THEN 'need review'
    WHEN standardized_salary > 200000 THEN 'unusually high'
    WHEN standardized_salary BETWEEN 30000 AND 40000 THEN 'possibly part_time'
    ELSE 'normal range'
  END AS salary_comment
FROM s
ORDER BY standardized_salary DESC
LIMIT 20;



-- 🟢 Exercise 5 — Monthly Aggregation

-- Count number of job postings per month.

-- Group by month.

-- Use:

-- DATE_TRUNC('month', job_posted_date)

-- Order from newest month first.


SELECT
  DATE_TRUNC('month', job_posted_date) AS job_posted_month,
  COUNT(*) AS job_count
FROM job_postings_fact
GROUP BY 1
ORDER BY job_posted_month DESC;

  --Exercise 6 — Weekly Analysis

-- Find how many jobs were posted each week.

-- Group by week.


SELECT
  DATE_TRUNC('week', job_posted_date) AS job_posted_week,
  COUNT(*) AS job_count
FROM job_postings_fact
GROUP BY 1
ORDER BY job_posted_week DESC;

-- -- 

-- 🟢 Exercise 7 — Daily Trend

-- Get total postings per day for the last 30 days only.

SELECT
  DATE_TRUNC('day', job_posted_date) AS job_posted_day,
  EXTRACT(day FROM job_posted_date) AS day_number,
  COUNT(job_id) AS job_count
FROM job_postings_fact
WHERE job_posted_date >= (
    SELECT MAX(job_posted_date) - INTERVAL '30 days'
    FROM job_postings_fact
)
GROUP BY DATE_TRUNC('day', job_posted_date)
ORDER BY job_posted_day;

---where can't contain aggregate functions

-- 🟢 Exercise 9 — Which Month Has Most Jobs?

-- Return:

-- Month number

-- Count

-- Order descending

SELECT
count(job_id),
EXTRACT (month FROM job_posted_date) AS month_number
FROM job_postings_fact
GROUP BY 
EXTRACT (month FROM job_posted_date)
ORDER BY month_number DESC
LIMIT 10;
  

-- 🟢 Exercise 10 — Weekend vs Weekday

-- Create column:

-- If day is Saturday or Sunday → 'Weekend'

-- Else → 'Weekday'

-- Hint:

-- EXTRACT(DOW FROM job_posted_date)

-- (Postgres: 0 = Sunday, 6 = Saturday)

SELECT
  count(job_id),
  EXTRACT (DOW FROM job_posted_date) AS day_num,
  CASE WHEN (EXTRACT (DOW FROM job_posted_date) IN (1,2,3,4,5)) THEN 'Weekday'
       ELSE 'Weekend'
  END AS day_type
FROM job_postings_fact
GROUP BY 
  EXTRACT (DOW FROM job_posted_date)
ORDER BY day_num DESC
LIMIT 10;
  


WITH monthly AS (
  SELECT
    DATE_TRUNC('month', job_posted_date) AS month_start,
    COUNT(*) AS total_postings,
    SUM(CASE WHEN EXTRACT(DOW FROM job_posted_date) IN (0, 6) THEN 1 ELSE 0 END) AS weekend_postings
  FROM job_postings_fact
  GROUP BY 1
)
SELECT
  month_start,
  total_postings,
  weekend_postings,
  total_postings - weekend_postings AS weekday_postings,
  ROUND(100.0 * weekend_postings / total_postings, 2) || '%' AS weekend_pct,
  ROUND(100.0 * (total_postings - weekend_postings) / total_postings, 2) || '%' AS weekday_pct
FROM monthly
ORDER BY month_start DESC;