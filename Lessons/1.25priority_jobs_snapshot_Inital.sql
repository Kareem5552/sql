-- Initial Load: Creating the snapshot table for the first time
CREATE TABLE IF NOT EXISTS main.priority_jobs_snapshot AS 
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    r.priority_lvl,
    TRUE AS is_active,
    CURRENT_TIMESTAMP AS updated_at,    -- Set birth date for the records
    NULL::TIMESTAMP AS deactivated_at  -- Cast to ensure correct data type
FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id
INNER JOIN staging.priority_roles AS r
    ON jpf.job_title_short = r.role_name;

-- Verification
