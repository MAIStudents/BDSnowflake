-- Справочники

CREATE TABLE dim_country (
    country_id   SERIAL PRIMARY KEY,
    country      VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_city (
    city_id    SERIAL PRIMARY KEY,
    city       VARCHAR(100) NOT NULL,
    state      VARCHAR(100)
);

CREATE TABLE dim_location (
    location_id  SERIAL PRIMARY KEY,
    city_id      INT REFERENCES dim_city(city_id),
    country_id   INT REFERENCES dim_country(country_id),
    postal_code  VARCHAR(20),
    address      VARCHAR(255)
);

CREATE TABLE dim_pet_type (
                              pet_type_id SERIAL PRIMARY KEY,
                              type VARCHAR(50)
);

CREATE TABLE dim_pet_breed (
                               pet_breed_id SERIAL PRIMARY KEY,
                               breed VARCHAR(100)
);

CREATE TABLE dim_pet (
    pet_id      SERIAL PRIMARY KEY,
    pet_type_id INT REFERENCES dim_pet_type(pet_type_id),
    pet_breed   INT REFERENCES dim_pet_breed(pet_breed_id)
);

CREATE TABLE dim_category (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE dim_pet_category (
    pet_category_id   SERIAL PRIMARY KEY,
    category_name     VARCHAR(100) NOT NULL
);

CREATE TABLE dim_brand (
    brand_id    SERIAL PRIMARY KEY,
    brand_name  VARCHAR(100) NOT NULL
);

CREATE TABLE dim_date (
    date_id      SERIAL PRIMARY KEY,
    full_date    DATE NOT NULL,
    year         INT,
    month        INT,
    day_of_week  INT
);

-- Измерения

CREATE TABLE dim_customer (
    customer_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(100),
    last_name     VARCHAR(100),
    age           INT,
    email         VARCHAR(255),
    location_id   INT REFERENCES dim_location(location_id),
    pet_id        INT REFERENCES dim_pet(pet_id),
    pet_name      VARCHAR(100)
);

CREATE TABLE dim_seller (
    seller_id    SERIAL PRIMARY KEY,
    first_name   VARCHAR(100),
    last_name    VARCHAR(100),
    email        VARCHAR(255),
    location_id  INT REFERENCES dim_location(location_id)
);

CREATE TABLE dim_product (
    product_id          SERIAL PRIMARY KEY,
    product_name        VARCHAR(255),
    category_id         INT REFERENCES dim_category(category_id),
    pet_category_id     INT REFERENCES dim_pet_category(pet_category_id),
    brand_id            INT REFERENCES dim_brand(brand_id),
    price               NUMERIC(10,2),
    quantity            INT,
    weight              NUMERIC(10,2),
    color               VARCHAR(50),
    size                VARCHAR(50),
    material            VARCHAR(100),
    description         TEXT,
    rating              NUMERIC(3,1),
    reviews             INT,
    release_date_id     INT REFERENCES dim_date(date_id),
    expiry_date_id      INT REFERENCES dim_date(date_id)
);

CREATE TABLE dim_store (
    store_id     SERIAL PRIMARY KEY,
    store_name   VARCHAR(255),
    location_id  INT REFERENCES dim_location(location_id),
    phone        VARCHAR(50),
    email        VARCHAR(255)
);

CREATE TABLE dim_supplier (
    supplier_id  SERIAL PRIMARY KEY,
    name         VARCHAR(255),
    contact      VARCHAR(255),
    email        VARCHAR(255),
    phone        VARCHAR(50),
    location_id  INT REFERENCES dim_location(location_id)
);

-- Факты

CREATE TABLE fact_sales (
    sale_id      SERIAL PRIMARY KEY,
    date_id      INT REFERENCES dim_date(date_id),
    customer_id  INT REFERENCES dim_customer(customer_id),
    seller_id    INT REFERENCES dim_seller(seller_id),
    product_id   INT REFERENCES dim_product(product_id),
    store_id     INT REFERENCES dim_store(store_id),
    supplier_id  INT REFERENCES dim_supplier(supplier_id),
    quantity     INT,
    total_price  NUMERIC(10,2)
);
