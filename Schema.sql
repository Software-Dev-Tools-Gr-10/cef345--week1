CREATE TABLE sales (
id serial primary key,
user_id integer references users(id),
customer_id integer references customers(id),
payment_method varchar,
total integer,
created_at date
);

CREATE TABLE sales_items(
id serial primary key,
sale_id integer references sales(id),
product_id integer references products(id),
quamtity integer,
unit_price integer,
unit_cost integer
);