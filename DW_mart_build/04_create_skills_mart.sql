-- Step 4: Create Skills Demand Mart
DROP SCHEMA IF EXISTS skills_mart CASCADE;
CREATE SCHEMA IF NOT EXISTS skills_mart;

-------------------------------------------------------
-- 1. Create and Load dim_skills
-------------------------------------------------------
CREATE TABLE skills_mart.dim_skills (
    skill_id INTEGER PRIMARY KEY,
    skills VARCHAR,
    type VARCHAR
);

INSERT INTO skills_mart.dim_skills (skill_id, skills, type)
SELECT
    skill_id,
    skills,
    type
FROM skills_dim;

-------------------------------------------------------
-- 2. Create and Load dim_date_month
-------------------------------------------------------
CREATE TABLE skills_mart.dim_date_month (
    month_start_date DATE PRIMARY KEY,
    year INTEGER,
    month INTEGER,
    quarter INTEGER,
    quarter_name VARCHAR,
    year_quarter VARCHAR
);

INSERT INTO skills_mart.dim_date_month
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(QUARTER FROM job_posted_date) AS quarter,
    'Q' || '-' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS quarter_name,
    EXTRACT(YEAR FROM job_posted_date)::VARCHAR || '-Q' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS year_quarter
FROM job_postings_fact
ORDER BY month_start_date;

-------------------------------------------------------
-- 3. Create and Load fact_skill_demand_monthly
-------------------------------------------------------
CREATE TABLE skills_mart.fact_skill_demand_monthly (
    skill_id INTEGER,
    month_start_date DATE,
    job_title_short VARCHAR,
    posting_count INTEGER,
    remote_posting_count INTEGER,
    health_insurance_posting_count INTEGER,
    no_degree_mentioned_posting_count INTEGER,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (skill_id) REFERENCES skills_mart.dim_skills (skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skills_mart.dim_date_month (month_start_date)
);

INSERT INTO skills_mart.fact_skill_demand_monthly
WITH job_postings_prep AS (
    SELECT
        sjd.skill_id,
        DATE_TRUNC('month', jpf.job_posted_date) AS month_start_date,
        jpf.job_title_short,
        CASE WHEN jpf.job_work_from_home = TRUE THEN 1 ELSE 0 END AS is_remote,
        CASE WHEN jpf.job_health_insurance = TRUE THEN 1 ELSE 0 END AS has_health_insurance,
        CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree_mentioned
    FROM job_postings_fact jpf
    INNER JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
)
SELECT
    skill_id,
    month_start_date,
    job_title_short,
    COUNT(*) AS posting_count,
    SUM(is_remote) AS remote_posting_count,
    SUM(has_health_insurance) AS health_insurance_posting_count,
    SUM(no_degree_mentioned) AS no_degree_mentioned_posting_count
FROM job_postings_prep
GROUP BY ALL
ORDER BY month_start_date, skill_id, job_title_short;

SELECT 'skill_dimension table' AS table_name, COUNT(*) AS record_count FROM skills_mart.dim_skills
UNION ALL
SELECT 'date_month_dimension', COUNT(*) FROM skills_mart.dim_date_month
UNION ALL
SELECT 'fact_skill_demand_monthly', COUNT(*) FROM skills_mart.fact_skill_demand_monthly;

SELECT '=== dim_skills sample ===' AS info;
SELECT * FROM skills_mart.dim_skills 
LIMIT 5;

SELECT '=== dim_date_month sample ===' AS info;
SELECT * FROM skills_mart.dim_date_month
LIMIT 5;

SELECT '=== fact_skill_demand_monthly sample ===' AS info;
SELECT * FROM skills_mart.fact_skill_demand_monthly
LIMIT 5;

