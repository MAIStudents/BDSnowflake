-- liquibase formatted sql
-- changeset admin:1

-- Заполнение таблицы стран
INSERT INTO snowflake.dim_country (country_name)
SELECT DISTINCT customer_country
FROM public.mock_data
WHERE customer_country IS NOT NULL
UNION
SELECT DISTINCT seller_country
FROM public.mock_data
WHERE seller_country IS NOT NULL
UNION
SELECT DISTINCT store_country
FROM public.mock_data
WHERE store_country IS NOT NULL
UNION
SELECT DISTINCT supplier_country
FROM public.mock_data
WHERE supplier_country IS NOT NULL;

-- Заполнение таблицы городов
INSERT INTO snowflake.dim_city (city_name, country_id)
SELECT DISTINCT store_city,
                c.country_id
FROM public.mock_data md
         JOIN snowflake.dim_country c ON c.country_name = md.store_country
WHERE md.store_city IS NOT NULL
UNION
SELECT DISTINCT supplier_city,
                c.country_id
FROM public.mock_data md
         JOIN snowflake.dim_country c ON c.country_name = md.supplier_country
WHERE md.supplier_city IS NOT NULL;

-- Заполнение таблицы адресов
INSERT INTO snowflake.dim_address (postal_code, city_id)
SELECT DISTINCT customer_postal_code,
                ci.city_id
FROM public.mock_data md
         JOIN snowflake.dim_country c ON c.country_name = md.customer_country
         JOIN snowflake.dim_city ci ON ci.city_name = md.store_city AND ci.country_id = c.country_id
WHERE md.customer_postal_code IS NOT NULL
UNION
SELECT DISTINCT seller_postal_code,
                ci.city_id
FROM public.mock_data md
         JOIN snowflake.dim_country c ON c.country_name = md.seller_country
         JOIN snowflake.dim_city ci ON ci.city_name = md.store_city AND ci.country_id = c.country_id
WHERE md.seller_postal_code IS NOT NULL
UNION
SELECT DISTINCT NULL as postal_code,
                ci.city_id
FROM public.mock_data md
         JOIN snowflake.dim_country c ON c.country_name = md.store_country
         JOIN snowflake.dim_city ci ON ci.city_name = md.store_city AND ci.country_id = c.country_id
WHERE md.store_name IS NOT NULL
UNION
SELECT DISTINCT NULL as postal_code,
                ci.city_id
FROM public.mock_data md
         JOIN snowflake.dim_country c ON c.country_name = md.supplier_country
         JOIN snowflake.dim_city ci ON ci.city_name = md.supplier_city AND ci.country_id = c.country_id
WHERE md.supplier_name IS NOT NULL;

-- Заполнение таблицы клиентов
INSERT INTO snowflake.dim_customer (first_name, last_name, age, email, address_id)
SELECT DISTINCT md.customer_first_name,
                md.customer_last_name,
                md.customer_age,
                md.customer_email,
                a.address_id
FROM public.mock_data md
         LEFT JOIN snowflake.dim_country c ON c.country_name = md.customer_country
         LEFT JOIN snowflake.dim_city ci ON ci.city_name = md.store_city AND ci.country_id = c.country_id
         LEFT JOIN snowflake.dim_address a ON a.postal_code = md.customer_postal_code AND a.city_id = ci.city_id
WHERE md.customer_first_name IS NOT NULL;

-- Заполнение таблицы питомцев
INSERT INTO snowflake.dim_pet (pet_name, pet_type, pet_breed, pet_category)
SELECT DISTINCT customer_pet_name,
                customer_pet_type,
                customer_pet_breed,
                pet_category
FROM public.mock_data
WHERE customer_pet_name IS NOT NULL;

-- Заполнение таблицы продавцов
INSERT INTO snowflake.dim_seller (first_name, last_name, email, address_id)
SELECT DISTINCT md.seller_first_name,
                md.seller_last_name,
                md.seller_email,
                a.address_id
FROM public.mock_data md
         LEFT JOIN snowflake.dim_country c ON c.country_name = md.seller_country
         LEFT JOIN snowflake.dim_city ci ON ci.city_name = md.store_city AND ci.country_id = c.country_id
         LEFT JOIN snowflake.dim_address a ON a.postal_code = md.seller_postal_code AND a.city_id = ci.city_id
WHERE md.seller_first_name IS NOT NULL;

-- Заполнение таблицы магазинов
INSERT INTO snowflake.dim_store (store_name, address_id, phone, email)
SELECT DISTINCT md.store_name,
                a.address_id,
                md.store_phone,
                md.store_email
FROM public.mock_data md
         LEFT JOIN snowflake.dim_country c ON c.country_name = md.store_country
         LEFT JOIN snowflake.dim_city ci ON ci.city_name = md.store_city AND ci.country_id = c.country_id
         LEFT JOIN snowflake.dim_address a ON a.city_id = ci.city_id AND a.postal_code IS NULL
WHERE md.store_name IS NOT NULL;

-- Заполнение таблицы поставщиков
INSERT INTO snowflake.dim_supplier (supplier_name, contact, email, phone, address_id)
SELECT DISTINCT md.supplier_name,
                md.supplier_contact,
                md.supplier_email,
                md.supplier_phone,
                a.address_id
FROM public.mock_data md
         LEFT JOIN snowflake.dim_country c ON c.country_name = md.supplier_country
         LEFT JOIN snowflake.dim_city ci ON ci.city_name = md.supplier_city AND ci.country_id = c.country_id
         LEFT JOIN snowflake.dim_address a ON a.city_id = ci.city_id AND a.postal_code IS NULL
WHERE md.supplier_name IS NOT NULL;

-- Заполнение таблицы продуктов
INSERT INTO snowflake.dim_product (product_name, category, price, weight, color, size, brand,
                                   material, description, rating, reviews, release_date, expiry_date, supplier_id)
SELECT DISTINCT md.product_name,
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
                CASE
                    WHEN md.product_release_date IS NOT NULL AND md.product_release_date != ''
        THEN TO_DATE(md.product_release_date, 'MM/DD/YYYY')
                    ELSE NULL
                    END,
                CASE
                    WHEN md.product_expiry_date IS NOT NULL AND md.product_expiry_date != ''
        THEN TO_DATE(md.product_expiry_date, 'MM/DD/YYYY')
                    ELSE NULL
                    END,
                s.supplier_id
FROM public.mock_data md
         LEFT JOIN snowflake.dim_supplier s ON s.supplier_name = md.supplier_name
WHERE md.product_name IS NOT NULL;

-- Заполнение таблицы фактов продаж
INSERT INTO snowflake.fact_sales (customer_id, pet_id, seller_id, store_id, product_id,
                                  sale_date, quantity, total_price)
SELECT DISTINCT c.customer_id,
                p.pet_id,
                s.seller_id,
                st.store_id,
                pr.product_id,
                TO_DATE(md.sale_date, 'MM/DD/YYYY'),
                md.sale_quantity,
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
    st.store_name = md.store_name
         LEFT JOIN snowflake.dim_product pr ON
    pr.product_name = md.product_name AND
    pr.category = md.product_category
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
-- rollback TRUNCATE snowflake.dim_address;
-- rollback TRUNCATE snowflake.dim_city;
-- rollback TRUNCATE snowflake.dim_country;