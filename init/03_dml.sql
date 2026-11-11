TRUNCATE TABLE fact_sales, dim_product, dim_store, dim_seller, dim_customer, dim_supplier, dim_date, dim_material, dim_size, dim_color, dim_brand, dim_pet_category, dim_product_category, dim_pet_breed, dim_pet_type, dim_city, dim_country RESTART IDENTITY CASCADE;

INSERT INTO dim_country (name)
SELECT DISTINCT country
FROM (
    SELECT customer_country AS country FROM mock_data
    UNION ALL
    SELECT seller_country FROM mock_data
    UNION ALL
    SELECT store_country FROM mock_data
    UNION ALL
    SELECT supplier_country FROM mock_data
) c;

INSERT INTO dim_pet_type (name)
SELECT DISTINCT customer_pet_type
FROM mock_data;

INSERT INTO dim_pet_breed (name)
SELECT DISTINCT customer_pet_breed
FROM mock_data;

INSERT INTO dim_product_category (name)
SELECT DISTINCT product_category
FROM mock_data;

INSERT INTO dim_pet_category (name)
SELECT DISTINCT pet_category
FROM mock_data;

INSERT INTO dim_brand (name)
SELECT DISTINCT product_brand
FROM mock_data;

INSERT INTO dim_color (name)
SELECT DISTINCT product_color
FROM mock_data;

INSERT INTO dim_size (name)
SELECT DISTINCT product_size
FROM mock_data;

INSERT INTO dim_material (name)
SELECT DISTINCT product_material
FROM mock_data;

INSERT INTO dim_city (name, country_key)
SELECT DISTINCT x.city, co.country_key
FROM (
    SELECT store_city AS city, store_country AS country FROM mock_data
    UNION ALL
    SELECT supplier_city, supplier_country FROM mock_data
) x
JOIN dim_country co ON co.name = x.country;

INSERT INTO dim_supplier (name, contact, email, phone, address, city_key)
SELECT DISTINCT
    m.supplier_name,
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    m.supplier_address,
    ci.city_key
FROM mock_data m
JOIN dim_country co ON co.name = m.supplier_country
JOIN dim_city ci ON ci.name = m.supplier_city AND ci.country_key = co.country_key;

INSERT INTO dim_customer (first_name, last_name, age, email, postal_code, country_key, pet_type_key, pet_breed_key, pet_name)
SELECT DISTINCT
    m.customer_first_name,
    m.customer_last_name,
    m.customer_age,
    m.customer_email,
    NULLIF(m.customer_postal_code, ''),
    co.country_key,
    pt.pet_type_key,
    pb.pet_breed_key,
    m.customer_pet_name
FROM mock_data m
JOIN dim_country co ON co.name = m.customer_country
JOIN dim_pet_type pt ON pt.name = m.customer_pet_type
JOIN dim_pet_breed pb ON pb.name = m.customer_pet_breed;

INSERT INTO dim_seller (first_name, last_name, email, postal_code, country_key)
SELECT DISTINCT
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    NULLIF(m.seller_postal_code, ''),
    co.country_key
FROM mock_data m
JOIN dim_country co ON co.name = m.seller_country;

INSERT INTO dim_store (name, location, city_key, state, phone, email)
SELECT DISTINCT
    m.store_name,
    m.store_location,
    ci.city_key,
    NULLIF(m.store_state, ''),
    m.store_phone,
    m.store_email
FROM mock_data m
JOIN dim_country co ON co.name = m.store_country
JOIN dim_city ci ON ci.name = m.store_city AND ci.country_key = co.country_key;

INSERT INTO dim_product (name, price, stock_quantity, weight, description, rating, reviews, release_date, expiry_date, product_category_key, pet_category_key, brand_key, color_key, size_key, material_key, supplier_key)
SELECT DISTINCT
    m.product_name,
    m.product_price,
    m.product_quantity,
    m.product_weight,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    m.product_release_date,
    m.product_expiry_date,
    pc.product_category_key,
    pcat.pet_category_key,
    b.brand_key,
    col.color_key,
    sz.size_key,
    mat.material_key,
    su.supplier_key
FROM mock_data m
JOIN dim_product_category pc ON pc.name = m.product_category
JOIN dim_pet_category pcat ON pcat.name = m.pet_category
JOIN dim_brand b ON b.name = m.product_brand
JOIN dim_color col ON col.name = m.product_color
JOIN dim_size sz ON sz.name = m.product_size
JOIN dim_material mat ON mat.name = m.product_material
JOIN dim_country suc ON suc.name = m.supplier_country
JOIN dim_city suci ON suci.name = m.supplier_city AND suci.country_key = suc.country_key
JOIN dim_supplier su
    ON su.name = m.supplier_name
   AND su.contact = m.supplier_contact
   AND su.email = m.supplier_email
   AND su.phone = m.supplier_phone
   AND su.address = m.supplier_address
   AND su.city_key = suci.city_key;

INSERT INTO dim_date (date_key, day, month, month_name, quarter, year, day_of_week, day_name, is_weekend)
SELECT
    sale_date,
    EXTRACT(DAY FROM sale_date)::smallint,
    EXTRACT(MONTH FROM sale_date)::smallint,
    TO_CHAR(sale_date, 'TMMonth'),
    EXTRACT(QUARTER FROM sale_date)::smallint,
    EXTRACT(YEAR FROM sale_date)::smallint,
    EXTRACT(ISODOW FROM sale_date)::smallint,
    TO_CHAR(sale_date, 'TMDay'),
    EXTRACT(ISODOW FROM sale_date) IN (6, 7)
FROM (
    SELECT DISTINCT sale_date
    FROM mock_data
) d;

INSERT INTO fact_sales (date_key, customer_key, seller_key, product_key, store_key, quantity, total_price)
SELECT
    m.sale_date,
    c.customer_key,
    se.seller_key,
    p.product_key,
    st.store_key,
    m.sale_quantity,
    m.sale_total_price
FROM mock_data m
JOIN dim_country cc ON cc.name = m.customer_country
JOIN dim_pet_type pt ON pt.name = m.customer_pet_type
JOIN dim_pet_breed pb ON pb.name = m.customer_pet_breed
JOIN dim_customer c
    ON c.email = m.customer_email
   AND c.first_name = m.customer_first_name
   AND c.last_name = m.customer_last_name
   AND c.age = m.customer_age
   AND c.postal_code IS NOT DISTINCT FROM NULLIF(m.customer_postal_code, '')
   AND c.pet_name = m.customer_pet_name
   AND c.country_key = cc.country_key
   AND c.pet_type_key = pt.pet_type_key
   AND c.pet_breed_key = pb.pet_breed_key
JOIN dim_country sec ON sec.name = m.seller_country
JOIN dim_seller se
    ON se.email = m.seller_email
   AND se.first_name = m.seller_first_name
   AND se.last_name = m.seller_last_name
   AND se.postal_code IS NOT DISTINCT FROM NULLIF(m.seller_postal_code, '')
   AND se.country_key = sec.country_key
JOIN dim_country stc ON stc.name = m.store_country
JOIN dim_city stci ON stci.name = m.store_city AND stci.country_key = stc.country_key
JOIN dim_store st
    ON st.name = m.store_name
   AND st.location = m.store_location
   AND st.state IS NOT DISTINCT FROM NULLIF(m.store_state, '')
   AND st.phone = m.store_phone
   AND st.email = m.store_email
   AND st.city_key = stci.city_key
JOIN dim_product_category pc ON pc.name = m.product_category
JOIN dim_pet_category pcat ON pcat.name = m.pet_category
JOIN dim_brand b ON b.name = m.product_brand
JOIN dim_color col ON col.name = m.product_color
JOIN dim_size sz ON sz.name = m.product_size
JOIN dim_material mat ON mat.name = m.product_material
JOIN dim_country suc ON suc.name = m.supplier_country
JOIN dim_city suci ON suci.name = m.supplier_city AND suci.country_key = suc.country_key
JOIN dim_supplier su
    ON su.name = m.supplier_name
   AND su.contact = m.supplier_contact
   AND su.email = m.supplier_email
   AND su.phone = m.supplier_phone
   AND su.address = m.supplier_address
   AND su.city_key = suci.city_key
JOIN dim_product p
    ON p.name = m.product_name
   AND p.price = m.product_price
   AND p.stock_quantity = m.product_quantity
   AND p.weight = m.product_weight
   AND p.description = m.product_description
   AND p.rating = m.product_rating
   AND p.reviews = m.product_reviews
   AND p.release_date = m.product_release_date
   AND p.expiry_date = m.product_expiry_date
   AND p.product_category_key = pc.product_category_key
   AND p.pet_category_key = pcat.pet_category_key
   AND p.brand_key = b.brand_key
   AND p.color_key = col.color_key
   AND p.size_key = sz.size_key
   AND p.material_key = mat.material_key
   AND p.supplier_key = su.supplier_key;
