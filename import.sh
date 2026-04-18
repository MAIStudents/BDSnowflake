docker stop bigdata-lr1 2>/dev/null
docker rm bigdata-lr1 2>/dev/null
docker run -d --name bigdata-lr1 -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin -p 5432:5432 postgres:16

sleep 2

docker exec -i bigdata-lr1 psql -U admin -d postgres < ./import_ddl.sql

for file in ./"исходные данные"/*.csv; do
    docker cp "$file" "bigdata-lr1:/tmp/$(basename "$file")"
    docker exec -i bigdata-lr1 psql -U admin -d postgres -c "\COPY mock_data (source_id, customer_first_name, customer_last_name, customer_age, customer_email, customer_country, customer_postal_code, customer_pet_type, customer_pet_name, customer_pet_breed, seller_first_name, seller_last_name, seller_email, seller_country, seller_postal_code, product_name, product_category, product_price, product_quantity, sale_date, sale_customer_id, sale_seller_id, sale_product_id, sale_quantity, sale_total_price, store_name, store_location, store_city, store_state, store_country, store_phone, store_email, pet_category, product_weight, product_color, product_size, product_brand, product_material, product_description, product_rating, product_reviews, product_release_date, product_expiry_date, supplier_name, supplier_contact, supplier_email, supplier_phone, supplier_address, supplier_city, supplier_country) FROM '/tmp/$(basename "$file")' DELIMITER ',' CSV HEADER;"
done

docker exec bigdata-lr1 rm -f /tmp/*.csv

echo "Импорт завершён"
