# Temu marketplace · Advanced Database Systems

**Selected organisation:** Temu, the popular online marketplace. This is a classroom simulation with fictional products, buyers, sellers and orders. The database design is for this assignment.

Imagine two people find a iPhone 18. There is only one left. The shop must show the product, let one person buy it, and keep an accurate record of who got it.

| Assignment activity | Linkage |
|---|---|
| 1. Database design and modelling | [How the shop remembers products and orders](portfolio-1-database-design/Adebayo_Oluremi_301920976_README.md) |
| 2. Query processing and optimisation | [How the shop finds products faster](portfolio-2-query-optimisation/Adebayo_Oluremi_301920976_README.md) |
| 3. Transactions and concurrency | [What happens when two buyers want the last one](portfolio-3-transactions-concurrency/Adebayo_Oluremi_301920976_README.md) |
| 4. NoSQL and advanced data models | [How one product card holds different details](portfolio-4-nosql/Adebayo_Oluremi_301920976_README.md) |
| 5. Distributed and cloud databases | [How a second database helps when the first one fails](portfolio-5-distributed-cloud/Adebayo_Oluremi_301920976_README.md) |
| Final documentation | [Three-page editable Word summary](Adebayo_Oluremi_301920976_MIT8103_Temu_Summary.docx) |

The [evidence folder](evidence/Adebayo_Oluremi_301920976_README.md) holds the original test outputs and visual copies of selected output lines.

## Run the same tests

Use a fresh PostgreSQL database and set your normal connection settings. From this repository's root, with the PostgreSQL command-line client, Python 3 and MongoDB Shell installed, run:

```bash
set -euo pipefail
export PGDATABASE=temu_portfolio PGTZ=UTC
mkdir -p evidence
psql -X -v ON_ERROR_STOP=1 -c 'SELECT version()' -f portfolio-1-database-design/Adebayo_Oluremi_301920976_schema.sql -f portfolio-1-database-design/Adebayo_Oluremi_301920976_seed.sql -f portfolio-1-database-design/Adebayo_Oluremi_301920976_checks.sql 2>&1 | tee evidence/Adebayo_Oluremi_301920976_design.txt
bash portfolio-2-query-optimisation/Adebayo_Oluremi_301920976_measure.sh 2>&1 | tee evidence/Adebayo_Oluremi_301920976_performance.txt
python3 portfolio-3-transactions-concurrency/Adebayo_Oluremi_301920976_demo.py 2>&1 | tee evidence/Adebayo_Oluremi_301920976_transactions.txt
psql -X -v ON_ERROR_STOP=1 -f portfolio-2-query-optimisation/Adebayo_Oluremi_301920976_order-receipt.sql | tee evidence/Adebayo_Oluremi_301920976_receipt.txt
psql -X -v ON_ERROR_STOP=1 -f portfolio-3-transactions-concurrency/Adebayo_Oluremi_301920976_delivery-demo.sql -f portfolio-2-query-optimisation/Adebayo_Oluremi_301920976_track-delivery.sql 2>&1 | tee evidence/Adebayo_Oluremi_301920976_delivery.txt
mongosh --quiet --eval 'print("MongoDB " + db.version())' --file portfolio-4-nosql/Adebayo_Oluremi_301920976_catalogue.js | tee evidence/Adebayo_Oluremi_301920976_mongodb.txt
```

[Section 4 deliverables](Adebayo_Oluremi_301920976_DELIVERABLES.md)
The tests ran locally on PostgreSQL 17.11 and MongoDB 7.0.26. The cloud exercise is a written proposal.
