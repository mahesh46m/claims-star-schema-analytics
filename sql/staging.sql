-- Source-system staging tables (synthetic practice-management / claims feed).
CREATE TABLE IF NOT EXISTS src_members (
  member_id   TEXT PRIMARY KEY,
  first_name  TEXT NOT NULL,
  last_name   TEXT NOT NULL,
  dob         TEXT NOT NULL,        -- YYYY-MM-DD
  gender      TEXT NOT NULL,        -- F / M
  zip_code    TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS src_member_updates (
  member_id     TEXT NOT NULL REFERENCES src_members(member_id),
  zip_code      TEXT NOT NULL,
  effective_date TEXT NOT NULL      -- when the new ZIP took effect
);

CREATE TABLE IF NOT EXISTS src_providers (
  provider_id  TEXT PRIMARY KEY,
  npi          TEXT NOT NULL,       -- synthetic, not a real NPI
  practice_name TEXT NOT NULL,
  specialty    TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS src_claims (
  claim_id    TEXT PRIMARY KEY,
  member_id   TEXT NOT NULL REFERENCES src_members(member_id),
  provider_id TEXT NOT NULL REFERENCES src_providers(provider_id),
  payer_id    TEXT NOT NULL,
  received_date TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS src_claim_lines (
  claim_id     TEXT NOT NULL REFERENCES src_claims(claim_id),
  line_no      INTEGER NOT NULL,
  cpt_code     TEXT NOT NULL,
  service_date TEXT NOT NULL,
  billed       REAL NOT NULL,
  allowed      REAL NOT NULL,
  paid         REAL NOT NULL,
  status       TEXT NOT NULL,       -- paid / denied
  PRIMARY KEY (claim_id, line_no)
);

CREATE TABLE IF NOT EXISTS src_payers (
  payer_id   TEXT PRIMARY KEY,
  payer_name TEXT NOT NULL
);
