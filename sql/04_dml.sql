-- Страны
INSERT INTO dim_country (country_name)
SELECT DISTINCT country_name
FROM (
    SELECT customer_country AS country_name FROM mock_data
    UNION
    SELECT seller_country AS country_name FROM mock_data
    UNION
    SELECT store_country AS country_name FROM mock_data
    UNION
    SELECT supplier_country AS country_name FROM mock_data
) countries
WHERE country_name IS NOT NULL
  AND country_name <> '';

-- Города
INSERT INTO dim_city (city_name, country_id)
SELECT DISTINCT
    src.city_name,
    dc.country_id
FROM (
    SELECT store_city AS city_name, store_country AS country_name
    FROM mock_data
    WHERE store_city IS NOT NULL
      AND store_city <> ''
      AND store_country IS NOT NULL
      AND store_country <> ''
    UNION
    SELECT supplier_city AS city_name, supplier_country AS country_name
    FROM mock_data
    WHERE supplier_city IS NOT NULL
      AND supplier_city <> ''
      AND supplier_country IS NOT NULL
      AND supplier_country <> ''
) src
JOIN dim_country dc
  ON dc.country_name = src.country_name;

-- Категории товаров
INSERT INTO dim_product_category (category_name)
SELECT DISTINCT product_category
FROM mock_data
WHERE product_category IS NOT NULL
  AND product_category <> '';

-- Покупатели
INSERT INTO dim_customer (
    customer_id,
    first_name,
    last_name,
    age,
    email,
    postal_code,
    pet_type,
    pet_name,
    pet_breed,
    country_id
)
SELECT DISTINCT ON (md.sale_customer_id)
    md.sale_customer_id,
    md.customer_first_name,
    md.customer_last_name,
    md.customer_age,
    md.customer_email,
    md.customer_postal_code,
    md.customer_pet_type,
    md.customer_pet_name,
    md.customer_pet_breed,
    dc.country_id
FROM mock_data md
LEFT JOIN dim_country dc
  ON dc.country_name = md.customer_country
WHERE md.sale_customer_id IS NOT NULL
ORDER BY md.sale_customer_id, md.id;

-- Продавцы
INSERT INTO dim_seller (
    seller_id,
    first_name,
    last_name,
    email,
    postal_code,
    country_id
)
SELECT DISTINCT ON (md.sale_seller_id)
    md.sale_seller_id,
    md.seller_first_name,
    md.seller_last_name,
    md.seller_email,
    md.seller_postal_code,
    dc.country_id
FROM mock_data md
LEFT JOIN dim_country dc
  ON dc.country_name = md.seller_country
WHERE md.sale_seller_id IS NOT NULL
ORDER BY md.sale_seller_id, md.id;

-- Товары
INSERT INTO dim_product (
    product_id,
    product_name,
    category_id,
    pet_category,
    weight,
    color,
    size,
    brand,
    material,
    description,
    rating,
    reviews,
    release_date,
    expiry_date
)
SELECT DISTINCT ON (md.sale_product_id)
    md.sale_product_id,
    md.product_name,
    dpc.category_id,
    md.pet_category,
    md.product_weight,
    md.product_color,
    md.product_size,
    md.product_brand,
    md.product_material,
    md.product_description,
    md.product_rating,
    md.product_reviews,
    md.product_release_date,
    md.product_expiry_date
FROM mock_data md
LEFT JOIN dim_product_category dpc
  ON dpc.category_name = md.product_category
WHERE md.sale_product_id IS NOT NULL
ORDER BY md.sale_product_id, md.id;

-- Магазины
INSERT INTO dim_store (
    store_name,
    location,
    state,
    phone,
    email,
    city_id
)
SELECT DISTINCT
    md.store_name,
    md.store_location,
    md.store_state,
    md.store_phone,
    md.store_email,
    dcity.city_id
FROM mock_data md
LEFT JOIN dim_country dcountry
  ON dcountry.country_name = md.store_country
LEFT JOIN dim_city dcity
  ON dcity.city_name = md.store_city
 AND dcity.country_id = dcountry.country_id
WHERE md.store_name IS NOT NULL
  AND md.store_name <> '';

-- Поставщики
INSERT INTO dim_supplier (
    supplier_name,
    contact,
    email,
    phone,
    address,
    city_id
)
SELECT DISTINCT
    md.supplier_name,
    md.supplier_contact,
    md.supplier_email,
    md.supplier_phone,
    md.supplier_address,
    dcity.city_id
FROM mock_data md
LEFT JOIN dim_country dcountry
  ON dcountry.country_name = md.supplier_country
LEFT JOIN dim_city dcity
  ON dcity.city_name = md.supplier_city
 AND dcity.country_id = dcountry.country_id
WHERE md.supplier_name IS NOT NULL
  AND md.supplier_name <> '';

-- Даты
INSERT INTO dim_date (date_id, full_date, year, month, day, quarter, week_day)
SELECT DISTINCT
    TO_CHAR(md.sale_date, 'YYYYMMDD')::INTEGER,
    md.sale_date,
    EXTRACT(YEAR FROM md.sale_date)::INTEGER,
    EXTRACT(MONTH FROM md.sale_date)::INTEGER,
    EXTRACT(DAY FROM md.sale_date)::INTEGER,
    EXTRACT(QUARTER FROM md.sale_date)::INTEGER,
    EXTRACT(DOW FROM md.sale_date)::INTEGER
FROM mock_data md
WHERE md.sale_date IS NOT NULL;

-- Факты продаж
INSERT INTO fact_sales (
    date_id,
    customer_id,
    seller_id,
    product_id,
    store_id,
    supplier_id,
    quantity_sold,
    unit_price,
    total_amount
)
SELECT
    TO_CHAR(md.sale_date, 'YYYYMMDD')::INTEGER,
    md.sale_customer_id,
    md.sale_seller_id,
    md.sale_product_id,
    ds.store_id,
    dsp.supplier_id,
    md.sale_quantity,
    md.product_price,
    md.sale_total_price
FROM mock_data md
LEFT JOIN dim_country store_country
  ON store_country.country_name = md.store_country
LEFT JOIN dim_city store_city
  ON store_city.city_name = md.store_city
 AND store_city.country_id = store_country.country_id
LEFT JOIN dim_store ds
  ON ds.store_name = md.store_name
 AND COALESCE(ds.location, '') = COALESCE(md.store_location, '')
 AND COALESCE(ds.state, '') = COALESCE(md.store_state, '')
 AND COALESCE(ds.phone, '') = COALESCE(md.store_phone, '')
 AND COALESCE(ds.email, '') = COALESCE(md.store_email, '')
 AND ds.city_id IS NOT DISTINCT FROM store_city.city_id
LEFT JOIN dim_country supplier_country
  ON supplier_country.country_name = md.supplier_country
LEFT JOIN dim_city supplier_city
  ON supplier_city.city_name = md.supplier_city
 AND supplier_city.country_id = supplier_country.country_id
LEFT JOIN dim_supplier dsp
  ON dsp.supplier_name = md.supplier_name
 AND COALESCE(dsp.contact, '') = COALESCE(md.supplier_contact, '')
 AND COALESCE(dsp.email, '') = COALESCE(md.supplier_email, '')
 AND COALESCE(dsp.phone, '') = COALESCE(md.supplier_phone, '')
 AND COALESCE(dsp.address, '') = COALESCE(md.supplier_address, '')
 AND dsp.city_id IS NOT DISTINCT FROM supplier_city.city_id
WHERE md.sale_date IS NOT NULL;
