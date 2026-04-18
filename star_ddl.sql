-- Dimension tables

CREATE TABLE dim_customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    age INTEGER,
    email VARCHAR(255),
    country VARCHAR(100),
    postal_code VARCHAR(20)
);

CREATE TABLE dim_seller (
    seller_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    country VARCHAR(100),
    postal_code VARCHAR(20)
);

CREATE TABLE dim_product (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    category VARCHAR(100),
    price NUMERIC(10,2),
    weight NUMERIC(8,2),
    color VARCHAR(50),
    size VARCHAR(50),
    brand VARCHAR(100),
    material VARCHAR(100),
    description TEXT,
    rating NUMERIC(3,1),
    reviews INTEGER,
    release_date DATE,
    expiry_date DATE
);

CREATE TABLE dim_pet (
    pet_id SERIAL PRIMARY KEY,
    pet_type VARCHAR(50),
    pet_name VARCHAR(100),
    pet_breed VARCHAR(100),
    pet_category VARCHAR(100)
);

CREATE TABLE dim_store (
    store_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    location VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(255)
);

CREATE TABLE dim_supplier (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    contact VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    address VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE dim_date (
    date_id INTEGER PRIMARY KEY,
    full_date DATE NOT NULL,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    quarter INTEGER,
    week INTEGER,
    weekday VARCHAR(10),
    is_weekend BOOLEAN
);

-- Fact table

CREATE TABLE fact_sales (
    sales_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES dim_customer(customer_id),
    seller_id INTEGER NOT NULL REFERENCES dim_seller(seller_id),
    product_id INTEGER NOT NULL REFERENCES dim_product(product_id),
    pet_id INTEGER REFERENCES dim_pet(pet_id),
    store_id INTEGER REFERENCES dim_store(store_id),
    supplier_id INTEGER REFERENCES dim_supplier(supplier_id),
    date_id INTEGER NOT NULL REFERENCES dim_date(date_id),

    quantity INTEGER NOT NULL,
    total_price NUMERIC(10,2) NOT NULL,
    unit_price NUMERIC(10,2)
);



-- Indexes for dimension tables

CREATE INDEX idx_dim_customer_email ON dim_customer(email);
CREATE INDEX idx_dim_customer_country ON dim_customer(country);

CREATE INDEX idx_dim_seller_email ON dim_seller(email);
CREATE INDEX idx_dim_seller_country ON dim_seller(country);

CREATE INDEX idx_dim_product_category ON dim_product(category);
CREATE INDEX idx_dim_product_brand ON dim_product(brand);
CREATE INDEX idx_dim_product_name ON dim_product(name);

CREATE INDEX idx_dim_pet_type ON dim_pet(pet_type);
CREATE INDEX idx_dim_pet_category ON dim_pet(pet_category);

CREATE INDEX idx_dim_store_country ON dim_store(country);
CREATE INDEX idx_dim_store_city ON dim_store(city);

CREATE INDEX idx_dim_supplier_country ON dim_supplier(country);
CREATE INDEX idx_dim_supplier_city ON dim_supplier(city);

-- Indexes for fact table (самые важные)

CREATE INDEX idx_fact_sales_customer_id ON fact_sales(customer_id);
CREATE INDEX idx_fact_sales_seller_id ON fact_sales(seller_id);
CREATE INDEX idx_fact_sales_product_id ON fact_sales(product_id);
CREATE INDEX idx_fact_sales_date_id ON fact_sales(date_id);

CREATE INDEX idx_fact_sales_store_id ON fact_sales(store_id);
CREATE INDEX idx_fact_sales_supplier_id ON fact_sales(supplier_id);
CREATE INDEX idx_fact_sales_pet_id ON fact_sales(pet_id);

CREATE INDEX idx_fact_sales_date_customer ON fact_sales(date_id, customer_id);
CREATE INDEX idx_fact_sales_date_product ON fact_sales(date_id, product_id);
CREATE INDEX idx_fact_sales_product_date ON fact_sales(product_id, date_id);