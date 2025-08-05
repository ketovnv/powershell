#!/usr/bin/env python3
"""
examples.py - Примеры использования EmojiSystem
Демонстрирует различные способы применения системы эмодзи
"""

from EmojiSystem.py import (get_emoji, get_file_icon, emoji_system)
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.live import Live
from rich.layout import Layout
from rich.text import Text
import time
import random

console = Console()


def demo_basic_usage():
    """Демонстрация базового использования"""
    console.print(Panel.fit(
        "[bold cyan]🚀 Базовое использование EmojiSystem[/bold cyan]",
        border_style="cyan"
    ))

    # Примеры получения эмодзи
    examples = [
        ("Docker контейнер", get_emoji("docker", "devops")),
        ("Python файл", get_file_icon("script.py")),
        ("Успешный статус", get_emoji("success", "status")),
        ("Git коммит", get_emoji("commit", "git")),
        ("Сервер", get_emoji("server", "network")),
        ("База данных", get_emoji("database", "database")),
        ("Украинский флаг", get_emoji("ukraine", "ukraine")),
    ]

    table = Table(show_header=True, header_style="bold magenta")
    table.add_column("Описание", width=20)
    table.add_column("Код", width=40)
    table.add_column("Результат", width=10)

    for desc, emoji in examples:
        if "файл" in desc:
            code = f'get_file_icon("script.py")'
        elif "контейнер" in desc:
            code = f'get_emoji("docker", "devops")'
        elif "статус" in desc:
            code = f'get_emoji("success", "status")'
        elif "коммит" in desc:
            code = f'get_emoji("commit", "git")'
        elif "Сервер" in desc:
            code = f'get_emoji("server", "network")'
        elif "База" in desc:
            code = f'get_emoji("database", "database")'
        else:
            code = f'get_emoji("ukraine", "ukraine")'

        table.add_row(desc, f"[green]{code}[/green]", emoji)

    console.print(table)


def demo_file_monitoring():
    """Демонстрация мониторинга файлов с иконками"""
    console.print(Panel.fit(
        "[bold yellow]📁 Мониторинг файлов[/bold yellow]",
        border_style="yellow"
    ))

    files = [
        "app.py", "requirements.txt", "docker-compose.yml", "README.md",
        "config.json", "styles.css", "main.js", "database.sql",
        "backup.tar.gz", "script.sh", "Dockerfile", "package.json"
    ]

    table = Table(show_header=True, header_style="bold blue")
    table.add_column("Файл", width=20)
    table.add_column("Тип", width=15)
    table.add_column("Иконка", width=8)
    table.add_column("Статус", width=12)

    statuses = ["running", "success", "warning", "error"]

    for file in files:
        ext = file.split('.')[-1] if '.' in file else file
        file_icon = get_file_icon(file)
        status = random.choice(statuses)
        status_icon = get_emoji(status, "status")

        table.add_row(
            file,
            ext.upper(),
            file_icon,
            f"{status_icon} {status}"
        )

    console.print(table)


def demo_devops_dashboard():
    """Демонстрация DevOps дашборда"""
    console.print(Panel.fit(
        "[bold green]🔧 DevOps Dashboard[/bold green]",
        border_style="green"
    ))

    services = [
        ("Frontend", "react", "running", "devops"),
        ("Backend API", "node", "running", "devops"),
        ("Database", "postgres", "healthy", "status"),
        ("Redis Cache", "redis", "running", "database"),
        ("Docker", "docker", "running", "devops"),
        ("Kubernetes", "k8s", "running", "devops"),
        ("Monitoring", "monitor", "warning", "devops"),
        ("CI/CD Pipeline", "pipeline", "success", "devops"),
    ]

    table = Table(show_header=True, header_style="bold green")
    table.add_column("Сервис", width=20)
    table.add_column("Тип", width=15)
    table.add_column("Статус", width=15)
    table.add_column("Действия", width=20)

    for service, tech, status, category in services:
        tech_icon = get_emoji(tech, category if tech != "react" and tech != "node" else "development")
        if tech == "react":
            tech_icon = "⚛️"
        elif tech == "node":
            tech_icon = "🟢"

        status_icon = get_emoji(status, "status")

        # Действия
        actions = []
        if status == "running":
            actions.append(f"{get_emoji('stop', 'status')} Stop")
        if status == "warning":
            actions.append(f"{get_emoji('fix', 'development')} Fix")
        if "pipeline" in service.lower():
            actions.append(f"{get_emoji('deploy', 'devops')} Deploy")

        table.add_row(
            f"{tech_icon} {service}",
            tech.upper(),
            f"{status_icon} {status.title()}",
            " | ".join(actions[:2])
        )

    console.print(table)


def demo_git_workflow():
    """Демонстрация Git workflow"""
    console.print(Panel.fit(
        "[bold magenta]🌿 Git Workflow[/bold magenta]",
        border_style="magenta"
    ))

    git_actions = [
        ("Создание ветки", "branch", "feature/user-auth"),
        ("Коммит изменений", "commit", "Add user authentication"),
        ("Отправка изменений", "push", "origin feature/user-auth"),
        ("Создание PR", "pr", "User authentication feature"),
        ("Код ревью", "review", "2 approvals required"),
        ("Слияние", "merge", "Merge to main branch"),
        ("Релиз", "release", "v1.2.0"),
        ("Тег", "tag", "v1.2.0"),
    ]

    for i, (action, git_type, details) in enumerate(git_actions, 1):
        icon = get_emoji(git_type, "git")
        status_icon = get_emoji("success", "status") if i <= 6 else get_emoji("pending", "status")

        console.print(f"{i}. {icon} [bold]{action}[/bold]: {details} {status_icon}")


def demo_system_monitoring():
    """Демонстрация системного мониторинга"""
    console.print(Panel.fit(
        "[bold red]🖥️ Системный мониторинг[/bold red]",
        border_style="red"
    ))

    # Симуляция системных метрик
    metrics = [
        ("CPU", "cpu", random.randint(10, 90), "%"),
        ("RAM", "memory", random.randint(30, 85), "%"),
        ("Диск", "disk", random.randint(40, 75), "%"),
        ("Сеть", "network", random.randint(5, 50), "Mbps"),
        ("Температура", "temperature", random.randint(35, 80), "°C"),
        ("Батарея", "battery", random.randint(20, 100), "%"),
    ]

    table = Table(show_header=True, header_style="bold red")
    table.add_column("Компонент", width=15)
    table.add_column("Значение", width=12)
    table.add_column("Статус", width=12)
    table.add_column("График", width=30)

    for name, metric_type, value, unit in metrics:
        icon = get_emoji(metric_type, "performance")

        # Определение статуса по значению
        if metric_type == "temperature":
            status = "hot" if value > 70 else "good"
        elif metric_type == "battery":
            status = "warning" if value < 30 else "good"
        else:
            status = "warning" if value > 80 else "good"

        status_icon = get_emoji(status, "status")

        # Простой график
        bar_length = min(20, int(value / 5))
        bar = "█" * bar_length + "░" * (20 - bar_length)

        table.add_row(
            f"{icon} {name}",
            f"{value}{unit}",
            f"{status_icon} {status}",
            f"[green]{bar}[/green]"
        )

    console.print(table)


def demo_progress_with_emojis():
    """Демонстрация прогресс-бара с эмодзи"""
    console.print(Panel.fit(
        "[bold blue]⏳ Процессы с эмодзи[/bold blue]",
        border_style="blue"
    ))

    tasks = [
        ("Сборка Docker образа", "docker", 100),
        ("Установка зависимостей", "package", 85),
        ("Тестирование", "test", 60),
        ("Развертывание", "deploy", 30),
    ]

    with Progress(
            SpinnerColumn(),
            TextColumn("[bold blue]{task.description}"),
            *Progress.get_default_columns(),
            console=console
    ) as progress:

        task_ids = []
        for desc, emoji_type, total in tasks:
            icon = get_emoji(emoji_type, "devops")
            task_id = progress.add_task(f"{icon} {desc}", total=total)
            task_ids.append((task_id, total))

        # Симуляция выполнения
        for _ in range(100):
            for task_id, total in task_ids:
                progress.advance(task_id, random.uniform(0.1, 1.0))
            time.sleep(0.05)


def demo_ukraine_support():
    """Демонстрация поддержки Украины"""
    console.print(Panel.fit(
        "[bold yellow]🇺🇦 Підтримка України[/bold yellow]",
        border_style="yellow"
    ))

    ukraine_messages = [
        ("ukraine", "Слава Україні!"),
        ("heart", "Любов і підтримка"),
        ("sunflower", "Символ надії"),
        ("peace", "Мир в Україні"),
        ("victory", "Перемога буде за нами"),
        ("strong", "Україна сильна"),
        ("freedom", "Свобода і незалежність"),
        ("unity", "Єдність народу"),
    ]

    for emoji_name, message in ukraine_messages:
        icon = get_emoji(emoji_name, "ukraine")
        console.print(f"{icon} [bold blue]{message}[/bold blue]", justify="center")

    # Флаг Украины
    flag_text = Text()
    flag_text.append("🇺🇦 " * 10, style="bold")
    console.print(Panel(flag_text, border_style="blue"))


def demo_interactive_search():
    """Интерактивная демонстрация поиска"""
    console.print(Panel.fit(
        "[bold cyan]🔍 Интерактивный поиск[/bold cyan]",
        border_style="cyan"
    ))

    search_queries = ["docker", "git", "status", "ukraine", "network"]

    for query in search_queries:
        console.print(f"\n[bold]Поиск: '{query}'[/bold]")
        results = emoji_system.find_emoji(query)

        if results:
            # Показываем первые 5 результатов
            for result in results[:5]:
                console.print(f"  {result['emoji']} {result['name']} [{result['category']}]")

            if len(results) > 5:
                console.print(f"  [dim]... и еще {len(results) - 5} результатов[/dim]")
        else:
            console.print("  [red]Ничего не найдено[/red]")


if __name__ == "__main__":
    console.print(Panel.fit(
        "[bold magenta]🎨 EmojiSystem Examples[/bold magenta]\n"
        "[cyan]Демонстрация возможностей системы эмодзи[/cyan]",
        border_style="magenta"
    ))

    demos = [
        ("Базовое использование", demo_basic_usage),
        ("Мониторинг файлов", demo_file_monitoring),
        ("DevOps Dashboard", demo_devops_dashboard),
        ("Git Workflow", demo_git_workflow),
        ("Системный мониторинг", demo_system_monitoring),
        ("Поддержка Украины", demo_ukraine_support),
        ("Интерактивный поиск", demo_interactive_search),
        ("Прогресс с эмодзи", demo_progress_with_emojis),
    ]

    for i, (name, func) in enumerate(demos, 1):
        console.print(f"\n[bold green]Демо {i}: {name}[/bold green]")
        console.print("─" * 50)
        func()

        if i < len(demos):
            console.print("\n[dim]Нажмите Enter для продолжения...[/dim]")
            input()

    console.print(Panel.fit(
        "[bold green]✅ Все демонстрации завершены![/bold green]\n"
        "[yellow]Спасибо за внимание![/yellow]",
        border_style="green"
    ))