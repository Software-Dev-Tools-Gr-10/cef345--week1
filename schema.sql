CREATE TABLES sales (
    id INTERGER PRIMARY KEY,
    user-id INTERGER NOT NULL,
    payment_method TEXT NOT NULL,
    total INTERGER NOT NULL,
    created_at TEXT NOT NULL,

    FOREIGN KEY (user_id) REFERENCES user(id),
    FOREIGN KEY (customer_id) REFERENCES customer(id)
    );

CREATE TABLE sale_item (
    id INTERGER PRIMARY KEY,
    sale_id INTERGER NOT NULL,
    product_id INTERGER NOT NULL,
    quantity INTERGER NOT NULL CHECK (quantity > 0),
    unit_price INTERGER NOT NULL,
    unit_cost INTERGER NOT NULL,

    FOREIGN KEY (sale_id) REFERENCES sales(id),
    FOREIGN KEY (product_id) REFERENCES products(id),

);