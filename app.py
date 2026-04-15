import json
from pathlib import Path


DATA_FILE = Path("tasks.json")


def load_tasks() -> list[dict]:
    if not DATA_FILE.exists():
        return []
    try:
        return json.loads(DATA_FILE.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return []


def save_tasks(tasks: list[dict]) -> None:
    DATA_FILE.write_text(json.dumps(tasks, ensure_ascii=False, indent=2), encoding="utf-8")


def show_tasks(tasks: list[dict]) -> None:
    if not tasks:
        print("\nСписок задач пуст.\n")
        return
    print("\nТекущие задачи:")
    for i, task in enumerate(tasks, start=1):
        status = "✅" if task["done"] else "⬜"
        print(f"{i}. {status} {task['title']}")
    print()


def show_stats(tasks: list[dict]) -> None:
    total = len(tasks)
    done = sum(1 for task in tasks if task["done"])
    pending = total - done
    print("Статистика задач:")
    print(f"- Всего: {total}")
    print(f"- Выполнено: {done}")
    print(f"- В работе: {pending}\n")


def add_task(tasks: list[dict]) -> None:
    title = input("Введите текст задачи: ").strip()
    if not title:
        print("Пустую задачу добавить нельзя.\n")
        return
    tasks.append({"title": title, "done": False})
    save_tasks(tasks)
    print("Задача добавлена.\n")


def mark_done(tasks: list[dict]) -> None:
    if not tasks:
        print("Нет задач для отметки.\n")
        return
    show_tasks(tasks)
    raw = input("Введите номер выполненной задачи: ").strip()
    if not raw.isdigit():
        print("Нужно ввести число.\n")
        return
    idx = int(raw) - 1
    if idx < 0 or idx >= len(tasks):
        print("Некорректный номер задачи.\n")
        return
    tasks[idx]["done"] = True
    save_tasks(tasks)
    print("Задача отмечена как выполненная.\n")


def delete_task(tasks: list[dict]) -> None:
    if not tasks:
        print("Нет задач для удаления.\n")
        return
    show_tasks(tasks)
    raw = input("Введите номер задачи для удаления: ").strip()
    if not raw.isdigit():
        print("Нужно ввести число.\n")
        return
    idx = int(raw) - 1
    if idx < 0 or idx >= len(tasks):
        print("Некорректный номер задачи.\n")
        return
    removed = tasks.pop(idx)
    save_tasks(tasks)
    print(f"Удалено: {removed['title']}\n")


def print_menu() -> None:
    print("=== Менеджер задач ===")
    print("1. Показать задачи")
    print("2. Добавить задачу")
    print("3. Отметить задачу выполненной")
    print("4. Удалить задачу")
    print("5. Показать статистику")
    print("0. Выход")


def main() -> None:
    tasks = load_tasks()
    while True:
        print_menu()
        choice = input("Выберите действие: ").strip()
        print()
        if choice == "1":
            show_tasks(tasks)
        elif choice == "2":
            add_task(tasks)
        elif choice == "3":
            mark_done(tasks)
        elif choice == "4":
            delete_task(tasks)
        elif choice == "5":
            show_stats(tasks)
        elif choice == "0":
            print("Работа завершена.")
            break
        else:
            print("Неизвестная команда.\n")


if __name__ == "__main__":
    main()
