
-- =========================
-- RESET SCHEMA
-- =========================
DROP SCHEMA IF EXISTS company_mart CASCADE;
CREATE SCHEMA company_mart;

--------------------------------------------------
-- 1) DIM: COMPANY
--------------------------------------------------
CREATE TABLE company_mart.dim_company (
    company_id INTEGER PRIMARY KEY,
    company_name VARCHAR
);

INSERT INTO company_mart.dim_company (company_id, company_name)
SELECT
    company_id,
    name
FROM company_dim
WHERE company_id IS NOT NULL;

--------------------------------------------------
-- 2) DIM: JOB TITLE SHORT
--------------------------------------------------
CREATE TABLE company_mart.dim_job_title_short (
    job_title_short_id INTEGER PRIMARY KEY,
    job_title_short VARCHAR UNIQUE
);

INSERT INTO company_mart.dim_job_title_short (job_title_short_id, job_title_short)
SELECT 
    ROW_NUMBER() OVER (ORDER BY job_title_short) AS job_title_short_id,
    job_title_short
FROM (
    SELECT DISTINCT job_title_short
    FROM job_postings_fact
    WHERE job_title_short IS NOT NULL
) t;

--------------------------------------------------
-- 3) DIM: JOB TITLE
--------------------------------------------------
CREATE TABLE company_mart.dim_job_title (
    job_title_id INTEGER PRIMARY KEY,
    job_title VARCHAR UNIQUE
);

INSERT INTO company_mart.dim_job_title (job_title_id, job_title)
SELECT 
    ROW_NUMBER() OVER (ORDER BY job_title) AS job_title_id,
    job_title
FROM (
    SELECT DISTINCT job_title
    FROM job_postings_fact
    WHERE job_title IS NOT NULL
) t;

--------------------------------------------------
-- 4) DIM: LOCATION
--------------------------------------------------
CREATE TABLE company_mart.dim_location (
    location_id INTEGER PRIMARY KEY,
    job_country VARCHAR,
    job_location VARCHAR
);

INSERT INTO company_mart.dim_location (location_id, job_country, job_location)
SELECT 
    ROW_NUMBER() OVER (ORDER BY job_country, job_location) AS location_id,
    job_country,
    job_location
FROM (
    SELECT DISTINCT
        job_country,
        job_location
    FROM job_postings_fact
    WHERE job_country IS NOT NULL
      AND job_location IS NOT NULL
) t;

--------------------------------------------------
-- 5) DIM: DATE (MONTH LEVEL)
--------------------------------------------------
CREATE TABLE company_mart.dim_date_month (
    month_start_date DATE PRIMARY KEY,
    year INTEGER,
    month INTEGER
);

INSERT INTO company_mart.dim_date_month (month_start_date, year, month)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date)::DATE,
    EXTRACT(YEAR FROM job_posted_date),
    EXTRACT(MONTH FROM job_posted_date)
FROM job_postings_fact
WHERE job_posted_date IS NOT NULL;

--------------------------------------------------
-- 6) BRIDGE: COMPANY ↔ LOCATION
--------------------------------------------------
CREATE TABLE company_mart.bridge_company_location (
    company_id INTEGER,
    location_id INTEGER,
    PRIMARY KEY (company_id, location_id),
    FOREIGN KEY (company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (location_id) REFERENCES company_mart.dim_location(location_id)
);

INSERT INTO company_mart.bridge_company_location (company_id, location_id)
SELECT DISTINCT
    jpf.company_id,
    loc.location_id
FROM job_postings_fact jpf
JOIN company_mart.dim_location loc
    ON jpf.job_country = loc.job_country
   AND jpf.job_location = loc.job_location
WHERE jpf.company_id IS NOT NULL;

--------------------------------------------------
-- 7) BRIDGE: JOB TITLE ↔ JOB TITLE SHORT
--------------------------------------------------
CREATE TABLE company_mart.bridge_job_title (
    job_title_short_id INTEGER,
    job_title_id INTEGER,
    PRIMARY KEY (job_title_short_id, job_title_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (job_title_id) REFERENCES company_mart.dim_job_title(job_title_id)
);

INSERT INTO company_mart.bridge_job_title (job_title_short_id, job_title_id)
SELECT DISTINCT
    djs.job_title_short_id,
    djt.job_title_id
FROM job_postings_fact jpf
JOIN company_mart.dim_job_title_short djs
    ON jpf.job_title_short = djs.job_title_short
JOIN company_mart.dim_job_title djt
    ON jpf.job_title = djt.job_title
WHERE jpf.job_title_short IS NOT NULL
  AND jpf.job_title IS NOT NULL;

--------------------------------------------------
-- 8) FACT TABLE
--------------------------------------------------
CREATE TABLE company_mart.fact_company_hiring_monthly (
    company_id INTEGER,
    job_title_short_id INTEGER,
    job_country VARCHAR,
    month_start_date DATE,

    postings_count INTEGER,
    median_salary_year DOUBLE PRECISION,
    min_salary_year DOUBLE PRECISION,
    max_salary_year DOUBLE PRECISION,
    remote_share DOUBLE PRECISION,
    health_insurance_share DOUBLE PRECISION,
    no_degree_mention_share DOUBLE PRECISION,

    PRIMARY KEY (company_id, job_title_short_id, job_country, month_start_date),

    FOREIGN KEY (company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (month_start_date) REFERENCES company_mart.dim_date_month(month_start_date)
);

INSERT INTO company_mart.fact_company_hiring_monthly
SELECT
    jpf.company_id,
    djs.job_title_short_id,
    jpf.job_country,
    DATE_TRUNC('month', jpf.job_posted_date)::DATE,

    COUNT(*) AS postings_count,

    MEDIAN(jpf.salary_year_avg) AS median_salary_year,
    MIN(jpf.salary_year_avg) AS min_salary_year,
    MAX(jpf.salary_year_avg) AS max_salary_year,

    AVG(CASE WHEN jpf.job_work_from_home THEN 1.0 ELSE 0.0 END) AS remote_share,
    AVG(CASE WHEN jpf.job_health_insurance THEN 1.0 ELSE 0.0 END) AS health_insurance_share,
    AVG(CASE WHEN jpf.job_no_degree_mention THEN 1.0 ELSE 0.0 END) AS no_degree_mention_share

FROM job_postings_fact jpf
JOIN company_mart.dim_job_title_short djs
    ON jpf.job_title_short = djs.job_title_short

WHERE jpf.company_id IS NOT NULL
  AND jpf.job_posted_date IS NOT NULL
  AND jpf.job_country IS NOT NULL

GROUP BY
    jpf.company_id,
    djs.job_title_short_id,
    jpf.job_country,
    DATE_TRUNC('month', jpf.job_posted_date);


-- =========================
-- TABLE COUNTS (VALIDATION)
-- =========================

SELECT 'Company Dimension' AS table_name, COUNT(*) AS record_count 
FROM company_mart.dim_company

UNION ALL
SELECT 'Job Title Short Dimension', COUNT(*) 
FROM company_mart.dim_job_title_short

UNION ALL
SELECT 'Job Title Dimension', COUNT(*) 
FROM company_mart.dim_job_title

UNION ALL
SELECT 'Location Dimension', COUNT(*) 
FROM company_mart.dim_location

UNION ALL
SELECT 'Date Month Dimension', COUNT(*) 
FROM company_mart.dim_date_month

UNION ALL
SELECT 'Company Location Bridge', COUNT(*) 
FROM company_mart.bridge_company_location

UNION ALL
SELECT 'Job Title Bridge', COUNT(*) 
FROM company_mart.bridge_job_title

UNION ALL
SELECT 'Company Hiring Fact', COUNT(*) 
FROM company_mart.fact_company_hiring_monthly;


-- =========================
-- DIMENSION SAMPLES
-- =========================

SELECT '=== Company Dimension Sample ===' AS info;
SELECT * FROM company_mart.dim_company LIMIT 5;

SELECT '=== Job Title Short Dimension Sample ===' AS info;
SELECT * FROM company_mart.dim_job_title_short LIMIT 10;

SELECT '=== Job Title Dimension Sample ===' AS info;
SELECT * FROM company_mart.dim_job_title LIMIT 10;

SELECT '=== Location Dimension Sample ===' AS info;
SELECT * FROM company_mart.dim_location LIMIT 10;

SELECT '=== Date Month Dimension Sample ===' AS info;
SELECT * FROM company_mart.dim_date_month 
ORDER BY month_start_date DESC 
LIMIT 10;


-- =========================
-- BRIDGE SAMPLES
-- =========================

SELECT '=== Company Location Bridge Sample ===' AS info;

SELECT 
    bcl.company_id,
    dc.company_name,
    bcl.location_id,
    dl.job_country,
    dl.job_location
FROM company_mart.bridge_company_location bcl
JOIN company_mart.dim_company dc 
    ON bcl.company_id = dc.company_id
JOIN company_mart.dim_location dl 
    ON bcl.location_id = dl.location_id
LIMIT 10;


SELECT '=== Job Title Bridge Sample ===' AS info;

SELECT 
    bjt.job_title_short_id,
    djs.job_title_short,
    bjt.job_title_id,
    djt.job_title
FROM company_mart.bridge_job_title bjt
JOIN company_mart.dim_job_title_short djs 
    ON bjt.job_title_short_id = djs.job_title_short_id
JOIN company_mart.dim_job_title djt 
    ON bjt.job_title_id = djt.job_title_id
WHERE djs.job_title_short = 'Data Engineer'
LIMIT 10;


-- =========================
-- FACT TABLE SAMPLE
-- =========================

SELECT '=== Company Hiring Fact Sample ===' AS info;

SELECT 
    fchm.company_id,
    dc.company_name,
    djs.job_title_short,
    fchm.job_country,
    fchm.month_start_date,
    fchm.postings_count,
    fchm.median_salary_year
FROM company_mart.fact_company_hiring_monthly fchm
JOIN company_mart.dim_company dc 
    ON fchm.company_id = dc.company_id
JOIN company_mart.dim_job_title_short djs 
    ON fchm.job_title_short_id = djs.job_title_short_id
ORDER BY fchm.postings_count DESC, fchm.median_salary_year DESC
LIMIT 10;