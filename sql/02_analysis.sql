-- 02_analysis.sql
-- PostgreSQL. Five questions, same answers as the Excel pivot tables and the Power BI dashboard.
-- A shipment is "late" when it was delivered after the scheduled delivery date.

-- Q1. Overall: how many shipments, how many late, what share?
SELECT COUNT(*) AS total_shipments,
       SUM(CASE WHEN delivered_date > scheduled_date THEN 1 ELSE 0 END) AS late_shipments,
       ROUND(100.0 * SUM(CASE WHEN delivered_date > scheduled_date THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_late
FROM shipments;
-- 10324 | 1186 | 11.49

-- Q2. Late share by fulfilment channel
SELECT fulfill_via,
       COUNT(*) AS shipments,
       ROUND(100.0 * SUM(CASE WHEN delivered_date > scheduled_date THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_late
FROM shipments
GROUP BY fulfill_via
ORDER BY pct_late DESC;
-- From RDC 17.15 | Direct Drop 5.26

-- Q3. Is it the transport mode? Compare channels within the same mode
SELECT shipment_mode,
       fulfill_via,
       COUNT(*) AS shipments,
       ROUND(100.0 * SUM(CASE WHEN delivered_date > scheduled_date THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_late
FROM shipments
GROUP BY shipment_mode, fulfill_via
ORDER BY shipment_mode, fulfill_via;
-- Truck: From RDC 23.25 vs Direct Drop 1.20 | Air: From RDC 15.91 vs Direct Drop 5.10

-- Q4. Worst countries, only those with at least 200 shipments (small samples excluded)
SELECT country,
       COUNT(*) AS shipments,
       ROUND(100.0 * SUM(CASE WHEN delivered_date > scheduled_date THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_late
FROM shipments
GROUP BY country
HAVING COUNT(*) >= 200
ORDER BY pct_late DESC;
-- Congo, DRC 24.92 | Mozambique 18.38 | Zambia 15.81 | Zimbabwe 14.31 | Tanzania 12.72 ...

-- Q5. Trend: late share by scheduled year and channel
SELECT EXTRACT(YEAR FROM scheduled_date) AS year,
       fulfill_via,
       COUNT(*) AS shipments,
       ROUND(100.0 * SUM(CASE WHEN delivered_date > scheduled_date THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_late
FROM shipments
GROUP BY EXTRACT(YEAR FROM scheduled_date), fulfill_via
ORDER BY year, fulfill_via;
-- From RDC: 0.97 (2008) -> 37.24 (2011), then 27-35 % from 2013 to 2015
