"""Build storage locations for every file in the lake.

Every layer, source and table follows ONE layout:

    <root>/<layer>/<source>/<table>/ingest_date=<YYYY-MM-DD>

Keeping this logic in a single function means no other code in the
project ever hand-builds a path string.
"""

from datetime import date

# The three layers of our lake, in the order data flows through them.
# A tuple (not a list) because it must never change while the program runs.
LAYERS = ("raw", "bronze", "curated")


def partition_path(
    root: str, layer: str, source: str, table: str, ingest_date: date
) -> str:
    """Return the folder (or S3 prefix) holding one table's data for one day.

    Example:
        >>> partition_path("data/lake", "raw", "olist", "orders", date(2026, 11, 9))
        'data/lake/raw/olist/orders/ingest_date=2026-11-09'
    """
    if layer not in LAYERS:
        raise ValueError(f"Unkown layer '{layer!r}'; expected one of {LAYERS}")
    root = root.rstrip("/")
    return f"{root}/{layer}/{source}/{table}/ingest_date={ingest_date.isoformat()}"
