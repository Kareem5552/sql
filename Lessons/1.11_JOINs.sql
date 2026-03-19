SELECT 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    cd.name AS company_name,
    cd.link_google AS company_link_google
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
ON jpf.company_id = cd.company_id

LIMIT 10;

SELECT * FROM company_dim
LIMIT 10;

SELECT 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    cd.name AS company_name,
    cd.link_google AS company_link_google
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
ON jpf.company_id = cd.company_id
LIMIT 10;

SELECT 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    cd.name AS company_name,
    cd.link_google AS company_link_google
FROM job_postings_fact AS jpf
FULL JOIN company_dim AS cd
ON jpf.company_id = cd.company_id
LIMIT 10;

SELECT * 
FROM skills_job_dim
LIMIT 10;

SELECT
 jpf.job_id,
    jpf.job_title_short,
    sjd.skill_id,
    sd.skills 
FROM job_postings_fact AS jpf
JOIN skills_job_dim AS sjd
ON jpf.job_id = sjd.job_id
JOIN skills_dim AS sd
ON sjd.skill_id = sd.skill_id;
LIMIT 10;

SELECT
cd.name AS company_name,
COUNT(jpf.job_id) AS posting_count
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
ON jpf.company_id = cd.company_id
WHERE jpf.job_country = 'United States'
GROUP BY cd.name
HAVING COUNT(jpf.job_id) > 3000
ORDER BY posting_count DESC
LIMIT 10;

---Exercises 

SELECT 
jpf.job_title ,
jpf.salary_year_avg,
cd.name ,
sjd.skill_id ,
sd.skills
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
ON jpf.company_id = cd.company_id
LEFT JOIN skills_job_dim AS sjd
ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
ON sjd.skill_id = sd.skills
WHERE jpf.salary_year_avg > 10000 AND sd.skills = 'Python'
ORDER BY jpf.salary_year_avg DESC
LIMIT 10;

SELECT 
job_title_short,
count(job_title_short),
job_work_from_home
FROM job_postings_fact
GROUP BY 
job_title_short,
job_work_from_home
HAVING job_work_from_home = 'True'
ORDER BY count(job_title_short) DESC
LIMIT 5;

SELECT 
sd.skills AS skill,
count(jpf.job_id) AS job_demand,
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd 
ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
ON sjd.skill_id = sd.skill_id
WHERE job_title_short = 'Data Engineer' AND jpf.job_work_from_home = True
GROUP BY jpf.job_title_short,
sjd.skill_id,
sd.skills
ORDER BY count(jpf.job_id) DESC 
LIMIT 10;

