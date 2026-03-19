
-- Environment: DuckDB (adjust as needed)  
-- Purpose: maintain a snapshot of priority jobs with soft-delete and reactivation logic

WITH src AS (
    SELECT
        jpf.job_id,
        jpf.job_title_short,
        r.priority_lvl
    FROM data_jobs.job_postings_fact AS jpf
    JOIN staging.priority_roles AS r
        ON jpf.job_title_short = r.role_name
),
-- capture a single timestamp for the merge so all rows share the same value

ts AS (
    SELECT CURRENT_TIMESTAMP AS now_ts
)

MERGE INTO main.priority_jobs_snapshot AS tgt
USING src
ON tgt.job_id = src.job_id

-- 1. REACTIVATION: was previously soft-deleted and now reappears
WHEN MATCHED AND tgt.is_active = FALSE THEN
    UPDATE SET
        is_active = TRUE,
        deactivated_at = NULL,
        updated_at = ts.now_ts

-- 2. BUSINESS UPDATE: priority level has changed while active
WHEN MATCHED AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl THEN
    UPDATE SET
        priority_lvl = src.priority_lvl,
        updated_at = ts.now_ts

-- 3. NEW JOB: insert fresh record
WHEN NOT MATCHED THEN
    INSERT (job_id, job_title_short, priority_lvl, is_active, updated_at)
    VALUES (src.job_id, src.job_title_short, src.priority_lvl, TRUE, ts.now_ts)

-- 4. SOFT DELETE: previously active but missing from source today
WHEN NOT MATCHED BY SOURCE AND tgt.is_active = TRUE THEN
    UPDATE SET
        is_active = FALSE,
        deactivated_at = ts.now_ts,
        updated_at = ts.now_ts;

-- quick sanity check
SELECT
    job_title_short,
    is_active
FROM main.priority_jobs_snapshot
GROUP BY job_title_short, is_active
ORDER BY is_active DESC, job_title_short;
