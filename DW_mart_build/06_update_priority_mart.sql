-- Step 6: Update Priority Roles Mart

-------------------------------------------------------
-- 1. Simulate Business Updating Priority Roles
-------------------------------------------------------
-- Update existing role
UPDATE priority_mart.priority_roles
SET priority_lvl = 1
WHERE role_name = 'Data Engineer';

-- Insert new role
INSERT INTO priority_mart.priority_roles (role_id, role_name, priority_lvl)
VALUES (4, 'Data Scientist', 3);

-------------------------------------------------------
-- 2. Create Temp Source Table
-------------------------------------------------------
SELECT '=== Creating Temp Source Table ===' AS info;

CREATE OR REPLACE TEMP TABLE source_priority_jobs AS
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
-- 3. Batch Update Priority Jobs Snapshot (MERGE)
-------------------------------------------------------
SELECT '=== Batch Updating Priority Jobs Snapshot ===' AS info;

MERGE INTO priority_mart.priority_jobs_snapshot AS target
USING source_priority_jobs AS src
ON target.job_id = src.job_id
-- If a match is found and the priority level has changed, update it
WHEN MATCHED AND target.priority_lvl IS DISTINCT FROM src.priority_lvl THEN
    UPDATE SET 
        priority_lvl = src.priority_lvl,
        updated_at = src.updated_at
-- If the job is in the source but not the target, insert it
WHEN NOT MATCHED THEN
    INSERT (job_id, job_title_short, company_name, job_posted_date, salary_year_avg, priority_lvl, updated_at)
    VALUES (src.job_id, src.job_title_short, src.company_name, src.job_posted_date, src.salary_year_avg, src.priority_lvl, src.updated_at)
-- If the job is in the target but no longer in the source, delete it
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;

-------------------------------------------------------
-- 4. Final Check Query
-------------------------------------------------------
SELECT '=== Data Validation After Update ===' AS info;

SELECT * FROM priority_mart.priority_roles;

SELECT
    job_title_short,
    COUNT(job_id) AS job_count,
    MIN(priority_lvl) AS priority_lvl,
    MIN(updated_at) AS updated_at
FROM priority_mart.priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC;