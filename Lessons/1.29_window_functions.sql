SELECT 
job_id, 
job_title_short,
salary_hour_avg::DECIMAL(10,2),
AVG(salary_hour_avg) OVER(
    PARTITION BY job_title_short
) AS overall_salary_hour_avg
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
ORDER BY RANDOM()
LIMIT 20;

SELECT
job_id,
job_title_short,
company_id,
salary_hour_avg,
AVG(salary_hour_avg) OVER (
PARTITION BY job_title_short, company_id
)
FROM
job_postings_fact
WHERE
salary_hour_avg IS NOT NULL
ORDER BY
RANDOM()
LIMIT 10;

SELECT
job_id,
job_title_short,
company_id,
salary_hour_avg,
RANK() OVER (
ORDER BY salary_hour_avg DESC
) AS salary_rank
FROM
job_postings_fact
WHERE
salary_hour_avg IS NOT NULL
ORDER BY
salary_hour_avg DESC
LIMIT 10;


SELECT
job_posted_date,
job_title_short,
company_id,
salary_hour_avg,
AVG(salary_hour_avg) OVER (
PARTITION BY job_title_short,
ORDER BY job_posted_date DESC
) AS running_avg_salary
FROM
job_postings_fact
WHERE
salary_hour_avg IS NOT NULL
ORDER BY
job_posted_date DESC
LIMIT 10;


SELECT
    job_id,
    company_id,
    job_title_short,
    salary_hour_avg::DECIMAL(10,2),
    AVG(salary_hour_avg) OVER w AS avg_for_title_company,
    salary_hour_avg::DECIMAL(10,2) - (AVG(salary_hour_avg) OVER w) AS diff_from_avg

FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
WINDOW w AS (PARTITION BY job_title_short, company_id)
ORDER BY company_id 
LIMIT 10;


SELECT
    job_id,
    company_id,
    job_title_short,
    salary_hour_avg::DECIMAL(10,2),
    (AVG(salary_hour_avg) OVER w)::DECIMAL(10,2) AS avg_for_company,
    (salary_hour_avg - AVG(salary_hour_avg) OVER w)::DECIMAL(10,2) AS diff_from_avg
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
    AND (salary_hour_avg - AVG(salary_hour_avg) OVER w)::DECIMAL(10,2) > 50
WINDOW w AS (
    PARTITION BY company_id
    ORDER BY salary_hour_avg DESC
)
ORDER BY salary_hour_avg DESC
LIMIT 30;

SELECT * FROM(
    SELECT
        job_id,
        company_id,
        job_title_short,
        salary_hour_avg::DECIMAL(10,2) AS salary_hour_avg,
        (AVG(salary_hour_avg) OVER w)::DECIMAL(10,2) AS avg_for_company,
        (salary_hour_avg - AVG(salary_hour_avg) OVER w)::DECIMAL(10,2) AS diff_from_avg
    FROM job_postings_fact
    WHERE salary_hour_avg IS NOT NULL
    WINDOW w AS (
        PARTITION BY company_id, job_title_short
    )
) AS sub
WHERE diff_from_avg > -50

LIMIT 30;


SELECT
    job_id,
    job_title_short,
    job_posted_date,
    salary_hour_avg::DECIMAL(10,2),
    ROW_NUMBER() OVER (
        PARTITION BY job_title_short
        ORDER BY salary_hour_avg DESC
    ) AS posting_sequence  -- Always alias your window functions!
FROM job_postings_fact
WHERE job_posted_date IS NOT NULL
ORDER BY job_title_short, posting_sequence
LIMIT 20;

SELECT
    company_id, 
    job_title_short, 
    salary_year_avg::DECIMAL(10,2) AS salary_year_avg,
    DENSE_RANK() OVER (
        PARTITION BY job_title_short
        ORDER BY salary_year_avg DESC
    ) AS salary_rank
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY job_title_short, salary_rank
LIMIT 20;


WITH ranked_pay AS (
    SELECT 
        job_title_short,
        salary_year_avg,
        ROW_NUMBER() OVER(
            PARTITION BY job_title_short 
            ORDER BY salary_year_avg DESC
        ) AS top_rank
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
)
SELECT * FROM ranked_pay 
WHERE top_rank = 1;