INSERT INTO dim_customer (customer_email, customer_first_name, customer_last_name, customer_age, customer_country, customer_postal_code)
SELECT customer_email, MAX(customer_first_name), MAX(customer_last_name), MAX(customer_age), MAX(customer_country), MAX(customer_postal_code)
FROM mock_data WHERE customer_email IS NOT NULL GROUP BY customer_email;

INSERT INTO dim_seller (seller_email, seller_first_name, seller_last_name, seller_country, seller_postal_code)
SELECT seller_email, MAX(seller_first_name), MAX(seller_last_name), MAX(seller_country), MAX(seller_postal_code)
FROM mock_data WHERE seller_email IS NOT NULL GROUP BY seller_email;

INSERT INTO dim_product (product_name, product_category, product_brand, product_material, product_color, product_size, product_weight, product_description, product_rating, product_reviews, product_release_date, product_expiry_date)
SELECT product_name, MAX(product_category), MAX(product_brand), MAX(product_material), MAX(product_color), MAX(product_size), MAX(product_weight), MAX(product_description), MAX(product_rating), MAX(product_reviews), MAX(product_release_date), MAX(product_expiry_date)
FROM mock_data WHERE product_name IS NOT NULL GROUP BY product_name;

INSERT INTO dim_store (store_name, store_location, store_city, store_state, store_country, store_phone, store_email)
SELECT store_name, MAX(store_location), MAX(store_city), MAX(store_state), MAX(store_country), MAX(store_phone), MAX(store_email)
FROM mock_data WHERE store_name IS NOT NULL GROUP BY store_name;

INSERT INTO dim_supplier (supplier_name, supplier_contact, supplier_email, supplier_phone, supplier_address, supplier_city, supplier_country)
SELECT supplier_name, MAX(supplier_contact), MAX(supplier_email), MAX(supplier_phone), MAX(supplier_address), MAX(supplier_city), MAX(supplier_country)
FROM mock_data WHERE supplier_name IS NOT NULL GROUP BY supplier_name;

INSERT INTO dim_date (date_value, year, month, day, quarter, day_of_week, is_weekend)
SELECT DISTINCT sale_date,
       EXTRACT(YEAR FROM sale_date),
       EXTRACT(MONTH FROM sale_date),
       EXTRACT(DAY FROM sale_date),
       EXTRACT(QUARTER FROM sale_date),
       EXTRACT(ISODOW FROM sale_date),
       CASE WHEN EXTRACT(ISODOW FROM sale_date) IN (6, 7) THEN TRUE ELSE FALSE END
FROM mock_data WHERE sale_date IS NOT NULL;

INSERT INTO dim_pet (pet_type, pet_name, pet_breed, pet_category, customer_id)
SELECT MAX(m.customer_pet_type), m.customer_pet_name, MAX(m.customer_pet_breed), MAX(m.pet_category), c.customer_id
FROM mock_data m
JOIN dim_customer c ON m.customer_email = c.customer_email
WHERE m.customer_pet_name IS NOT NULL
GROUP BY m.customer_pet_name, c.customer_id;
