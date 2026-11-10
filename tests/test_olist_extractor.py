from datetime import date

import pytest

from commerce_lake.extractors.olist import OLIST_FILES, extract_olist, land_file

DAY = date(2026, 11, 10)


@pytest.fixture
def source_dir(tmp_path):
    """Create a temporary source directory with all Olist files."""
    folder = tmp_path / "source"
    folder.mkdir()
    for filename in OLIST_FILES.values():
        (folder / filename).write_text(f"id,name\n1,{filename}\n")
    return folder


def test_land_file_copies_bytes_unchanged(tmp_path):
    source = tmp_path / "in.csv"
    source.write_bytes(b'id,comment\n1,"two\nlines"\n')

    landed = land_file(source, tmp_path / "out")

    assert landed.read_bytes() == source.read_bytes()


def test_land_file_creates_missing_folder(tmp_path):
    source = tmp_path / "in.csv"
    source.write_text("id,name\n1,foo\n")

    landed = land_file(source, tmp_path / "a" / "b" / "c")

    assert landed == tmp_path / "a" / "b" / "c" / "in.csv"
    assert landed.is_file()


def test_extract_olist_lands_every_table_in_its_partition(source_dir, tmp_path):
    lake = tmp_path / "lake"

    landed = extract_olist(source_dir, str(lake), DAY)

    assert len(landed) == len(OLIST_FILES)
    orders = lake / "raw/olist/orders/ingest_date=2026-11-10/olist_orders_dataset.csv"
    assert orders in landed
    assert orders.is_file()


def test_extract_olist_lands_nothing_if_a_source_file_is_missing(source_dir, tmp_path):
    (source_dir / "olist_orders_dataset.csv").unlink()
    lake = tmp_path / "lake"

    with pytest.raises(FileNotFoundError, match="olist_orders_dataset.csv"):
        extract_olist(source_dir, str(lake), DAY)

    assert not lake.exists()
