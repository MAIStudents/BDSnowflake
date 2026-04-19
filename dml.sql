-- DML: заполнение таблиц из mock_data
-- Порядок важен: сначала справочники, потом измерения, потом факты

-- 1. dim_country
INSERT INTO dim_country (country)
SELECT DISTINCT customer_country FROM mock_data WHERE customer_country IS NOT NULL
UNION
SELECT DISTINCT seller_country FROM mock_data WHERE seller_country IS NOT NULL
UNION
SELECT DISTINCT store_country FROM mock_data WHERE store_country IS NOT NULL
UNION
SELECT DISTINCT supplier_country FROM mock_data WHERE supplier_country IS NOT NULL;

-- 2. dim_city
INSERT INTO dim_city (city, state)
SELECT DISTINCT store_city, store_state FROM mock_data WHERE store_city IS NOT NULL
UNION
SELECT DISTINCT supplier_city, NULL FROM mock_data WHERE supplier_city IS NOT NULL;

-- 3. dim_location
-- customer
INSERT INTO dim_location (city_id, country_id, postal_code, address)
SELECT DISTINCT
    NULL::INT,
    c.country_id,
    m.customer_postal_code,
    NULL
FROM mock_data m
JOIN dim_country c ON c.country = m.customer_country;

-- seller
INSERT INTO dim_location (city_id, country_id, postal_code, address)
SELECT DISTINCT
    NULL::INT,
    c.country_id,
    m.seller_postal_code,
    NULL
FROM mock_data m
JOIN dim_country c ON c.country = m.seller_country
WHERE NOT EXISTS (
    SELECT 1 FROM dim_location dl
    JOIN dim_country dc ON dc.country_id = dl.country_id
    WHERE dc.country = m.seller_country
      AND COALESCE(dl.postal_code, '') = COALESCE(m.seller_postal_code, '')
);

-- store
INSERT INTO dim_location (city_id, country_id, postal_code, address)
SELECT DISTINCT
    ci.city_id,
    co.country_id,
    NULL::VARCHAR,
    m.store_location
FROM mock_data m
JOIN dim_city ci ON ci.city = m.store_city AND COALESCE(ci.state, '') = COALESCE(m.store_state, '')
JOIN dim_country co ON co.country = m.store_country;

-- supplier
INSERT INTO dim_location (city_id, country_id, postal_code, address)
SELECT DISTINCT
    ci.city_id,
    co.country_id,
    NULL::VARCHAR,
    m.supplier_address
FROM mock_data m
JOIN dim_city ci ON ci.city = m.supplier_city
JOIN dim_country co ON co.country = m.supplier_country;

-- 4.1 dim_pet_type
INSERT INTO dim_pet_type (type)
SELECT DISTINCT customer_pet_type
FROM mock_data
WHERE customer_pet_type IS NOT NULL;

-- 4.2 dim_pet_breed
INSERT INTO dim_pet_breed (breed)
SELECT DISTINCT customer_pet_breed
FROM mock_data
WHERE customer_pet_breed IS NOT NULL;

-- 4.3 dim_pet
INSERT INTO dim_pet (pet_type_id, pet_breed)
SELECT DISTINCT
    pt.pet_type_id,
    pb.pet_breed_id
FROM mock_data m
JOIN dim_pet_type pt ON pt.type = m.customer_pet_type
JOIN dim_pet_breed pb ON pb.breed = m.customer_pet_breed;

-- 5. dim_category
INSERT INTO dim_category (category_name)
SELECT DISTINCT product_category FROM mock_data WHERE product_category IS NOT NULL;

-- 6. dim_pet_category
INSERT INTO dim_pet_category (category_name)
SELECT DISTINCT pet_category FROM mock_data WHERE pet_category IS NOT NULL;

-- 7. dim_brand
INSERT INTO dim_brand (brand_name)
SELECT DISTINCT product_brand FROM mock_data WHERE product_brand IS NOT NULL;

-- 8. dim_date
INSERT INTO dim_date (full_date, year, month, day_of_week)
SELECT DISTINCT
    d::DATE,
    EXTRACT(YEAR FROM d::DATE)::INT,
    EXTRACT(MONTH FROM d::DATE)::INT,
    EXTRACT(DOW FROM d::DATE)::INT
FROM (
    SELECT sale_date AS d FROM mock_data WHERE sale_date IS NOT NULL
    UNION
    SELECT product_release_date FROM mock_data WHERE product_release_date IS NOT NULL
    UNION
    SELECT product_expiry_date FROM mock_data WHERE product_expiry_date IS NOT NULL
) dates;

-- 9. dim_customer
INSERT INTO dim_customer (first_name, last_name, age, email, location_id, pet_id, pet_name)
SELECT DISTINCT ON (m.customer_email)
    m.customer_first_name,
    m.customer_last_name,
    m.customer_age,
    m.customer_email,
    dl.location_id,
    dp.pet_id,
    m.customer_pet_name
FROM mock_data m
JOIN dim_location dl ON dl.country_id = (SELECT country_id FROM dim_country WHERE country = m.customer_country)
    AND COALESCE(dl.postal_code, '') = COALESCE(m.customer_postal_code, '')
    AND dl.city_id IS NULL
JOIN dim_pet dp ON dp.pet_type_id = (SELECT pet_type_id FROM dim_pet_type WHERE type = m.customer_pet_type)
    AND dp.pet_breed = (SELECT pet_breed_id FROM dim_pet_breed WHERE breed = m.customer_pet_breed);

-- 10. dim_seller
INSERT INTO dim_seller (first_name, last_name, email, location_id)
SELECT DISTINCT ON (m.seller_email)
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    dl.location_id
FROM mock_data m
JOIN dim_location dl ON dl.country_id = (SELECT country_id FROM dim_country WHERE country = m.seller_country)
    AND COALESCE(dl.postal_code, '') = COALESCE(m.seller_postal_code, '')
    AND dl.city_id IS NULL;

-- 11. dim_product
INSERT INTO dim_product (
    product_name, category_id, pet_category_id, brand_id,
    price, quantity, weight, color, size, material,
    description, rating, reviews, release_date_id, expiry_date_id
)
SELECT DISTINCT ON (m.product_name, m.product_brand)
    m.product_name,
    dc.category_id,
    dpc.pet_category_id,
    db.brand_id,
    m.product_price,
    m.product_quantity,
    m.product_weight,
    m.product_color,
    m.product_size,
    m.product_material,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    dr.date_id,
    de.date_id
FROM mock_data m
JOIN dim_category dc ON dc.category_name = m.product_category
JOIN dim_pet_category dpc ON dpc.category_name = m.pet_category
JOIN dim_brand db ON db.brand_name = m.product_brand
JOIN dim_date dr ON dr.full_date = m.product_release_date::DATE
JOIN dim_date de ON de.full_date = m.product_expiry_date::DATE;

-- 12. dim_store
INSERT INTO dim_store (store_name, location_id, phone, email)
SELECT DISTINCT ON (m.store_name, m.store_city)
    m.store_name,
    dl.location_id,
    m.store_phone,
    m.store_email
FROM mock_data m
JOIN dim_city ci ON ci.city = m.store_city AND COALESCE(ci.state, '') = COALESCE(m.store_state, '')
JOIN dim_country co ON co.country = m.store_country
JOIN dim_location dl ON dl.city_id = ci.city_id AND dl.country_id = co.country_id;

-- 13. dim_supplier
INSERT INTO dim_supplier (name, contact, email, phone, location_id)
SELECT DISTINCT ON (m.supplier_name)
    m.supplier_name,
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    dl.location_id
FROM mock_data m
JOIN dim_city ci ON ci.city = m.supplier_city
JOIN dim_country co ON co.country = m.supplier_country
JOIN dim_location dl ON dl.city_id = ci.city_id AND dl.country_id = co.country_id;

-- 14. fact_sales
INSERT INTO fact_sales (date_id, customer_id, seller_id, product_id, store_id, supplier_id, quantity, total_price)
SELECT
    dd.date_id,
    dc.customer_id,
    ds.seller_id,
    dp.product_id,
    dst.store_id,
    dsu.supplier_id,
    m.sale_quantity,
    m.sale_total_price
FROM mock_data m
JOIN dim_date dd       ON dd.full_date   = m.sale_date::DATE
JOIN dim_customer dc   ON dc.email       = m.customer_email
JOIN dim_seller ds     ON ds.email       = m.seller_email
JOIN dim_product dp    ON dp.product_name = m.product_name
JOIN dim_brand db      ON db.brand_id    = dp.brand_id AND db.brand_name = m.product_brand
JOIN dim_store dst     ON dst.store_name = m.store_name
JOIN dim_location dls  ON dls.location_id = dst.location_id
JOIN dim_city ci       ON ci.city_id     = dls.city_id AND ci.city = m.store_city
JOIN dim_supplier dsu  ON dsu.name       = m.supplier_name;
