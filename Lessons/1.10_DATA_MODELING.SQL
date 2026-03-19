SELECT
 job_id,
 job_title_short,
 salary_year_avg,
 company_id
 FROM
    job_postings_fact
LIMIT 10;

SELECT 
    company_id,
    name
FROM
    company_dim
LIMIT 10;

SELECT * 
FROM skills_dim
LIMIT 5;

SELECT *
FROM information_schema.columns
WHERE table_catalog = 'data_jobs';

DESCRIBE job_postings_fact;


SELECT 
    table_name, 
    column_name, 
    data_type
FROM 
    information_schema.columns
ORDER BY 
    table_name;

SELECT 
constraint_name, 
table_name, 
constraint_type 
FROM information_schema.table_constraints ;


SELECT constraint_name,unique_constraint_name
FROM 
information_schema.referential_constraints;

SELECT *
FROM information_schema.referential_constraints;



