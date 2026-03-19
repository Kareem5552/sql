SELECT
COUNT(sjd.job_id),
sjd.job_id
FROM skills_job_dim AS sjd
WHERE EXISTS (
    SELECT 1
    FROM skills_dim AS sd1
    WHERE sd1.skills = 'python'
    AND sd1.skill_id = sjd.skill_id
) 
AND 
EXISTS(
     SELECT 1
    FROM skills_dim AS sd1
    WHERE sd1.skills = 'sql'
    AND sd1.skill_id = sjd.skill_id
)
GROUP BY sjd.job_id;

SELECT 
sjd.job_id,
COUNT (DISTINCT sd.skills ) AS distinct_skills
FROM skills_job_dim AS sjd
JOIN skills_dim sd ON
sjd.skill_id = sd.skill_id
GROUP BY sjd.job_id
HAVING COUNT (DISTINCT sd.skills ) > 3

ORDER BY sjd.job_id;


WITH sql_jobs AS (
    SELECT 
    sjd.job_id,
    sjd.skill_id AS skill_id,
    sd.skills AS skill
    FROM 
skills_job_dim AS sjd
JOIN skills_dim AS sd ON
sjd.skill_id = sd.skill_id
WHERE EXISTS(
    SELECT 1
    FROM skills_job_dim AS sd1
    JOIN skills_dim AS sd2 ON
    sd1.skill_id = sd2.skill_id
    WHERE sd2.skills = 'sql' AND sd1.job_id = sjd.job_id
   
)
)
SELECT 
DISTINCT jpf.job_id,
jpf.job_title_short,
jpf.job_location,
jpf.salary_year_avg,
sj.skill_id,
sj.skill
FROM
job_postings_fact AS jpf
JOIN sql_jobs AS sj 
ON jpf.job_id = sj.job_id
WHERE jpf.salary_year_avg IS NOT NULL AND jpf.job_location IS NOT NULL
ORDER BY jpf.salary_year_avg DESC 
LIMIT 100;


---Count how many skills each job needs (per job)”

WITH skills_per_job AS (
  SELECT
  sjd.job_id,

  COUNT(sd.skills) AS skill_count
  FROM skills_job_dim AS sjd
  JOIN skills_dim sd 
  ON sjd.skill_id = sd.skill_id
  GROUP BY 
  sjd.job_id
)

SELECT 
* FROM skills_per_job
LIMIT 20;

---MOST COMMON SKILLS

WITH remote_skills AS (
    SELECT sd.skills, COUNT(sjd.job_id) AS job_count
    FROM job_postings_fact jpf
    JOIN skils_job_dim sjd ON jpf.job_id = sjd.job_id
    JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
    WHERE jpf.job_work_from_home = TRUE
    GROUP BY sde.skills
)
SELECT * FROM remote_skills
ORDER BY job_count DESC
LIMIT 10;

