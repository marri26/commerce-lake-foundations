# Commerce Lake Foundations

A nightly batch data lake that turns a marketplace's scattered exports into **one trusted daily
revenue, margin and inventory number** — built on AWS (S3 · Glue · Athena) with plain Python and
DuckDB, orchestrated by Airflow, provisioned with Terraform. Deliberately **no Spark**: the project
pushes a single machine until it breaks, and documents where.

## The business problem

Finance exports three systems into Excel every Monday, spends a day reconciling, and the numbers
never agree. This pipeline replaces that with an automated, idempotent, queryable source of truth.

## Architecture (target)

```
sources ──► extractors ──► S3 /raw ──► /bronze (Parquet) ──► /curated ──► Glue + Athena ──► dashboard
              [ Airflow orchestrates · Terraform provisions · GitHub Actions deploys ]
```

## Progress

| Version | Milestone | Status |
|---|---|---|
| v0.0.1 | M0 — Repo initialised | ✅ |
| v0.1.0 | M0 — Project skeleton (uv, ruff, pytest, Makefile) | ✅ |
| v0.2.0 | M1 — Explore the data, define "daily revenue" | ⏳ |
| v0.3.0 | M2 — First extractor → raw layer | |
| v0.4.0 | M3 — Bronze Parquet + format benchmark | |
| v0.5.0 | M4 — Curated layer + first revenue number | |
| v0.6.0 | M5 — API extractors + watermark incremental | |
| v0.7.0 | M6 — Synthetic inventory & settlements | |
| v0.8.0 | M7 — AWS infrastructure via Terraform | |
| v0.9.0 | M8 — Glue Catalog + Athena + partitioning experiment | |
| v0.10.0 | M9 — Airflow + 90-day idempotent backfill | |
| v0.11.0 | M10 — The single-node scale wall | |
| v0.12.0 | M11 — CI/CD | |
| v1.0.0 | M12 — Documentation complete | |
