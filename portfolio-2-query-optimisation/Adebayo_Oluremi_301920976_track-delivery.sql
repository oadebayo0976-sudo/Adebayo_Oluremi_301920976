-- Find the latest update for one order. Keep deliveries with no updates visible.
SELECT o.order_id, d.tracking_code, COALESCE(u.status, 'No updates yet') AS latest_status,
       u.updated_at
FROM orders AS o
JOIN deliveries AS d USING (order_id)
LEFT JOIN LATERAL (
    SELECT status, updated_at
    FROM delivery_updates
    WHERE delivery_id = d.delivery_id
    ORDER BY updated_at DESC
    LIMIT 1
) AS u ON true
WHERE o.order_id = 101;

-- Follow the same parcel from its first update to its last.
SELECT u.status, u.updated_at
FROM deliveries AS d
JOIN delivery_updates AS u USING (delivery_id)
WHERE d.order_id = 101
ORDER BY u.updated_at;
