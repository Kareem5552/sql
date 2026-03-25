-- step 3 : create flat mart table

DROP SCHEMA IF EXISTS flat_mart CASCADE;

SELECT '=== loading flat_mart schema and table ===' AS info_message;
CREATE SCHEMA flat_mart;

DROP TABLE IF EXISTS flat_mart.job_postings_flat;

CREATE TABLE flat_mart.job_postings_flat AS

SELECT 
    jpf.job_id,
    jpf.company_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    cd.name AS company_name,
    ARRAY_AGG(
        STRUCT_PACK(skill := sd.skills, type := sd.type)
    ) AS skills_and_types

FROM job_postings_fact AS jpf

LEFT JOIN company_dim AS cd ON jpf.company_id = cd.company_id

LEFT JOIN skills_job_dim AS sjd ON jpf.job_id = sjd.job_id

LEFT JOIN skills_dim AS sd ON sjd.skill_id = sd.skill_id

GROUP BY ALL;

SELECT 'flat_mart job postings' AS table_name, COUNT(*) AS record_count FROM flat_mart.job_postings_flat;

SELECT '=== flat_mart job postings sample ===' AS info;
SELECT * FROM flat_mart.job_postings_flat LIMIT 5;
