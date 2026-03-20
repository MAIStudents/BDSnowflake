-- liquibase formatted sql
-- changeset admin:0

CREATE SCHEMA snowflake;

-- Таблица клиентов
CREATE TABLE snowflake.dim_customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INTEGER,
    email VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(50)
);

-- Таблица питомцев
CREATE TABLE snowflake.dim_pet (
    pet_id SERIAL PRIMARY KEY,
    pet_name VARCHAR(50),
    pet_type VARCHAR(50),
    pet_breed VARCHAR(50),
    pet_category VARCHAR(50)
);

-- Таблица продавцов
CREATE TABLE snowflake.dim_seller (
    seller_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(50)
);

-- Таблица магазинов
CREATE TABLE snowflake.dim_store (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(50),
    location VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    phone VARCHAR(50),
    email VARCHAR(50)
);

-- Таблица поставщиков
CREATE TABLE snowflake.dim_supplier (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(50),
    contact VARCHAR(50),
    email VARCHAR(50),
    phone VARCHAR(50),
    address VARCHAR(50),
    city VARCHAR(50),
    country VARCHAR(50)
);

-- Таблица продуктов
CREATE TABLE snowflake.dim_product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50),
    price REAL,
    weight REAL,
    color VARCHAR(50),
    size VARCHAR(50),
    brand VARCHAR(50),
    material VARCHAR(50),
    description VARCHAR(1024),
    rating REAL,
    reviews INTEGER,
    release_date DATE,
    expiry_date DATE,
    supplier_id INTEGER REFERENCES snowflake.dim_supplier(supplier_id)
);

-- Таблица времени
CREATE TABLE snowflake.dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE UNIQUE,
    year INTEGER,
    quarter INTEGER,
    month INTEGER,
    month_name VARCHAR(20),
    day INTEGER,
    day_of_week INTEGER,
    weekday_name VARCHAR(20),
    is_weekend BOOLEAN
);

-- Таблица фактов продаж
CREATE TABLE snowflake.fact_sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES snowflake.dim_customer(customer_id),
    pet_id INTEGER REFERENCES snowflake.dim_pet(pet_id),
    seller_id INTEGER REFERENCES snowflake.dim_seller(seller_id),
    store_id INTEGER REFERENCES snowflake.dim_store(store_id),
    product_id INTEGER REFERENCES snowflake.dim_product(product_id),
    date_id INTEGER REFERENCES snowflake.dim_date(date_id),
    quantity INTEGER,
    unit_price REAL,
    total_price REAL
);

--rollback drop schema snowflake cascade;