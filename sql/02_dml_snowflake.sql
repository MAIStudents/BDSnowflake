TRUNCATE TABLE fact_sales RESTART IDENTITY;
TRUNCATE TABLE dim_product RESTART IDENTITY CASCADE;
TRUNCATE TABLE dim_store RESTART IDENTITY CASCADE;
TRUNCATE TABLE dim_supplier RESTART IDENTITY CASCADE;
TRUNCATE TABLE dim_seller RESTART IDENTITY CASCADE;
TRUNCATE TABLE dim_pet RESTART IDENTITY CASCADE;
TRUNCATE TABLE dim_customer RESTART IDENTITY CASCADE;
TRUNCATE TABLE dim_material RESTART IDENTITY CASCADE;
TRUNCATE TABLE dim_brand RESTART IDENTITY CASCADE;
TRUNCATE TABLE dim_product_category RESTART IDENTITY CASCADE;
TRUNCATE TABLE dim_pet_category RESTART IDENTITY CASCADE;
TRUNCATE TABLE dim_pet_type RESTART IDENTITY CASCADE;
TRUNCATE TABLE dim_country RESTART IDENTITY CASCADE;

INSERT INTO dim_country (country_name)
SELECT DISTINCT country_name
FROM (
    SELECT NULLIF(TRIM(customer_country), '') AS country_name FROM stg_pet_sales
    UNION
    SELECT NULLIF(TRIM(seller_country), '') AS country_name FROM stg_pet_sales
    UNION
    SELECT NULLIF(TRIM(store_country), '') AS country_name FROM stg_pet_sales
    UNION
    SELECT NULLIF(TRIM(supplier_country), '') AS country_name FROM stg_pet_sales
) countries
WHERE country_name IS NOT NULL;

INSERT INTO dim_pet_type (pet_type_name)
SELECT DISTINCT NULLIF(TRIM(customer_pet_type), '')
FROM stg_pet_sales
WHERE NULLIF(TRIM(customer_pet_type), '') IS NOT NULL;

INSERT INTO dim_pet_category (pet_category_name)
SELECT DISTINCT NULLIF(TRIM(pet_category), '')
FROM stg_pet_sales
WHERE NULLIF(TRIM(pet_category), '') IS NOT NULL;

INSERT INTO dim_product_category (product_category_name)
SELECT DISTINCT NULLIF(TRIM(product_category), '')
FROM stg_pet_sales
WHERE NULLIF(TRIM(product_category), '') IS NOT NULL;

INSERT INTO dim_brand (brand_name)
SELECT DISTINCT NULLIF(TRIM(product_brand), '')
FROM stg_pet_sales
WHERE NULLIF(TRIM(product_brand), '') IS NOT NULL;

INSERT INTO dim_material (material_name)
SELECT DISTINCT NULLIF(TRIM(product_material), '')
FROM stg_pet_sales
WHERE NULLIF(TRIM(product_material), '') IS NOT NULL;

INSERT INTO dim_customer (
    first_name,
    last_name,
    age,
    email,
    postal_code,
    country_id
)
SELECT DISTINCT
    TRIM(customer_first_name),
    TRIM(customer_last_name),
    customer_age,
    TRIM(customer_email),
    NULLIF(TRIM(customer_postal_code), ''),
    c.country_id
FROM stg_pet_sales s
LEFT JOIN dim_country c
    ON c.country_name = NULLIF(TRIM(s.customer_country), '')
WHERE NULLIF(TRIM(customer_email), '') IS NOT NULL;

INSERT INTO dim_pet (
    pet_name,
    pet_breed,
    pet_type_id,
    pet_category_id,
    owner_email
)
SELECT DISTINCT
    NULLIF(TRIM(s.customer_pet_name), ''),
    NULLIF(TRIM(s.customer_pet_breed), ''),
    pt.pet_type_id,
    pc.pet_category_id,
    TRIM(s.customer_email)
FROM stg_pet_sales s
LEFT JOIN dim_pet_type pt
    ON pt.pet_type_name = NULLIF(TRIM(s.customer_pet_type), '')
LEFT JOIN dim_pet_category pc
    ON pc.pet_category_name = NULLIF(TRIM(s.pet_category), '')
WHERE NULLIF(TRIM(s.customer_email), '') IS NOT NULL;

INSERT INTO dim_seller (
    first_name,
    last_name,
    email,
    postal_code,
    country_id
)
SELECT DISTINCT
    TRIM(seller_first_name),
    TRIM(seller_last_name),
    TRIM(seller_email),
    NULLIF(TRIM(seller_postal_code), ''),
    c.country_id
FROM stg_pet_sales s
LEFT JOIN dim_country c
    ON c.country_name = NULLIF(TRIM(s.seller_country), '')
WHERE NULLIF(TRIM(seller_email), '') IS NOT NULL;

INSERT INTO dim_supplier (
    supplier_name,
    contact_name,
    email,
    phone,
    address_line,
    city,
    country_id
)
SELECT DISTINCT
    TRIM(supplier_name),
    NULLIF(TRIM(supplier_contact), ''),
    TRIM(supplier_email),
    NULLIF(TRIM(supplier_phone), ''),
    NULLIF(TRIM(supplier_address), ''),
    NULLIF(TRIM(supplier_city), ''),
    c.country_id
FROM stg_pet_sales s
LEFT JOIN dim_country c
    ON c.country_name = NULLIF(TRIM(s.supplier_country), '')
WHERE NULLIF(TRIM(supplier_email), '') IS NOT NULL;

INSERT INTO dim_store (
    store_name,
    location_name,
    city,
    state_name,
    country_id,
    phone,
    email
)
SELECT DISTINCT
    TRIM(store_name),
    NULLIF(TRIM(store_location), ''),
    NULLIF(TRIM(store_city), ''),
    NULLIF(TRIM(store_state), ''),
    c.country_id,
    NULLIF(TRIM(store_phone), ''),
    TRIM(store_email)
FROM stg_pet_sales s
LEFT JOIN dim_country c
    ON c.country_name = NULLIF(TRIM(s.store_country), '')
WHERE NULLIF(TRIM(store_email), '') IS NOT NULL;

INSERT INTO dim_product (
    product_name,
    product_category_id,
    brand_id,
    material_id,
    supplier_id,
    price,
    available_quantity,
    weight,
    color,
    size_name,
    description,
    rating,
    reviews_count,
    release_date,
    expiry_date
)
SELECT DISTINCT
    TRIM(s.product_name),
    pc.product_category_id,
    b.brand_id,
    m.material_id,
    sup.supplier_id,
    s.product_price,
    s.product_quantity,
    s.product_weight,
    NULLIF(TRIM(s.product_color), ''),
    NULLIF(TRIM(s.product_size), ''),
    NULLIF(TRIM(s.product_description), ''),
    s.product_rating,
    s.product_reviews,
    TO_DATE(s.product_release_date, 'MM/DD/YYYY'),
    TO_DATE(s.product_expiry_date, 'MM/DD/YYYY')
FROM stg_pet_sales s
LEFT JOIN dim_product_category pc
    ON pc.product_category_name = NULLIF(TRIM(s.product_category), '')
LEFT JOIN dim_brand b
    ON b.brand_name = NULLIF(TRIM(s.product_brand), '')
LEFT JOIN dim_material m
    ON m.material_name = NULLIF(TRIM(s.product_material), '')
LEFT JOIN dim_supplier sup
    ON sup.email = TRIM(s.supplier_email);

INSERT INTO fact_sales (
    staging_id,
    source_row_id,
    sale_date,
    source_customer_id,
    source_seller_id,
    source_product_id,
    sale_quantity,
    sale_total_price,
    customer_id,
    pet_id,
    seller_id,
    product_id,
    store_id
)
SELECT
    s.staging_id,
    s.id,
    TO_DATE(s.sale_date, 'MM/DD/YYYY'),
    s.sale_customer_id,
    s.sale_seller_id,
    s.sale_product_id,
    s.sale_quantity,
    s.sale_total_price,
    dc.customer_id,
    dp.pet_id,
    ds.seller_id,
    dpr.product_id,
    dst.store_id
FROM stg_pet_sales s
JOIN dim_customer dc
    ON dc.email = TRIM(s.customer_email)
LEFT JOIN dim_pet dp
    ON dp.owner_email = TRIM(s.customer_email)
JOIN dim_seller ds
    ON ds.email = TRIM(s.seller_email)
JOIN dim_store dst
    ON dst.email = TRIM(s.store_email)
JOIN dim_supplier sup
    ON sup.email = TRIM(s.supplier_email)
JOIN dim_product_category pc
    ON pc.product_category_name = NULLIF(TRIM(s.product_category), '')
JOIN dim_brand b
    ON b.brand_name = NULLIF(TRIM(s.product_brand), '')
JOIN dim_material m
    ON m.material_name = NULLIF(TRIM(s.product_material), '')
JOIN dim_product dpr
    ON dpr.product_name = TRIM(s.product_name)
   AND dpr.product_category_id = pc.product_category_id
   AND dpr.brand_id = b.brand_id
   AND dpr.material_id = m.material_id
   AND dpr.supplier_id = sup.supplier_id
   AND dpr.price = s.product_price
   AND dpr.available_quantity = s.product_quantity
   AND dpr.weight = s.product_weight
   AND dpr.color IS NOT DISTINCT FROM NULLIF(TRIM(s.product_color), '')
   AND dpr.size_name IS NOT DISTINCT FROM NULLIF(TRIM(s.product_size), '')
   AND dpr.description IS NOT DISTINCT FROM NULLIF(TRIM(s.product_description), '')
   AND dpr.rating IS NOT DISTINCT FROM s.product_rating
   AND dpr.reviews_count IS NOT DISTINCT FROM s.product_reviews
   AND dpr.release_date IS NOT DISTINCT FROM TO_DATE(s.product_release_date, 'MM/DD/YYYY')
   AND dpr.expiry_date IS NOT DISTINCT FROM TO_DATE(s.product_expiry_date, 'MM/DD/YYYY');
