BEGIN;
INSERT INTO customers VALUES (1, 'Sample Buyer A'), (2, 'Sample Buyer B');
INSERT INTO sellers VALUES (1, 'Sample Everyday Shop'), (2, 'Sample Desk Shop');
INSERT INTO products VALUES
    (1, 1, 'iPhone 18', 'Electronics', 450000, 1),
    (2, 2, 'Portable power bank', 'Electronics', 8500, 12);
INSERT INTO products
SELECT n, 2, 'Sample item ' || n,
       CASE WHEN n % 1000 = 0 THEN 'Electronics' ELSE 'Stationery' END,
       100 * (1000 + n % 9000), 10
FROM generate_series(3, 160000) AS series(n);
COMMIT;
