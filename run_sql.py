#!/usr/bin/env python3
"""Run a SQL file against DuckDB with raw CSVs auto-loaded as views."""
import sys
import duckdb
from pathlib import Path

ROOT = Path(__file__).parent
DB_PATH = ROOT / "pipelineiq.duckdb"
RAW_TABLES = {
    "contacts_raw":    ROOT / "data/raw/contacts_dirty.csv",
    "deals_raw":       ROOT / "data/raw/deals_dirty.csv",
    "ad_clicks_raw":   ROOT / "data/raw/ad_clicks.csv",
    "ad_campaigns_raw":ROOT / "data/raw/ad_campaigns.csv",
}

def main(sql_file: str):
    con = duckdb.connect(DB_PATH)
    for name, path in RAW_TABLES.items():
        con.execute(f"CREATE OR REPLACE VIEW {name} AS SELECT * FROM read_csv_auto('{path}')")
    sql = open(sql_file).read()
    result = con.execute(sql).fetchdf()
    print(result.to_string(index=False))

if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "sql/01_audit.sql")
