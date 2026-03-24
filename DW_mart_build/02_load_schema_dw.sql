---step 2 : load data from CSV files to tables


SELECT '=== loading company_dim table from company_dim.csv ===' AS info_message;


INSERT INTO company_dim (company_id, name)
SELECT company_id, name
FROM read_csv('company_dim.csv', AUTO_DETECT=true);

SELECT '=== loading skills_dim table from skills_dim.csv ===' AS info_message;


INSERT INTO skills_dim (skill_id, skills, type)
SELECT skill_id, skills, type
FROM read_csv('skills_dim.csv', AUTO_DETECT=true);

SELECT '=== loading job_postings_fact table from job_postings_fact.csv ===' AS info_message;

INSERT INTO job_postings_fact (job_id, company_id, job_title_short, job_title, job_location, job_via, job_schedule_type,
job_work_from_home, search_location, job_posted_date, job_no_degree_mention, job_health_insurance, job_country,
salary_rate, salary_year_avg, salary_hour_avg)
SELECT job_id, company_id, job_title_short, job_title, job_location, job_via, job_schedule_type,
job_work_from_home, search_location, job_posted_date, job_no_degree_mention, job_health_insurance,
job_country, salary_rate, salary_year_avg, salary_hour_avg
FROM read_csv('job_postings_fact.csv', AUTO_DETECT=true);

SELECT '=== loading skills_job_dim table from skills_job_dim.csv ===' AS info_message;


INSERT INTO skills_job_dim (job_id, skill_id)
SELECT job_id, skill_id
FROM read_csv('skills_job_dim.csv', AUTO_DETECT=true);

