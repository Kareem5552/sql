WITH skills AS (
    SELECT 'python' AS skill
    UNION ALL
    SELECT 'sql'
    UNION ALL
    SELECT 'java'
),
 skill_lists AS (
    SELECT ARRAY_AGG(skill ORDER BY skill) AS skill_list
    FROM skills
)

SELECT skill_list
FROM skill_lists;



SELECT {'python' : 'programming', 'sql' : 'querying', 'java' : 'programming'} AS skill_struct;


WITH skill_struct AS (
    SELECT STRUCT_PACK(skill := 'python', category := 'programming') AS skill_info
    UNION ALL
    SELECT STRUCT_PACK(skill := 'sql', category := 'querying') AS skill_info
    UNION ALL
    SELECT STRUCT_PACK(skill := 'java', category := 'programming') AS skill_info
)

SELECT
skill_info.skill,
skill_info.category
FROM skill_struct;

WITH skills_tables AS (
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL
    SELECT 'sql', 'querying'
    UNION ALL
    SELECT 'java', 'programming'
)

SELECT
    STRUCT_PACK(skill := skills, category := types) AS skill_info
FROM skills_tables;

---Array of structs

WITH skills_tables AS (
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL
    SELECT 'sql', 'querying'
    UNION ALL
    SELECT 'java', 'programming'
),

array_struct AS (
    SELECT
        ARRAY_AGG(
            STRUCT_PACK(skill := skills, category := types)
            ORDER BY skills
        ) AS skill_struct_array
    FROM skills_tables
)

SELECT
    skill_struct_array[1].skill AS first_skill_struct,
    skill_struct_array[2].skill AS second_skill_struct
FROM array_struct;


--JSON


WITH raw_skill_json AS (
    SELECT
        '{"skill": "python", "type": "programming"}'::JSON AS skill_json
)
SELECT
    STRUCT_PACK(
        skill := JSON_EXTRACT_STRING(skill_json, '$.skill')
    )
FROM raw_skill_json;




