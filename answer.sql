DROP TABLE IF EXISTS FactSales CASCADE;

DROP TABLE IF EXISTS DimProduct CASCADE;

DROP TABLE IF EXISTS DimCustomer CASCADE;

DROP TABLE IF EXISTS DimSeller CASCADE;

DROP TABLE IF EXISTS DimStore CASCADE;

DROP TABLE IF EXISTS DimSupplier CASCADE;

DROP TABLE IF EXISTS DimPet CASCADE;

DROP TABLE IF EXISTS DimDate CASCADE;

DROP TABLE IF EXISTS DimBrand CASCADE;

DROP TABLE IF EXISTS DimCategory CASCADE;

DROP TABLE IF EXISTS DimLocation CASCADE;

CREATE TABLE IF NOT EXISTS DimLocation (
    location_id SERIAL PRIMARY KEY,
    country VARCHAR(255),
    city VARCHAR(255),
    postal_code VARCHAR(50),
    address TEXT
);

CREATE TABLE IF NOT EXISTS DimBrand (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR(255) UNIQUE
);

CREATE TABLE IF NOT EXISTS DimCategory (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(255) UNIQUE
);

CREATE TABLE IF NOT EXISTS DimPet (
    pet_id SERIAL PRIMARY KEY,
    pet_type VARCHAR(255),
    pet_name VARCHAR(255),
    pet_breed VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS DimDate (
    date_id INT PRIMARY KEY,
    full_date DATE NOT NULL,
    year SMALLINT NOT NULL,
    quarter SMALLINT NOT NULL,
    month SMALLINT NOT NULL,
    day SMALLINT NOT NULL,
    day_of_week SMALLINT NOT NULL,
    week_of_year SMALLINT NOT NULL
);

CREATE TABLE IF NOT EXISTS DimSupplier (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(255),
    supplier_contact VARCHAR(255),
    supplier_email VARCHAR(255),
    supplier_phone VARCHAR(50),
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES DimLocation (location_id)
);

CREATE TABLE IF NOT EXISTS DimProduct (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    product_description TEXT,
    product_price NUMERIC(10, 2),
    product_weight NUMERIC(10, 2),
    product_quantity INT,
    product_rating NUMERIC(3, 2),
    product_reviews INT,
    product_color VARCHAR(50),
    product_size VARCHAR(50),
    product_material VARCHAR(100),
    pet_category VARCHAR(100),
    product_release_date DATE,
    product_expiry_date DATE,
    brand_id INT,
    category_id INT,
    supplier_id INT,
    FOREIGN KEY (brand_id) REFERENCES DimBrand (brand_id),
    FOREIGN KEY (category_id) REFERENCES DimCategory (category_id),
    FOREIGN KEY (supplier_id) REFERENCES DimSupplier (supplier_id)
);

CREATE TABLE IF NOT EXISTS DimCustomer (
    customer_id INT PRIMARY KEY,
    customer_first_name VARCHAR(255),
    customer_last_name VARCHAR(255),
    customer_age SMALLINT,
    customer_email VARCHAR(255),
    location_id INT,
    pet_id INT,
    FOREIGN KEY (location_id) REFERENCES DimLocation (location_id),
    FOREIGN KEY (pet_id) REFERENCES DimPet (pet_id)
);

CREATE TABLE IF NOT EXISTS DimStore (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(255),
    store_phone VARCHAR(50),
    store_email VARCHAR(255),
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES DimLocation (location_id)
);

CREATE TABLE IF NOT EXISTS DimSeller (
    seller_id INT PRIMARY KEY,
    seller_first_name VARCHAR(255),
    seller_last_name VARCHAR(255),
    seller_email VARCHAR(255),
    store_id INT,
    FOREIGN KEY (store_id) REFERENCES DimStore (store_id)
);

CREATE TABLE IF NOT EXISTS FactSales (
    sale_id SERIAL PRIMARY KEY,
    sale_quantity INT,
    sale_total_price NUMERIC(12, 2),
    product_id INT,
    customer_id INT,
    seller_id INT,
    date_id INT,
    FOREIGN KEY (product_id) REFERENCES DimProduct (product_id),
    FOREIGN KEY (customer_id) REFERENCES DimCustomer (customer_id),
    FOREIGN KEY (seller_id) REFERENCES DimSeller (seller_id),
    FOREIGN KEY (date_id) REFERENCES DimDate (date_id)
);