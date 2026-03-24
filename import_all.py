import os
import subprocess
import sys

CONTAINER = "bdsnowflake-postgres-1"
DB = "snowfleak"
USER = "german"
TABLE = "pet_sales"
DATA_DIR = "./исходные данные"


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

    print(f"\nОчищаю таблицу {TABLE} ...")
    result = run_command([
        "docker", "exec", CONTAINER,
        "psql", "-v", "ON_ERROR_STOP=1",
        "-U", USER,
        "-d", DB,
        "-c", f"TRUNCATE TABLE {TABLE};"
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
COPY {TABLE}
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
                "-c", f"SELECT COUNT(*) FROM {TABLE};"
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
            "-c", f"SELECT COUNT(*) FROM {TABLE};"
        ],
        check=True,
        text=True,
        capture_output=True,
        stdin=subprocess.DEVNULL
    )

    final_count = final_result.stdout.strip()
    print("\nИмпорт завершён.")
    print(f"Итоговое количество строк: {final_count}")


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