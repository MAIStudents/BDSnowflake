INSERT INTO fact_sales (date_id, customer_id, seller_id, product_id, store_id, supplier_id, pet_id, quantity, product_price, total_price)
SELECT 
    dd.date_id,
    dc.customer_id,
    ds.seller_id,
    dp.product_id,
    dst.store_id,
    dsup.supplier_id,
    dpet.pet_id,
    m.sale_quantity,
    m.product_price,
    m.sale_total_price
FROM mock_data m
LEFT JOIN dim_date dd ON m.sale_date = dd.date_value
LEFT JOIN dim_customer dc ON m.customer_email = dc.customer_email
LEFT JOIN dim_seller ds ON m.seller_email = ds.seller_email
LEFT JOIN dim_product dp ON m.product_name = dp.product_name
LEFT JOIN dim_store dst ON m.store_name = dst.store_name
LEFT JOIN dim_supplier dsup ON m.supplier_name = dsup.supplier_name
LEFT JOIN dim_pet dpet ON m.customer_pet_name = dpet.pet_name AND dc.customer_id = dpet.customer_id
WHERE m.sale_quantity IS NOT NULL;
