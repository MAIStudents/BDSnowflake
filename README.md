# BigDataSnowflake
Анализ больших данных - лабораторная работа №1 - нормализация данных в снежинку

Одна из задач data engineer при работе с данными BigData трансформировать исходную модель данных источника в аналитическую модель данных. Аналитическая модель данных позволяет исследовать данные и принимать на основе полученных данных решения. Классическими универсальными схемами для анализа данных являются "звезда" и "снежинка". В лабораторной работе вам предстоит потренироваться в трансформации исходных данных из источников в модель данных снежинка.

Что необходимо сделать?

Необходимо данные источника (файлы mock_data.csv с номерами), которые представляют информацию о покупателях, продавцах, поставщиках, магазинах, товарах для домашних питомцев трансформировать в модель снежинка/звезда (факты и измерения с нормализацией).

<img width="1411" height="692" alt="Лабораторная работа 1" src="https://github.com/user-attachments/assets/0282c756-76a3-48f7-86e4-df6e1ec6ac89" />


Алгоритм:
1. форкнуть к себе этот репозиторий.
2. Устанавливаете себе инструмент для работы с запросами SQL (рекомендую DBeaver).
3. Запускаете базу данных PostgreSQL (рекомендую установку через docker).
4. Скачиваете файлы с исходными данными mock_data( * ).csv, где ( * ) номера файлов. Всего 10 файлов, каждый по 1000 строк.
5. Импортируете данные в БД PostgreSQL (например, через механизм импорта csv в DBeaver). Всего в таблице mock_data должно находиться 10000 строк из 10 файлов.
6. Анализируете исходные данные с помощью запросов.
7. Выявляете сущности фактов и измерений.
8. Реализуете скрипты DDL для создания таблиц фактов и измерений.
9. Реализуете скрипты DML для заполнения таблиц фактов и измерений из исходных данных.
10. Проверяете полученный результат.
11. Отправляете результат на проверку лаборантам.
12. Обсуждаете работу с лаборантами.

Что должно быть результатом работы?
1. Репозиторий, в котором есть исходные данные mock_data( * ).csv, где ( * ) номера файлов. Всего 10 файлов, каждый по 1000 строк.
2. Файл docker-compose.yml с установкой PostgreSQL и заполненными данными из файлов mock_data(*).csv.
3. Скрипты DDL (SQL) создания таблиц фактов и измерений в соответствии с моделью снежинка/звезда.
4. Скрипты DML (SQL) заполнения таблиц фактов и измерений из исходных данных.

---

**Измерения:**
- `dim_customer` — покупатели
- `dim_pet` — питомцы покупателей (нормализация снежинки)
- `dim_seller` — продавцы
- `dim_product` — товары
- `dim_product_category` — категории товаров (нормализация снежинки)
- `dim_brand` — бренды товаров (нормализация снежинки)
- `dim_store` — магазины
- `dim_supplier` — поставщики
- `dim_date` — календарное измерение
- `dim_country` — страны (общее измерение для нормализации)

---

## Инструкция по запуску

### Требования

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (версия 20+)
- [pgAdmin 4](https://www.pgadmin.org/download/) или любой SQL-клиент

### Шаг 1 — Клонировать репозиторий

```bash
git clone <url-репозитория>
cd BDLab1
```

### Шаг 2 — Запустить контейнер

```bash
docker-compose up -d
```

При первом запуске PostgreSQL автоматически выполнит скрипт `init/01_init.sql`, который:
1. Создаст таблицу-источник `mock_data` и все таблицы схемы снежинки
2. Загрузит все 10 CSV файлов (10 000 строк) в `mock_data`
3. Заполнит все таблицы измерений и таблицу фактов

> Прогресс можно отслеживать командой:
> ```bash
> docker logs -f bdlab1_postgres
> ```
> Когда появится строка `database system is ready to accept connections` — база готова.

### Шаг 3 — Подключиться через pgAdmin

Создать новое подключение в pgAdmin со следующими параметрами:

| Параметр | Значение |
|---|---|
| Host | `localhost` |
| Port | `5432` |
| Database | `petshop` |
| Username | `postgres` |
| Password | `postgres` |

### Шаг 4 — Проверить результат

Выполнить в pgAdmin (Query Tool):

```sql
-- 1. Проверка количества строк в источнике (должно быть 10000)
SELECT COUNT(*) FROM mock_data;

-- 2. Проверка заполненности всех таблиц
SELECT 'dim_country' AS table_name, COUNT(*) FROM dim_country
UNION ALL SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL SELECT 'dim_pet', COUNT(*) FROM dim_pet
UNION ALL SELECT 'dim_seller', COUNT(*) FROM dim_seller
UNION ALL SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_product_category', COUNT(*) FROM dim_product_category
UNION ALL SELECT 'dim_brand', COUNT(*) FROM dim_brand
UNION ALL SELECT 'dim_store', COUNT(*) FROM dim_store
UNION ALL SELECT 'dim_supplier', COUNT(*) FROM dim_supplier
UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL SELECT 'fact_sales', COUNT(*) FROM fact_sales;

-- 3. Проверка целостности — все внешние ключи в факте должны быть заполнены (все 0)
SELECT
    COUNT(*) FILTER (WHERE date_id IS NULL)     AS null_dates,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customers,
    COUNT(*) FILTER (WHERE seller_id IS NULL)   AS null_sellers,
    COUNT(*) FILTER (WHERE product_id IS NULL)  AS null_products,
    COUNT(*) FILTER (WHERE store_id IS NULL)    AS null_stores,
    COUNT(*) FILTER (WHERE supplier_id IS NULL) AS null_suppliers
FROM fact_sales;

-- 4. Пример аналитического запроса — выручка по категориям товаров
SELECT dpc.category_name, SUM(fs.sale_total_price) AS total_revenue
FROM fact_sales fs
JOIN dim_product dp ON fs.product_id = dp.product_id
JOIN dim_product_category dpc ON dp.category_id = dpc.category_id
GROUP BY dpc.category_name
ORDER BY total_revenue DESC;
```

### Пересоздать базу с нуля

Если нужно повторно запустить инициализацию (например, после изменений):

```bash
docker-compose down -v
docker-compose up -d
```