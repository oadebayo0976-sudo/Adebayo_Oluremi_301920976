BEGIN;
CREATE TABLE customers (
    customer_id integer PRIMARY KEY,
    customer_name text NOT NULL
);
CREATE TABLE sellers (
    seller_id integer PRIMARY KEY,
    shop_name text NOT NULL
);
CREATE TABLE products (
    product_id integer PRIMARY KEY,
    seller_id integer NOT NULL REFERENCES sellers,
    product_name text NOT NULL,
    category text NOT NULL,
    price_ngn numeric(12,2) NOT NULL CHECK (price_ngn > 0),
    stock integer NOT NULL CHECK (stock >= 0)
);
CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    customer_id integer NOT NULL REFERENCES customers,
    ordered_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE order_items (
    order_id integer REFERENCES orders,
    product_id integer REFERENCES products,
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price_ngn numeric(12,2) NOT NULL CHECK (unit_price_ngn > 0),
    PRIMARY KEY (order_id, product_id)
);
CREATE TABLE deliveries (
    delivery_id integer PRIMARY KEY,
    order_id integer NOT NULL UNIQUE REFERENCES orders,
    tracking_code text NOT NULL UNIQUE CHECK (btrim(tracking_code) <> '')
);
CREATE TABLE delivery_updates (
    update_id integer PRIMARY KEY,
    delivery_id integer NOT NULL REFERENCES deliveries,
    status text NOT NULL CHECK (status IN ('Preparing', 'Dispatched', 'Out for delivery', 'Delivered')),
    updated_at timestamptz NOT NULL,
    UNIQUE (delivery_id, updated_at)
);
COMMIT;
