-- Создаем таблицу для сырых данных. Все поля текстовые для простоты импорта.
CREATE TABLE mock_data (
    id TEXT,
    sale_seller_id TEXT,
    product_rating TEXT,
    product_reviews TEXT,
    sale_product_id TEXT,
    sale_quantity TEXT,
    sale_total_price TEXT,
    product_weight TEXT,
    product_price TEXT,
    product_quantity TEXT,
    customer_age TEXT,
    sale_customer_id TEXT,
    seller_country TEXT,
    seller_postal_code TEXT,
    product_name TEXT,
    product_category TEXT,
    sale_date TEXT,
    store_name TEXT,
    store_location TEXT,
    store_city TEXT,
    store_state TEXT,
    store_country TEXT,
    store_phone TEXT,
    store_email TEXT,
    pet_category TEXT,
    product_color TEXT,
    product_size TEXT,
    product_brand TEXT,
    product_material TEXT,
    product_description TEXT,
    product_release_date TEXT,
    product_expiry_date TEXT,
    supplier_name TEXT,
    supplier_contact TEXT,
    supplier_email TEXT,
    supplier_phone TEXT,
    supplier_address TEXT,
    supplier_city TEXT,
    supplier_country TEXT,
    customer_first_name TEXT,
    customer_last_name TEXT,
    customer_email TEXT,
    customer_country TEXT,
    customer_postal_code TEXT,
    customer_pet_type TEXT,
    customer_pet_name TEXT,
    customer_pet_breed TEXT,
    seller_first_name TEXT,
    seller_last_name TEXT,
    seller_email TEXT
);

-- Копируем данные из каждого CSV-файла.
-- Путь /data/mock_data_*.csv соответствует тому, как мы смонтируем данные в docker-compose.
-- Обратите внимание на использование \copy, это команда psql.
\copy mock_data FROM '/data/mock_data_1.csv' WITH (FORMAT csv, HEADER true);

\copy mock_data FROM '/data/mock_data_2.csv' WITH (FORMAT csv, HEADER true);

\copy mock_data FROM '/data/mock_data_3.csv' WITH (FORMAT csv, HEADER true);

\copy mock_data FROM '/data/mock_data_4.csv' WITH (FORMAT csv, HEADER true);

\copy mock_data FROM '/data/mock_data_5.csv' WITH (FORMAT csv, HEADER true);

\copy mock_data FROM '/data/mock_data_6.csv' WITH (FORMAT csv, HEADER true);

\copy mock_data FROM '/data/mock_data_7.csv' WITH (FORMAT csv, HEADER true);

\copy mock_data FROM '/data/mock_data_8.csv' WITH (FORMAT csv, HEADER true);

\copy mock_data FROM '/data/mock_data_9.csv' WITH (FORMAT csv, HEADER true);

\copy mock_data FROM '/data/mock_data_10.csv' WITH (FORMAT csv, HEADER true);