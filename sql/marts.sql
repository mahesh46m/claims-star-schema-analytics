-- Mart queries over the star schema. "-- mart: <name>" blocks.

-- mart: Monthly denial rate by payer
SELECT d.year, d.month, p.payer_name,
       COUNT(*) AS lines,
       ROUND(100.0 * SUM(f.is_denied) / COUNT(*), 1) AS denial_pct,
       ROUND(SUM(f.billed), 0) AS billed
FROM fact_claim_line f
JOIN dim_date d   ON d.date_key = f.service_date_key
JOIN dim_payer p  ON p.payer_key = f.payer_key
GROUP BY d.year, d.month, p.payer_name
ORDER BY d.year, d.month, p.payer_name;

-- mart: Top providers by collected amount
SELECT pr.practice_name, pr.specialty,
       COUNT(*) AS lines,
       ROUND(SUM(f.paid), 0) AS collected
FROM fact_claim_line f
JOIN dim_provider pr ON pr.provider_key = f.provider_key
GROUP BY pr.practice_name, pr.specialty
ORDER BY collected DESC
LIMIT 10;

-- mart: Allowed-to-billed ratio by payer
SELECT p.payer_name,
       ROUND(SUM(f.billed), 0) AS billed,
       ROUND(SUM(f.allowed), 0) AS allowed,
       ROUND(100.0 * SUM(f.allowed) / SUM(f.billed), 1) AS allowed_pct_of_billed
FROM fact_claim_line f
JOIN dim_payer p ON p.payer_key = f.payer_key
GROUP BY p.payer_name
ORDER BY allowed_pct_of_billed;
