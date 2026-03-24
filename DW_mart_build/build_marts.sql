--step 1 : create star schema tables for warehouse

.read 01_create_warehouse_schema.sql

--step 2 : load data from CSV files to tables

.read 02_load_schema_dw.sql