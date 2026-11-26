# Claims Star Schema: Analytics Engineering Demo

A portfolio project by **Mahesh M**: a Kimball-style dimensional model for healthcare claims, built with pure SQL ETL (staging -> dimensions -> one line-grain fact), a suite of data tests that must all pass, and mart queries for denial and collections reporting.

> **Demo project.** All data is synthetic and randomly generated (fixed seed). It is not based on any real member, provider, payer or employer data, and the numbers are not real-world metrics.

## What it does

1. **Stage** (`scripts/generate_source.py`): synthetic source-system tables (`src_members`, `src_providers`, `src_payers`, `src_claims`, `src_claim_lines`): 600 members, 60 providers, 3,000 claims, 7,460 service lines across 2025.
2. **Model** (`sql/star.sql`, `sql/etl.sql`): a star schema - `dim_member`, `dim_provider`, `dim_payer`, `dim_date` and `fact_claim_line` (grain: one claim service line). ETL is pure SQL: deduped dimension loads with surrogate keys, a recursive-CTE date spine, and a key-resolving fact load.
3. **Test** (`sql/tests.sql`): 13 data tests - unique keys, fact-to-dimension referential integrity, accepted values, no negative amounts, paid <= allowed, denied lines carry zero payment, fact row count matches staging. Any failure exits non-zero.
4. **Report** (`sql/marts.sql`): monthly denial rate by payer, top providers by collections, allowed-to-billed ratio by payer.

## Headline results (seed 42)

| KPI | Value |
|---|---|
| Fact rows | 7,460 |
| Denial rate | 12.5% |
| Data tests | 13 / 13 PASS |

Full build log and mart output in [`sample_output.md`](sample_output.md).

## Run it

Requires Python 3.8+ only (built-in `sqlite3`, no installs).

```bash
python scripts/build_model.py
```

## How I build these projects (AI, used honestly)

I use AI tools as a drafting partner: they help me sketch schemas, SQL and pipeline structure quickly. Everything that ships here is then **verified by actually running it** - the test suite above is the check, and the numbers come from executing the code, not from the AI's claims. Synthetic data keeps the whole workflow safe to share. That is how I use AI in my analytics work: fast drafts, machine-checked results, and domain judgment for what the metrics should mean.

## Layout

```
sql/staging.sql          source-system tables
sql/star.sql             dimensions + fact_claim_line
sql/etl.sql              staging -> star ETL (idempotent)
sql/tests.sql            13 data tests (violation counts; zero = pass)
sql/marts.sql            reporting queries over the star
scripts/generate_source.py  deterministic synthetic source data
scripts/build_model.py      stage -> build -> test -> marts
```

## Possible extensions

SCD Type 2 dimensions for member and provider attributes, incremental fact loads with a watermark, dbt-style test configuration, and a BI semantic layer over the marts.

---
Author: Mahesh M. Released under the MIT License.
