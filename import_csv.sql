-- Скрипт импорта CSV файлов в таблицу mock_data
-- Выполнять в pgAdmin после создания таблицы через ddl.sql
-- ВАЖНО: укажи правильный путь к файлам на своём компьютере

-- Замени путь C:/Users/max_d/OneDrive/Desktop/nenahov/BDLab1/исходные данные/ на актуальный

COPY mock_data FROM '/csv_data/MOCK_DATA.csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (1).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (2).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (3).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (4).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (5).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (6).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (7).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (8).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

COPY mock_data FROM '/csv_data/MOCK_DATA (9).csv'
    WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

-- Проверка: должно быть 10000 строк
SELECT COUNT(*) FROM mock_data;
