library(DBI)
library(RPostgres)
con <- dbConnect(Postgres(), 
                 host = 'postgres',
                 dbname = 'analytics',
                 user = 'analytics', 
                 password = 'analytics')
# Create and write a table using generic types
# dbWriteTable(con, 'transfusion_data', <your_data_table>)
dbWriteTable(con, 'transfusion_data', transfusion_example_table)
# Append more data
# dbAppendTable(con, 'transfusion_data', <your_data_additional_table>)
# Alternative method
# Create table
dbExecute(con, "CREATE TABLE transfusion_hgb_2021 (
               id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
               age_year double precision,
               time timestamp without time zone,
               fin double precision,
               unit_no text,
               volume double precision,
               donor_center text,
               mrn text,
               location text,
               hgb double precision,
               hours double precision,
               blood_group text,
               antibody text,
               level text)")
# Append data to table
dbAppendTable(con, 'transfusion_hgb_2021', transfusion_example_table)
# Read first 10 entries
