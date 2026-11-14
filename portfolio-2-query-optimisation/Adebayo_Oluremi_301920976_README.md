# 2. How the shop finds products faster

The brief asks for Structured Query Language (SQL) queries, results, execution plans, indexing evidence and an explanation of the measured performance. SQL tells the database which information to find.

1. I asked PostgreSQL for Electronics products priced from 400,000 to 500,000 Nigerian naira. The iPhone 18 costs 450,000, so it fits.
2. I ran the search without the new index. The execution plan, which lists the steps the database took, showed a parallel table scan. PostgreSQL checked the rows in the table to find the matches.
3. I added an index on category and price. It works like an index in a book. The database can go to the Electronics entries and look in the requested price range.
4. I ran the same search again. PostgreSQL used the index to find the matching rows. It also used an incremental sort to finish putting them in order.
5. I compared the two result files. Both contained exactly the same 37 products.

| Local measure | Before | After |
|---|---:|---:|
| Products returned | 37 | 37 |
| Middle time of three runs | 10.323 milliseconds | 0.141 milliseconds |
| Data blocks found in memory per run | 1,597 | 49 |

The index helped this search on the practice dataset. Both phases used data already in memory. Indexes also take storage and need updates when indexed values change.

The receipt query uses order 101 to join the order, buyer, order line and product. It returned Buyer A, one iPhone 18 and a line total of 450,000 Nigerian naira.

[Search SQL](Adebayo_Oluremi_301920976_catalogue.sql) · [Receipt SQL](Adebayo_Oluremi_301920976_order-receipt.sql) · [Receipt result](../evidence/Adebayo_Oluremi_301920976_receipt.txt) · [Index and timing script](Adebayo_Oluremi_301920976_measure.sh) · [Before rows](../evidence/Adebayo_Oluremi_301920976_catalogue-before.csv) · [After rows](../evidence/Adebayo_Oluremi_301920976_catalogue-after.csv) · [Before plan](../evidence/Adebayo_Oluremi_301920976_plan-before-1.json) · [After plan](../evidence/Adebayo_Oluremi_301920976_plan-after-1.json) · [All timings](../evidence/Adebayo_Oluremi_301920976_performance.txt)

![Selected lines from the recorded output](../evidence/Adebayo_Oluremi_301920976_query-output.png)

## Track order 101

The buyer opens their order to track the phone. The query uses the order number to find the parcel, then uses the parcel number to find its updates. To show the current status, it sorts the updates newest first and takes the first one. For the full journey, it sorts oldest first. If a delivery has been created but has no updates, the current status reads “No updates yet”.

![Order and parcel links](../portfolio-1-database-design/Adebayo_Oluremi_301920976_delivery.png)

| Time in Coordinated Universal Time | What the buyer sees |
|---|---|
| 08:00 | Preparing |
| 09:00 | Dispatched |
| 11:00 | Out for delivery |
| 14:00 | Delivered |

The recorded test used fictional dates and statuses. The status rule checks the allowed words. This exercise records events and sorts them by time.

[Tracking query](Adebayo_Oluremi_301920976_track-delivery.sql) · [Create and test delivery](../portfolio-3-transactions-concurrency/Adebayo_Oluremi_301920976_delivery-demo.sql) · [Recorded tracking results](../evidence/Adebayo_Oluremi_301920976_delivery.txt)
