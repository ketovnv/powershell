"""
Глобальная настройка Rich через reconfigure()
Импортируйте этот модуль ПЕРВЫМ в любом проекте для автоматического применения темы
"""

from rich import reconfigure
from rich.theme import Theme
from rich.console import Console

# ==================== ВАША ГЛОБАЛЬНАЯ ТЕМА ====================
GLOBAL_THEME = Theme({
    # Основные цвета
    'primary': 'bold '+ '#F1F2F6',
    'secondary': '#95a5a6',
    'accent': '#9b59b6',
    'info': '#3498db', 
    'success': '#2ecc71',
    'warning': '#f39c12',
    'error': '#e74c3c',
    'muted': 'dim #7f8c8d',
    'debug': 'dim #95a5a6',
    
    # JSON стили (для rich.print с JSON)
    'json.key': 'bold '+ '#3498db',
    'json.string': '#2ecc71',
    'json.number': '#f39c12',
    'json.bool_true': 'bold #2ecc71',
    'json.bool_false': 'bold #e74c3c',
    'json.null': 'italic #95a5a6',
    
    # Repr стили (для rich.print с объектами Python)
    'repr.number': '#f39c12',
    'repr.str': '#2ecc71',
    'repr.bool_true': 'bold #2ecc71',
    'repr.bool_false': 'bold #e74c3c',
    'repr.none': 'italic #95a5a6',
    'repr.call': 'bold #3498db',
    'repr.attrib_name': '#9b59b6',
    'repr.attrib_value': '#2ecc71',
    'repr.tag_start': 'bold #9b59b6',
    'repr.tag_name': 'bold #e74c3c',
    'repr.tag_contents': '#2ecc71',
    'repr.tag_end': 'bold #9b59b6',
    'repr.url': 'underline #3498db',
    'repr.uuid': '#f39c12',
    'repr.filename': '#2ecc71',
    'repr.path': 'bold #3498db',
    
    # Инспект стили (для rich.inspect)
    'inspect.callable': 'bold #9b59b6',
    'inspect.def': 'bold #e74c3c',
    'inspect.async_def': 'bold #e74c3c',
    'inspect.class': 'bold #f39c12',
    'inspect.parameter.name': '#3498db',
    'inspect.parameter.default': 'italic #95a5a6',
    'inspect.value.border': '#7f8c8d',
    'inspect.value.title': 'bold #3498db',
    'inspect.doc': 'italic #95a5a6',
    'inspect.attr.dunder': 'italic #7f8c8d',
    'inspect.attr': '#3498db',
    
    # Progress стили
    'progress.description': '#95a5a6',
    'progress.percentage': 'bold #3498db',
    'progress.download': '#2ecc71',
    'progress.filesize': '#f39c12',
    'progress.filesize.total': '#f39c12',
    'progress.elapsed': '#95a5a6',
    'progress.remaining': '#95a5a6',
    'progress.data.speed': '#f39c12',
    'progress.spinner': '#9b59b6',
    
    # Таблицы
    'table.header': 'bold #3498db',
    'table.footer': 'bold #3498db',
    'table.cell': 'white',
    'table.title': 'bold #3498db',
    'table.caption': 'italic #95a5a6',
    
    # Панели и границы
    'panel.border': '#3498db',
    'panel.title': 'bold #3498db',
    'border.key': '#95a5a6',
    
    # Tree стили
    'tree.line': '#7f8c8d',
    
    # Логирование
    'logging.level.critical': 'bold white on red',
    'logging.level.error': 'bold #e74c3c',
    'logging.level.warning': 'bold #f39c12',
    'logging.level.info': 'bold #3498db',
    'logging.level.debug': 'dim #95a5a6',
    'logging.level.trace': 'dim #7f8c8d',
    'logging.keyword': 'bold #9b59b6',
    'logging.time': 'dim #95a5a6',
    'logging.level.name': 'bold',
    'logging.filename': '#2ecc71',
    'logging.funcname': '#3498db',
    'logging.lineno': '#f39c12',
    
    # Статус и спиннеры
    'status.spinner': '#9b59b6',
    'status.text': '#95a5a6',
    
    # Подсветка синтаксиса (базовые стили для встроенной подсветки)
    'syntax.text': 'white',
    'syntax.comment': 'italic #95a5a6',
    'syntax.comment.hashbang': 'italic #95a5a6',
    'syntax.comment.multiline': 'italic #95a5a6',
    'syntax.comment.single': 'italic #95a5a6',
    'syntax.comment.special': 'italic bold #95a5a6',
    'syntax.keyword': 'bold #9b59b6',
    'syntax.keyword.constant': 'bold #e74c3c',
    'syntax.keyword.declaration': 'bold #9b59b6',
    'syntax.keyword.namespace': 'bold #9b59b6',
    'syntax.keyword.pseudo': 'bold #9b59b6',
    'syntax.keyword.reserved': 'bold #9b59b6',
    'syntax.keyword.type': 'bold #f39c12',
    'syntax.operator': '#3498db',
    'syntax.operator.word': 'bold #9b59b6',
    'syntax.punctuation': '#95a5a6',
    'syntax.name': 'white',
    'syntax.name.attribute': '#3498db',
    'syntax.name.builtin': 'bold #e74c3c',
    'syntax.name.builtin.pseudo': 'bold #e74c3c',
    'syntax.name.class': 'bold #f39c12',
    'syntax.name.constant': 'bold #e74c3c',
    'syntax.name.decorator': 'bold #9b59b6',
    'syntax.name.entity': 'bold #f39c12',
    'syntax.name.exception': 'bold #e74c3c',
    'syntax.name.function': 'bold #3498db',
    'syntax.name.function.magic': 'bold #9b59b6',
    'syntax.name.property': '#3498db',
    'syntax.name.label': 'italic #95a5a6',
    'syntax.name.namespace': 'underline #f39c12',
    'syntax.name.other': 'white',
    'syntax.name.tag': 'bold #e74c3c',
    'syntax.name.variable': '#3498db',
    'syntax.name.variable.class': '#3498db',
    'syntax.name.variable.global': '#3498db',
    'syntax.name.variable.instance': '#3498db',
    'syntax.name.variable.magic': 'bold #9b59b6',
    'syntax.literal': '#f39c12',
    'syntax.literal.date': '#f39c12',
    'syntax.string': '#2ecc71',
    'syntax.string.affix': '#2ecc71',
    'syntax.string.backtick': '#2ecc71',
    'syntax.string.char': '#2ecc71',
    'syntax.string.delimiter': '#2ecc71',
    'syntax.string.doc': 'italic #2ecc71',
    'syntax.string.double': '#2ecc71',
    'syntax.string.escape': 'bold #e74c3c',
    'syntax.string.heredoc': '#2ecc71',
    'syntax.string.interpol': 'bold #3498db',
    'syntax.string.other': '#2ecc71',
    'syntax.string.regex': 'bold #f39c12',
    'syntax.string.single': '#2ecc71',
    'syntax.string.symbol': '#2ecc71',
    'syntax.number': '#f39c12',
    'syntax.number.bin': '#f39c12',
    'syntax.number.float': '#f39c12',
    'syntax.number.hex': '#f39c12',
    'syntax.number.integer': '#f39c12',
    'syntax.number.integer.long': '#f39c12',
    'syntax.number.oct': '#f39c12',
    'syntax.generic': 'white',
    'syntax.generic.deleted': 'bold #e74c3c',
    'syntax.generic.emph': 'italic white',
    'syntax.generic.error': 'bold #e74c3c',
    'syntax.generic.heading': 'bold #3498db',
    'syntax.generic.inserted': 'bold #2ecc71',
    'syntax.generic.output': '#95a5a6',
    'syntax.generic.prompt': 'bold #3498db',
    'syntax.generic.strong': 'bold white',
    'syntax.generic.subheading': 'bold #f39c12',
    'syntax.generic.traceback': 'bold #e74c3c',
})

# ==================== ГЛОБАЛЬНАЯ ПЕРЕНАСТРОЙКА ====================

def setup_global_rich_theme():

    reconfigure(
        theme=GLOBAL_THEME,
        force_terminal=True,  # Принудительно включаем цвета
        width=120,            # Ширина консоли по умолчанию
        legacy_windows=False, # Отключаем legacy режим для Windows
        safe_box=True,        # Безопасные символы для box drawing
        _environ={},          # Не переопределяем переменные окружения
    )
    
    print("🎨 Rich глобально настроен с вашей темой!")

# ==================== ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ ====================

def get_themed_console(**kwargs):
    """
    Создает Console с нашей темой (для явного использования)
    Параметры будут объединены с глобальной темой
    """
    # Тема уже установлена глобально через reconfigure(),
    # но можно передать дополнительные параметры
    return Console(**kwargs)

def update_global_theme(additional_styles):
    """
    Обновляет глобальную тему дополнительными стилями
    
    Args:
        additional_styles (dict): Дополнительные стили для добавления
    """
    # Объединяем стили
    updated_styles = {**GLOBAL_THEME.styles, **additional_styles}
    updated_theme = Theme(updated_styles)
    
    # Применяем обновленную тему глобально
    reconfigure(theme=updated_theme)
    print(f"✅ Глобальная тема обновлена! Добавлено стилей: {len(additional_styles)}")

def reset_to_default_theme():
    """Сбрасывает Rich к стандартной теме"""
    reconfigure(theme=None)
    print("🔄 Rich сброшен к стандартной теме")

def show_theme_demo():
    """Демонстрация всех стилей темы"""
    from rich import print
    from rich.panel import Panel
    from rich.table import Table
    from rich.syntax import Syntax
    from rich.progress import track
    from rich.tree import Tree
    import time
    
    print(Panel("🎨 [panel.title]ДЕМОНСТРАЦИЯ ТЕМЫ[/panel.title] 🎨", style="panel.border"))
    
    # Основные стили
    print("\n[bold]Основные стили:[/bold]")
    print("  [primary]Primary text[/primary]")
    print("  [success]Success message[/success]") 
    print("  [warning]Warning message[/warning]")
    print("  [error]Error message[/error]")
    print("  [info]Info message[/info]")
    print("  [muted]Muted text[/muted]")
    
    # Python объекты
    print("\n[bold]Python объекты:[/bold]")
    print({"name": "test", "active": True, "count": 42, "value": None})
    print([1, 2, 3, "hello", True, None])
    
    # Код
    print("\n[bold]Подсветка кода:[/bold]")
    code = '''
def hello_world(name: str = "World") -> str:
    """Приветствует мир"""
    return f"Hello, {name}!"

# Вызов функции
result = hello_world("Rich")
print(result)  # Hello, Rich!
'''
    syntax = Syntax(code, "python", line_numbers=True)
    print(syntax)
    
    # Таблица
    print("\n[bold]Таблица:[/bold]")
    table = Table(title="Пример таблицы", style="table.header")
    table.add_column("Имя", style="primary")
    table.add_column("Возраст", style="accent", justify="right")
    table.add_column("Статус", style="success")
    
    table.add_row("Alice", "25", "✅ Активна")
    table.add_row("Bob", "30", "❌ Неактивен") 
    table.add_row("Carol", "28", "✅ Активна")
    
    print(table)
    
    # Дерево
    print("\n[bold]Дерево:[/bold]")
    tree = Tree("📁 [primary]Проект[/primary]")
    tree.add("📄 main.py")
    tree.add("📄 config.py")
    src = tree.add("📁 src")
    src.add("📄 __init__.py")
    src.add("📄 utils.py")
    print(tree)
    
    # Прогресс
    print("\n[bold]Прогресс-бар:[/bold]")
    for i in track(range(20), description="[progress.description]Обработка файлов[/progress.description]"):
        time.sleep(0.05)

def list_all_styles():
    """Выводит все доступные стили темы"""
    from rich.table import Table
    from rich import print
    
    table = Table(title="Все стили темы", show_header=True, header_style="table.header")
    table.add_column("Название стиля", style="primary")
    table.add_column("Пример", style="secondary")
    
    for style_name, style_value in GLOBAL_THEME.styles.items():
        table.add_row(style_name, f"[{style_name}]Пример текста[/{style_name}]")
    
    print(table)

# ==================== АВТОМАТИЧЕСКАЯ ИНИЦИАЛИЗАЦИЯ ====================

# Автоматически настраиваем Rich при импорте модуля
setup_global_rich_theme()

# Экспортируем для удобства
__all__ = [
    'GLOBAL_THEME', 
    'setup_global_rich_theme',
    'get_themed_console', 
    'update_global_theme',
    'reset_to_default_theme',
    'show_theme_demo',
    'list_all_styles'
]

# ==================== ПРИМЕР ИСПОЛЬЗОВАНИЯ ====================

if __name__ == "__main__":
    # Демонстрация возможностей
    show_theme_demo()
    list_all_styles()
    print("\n" + "="*60)
    print("Теперь ALL Rich функции используют вашу тему!")
    print("="*60)
    
    # Проверим, что обычные Rich функции работают с нашей темой
    from rich import print, inspect
    from rich.console import Console
    
    # Создаем новые Console - они автоматически будут с нашей темой
    console = Console()
    
    
    # console.print("✅ Console 1 использует глобальную тему!", style="success")
    # console2.print("✅ Console 2 тоже использует глобальную тему!", style="primary")
    
    # Даже rich.print использует нашу тему
    print("✅ [accent]rich.print тоже использует глобальную тему![/accent]")
    
    # И inspect тоже
    def example_function(x: int = 42) -> str:
        """Пример функции для демонстрации"""
        return f"Result: {x}"
    
    print("\n[bold]rich.inspect с нашей темой:[/bold]")
    inspect(example_function)
    
    from rich.console import Console
from rich.color import Color
from rich.progress import Progress, BarColumn, TextColumn
from rich.live import Live
from rich.panel import Panel
from time import sleep
import math
from rich.json import JSON
import json
from rich.table import Table
console = Console()
def format_api_response():
    """Красивое отображение JSON ответов API"""
    
    
    # Табличное представление пользователей
    users_table = Table(title="👥 Users Data")
    users_table.add_column("ID", justify="center")
    users_table.add_column("Name", style="cyan")
    users_table.add_column("Email", style="blue")
    users_table.add_column("Status", justify="center")
    
    for user in api_data["data"]["users"]:
        status = "[green]Active[/green]" if user["active"] else "[red]Inactive[/red]"
        users_table.add_row(
            str(user["id"]), 
            user["name"], 
            user["email"], 
            status
        )
    
   console.print(users_table)
format_api_response()    
from rich.console import Console
from rich.color import Color
from rich.progress import Progress, BarColumn, TextColumn
from rich.live import Live
from rich.panel import Panel
from time import sleep
import math

console = Console()

def gradient_text(text, color1=r'$( $color1 )', color2=r'$( $color2 )'):
    length = len(text)
    result = ""
    for i, char in enumerate(text):
        ratio = i / max(length - 1, 1)
        r1, g1, b1 = Color.parse(color1).triplet
        r2, g2, b2 = Color.parse(color2).triplet
        r = int(r1 + (r2 - r1) * ratio)
        g = int(g1 + (g2 - g1) * ratio)
        b = int(b1 + (b2 - b1) * ratio)
        result += f"[#{r:02x}{g:02x}{b:02x}]{char}[/]"
    return result
text = "RICH GRADIENT"
console.print(gradient_text(r'$( $text )'), style="bold", justify=r'$( $justify )')
import json

data = {
    "name": "John",
    "age": 30,
    "cities": ["New York", "London", "Tokyo"]
}

console.print(json.dumps(data, indent=2))
from rich.console import Console
from rich.table import Table
from rich.progress import track
from rich.panel import Panel
import time

console = Console()

# Приветствие
console.print(Panel.fit("🐍 Python Rich в PowerShell 7.6", style="bold blue"))

# Таблица
table = Table(show_header=True, header_style="bold magenta")
table.add_column("Файл", style="dim")
table.add_column("Размер")
table.add_column("Статус", justify="center")

table.add_row("config.json", "1.2KB", "[green]✓[/green]")
table.add_row("data.csv", "45MB", "[yellow]⚠[/yellow]")
table.add_row("backup.zip", "120MB", "[red]✗[/red]")

console.print(table)

# Progress bar
for i in track(range(20), description="Обработка файлов..."):
    time.sleep(0.1)

console.print("[bold green]Готово![/bold green] 🎉")
from rich.console import Console
from rich.measure import Measurement

class CustomGauge:
    """Кастомный индикатор прогресса"""
    
    def __init__(self, value: float, max_value: float = 100):
        self.value = value
        self.max_value = max_value
    
    def __rich_console__(self, console, options):
        width = options.max_width or 40
        filled = int((self.value / self.max_value) * width)
        bar = "█" * filled + "░" * (width - filled)
        percentage = (self.value / self.max_value) * 100
        
        yield f"[cyan]{bar}[/cyan] {percentage:.1f}%"
    
    def __rich_measure__(self, console, options):
        return Measurement(10, options.max_width or 40)

# Использование
console = Console()
console.print(CustomGauge(75, 100))
from rich.spinner import Spinner
from rich.live import Live
import time

def animated_loading():
    """Анимированная загрузка с множественными спиннерами"""
    spinners = ["dots", "line", "arc", "arrow3", "bouncingBar", "clock"]
    
    with Live() as live:
        for i in range(50):
            spinner_name = spinners[i % len(spinners)]
            spinner = Spinner(spinner_name, text=f"Loading... {spinner_name}")
            live.update(Panel(spinner, title=f"Step {i+1}/50"))
            time.sleep(0.2)