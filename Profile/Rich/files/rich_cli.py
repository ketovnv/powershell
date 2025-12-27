#!/usr/bin/env python3
"""
Rich CLI - Удобный интерфейс для вызова Rich из командной строки/PowerShell
Использование: python rich_cli.py <command> [options]
"""

import argparse
import json
from rich.json import JSON
import sys
from pathlib import Path

# Импортируем наши Rich модули
try:
    from rich_theme import  console, log, print_gradient_log,setup_gradient_console
    from rich_theme import print_fire_gradient, print_ocean_gradient, print_code_with_gradient_borders
    from rich_theme import create_rainbow_text, highlight_with_custom_gradients

    from gradient_rich_theme import (
        print_fire_gradient, print_ocean_gradient, create_rainbow_text, 
        print_rainbow_title, log as gradient_log
    )
    GRADIENT_AVAILABLE = True
except ImportError:
    from rich.console import Console
    from rich.syntax import Syntax
    console = Console()
    GRADIENT_AVAILABLE = False

def cmd_log(args):
    """Команда для логирования"""
    if GRADIENT_AVAILABLE and args.gradient:
        gradient_log(args.message, args.level)
    else:
        level_colors = {
            'INFO': 'bold blue',
            'SUCCESS': 'bold green',
            'WARN': 'bold yellow', 
            'ERROR': 'bold red',
            'DEBUG': 'dim cyan'
        }
        style = level_colors.get(args.level, 'white')
        console.print(f"[{style}]{args.level}[/{style}]: {args.message}")

def cmd_code(args):
    """Команда для отображения кода"""
    code = args.code
    if args.file:
        try:
            code = Path(args.file).read_text(encoding='utf-8')
        except Exception as e:
            console.print(f"[bold red]Ошибка чтения файла: {e}[/bold red]")
            return
    
    if hasattr(print_code_with_gradient_borders, '__call__'):
        print_code_with_gradient_borders(code, args.language, args.line_numbers )
    else:
        syntax = Syntax(code, args.language, line_numbers=args.line_numbers)
        console.print(syntax)

def cmd_json(args):
    """Команда для отображения JSON"""
    try:
        # if args.file:
        #     data = json.loads(Path(args.file).read_text())
        # else:
        #     data = json.loads(args.data)
            # json.dumps(data, indent=2)
            # syntax = Syntax(JSON.from_data(data), "json")
        console.print(args.data)
    except json.JSONDecodeError as e:
        console.print(f"[bold red]Ошибка JSON: {e}[/bold red]")
    except Exception as e:
        console.print(f"[bold red]Ошибка: {e}[/bold red]")

def cmd_table(args):
    """Команда для отображения таблицы"""
    try:
        data = json.loads(args.data)
        headers = json.loads(args.headers) if args.headers else None
        
        if hasattr(print_table, '__call__'):
            print_table(data, headers, args.title)
        else:
            from rich.table import Table
            table = Table(title=args.title)
            
            if headers:
                for header in headers:
                    table.add_column(header)
            
            for row in data:
                table.add_row(*[str(cell) for cell in row])
            
            console.print(table)
    except Exception as e:
        console.print(f"[bold red]Ошибка создания таблицы: {e}[/bold red]")

def cmd_gradient(args):
    """Команда для градиентного текста"""
    if not GRADIENT_AVAILABLE:
        console.print("[bold red]Градиентные функции недоступны. Установите gradient_rich_theme.[/bold red]")
        return
    
    text = args.text
    gradient_type = args.type.lower()
    
    if gradient_type == 'fire':
        print_fire_gradient(text)
    elif gradient_type == 'ocean':
        print_ocean_gradient(text) 
    elif gradient_type == 'rainbow':
        rainbow_text = create_rainbow_text(text)
        console.print(rainbow_text)
    elif gradient_type == 'title':
        print_rainbow_title(text)
    else:
        console.print(f"[bold red]Неизвестный тип градиента: {gradient_type}[/bold red]")

def cmd_text(args):
    """Простой вывод текста со стилем"""
    console.print(args.text, style=args.style)
    
def cmd_setup(args):     
    setup_gradient_console()   

def cmd_panel(args):
    """Вывод текста в панели"""
    from rich.panel import Panel
    panel = Panel(
        args.text,
        title=args.title if args.title else None,
        border_style=args.border_style
    )
    console.print(panel)

def cmd_progress(args):
    """Демонстрация прогресс-бара"""
    from rich.progress import track
    import time
    
    for i in track(range(args.steps), description=args.description):
        time.sleep(args.delay)

def cmd_tree(args):
    """Отображение дерева файлов"""
    from rich.tree import Tree
    from pathlib import Path
    
    def build_tree(tree, path, max_depth=3, current_depth=0):
        if current_depth >= max_depth:
            return
        
        try:
            for item in sorted(path.iterdir()):
                if item.name.startswith('.'):
                    continue
                    
                if item.is_dir():
                    branch = tree.add(f"📁 {item.name}")
                    if current_depth < max_depth - 1:
                        build_tree(branch, item, max_depth, current_depth + 1)
                else:
                    tree.add(f"📄 {item.name}")
        except PermissionError:
            tree.add("❌ Permission denied")
    
    root_path = Path(args.path)
    tree = Tree(f"🗂️ {root_path.name}")
    build_tree(tree, root_path, args.depth)
    console.print(tree)

def main():
    parser = argparse.ArgumentParser(
        description="Rich CLI - Красивый вывод в терминале",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Примеры использования:
  python rich_cli.py log "Сообщение" -l INFO
  python rich_cli.py code "print('Hello')" -lang python
  python rich_cli.py json '{"name": "test", "value": 123}'
  python rich_cli.py gradient "Красивый текст" -t rainbow
  python rich_cli.py table '[["Alice", 25], ["Bob", 30]]' -headers '["Name", "Age"]'
        """
    )
    
    subparsers = parser.add_subparsers(dest='command', help='Доступные команды')
    
    # Команда log
    log_parser = subparsers.add_parser('log', help='Логирование сообщений')
    log_parser.add_argument('message', help='Сообщение для логирования')
    log_parser.add_argument('-l', '--level', default='INFO', 
                           choices=['INFO', 'SUCCESS', 'WARN', 'ERROR', 'DEBUG'],
                           help='Уровень лога')
    log_parser.add_argument('-g', '--gradient', action='store_true',
                           help='Использовать градиентную подсветку')
    log_parser.set_defaults(func=cmd_log)
    
    # Команда code
    code_parser = subparsers.add_parser('code', help='Отображение кода')
    code_parser.add_argument('code', nargs='?', help='Код для отображения')
    code_parser.add_argument('-f', '--file', help='Файл с кодом')
    code_parser.add_argument('-lang', '--language', default='python', help='Язык программирования')
    code_parser.add_argument('-ln', '--line-numbers', action='store_true', help='Показать номера строк')
    code_parser.add_argument('-t', '--title', help='Заголовок блока кода')
    code_parser.set_defaults(func=cmd_code)
    
    # Команда json
    json_parser = subparsers.add_parser('json', help='Отображение JSON')
    json_parser.add_argument('data', nargs='?', help='JSON строка')
    json_parser.add_argument('-f', '--file', help='Файл с JSON')
    json_parser.set_defaults(func=cmd_json)
    
    # Команда table
    table_parser = subparsers.add_parser('table', help='Отображение таблицы')
    table_parser.add_argument('data', help='Данные таблицы в формате JSON')
    table_parser.add_argument('-headers', help='Заголовки таблицы в формате JSON')
    table_parser.add_argument('-t', '--title', help='Заголовок таблицы')
    table_parser.set_defaults(func=cmd_table)
    
    # Команда gradient
    gradient_parser = subparsers.add_parser('gradient', help='Градиентный текст')
    gradient_parser.add_argument('text', help='Текст для градиента')
    gradient_parser.add_argument('-t', '--type', default='rainbow',
                                choices=['fire', 'ocean', 'rainbow', 'title'],
                                help='Тип градиента')
    gradient_parser.set_defaults(func=cmd_gradient)
    
    # Команда text
    text_parser = subparsers.add_parser('text', help='Простой текст со стилем')
    text_parser.add_argument('text', help='Текст для вывода')
    text_parser.add_argument('-s', '--style', default='white', help='Стиль текста')
    text_parser.set_defaults(func=cmd_text)
    
    # Команда panel
    panel_parser = subparsers.add_parser('panel', help='Текст в панели')
    panel_parser.add_argument('text', help='Текст для панели')
    panel_parser.add_argument('-t', '--title', help='Заголовок панели')
    panel_parser.add_argument('-b', '--border-style', default='blue', help='Стиль границы')
    panel_parser.set_defaults(func=cmd_panel)
    
    # Команда progress
    progress_parser = subparsers.add_parser('progress', help='Прогресс-бар')
    progress_parser.add_argument('-s', '--steps', type=int, default=10, help='Количество шагов')
    progress_parser.add_argument('-d', '--delay', type=float, default=0.1, help='Задержка между шагами')
    progress_parser.add_argument('-desc', '--description', default='Processing...', help='Описание процесса')
    progress_parser.set_defaults(func=cmd_progress)
    
    # Команда tree
    tree_parser = subparsers.add_parser('tree', help='Дерево файлов')
    tree_parser.add_argument('path', default='.', nargs='?', help='Путь к директории')
    tree_parser.add_argument('-d', '--depth', type=int, default=3, help='Глубина дерева')
    tree_parser.set_defaults(func=cmd_tree)
    
    setup_parser = subparsers.add_parser('setup', help='Инициализация консоли')    
    setup_parser.set_defaults(func=cmd_setup)
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    try:
        args.func(args)
    except Exception as e:
        console.print(f"[bold red]Ошибка выполнения команды: {e}[/bold red]")
        if '--debug' in sys.argv:
            raise

if __name__ == '__main__':
    main()



class PowerSyntaxStyle(material.MaterialStyle):
    name = 'material'
    background_color = '$( $colors.background)'

