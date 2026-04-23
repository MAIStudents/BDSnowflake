import os
import subprocess
import sys

CONTAINER = "bdsnowflake-postgres-1"
DB = "snowfleak"
USER = "german"
STAGING_TABLE = "stg_pet_sales"
DATA_DIR = "./исходные данные"
DDL_SQL = "/sql/01_ddl_snowflake.sql"
TRANSFORM_SQL = "/sql/02_dml_snowflake.sql"
COLUMN_LIST = """
id,
customer_first_name,
customer_last_name,
customer_age,
customer_email,
customer_country,
customer_postal_code,
customer_pet_type,
customer_pet_name,
customer_pet_breed,
seller_first_name,
seller_last_name,
seller_email,
seller_country,
seller_postal_code,
product_name,
product_category,
product_price,
product_quantity,
sale_date,
sale_customer_id,
sale_seller_id,
sale_product_id,
sale_quantity,
sale_total_price,
store_name,
store_location,
store_city,
store_state,
store_country,
store_phone,
store_email,
pet_category,
product_weight,
product_color,
product_size,
product_brand,
product_material,
product_description,
product_rating,
product_reviews,
product_release_date,
product_expiry_date,
supplier_name,
supplier_contact,
supplier_email,
supplier_phone,
supplier_address,
supplier_city,
supplier_country
""".strip()


def run_command(cmd: list[str]) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd,
        check=True,
        text=True,
        capture_output=True
    )


def main() -> None:
    if not os.path.isdir(DATA_DIR):
        print(f"Ошибка: папка '{DATA_DIR}' не найдена.")
        sys.exit(1)

    files = [
        os.path.join(DATA_DIR, name)
        for name in os.listdir(DATA_DIR)
        if name.lower().endswith(".csv")
    ]
    files.sort()

    print(f"Найдено CSV-файлов: {len(files)}")
    if not files:
        print("CSV-файлы не найдены.")
        sys.exit(1)

    print("Файлы для импорта:")
    for file_path in files:
        print(f"- {file_path}")

    print("\nПересоздаю DDL для staging и snowflake-схемы ...")
    ddl_result = run_command([
        "docker", "exec", CONTAINER,
        "psql", "-v", "ON_ERROR_STOP=1",
        "-U", USER,
        "-d", DB,
        "-f", DDL_SQL
    ])
    if ddl_result.stdout.strip():
        print(ddl_result.stdout.strip())

    print(f"\nОчищаю таблицу {STAGING_TABLE} ...")
    result = run_command([
        "docker", "exec", CONTAINER,
        "psql", "-v", "ON_ERROR_STOP=1",
        "-U", USER,
        "-d", DB,
        "-c", f"TRUNCATE TABLE {STAGING_TABLE} RESTART IDENTITY CASCADE;"
    ])
    if result.stdout.strip():
        print(result.stdout.strip())

    for host_file in files:
        base_name = os.path.basename(host_file)
        container_file = f"/data/{base_name}"

        print(f"\nПроверяю наличие файла в контейнере: {container_file}")
        subprocess.run(
            ["docker", "exec", CONTAINER, "test", "-f", container_file],
            check=True,
            stdin=subprocess.DEVNULL
        )

        print(f"Загружаю: {host_file}")
        copy_sql = f"""
COPY {STAGING_TABLE} (
{COLUMN_LIST}
)
FROM '{container_file}'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);
""".strip()

        result = subprocess.run(
            [
                "docker", "exec", CONTAINER,
                "psql", "-v", "ON_ERROR_STOP=1",
                "-U", USER,
                "-d", DB,
                "-c", copy_sql
            ],
            check=True,
            text=True,
            capture_output=True,
            stdin=subprocess.DEVNULL
        )

        if result.stdout.strip():
            print(result.stdout.strip())

        count_result = subprocess.run(
            [
                "docker", "exec", CONTAINER,
                "psql", "-t", "-A",
                "-U", USER,
                "-d", DB,
                "-c", f"SELECT COUNT(*) FROM {STAGING_TABLE};"
            ],
            check=True,
            text=True,
            capture_output=True,
            stdin=subprocess.DEVNULL
        )

        current_count = count_result.stdout.strip()
        print(f"Сейчас строк в таблице: {current_count}")

    final_result = subprocess.run(
        [
            "docker", "exec", CONTAINER,
            "psql", "-t", "-A",
            "-U", USER,
            "-d", DB,
            "-c", f"SELECT COUNT(*) FROM {STAGING_TABLE};"
        ],
        check=True,
        text=True,
        capture_output=True,
        stdin=subprocess.DEVNULL
    )

    final_count = final_result.stdout.strip()
    print("\nЗапускаю трансформацию в схему snowflake ...")
    transform_result = run_command([
        "docker", "exec", CONTAINER,
        "psql", "-v", "ON_ERROR_STOP=1",
        "-U", USER,
        "-d", DB,
        "-f", TRANSFORM_SQL
    ])
    if transform_result.stdout.strip():
        print(transform_result.stdout.strip())

    fact_count_result = run_command([
        "docker", "exec", CONTAINER,
        "psql", "-t", "-A",
        "-U", USER,
        "-d", DB,
        "-c", "SELECT COUNT(*) FROM fact_sales;"
    ])

    print("\nИмпорт завершён.")
    print(f"Итоговое количество строк в staging: {final_count}")
    print(f"Итоговое количество строк в fact_sales: {fact_count_result.stdout.strip()}")


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as e:
        print("\nОшибка при выполнении команды.")
        print(f"Код возврата: {e.returncode}")
        if e.stdout:
            print("STDOUT:")
            print(e.stdout)
        if e.stderr:
            print("STDERR:")
            print(e.stderr)
        sys.exit(1)
