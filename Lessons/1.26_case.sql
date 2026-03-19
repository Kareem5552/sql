---bucket salarie

SELECT
  job_title_short,
  salary_hour_avg,
  CASE 
    WHEN salary_hour_avg IS NULL THEN 'missing'
    WHEN salary_hour_avg < 25 THEN 'low'
    WHEN salary_hour_avg < 50 THEN 'medium'
    ELSE 'high'
  END AS salary_bucket
FROM job_postings_fact
ORDER BY random()
LIMIT 20;

---handling missing data

SELECT
  job_title,
  salary_hour_avg::DECIMAL(10,2),
  CASE 
    WHEN salary_hour_avg < 25 THEN 'low'
    WHEN salary_hour_avg < 50 THEN 'medium'
    ELSE 'high'
  END AS salary_bucket,
  CASE 
    WHEN job_title_short LIKE '%Data%' AND job_title_short LIKE '%Engineer%' THEN 'data_engineer'
    WHEN job_title_short LIKE '%Data%' AND job_title_short LIKE '%Analyst%' THEN 'data_analyst'
    WHEN job_title_short LIKE '%Data%' AND job_title_short LIKE '%Scientist%' THEN 'data_scientist'
    ELSE 'other'
  END AS job_title_category
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL AND job_title_short IS NOT NULL
ORDER BY random()
LIMIT 20;


SELECT job_title_short,
COUNT(*) AS job_count,
MEDIAN(
  CASE 
  WHEN salary_year_avg < 100000 THEN salary_year_avg
  END
) AS median_low_salary,
MEDIAN(
  CASE
  WHEN salary_year_avg >= 100000 AND salary_year_avg < 150000 THEN salary_year_avg
  END
) AS median_high_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY job_title_short
ORDER BY job_count DESC;



WITH salary_stats AS (
SELECT job_title_short,
salary_hour_avg,
salary_year_avg,
CASE WHEN
salary_year_avg IS NOT NULL THEN salary_year_avg
WHEN salary_hour_avg IS NOT NULL THEN salary_hour_avg * 40 * 52

END AS standardized_salary

FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL
)


SELECT job_title_short,
salary_hour_avg,
salary_year_avg,
CASE 
    WHEN standardized_salary IS NULL THEN 'missing'
    WHEN standardized_salary < 50000 THEN 'low'
    WHEN standardized_salary < 100000 THEN 'medium'
    ELSE 'high'
END AS salary_bucket
FROM salary_stats
ORDER BY random()
LIMIT 20;
