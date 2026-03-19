-- ====================================
-- 1️⃣ Drop & Create Schemas
-- ====================================
DROP SCHEMA IF EXISTS tech_hiring_lab.staging CASCADE;
DROP SCHEMA IF EXISTS tech_hiring_lab.production CASCADE;
DROP SCHEMA IF EXISTS tech_hiring_lab.analytics CASCADE;

CREATE SCHEMA tech_hiring_lab.staging;
CREATE SCHEMA tech_hiring_lab.production;
CREATE SCHEMA tech_hiring_lab.analytics;

USE tech_hiring_lab;

-- ====================================
-- 2️⃣ Production Tables
-- ====================================
CREATE TABLE IF NOT EXISTS production.companies (
    company_id    INTEGER PRIMARY KEY,
    company_name  VARCHAR(50) NOT NULL UNIQUE,
    country       VARCHAR(50),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS production.employees (
    employee_id  INTEGER PRIMARY KEY,
    full_name    VARCHAR(50) NOT NULL,
    email        VARCHAR(100) NOT NULL UNIQUE,
    years_exp    INTEGER DEFAULT 0,
    salary       DECIMAL(10,2) CHECK (salary >= 30000),
    company_id   INTEGER NOT NULL REFERENCES production.companies(company_id)
);

-- ====================================
-- 3️⃣ Staging Tables
-- ====================================
CREATE TABLE IF NOT EXISTS staging.job_postings (
    job_id       INTEGER PRIMARY KEY,
    job_title    VARCHAR(100) NOT NULL,
    min_salary   DECIMAL(10,2),
    max_salary   DECIMAL(10,2),
    company_id   INTEGER NOT NULL REFERENCES production.companies(company_id)
);

-- ====================================
-- 4️⃣ Insert Data into Production
-- ====================================
INSERT INTO production.companies (company_id, company_name, country)
VALUES
    (1, 'TechCorp', 'USA'),
    (2, 'DataSolutions', 'UK'),
    (3, 'AI Innovators', 'Canada')
ON CONFLICT (company_id) DO NOTHING;

INSERT INTO production.employees (employee_id, full_name, email, years_exp, salary, company_id)
VALUES
    (1, 'Alice Johnson', 'alice.johnson@example.com', 5, 75000.00, 1),
    (2, 'Bob Smith', 'bob.smith@example.com', 1, 60000.00, 2),
    (3, 'Charlie Brown', 'charlie.brown@example.com', 1, 65000.00, 3),
    (4, 'David Lee', 'david.lee@example.com', 2, 70000.00, 1)
ON CONFLICT (employee_id) DO NOTHING;

-- ====================================
-- 5️⃣ Insert Data into Staging
-- ====================================
INSERT INTO staging.job_postings (job_id, job_title, min_salary, max_salary, company_id)
VALUES
    (1, 'Data Engineer', 60000, 90000, 1),
    (2, 'Software Engineer', 55000, 85000, 2),
    (3, 'AI Researcher', 70000, 120000, 3)
ON CONFLICT (job_id) DO NOTHING;

-- ====================================
-- 6️⃣ Check Table Schema
-- ====================================
SELECT table_schema, table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema IN ('production', 'staging');



SELECT DISTINCT
    job_title_short,
    salary_year_avg::INT, -- Cast here for clean display
    (SELECT AVG(salary_year_avg)::INT FROM job_postings_fact) AS global_average_salary
FROM 
    job_postings_fact
WHERE 
    salary_year_avg > (SELECT AVG(salary_year_avg) FROM job_postings_fact) -- No casting needed for the logic
ORDER BY 
    salary_year_avg DESC; -- No casting needed for ordering



SELECT 
job_title_short,
COUNT(company_id)
FROM 
job_postings_fact
GROUP BY
job_title_short
company_id
HAVING count(company_id) > 5;



SELECT 
    tgt.job_id,
FROM 
    job_postings_fact AS tgt
WHERE EXISTS (
    SELECT 1
    FROM skills_job_dim sub_src
    WHERE tgt.job_id = sub_src.job_id
)
ORDER BY 
    tgt.job_id
LIMIT 20;



SELECT
    job_id,
    company_id,
    salary_year_avg,
    AVG(salary_year_avg) AS salary_avg,
    (SELECT 
    AVG(salary_year_avg)AS overall_salary_avg,
   FROM job_postings_fact )
    
FROM job_postings_fact tgt
WHERE salary_year_avg > (
    SELECT AVG(salary_year_avg)
    FROM job_postings_fact sub
    WHERE sub.company_id = tgt.company_id
)

ORDER BY company_id, salary_year_avg DESC;



---CTE 
---calculate max salary per company , return the full job rows that match the max

WITH max_salary AS (
    SELECT
        company_id,
        MAX(salary_year_avg) AS max_company_salary
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
    GROUP BY company_id
)

SELECT tgt.*
FROM job_postings_fact tgt
JOIN max_salary ms
    ON tgt.company_id = ms.company_id
   AND tgt.salary_year_avg = ms.max_company_salary
ORDER BY tgt.company_id;


--Return companies where:

--They have jobs in job_postings_fact

--But NONE of their jobs have skills in skills_job_dim

--👉 This requires nested logic with NOT EXISTS

SELECT DISTINCT company_id
FROM job_postings_fact AS j
WHERE NOT EXISTS (
    SELECT 1
    FROM skills_job_dim AS s
    WHERE s.job_id = j.job_id
);



/*8️⃣ Skill Count Per Job (Only For Jobs With More Than 3 Skills)

Return:

job_id

number of skills

But only include jobs with more than 3 skills.

👉 Use a CTE.*/

WITH count_jobs AS (
    SELECT sjd.job_id,
           COUNT(sjd.skill_id) AS skill_count
    FROM skills_job_dim sjd
    GROUP BY sjd.job_id
    HAVING COUNT(sjd.skill_id) > 3
)
SELECT jpf.*, cj.skill_count
FROM job_postings_fact AS jpf

JOIN count_jobs AS cj
ON jpf.job_id = cj.job_id
WHERE jpf.salary_year_avg IS NOT NULL OR jpf.salary_hour_avg IS NOT NULL
ORDER BY cj.job_id



--9️⃣ Find Duplicate Skill Assignments

---Return job_id and skill_id where:

--The same skill is listed more than once for a job.

--- Use GROUP BY + HAVING in a subquery or CTE.



SELECT 
jpf.job_id ,
cj.skill_id
FROM job_postings_fact AS jpf
JOIN count_jobs AS cj 
ON jpf.job_id = cj.job_id;


WITH duplicate_skills AS (
    SELECT sjd.skill_id
    FROM skills_job_dim sjd
    GROUP BY sjd.skill_id
    HAVING COUNT(sjd.job_id) > 1
)
SELECT jpf.job_id,
       ds.skill_id,
       sd.skills
FROM job_postings_fact jpf
JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
JOIN duplicate_skills ds ON sjd.skill_id = ds.skill_id
JOIN skills_dim sd ON ds.skill_id = sd.skill_id
ORDER BY jpf.job_id, ds.skill_id
LIMIT 20;



  /*  🔟 Jobs That Have ALL Required Skills

Suppose required skills are:

SQL

Python

AWS

Return jobs that contain ALL 3 skills.

👉 You’ll need:

GROUP BY

HAVING COUNT
OR

Multiple EXISTS*/



    
  
WITH required_skills AS (
    SELECT sjd.job_id,
           sd.skills
    FROM skills_job_dim sjd
    JOIN skills_dim sd
      ON sjd.skill_id = sd.skill_id
    WHERE sd.skills IN ('sql', 'python', 'aws')
)

SELECT job_id
FROM required_skills
GROUP BY job_id
HAVING COUNT(skills) = 3;








SELECT 
COUNT(DISTINCT sjd.job_id) AS skill_count,
sd.skills
FROM skills_job_dim AS sjd
JOIN skills_dim sd ON
sjd.skill_id = sd.skill_id
GROUP BY sd.skills
ORDER BY skill_count DESC
LIMIT 3;

SELECT 
count(sjd.skill_d),
sd.skills,
sjd.job_id
FROM skills_job_dim AS sjd
WHERE EXISTS (
    SELECT 1
    FROM
    skills_dim AS sd1
    WHERE sd1.skills IN ['sql','python','aws']
    AND sjd.skill_id = sd1.skill_id
);


WITH