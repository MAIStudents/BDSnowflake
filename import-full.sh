#!/bin/bash
set -e

echo "Инициализация БД..."

until pg_isready -U admin -d postgres; do
  echo "Ожидаем запуска PostgreSQL..."
  sleep 2
done

echo "PostgreSQL готов. Начинаем импорт CSV..."
for file in /csv_data/*.csv; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "Импортируем: $filename"
        
        psql -U admin -d postgres <<EOF
\COPY mock_data (source_id, customer_first_name, customer_last_name, customer_age, customer_email, customer_country, customer_postal_code, customer_pet_type, customer_pet_name, customer_pet_breed, seller_first_name, seller_last_name, seller_email, seller_country, seller_postal_code, product_name, product_category, product_price, product_quantity, sale_date, sale_customer_id, sale_seller_id, sale_product_id, sale_quantity, sale_total_price, store_name, store_location, store_city, store_state, store_country, store_phone, store_email, pet_category, product_weight, product_color, product_size, product_brand, product_material, product_description, product_rating, product_reviews, product_release_date, product_expiry_date, supplier_name, supplier_contact, supplier_email, supplier_phone, supplier_address, supplier_city, supplier_country) FROM '$file' DELIMITER ',' CSV HEADER;
EOF
    fi
done

echo "Импорт CSV завершён. Заполняем звёздную схему..."

# Запускаем star_dml.sql
psql -U admin -d postgres -f /star_dml.sql

echo "=== Полная инициализация завершена успешно! ==="