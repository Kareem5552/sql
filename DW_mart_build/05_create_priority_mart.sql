-- Step 5: Create Priority Roles Mart

DROP SCHEMA IF EXISTS priority_mart CASCADE;
CREATE SCHEMA priority_mart;

-------------------------------------------------------
-- 1. Create and Load priority_roles
-------------------------------------------------------
SELECT '=== Starting to Build Priority Mart ===' AS info;

CREATE TABLE priority_mart.priority_roles (
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR,
    priority_lvl INTEGER
);

-- Initial load: Only 3 roles!
INSERT INTO priority_mart.priority_roles (role_id, role_name, priority_lvl)
VALUES
    (1, 'Data Engineer', 2),
    (2, 'Senior Data Engineer', 1),
    (3, 'Software Engineer', 3);

-------------------------------------------------------
-- 2. Create and Load priority_jobs_snapshot (Initial)
-------------------------------------------------------
SELECT '=== Loading Snapshot for Priority Mart ===' AS info;

CREATE OR REPLACE TABLE priority_mart.priority_jobs_snapshot (
    job_id INTEGER,
    job_title_short VARCHAR,
    company_name VARCHAR,
    job_posted_date TIMESTAMP,
    salary_year_avg DOUBLE,
    priority_lvl INTEGER,
    updated_at TIMESTAMP
);

INSERT INTO priority_mart.priority_jobs_snapshot (
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at
)
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    r.priority_lvl,
    CURRENT_TIMESTAMP AS updated_at
FROM job_postings_fact jpf
LEFT JOIN company_dim cd ON jpf.company_id = cd.company_id
INNER JOIN priority_mart.priority_roles r ON jpf.job_title_short = r.role_name;

-------------------------------------------------------
-- 3. Data Validation
-------------------------------------------------------
SELECT * FROM priority_mart.priority_roles;

SELECT
    job_title_short,
    COUNT(job_id) AS job_count,
    MIN(priority_lvl) AS priority_lvl,
    MIN(updated_at) AS updated_at
FROM priority_mart.priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC;