-- 03_analysis_with_cte.sql
-- PostgreSQL. Same idea as 02, but the "late" flag is defined once in a CTE.
-- If the definition of "late" changes (for example, more than 7 days), only one line changes.

WITH flagged AS (
    SELECT *,
           CASE WHEN delivered_date > scheduled_date THEN 1 ELSE 0 END AS is_late
    FROM shipments
)
SELECT country,
       fulfill_via,
       COUNT(*) AS shipments,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2) AS pct_late
FROM flagged
WHERE country IN ('Congo, DRC', 'Mozambique', 'Zambia', 'Nigeria')
GROUP BY country, fulfill_via
ORDER BY country, fulfill_via;
-- Congo, DRC: From RDC 38.03 vs Direct Drop 1.67
-- Nigeria is the exception: Direct Drop 20.97 vs From RDC 9.28
