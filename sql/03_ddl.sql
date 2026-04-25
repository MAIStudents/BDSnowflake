DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_seller CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_product_category CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_supplier CASCADE;
DROP TABLE IF EXISTS dim_country CASCADE;
DROP TABLE IF EXISTS dim_city CASCADE;

-- Измерения

-- Страна
CREATE TABLE dim_country (
    country_id   SERIAL PRIMARY KEY,
    country_name VARCHAR(255) UNIQUE NOT NULL
);

-- Город
CREATE TABLE dim_city (
    city_id     SERIAL PRIMARY KEY,
    city_name   VARCHAR(255) NOT NULL,
    country_id  INTEGER REFERENCES dim_country(country_id),
    UNIQUE(city_name, country_id)
);

-- Категория товара
CREATE TABLE dim_product_category (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(255) UNIQUE NOT NULL
);

-- Покупатель
CREATE TABLE dim_customer (
    customer_id        INTEGER PRIMARY KEY,
    first_name         VARCHAR(255),
    last_name          VARCHAR(255),
    age                INTEGER,
    email              VARCHAR(255),
    postal_code        VARCHAR(50),
    pet_type           VARCHAR(50),
    pet_name           VARCHAR(255),
    pet_breed          VARCHAR(255),
    country_id         INTEGER REFERENCES dim_country(country_id)
);

-- Продавец
CREATE TABLE dim_seller (
    seller_id     INTEGER PRIMARY KEY,
    first_name    VARCHAR(255),
    last_name     VARCHAR(255),
    email         VARCHAR(255),
    postal_code   VARCHAR(50),
    country_id    INTEGER REFERENCES dim_country(country_id)
);

-- Товар
CREATE TABLE dim_product (
    product_id      INTEGER PRIMARY KEY,
    product_name    VARCHAR(255) NOT NULL,
    category_id     INTEGER REFERENCES dim_product_category(category_id),
    pet_category    VARCHAR(255),
    weight          DECIMAL(10,2),
    color           VARCHAR(50),
    size            VARCHAR(50),
    brand           VARCHAR(255),
    material        VARCHAR(255),
    description     TEXT,
    rating          DECIMAL(3,1),
    reviews         INTEGER,
    release_date    DATE,
    expiry_date     DATE
);

-- Магазин
CREATE TABLE dim_store (
    store_id      SERIAL PRIMARY KEY,
    store_name    VARCHAR(255) NOT NULL,
    location      VARCHAR(255),
    state         VARCHAR(255),
    phone         VARCHAR(50),
    email         VARCHAR(255),
    city_id       INTEGER REFERENCES dim_city(city_id)
);

-- Поставщик
CREATE TABLE dim_supplier (
    supplier_id   SERIAL PRIMARY KEY,
    supplier_name VARCHAR(255) NOT NULL,
    contact       VARCHAR(255),
    email         VARCHAR(255),
    phone         VARCHAR(50),
    address       VARCHAR(255),
    city_id       INTEGER REFERENCES dim_city(city_id)
);

-- Дата
CREATE TABLE dim_date (
    date_id   INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year      INTEGER,
    month     INTEGER,
    day       INTEGER,
    quarter   INTEGER,
    week_day  INTEGER
);

-- Факты
CREATE TABLE fact_sales (
    sale_id          SERIAL PRIMARY KEY,
    date_id          INTEGER REFERENCES dim_date(date_id),
    customer_id      INTEGER REFERENCES dim_customer(customer_id),
    seller_id        INTEGER REFERENCES dim_seller(seller_id),
    product_id       INTEGER REFERENCES dim_product(product_id),
    store_id         INTEGER REFERENCES dim_store(store_id),
    supplier_id      INTEGER REFERENCES dim_supplier(supplier_id),
    quantity_sold    INTEGER NOT NULL,
    unit_price       DECIMAL(10,2) NOT NULL,
    total_amount     DECIMAL(10,2) NOT NULL
);
