"""Tests for commerce_lake.paths."""

from datetime import date

import pytest

from commerce_lake.paths import partition_path

DAY = date(2026, 11, 9)


def test_builds_local_path():
    result = partition_path("data/lake", "raw", "olist", "orders", DAY)
    assert result == "data/lake/raw/olist/orders/ingest_date=2026-11-09"


def test_builds_s3_path():
    result = partition_path("s3://commerce-lake", "bronze", "fx", "rates", DAY)
    assert result == "s3://commerce-lake/bronze/fx/rates/ingest_date=2026-11-09"


def test_trailing_slash_on_root_is_ignored():
    with_slash = partition_path("data/lake/", "raw", "olist", "orders", DAY)
    without_slash = partition_path("data/lake", "raw", "olist", "orders", DAY)
    assert with_slash == without_slash


def test_unknown_layer_is_rejected():
    with pytest.raises(ValueError, match="Unkown layer"):
        partition_path("data/lake", "silver", "olist", "orders", DAY)
