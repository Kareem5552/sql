SELECT 

EXTRACT(YEAR FROM job_posted_date) AS posted_year,
EXTRACT(MONTH FROM job_posted_date) AS posted_month,
COUNT(job_id) AS num_jobs

FROM job_postings_fact
WHERE job_posted_date IS NOT NULL AND job_title_short ='Data Engineer'
GROUP BY posted_year, posted_month
ORDER BY posted_year DESC, posted_month DESC
LIMIT 10;



SELECT 
DATE_TRUNC('month', job_posted_date) AS job_posted_month,
COUNT(job_id) AS job_count,
EXTRACT(month FROM job_posted_date) AS posted_month,
EXTRACT(year FROM job_posted_date) AS posted_year

FROM job_postings_fact
WHERE job_title_short = 'Data Engineer' AND EXTRACT(year FROM job_posted_date) = 2023
GROUP BY DATE_TRUNC('month', job_posted_date),EXTRACT(month FROM job_posted_date),
EXTRACT(year FROM job_posted_date)
LIMIT 10;



SELECT 
job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'Europe/Paris' AS job_posted_date_etc
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer' 
ORDER BY job_posted_date_etc DESC
LIMIT 10;


SELECT
EXTRACT (HOUR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST') AS job_posted_hour,
COUNT (job_id)
FROM job_postings_fact
WHERE
job_location LIKE 'New York, NY'
GROUP BY
EXTRACT(HOUR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST')
ORDER BY
job_posted_hour;