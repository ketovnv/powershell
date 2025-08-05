#!/usr/bin/env python3
"""
setup_windows_fonts.py - Помощник настройки шрифтов для лучшей поддержки эмодзи в Windows
"""

import platform
import subprocess
import sys
import os
from pathlib import Path
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.prompt import Confirm

console = Console()

def check_windows_terminal():
    """Проверка установки Windows Terminal"""
    try:
        result = subprocess.run(['wt', '--version'], capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            return True, result.stdout.strip()
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass
    return False, None

def check_font_installed(font_name):
    """Проверка установки шрифта в Windows"""
    if platform.system() != "Windows":
        return False

    try:
        import winreg
        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE,
                           r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts") as key:
            i = 0
            while True:
                try:
                    name, value, _ = winreg.EnumValue(key, i)
                    if font_name.lower() in name.lower():
                        return True
                    i += 1
                except OSError:
                    break
    except ImportError:
        pass

    return False

def get_recommended_fonts():
    """Список рекомендуемых шрифтов с поддержкой эмодзи"""
    return [
        {
            'name': 'Cascadia Code',
            'description': 'Официальный шрифт Microsoft с отличной поддержкой эмодзи',
            'install_cmd': 'winget install Microsoft.CascadiaCode',
            'download_url': 'https://github.com/microsoft/cascadia-code/releases',
            'check_names': ['Cascadia Code', 'CascadiaCode']
        },
        {
            'name': 'JetBrains Mono',
            'description': 'Популярный шрифт для разработчиков',
            'install_cmd': 'winget install JetBrains.JetBrainsMono',
            'download_url': 'https://www.jetbrains.com/lp/mono/',
            'check_names': ['JetBrains Mono']
        },
        {
            'name': 'Fira Code',
            'description': 'Шрифт с лигатурами и хорошей поддержкой Unicode',
            'install_cmd': 'winget install "Fira Code"',
            'download_url': 'https://github.com/tonsky/FiraCode',
            'check_names': ['Fira Code']
        },
        {
            'name': 'Noto Color Emoji',
            'description': 'Специальный шрифт Google для эмодзи',
            'install_cmd': 'Скачать вручную с GitHub',
            'download_url': 'https://github.com/googlefonts/noto-emoji',
            'check_names': ['Noto Color Emoji']
        }
    ]

def show_font_status():
    """Показать статус установленных шрифтов"""
    console.print(Panel.fit(
        "[bold cyan]🔤 Статус шрифтов с поддержкой эмодзи[/bold cyan]",
        border_style="cyan"
    ))

    fonts = get_recommended_fonts()

    table = Table(show_header=True, header_style="bold magenta")
    table.add_column("Шрифт", width=20)
    table.add_column("Статус", width=15)
    table.add_column("Описание", width=40)
    table.add_column("Установка", width=30)

    for font in fonts:
        # Проверяем все возможные имена шрифта
        installed = any(check_font_installed(name) for name in font['check_names'])

        status = "[green]✅ Установлен[/green]" if installed else "[red]❌ Не установлен[/red]"

        table.add_row(
            font['name'],
            status,
            font['description'],
            font['install_cmd']
        )

    console.print(table)

def install_cascadia_code():
    """Установка Cascadia Code через winget"""
    if platform.system() != "Windows":
        console.print("[red]Эта функция работает только в Windows[/red]")
        return False

    console.print("[yellow]Попытка установки Cascadia Code...[/yellow]")

    try:
        # Проверяем наличие winget
        subprocess.run(['winget', '--version'], check=True, capture_output=True)

        # Устанавливаем шрифт
        result = subprocess.run([
            'winget', 'install', 'Microsoft.CascadiaCode', '--accept-package-agreements'
        ], capture_output=True, text=True)

        if result.returncode == 0:
            console.print("[green]✅ Cascadia Code успешно установлен![/green]")
            console.print("[yellow]Перезапустите терминал для применения изменений[/yellow]")
            return True
        else:
            console.print(f"[red]Ошибка установки: {result.stderr}[/red]")
            return False

    except subprocess.CalledProcessError:
        console.print("[red]winget не найден. Установите App Installer из Microsoft Store[/red]")
        return False
    except FileNotFoundError:
        console.print("[red]winget не найден в системе[/red]")
        return False

def show_windows_terminal_setup():
    """Показать инструкции по настройке Windows Terminal"""
    wt_installed, version = check_windows_terminal()

    if wt_installed:
        console.print(f"[green]✅ Windows Terminal установлен: {version}[/green]")
    else:
        console.print("[red]❌ Windows Terminal не найден[/red]")

    setup_instructions = """[bold cyan]🛠️ Настройка Windows Terminal для эмодзи:[/bold cyan]

[yellow]1. Установка Windows Terminal:[/yellow]
```bash
winget install Microsoft.WindowsTerminal
# или из Microsoft Store
```

[yellow]2. Настройка шрифта в Windows Terminal:[/yellow]
• Ctrl+, (открыть настройки)
• Профили → По умолчанию → Внешний вид
• Семейство шрифтов: "Cascadia Code" или "JetBrains Mono"
• Размер: 12-14

[yellow]3. JSON конфигурация (profiles.json):[/yellow]
```json
{
    "profiles": {
        "defaults": {
            "font": {
                "face": "Cascadia Code",
                "size": 12
            }
        }
    }
}
```

[yellow]4. Для VSCode Terminal:[/yellow]
• File → Preferences → Settings
• Найти "terminal.integrated.fontFamily"
• Установить: "Cascadia Code, JetBrains Mono, monospace"

[yellow]5. Для PowerShell:[/yellow]
• Правый клик на заголовке → Properties
• Font → Cascadia Code"""

    console.print(Panel(setup_instructions, border_style="blue"))

def test_emoji_rendering():
    """Тест отображения эмодзи"""
    console.print(Panel.fit(
        "[bold magenta]🧪 Тест отображения эмодзи[/bold magenta]",
        border_style="magenta"
    ))

    test_cases = [
        ("Базовые эмодзи", "😀 😂 🤔 😍 🤩"),
        ("Программирование", "🐍 🔥 💻 📦 ⚡"),
        ("Флаги (проблемные)", "🇺🇦 🇺🇸 🇬🇧 🇩🇪 🇫🇷"),
        ("Цветные геометрические", "🔴 🟠 🟡 🟢 🔵 🟣"),
        ("Сложные эмодзи", "👨‍💻 👩‍🔬 🏴‍☠️"),
        ("Символы", "✅ ❌ ⚠️ ℹ️ 🚀"),
        ("Валюты", "$ € £ ¥ ₿ Ξ"),
    ]

    for category, emojis in test_cases:
        console.print(f"[bold]{category}:[/bold] {emojis}")

    console.print("\n[yellow]❓ Если вы видите квадраты □ или знаки вопроса ?, то шрифт не поддерживает эти эмодзи[/yellow]")

def create_font_install_script():
    """Создание скрипта для автоматической установки шрифтов"""
    script_content = """@echo off
echo Installing fonts for better emoji support...

REM Install Cascadia Code
winget install Microsoft.CascadiaCode --accept-package-agreements

REM Install JetBrains Mono  
winget install JetBrains.JetBrainsMono --accept-package-agreements

REM Install Windows Terminal if not installed
winget install Microsoft.WindowsTerminal --accept-package-agreements

echo.
echo Installation complete!
echo Please restart your terminal applications.
pause
"""

    script_path = Path("install_fonts.bat")
    script_path.write_text(script_content, encoding='utf-8')

    console.print(f"[green]✅ Создан скрипт: {script_path.absolute()}[/green]")
    console.print("[yellow]Запустите install_fonts.bat от имени администратора[/yellow]")

def main():
    console.print(Panel.fit(
        "[bold magenta]🔤 Настройка шрифтов для эмодзи в Windows[/bold magenta]\n"
        "[cyan]Улучшение поддержки эмодзи в терминалах Windows[/cyan]",
        border_style="magenta"
    ))

    if platform.system() != "Windows":
        console.print("[yellow]⚠️ Этот инструмент предназначен для Windows[/yellow]")
        console.print("[cyan]В Linux/macOS эмодзи обычно работают из коробки[/cyan]")
        return

    # Показываем текущий статус
    show_font_status()

    # Тест отображения
    console.print("\n")
    test_emoji_rendering()

    # Инструкции по настройке
    console.print("\n")
    show_windows_terminal_setup()

    # Предлагаем автоматическую установку
    console.print("\n")
    if Confirm.ask("🤖 Установить Cascadia Code автоматически?"):
        install_cascadia_code()

    if Confirm.ask("📝 Создать bat-скрипт для установки всех шрифтов?"):
        create_font_install_script()

    # Финальные рекомендации
    final_panel = Panel(
        """[bold green]🎉 Рекомендации для идеальной работы с эмодзи:[/bold green]

1️⃣ [bold]Используйте Windows Terminal[/bold] вместо стандартного cmd/PowerShell
2️⃣ [bold]Установите Cascadia Code[/bold] - лучший шрифт для эмодзи  
3️⃣ [bold]Настройте шрифт[/bold] в вашем терминале/редакторе
4️⃣ [bold]Обновите Windows[/bold] до последней версии
5️⃣ [bold]Используйте emoji_system_windows.py[/bold] с автоматическими фоллбэками

[yellow]💡 После установки шрифтов перезапустите все терминалы![/yellow]""",
        title="✨ Итоги",
        border_style="green"
    )
    console.print(final_panel)

if __name__ == "__main__":
    main()