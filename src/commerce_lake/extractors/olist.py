import shutil
from datetime import date
from pathlib import Path

from commerce_lake.paths import partition_path

OLIST_FILES = {
    "customers": "olist_customers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "payments": "olist_order_payments_dataset.csv",
    "reviews": "olist_order_reviews_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}


def land_file(source_file: Path, target_dir: Path) -> Path:
    """Copy a file from the source to the target directory."""
    target_dir.mkdir(parents=True, exist_ok=True)
    target_file = target_dir / source_file.name
    shutil.copy2(source_file, target_file)
    return target_file


def extract_olist(source_dir: Path, lake_root: str, ingest_date: date) -> list[Path]:
    """Extract the Olist source files into the lake."""
    missing = [
        name for name in OLIST_FILES.values() if not (source_dir / name).is_file()
    ]
    if missing:
        raise FileNotFoundError(f"Missing Olist source files: {source_dir}:{missing}")
    landed = []
    for table, filename in OLIST_FILES.items():
        source_file = source_dir / filename
        target_dir = Path(partition_path(lake_root, "raw", "olist", table, ingest_date))
        landed.append(land_file(source_file, target_dir))
    return landed
