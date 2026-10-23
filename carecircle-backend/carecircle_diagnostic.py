"""
CareCircle read-only diagnostic
Run this from D:\Projects\carecircle-backend with the backend virtual environment activated.
This script does NOT create, update, or delete database records.
"""
from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

try:
    from sqlalchemy import inspect, text
    from app.database import engine
    import app.models  # noqa: F401 - ensure model metadata is loaded
    from app.models import Base
except Exception as exc:
    print("SETUP ERROR: Could not import the backend database/models.")
    print(f"Details: {type(exc).__name__}: {exc}")
    print("Run this script from the backend project folder with its .venv activated.")
    sys.exit(2)

API_BASE = os.getenv("CARECIRCLE_API_BASE", "http://127.0.0.1:8000").rstrip("/")
EXPECTED_TABLES = {
    "users",
    "care_recipients",
    "helper_profiles",
    "care_requests",
    "care_status_events",
}

def result(label: str, ok: bool, detail: str = "") -> None:
    print(f"[{'PASS' if ok else 'CHECK'}] {label}" + (f" — {detail}" if detail else ""))

def main() -> int:
    print("=" * 68)
    print("CARECIRCLE READ-ONLY DIAGNOSTIC")
    print("Database changes: NONE")
    print(f"API base URL: {API_BASE}")
    print("=" * 68)

    # Database connection
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        result("Neon/database connection", True, "SELECT 1 succeeded")
    except Exception as exc:
        result("Neon/database connection", False, f"{type(exc).__name__}: {exc}")
        print("\nCannot continue database checks until the connection works.")
        return 1

    inspector = inspect(engine)
    actual_tables = set(inspector.get_table_names(schema="public"))
    missing_tables = sorted(EXPECTED_TABLES - actual_tables)
    result("Required tables exist", not missing_tables,
           "all 5 found" if not missing_tables else "missing: " + ", ".join(missing_tables))

    # Compare model columns to database columns; don't print secrets or row data.
    metadata = Base.metadata
    for table_name in sorted(EXPECTED_TABLES & actual_tables):
        db_cols = {c["name"]: c for c in inspector.get_columns(table_name, schema="public")}
        model_table = metadata.tables.get(table_name)
        if model_table is None:
            result(f"{table_name}: model metadata", False, "table not found in loaded SQLAlchemy metadata")
            continue

        missing_cols = sorted(set(model_table.columns.keys()) - set(db_cols))
        extra_cols = sorted(set(db_cols) - set(model_table.columns.keys()))
        result(f"{table_name}: columns vs model", not missing_cols,
               ("missing in DB: " + ", ".join(missing_cols)) if missing_cols
               else ("extra DB columns: " + ", ".join(extra_cols) if extra_cols else "column names match"))

        # Report varchar lengths that differ, without making changes.
        length_mismatches = []
        for col in model_table.columns:
            actual = db_cols.get(col.name)
            if not actual:
                continue
            model_len = getattr(col.type, "length", None)
            db_len = getattr(actual["type"], "length", None)
            if model_len is not None and db_len is not None and model_len != db_len:
                length_mismatches.append(f"{col.name} model={model_len}, DB={db_len}")
        result(f"{table_name}: varchar lengths", not length_mismatches,
               "; ".join(length_mismatches) if length_mismatches else "no detected length mismatches")

    # Foreign keys, unique constraints and primary keys.
    fk_missing = []
    unique_notes = []
    for table_name in sorted(EXPECTED_TABLES & actual_tables):
        db_fks = inspector.get_foreign_keys(table_name, schema="public")
        model_table = metadata.tables.get(table_name)
        model_fk_pairs = set()
        if model_table is not None:
            for fk in model_table.foreign_keys:
                model_fk_pairs.add((fk.parent.name, fk.column.table.name, fk.column.name))
        db_fk_pairs = set()
        for fk in db_fks:
            referred_table = fk.get("referred_table")
            referred_cols = fk.get("referred_columns") or []
            for local_col, ref_col in zip(fk.get("constrained_columns") or [], referred_cols):
                db_fk_pairs.add((local_col, referred_table, ref_col))
        for pair in sorted(model_fk_pairs - db_fk_pairs):
            fk_missing.append(f"{table_name}.{pair[0]} -> {pair[1]}.{pair[2]}")

        db_unique_cols = set()
        for item in inspector.get_unique_constraints(table_name, schema="public"):
            cols = item.get("column_names") or []
            if len(cols) == 1:
                db_unique_cols.add(cols[0])
        for idx in inspector.get_indexes(table_name, schema="public"):
            cols = idx.get("column_names") or []
            if idx.get("unique") and len(cols) == 1:
                db_unique_cols.add(cols[0])
        if table_name == "users":
            for col in ("email", "phone"):
                if col not in db_unique_cols:
                    unique_notes.append(f"users.{col} lacks a detected single-column UNIQUE constraint/index")
        if table_name == "helper_profiles" and "user_id" not in db_unique_cols:
            unique_notes.append("helper_profiles.user_id lacks a detected single-column UNIQUE constraint/index")

    result("Foreign keys vs model", not fk_missing,
           "model foreign keys found" if not fk_missing else "; ".join(fk_missing))
    result("Expected uniqueness", not unique_notes,
           "users.email, users.phone, helper_profiles.user_id verified" if not unique_notes else "; ".join(unique_notes))

    # Password hash check; never print password hashes.
    try:
        with engine.connect() as conn:
            row = conn.execute(text("""
                SELECT COUNT(*) AS total_users,
                       COUNT(*) FILTER (WHERE password_hash IS NULL OR password_hash = '') AS missing_hashes
                FROM users
            """)).mappings().one()
        result("User password hashes", row["missing_hashes"] == 0,
               f"{row['missing_hashes']} of {row['total_users']} users have a missing/empty hash")
        if row["missing_hashes"]:
            print("       NOTE: This is read-only. No password or hash was changed.")
    except Exception as exc:
        result("User password hashes", False, f"{type(exc).__name__}: {exc}")

    # API checks are read-only. /me without a token should be rejected (401/403).
    def http_status(path: str, timeout: float = 4.0):
        req = urllib.request.Request(API_BASE + path, headers={"Accept": "application/json"})
        try:
            with urllib.request.urlopen(req, timeout=timeout) as response:
                return response.status, response.read(2_000_000 if path == "/openapi.json" else 3000).decode("utf-8", "replace")
        except urllib.error.HTTPError as exc:
            return exc.code, exc.read(1000).decode("utf-8", "replace")
        except Exception as exc:
            return None, f"{type(exc).__name__}: {exc}"

    status, body = http_status("/openapi.json")
    result("FastAPI OpenAPI endpoint", status == 200, f"HTTP {status}" if status else body)
    if status == 200:
        try:
            spec = json.loads(body)
            paths = spec.get("paths", {})
            expected_paths = [
                "/api/auth/register",
                "/api/auth/login",
                "/api/auth/me",
                "/api/profiles/recipients",
                "/api/profiles/helper",
            ]
            missing_paths = [p for p in expected_paths if p not in paths]
            result("Expected API routes", not missing_paths,
                   "core routes found" if not missing_paths else "not found: " + ", ".join(missing_paths))
        except Exception as exc:
            result("OpenAPI JSON parse", False, str(exc))

    status, body = http_status("/api/auth/me")
    result("Unauthenticated /api/auth/me protection", status in (401, 403),
           f"HTTP {status}; expected 401 or 403 without a token" if status is not None else body)

    print("\n" + "=" * 68)
    print("NEXT: Run `flutter analyze` from D:\\Projects\\CareCircle\\carecircle.")
    print("This script does not test a real password login, create profiles, or submit care requests.")
    print("Those actions need a deliberate test account/password and should be tested separately.")
    print("=" * 68)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
