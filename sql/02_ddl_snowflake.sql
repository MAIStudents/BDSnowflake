CREATE TABLE IF NOT EXISTS dim_country (
    country_id BIGSERIAL PRIMARY KEY,
    country_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_pet_type (
    pet_type_id BIGSERIAL PRIMARY KEY,
    pet_type_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_pet_category (
    pet_category_id BIGSERIAL PRIMARY KEY,
    pet_category_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_product_category (
    product_category_id BIGSERIAL PRIMARY KEY,
    product_category_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_supplier (
    supplier_id BIGSERIAL PRIMARY KEY,
    supplier_name TEXT NOT NULL,
    supplier_contact TEXT NOT NULL,
    supplier_email TEXT NOT NULL UNIQUE,
    supplier_phone TEXT NOT NULL,
    supplier_address TEXT NOT NULL,
    supplier_city TEXT NOT NULL,
    country_id BIGINT NOT NULL REFERENCES dim_country(country_id)
);

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id BIGSERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INTEGER NOT NULL,
    email TEXT NOT NULL UNIQUE,
    postal_code TEXT,
    country_id BIGINT NOT NULL REFERENCES dim_country(country_id),
    pet_type_id BIGINT NOT NULL REFERENCES dim_pet_type(pet_type_id),
    pet_name TEXT NOT NULL,
    pet_breed TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_seller (
    seller_id BIGSERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    postal_code TEXT,
    country_id BIGINT NOT NULL REFERENCES dim_country(country_id)
);

CREATE TABLE IF NOT EXISTS dim_store (
    store_id BIGSERIAL PRIMARY KEY,
    store_name TEXT NOT NULL,
    store_location TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT,
    phone TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    country_id BIGINT NOT NULL REFERENCES dim_country(country_id)
);

CREATE TABLE IF NOT EXISTS dim_product (
    product_id BIGSERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    product_category_id BIGINT NOT NULL REFERENCES dim_product_category(product_category_id),
    current_price NUMERIC(10, 2) NOT NULL,
    stock_quantity INTEGER NOT NULL,
    pet_category_id BIGINT NOT NULL REFERENCES dim_pet_category(pet_category_id),
    product_weight NUMERIC(10, 2) NOT NULL,
    color TEXT NOT NULL,
    size TEXT NOT NULL,
    brand TEXT NOT NULL,
    material TEXT NOT NULL,
    description TEXT NOT NULL,
    rating NUMERIC(3, 1) NOT NULL,
    reviews_count INTEGER NOT NULL,
    release_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    supplier_id BIGINT NOT NULL REFERENCES dim_supplier(supplier_id),
    UNIQUE (
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
);

CREATE TABLE IF NOT EXISTS dim_date (
    date_id INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_of_month INTEGER NOT NULL,
    month_number INTEGER NOT NULL,
    month_name TEXT NOT NULL,
    quarter_number INTEGER NOT NULL,
    year_number INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS fact_sales (
    sale_id BIGSERIAL PRIMARY KEY,
    mock_data_key BIGINT NOT NULL UNIQUE REFERENCES mock_data(mock_data_key),
    source_sale_row_id INTEGER NOT NULL,
    sale_customer_source_id INTEGER NOT NULL,
    sale_seller_source_id INTEGER NOT NULL,
    sale_product_source_id INTEGER NOT NULL,
    sale_date_id INTEGER NOT NULL REFERENCES dim_date(date_id),
    customer_id BIGINT NOT NULL REFERENCES dim_customer(customer_id),
    seller_id BIGINT NOT NULL REFERENCES dim_seller(seller_id),
    product_id BIGINT NOT NULL REFERENCES dim_product(product_id),
    store_id BIGINT NOT NULL REFERENCES dim_store(store_id),
    sale_quantity INTEGER NOT NULL,
    sale_total_price NUMERIC(10, 2) NOT NULL
);
