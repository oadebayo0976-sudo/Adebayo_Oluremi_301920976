SELECT product_id, product_name, price_ngn
FROM products
WHERE category = 'Electronics' AND price_ngn BETWEEN 400000 AND 500000
ORDER BY price_ngn, product_id
