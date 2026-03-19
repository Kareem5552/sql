-- Describe the table (keeps intent from original file)
DESCRIBE data_jobs.job_postings_fact;

-- Select a clean, valid list of columns for inspection
DROP TABLE IF EXISTS staging.job_postings_flat;
CREATE TABLE IF NOT EXISTS staging.job_postings_flat AS
SELECT
	jpf.job_id,
	jpf.job_title_short,
	jpf.job_title,
	jpf.job_location,
	jpf.job_via,
	jpf.job_work_from_home,
	jpf.search_location,
	jpf.job_posted_date,
	jpf.job_no_degree_mention,
	jpf.job_health_insurance,
	jpf.job_country,
	jpf.salary_rate,
	jpf.salary_year_avg,
	jpf.salary_hour_avg ,
    cd.name AS company_name
FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd ON jpf.company_id = cd.company_id;


SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_catalog = 'data_jobs' AND table_name = 'job_postings_fact';

CREATE VIEW OR REPLACE staging.priority_jobs_flat_view AS
SELECT
jpf.*,
r.role_name,
r.priority_lvl

FROM staging.job_postings_flat AS jpf
JOIN staging.priority_roles AS r
ON jpf.job_title_short = r.role_name
WHERE r.priority_lvl = 1;

SELECT COUNT(*) AS priority_job_count,
job_title_short
AS priority_job_count
FROM staging.priority_jobs_flat_view
GROUP BY job_title_short
ORDER BY COUNT(*) DESC;
DROP TEMPORARY TABLE IF EXISTS staging.temp_senior;
/*CREATE TEMPORARY TABLE staging.temp_senior AS
SELECT * 
FROM staging.priority_jobs_flat_view
WHERE job_title_short = 'Senior Data Engineer';
*/

SELECT *
FROM temp_senior
LIMIT 5;

DELETE FROM staging.job_postings_flat
WHERE job_posted_date < '2024-01-01';

SELECT * FROM staging.job_postings_flat
WHERE job_posted_date < '2025-01-01';

