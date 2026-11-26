-- Star schema: dimensions + one line-grain fact table.
CREATE TABLE IF NOT EXISTS dim_member (
  member_key INTEGER PRIMARY KEY,
  member_id  TEXT NOT NULL UNIQUE,
  first_name TEXT NOT NULL,
  last_name  TEXT NOT NULL,
  dob        TEXT NOT NULL,
  gender     TEXT NOT NULL,
  zip_code   TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_provider (
  provider_key INTEGER PRIMARY KEY,
  provider_id  TEXT NOT NULL UNIQUE,
  npi          TEXT NOT NULL,
  practice_name TEXT NOT NULL,
  specialty    TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_payer (
  payer_key  INTEGER PRIMARY KEY,
  payer_id   TEXT NOT NULL UNIQUE,
  payer_name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_date (
  date_key  INTEGER PRIMARY KEY,    -- YYYYMMDD
  full_date TEXT NOT NULL UNIQUE,
  year      INTEGER NOT NULL,
  month     INTEGER NOT NULL,
  day       INTEGER NOT NULL,
  day_name  TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS fact_claim_line (
  claim_line_key  INTEGER PRIMARY KEY,
  claim_id        TEXT NOT NULL,
  line_no         INTEGER NOT NULL,
  member_key      INTEGER NOT NULL REFERENCES dim_member(member_key),
  provider_key    INTEGER NOT NULL REFERENCES dim_provider(provider_key),
  payer_key       INTEGER NOT NULL REFERENCES dim_payer(payer_key),
  service_date_key INTEGER NOT NULL REFERENCES dim_date(date_key),
  cpt_code        TEXT NOT NULL,
  billed          REAL NOT NULL,
  allowed         REAL NOT NULL,
  paid            REAL NOT NULL,
  is_denied       INTEGER NOT NULL,  -- 0 / 1
  UNIQUE (claim_id, line_no)
);
