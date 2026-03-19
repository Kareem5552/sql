SELECT UNNEST([1,1,1,4])
EXCEPT ALL
SELECT UNNEST([1,1,2,2]);

CREATE TEMP TABLE jobs_23 AS
SELECT * EXCLUDE (job_id,job_posted_date) 
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2023;


CREATE TEMP TABLE jobs_24 AS
SELECT * EXCLUDE (job_id,job_posted_date) 
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2024;


SELECT 
'jobs_23' AS table_name,
COUNT(*) FROM jobs_23 AS job_count
UNION ALL
SELECT 'jobs_24' AS table_name,
COUNT(*) FROM jobs_24 AS job_count;

SELECT * FROM jobs_23
UNION ALL
SELECT * FROM jobs_24;

SELECT * FROM jobs_23
EXCEPT ALL
SELECT * FROM jobs_24;

