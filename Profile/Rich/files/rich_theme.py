from rich.console import Console
from rich.theme import Theme
from rich.syntax import Syntax
from rich.text import Text
from rich.panel import Panel
from rich.color import Color
from pygments.lexer import RegexLexer
from pygments.token import Generic, Name, Comment, String, Number, Keyword, Text as PygmentsText
import re
import logging
from pythonjsonlogger.json import JsonFormatter

logger = logging.getLogger()
logger.setLevel(logging.INFO)

handler = logging.StreamHandler()
handler.setFormatter(JsonFormatter())

logger.addHandler(handler)

logger.info("Logging using pythonjsonlogger!", extra={"more_data": True})

# {"message": "Logging using pythonjsonlogger!", "more_data": true}
# ==================== ЕДИНАЯ ГРАДИЕНТНАЯ ТЕМА ====================

GRADIENT_THEME = Theme({
    # Основные цвета с градиентными оттенками
    'primary': 'bold #3498db',
    'primary.light': '#5dade2',
    'primary.dark': '#2980b9',
    
    'success': 'bold #2ecc71', 
    'success.light': '#58d68d',
    'success.dark': '#27ae60',
    
    'error': 'bold #e74c3c',
    'error.light': '#ec7063', 
    'error.dark': '#c0392b',
    
    'warning': 'bold #f39c12',
    'warning.light': '#f7dc6f',
    'warning.dark': '#e67e22',
    
    'accent': 'bold #9b59b6',
    'accent.light': '#bb8fce',
    'accent.dark': '#8e44ad',
    
    # Специальные градиентные стили
    'gradient.fire': '#ff4444',
    'gradient.ocean': '#44aaff', 
    'gradient.forest': '#44ff44',
    'gradient.sunset': '#ff8844',
    'gradient.aurora': '#aa44ff',
    
    # Логи с градиентными уровнями
    'log.critical': 'bold #ff0000 on #330000',
    'log.error': 'bold #ff4444',
    'log.warn': 'bold #ffaa44', 
    'log.info': 'bold #44aaff',
    'log.debug': 'dim #888888',
    'log.trace': 'dim #444444',
    
    # JSON с градиентом
    'json.key': 'bold #3498db',
    'json.string': '#2ecc71',
    'json.number': '#f39c12',
    'json.bool': 'bold #9b59b6',
    'json.null': 'italic #95a5a6',
})

# ==================== КАСТОМНЫЙ ЛЕКСЕР С ГРАДИЕНТАМИ ====================
class GradientLogLexer(RegexLexer):
    """Лексер для логов с поддержкой градиентной подсветки"""
    name = 'GradientLog'
    aliases = ['gradlog', 'glog']
    
    tokens = {
        'root': [
            # Критические ошибки - красный градиент
            (r'\b(CRITICAL|FATAL|PANIC)\b', Generic.Error),
            # Ошибки - красно-оранжевый градиент  
            (r'\b(ERROR|FAIL|FAILED)\b', Name.Exception),
            # Предупреждения - желто-оранжевый градиент
            (r'\b(WARN|WARNING|CAUTION)\b', Generic.Subheading),
            # Информация - сине-голубой градиент
            (r'\b(INFO|NOTICE)\b', Generic.Inserted),
            # Отладка - серый градиент
            (r'\b(DEBUG|TRACE|VERBOSE)\b', Comment.Single),
            # Успех - зелёный градиент
            (r'\b(SUCCESS|OK|PASS|PASSED|COMPLETE)\b', String.Symbol),
            
            # Временные метки - фиолетовый градиент
            (r'\d{4}-\d{2}-\d{2}[\sT]\d{2}:\d{2}:\d{2}(?:\.\d{3})?(?:Z|[+-]\d{2}:\d{2})?', Comment.Preproc),
            
            # JSON структуры - cyan градиент
            (r'\{[^}]*\}', String.Doc),
            (r'\[[^\]]*\]', String.Doc),
            
            # Строки - зелёный градиент
            (r'"[^"]*"|\'[^\']*\'', String.Double),
            
            # Числа - магента градиент
            (r'\b\d+\.\d+\b', Number.Float),
            (r'\b\d+\b', Number.Integer),
            
            # IP адреса - голубой градиент
            (r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b', Number.Hex),
            
            # URLs - синий градиент
            (r'https?://[^\s]+', String.Other),
            
            # HTTP статусы
            (r'\b[1-5]\d{2}\b', Keyword.Type),  # 200, 404, etc.
            
            # Размеры файлов
            (r'\b\d+\.?\d*\s*(KB|MB|GB|TB|B)\b', Number.Oct),
            
            # Процентное соотношение
            (r'\b\d+\.?\d*%\b', Number.Bin),
            
            # Остальное
            (r'\s+', Text),
            (r'.', Text),
        ]
    }

# ==================== ГЛОБАЛЬНАЯ КОНСОЛЬ ====================
console = Console(theme=GRADIENT_THEME, force_terminal=True, width=120)

# ==================== ФУНКЦИИ С ГРАДИЕНТАМИ ====================
def create_rainbow_text(text, colors=None):
    """Создает радужный градиент для текста"""
    if colors is None:
        colors = ["#ff0000", "#ff8800", "#ffff00", "#88ff00", "#00ff00", 
                 "#00ff88", "#00ffff", "#0088ff", "#0000ff", "#8800ff"]
    
    result = Text()
    color_count = len(colors)
    
    for i, char in enumerate(text):
        color_index = (i * color_count) // len(text)
        color_index = min(color_index, color_count - 1)
        result.append(char, style=colors[color_index])
    
    return result

def print_gradient_log(text):
    """Печать логов с градиентной подсветкой через кастомный лексер"""
    syntax = Syntax(
        text,
        lexer=GradientLogLexer(),
        theme="material",
        background_color="#1a1a1a",
        line_numbers=True
    )
    console.print(syntax)

def print_rainbow_title(title):
    """Печать заголовка с радужным градиентом"""
    rainbow_title = create_rainbow_text(title)
    console.print(Panel(rainbow_title, style="bold"))

def print_fire_gradient(text):
    """Огненный градиент: красный -> оранжевый -> желтый"""
    fire_colors = ["#ff0000", "#ff3300", "#ff6600", "#ff9900", "#ffcc00", "#ffff00"]
    fire_text = create_rainbow_text(text, fire_colors)
    console.print(fire_text)

def print_ocean_gradient(text):
    """Океанский градиент: темно-синий -> голубой -> белый"""
    ocean_colors = ["#000080", "#0033cc", "#0066ff", "#3399ff", "#66ccff", "#99ffff"]
    ocean_text = create_rainbow_text(text, ocean_colors)
    console.print(ocean_text)

def print_code_with_gradient_borders(code, language="python", line_numbers=True):
    """Код с градиентными границами"""
    syntax = Syntax(code, language, theme="material", line_numbers=True)
    
    # Создаем градиентный заголовок
    title = create_rainbow_text(f"✨ {language.upper()} CODE ✨")
    
    console.print(Panel(
        syntax, 
        title=title,
        border_style="bold magenta",
        padding=(1, 2)
    ))

# ==================== ПРОДВИНУТЫЙ ГРАДИЕНТНЫЙ ЛЕКСЕР ====================
def highlight_with_custom_gradients(text):
    """Сложная подсветка с множественными градиентами"""
    result = Text()
    
    # Паттерны для разных типов данных
    patterns = [
        (r'\b(CRITICAL|FATAL)\b', lambda m: create_rainbow_text(m.group(), ["#ff0000", "#cc0000"])),
        (r'\b(ERROR|FAIL)\b', lambda m: create_rainbow_text(m.group(), ["#ff4444", "#ff0000"])),
        (r'\b(WARN|WARNING)\b', lambda m: create_rainbow_text(m.group(), ["#ffff00", "#ff8800"])),
        (r'\b(INFO|NOTICE)\b', lambda m: create_rainbow_text(m.group(), ["#00aaff", "#cc001f"])),
        (r'\b(DEBUG|TRACE)\b', lambda m: create_rainbow_text(m.group(), ["#888888", "#444444"])),
        (r'\b(SUCCESS|OK|PASS)\b', lambda m: create_rainbow_text(m.group(), ["#00ff00", "#00cc00"])),
        (r'"[^"]*"', lambda m: create_rainbow_text(m.group(), ["#00ff88", "#00ccaa"])),
        (r'\b\d+\.?\d*\b', lambda m: create_rainbow_text(m.group(), ["#ff00ff", "#cc00cc"])),
    ]
    
    last_end = 0
    
    for pattern, gradient_func in patterns:
        for match in re.finditer(pattern, text):
            # Добавляем текст до совпадения
            if match.start() > last_end:
                result.append(text[last_end:match.start()])
            
            # Добавляем градиентный текст
            gradient_text = gradient_func(match)
            result.append_text(gradient_text)
            last_end = match.end()
    
    # Добавляем оставшийся текст
    if last_end < len(text):
        result.append(text[last_end:])
    
    return result

# ==================== ОСНОВНОЙ ИНТЕРФЕЙС ====================
def setup_gradient_console():
    """Настройка консоли с градиентами - вызвать один раз"""
    global console
    console = Console(theme=GRADIENT_THEME, force_terminal=True)
    
    # Печатаем красивый заголовок при инициализации
    title = create_rainbow_text("🌈 GRADIENT CONSOLE INITIALIZED 🌈")
    console.print(Panel(title, style="bold"))

def log(message, level="INFO", use_gradients=True):
    """Универсальная функция логирования с градиентами"""
    timestamp = "2024-01-15 10:30:45"  # В реальности datetime.now()
    log_line = f"{timestamp} {level}: {message}"
    
    if use_gradients:
        highlighted = highlight_with_custom_gradients(log_line)
        console.print(highlighted)
    else:
        console.print(log_line)

# ==================== ЭКСПОРТ ====================
# Инициализируем сразу
setup_gradient_console()

# Экспортируемые функции
__all__ = [
    'console', 'setup_gradient_console', 'log', 'print_gradient_log', 'print_rainbow_title',
    'print_fire_gradient', 'print_ocean_gradient', 'print_code_with_gradient_borders',
    'create_rainbow_text', 'highlight_with_custom_gradients'
]

# ==================== ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ ====================
if __name__ == "__main__":
    # Демонстрация всех возможностей
    
    print_rainbow_title("GRADIENT LOGGING SYSTEM")
    
    # Разные типы логов
    log("Application started successfully", "SUCCESS")
    log("Loading configuration from config.json", "INFO") 
    log("Memory usage is getting high: 89.5%", "WARN")
    log("Database connection failed after 30.2 seconds", "ERROR")
    log("Trace: function_call() -> return_value", "DEBUG")
    
    # Градиентные эффекты
    print_fire_gradient("🔥 FIRE GRADIENT TEXT 🔥")
    print_ocean_gradient("🌊 OCEAN GRADIENT TEXT 🌊")
    
    # Код с градиентными границами
    sample_code = '''
def process_data(items):
    results = []
    for item in items:
        if item.is_valid():
            results.append(item.process())
    return results
'''
    
    print_code_with_gradient_borders(sample_code, "python")
    
    # Сложный лог с множественными градиентами
    complex_log = '''
2024-01-15 10:30:45 INFO: Processing "user_data.json" with 1250 records
2024-01-15 10:30:46 DEBUG: Memory usage: 85.7 MB, CPU: 45%
2024-01-15 10:30:47 ERROR: Connection to 192.168.1.100 failed
2024-01-15 10:30:48 SUCCESS: Backup completed in 12.5 seconds
2024-01-15 10:30:49 WARN: Cache hit ratio dropped to 67%
'''
    
    console.print("\n" + "="*60)
    console.print("Complex log with multiple gradients:", style="bold")
    console.print("="*60)
    
    highlighted_complex = highlight_with_custom_gradients(complex_log)
    console.print(highlighted_complex)