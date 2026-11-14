#!/usr/bin/env bash
set -euo pipefail
query=$(cat portfolio-2-query-optimisation/Adebayo_Oluremi_301920976_catalogue.sql)
psql -X -v ON_ERROR_STOP=1 -c 'DROP INDEX IF EXISTS products_category_price_idx' -c 'ANALYZE products'
for phase in before after; do
    if [[ "$phase" == after ]]; then
        psql -X -v ON_ERROR_STOP=1 -c 'CREATE INDEX products_category_price_idx ON products(category, price_ngn)'
    fi
    psql -X --csv -v ON_ERROR_STOP=1 -c "$query" > "evidence/Adebayo_Oluremi_301920976_catalogue-$phase.csv"
    for trial in 1 2 3; do
        psql -X -At -v ON_ERROR_STOP=1 -c "EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) $query" > "evidence/Adebayo_Oluremi_301920976_plan-$phase-$trial.json"
    done
done
cmp evidence/Adebayo_Oluremi_301920976_catalogue-before.csv evidence/Adebayo_Oluremi_301920976_catalogue-after.csv
python3 - <<'PY'
import csv
import json
import statistics
from pathlib import Path
with open('evidence/Adebayo_Oluremi_301920976_catalogue-after.csv') as source:
    rows = list(csv.DictReader(source))
assert len(rows) == 37, len(rows)
print(f'Identical query results: {len(rows)} products')

def names(plan):
    yield plan['Node Type']
    for child in plan.get('Plans', []):
        yield from names(child)
for phase in ('before', 'after'):
    runs = [json.loads(p.read_text())[0] for p in sorted(Path('evidence').glob(f'Adebayo_Oluremi_301920976_plan-{phase}-*.json'))]
    for run in runs:
        plan = run['Plan']
        assert plan['Actual Rows'] == len(rows)
        print(f"{phase}: {' / '.join(names(plan))}; {run['Execution Time']} ms; "
              f"{plan.get('Shared Hit Blocks', 0)} buffer hits; {plan.get('Shared Read Blocks', 0)} buffer reads")
    print(f"{phase} median: {statistics.median(r['Execution Time'] for r in runs):.3f} ms")
PY
