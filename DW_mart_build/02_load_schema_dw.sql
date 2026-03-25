-- step 2 : load data from CSV files to tables

-- loading company_dim
SELECT '=== loading company_dim table from company_dim.csv ===' AS info_message;
INSERT INTO company_dim (company_id, name)
SELECT company_id, name
FROM read_csv('company_dim.csv', AUTO_DETECT=true);

-- loading skills_dim
SELECT '=== loading skills_dim table from skills_dim.csv ===' AS info_message;
INSERT INTO skills_dim (skill_id, skills, type)
SELECT skill_id, skills, type
FROM read_csv('skills_dim.csv', AUTO_DETECT=true);

-- loading job_postings_fact
SELECT '=== loading job_postings_fact table from job_postings_fact.csv ===' AS info_message;
INSERT INTO job_postings_fact (job_id, company_id, job_title_short, job_title, job_location, job_via, job_schedule_type,
job_work_from_home, search_location, job_posted_date, job_no_degree_mention, job_health_insurance, job_country,
salary_rate, salary_year_avg, salary_hour_avg)
SELECT job_id, company_id, job_title_short, job_title, job_location, job_via, job_schedule_type,
job_work_from_home, search_location, job_posted_date, job_no_degree_mention, job_health_insurance,
job_country, salary_rate, salary_year_avg, salary_hour_avg
FROM read_csv('job_postings_fact.csv', AUTO_DETECT=true);

-- loading skills_job_dim
SELECT '=== loading skills_job_dim table from skills_job_dim.csv ===' AS info_message;
INSERT INTO skills_job_dim (job_id, skill_id)
SELECT job_id, skill_id
FROM read_csv('skills_job_dim.csv', AUTO_DETECT=true);

-- row counts
SELECT 'Company Dim' AS table_name, COUNT(*) AS record_count FROM company_dim
UNION ALL
SELECT 'Skills Dim', COUNT(*) FROM skills_dim
UNION ALL
SELECT 'Job Postings Fact', COUNT(*) FROM job_postings_fact
UNION ALL
SELECT 'Skills Job Dim', COUNT(*) FROM skills_job_dim;

-- samples
SELECT '=== Company Dimension Sample ===' AS info;
SELECT * FROM company_dim LIMIT 5;

SELECT '=== Skills Dimension Sample ===' AS info;
SELECT * FROM skills_dim LIMIT 5;

SELECT '=== Job Postings Fact Sample ===' AS info;
SELECT * FROM job_postings_fact LIMIT 5;

SELECT '=== Skills Job Bridge Sample ===' AS info;
SELECT * FROM skills_job_dim LIMIT 5;