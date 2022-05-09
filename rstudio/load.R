library(DBI)
library(RPostgres)
con <- dbConnect(Postgres(), 
                 host = 'postgres',
                 dbname = 'analytics',
                 user = 'analytics', 
                 password = 'analytics')
# Create table
dbExecute(con, "CREATE TABLE transfusion_hgb_2021 (
               id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
               age_year integer,
               time timestamp without time zone,
               fin bigint,
               unit_no text,
               volume integer,
               donor_center text,
               mrn bigint,
               location text,
               hgb numeric,
               hours numeric,
               blood_group text,
               antibody text,
               level text)")
# List tables
dbListTables(con)
# Read tables
dbReadTable(con, "transfusion_hgb_2021")
# Append table
dbAppendTable(con, 'transfusion_hgb_2021', transfusion_example_table)
# Read first 10 entries
dbGetQuery(con, "SELECT * FROM transfusion_hgb_2021 LIMIT 10")
# Create and write a table using generic types
dbWriteTable(con, 'transfusion_eee', <your_table_name_here>)
