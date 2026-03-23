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

INSERT INTO dim_state (state_nk, state_name, country_id)
SELECT DISTINCT
    CONCAT_WS('||', md.store_country, md.store_state),
    md.store_state,
    c.country_id
FROM mock_data md
JOIN dim_country c
  ON c.country_name = md.store_country
WHERE NULLIF(md.store_state, '') IS NOT NULL
ON CONFLICT (state_nk) DO NOTHING;

INSERT INTO dim_city (city_nk, city_name, state_id, country_id)
SELECT DISTINCT
    CONCAT_WS('||', md.store_country, COALESCE(NULLIF(md.store_state, ''), 'NO_STATE'), md.store_city),
    md.store_city,
    st.state_id,
    c.country_id
FROM mock_data md
JOIN dim_country c
  ON c.country_name = md.store_country
LEFT JOIN dim_state st
  ON st.state_nk = CONCAT_WS('||', md.store_country, md.store_state)
UNION
SELECT DISTINCT
    CONCAT_WS('||', md.supplier_country, 'NO_STATE', md.supplier_city),
    md.supplier_city,
    NULL::BIGINT,
    c.country_id
FROM mock_data md
JOIN dim_country c
  ON c.country_name = md.supplier_country
ON CONFLICT (city_nk) DO NOTHING;

INSERT INTO dim_address (address_nk, address_line, city_id)
SELECT DISTINCT
    CONCAT_WS(
        '||',
        md.store_location,
        CONCAT_WS('||', md.store_country, COALESCE(NULLIF(md.store_state, ''), 'NO_STATE'), md.store_city)
    ),
    md.store_location,
    city.city_id
FROM mock_data md
JOIN dim_city city
  ON city.city_nk = CONCAT_WS('||', md.store_country, COALESCE(NULLIF(md.store_state, ''), 'NO_STATE'), md.store_city)
UNION
SELECT DISTINCT
    CONCAT_WS('||', md.supplier_address, CONCAT_WS('||', md.supplier_country, 'NO_STATE', md.supplier_city)),
    md.supplier_address,
    city.city_id
FROM mock_data md
JOIN dim_city city
  ON city.city_nk = CONCAT_WS('||', md.supplier_country, 'NO_STATE', md.supplier_city)
ON CONFLICT (address_nk) DO NOTHING;

INSERT INTO dim_postal_code (postal_code_nk, postal_code, country_id)
SELECT DISTINCT
    CONCAT_WS('||', md.customer_country, md.customer_postal_code),
    md.customer_postal_code,
    c.country_id
FROM mock_data md
JOIN dim_country c
  ON c.country_name = md.customer_country
WHERE NULLIF(md.customer_postal_code, '') IS NOT NULL
UNION
SELECT DISTINCT
    CONCAT_WS('||', md.seller_country, md.seller_postal_code),
    md.seller_postal_code,
    c.country_id
FROM mock_data md
JOIN dim_country c
  ON c.country_name = md.seller_country
WHERE NULLIF(md.seller_postal_code, '') IS NOT NULL
ON CONFLICT (postal_code_nk) DO NOTHING;

INSERT INTO dim_pet_category (pet_category_name)
SELECT DISTINCT pet_category_name
FROM (
    SELECT pet_category AS pet_category_name
    FROM mock_data
    UNION
    SELECT INITCAP(customer_pet_type) || 's' AS pet_category_name
    FROM mock_data
) categories
WHERE pet_category_name IS NOT NULL
  AND pet_category_name <> ''
ON CONFLICT (pet_category_name) DO NOTHING;

INSERT INTO dim_pet_type (pet_type_name, pet_category_id)
SELECT DISTINCT
    md.customer_pet_type,
    pc.pet_category_id
FROM mock_data md
JOIN dim_pet_category pc
  ON pc.pet_category_name = INITCAP(md.customer_pet_type) || 's'
WHERE md.customer_pet_type <> ''
ON CONFLICT (pet_type_name) DO NOTHING;

INSERT INTO dim_pet_breed (pet_breed_name)
SELECT DISTINCT customer_pet_breed
FROM mock_data
WHERE customer_pet_breed <> ''
ON CONFLICT (pet_breed_name) DO NOTHING;

INSERT INTO dim_customer_pet (customer_pet_nk, pet_name, pet_type_id, pet_breed_id)
SELECT DISTINCT
    CONCAT_WS('||', md.customer_pet_name, md.customer_pet_type, md.customer_pet_breed),
    md.customer_pet_name,
    pt.pet_type_id,
    pb.pet_breed_id
FROM mock_data md
JOIN dim_pet_type pt
  ON pt.pet_type_name = md.customer_pet_type
JOIN dim_pet_breed pb
  ON pb.pet_breed_name = md.customer_pet_breed
ON CONFLICT (customer_pet_nk) DO NOTHING;

INSERT INTO dim_product_category (product_category_name)
SELECT DISTINCT product_category
FROM mock_data
WHERE product_category <> ''
ON CONFLICT (product_category_name) DO NOTHING;

INSERT INTO dim_product_brand (brand_name)
SELECT DISTINCT product_brand
FROM mock_data
WHERE product_brand <> ''
ON CONFLICT (brand_name) DO NOTHING;

INSERT INTO dim_product_material (material_name)
SELECT DISTINCT product_material
FROM mock_data
WHERE product_material <> ''
ON CONFLICT (material_name) DO NOTHING;

INSERT INTO dim_product_color (color_name)
SELECT DISTINCT product_color
FROM mock_data
WHERE product_color <> ''
ON CONFLICT (color_name) DO NOTHING;

INSERT INTO dim_product_size (size_name)
SELECT DISTINCT product_size
FROM mock_data
WHERE product_size <> ''
ON CONFLICT (size_name) DO NOTHING;

WITH all_dates AS (
    SELECT TO_DATE(sale_date, 'MM/DD/YYYY') AS full_date FROM mock_data
    UNION
    SELECT TO_DATE(product_release_date, 'MM/DD/YYYY') AS full_date FROM mock_data
    UNION
    SELECT TO_DATE(product_expiry_date, 'MM/DD/YYYY') AS full_date FROM mock_data
)
INSERT INTO dim_year (year_number)
SELECT DISTINCT EXTRACT(YEAR FROM full_date)::INTEGER
FROM all_dates
ON CONFLICT (year_number) DO NOTHING;

WITH all_dates AS (
    SELECT TO_DATE(sale_date, 'MM/DD/YYYY') AS full_date FROM mock_data
    UNION
    SELECT TO_DATE(product_release_date, 'MM/DD/YYYY') AS full_date FROM mock_data
    UNION
    SELECT TO_DATE(product_expiry_date, 'MM/DD/YYYY') AS full_date FROM mock_data
)
INSERT INTO dim_quarter (quarter_nk, quarter_number, year_id)
SELECT DISTINCT
    CONCAT(EXTRACT(YEAR FROM full_date)::INTEGER, '-Q', EXTRACT(QUARTER FROM full_date)::INTEGER),
    EXTRACT(QUARTER FROM full_date)::INTEGER,
    y.year_id
FROM all_dates
JOIN dim_year y
  ON y.year_number = EXTRACT(YEAR FROM full_date)::INTEGER
ON CONFLICT (quarter_nk) DO NOTHING;

WITH all_dates AS (
    SELECT TO_DATE(sale_date, 'MM/DD/YYYY') AS full_date FROM mock_data
    UNION
    SELECT TO_DATE(product_release_date, 'MM/DD/YYYY') AS full_date FROM mock_data
    UNION
    SELECT TO_DATE(product_expiry_date, 'MM/DD/YYYY') AS full_date FROM mock_data
)
INSERT INTO dim_month (month_nk, month_number, month_name, quarter_id)
SELECT DISTINCT
    TO_CHAR(full_date, 'YYYY-MM'),
    EXTRACT(MONTH FROM full_date)::INTEGER,
    TRIM(TO_CHAR(full_date, 'Month')),
    q.quarter_id
FROM all_dates
JOIN dim_quarter q
  ON q.quarter_nk = CONCAT(EXTRACT(YEAR FROM full_date)::INTEGER, '-Q', EXTRACT(QUARTER FROM full_date)::INTEGER)
ON CONFLICT (month_nk) DO NOTHING;

WITH all_dates AS (
    SELECT TO_DATE(sale_date, 'MM/DD/YYYY') AS full_date FROM mock_data
    UNION
    SELECT TO_DATE(product_release_date, 'MM/DD/YYYY') AS full_date FROM mock_data
    UNION
    SELECT TO_DATE(product_expiry_date, 'MM/DD/YYYY') AS full_date FROM mock_data
)
INSERT INTO dim_date (date_id, full_date, day_of_month, month_id)
SELECT DISTINCT
    TO_CHAR(full_date, 'YYYYMMDD')::INTEGER,
    full_date,
    EXTRACT(DAY FROM full_date)::INTEGER,
    m.month_id
FROM all_dates
JOIN dim_month m
  ON m.month_nk = TO_CHAR(full_date, 'YYYY-MM')
ON CONFLICT (date_id) DO NOTHING;

INSERT INTO dim_supplier (
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    address_id
)
SELECT DISTINCT
    md.supplier_name,
    md.supplier_contact,
    md.supplier_email,
    md.supplier_phone,
    a.address_id
FROM mock_data md
JOIN dim_address a
  ON a.address_nk = CONCAT_WS('||', md.supplier_address, CONCAT_WS('||', md.supplier_country, 'NO_STATE', md.supplier_city))
ON CONFLICT (supplier_email) DO NOTHING;

INSERT INTO dim_customer (
    first_name,
    last_name,
    age,
    email,
    country_id,
    postal_code_id,
    customer_pet_id
)
SELECT DISTINCT
    md.customer_first_name,
    md.customer_last_name,
    md.customer_age::INTEGER,
    md.customer_email,
    c.country_id,
    pc.postal_code_id,
    cp.customer_pet_id
FROM mock_data md
JOIN dim_country c
  ON c.country_name = md.customer_country
LEFT JOIN dim_postal_code pc
  ON pc.postal_code_nk = CONCAT_WS('||', md.customer_country, md.customer_postal_code)
JOIN dim_customer_pet cp
  ON cp.customer_pet_nk = CONCAT_WS('||', md.customer_pet_name, md.customer_pet_type, md.customer_pet_breed)
ON CONFLICT (email) DO NOTHING;

INSERT INTO dim_seller (
    first_name,
    last_name,
    email,
    country_id,
    postal_code_id
)
SELECT DISTINCT
    md.seller_first_name,
    md.seller_last_name,
    md.seller_email,
    c.country_id,
    pc.postal_code_id
FROM mock_data md
JOIN dim_country c
  ON c.country_name = md.seller_country
LEFT JOIN dim_postal_code pc
  ON pc.postal_code_nk = CONCAT_WS('||', md.seller_country, md.seller_postal_code)
ON CONFLICT (email) DO NOTHING;

INSERT INTO dim_store (
    store_name,
    phone,
    email,
    address_id
)
SELECT DISTINCT
    md.store_name,
    md.store_phone,
    md.store_email,
    a.address_id
FROM mock_data md
JOIN dim_address a
  ON a.address_nk = CONCAT_WS(
      '||',
      md.store_location,
      CONCAT_WS('||', md.store_country, COALESCE(NULLIF(md.store_state, ''), 'NO_STATE'), md.store_city)
  )
ON CONFLICT (email) DO NOTHING;

INSERT INTO dim_product (
    product_nk,
    product_name,
    product_category_id,
    current_price,
    stock_quantity,
    pet_category_id,
    product_weight,
    color_id,
    size_id,
    brand_id,
    material_id,
    description,
    rating,
    reviews_count,
    release_date_id,
    expiry_date_id,
    supplier_id
)
SELECT DISTINCT
    CONCAT_WS(
        '||',
        md.product_name,
        md.product_category,
        md.product_price,
        md.product_quantity,
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
        md.product_expiry_date,
        md.supplier_email
    ),
    md.product_name,
    pc.product_category_id,
    md.product_price::NUMERIC(10, 2),
    md.product_quantity::INTEGER,
    petc.pet_category_id,
    md.product_weight::NUMERIC(10, 2),
    col.color_id,
    sz.size_id,
    br.brand_id,
    mat.material_id,
    md.product_description,
    md.product_rating::NUMERIC(3, 1),
    md.product_reviews::INTEGER,
    rd.date_id,
    ed.date_id,
    s.supplier_id
FROM mock_data md
JOIN dim_product_category pc
  ON pc.product_category_name = md.product_category
JOIN dim_pet_category petc
  ON petc.pet_category_name = md.pet_category
JOIN dim_product_color col
  ON col.color_name = md.product_color
JOIN dim_product_size sz
  ON sz.size_name = md.product_size
JOIN dim_product_brand br
  ON br.brand_name = md.product_brand
JOIN dim_product_material mat
  ON mat.material_name = md.product_material
JOIN dim_date rd
  ON rd.full_date = TO_DATE(md.product_release_date, 'MM/DD/YYYY')
JOIN dim_date ed
  ON ed.full_date = TO_DATE(md.product_expiry_date, 'MM/DD/YYYY')
JOIN dim_supplier s
  ON s.supplier_email = md.supplier_email
ON CONFLICT (product_nk) DO NOTHING;

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
JOIN dim_product p
  ON p.product_nk = CONCAT_WS(
      '||',
      md.product_name,
      md.product_category,
      md.product_price,
      md.product_quantity,
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
      md.product_expiry_date,
      md.supplier_email
  )
ON CONFLICT (mock_data_key) DO NOTHING;
