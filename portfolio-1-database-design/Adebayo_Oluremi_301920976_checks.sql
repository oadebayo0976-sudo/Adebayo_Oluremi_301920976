DO $$
BEGIN
    BEGIN
        INSERT INTO products VALUES (200001, 1, 'Bad price', 'Electronics', 0, 1);
        RAISE EXCEPTION 'Expected zero price to be rejected';
    EXCEPTION WHEN check_violation THEN RAISE NOTICE 'PASS: zero price rejected';
    END;
    BEGIN
        UPDATE products SET stock = -1 WHERE product_id = 1;
        RAISE EXCEPTION 'Expected negative stock to be rejected';
    EXCEPTION WHEN check_violation THEN RAISE NOTICE 'PASS: negative stock rejected';
    END;
    BEGIN
        INSERT INTO orders (order_id, customer_id) VALUES (90, 999);
        RAISE EXCEPTION 'Expected missing customer to be rejected';
    EXCEPTION WHEN foreign_key_violation THEN RAISE NOTICE 'PASS: unknown customer rejected';
    END;
END $$;
SELECT count(*) AS products_loaded FROM products;
SELECT product_name, stock FROM products WHERE product_id = 1;
