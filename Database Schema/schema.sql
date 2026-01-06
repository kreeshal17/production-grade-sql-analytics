-- creating a database
create database if not exists apple;
use apple;


-- creating a table category
create table category(
category_id int primary key,
category_name varchar(50) 
);
-- creating table stores
CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50),
    open_date DATE
);
-- creating table products
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    launch_date DATE,
    price DECIMAL(10,2),
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- creating a table sales
CREATE TABLE sales (
    sale_id BIGINT PRIMARY KEY,
    sale_date DATE,
    store_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- creating table warrenty
CREATE TABLE warranty (
    claim_id BIGINT PRIMARY KEY,
    claim_date DATE,
    sale_id BIGINT,
    repair_status VARCHAR(30),
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id)
);


