-- dimensions
INSERT INTO dim_customer (first_name, last_name, age, email, country, postal_code)
SELECT DISTINCT 
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code
FROM mock_data
WHERE customer_email IS NOT NULL;

INSERT INTO dim_seller (first_name, last_name, email, country, postal_code)
SELECT DISTINCT 
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM mock_data
WHERE seller_email IS NOT NULL;

INSERT INTO dim_product (name, category, price, weight, color, size, brand, material, 
                         description, rating, reviews, release_date, expiry_date)
SELECT DISTINCT 
    product_name,
    product_category,
    product_price,
    product_weight,
    product_color,
    product_size,
    product_brand,
    product_material,
    product_description,
    product_rating,
    product_reviews,
    product_release_date,
    product_expiry_date
FROM mock_data
WHERE product_name IS NOT NULL;

INSERT INTO dim_pet (pet_type, pet_name, pet_breed, pet_category)
SELECT DISTINCT 
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed,
    pet_category
FROM mock_data
WHERE customer_pet_type IS NOT NULL OR customer_pet_name IS NOT NULL;

INSERT INTO dim_store (name, location, city, state, country, phone, email)
SELECT DISTINCT 
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM mock_data
WHERE store_name IS NOT NULL;

INSERT INTO dim_supplier (name, contact, email, phone, address, city, country)
SELECT DISTINCT 
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM mock_data
WHERE supplier_name IS NOT NULL;

INSERT INTO dim_date (date_id, full_date, year, month, day, quarter, week, weekday, is_weekend)
SELECT DISTINCT 
    TO_CHAR(d, 'YYYYMMDD')::INTEGER,
    d,
    EXTRACT(YEAR FROM d)::INTEGER,
    EXTRACT(MONTH FROM d)::INTEGER,
    EXTRACT(DAY FROM d)::INTEGER,
    EXTRACT(QUARTER FROM d)::INTEGER,
    EXTRACT(WEEK FROM d)::INTEGER,
    TO_CHAR(d, 'Day'),
    EXTRACT(DOW FROM d) IN (0,6)
FROM generate_series(
        (SELECT MIN(sale_date) FROM mock_data WHERE sale_date IS NOT NULL),
        (SELECT MAX(sale_date) FROM mock_data WHERE sale_date IS NOT NULL),
        '1 day'::interval
     ) AS d
ON CONFLICT (date_id) DO NOTHING;


-- fact_sales
INSERT INTO fact_sales (
    customer_id, 
    seller_id, 
    product_id, 
    pet_id, 
    store_id, 
    supplier_id, 
    date_id,
    quantity, 
    total_price, 
    unit_price
)
SELECT 
    c.customer_id,
    s.seller_id,
    p.product_id,
    pet.pet_id,
    st.store_id,
    sup.supplier_id,
    TO_CHAR(m.sale_date, 'YYYYMMDD')::INTEGER AS date_id,
    
    m.sale_quantity,
    m.sale_total_price,
    m.product_price AS unit_price
FROM mock_data m
LEFT JOIN dim_customer c 
    ON c.first_name = m.customer_first_name 
   AND c.last_name = m.customer_last_name 
   AND c.email = m.customer_email
LEFT JOIN dim_seller s 
    ON s.first_name = m.seller_first_name 
   AND s.last_name = m.seller_last_name 
   AND s.email = m.seller_email
LEFT JOIN dim_product p 
    ON p.name = m.product_name 
   AND p.category = m.product_category 
   AND p.price = m.product_price
LEFT JOIN dim_pet pet 
    ON pet.pet_type = m.customer_pet_type 
   AND pet.pet_name = m.customer_pet_name 
   AND pet.pet_breed = m.customer_pet_breed
LEFT JOIN dim_store st 
    ON st.name = m.store_name 
   AND st.city = m.store_city 
   AND st.country = m.store_country
LEFT JOIN dim_supplier sup 
    ON sup.name = m.supplier_name 
   AND sup.email = m.supplier_email
WHERE m.sale_date IS NOT NULL 
  AND m.sale_quantity > 0;