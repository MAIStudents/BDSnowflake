DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_store;
DROP TABLE IF EXISTS dim_supplier;
DROP TABLE IF EXISTS dim_seller;
DROP TABLE IF EXISTS dim_pet;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_material;
DROP TABLE IF EXISTS dim_brand;
DROP TABLE IF EXISTS dim_product_category;
DROP TABLE IF EXISTS dim_pet_category;
DROP TABLE IF EXISTS dim_pet_type;
DROP TABLE IF EXISTS dim_country;
DROP TABLE IF EXISTS stg_pet_sales;
DROP TABLE IF EXISTS pet_sales;

CREATE TABLE stg_pet_sales (
    staging_id            BIGSERIAL PRIMARY KEY,
    id                    TEXT,
    customer_first_name   TEXT,
    customer_last_name    TEXT,
    customer_age          INTEGER,
    customer_email        TEXT,
    customer_country      TEXT,
    customer_postal_code  TEXT,
    customer_pet_type     TEXT,
    customer_pet_name     TEXT,
    customer_pet_breed    TEXT,
    seller_first_name     TEXT,
    seller_last_name      TEXT,
    seller_email          TEXT,
    seller_country        TEXT,
    seller_postal_code    TEXT,
    product_name          TEXT,
    product_category      TEXT,
    product_price         NUMERIC,
    product_quantity      INTEGER,
    sale_date             TEXT,
    sale_customer_id      TEXT,
    sale_seller_id        TEXT,
    sale_product_id       TEXT,
    sale_quantity         INTEGER,
    sale_total_price      NUMERIC,
    store_name            TEXT,
    store_location        TEXT,
    store_city            TEXT,
    store_state           TEXT,
    store_country         TEXT,
    store_phone           TEXT,
    store_email           TEXT,
    pet_category          TEXT,
    product_weight        NUMERIC,
    product_color         TEXT,
    product_size          TEXT,
    product_brand         TEXT,
    product_material      TEXT,
    product_description   TEXT,
    product_rating        NUMERIC,
    product_reviews       INTEGER,
    product_release_date  TEXT,
    product_expiry_date   TEXT,
    supplier_name         TEXT,
    supplier_contact      TEXT,
    supplier_email        TEXT,
    supplier_phone        TEXT,
    supplier_address      TEXT,
    supplier_city         TEXT,
    supplier_country      TEXT
);

CREATE TABLE dim_country (
    country_id    BIGSERIAL PRIMARY KEY,
    country_name  TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_pet_type (
    pet_type_id    BIGSERIAL PRIMARY KEY,
    pet_type_name  TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_pet_category (
    pet_category_id    BIGSERIAL PRIMARY KEY,
    pet_category_name  TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_product_category (
    product_category_id    BIGSERIAL PRIMARY KEY,
    product_category_name  TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_brand (
    brand_id    BIGSERIAL PRIMARY KEY,
    brand_name  TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_material (
    material_id    BIGSERIAL PRIMARY KEY,
    material_name  TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_customer (
    customer_id      BIGSERIAL PRIMARY KEY,
    first_name       TEXT NOT NULL,
    last_name        TEXT NOT NULL,
    age              INTEGER,
    email            TEXT NOT NULL UNIQUE,
    postal_code      TEXT,
    country_id       BIGINT REFERENCES dim_country(country_id)
);

CREATE TABLE dim_pet (
    pet_id            BIGSERIAL PRIMARY KEY,
    pet_name          TEXT,
    pet_breed         TEXT,
    pet_type_id       BIGINT REFERENCES dim_pet_type(pet_type_id),
    pet_category_id   BIGINT REFERENCES dim_pet_category(pet_category_id),
    owner_email       TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_seller (
    seller_id       BIGSERIAL PRIMARY KEY,
    first_name      TEXT NOT NULL,
    last_name       TEXT NOT NULL,
    email           TEXT NOT NULL UNIQUE,
    postal_code     TEXT,
    country_id      BIGINT REFERENCES dim_country(country_id)
);

CREATE TABLE dim_supplier (
    supplier_id      BIGSERIAL PRIMARY KEY,
    supplier_name    TEXT NOT NULL,
    contact_name     TEXT,
    email            TEXT NOT NULL UNIQUE,
    phone            TEXT,
    address_line     TEXT,
    city             TEXT,
    country_id       BIGINT REFERENCES dim_country(country_id)
);

CREATE TABLE dim_store (
    store_id         BIGSERIAL PRIMARY KEY,
    store_name       TEXT NOT NULL,
    location_name    TEXT,
    city             TEXT,
    state_name       TEXT,
    country_id       BIGINT REFERENCES dim_country(country_id),
    phone            TEXT,
    email            TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_product (
    product_id             BIGSERIAL PRIMARY KEY,
    product_name           TEXT NOT NULL,
    product_category_id    BIGINT REFERENCES dim_product_category(product_category_id),
    brand_id               BIGINT REFERENCES dim_brand(brand_id),
    material_id            BIGINT REFERENCES dim_material(material_id),
    supplier_id            BIGINT REFERENCES dim_supplier(supplier_id),
    price                  NUMERIC,
    available_quantity     INTEGER,
    weight                 NUMERIC,
    color                  TEXT,
    size_name              TEXT,
    description            TEXT,
    rating                 NUMERIC,
    reviews_count          INTEGER,
    release_date           DATE,
    expiry_date            DATE
);

CREATE UNIQUE INDEX ux_dim_product_natural_key
    ON dim_product (
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
    );

CREATE TABLE fact_sales (
    sales_id             BIGSERIAL PRIMARY KEY,
    staging_id           BIGINT NOT NULL UNIQUE REFERENCES stg_pet_sales(staging_id),
    source_row_id        TEXT,
    sale_date            DATE NOT NULL,
    source_customer_id   TEXT,
    source_seller_id     TEXT,
    source_product_id    TEXT,
    sale_quantity        INTEGER NOT NULL,
    sale_total_price     NUMERIC NOT NULL,
    customer_id          BIGINT NOT NULL REFERENCES dim_customer(customer_id),
    pet_id               BIGINT REFERENCES dim_pet(pet_id),
    seller_id            BIGINT NOT NULL REFERENCES dim_seller(seller_id),
    product_id           BIGINT NOT NULL REFERENCES dim_product(product_id),
    store_id             BIGINT NOT NULL REFERENCES dim_store(store_id)
);
