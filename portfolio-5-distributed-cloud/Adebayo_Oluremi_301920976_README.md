# 5. How the shop could use a second database

The brief allows a written discussion or a deployed setup. I explain how I would set up the databases for the Temu marketplace exercise. The proposed setup uses the same linked PostgreSQL tables for orders and stock, with a second database that copies the saved changes.

![Cloud database proposal](Adebayo_Oluremi_301920976_cloud.png)

## Replication

Buyer A purchases the iPhone 18. The main PostgreSQL database saves the order and the lower stock. It sends those changes to a second database, called a **replica**, in a different availability zone. An availability zone is a separate part of a cloud region.

## Routine reports and consistency

A routine report is a regular check staff use to understand how the shop is doing. For example, the morning dashboard can show how many orders the shop saved yesterday or how many parcels are still on the way.

When staff open that dashboard, it asks the second database for the numbers. The second database counts the order or parcel records it has already copied. The main database can keep handling new orders while the dashboard does that work. If a parcel was just marked Delivered, the dashboard may still count it as being on the way until the copy catches up. This is a question of **consistency**, or which version of the records each reader sees. Checkout and the live parcel tracking page use the main database for the latest saved information.

## Availability

Availability means the shop can keep serving people when something goes wrong. If the main database goes down, the shop may have to pause checkout. The operator or cloud service checks the failure, stops the old database from accepting orders and makes the second database take over. Once the shop reconnects to it, checkout can resume. An order saved just before the failure could be missing if it had yet to reach the copy. A separate backup helps recover older data after a mistake such as an accidental deletion.

## Sharding

Replication copies the same records. Sharding divides records between servers. If a catalogue becomes very large, product cards could be divided by product identifier. Searching by category might then need to check more than one server. I would keep checkout on one main database in this design, since an order can contain several products and all stock changes need to succeed together.

To test a deployment, I would measure how long an order takes to reach the copy, how long checkout pauses during a switch, and whether recent saved orders are still there. This portfolio proposes the design. No cloud service was deployed.

A delivery update such as “Delivered” would also be saved on the main database. A tracking page that needs the latest status should read from that database. A report on the copy might briefly still show “Out for delivery” while the copy catches up.
