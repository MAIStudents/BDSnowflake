CREATE TABLE dim_country (
    country_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE dim_city (
    city_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    country_key integer NOT NULL REFERENCES dim_country (country_key),
    UNIQUE (name, country_key)
);

CREATE TABLE dim_pet_type (
    pet_type_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE dim_pet_breed (
    pet_breed_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE dim_product_category (
    product_category_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE dim_pet_category (
    pet_category_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE dim_brand (
    brand_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE dim_color (
    color_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE dim_size (
    size_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE dim_material (
    material_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE dim_supplier (
    supplier_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    contact text NOT NULL,
    email text NOT NULL,
    phone text NOT NULL,
    address text NOT NULL,
    city_key integer NOT NULL REFERENCES dim_city (city_key)
);

CREATE TABLE dim_customer (
    customer_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name text NOT NULL,
    last_name text NOT NULL,
    age smallint NOT NULL,
    email text NOT NULL UNIQUE,
    postal_code text,
    country_key integer NOT NULL REFERENCES dim_country (country_key),
    pet_type_key integer NOT NULL REFERENCES dim_pet_type (pet_type_key),
    pet_breed_key integer NOT NULL REFERENCES dim_pet_breed (pet_breed_key),
    pet_name text NOT NULL
);

CREATE TABLE dim_seller (
    seller_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text NOT NULL UNIQUE,
    postal_code text,
    country_key integer NOT NULL REFERENCES dim_country (country_key)
);

CREATE TABLE dim_store (
    store_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    location text NOT NULL,
    city_key integer NOT NULL REFERENCES dim_city (city_key),
    state text,
    phone text NOT NULL,
    email text NOT NULL
);

CREATE TABLE dim_product (
    product_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    price numeric(10,2) NOT NULL,
    stock_quantity integer NOT NULL,
    weight numeric(10,2) NOT NULL,
    description text NOT NULL,
    rating numeric(3,1) NOT NULL,
    reviews integer NOT NULL,
    release_date date NOT NULL,
    expiry_date date NOT NULL,
    product_category_key integer NOT NULL REFERENCES dim_product_category (product_category_key),
    pet_category_key integer NOT NULL REFERENCES dim_pet_category (pet_category_key),
    brand_key integer NOT NULL REFERENCES dim_brand (brand_key),
    color_key integer NOT NULL REFERENCES dim_color (color_key),
    size_key integer NOT NULL REFERENCES dim_size (size_key),
    material_key integer NOT NULL REFERENCES dim_material (material_key),
    supplier_key integer NOT NULL REFERENCES dim_supplier (supplier_key)
);

CREATE TABLE dim_date (
    date_key date PRIMARY KEY,
    day smallint NOT NULL,
    month smallint NOT NULL,
    month_name text NOT NULL,
    quarter smallint NOT NULL,
    year smallint NOT NULL,
    day_of_week smallint NOT NULL,
    day_name text NOT NULL,
    is_weekend boolean NOT NULL
);

CREATE TABLE fact_sales (
    sale_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_key date NOT NULL REFERENCES dim_date (date_key),
    customer_key integer NOT NULL REFERENCES dim_customer (customer_key),
    seller_key integer NOT NULL REFERENCES dim_seller (seller_key),
    product_key integer NOT NULL REFERENCES dim_product (product_key),
    store_key integer NOT NULL REFERENCES dim_store (store_key),
    quantity integer NOT NULL,
    total_price numeric(12,2) NOT NULL
);
