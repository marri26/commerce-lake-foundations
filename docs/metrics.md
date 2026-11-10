# Metric definitions

Every number here is reproducible from SQL in `sql/explore/`. Performance metrics
(format benchmark, partitioning experiment, scale wall) are added in later milestones.

## Daily revenue (v1)

**One sentence:** the sum of item price plus freight for every order that was not
canceled or unavailable, attributed to the São Paulo calendar date the order was
placed, in BRL.

| Part | Decision | Why |
|---|---|---|
| **Measure** | `sum(price + freight_value)` from `order_items` | It is what the customer was **billed**. It reconciles to cash collected within 0.02% on fulfilled orders, which makes the settlement reconciliation in M6 possible. GMV excludes freight and cannot be reconciled to any cash figure |
| **Population** | All orders **except** `canceled` and `unavailable` | Those orders were never fulfilled. `delivered`-only would leave today's revenue unknown for 1–3 weeks, which is useless for a daily number |
| **Date attribution** | `order_purchase_timestamp` → calendar date | Known the moment the order is placed, never changes, and matches how the business talks about a day's sales ("Black Friday did R$178k") |
| **Time zone** | `America/Sao_Paulo` local date | The business operates in Brazil; a sale at 22:30 local on Nov 24 is a Nov 24 sale. The curated layer will also store the UTC timestamp so it can be joined with UTC sources (FX, weather, settlements) |
| **Currency** | BRL | The source currency. Converted views (USD, INR) come in M5 using the FX rate for the purchase date |

**SQL reference:** `sql/explore/04_revenue.sql`, view `order_revenue`, last query.

### Reference values (for regression checks)

| Scope | Orders | Daily revenue v1 (BRL) |
|---|---:|---:|
| Whole dataset (2016-09-04 → 2018-10-17) | 98,207 | 15,735,527.03 |
| 2017-11-24 (Black Friday, busiest day) | 1,166 | 178,377.63 |

Once the pipeline exists, its curated output must reproduce these numbers exactly.
That turns this exploration into a test.

## Companion metrics

Reported **alongside** daily revenue, never mixed into it.

| Metric | Definition | Whole dataset (BRL) | Use |
|---|---|---:|---|
| **GMV** | `sum(price)`, same population and date as daily revenue | 13,494,400.74 | marketplace size, seller-side view, excludes shipping |
| **Cash collected** | `sum(payment_value)`, **all** orders | 16,008,872.12 | treasury view; input to the settlement reconciliation (M6) |
| **Unfulfilled cash** | cash collected on orders with no items | 162,591.95 | refund exposure: money taken for orders never fulfilled |

## How the three measures compare (whole dataset, all orders)

| Measure | Total (BRL) | vs order revenue |
|---|---:|---:|
| GMV (`price`) | 13,591,643.70 | −14.2% (no freight) |
| Order revenue (`price + freight`) | 15,843,553.24 | — |
| Cash collected (`payment_value`) | 16,008,872.12 | +1.0% |

The +1.0% gap between cash and order revenue comes from two sources:

| Source | Orders | Amount (BRL) |
|---|---:|---:|
| Cash on orders with **no items** (`unavailable` 124,339.02 · `canceled` 37,337.87 · other 915.06) | 775 | 162,591.95 |
| Customers paid **more** than billed: most likely instalment interest (259 of the 291 orders paid in instalments) | 291 | +3,070.41 |
| Customers paid **less** than billed (discounts / voucher handling) | 90 | −343.04 |

## Known caveats

1. **Past days can change (restatement).** An order placed on day D and canceled on
   day D+7 leaves the day-D number. The source has no cancellation timestamp, so the
   pipeline must **recompute a trailing window** of days on every run, not just
   yesterday. This is a core requirement for the M9 backfill and idempotency design.
2. **Unfulfilled cash.** R$162,591.95 was collected on 775 orders that never had items.
   This is excluded from revenue by design and must surface in reconciliation, not disappear.
3. **Data edges.** 2016 is sparse (Sept: 4, Oct: 324, Nov: **0**, Dec: 1 orders) and
   the data is truncated after August 2018 (Sept: 16, Oct: 4). **Trusted reporting
   window: 2017-01-01 → 2018-08-31.** Daily trends outside it are artefacts of the
   extract, not the business.
4. **No time zone in the source.** Timestamps are assumed to be São Paulo local time.
   Brazil abolished daylight saving in 2019, but it applied during 2016–2018, so the
   UTC conversion in M4 must use the `America/Sao_Paulo` zone rules, not a fixed −03:00 offset.
5. **8 `delivered` orders lack a delivery date.** They do not affect this metric
   (purchase date attribution) but would affect any delivery-date-based variant.
