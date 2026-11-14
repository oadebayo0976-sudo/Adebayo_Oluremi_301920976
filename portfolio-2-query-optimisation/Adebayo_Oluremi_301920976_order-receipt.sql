SELECT o.order_id, c.customer_name, p.product_name, i.quantity,
       i.unit_price_ngn, i.quantity * i.unit_price_ngn AS line_total_ngn
FROM orders o
JOIN customers c USING (customer_id)
JOIN order_items i USING (order_id)
JOIN products p USING (product_id)
WHERE o.order_id = 101;
