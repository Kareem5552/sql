SELECT 
  table_name,
  column_name,
  data_type
FROM 
information_schema.columns
WHERE table_name = 'job_postings_fact' OR table_name = 'company_dim';

SELECT 
CAST(job_id AS VARCHAR) || '-'|| CAST(company_id AS VARCHAR),
CAST(job_work_from_home AS INT) AS job_work_from_home,
CAST(job_posted_date AS DATE) AS job_posted_date,
CAST(salary_year_avg AS DECIMAL(10,0)) AS salary_year_avg
FROM 
job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10;



SELECT 
job_id::VARCHAR|| '-'|| company_id::VARCHAR,
job_work_from_home::INT AS job_work_from_home,
job_posted_date::DATE AS job_posted_date,
salary_year_avg::DECIMAL(10,0) AS salary_year_avg
FROM 
job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10;

SELECT 
job_title,
salary_year_avg::INT,
job_work_from_home
FROM
job_postings_fact
WHERE (job_posted_date::DATE >='2023-01-01') AND (job_work_from_home IS NOT NULL) AND salary_year_avg IS NOT NULL
LIMIT 10;

SELECT 
job_title,
(salary_year_avg/ 12)::FLOAT AS monthly_salary_avg
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY monthly_salary_avg DESC
LIMIT 10;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'job_postings_fact';
