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
  AND country_name <> ''
ON CONFLICT (country_name) DO NOTHING;

INSERT INTO dim_pet_type (pet_type_name)
SELECT DISTINCT customer_pet_type
FROM mock_data
WHERE customer_pet_type <> ''
ON CONFLICT (pet_type_name) DO NOTHING;

INSERT INTO dim_pet_category (pet_category_name)
SELECT DISTINCT pet_category
FROM mock_data
WHERE pet_category <> ''
ON CONFLICT (pet_category_name) DO NOTHING;

INSERT INTO dim_product_category (product_category_name)
SELECT DISTINCT product_category
FROM mock_data
WHERE product_category <> ''
ON CONFLICT (product_category_name) DO NOTHING;

INSERT INTO dim_supplier (
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    country_id
)
SELECT DISTINCT
    md.supplier_name,
    md.supplier_contact,
    md.supplier_email,
    md.supplier_phone,
    md.supplier_address,
    md.supplier_city,
    c.country_id
FROM mock_data md
JOIN dim_country c
  ON c.country_name = md.supplier_country
ON CONFLICT (supplier_email) DO NOTHING;

INSERT INTO dim_customer (
    first_name,
    last_name,
    age,
    email,
    postal_code,
    country_id,
    pet_type_id,
    pet_name,
    pet_breed
)
SELECT DISTINCT
    md.customer_first_name,
    md.customer_last_name,
    md.customer_age::INTEGER,
    md.customer_email,
    NULLIF(md.customer_postal_code, ''),
    c.country_id,
    pt.pet_type_id,
    md.customer_pet_name,
    md.customer_pet_breed
FROM mock_data md
JOIN dim_country c
  ON c.country_name = md.customer_country
JOIN dim_pet_type pt
  ON pt.pet_type_name = md.customer_pet_type
ON CONFLICT (email) DO NOTHING;

INSERT INTO dim_seller (
    first_name,
    last_name,
    email,
    postal_code,
    country_id
)
SELECT DISTINCT
    md.seller_first_name,
    md.seller_last_name,
    md.seller_email,
    NULLIF(md.seller_postal_code, ''),
    c.country_id
FROM mock_data md
JOIN dim_country c
  ON c.country_name = md.seller_country
ON CONFLICT (email) DO NOTHING;

INSERT INTO dim_store (
    store_name,
    store_location,
    city,
    state,
    phone,
    email,
    country_id
)
SELECT DISTINCT
    md.store_name,
    md.store_location,
    md.store_city,
    NULLIF(md.store_state, ''),
    md.store_phone,
    md.store_email,
    c.country_id
FROM mock_data md
JOIN dim_country c
  ON c.country_name = md.store_country
ON CONFLICT (email) DO NOTHING;

INSERT INTO dim_product (
    product_name,
    product_category_id,
    current_price,
    stock_quantity,
    pet_category_id,
    product_weight,
    color,
    size,
    brand,
    material,
    description,
    rating,
    reviews_count,
    release_date,
    expiry_date,
    supplier_id
)
SELECT DISTINCT
    md.product_name,
    pc.product_category_id,
    md.product_price::NUMERIC(10, 2),
    md.product_quantity::INTEGER,
    petc.pet_category_id,
    md.product_weight::NUMERIC(10, 2),
    md.product_color,
    md.product_size,
    md.product_brand,
    md.product_material,
    md.product_description,
    md.product_rating::NUMERIC(3, 1),
    md.product_reviews::INTEGER,
    TO_DATE(md.product_release_date, 'MM/DD/YYYY'),
    TO_DATE(md.product_expiry_date, 'MM/DD/YYYY'),
    s.supplier_id
FROM mock_data md
JOIN dim_product_category pc
  ON pc.product_category_name = md.product_category
JOIN dim_pet_category petc
  ON petc.pet_category_name = md.pet_category
JOIN dim_supplier s
  ON s.supplier_email = md.supplier_email
ON CONFLICT DO NOTHING;

INSERT INTO dim_date (
    date_id,
    full_date,
    day_of_month,
    month_number,
    month_name,
    quarter_number,
    year_number
)
SELECT DISTINCT
    TO_CHAR(TO_DATE(md.sale_date, 'MM/DD/YYYY'), 'YYYYMMDD')::INTEGER,
    TO_DATE(md.sale_date, 'MM/DD/YYYY'),
    EXTRACT(DAY FROM TO_DATE(md.sale_date, 'MM/DD/YYYY'))::INTEGER,
    EXTRACT(MONTH FROM TO_DATE(md.sale_date, 'MM/DD/YYYY'))::INTEGER,
    TRIM(TO_CHAR(TO_DATE(md.sale_date, 'MM/DD/YYYY'), 'Month')),
    EXTRACT(QUARTER FROM TO_DATE(md.sale_date, 'MM/DD/YYYY'))::INTEGER,
    EXTRACT(YEAR FROM TO_DATE(md.sale_date, 'MM/DD/YYYY'))::INTEGER
FROM mock_data md
ON CONFLICT (date_id) DO NOTHING;

INSERT INTO fact_sales (
    mock_data_key,
    source_sale_row_id,
    sale_customer_source_id,
    sale_seller_source_id,
    sale_product_source_id,
    sale_date_id,
    customer_id,
    seller_id,
    product_id,
    store_id,
    sale_quantity,
    sale_total_price
)
SELECT
    md.mock_data_key,
    md.id::INTEGER,
    md.sale_customer_id::INTEGER,
    md.sale_seller_id::INTEGER,
    md.sale_product_id::INTEGER,
    TO_CHAR(TO_DATE(md.sale_date, 'MM/DD/YYYY'), 'YYYYMMDD')::INTEGER,
    c.customer_id,
    s.seller_id,
    p.product_id,
    st.store_id,
    md.sale_quantity::INTEGER,
    md.sale_total_price::NUMERIC(10, 2)
FROM mock_data md
JOIN dim_customer c
  ON c.email = md.customer_email
JOIN dim_seller s
  ON s.email = md.seller_email
JOIN dim_store st
  ON st.email = md.store_email
JOIN dim_supplier sup
  ON sup.supplier_email = md.supplier_email
JOIN dim_product_category pc
  ON pc.product_category_name = md.product_category
JOIN dim_pet_category petc
  ON petc.pet_category_name = md.pet_category
JOIN dim_product p
  ON p.product_name = md.product_name
 AND p.product_category_id = pc.product_category_id
 AND p.current_price = md.product_price::NUMERIC(10, 2)
 AND p.stock_quantity = md.product_quantity::INTEGER
 AND p.pet_category_id = petc.pet_category_id
 AND p.product_weight = md.product_weight::NUMERIC(10, 2)
 AND p.color = md.product_color
 AND p.size = md.product_size
 AND p.brand = md.product_brand
 AND p.material = md.product_material
 AND p.description = md.product_description
 AND p.rating = md.product_rating::NUMERIC(3, 1)
 AND p.reviews_count = md.product_reviews::INTEGER
 AND p.release_date = TO_DATE(md.product_release_date, 'MM/DD/YYYY')
 AND p.expiry_date = TO_DATE(md.product_expiry_date, 'MM/DD/YYYY')
 AND p.supplier_id = sup.supplier_id
ON CONFLICT (mock_data_key) DO NOTHING;
