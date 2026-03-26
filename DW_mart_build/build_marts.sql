-- step 1 : create star schema tables for warehouse

.read 01_create_warehouse_schema.sql

-- step 2 : load data from CSV files to tables

.read 02_load_schema_dw.sql

--- step 3 : create flat mart table

.read 03_create_flat_mart.sql

--- step 4 : create skills mart tables

.read 04_create_skills_mart.sql

