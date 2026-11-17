-- 01_create_table.sql
-- PostgreSQL. Creates the shipments table and loads the cleaned data.
-- Run from the repo root:  psql -d <your_database> -f sql/01_create_table.sql

DROP TABLE IF EXISTS shipments;

CREATE TABLE shipments (
    id              INTEGER PRIMARY KEY,
    country         TEXT    NOT NULL,
    fulfill_via     TEXT    NOT NULL,   -- 'Direct Drop' or 'From RDC'
    shipment_mode   TEXT    NOT NULL,   -- 'N/A' was replaced with 'Unknown' during cleaning
    scheduled_date  DATE    NOT NULL,
    delivered_date  DATE    NOT NULL
);

\copy shipments FROM 'data/shipments_clean.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

-- Data checks before any analysis
SELECT COUNT(*) AS total_rows FROM shipments;                                -- expected: 10324
SELECT COUNT(*) - COUNT(delivered_date) AS missing_delivery_date FROM shipments;  -- expected: 0
