-- ETL: staging -> star. Idempotent via DELETE + reload (demo scale).

DELETE FROM fact_claim_line;
DELETE FROM dim_member;
DELETE FROM dim_provider;
DELETE FROM dim_payer;
DELETE FROM dim_date;

-- SCD2: base version effective at the epoch plus one version per update.
WITH versions AS (
  SELECT member_id, first_name, last_name, dob, gender, zip_code,
         DATE('2024-01-01') AS effective_date
  FROM src_members
  UNION ALL
  SELECT u.member_id, m.first_name, m.last_name, m.dob, m.gender, u.zip_code,
         u.effective_date
  FROM src_member_updates u
  JOIN src_members m ON m.member_id = u.member_id
),
ordered AS (
  SELECT v.*,
         LEAD(effective_date) OVER (PARTITION BY member_id ORDER BY effective_date) AS next_eff
  FROM versions v
)
INSERT INTO dim_member (member_key, member_id, first_name, last_name, dob, gender,
                        zip_code, effective_date, expiry_date, is_current)
SELECT ROW_NUMBER() OVER (ORDER BY member_id, effective_date),
       member_id, first_name, last_name, dob, gender, zip_code,
       effective_date,
       COALESCE(DATE(next_eff, '-1 day'), '9999-12-31'),
       CASE WHEN next_eff IS NULL THEN 1 ELSE 0 END
FROM ordered;

INSERT INTO dim_provider (provider_key, provider_id, npi, practice_name, specialty)
SELECT ROW_NUMBER() OVER (ORDER BY provider_id),
       provider_id, npi, practice_name, specialty
FROM src_providers;

INSERT INTO dim_payer (payer_key, payer_id, payer_name)
SELECT ROW_NUMBER() OVER (ORDER BY payer_id), payer_id, payer_name
FROM src_payers;

-- dim_date spans the observed service-date range.
WITH RECURSIVE span(lo, hi) AS (
  SELECT MIN(service_date), MAX(service_date) FROM src_claim_lines
), d(full_date) AS (
  SELECT lo FROM span
  UNION ALL
  SELECT DATE(full_date, '+1 day') FROM d, span WHERE full_date < span.hi
)
INSERT INTO dim_date (date_key, full_date, year, month, day, day_name)
SELECT CAST(STRFTIME('%Y%m%d', full_date) AS INTEGER),
       full_date,
       CAST(STRFTIME('%Y', full_date) AS INTEGER),
       CAST(STRFTIME('%m', full_date) AS INTEGER),
       CAST(STRFTIME('%d', full_date) AS INTEGER),
       STRFTIME('%w', full_date)
FROM d;

INSERT INTO fact_claim_line (
  claim_line_key, claim_id, line_no, member_key, provider_key, payer_key,
  service_date_key, cpt_code, billed, allowed, paid, is_denied
)
SELECT ROW_NUMBER() OVER (ORDER BY cl.claim_id, cl.line_no),
       cl.claim_id,
       cl.line_no,
       dm.member_key,
       dp.provider_key,
       dpy.payer_key,
       CAST(STRFTIME('%Y%m%d', cl.service_date) AS INTEGER),
       cl.cpt_code,
       cl.billed,
       cl.allowed,
       cl.paid,
       CASE WHEN cl.status = 'denied' THEN 1 ELSE 0 END
FROM src_claim_lines cl
JOIN src_claims   c   ON c.claim_id = cl.claim_id
JOIN dim_member   dm  ON dm.member_id = c.member_id
                     AND cl.service_date BETWEEN dm.effective_date AND dm.expiry_date
JOIN dim_provider dp  ON dp.provider_id = c.provider_id
JOIN dim_payer    dpy ON dpy.payer_id = c.payer_id;
