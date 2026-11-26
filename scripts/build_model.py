"""Build the star schema, run the data tests, print the marts.

Usage: python scripts/build_model.py   (creates/refresh claims.db in the repo root)
"""
import os
import sqlite3
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB = os.path.join(ROOT, "claims.db")
SQL = os.path.join(ROOT, "sql")

sys.path.insert(0, os.path.join(ROOT, "scripts"))
from generate_source import generate  # noqa: E402


def run_blocks(con, path, marker):
    """Run '-- <marker>: <name>' separated statements; yield (name, cursor)."""
    with open(path) as f:
        text = f.read()
    blocks = []
    name, buf = None, []
    for line in text.splitlines():
        if line.strip().startswith(f"-- {marker}:"):
            if name and "".join(buf).strip():
                blocks.append((name, "\n".join(buf)))
            name, buf = line.split(":", 1)[1].strip(), []
        elif name:
            buf.append(line)
    if name and "".join(buf).strip():
        blocks.append((name, "\n".join(buf)))
    for nm, stmt in blocks:
        yield nm, con.execute(stmt)


def print_table(cur):
    cols = [d[0] for d in cur.description]
    rows = cur.fetchall()
    widths = [max(len(str(c)), *(len(str(r[i])) for r in rows)) for i, c in enumerate(cols)]
    print(" | ".join(str(c).ljust(widths[i]) for i, c in enumerate(cols)))
    print("-+-".join("-" * w for w in widths))
    for r in rows:
        print(" | ".join(str(v).ljust(widths[i]) for i, v in enumerate(r)))


def main():
    n_claims, n_lines = generate(DB)
    print(f"staged {n_claims} claims / {n_lines} lines (synthetic)")

    con = sqlite3.connect(DB)
    with open(os.path.join(SQL, "star.sql")) as f:
        con.executescript(f.read())
    with open(os.path.join(SQL, "etl.sql")) as f:
        con.executescript(f.read())

    n_fact = con.execute("SELECT COUNT(*) FROM fact_claim_line").fetchone()[0]
    n_denied = con.execute("SELECT SUM(is_denied) FROM fact_claim_line").fetchone()[0]
    print(f"star built: {n_fact} fact rows; denial rate {100.0*n_denied/n_fact:.1f}%\n")

    print("# Data tests")
    failures = 0
    for name, cur in run_blocks(con, os.path.join(SQL, "tests.sql"), "test"):
        violations = cur.fetchone()[0]
        status = "PASS" if violations == 0 else f"FAIL ({violations} violations)"
        if violations != 0:
            failures += 1
        print(f"  {status:12s} {name}")
    print()

    print("# Marts")
    for name, cur in run_blocks(con, os.path.join(SQL, "marts.sql"), "mart"):
        print(f"## {name}")
        print_table(cur)
        print()

    con.close()
    if failures:
        print(f"{failures} data test(s) FAILED", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
