-- Data tests. Each "-- test: <name>" block must return exactly one row, one
-- column: the number of violations. Zero means pass.

-- test: dim_member surrogate key unique
SELECT COUNT(*) - COUNT(DISTINCT member_key) FROM dim_member;

-- test: dim_provider surrogate key unique
SELECT COUNT(*) - COUNT(DISTINCT provider_key) FROM dim_provider;

-- test: dim_date full_date unique
SELECT COUNT(*) - COUNT(DISTINCT full_date) FROM dim_date;

-- test: no overlapping member intervals
SELECT COUNT(*) FROM dim_member a
JOIN dim_member b ON a.member_id = b.member_id AND a.member_key < b.member_key
WHERE a.effective_date <= b.expiry_date AND b.effective_date <= a.expiry_date;

-- test: exactly one current version per member
SELECT COUNT(*) FROM (
  SELECT member_id FROM dim_member GROUP BY member_id HAVING SUM(is_current) <> 1
);

-- test: fact grain unique (claim_id, line_no)
SELECT COUNT(*) FROM (
  SELECT claim_id, line_no FROM fact_claim_line
  GROUP BY claim_id, line_no HAVING COUNT(*) > 1
);

-- test: fact member keys resolve
SELECT COUNT(*) FROM fact_claim_line f
LEFT JOIN dim_member d ON d.member_key = f.member_key
WHERE d.member_key IS NULL;

-- test: fact provider keys resolve
SELECT COUNT(*) FROM fact_claim_line f
LEFT JOIN dim_provider d ON d.provider_key = f.provider_key
WHERE d.provider_key IS NULL;

-- test: fact payer keys resolve
SELECT COUNT(*) FROM fact_claim_line f
LEFT JOIN dim_payer d ON d.payer_key = f.payer_key
WHERE d.payer_key IS NULL;

-- test: fact service dates resolve
SELECT COUNT(*) FROM fact_claim_line f
LEFT JOIN dim_date d ON d.date_key = f.service_date_key
WHERE d.date_key IS NULL;

-- test: no negative amounts
SELECT COUNT(*) FROM fact_claim_line
WHERE billed < 0 OR allowed < 0 OR paid < 0;

-- test: paid never exceeds allowed on paid lines
SELECT COUNT(*) FROM fact_claim_line
WHERE is_denied = 0 AND paid > allowed + 0.005;

-- test: denied lines carry zero payment
SELECT COUNT(*) FROM fact_claim_line
WHERE is_denied = 1 AND paid <> 0;

-- test: is_denied accepted values
SELECT COUNT(*) FROM fact_claim_line WHERE is_denied NOT IN (0, 1);

-- test: fact row count matches staged lines
SELECT ABS((SELECT COUNT(*) FROM fact_claim_line) - (SELECT COUNT(*) FROM src_claim_lines));
