DROP DATABASE IF EXISTS jobs_mart;
CREATE DATABASE IF NOT EXISTS jobs_mart;

SHOW DATABASES;  

-- DROP DATABASE IF EXISTS jobs_mart;

SELECT *
FROM information_schema.schemata;

-- Fully qualify the schema creation
DROP SCHEMA IF EXISTS jobs_mart.staging;
CREATE SCHEMA IF NOT EXISTS jobs_mart.staging;

-- Fully qualify the table creation
DROP TABLE IF EXISTS jobs_mart.staging.preferred_roles;
CREATE TABLE IF NOT EXISTS jobs_mart.staging.preferred_roles (
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR
);

-- Verify the table exists
SELECT * FROM information_schema.tables
WHERE table_catalog = 'jobs_mart';


SELECT schema_name 
FROM information_schema.schemata 
WHERE catalog_name = 'jobs_mart';

SELECT table_schema, table_name 
FROM information_schema.tables 
WHERE table_catalog = 'jobs_mart';

INSERT INTO staging.preferred_roles(role_id,role_name)
VALUES 
    (1,'Data Engineer'),
    (2,'Senior Data Engineer'),
    (3,'Software Engineer');


ALTER TABLE staging.preferred_roles
ADD COLUMN preferred_roles BOOLEAN;

UPDATE staging.preferred_roles
SET preferred_roles = TRUE
where role_id = 1 or role_id = 2;

UPDATE staging.preferred_roles
SET preferred_roles = FALSE
where role_id = 3;

ALTER TABLE staging.preferred_roles
RENAME TO priority_roles;

SELECT * 
FROM 
staging.priority_roles;

ALTER TABLE staging.priority_roles
RENAME COLUMN preferred_roles TO priority_lvl;


ALTER TABLE staging.priority_roles
ALTER COLUMN priority_lvl TYPE INT;

UPDATE staging.priority_roles
SET priority_lvl = 3
WHERE role_id = 3;
