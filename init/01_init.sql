-- =============================================================
-- Автоматическая инициализация БД при старте контейнера
-- Выполняется один раз при первом запуске postgres
-- =============================================================

CREATE TABLE IF NOT EXISTS mock_data (
    id INTEGER,
    customer_first_name VARCHAR(100),
    customer_last_name VARCHAR(100),
    customer_age INTEGER,
    customer_email VARCHAR(200),
    customer_country VARCHAR(100),
    customer_postal_code VARCHAR(20),
    customer_pet_type VARCHAR(50),
    customer_pet_name VARCHAR(100),
    customer_pet_breed VARCHAR(100),
    seller_first_name VARCHAR(100),
    seller_last_name VARCHAR(100),
    seller_email VARCHAR(200),
    seller_country VARCHAR(100),
    seller_postal_code VARCHAR(20),
    product_name VARCHAR(200),
    product_category VARCHAR(100),
    product_price NUMERIC(10,2),
    product_quantity INTEGER,
    sale_date VARCHAR(20),
    sale_customer_id INTEGER,
    sale_seller_id INTEGER,
    sale_product_id INTEGER,
    sale_quantity INTEGER,
    sale_total_price NUMERIC(10,2),
    store_name VARCHAR(200),
    store_location VARCHAR(200),
    store_city VARCHAR(100),
    store_state VARCHAR(100),
    store_country VARCHAR(100),
    store_phone VARCHAR(50),
    store_email VARCHAR(200),
    pet_category VARCHAR(100),
    product_weight NUMERIC(10,2),
    product_color VARCHAR(50),
    product_size VARCHAR(50),
    product_brand VARCHAR(100),
    product_material VARCHAR(100),
    product_description TEXT,
    product_rating NUMERIC(3,1),
    product_reviews INTEGER,
    product_release_date VARCHAR(20),
    product_expiry_date VARCHAR(20),
    supplier_name VARCHAR(200),
    supplier_contact VARCHAR(200),
    supplier_email VARCHAR(200),
    supplier_phone VARCHAR(50),
    supplier_address VARCHAR(200),
    supplier_city VARCHAR(100),
    supplier_country VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dim_country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    age INTEGER,
    email VARCHAR(200),
    country_id INTEGER REFERENCES dim_country(country_id),
    postal_code VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS dim_pet (
    pet_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES dim_customer(customer_id),
    pet_type VARCHAR(50),
    pet_name VARCHAR(100),
    pet_breed VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dim_seller (
    seller_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    country_id INTEGER REFERENCES dim_country(country_id),
    postal_code VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS dim_brand (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_product_category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(200),
    category_id INTEGER REFERENCES dim_product_category(category_id),
    pet_category VARCHAR(100),
    price NUMERIC(10,2),
    quantity INTEGER,
    weight NUMERIC(10,2),
    color VARCHAR(50),
    size VARCHAR(50),
    brand_id INTEGER REFERENCES dim_brand(brand_id),
    material VARCHAR(100),
    description TEXT,
    rating NUMERIC(3,1),
    reviews INTEGER,
    release_date DATE,
    expiry_date DATE
);

CREATE TABLE IF NOT EXISTS dim_store (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(200),
    location VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(100),
    country_id INTEGER REFERENCES dim_country(country_id),
    phone VARCHAR(50),
    email VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS dim_supplier (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(200),
    contact_name VARCHAR(200),
    email VARCHAR(200),
    phone VARCHAR(50),
    address VARCHAR(200),
    city VARCHAR(100),
    country_id INTEGER REFERENCES dim_country(country_id)
);

CREATE TABLE IF NOT EXISTS dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day INTEGER,
    month INTEGER,
    year INTEGER,
    quarter INTEGER,
    day_of_week INTEGER,
    week_of_year INTEGER
);

CREATE TABLE IF NOT EXISTS fact_sales (
    sale_id SERIAL PRIMARY KEY,
    date_id INTEGER REFERENCES dim_date(date_id),
    customer_id INTEGER REFERENCES dim_customer(customer_id),
    seller_id INTEGER REFERENCES dim_seller(seller_id),
    product_id INTEGER REFERENCES dim_product(product_id),
    store_id INTEGER REFERENCES dim_store(store_id),
    supplier_id INTEGER REFERENCES dim_supplier(supplier_id),
    sale_quantity INTEGER,
    sale_total_price NUMERIC(10,2),
    source_id INTEGER
);

COPY mock_data FROM '/csv_data/MOCK_DATA.csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (1).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (2).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (3).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (4).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (5).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (6).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (7).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (8).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (9).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

INSERT INTO dim_country (country_name)
SELECT DISTINCT country_name FROM (
    SELECT customer_country AS country_name FROM mock_data WHERE customer_country IS NOT NULL AND customer_country <> ''
    UNION
    SELECT seller_country FROM mock_data WHERE seller_country IS NOT NULL AND seller_country <> ''
    UNION
    SELECT store_country FROM mock_data WHERE store_country IS NOT NULL AND store_country <> ''
    UNION
    SELECT supplier_country FROM mock_data WHERE supplier_country IS NOT NULL AND supplier_country <> ''
) countries
ON CONFLICT (country_name) DO NOTHING;

INSERT INTO dim_customer (customer_id, first_name, last_name, age, email, country_id, postal_code)
SELECT DISTINCT ON (m.sale_customer_id)
    m.sale_customer_id,
    m.customer_first_name,
    m.customer_last_name,
    m.customer_age,
    m.customer_email,
    c.country_id,
    m.customer_postal_code
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = m.customer_country
ORDER BY m.sale_customer_id;

SELECT setval('dim_customer_customer_id_seq', (SELECT MAX(customer_id) FROM dim_customer));

INSERT INTO dim_pet (customer_id, pet_type, pet_name, pet_breed)
SELECT DISTINCT ON (m.sale_customer_id)
    m.sale_customer_id,
    m.customer_pet_type,
    m.customer_pet_name,
    m.customer_pet_breed
FROM mock_data m
WHERE m.customer_pet_type IS NOT NULL
ORDER BY m.sale_customer_id;

INSERT INTO dim_seller (seller_id, first_name, last_name, email, country_id, postal_code)
SELECT DISTINCT ON (m.sale_seller_id)
    m.sale_seller_id,
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    c.country_id,
    m.seller_postal_code
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = m.seller_country
ORDER BY m.sale_seller_id;

SELECT setval('dim_seller_seller_id_seq', (SELECT MAX(seller_id) FROM dim_seller));

INSERT INTO dim_brand (brand_name)
SELECT DISTINCT product_brand FROM mock_data
WHERE product_brand IS NOT NULL AND product_brand <> ''
ON CONFLICT (brand_name) DO NOTHING;

INSERT INTO dim_product_category (category_name)
SELECT DISTINCT product_category FROM mock_data
WHERE product_category IS NOT NULL AND product_category <> ''
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO dim_product (product_id, product_name, category_id, pet_category, price, quantity,
                         weight, color, size, brand_id, material, description,
                         rating, reviews, release_date, expiry_date)
SELECT DISTINCT ON (m.sale_product_id)
    m.sale_product_id,
    m.product_name,
    pc.category_id,
    m.pet_category,
    m.product_price,
    m.product_quantity,
    m.product_weight,
    m.product_color,
    m.product_size,
    b.brand_id,
    m.product_material,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    TO_DATE(m.product_release_date, 'MM/DD/YYYY'),
    TO_DATE(m.product_expiry_date, 'MM/DD/YYYY')
FROM mock_data m
LEFT JOIN dim_product_category pc ON pc.category_name = m.product_category
LEFT JOIN dim_brand b ON b.brand_name = m.product_brand
ORDER BY m.sale_product_id;

SELECT setval('dim_product_product_id_seq', (SELECT MAX(product_id) FROM dim_product));

INSERT INTO dim_store (store_name, location, city, state, country_id, phone, email)
SELECT DISTINCT ON (m.store_name, m.store_city)
    m.store_name,
    m.store_location,
    m.store_city,
    m.store_state,
    c.country_id,
    m.store_phone,
    m.store_email
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = m.store_country
ORDER BY m.store_name, m.store_city;

INSERT INTO dim_supplier (supplier_name, contact_name, email, phone, address, city, country_id)
SELECT DISTINCT ON (m.supplier_name)
    m.supplier_name,
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    m.supplier_address,
    m.supplier_city,
    c.country_id
FROM mock_data m
LEFT JOIN dim_country c ON c.country_name = m.supplier_country
ORDER BY m.supplier_name;

INSERT INTO dim_date (full_date, day, month, year, quarter, day_of_week, week_of_year)
SELECT DISTINCT
    d,
    EXTRACT(DAY FROM d)::INTEGER,
    EXTRACT(MONTH FROM d)::INTEGER,
    EXTRACT(YEAR FROM d)::INTEGER,
    EXTRACT(QUARTER FROM d)::INTEGER,
    EXTRACT(DOW FROM d)::INTEGER,
    EXTRACT(WEEK FROM d)::INTEGER
FROM (
    SELECT TO_DATE(sale_date, 'MM/DD/YYYY') AS d FROM mock_data WHERE sale_date IS NOT NULL
) dates
ON CONFLICT (full_date) DO NOTHING;

INSERT INTO fact_sales (date_id, customer_id, seller_id, product_id, store_id, supplier_id,
                        sale_quantity, sale_total_price, source_id)
SELECT
    dd.date_id,
    m.sale_customer_id,
    m.sale_seller_id,
    m.sale_product_id,
    ds.store_id,
    dsp.supplier_id,
    m.sale_quantity,
    m.sale_total_price,
    m.id
FROM mock_data m
LEFT JOIN dim_date dd ON dd.full_date = TO_DATE(m.sale_date, 'MM/DD/YYYY')
LEFT JOIN dim_store ds ON ds.store_name = m.store_name AND ds.city = m.store_city
LEFT JOIN dim_supplier dsp ON dsp.supplier_name = m.supplier_name;
