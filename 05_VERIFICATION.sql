SELECT 'Dimension Customers' as table_name, COUNT(*) as row_count FROM dim_customer
UNION ALL SELECT 'Dimension Sellers', COUNT(*) FROM dim_seller
UNION ALL SELECT 'Dimension Stores', COUNT(*) FROM dim_store
UNION ALL SELECT 'Dimension Products', COUNT(*) FROM dim_product
UNION ALL SELECT 'Dimension Suppliers', COUNT(*) FROM dim_supplier
UNION ALL SELECT 'Dimension Pets', COUNT(*) FROM dim_pet
UNION ALL SELECT 'Dimension Dates', COUNT(*) FROM dim_date
UNION ALL SELECT 'Fact Sales', COUNT(*) FROM fact_sales
ORDER BY table_name;

-- Тест 1: Продажи по датам (Год / Месяц)
SELECT dd.year, dd.month, COUNT(*) as total_sales, SUM(fs.total_price) as revenue
FROM fact_sales fs
JOIN dim_date dd ON fs.date_id = dd.date_id
GROUP BY dd.year, dd.month
ORDER BY dd.year, dd.month
LIMIT 10;

-- Тест 2: Продажи по категориям продуктов
SELECT dp.product_category, COUNT(*) as sale_count, SUM(fs.total_price) as revenue
FROM fact_sales fs
JOIN dim_product dp ON fs.product_id = dp.product_id
GROUP BY dp.product_category
ORDER BY revenue DESC
LIMIT 10;

-- Тест 3: Топ-10 продавцов по выручке
SELECT ds.seller_first_name, ds.seller_last_name, COUNT(*) as sales_count, SUM(fs.total_price) as total_revenue
FROM fact_sales fs
JOIN dim_seller ds ON fs.seller_id = ds.seller_id
GROUP BY ds.seller_id, ds.seller_first_name, ds.seller_last_name
ORDER BY total_revenue DESC
LIMIT 10;