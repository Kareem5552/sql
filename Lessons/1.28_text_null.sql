

WITH job_lower AS (
SELECT *,
LOWER(TRIM(job_title)) AS job_title_lower
FROM job_postings_fact
WHERE job_title IS NOT NULL
)





SELECT
job_title_lower,
CASE
WHEN job_title_lower LIKE '% data%'
AND job_title_lower LIKE '% analyst%' THEN 'Data Analyst'
WHEN job_title_lower LIKE '% data%'
AND job_title_lower LIKE '%scientist%' THEN 'Data Scientist'
WHEN job_title_lower LIKE '% data%'
AND job_title_lower LIKE '% engineer%' THEN 'Data Engineer'
ELSE 'Other'
END AS job_title_category
FROM job_lower
ORDER BY RANDOM ( )
LIMIT 30;

SELECT
salary_year_avg,
salary_hour_avg,
COALESCE((salary_year_avg)::TEXT, (salary_hour_avg * 2080)::TEXT,'missing_salary') AS standardized_salary
FROM
job_postings_fact
ORDER BY RANDOM()
LIMIT 30;


