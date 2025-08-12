Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

$global:richFolder = "${global:profilePath}/Rich/"

function Show-AllTokens
{
    $py = @"
from pygments.token import *
from rich.console import Console
from rich.table import Table

console = Console()
table = Table(title="Все токены Pygments")
table.add_column("Token", style="cyan")
table.add_column("Description", style="white")

tokens = [
    (Text, "Основной текст"),
    (Comment, "Комментарии"),
    (Keyword, "Ключевые слова"),
    (String, "Строки"),
    (Number, "Числа"),
    (Name.Function, "Функции"),
    (Name.Class, "Классы"),
    (Name.Builtin, "Встроенные функции"),
    (Operator, "Операторы"),
]

for token, desc in tokens:
    table.add_row(str(token), desc)

console.print(table)
"@
    python -c $py
}

function Show-ExistingTheme
{
    $py = @"
from rich.console import Console
from rich.syntax import Syntax
from rich.text import Text

console = Console()

# Тестовый код
code = '''
def fibonacci(n):
    \"\"\"Вычисляет число Фибоначчи\"\"\"
    if n <= 1:  # базовый случай
        return n
    return fibonacci(n-1) + fibonacci(n-2)

numbers = [fibonacci(i) for i in range(8)]
print(f"Результат: {numbers}")
class Example:
    def __init__(self, name):
        self.name = name  # Комментарий

    def greet(self):
        """Документация"""
        return f"Hello, {self.name}!"

obj = Example("World")
print(obj.greet())
'''

# Показываем разные рабочие темы
themes = {
    'default': 'Стандартная светлая тема',
    'emacs': 'Стиль Emacs',
    'friendly': 'Дружелюбная светлая тема',
    'colorful': 'Красочная тема',
    'autumn': 'Осенние цвета',
    'murphy': 'Тема Murphy',
    'manni': 'Тема Manni',
    'material': 'Material Design',
    'monokai': 'Популярная темная тема (как в Sublime)',
    'perldoc': 'Стиль Perl документации',
    'pastie': 'Стиль Pastie',
    'borland': 'Стиль Borland IDE',
    'trac': 'Стиль Trac',
    'native': 'Нативная темная тема',
    'fruity': 'Фруктовая тема',
    'bw': 'Черно-белая тема',
    'vim': 'Стиль Vim',
    'vs': 'Visual Studio стиль',
    'tango': 'Tango цветовая схема',
    'rrt': 'Темная тема RRT',
    'xcode': 'Стиль Xcode',
    'igor': 'Стиль Igor Pro',
    'paraiso-light': 'Светлая тема Paraiso',
    'paraiso-dark': 'Темная тема Paraiso',
    'lovelace': 'Тема Lovelace',
    'algol': 'Стиль Algol',
    'algol_nu': 'Стиль Algol (новый)',
    'arduino': 'Стиль Arduino IDE',
    'rainbow_dash': 'Rainbow Dash тема',
    'abap': 'ABAP стиль',
    'solarized-dark': 'Популярная темная Solarized',
    'solarized-light': 'Светлая Solarized',
    'github-dark': 'GitHub темная тема'
}

for theme_name, description in themes.items():
    console.print(f'\n[bold]{theme_name}[/bold] - {description}')
    try:
        syntax = Syntax(code, 'python', theme=theme_name, line_numbers=True, word_wrap=True)
        console.print(syntax)
        console.print('─' * 60)
    except Exception as e:
        console.print(f'[red]Не работает: {e}[/red]')
"@
    python -c $py
}

function Use-ConsoleThemes
{
    $py = @"
from rich.console import Console
from rich.syntax import Syntax
from rich.theme import Theme

# Создаем кастомную тему для консоли
custom_theme = Theme({
    'info': 'cyan',
    'warning': 'yellow',
    'error': 'red bold',
    'success': 'green bold'
})

console = Console(theme=custom_theme)

code = '''
import logging

class Logger:
    def __init__(self, name):
        self.name = name

    def log_info(self, message):
        logging.info(f"{self.name}: {message}")

    def log_error(self, error):
        logging.error(f"{self.name}: {error}")

logger = Logger("MyApp")
logger.log_info("Приложение запущено")
logger.log_error("Произошла ошибка!")
'''

# Используем лучшие темы
best_themes = ['github-dark', 'monokai', 'material', 'solarized-dark']

for theme in best_themes:
    console.print(f'\n[success]Тема: {theme}[/success]')
    syntax = Syntax(code, 'python', theme=theme, line_numbers=True)
    console.print(syntax)
    console.print('[info]' + '─' * 50 + '[/info]')
"@
    python -c $py
}

function Create-WorkingCustomTheme
{
    # Создаем файл темы
    $themeContent = @'
from pygments.style import Style
from pygments.token import *

class DraculaCustom(Style):
    name = 'dracula-custom'

    # Важно! Указываем background_color
    background_color = '#282a36'
    highlight_color = '#44475a'

    styles = {
        # Базовые
        Text:                   '#f8f8f2',
        Whitespace:             '#f8f8f2',
        Error:                  '#ff5555',
        Other:                  '#f8f8f2',

        # Комментарии - сделаем их зелеными
        Comment:                'italic #50fa7b',
        Comment.Multiline:      'italic #50fa7b',
        Comment.Preproc:        '#50fa7b',
        Comment.Single:         'italic #50fa7b',
        Comment.Special:        'italic bold #50fa7b',

        # Ключевые слова - розовые
        Keyword:                'bold #ff79c6',
        Keyword.Constant:       '#ff79c6',
        Keyword.Declaration:    '#ff79c6',
        Keyword.Namespace:      '#ff79c6',
        Keyword.Pseudo:         '#ff79c6',
        Keyword.Reserved:       '#ff79c6',
        Keyword.Type:           '#8be9fd',

        # Строки - желтые
        String:                 '#f1fa8c',
        String.Affix:           '#f1fa8c',
        String.Backtick:        '#f1fa8c',
        String.Char:            '#f1fa8c',
        String.Delimiter:       '#f1fa8c',
        String.Doc:             'italic #f1fa8c',
        String.Double:          '#f1fa8c',
        String.Escape:          '#ff79c6',
        String.Heredoc:         '#f1fa8c',
        String.Interpol:        '#f1fa8c',
        String.Other:           '#f1fa8c',
        String.Regex:           '#f1fa8c',
        String.Single:          '#f1fa8c',
        String.Symbol:          '#f1fa8c',

        # Числа - фиолетовые
        Number:                 '#bd93f9',
        Number.Bin:             '#bd93f9',
        Number.Float:           '#bd93f9',
        Number.Hex:             '#bd93f9',
        Number.Integer:         '#bd93f9',
        Number.Long:            '#bd93f9',
        Number.Oct:             '#bd93f9',

        # Операторы
        Operator:               '#ff79c6',
        Operator.Word:          '#ff79c6',

        # Пунктуация
        Punctuation:            '#f8f8f2',

        # Имена
        Name:                   '#f8f8f2',
        Name.Attribute:         '#50fa7b',
        Name.Builtin:           '#8be9fd',
        Name.Builtin.Pseudo:    '#8be9fd',
        Name.Class:             'bold #50fa7b',
        Name.Constant:          '#bd93f9',
        Name.Decorator:         '#50fa7b',
        Name.Entity:            '#50fa7b',
        Name.Exception:         'bold #ffb86c',
        Name.Function:          'bold #50fa7b',
        Name.Function.Magic:    '#50fa7b',
        Name.Property:          '#50fa7b',
        Name.Label:             '#8be9fd',
        Name.Namespace:         '#f8f8f2',
        Name.Other:             '#f8f8f2',
        Name.Tag:               '#ff79c6',
        Name.Variable:          '#8be9fd',
        Name.Variable.Class:    '#8be9fd',
        Name.Variable.Global:   '#8be9fd',
        Name.Variable.Instance: '#8be9fd',
        Name.Variable.Magic:    '#8be9fd',

        # Generic
        Generic:                '#f8f8f2',
        Generic.Deleted:        '#ff5555',
        Generic.Emph:           'italic #f8f8f2',
        Generic.Error:          '#ff5555',
        Generic.Heading:        'bold #6272a4',
        Generic.Inserted:       '#50fa7b',
        Generic.Output:         '#6272a4',
        Generic.Prompt:         'bold #6272a4',
        Generic.Strong:         'bold #f8f8f2',
        Generic.Subheading:     'bold #6272a4',
        Generic.Traceback:      '#ff5555'
    }
'@

    # Создаем файл
    Set-Content -Path "dracula_custom.py" -Value $themeContent -Encoding UTF8

    # Создаем setup файл для установки темы
    $setupContent = @'
from setuptools import setup, find_packages

setup(
    name="dracula-custom-pygments",
    version="1.0.0",
    py_modules=["dracula_custom"],
    entry_points={
        'pygments.styles': [
            'dracula-custom = dracula_custom:DraculaCustom',
        ],
    },
)
'@
    Set-Content -Path "setup.py" -Value $setupContent -Encoding UTF8

    # Устанавливаем тему
    python -m pip install -e .

    Write-Host "Тема установлена! Теперь тестируем..." -ForegroundColor Green

    # Тестируем
    $py = @"
from rich.console import Console
from rich.syntax import Syntax

console = Console()

code = '''
class DataProcessor:
    def __init__(self, data_source):
        self.data = data_source  # Это должно быть зеленым!

    def process(self):
        """Документация функции"""
        result = []
        for item in self.data:
            # Комментарий - тоже зеленый
            if isinstance(item, (int, float)):
                result.append(item * 2)
        return result

# Использование
processor = DataProcessor([1, 2.5, "text", 42])
numbers = processor.process()
print(f"Результат: {numbers}")
'''

console.print('[bold]Кастомная Dracula тема (зеленые комментарии):[/bold]')
syntax = Syntax(code, 'python', theme='dracula-custom', line_numbers=True)
console.print(syntax)

console.print('\n[bold]Для сравнения - стандартная monokai:[/bold]')
syntax2 = Syntax(code, 'python', theme='monokai', line_numbers=True)
console.print(syntax2)
"@
    python -c $py
}



function Simple-ColorMod
{
    $py = @"
import pygments.styles.monokai as monokai_module
from pygments.token import *
from rich.console import Console
from rich.syntax import Syntax

# Сохраняем оригинальный класс
OriginalMonokai = monokai_module.MonokaiStyle

class MyMonokai(OriginalMonokai):
    name = 'my-monokai'

    # Просто переопределяем нужные цвета
    styles = OriginalMonokai.styles.copy()
    styles[Comment] = 'italic #39ffFF'              # Неоново-зеленый
    styles[Comment.Single] = 'italic #39ffFF'
    styles[Comment.Multiline] = 'italic #39ffFF'
    styles[String] = '#ffd7FF'                       # Золотой
    styles[Name.Function] = 'bold #00bfff'           # Глубокий голубой
    styles[Number] = '#ff63FF'                       # Помидорный

# Заменяем класс в модуле
monokai_module.MonokaiStyle = MyMonokai

console = Console()

test_code = '''
def fibonacci(n):
    """Вычисляет последовательность Фибоначчи"""
    if n <= 1:  # Базовый случай
        return n
    # Рекурсивный вызов
    return fibonacci(n-1) + fibonacci(n-2)

result = fibonacci(8)
print(f"8-е число Фибоначчи: {result}")
'''

console.print('[bold cyan]Модифицированная тема:[/bold cyan]')
syntax = Syntax(test_code, 'python', theme='monokai', line_numbers=True)
console.print(syntax)
"@
    python -c $py
}

function Modify-AllThemes
{
    $py = @"
import pygments.styles.monokai as monokai
import pygments.styles.gh_dark as github
import pygments.styles.native as native
import pygments.styles.rrt as rrt
import pygments.styles.fruity as fruity
from pygments.token import *
from rich.console import Console
from rich.syntax import Syntax

# Модифицируем сразу несколько тем
themes_to_modify = [
    (monokai, 'MonokaiStyle'),
    (github, 'GhDarkStyle'),
    (native, 'NativeStyle'),
    (fruity, 'FruityStyle'),
    (rrt, 'RrtStyle')
]

custom_colors = {
    Comment: 'italic #00ff7f',              # Весенне-зеленый
    Comment.Single: 'italic #00ff7f',
    Comment.Multiline: 'italic #00ff7f',
    String: '#ffa500',                      # Оранжевый
    Name.Function: 'bold #1e90ff',          # Доджер-синий
    Number: '#da70d6',                      # Орхидея
    Name.Class: 'bold #32cd32',             # Лаймовый
    Keyword: 'bold #ff1493'                 # Глубокий розовый
}

for module, class_name in themes_to_modify:
    original_class = getattr(module, class_name)

    class ModifiedTheme(original_class):
        styles = original_class.styles.copy()
        styles.update(custom_colors)

    # Заменяем класс в модуле
    setattr(module, class_name, ModifiedTheme)

console = Console()
code = '''
class WebServer:
    def __init__(self, port=8080):
        self.port = port  # Порт сервера

    def start(self):
        """Запускает веб-сервер"""
        # Логика запуска
        return f"Сервер запущен на порту {self.port}"

server = WebServer(3000)
message = server.start()
print(message)
'''

themes = ['monokai', 'github-dark', 'native','fruity','rrt']
for theme in themes:
    console.print(f'\n[bold]Модифицированная {theme}:[/bold]')
    syntax = Syntax(code, 'python', theme=theme, line_numbers=True)
    console.print(syntax)
    console.print('─' * 50)
"@
    python -c $py
}

function Create-TempTheme
{
    $py = @"
import tempfile
import sys
import os
from pygments.style import Style
from pygments.token import *
from rich.console import Console
from rich.syntax import Syntax

# Создаем временный модуль с темой
temp_dir = tempfile.mkdtemp()
theme_file = os.path.join(temp_dir, 'mytheme.py')

theme_code = '''
from pygments.style import Style
from pygments.token import *

class CyberPunkStyle(Style):
    name = 'cyberpunk'
    background_color = '#0d1117'

    styles = {
        Text:                   '#c9d1d9',
        Comment:                'italic #9c3aed',      # Фиолетовые комментарии
        Comment.Single:         'italic #7c3aed',
        Comment.Multiline:      'italic #7c3aed',

        Keyword:                'bold #00FFFF',        # Неоново-розовые ключевые слова
        Keyword.Type:           'bold #00ffff',

        String:                 '#00ff41',             # Матричный зеленый
        String.Doc:             'italic #00ff41',

        Number:                 '#ff8c00',             # Киберпанковый оранжевый

        Name.Function:          'bold #0033ff',        # Электрик-синий
        Name.Class:             'bold #ff6b35',        # Ярко-оранжевый
        Name.Builtin:           '#8a2be2',             # Сине-фиолетовый

        Operator:               '#ff1493',             # Глубокий розовый

        Name.Variable:          '#ffd700',             # Золотой
    }
'''

# Записываем файл
with open(theme_file, 'w') as f:
    f.write(theme_code)

# Добавляем в sys.path
sys.path.insert(0, temp_dir)

# Импортируем и заменяем одну из существующих тем
from mytheme import CyberPunkStyle
import pygments.styles.monokai as monokai_module

# Заменяем Monokai на нашу тему
monokai_module.MonokaiStyle = CyberPunkStyle

console = Console()
code = '''
class HackerTools:
    def __init__(self, target_ip):
        self.target = target_ip  # IP цели

    def scan_ports(self):
        """Сканирует открытые порты"""
        # Логика сканирования
        open_ports = [22, 80, 443, 8080]
        return open_ports

    def exploit(self, port):
        """Попытка эксплойта"""
        if port == 22:
            return "SSH брутфорс..."
        return f"Атака на порт {port}"

hacker = HackerTools("192.168.1.1")
ports = hacker.scan_ports()
print(f"Найдены порты: {ports}")
'''

console.print('[bold magenta]🔥 CYBERPUNK THEME 🔥[/bold magenta]')
syntax = Syntax(code, 'python', theme='monokai', line_numbers=True)
console.print(syntax)

# Очищаем временные файлы
import shutil
shutil.rmtree(temp_dir)
"@
    python -c $py
}


function Quick-ThemeSwitch
{
    param([string]$Style = "neon")

    $colorSchemes = @{
        "neon" = @{
            Comment = "#39ff14"      # Неоново-зеленый
            String = "#ff073a"       # Неоново-красный
            Function = "#00ffff"     # Циан
            Number = "#ff8c00"       # Оранжевый
        }
        "matrix" = @{
            Comment = "#00ff41"      # Матричный зеленый
            String = "#00ff41"
            Function = "#ffffff"     # Белый
            Number = "#00ff41"
        }
        "dracula" = @{
            Comment = "#6272a4"      # Серо-синий
            String = "#f1fa8c"       # Желтый
            Function = "#50fa7b"     # Зеленый
            Number = "#bd93f9"       # Фиолетовый
        }
        "vscode" = @{
            Comment = "#6a9955"      # Тусклый зеленый
            String = "#ce9178"       # Песочный
            Function = "#dcdcaa"     # Светло-желтый
            Number = "#b5cea8"       # Светло-зеленый
        }
    }

    $colors = $colorSchemes[$Style]

    $py = @"
import pygments.styles.monokai as monokai
from pygments.token import *
from rich.console import Console
from rich.syntax import Syntax

# Применяем выбранную цветовую схему
class StyledTheme(monokai.MonokaiStyle):
    styles = monokai.MonokaiStyle.styles.copy()
    styles.update({
        Comment: 'italic $( $colors.Comment )',
        Comment.Single: 'italic $( $colors.Comment )',
        Comment.Multiline: 'italic $( $colors.Comment )',
        String: '$( $colors.String )',
        String.Doc: 'italic $( $colors.String )',
        Name.Function: 'bold $( $colors.Function )',
        Number: '$( $colors.Number )'
    })

monokai.MonokaiStyle = StyledTheme

console = Console()
code = '''
def calculate_fibonacci(limit):
    """Генерирует числа Фибоначчи до лимита"""
    a, b = 0, 1  # Начальные значения
    result = []

    while a < limit:
        # Добавляем число в результат
        result.append(a)
        a, b = b, a + b

    return result

numbers = calculate_fibonacci(100)
print(f"Фибоначчи до 100: {numbers}")
'''

console.print(f'[bold]Тема: $Style[/bold]')
syntax = Syntax(code, 'python', theme='monokai', line_numbers=True)
console.print(syntax)
"@
    python -c $py
}

function Setup-GlobalRichTheme
{
    $py = @"
from rich.console import Console
from rich.theme import Theme
from rich.syntax import Syntax
from rich.table import Table
from rich.json import JSON
from rich.panel import Panel
from rich.text import Text
import json

# Создаем глобальную тему для всех элементов Rich
global_theme = Theme({
    # Основные цвета
    'primary': '#00ffff',           # Циан
    'secondary': '#ff00ff',         # Магента
    'accent': '#ffff00',            # Желтый
    'success': '#00ff00',           # Зеленый
    'warning': '#ff8000',           # Оранжевый
    'error': '#ff0000',             # Красный
    'info': '#0080ff',              # Синий

    # Для таблиц
    'table.header': 'bold #00ffff',
    'table.row_even': '#ffffff',
    'table.row_odd': '#e0e0e0',
    'table.border': '#00ffff',

    # Для JSON
    'json.key': 'bold #ff00ff',
    'json.string': '#ffff00',
    'json.number': '#00ff00',
    'json.bool_true': 'bold #00ff00',
    'json.bool_false': 'bold #ff0000',
    'json.null': 'italic #808080',

    # Для панелей
    'panel.border': '#00ffff',
    'panel.title': 'bold #ffffff',

    # Для прогресс-баров
    'progress.description': '#ffffff',
    'progress.percentage': 'bold #00ff00',
    'progress.bar.complete': '#00ff00',
    'progress.bar.finished': '#00ffff',
})

# Создаем консоль с кастомной темой
console = Console(theme=global_theme)

# Также настраиваем цвета для синтаксиса
import pygments.styles.monokai as monokai
from pygments.token import *

class UnifiedTheme(monokai.MonokaiStyle):
    styles = monokai.MonokaiStyle.styles.copy()
    styles.update({
        Comment: 'italic #00ffff',      # Циан как в теме
        String: '#ffff00',              # Желтый как в теме
        Name.Function: 'bold #ff00ff',  # Магента как в теме
        Number: '#00ff00',              # Зеленый как в теме
    })

monokai.MonokaiStyle = UnifiedTheme

# === ДЕМОНСТРАЦИЯ ===

# 1. Код с синтаксисом
code = '''
class DataProcessor:
    def __init__(self, data):
        self.data = data  # Комментарий

    def process(self):
        """Обрабатывает данные"""
        return len(self.data)
'''

console.print(Panel("[bold]1. Код с подсветкой синтаксиса[/bold]", style="panel.border"))
syntax = Syntax(code, 'python', theme='monokai', line_numbers=True)
console.print(syntax)

# 2. Таблица
console.print(Panel("[bold]2. Таблица[/bold]", style="panel.border"))
table = Table(title="Статистика", style="table.border")
table.add_column("Параметр", style="table.header")
table.add_column("Значение", style="table.header")
table.add_column("Статус", style="table.header")

table.add_row("CPU", "85%", "[warning]Высокая[/warning]")
table.add_row("RAM", "45%", "[success]Нормальная[/success]")
table.add_row("Disk", "92%", "[error]Критическая[/error]")
console.print(table)

# 3. JSON
console.print(Panel("[bold]3. JSON данные[/bold]", style="panel.border"))
data = {
    "name": "Сервер",
    "status": True,
    "connections": 150,
    "uptime": None,
    "services": ["web", "database", "cache"]
}
console.print(JSON.from_data(data))

# 4. Текст с разметкой
console.print(Panel("[bold]4. Цветной текст[/bold]", style="panel.border"))
text = Text("🐹")
text.append("Успешно: ", style="success")
text.append("5 операций, ", style="primary")
text.append("Ошибок: ", style="error")
text.append("0, ", style="accent")
text.append("Предупреждений: ", style="warning")
text.append("2", style="secondary")
console.print(text)
"@
    python -c $py
}

function Create-UnifiedColorScheme
{
    param([string]$Scheme = "cyberpunk")

    $schemes = @{
        "cyberpunk" = @{
            primary = "#00ffff"      # Циан
            secondary = "#ff00ff"    # Магента
            accent = "#ffff00"       # Неон-желтый
            success = "#00ff41"      # Матрица-зеленый
            warning = "#ff8000"      # Оранжевый
            error = "#ff0080"        # Неон-розовый
        }
        "dracula" = @{
            primary = "#8be9fd"      # Циан
            secondary = "#ff79c6"    # Розовый
            accent = "#f1fa8c"       # Желтый
            success = "#50fa7b"      # Зеленый
            warning = "#ffb86c"      # Оранжевый
            error = "#ff5555"        # Красный
        }
        "matrix" = @{
            primary = "#00ff41"      # Зеленый
            secondary = "#ffffff"    # Белый
            accent = "#00ff41"       # Зеленый
            success = "#00ff41"      # Зеленый
            warning = "#ffffff"      # Белый
            error = "#ff0000"        # Красный
        }
    }

    $colors = $schemes[$Scheme]

    $py = @"
from rich.console import Console
from rich.theme import Theme
from rich.syntax import Syntax
from rich.table import Table
from rich.json import JSON
from rich.panel import Panel
from rich.progress import Progress, TextColumn, BarColumn, TaskProgressColumn
from rich.tree import Tree
import time

# Создаем тему $Scheme
theme = Theme({
    'primary': '$( $colors.primary )',
    'secondary': '$( $colors.secondary )',
    'accent': '$( $colors.accent )',
    'success': '$( $colors.success )',
    'warning': '$( $colors.warning )',
    'error': '$( $colors.error )',

    # Специальные стили
    'json.key': 'bold $( $colors.primary )',
    'json.string': '$( $colors.accent )',
    'json.number': '$( $colors.success )',
    'json.bool_true': 'bold $( $colors.success )',
    'json.bool_false': 'bold $( $colors.error )',
    'json.null': 'italic $( $colors.secondary )',

    'table.header': 'bold $( $colors.primary )',
    'table.border': '$( $colors.secondary )',
    'panel.border': '$( $colors.primary )',
})

console = Console(theme=theme)

# Настраиваем синтаксис
import pygments.styles.monokai as monokai
from pygments.token import *

class ${Scheme}SyntaxStyle(monokai.MonokaiStyle):
    styles = monokai.MonokaiStyle.styles.copy()
    styles.update({
        Comment: 'italic $( $colors.primary )',
        String: '$( $colors.accent )',
        Name.Function: 'bold $( $colors.success )',
        Number: '$( $colors.warning )',
        Keyword: 'bold $( $colors.secondary )',
    })

monokai.MonokaiStyle = ${Scheme}SyntaxStyle

# === ПОЛНАЯ ДЕМОНСТРАЦИЯ ===

console.print(Panel(f"[bold]🎨 Тема: ${Scheme}.upper() 🎨[/bold]", style="panel.border"))

# 1. Код
console.print(Panel("[bold]Синтаксис кода[/bold]", style="panel.border"))
code = '''
def analyze_data(dataset):
    """Анализирует набор данных"""
    # Подсчитываем статистику
    total = len(dataset)
    average = sum(dataset) / total
    return {"total": total, "average": average}
'''
syntax = Syntax(code, 'python', theme='monokai', line_numbers=True)
console.print(syntax)

# 2. JSON
console.print(Panel("[bold]JSON структура[/bold]", style="panel.border"))
data = {
    "server": "production",
    "active": True,
    "connections": 1250,
    "load": 0.85,
    "errors": None,
    "services": ["api", "web", "db"]
}
console.print(JSON.from_data(data))

# 3. Таблица
console.print(Panel("[bold]Таблица метрик[/bold]", style="panel.border"))
table = Table(title="Мониторинг системы", style="table.border")
table.add_column("Сервис", style="primary")
table.add_column("Статус", justify="center")
table.add_column("CPU", justify="right", style="accent")
table.add_column("RAM", justify="right", style="accent")

table.add_row("API", "[success]Работает[/success]", "23%", "45%")
table.add_row("Database", "[warning]Загружена[/warning]", "78%", "89%")
table.add_row("Cache", "[error]Ошибка[/error]", "5%", "12%")
console.print(table)

# 4. Дерево файлов
console.print(Panel("[bold]Структура проекта[/bold]", style="panel.border"))
tree = Tree("[primary]project/[/primary]")
tree.add("[secondary]src/[/secondary]").add("[accent]main.py[/accent]")
tree.add("[secondary]tests/[/secondary]").add("[accent]test_main.py[/accent]")
tree.add("[accent]README.md[/accent]")
console.print(tree)

# 5. Прогресс-бар (симуляция)
console.print(Panel("[bold]Процесс загрузки[/bold]", style="panel.border"))
with Progress(
    TextColumn("[progress.description]{task.description}"),
    BarColumn(style="success", complete_style="primary"),
    TaskProgressColumn(style="accent"),
    console=console
) as progress:
    task = progress.add_task("Загрузка данных...", total=100)
    for i in range(100):
        progress.update(task, advance=1)
        time.sleep(0.01)
"@
    python -c $py
}

function Set-RichTheme
{
    param(
        [ValidateSet("cyberpunk", "dracula", "matrix", "vscode", "github")]
        [string]$Theme = "cyberpunk"
    )

    # Создаем скрипт темы
    $themeScript = @"
import os
import json
from rich.console import Console
from rich.theme import Theme
from rich.syntax import Syntax
from rich.table import Table
from rich.json import JSON
from rich.panel import Panel

# Загружаем конфиг темы
theme_config = {
    'cyberpunk': {
        'primary': '#00ffff', 'secondary': '#ff00ff', 'accent': '#ffff00',
        'success': '#00ff41', 'warning': '#ff8000', 'error': '#ff0080'
    },
    'dracula': {
        'primary': '#8be9fd', 'secondary': '#ff79c6', 'accent': '#f1fa8c',
        'success': '#50fa7b', 'warning': '#ffb86c', 'error': '#ff5555'
    },
    'matrix': {
        'primary': '#00ff41', 'secondary': '#ffffff', 'accent': '#00ff41',
        'success': '#00ff41', 'warning': '#ffffff', 'error': '#ff0000'
    },
    'vscode': {
        'primary': '#007acc', 'secondary': '#c586c0', 'accent': '#dcdcaa',
        'success': '#4ec9b0', 'warning': '#d7ba7d', 'error': '#f44747'
    },
    'github': {
        'primary': '#0969da', 'secondary': '#8250df', 'accent': '#7c7c7c',
        'success': '#1a7f37', 'warning': '#bf8700', 'error': '#d1242f'
    }
}

colors = theme_config['$Theme']

# Создаем глобальную тему
rich_theme = Theme({
    'primary': colors['primary'],
    'secondary': colors['secondary'],
    'accent': colors['accent'],
    'success': colors['success'],
    'warning': colors['warning'],
    'error': colors['error'],

    'json.key': f"bold {colors['primary']}",
    'json.string': colors['accent'],
    'json.number': colors['success'],
    'json.bool_true': f"bold {colors['success']}",
    'json.bool_false': f"bold {colors['error']}",
    'json.null': f"italic {colors['secondary']}",

    'table.header': f"bold {colors['primary']}",
    'table.border': colors['secondary'],
    'panel.border': colors['primary'],
})

# Устанавливаем синтаксис
import pygments.styles.monokai as monokai
from pygments.token import *

class CustomSyntax(monokai.MonokaiStyle):
    styles = monokai.MonokaiStyle.styles.copy()
    styles.update({
        Comment: f"italic {colors['primary']}",
        String: colors['accent'],
        Name.Function: f"bold {colors['success']}",
        Number: colors['warning'],
        Keyword: f"bold {colors['secondary']}",
    })

monokai.MonokaiStyle = CustomSyntax

# Создаем консоль
console = Console(theme=rich_theme)

# Сохраняем тему для повторного использования
with open('current_theme.json', 'w') as f:
    json.dump(colors, f)

console.print(f"[primary]✨ Тема '{Theme}' активирована![/primary]")
"@

    python -c $themeScript
    Write-Host "Тема $Theme установлена!" -ForegroundColor Green
}

# Функция для тестирования всех элементов с текущей темой
function Test-AllRichElements
{
    $py = @"
import json
from rich.console import Console
from rich.theme import Theme
from rich.syntax import Syntax
from rich.table import Table
from rich.json import JSON
from rich.panel import Panel
from rich.tree import Tree
from rich.text import Text

# Загружаем текущую тему
try:
    with open('current_theme.json', 'r') as f:
        colors = json.load(f)
except:
    colors = {
        'primary': '#00ffff', 'secondary': '#ff00ff', 'accent': '#ffff00',
        'success': '#00ff41', 'warning': '#ff8000', 'error': '#ff0080'
    }

theme = Theme({
    'primary': colors['primary'],
    'secondary': colors['secondary'],
    'accent': colors['accent'],
    'success': colors['success'],
    'warning': colors['warning'],
    'error': colors['error'],
    'background_color': '#050709'
    'json.key': f"bold {colors['primary']}",
    'json.string': colors['accent'],
    'json.number': colors['success'],
    'table.header': f"bold {colors['primary']}",
    'table.row_even': '#ffffff',
    'table.row_odd': '#e0e0e0',
    'table.border': '#00ffff',
    'panel.border': colors['primary'],
})

console = Console(theme=theme)

# Тестируем все элементы
console.print(Panel("[bold]🎨 ТЕСТ ВСЕХ ЭЛЕМЕНТОВ 🎨[/bold]", style="panel.border"))

# Код
code = 'def hello(): return "world"  # комментарий'
console.print(Syntax(code, 'python', theme=theme))

# JSON
data = {"status": True, "count": 42, "name": "test", "errors": None}
console.print(JSON.from_data(data))

# Таблица
table = Table(style="table.border")
table.add_column("Ключ", style="primary")
table.add_column("Значение", style="accent")
table.add_row("Success", "[success]✓[/success]")
table.add_row("Warning", "[warning]⚠[/warning]")
table.add_row("Error", "[error]✗[/error]")
console.print(table)

# Текст
text = Text()
text.append("Primary ", style="primary")
text.append("Secondary ", style="secondary")
text.append("Accent", style="accent")
console.print(text)
"@
    python -c $py
}


function Set-PowerTheme
{
    $colors = @{
        primary = "#F1F2AB"
        background = '#030608'
        gradient = "#CCC570"
        secondary = "#ffffff"
        accent = "#B277BF"
        secondaryAccent = "#9247FF"
        info = "#8FBBDF"
        comment = "#555555"
        faded = "#151819"
        highlight = "#FFFF00"
        success = "#05AF35"
        warning = "#ffBD55"
        error = "#ff0000"
    }
    $Theme = "Power"
    # Создаем скрипт темы
    $themeScript = @"
from rich.console import Console
from rich.theme import Theme
from rich.syntax import Syntax
from rich.table import Table
from rich.json import JSON
from rich.panel import Panel
from rich.progress import Progress, TextColumn, BarColumn, TaskProgressColumn
from rich.tree import Tree
import json
import time


theme = Theme({
    'primary': '$( $colors.primary )',
    'secondary': '$( $colors.secondary )',
    'accent': '$( $colors.accent )',
    'info': '$( $colors.info )',
    'success': '$( $colors.success )',
    'warning': '$( $colors.warning )',
    'error': '$( $colors.error )',

    # Специальные стили
    'json.key': 'bold $( $colors.primary )',
    'json.str': '$( $colors.info )',
    'json.number': '$( $colors.secondary )',
    'json.bool_true': 'bold $( $colors.success )',
    'json.bool_false': 'bold $( $colors.error )',
    'json.null': 'italic $( $colors.accent )',

    'tree' : '$( $colors.primary )',
    'tree.line' : '$( $colors.secondary )',

    'table.header': 'bold $( $colors.secondaryAccent )',
    'table.border': '$( $colors.faded )',
    'panel.style':    '$( $colors.info)  bold' ,
    'panel.border':    '$( $colors.primary )' + " on " + '$( $colors.background)' ,
})

console = Console(theme=theme)

# Настраиваем синтаксис
import pygments.styles.material as material
from pygments.token import *

class PowerSyntaxStyle(material.MaterialStyle):
    name = 'material'
    background_color = '$( $colors.background)'
    highlight_color = '$( $colors.highlight)',
    line_number_color = '$( $colors.info)',
    line_number_background_color = '$( $colors.fade)',
    line_number_special_color =  '$( $colors.accent)',
    line_number_special_background_color =  '$( $colors.comment)',

    styles = material.MaterialStyle.styles.copy()
    styles.update({

         # Базовые
        Text:                 '$( $colors.primary )',
        Whitespace:       '$( $colors.secondary )',
        Error:                 '$( $colors.error )',
        Other:                '$( $colors.accent )',


        Comment:  '$( $colors.comment )',
        Comment.Multiline:      'italic $( $colors.comment )',
        Comment.Preproc:      'bold $( $colors.comment )',
        Comment.Single:          'italic $( $colors.comment )',
        Comment.Special:        'italic bold $( $colors.comment )',

        # Ключевые слова - розовые
        Keyword:                'bold  $( $colors.secondaryAccent )',
        Keyword.Constant:       '$( $colors.secondaryAccent )',
        Keyword.Declaration:    '$( $colors.secondaryAccent )',
        Keyword.Namespace:      '$( $colors.secondaryAccent )',
        Keyword.Pseudo:         '$( $colors.secondaryAccent )',
        Keyword.Reserved:       '$( $colors.secondaryAccent )',
        Keyword.Type:           '$( $colors.secondaryAccent )',


        Literal:                       '$( $colors.success )',
        Literal.Date:    '$( $colors.success )',
        # Строки - желтые
        String: '$( $colors.success )',
#        String.Affix:           '$( $colors.info )',
#        String.Backtick:        '$( $colors.info )',
#        String.Char:            '$( $colors.info )',
#        String.Delimiter:        '$( $colors.info )',
#        String.Doc:            'italic ' + '$( $colors.info )',
#        String.Double:          '$( $colors.info )',
#        String.Escape:         '$( $colors.info )',
#        String.Heredoc:          '$( $colors.info )',
#        String.Interpol:        '$( $colors.info )',
#        String.Other:       '$( $colors.info )',
#        String.Regex:           '$( $colors.info )',
#        String.Single:       '$( $colors.info )',
#        String.Symbol:     'bold '  +   '$( $colors.info )',


        Number:                 '$( $colors.secondary )',
        Number.Bin:           '$( $colors.success )',
        Number.Float:        '$( $colors.secondary )',
        Number.Hex:           '$( $colors.gradient )',
        Number.Integer:       '$( $colors.secondary )',
        Number.Long:          '$( $colors.secondaryAccent )',
        Number.Oct:            '$( $colors.accent )',

        # Операторы
        Operator:              '$( $colors.warning )',
        Operator.Word:       'italic ' +  '$( $colors.warning )',

        # Пунктуация
        Punctuation:           '$( $colors.info )',

        # Имена
        Name:                  '$( $colors.primary )',
#        Name.Attribute:         '#50fa7b',
#        Name.Builtin:           '#8be9fd',
#        Name.Builtin.Pseudo:    '#8be9fd',
#        Name.Class:             'bold #50fa7b',
#        Name.Constant:          '#bd93f9',
#        Name.Decorator:         '#50fa7b',
#        Name.Entity:            '#50fa7b',
#        Name.Exception:         'bold #ffb86c',
#        Name.Function:          'bold #50fa7b',
#        Name.Function.Magic:    '#50fa7b',
#        Name.Property:          '#50fa7b',
#        Name.Label:             '#8be9fd',
#        Name.Namespace:         '#f8f8f2',
#        Name.Other:             '#f8f8f2',
#        Name.Tag:               '#ff79c6',
#        Name.Variable:          '#8be9fd',
#        Name.Variable.Class:    '#8be9fd',
#        Name.Variable.Global:   '#8be9fd',
#        Name.Variable.Instance: '#8be9fd',
#        Name.Variable.Magic:    '#8be9fd',

        # Generic
        Generic:                '$( $colors.accent )',
        Generic.Deleted:        '$( $colors.error )',
        Generic.Emph:          '$( $colors.faded )',
        Generic.Error:        '$( $colors.error )',
        Generic.Heading:        'bold $( $colors.warning )',
        Generic.Inserted:       '$( $colors.success )',
        Generic.Output:           '$( $colors.faded )',
        Generic.Prompt:         '$( $colors.info )',
        Generic.Strong:         'bold ' + '$( $colors.success )',
        Generic.Subheading:      '$( $colors.gradient)',
        Generic.Traceback:     '$( $colors.error )',

        }
)

material.MaterialStyle = PowerSyntaxStyle

# === ПОЛНАЯ ДЕМОНСТРАЦИЯ ===

console.print(Panel(f"[bold]🎨 Тема: ${Theme}.upper() 🎨[/bold]", style="panel.style"))

# 1. Код
console.print(Panel("[bold]Синтаксис кода[/bold]", style="panel.border"))
code = '''
def analyze_data(dataset):
    """Анализирует набор данных"""
    # Подсчитываем статистику
    total = len(dataset)
    average = sum(dataset) / total
    return {"total": total, "average": average}
'''
syntax = Syntax(code, 'python', theme=material.MaterialStyle, line_numbers=True)
console.print(syntax)

# 2. JSON
console.print(Panel("[panel.style]JSON структура[/]", style="panel.border"))
data = {"server": "production","active": True,"connections": 1250,"load": 0.85,"errors": None,"services": ["api", "web", "db"]}
json_obj = JSON.from_data(data)
console.print(json_obj)

api_data = {
        "status": "success",
        "data": {
            "users": [
                {"id": 1, "name": "John Doe", "email": "john@example.com", "active": True},
                {"id": 2, "name": "Jane Smith", "email": "jane@example.com", "active": False}
            ],
            "pagination": {
                "page": 1,
                "per_page": 10,
                "total": 25,
                "total_pages": 3
            }
        },
        "timestamp": "2024-01-15T14:30:00Z"
    }

    # Красивый JSON
json_obj = JSON.from_data(api_data)
console.print(Panel(json_obj, title="📡 API Response", style="panel.border"))

# 3. Таблица
console.print(Panel("[bold]Таблица метрик[/bold]"))
table = Table(title="Мониторинг системы")
table.add_column("Сервис", style="primary")
table.add_column("Статус", justify="center")
table.add_column("CPU", justify="right", style="accent")
table.add_column("RAM", justify="right", style="accent")

table.add_row("API", "[success]Работает[/success]", "[info]23%[/]", "[info]45%[/]")
table.add_row("Database", "[warning]Загружена[/warning]", "[warning]78%[/]", "[warning]89%[/]")
table.add_row("Cache", "[error]Ошибка[/error]", "[info]5%[/]", "[info]12%[/]")
console.print(table)

# 4. Дерево файлов
console.print(Panel("[bold]Структура проекта[/]", style="panel.border"))
tree = Tree("[bold]project[/bold]")
tree.add("src").add("[info]main.py[/]")
tree.add("tests").add("[info]test_main.py[/]")
tree.add("[secondary]README.md[/secondary]")
console.print(tree)

# 5. Прогресс-бар (симуляция)
console.print(Panel("[bold]Процесс загрузки[/bold]", style="panel.border"))
with Progress(
    TextColumn("[progress.description]{task.description}"),
    BarColumn(style="success", complete_style="primary"),
    TaskProgressColumn(style="info"),
    console=console
) as progress:
    task = progress.add_task("Загрузка данных...", total=100)
    for i in range(100):
        progress.update(task, advance=1)
        time.sleep(0.005)
# Сохраняем тему для повторного использования
with open('current_theme.json', 'w') as f:
   json.dump('$colors', f)

console.print(f"[primary] Тема '${Theme}' активирована![/primary]")
"@

python -c $themeScript
Write-Host "" -ForegroundColor Green
ggrad " 🎯 Тема $Theme установлена! ✨" -color1 $colors.primary  -color2 $colors.gradient  -justify start
spt $colors
}


Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))