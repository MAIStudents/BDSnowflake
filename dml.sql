INSERT INTO
    DimBrand (brand_name)
SELECT DISTINCT
    product_brand
FROM mock_data
WHERE
    product_brand IS NOT NULL
ON CONFLICT (brand_name) DO NOTHING;

INSERT INTO
    DimCategory (category_name)
SELECT DISTINCT
    product_category
FROM mock_data
WHERE
    product_category IS NOT NULL
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO
    DimLocation (
        country,
        city,
        postal_code,
        address
    )
SELECT DISTINCT
    country,
    city,
    postal_code,
    address
FROM (
        SELECT
            store_country AS country, store_city AS city, NULL AS postal_code, store_location AS address
        FROM mock_data
        UNION ALL
        SELECT
            supplier_country AS country, supplier_city AS city, NULL AS postal_code, supplier_address AS address
        FROM mock_data
        UNION ALL
        SELECT
            customer_country AS country, NULL AS city, customer_postal_code AS postal_code, NULL AS address
        FROM mock_data
    ) AS all_locations
WHERE
    country IS NOT NULL
    OR city IS NOT NULL
    OR address IS NOT NULL
    OR postal_code IS NOT NULL;

INSERT INTO
    DimPet (pet_type, pet_name, pet_breed)
SELECT DISTINCT
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed
FROM mock_data
WHERE
    customer_pet_type IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO
    DimDate (
        date_id,
        full_date,
        year,
        quarter,
        month,
        day,
        day_of_week,
        week_of_year
    )
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT AS date_id,
    d AS full_date,
    EXTRACT(
        YEAR
        FROM d
    ) AS year,
    EXTRACT(
        QUARTER
        FROM d
    ) AS quarter,
    EXTRACT(
        MONTH
        FROM d
    ) AS month,
    EXTRACT(
        DAY
        FROM d
    ) AS day,
    EXTRACT(
        ISODOW
        FROM d
    ) AS day_of_week,
    EXTRACT(
        WEEK
        FROM d
    ) AS week_of_year
FROM (
        SELECT DISTINCT
            sale_date::DATE AS d
        FROM mock_data
        WHERE
            sale_date IS NOT NULL
    ) AS unique_dates
ON CONFLICT (date_id) DO NOTHING;

INSERT INTO
    DimSupplier (
        supplier_name,
        supplier_contact,
        supplier_email,
        supplier_phone,
        location_id
    )
SELECT DISTINCT
    md.supplier_name,
    md.supplier_contact,
    md.supplier_email,
    md.supplier_phone,
    dl.location_id
FROM
    mock_data AS md
    LEFT JOIN DimLocation AS dl ON md.supplier_country = dl.country
    AND md.supplier_city = dl.city
    AND md.supplier_address = dl.address
WHERE
    md.supplier_name IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO
    DimStore (
        store_name,
        store_phone,
        store_email,
        location_id
    )
SELECT DISTINCT
    md.store_name,
    md.store_phone,
    md.store_email,
    dl.location_id
FROM
    mock_data AS md
    LEFT JOIN DimLocation AS dl ON md.store_country = dl.country
    AND md.store_city = dl.city
    AND md.store_location = dl.address
WHERE
    md.store_name IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO
    DimSeller (
        seller_id,
        seller_first_name,
        seller_last_name,
        seller_email,
        store_id
    )
WITH
    RankedSellers AS (
        SELECT md.sale_seller_id, md.seller_first_name, md.seller_last_name, md.seller_email, ds.store_id, ROW_NUMBER() OVER (
                PARTITION BY
                    md.sale_seller_id
                ORDER BY md.id
            ) AS rn
        FROM mock_data AS md
            LEFT JOIN DimStore AS ds ON md.store_name = ds.store_name
        WHERE
            md.sale_seller_id IS NOT NULL
    )
SELECT
    sale_seller_id,
    seller_first_name,
    seller_last_name,
    seller_email,
    store_id
FROM RankedSellers
WHERE
    rn = 1;

INSERT INTO
    DimCustomer (
        customer_id,
        customer_first_name,
        customer_last_name,
        customer_age,
        customer_email,
        location_id,
        pet_id
    )
WITH
    RankedCustomers AS (
        SELECT md.sale_customer_id, md.customer_first_name, md.customer_last_name, md.customer_age, md.customer_email, dl.location_id, dp.pet_id, ROW_NUMBER() OVER (
                PARTITION BY
                    md.sale_customer_id
                ORDER BY md.id
            ) AS rn
        FROM
            mock_data AS md
            LEFT JOIN DimLocation AS dl ON md.customer_country = dl.country
            AND md.customer_postal_code = dl.postal_code
            AND dl.city IS NULL
            LEFT JOIN DimPet AS dp ON md.customer_pet_type = dp.pet_type
            AND md.customer_pet_name = dp.pet_name
            AND md.customer_pet_breed = dp.pet_breed
        WHERE
            md.sale_customer_id IS NOT NULL
    )
SELECT
    sale_customer_id,
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    location_id,
    pet_id
FROM RankedCustomers
WHERE
    rn = 1;

INSERT INTO
    DimProduct (
        product_id,
        product_name,
        product_description,
        product_price,
        product_weight,
        product_quantity,
        product_rating,
        product_reviews,
        product_color,
        product_size,
        product_material,
        pet_category,
        product_release_date,
        product_expiry_date,
        brand_id,
        category_id,
        supplier_id
    )
WITH
    RankedProducts AS (
        SELECT
            md.id,
            md.product_name,
            md.product_description,
            md.product_price,
            md.product_weight,
            md.product_quantity,
            md.product_rating,
            md.product_reviews,
            md.product_color,
            md.product_size,
            md.product_material,
            md.pet_category,
            NULLIF(md.product_release_date, '')::DATE AS product_release_date,
            NULLIF(md.product_expiry_date, '')::DATE AS product_expiry_date,
            db.brand_id,
            dc.category_id,
            ds.supplier_id,
            ROW_NUMBER() OVER (
                PARTITION BY
                    md.id
                ORDER BY md.product_name
            ) AS rn
        FROM
            mock_data AS md
            LEFT JOIN DimBrand AS db ON md.product_brand = db.brand_name
            LEFT JOIN DimCategory AS dc ON md.product_category = dc.category_name
            LEFT JOIN DimSupplier AS ds ON md.supplier_name = ds.supplier_name
        WHERE
            md.id IS NOT NULL
    )
SELECT
    id,
    product_name,
    product_description,
    product_price,
    product_weight,
    product_quantity,
    product_rating,
    product_reviews,
    product_color,
    product_size,
    product_material,
    pet_category,
    product_release_date,
    product_expiry_date,
    brand_id,
    category_id,
    supplier_id
FROM RankedProducts
WHERE
    rn = 1;

INSERT INTO
    FactSales (
        sale_quantity,
        sale_total_price,
        product_id,
        customer_id,
        seller_id,
        date_id
    )
SELECT md.sale_quantity, md.sale_total_price, md.sale_product_id, md.sale_customer_id, md.sale_seller_id, TO_CHAR(
        md.sale_date::DATE, 'YYYYMMDD'
    )::INT
FROM mock_data AS md
WHERE
    md.id IS NOT NULL;