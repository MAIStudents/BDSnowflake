-- liquibase formatted sql
-- changeset admin:1

-- Заполнение таблицы клиентов
INSERT INTO snowflake.dim_customer (first_name, last_name, age, email, country, postal_code)
SELECT DISTINCT
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code
FROM public.mock_data
WHERE customer_first_name IS NOT NULL;

-- Заполнение таблицы питомцев
INSERT INTO snowflake.dim_pet (pet_name, pet_type, pet_breed, pet_category)
SELECT DISTINCT
    customer_pet_name,
    customer_pet_type,
    customer_pet_breed,
    pet_category
FROM public.mock_data
WHERE customer_pet_name IS NOT NULL;

-- Заполнение таблицы продавцов
INSERT INTO snowflake.dim_seller (first_name, last_name, email, country, postal_code)
SELECT DISTINCT
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM public.mock_data
WHERE seller_first_name IS NOT NULL;

-- Заполнение таблицы магазинов
INSERT INTO snowflake.dim_store (store_name, location, city, state, country, phone, email)
SELECT DISTINCT
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM public.mock_data
WHERE store_name IS NOT NULL;

-- Заполнение таблицы поставщиков
INSERT INTO snowflake.dim_supplier (supplier_name, contact, email, phone, address, city, country)
SELECT DISTINCT
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM public.mock_data
WHERE supplier_name IS NOT NULL;

-- Заполнение таблицы продуктов (исправленный формат даты)
INSERT INTO snowflake.dim_product (
    product_name, category, price, weight, color, size, brand,
    material, description, rating, reviews, release_date, expiry_date, supplier_id
)
SELECT DISTINCT
    md.product_name,
    md.product_category,
    md.product_price,
    md.product_weight,
    md.product_color,
    md.product_size,
    md.product_brand,
    md.product_material,
    md.product_description,
    md.product_rating,
    md.product_reviews,
    -- Преобразование из формата MM/DD/YYYY в DATE
    TO_DATE(md.product_release_date, 'MM/DD/YYYY'),
    TO_DATE(md.product_expiry_date, 'MM/DD/YYYY'),
    s.supplier_id
FROM public.mock_data md
LEFT JOIN snowflake.dim_supplier s ON s.supplier_name = md.supplier_name
WHERE md.product_name IS NOT NULL
    AND md.product_release_date IS NOT NULL
    AND md.product_release_date != ''
    AND md.product_expiry_date IS NOT NULL
    AND md.product_expiry_date != '';

-- Заполнение таблицы дат (исправленный формат даты)
INSERT INTO snowflake.dim_date (full_date, year, quarter, month, month_name, day, day_of_week, weekday_name, is_weekend)
SELECT DISTINCT
    TO_DATE(sale_date, 'MM/DD/YYYY'),
    EXTRACT(YEAR FROM TO_DATE(sale_date, 'MM/DD/YYYY')),
    EXTRACT(QUARTER FROM TO_DATE(sale_date, 'MM/DD/YYYY')),
    EXTRACT(MONTH FROM TO_DATE(sale_date, 'MM/DD/YYYY')),
    TO_CHAR(TO_DATE(sale_date, 'MM/DD/YYYY'), 'Month'),
    EXTRACT(DAY FROM TO_DATE(sale_date, 'MM/DD/YYYY')),
    EXTRACT(DOW FROM TO_DATE(sale_date, 'MM/DD/YYYY')),
    TO_CHAR(TO_DATE(sale_date, 'MM/DD/YYYY'), 'Day'),
    CASE WHEN EXTRACT(DOW FROM TO_DATE(sale_date, 'MM/DD/YYYY')) IN (0, 6) THEN TRUE ELSE FALSE END
FROM public.mock_data
WHERE sale_date IS NOT NULL AND sale_date != '';

-- Заполнение таблицы фактов продаж
INSERT INTO snowflake.fact_sales (
    customer_id, pet_id, seller_id, store_id, product_id, date_id,
    quantity, unit_price, total_price
)
SELECT DISTINCT
    c.customer_id,
    p.pet_id,
    s.seller_id,
    st.store_id,
    pr.product_id,
    d.date_id,
    md.sale_quantity,
    md.product_price,
    md.sale_total_price
FROM public.mock_data md
LEFT JOIN snowflake.dim_customer c ON
    c.first_name = md.customer_first_name AND
    c.last_name = md.customer_last_name AND
    c.email = md.customer_email
LEFT JOIN snowflake.dim_pet p ON
    p.pet_name = md.customer_pet_name AND
    p.pet_type = md.customer_pet_type
LEFT JOIN snowflake.dim_seller s ON
    s.first_name = md.seller_first_name AND
    s.last_name = md.seller_last_name AND
    s.email = md.seller_email
LEFT JOIN snowflake.dim_store st ON
    st.store_name = md.store_name AND
    st.location = md.store_location
LEFT JOIN snowflake.dim_product pr ON
    pr.product_name = md.product_name AND
    pr.category = md.product_category
LEFT JOIN snowflake.dim_date d ON
    d.full_date = TO_DATE(md.sale_date, 'MM/DD/YYYY')
WHERE md.sale_quantity IS NOT NULL
    AND md.sale_date IS NOT NULL
    AND md.sale_date != '';

-- rollback TRUNCATE snowflake.fact_sales;
-- rollback TRUNCATE snowflake.dim_customer;
-- rollback TRUNCATE snowflake.dim_pet;
-- rollback TRUNCATE snowflake.dim_seller;
-- rollback TRUNCATE snowflake.dim_store;
-- rollback TRUNCATE snowflake.dim_product;
-- rollback TRUNCATE snowflake.dim_supplier;
-- rollback TRUNCATE snowflake.dim_date;