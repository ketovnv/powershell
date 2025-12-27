"""
Кастомный стиль Pygments с интеграцией Rich темы
Создает полностью свой стиль без зависимости от material или других стилей
"""

from pygments.style import Style
from pygments.token import *
from rich import reconfigure
from rich.theme import Theme
from rich.console import Console
from rich.syntax import Syntax

# ==================== ЦВЕТОВАЯ ПАЛИТРА ====================
class ColorPalette:
    """Единая цветовая палитра для Rich и Pygments"""
    
    # Основные цвета
    background = "#1a1a1a"
    foreground = "#ffffff"
    
    # Акцентные цвета
    primary = "#3498db"      # Синий
    secondary = "#95a5a6"    # Серый
    accent = "#9b59b6"       # Фиолетовый
    success = "#2ecc71"      # Зелёный
    warning = "#f39c12"      # Оранжевый
    error = "#e74c3c"        # Красный
    info = "#17a2b8"         # Голубой
    
    # Градации
    primary_light = "#5dade2"
    primary_dark = "#2980b9"
    success_light = "#58d68d"
    success_dark = "#27ae60"
    error_light = "#ec7063"
    error_dark = "#c0392b"
    warning_light = "#f7dc6f"
    warning_dark = "#e67e22"
    
    # Дополнительные
    comment = "#7f8c8d"
    string = "#2ecc71"
    number = "#f39c12"
    keyword = "#9b59b6"
    operator = "#3498db"
    function = "#e67e22"
    class_name = "#e74c3c"
    variable = "#17a2b8"
    
    # Специальные
    selection = "#34495e"
    line_number = "#7f8c8d"
    current_line = "#2c3e50"

# ==================== КАСТОМНЫЙ PYGMENTS СТИЛЬ ====================

class PowerShellStyle(Style):
    """
    Кастомный стиль Pygments, оптимизированный для PowerShell и Rich
    Полностью независимый, не требует material или других стилей
    """
    
    name = 'powershell-custom'
    
    # Цвета фона и переднего плана
    background_color = ColorPalette.background
    highlight_color = ColorPalette.selection
    line_number_color = ColorPalette.line_number
    line_number_background_color = ColorPalette.background
    line_number_special_color = ColorPalette.primary
    line_number_special_background_color = ColorPalette.current_line
    
    styles = {
        # Базовые токены
        Token:                     ColorPalette.foreground,
        Text:                      ColorPalette.foreground,
        Whitespace:                ColorPalette.foreground,
        Error:                     f'bg:{ColorPalette.error} {ColorPalette.foreground}',
        Other:                     ColorPalette.foreground,
        
        # Комментарии
        Comment:                   f'italic {ColorPalette.comment}',
        Comment.Hashbang:          f'italic {ColorPalette.comment}',
        Comment.Multiline:         f'italic {ColorPalette.comment}',
        Comment.Preproc:           f'bold {ColorPalette.info}',
        Comment.PreprocFile:       f'{ColorPalette.string}',
        Comment.Single:            f'italic {ColorPalette.comment}',
        Comment.Special:           f'italic bold {ColorPalette.warning}',
        
        # Ключевые слова
        Keyword:                   f'bold {ColorPalette.keyword}',
        Keyword.Constant:          f'bold {ColorPalette.error}',
        Keyword.Declaration:       f'bold {ColorPalette.keyword}',
        Keyword.Namespace:         f'bold {ColorPalette.accent}',
        Keyword.Pseudo:            f'bold {ColorPalette.keyword}',
        Keyword.Reserved:          f'bold {ColorPalette.keyword}',
        Keyword.Type:              f'bold {ColorPalette.primary}',
        
        # Имена
        Name:                      ColorPalette.foreground,
        Name.Attribute:            ColorPalette.primary,
        Name.Builtin:              f'bold {ColorPalette.function}',
        Name.Builtin.Pseudo:       f'bold {ColorPalette.function}',
        Name.Class:                f'bold {ColorPalette.class_name}',
        Name.Constant:             f'bold {ColorPalette.error}',
        Name.Decorator:            f'bold {ColorPalette.accent}',
        Name.Entity:               f'bold {ColorPalette.function}',
        Name.Exception:            f'bold {ColorPalette.error}',
        Name.Function:             f'bold {ColorPalette.function}',
        Name.Function.Magic:       f'bold {ColorPalette.accent}',
        Name.Property:             ColorPalette.primary,
        Name.Label:                f'italic {ColorPalette.comment}',
        Name.Namespace:            f'underline {ColorPalette.function}',
        Name.Other:                ColorPalette.foreground,
        Name.Tag:                  f'bold {ColorPalette.class_name}',
        Name.Variable:             ColorPalette.variable,
        Name.Variable.Class:       ColorPalette.variable,
        Name.Variable.Global:      f'bold {ColorPalette.variable}',
        Name.Variable.Instance:    ColorPalette.variable,
        Name.Variable.Magic:       f'bold {ColorPalette.accent}',
        
        # Литералы
        Literal:                   ColorPalette.number,
        Literal.Date:              ColorPalette.string,
        
        # Строки
        String:                    ColorPalette.string,
        String.Affix:              f'bold {ColorPalette.string}',
        String.Backtick:           ColorPalette.string,
        String.Char:               ColorPalette.string,
        String.Delimiter:          ColorPalette.string,
        String.Doc:                f'italic {ColorPalette.string}',
        String.Double:             ColorPalette.string,
        String.Escape:             f'bold {ColorPalette.error}',
        String.Heredoc:            ColorPalette.string,
        String.Interpol:           f'bold {ColorPalette.primary}',
        String.Other:              ColorPalette.string,
        String.Regex:              f'bold {ColorPalette.warning}',
        String.Single:             ColorPalette.string,
        String.Symbol:             ColorPalette.string,
        
        # Числа
        Number:                    ColorPalette.number,
        Number.Bin:                ColorPalette.number,
        Number.Float:              ColorPalette.number,
        Number.Hex:                ColorPalette.number,
        Number.Integer:            ColorPalette.number,
        Number.Integer.Long:       ColorPalette.number,
        Number.Oct:                ColorPalette.number,
        
        # Операторы
        Operator:                  ColorPalette.operator,
        Operator.Word:             f'bold {ColorPalette.keyword}',
        
        # Пунктуация
        Punctuation:               ColorPalette.secondary,
        
        # Общие категории
        Generic:                   ColorPalette.foreground,
        Generic.Deleted:           f'bg:{ColorPalette.error_dark} {ColorPalette.foreground}',
        Generic.Emph:              f'italic {ColorPalette.foreground}',
        Generic.Error:             f'bold {ColorPalette.error}',
        Generic.Heading:           f'bold {ColorPalette.primary}',
        Generic.Inserted:          f'bg:{ColorPalette.success_dark} {ColorPalette.foreground}',
        Generic.Output:            ColorPalette.secondary,
        Generic.Prompt:            f'bold {ColorPalette.primary}',
        Generic.Strong:            f'bold {ColorPalette.foreground}',
        Generic.Subheading:        f'bold {ColorPalette.function}',
        Generic.Traceback:         f'bold {ColorPalette.error}',
        
        # PowerShell специфичные токены (если доступны)
        'Token.Name.Builtin.Cmdlet': f'bold {ColorPalette.function}',
        'Token.Name.Variable.PowerShell': f'bold {ColorPalette.variable}',
        'Token.Operator.PowerShell': ColorPalette.operator,
    }

# ==================== RICH ТЕМА (СИНХРОНИЗИРОВАННАЯ) ====================

SYNCHRONIZED_RICH_THEME = Theme({
    # Основные стили (используем ту же палитру)
    'primary': f'bold {ColorPalette.primary}',
    'secondary': ColorPalette.secondary,
    'accent': ColorPalette.accent,
    'success': f'bold {ColorPalette.success}',
    'warning': f'bold {ColorPalette.warning}',
    'error': f'bold {ColorPalette.error}',
    'info': f'bold {ColorPalette.info}',
    'muted': f'dim {ColorPalette.comment}',
    
    # JSON (синхронизировано с Pygments)
    'json.key': f'bold {ColorPalette.primary}',
    'json.string': ColorPalette.string,
    'json.number': ColorPalette.number,
    'json.bool_true': f'bold {ColorPalette.success}',
    'json.bool_false': f'bold {ColorPalette.error}',
    'json.null': f'italic {ColorPalette.comment}',
    
    # Repr стили (синхронизировано)
    'repr.number': ColorPalette.number,
    'repr.str': ColorPalette.string,
    'repr.bool_true': f'bold {ColorPalette.success}',
    'repr.bool_false': f'bold {ColorPalette.error}',
    'repr.none': f'italic {ColorPalette.comment}',
    'repr.call': f'bold {ColorPalette.function}',
    'repr.attrib_name': ColorPalette.primary,
    'repr.attrib_value': ColorPalette.string,
    
    # Прогресс и интерфейс
    'progress.description': ColorPalette.secondary,
    'progress.percentage': f'bold {ColorPalette.primary}',
    'progress.data.speed': ColorPalette.number,
    
    # Таблицы
    'table.header': f'bold {ColorPalette.primary}',
    'table.border': ColorPalette.secondary,
    
    # Панели
    'panel.border': ColorPalette.primary,
    'panel.title': f'bold {ColorPalette.primary}',
    
    # Логирование
    'log.error': f'bold {ColorPalette.error}',
    'log.warn': f'bold {ColorPalette.warning}',
    'log.info': f'bold {ColorPalette.info}',
    'log.debug': f'dim {ColorPalette.comment}',
    'log.success': f'bold {ColorPalette.success}',
    'log.timestamp': f'dim {ColorPalette.comment}',
    
    # Синтаксис (дублируем из Pygments для консистентности)
    'syntax.comment': f'italic {ColorPalette.comment}',
    'syntax.keyword': f'bold {ColorPalette.keyword}',
    'syntax.string': ColorPalette.string,
    'syntax.number': ColorPalette.number,
    'syntax.name.function': f'bold {ColorPalette.function}',
    'syntax.name.class': f'bold {ColorPalette.class_name}',
    'syntax.operator': ColorPalette.operator,
})

# ==================== РЕГИСТРАЦИЯ И НАСТРОЙКА ====================

def register_custom_style():
    """Регистрирует кастомный стиль в Pygments"""
    from pygments.styles import get_all_styles
    from pygments import styles
    
    # Регистрируем наш стиль
    styles.STYLE_MAP['powershell-custom'] = f'{__name__}::PowerShellStyle'
    
    print("✅ Кастомный стиль Pygments зарегистрирован: 'powershell-custom'")

def setup_unified_theme():
    """
    Настраивает единую тему для Rich и Pygments
    Использует reconfigure для глобальной настройки Rich
    """
    # Регистрируем кастомный стиль Pygments
    register_custom_style()
    
    # Настраиваем Rich глобально
    reconfigure(
        theme=SYNCHRONIZED_RICH_THEME,
        force_terminal=True,
        width=120,
        legacy_windows=False,
    )
    
    print("🎨 Единая тема настроена! Rich и Pygments синхронизированы.")

# ==================== УДОБНЫЕ ФУНКЦИИ ====================

def print_code(code, language="python", line_numbers=True, title=None):
    """Печать кода с нашим кастомным стилем"""
    syntax = Syntax(
        code,
        language,
        theme="powershell-custom",  # Используем наш стиль!
        background_color=ColorPalette.background,
        line_numbers=line_numbers,
    )
    
    console = Console()  # Автоматически с нашей Rich темой
    
    if title:
        from rich.panel import Panel
        console.print(Panel(syntax, title=f"[panel.title]{title}[/panel.title]"))
    else:
        console.print(syntax)

def print_powershell_code(code, title="PowerShell Script"):
    """Специально для PowerShell кода"""
    print_code(code, "powershell", title=title)

def show_color_palette():
    """Демонстрация цветовой палитры"""
    from rich.table import Table
    from rich.panel import Panel
    
    console = Console()
    
    # Таблица с цветами
    table = Table(title="Цветовая палитра", show_header=True)
    table.add_column("Цвет", style="primary")
    table.add_column("Hex", style="secondary")
    table.add_column("Пример", style="accent")
    
    colors = {
        "Primary": (ColorPalette.primary, "primary"),
        "Success": (ColorPalette.success, "success"),
        "Warning": (ColorPalette.warning, "warning"),
        "Error": (ColorPalette.error, "error"),
        "Info": (ColorPalette.info, "info"),
        "Comment": (ColorPalette.comment, "muted"),
        "String": (ColorPalette.string, "json.string"),
        "Number": (ColorPalette.number, "json.number"),
        "Keyword": (ColorPalette.keyword, "accent"),
        "Function": (ColorPalette.function, "repr.call"),
    }
    
    for name, (hex_color, style) in colors.items():
        table.add_row(name, hex_color, f"[{style}]Пример текста[/{style}]")
    
    console.print(table)

def demo_unified_theme():
    """Демонстрация единой темы Rich + Pygments"""
    from rich import print
    from rich.panel import Panel
    
    console = Console()
    
    console.print(Panel("🚀 [panel.title]ДЕМОНСТРАЦИЯ ЕДИНОЙ ТЕМЫ[/panel.title] 🚀"))
    
    # Rich стили
    print("\n[bold]Rich стили:[/bold]")
    print("  [success]✅ Успешное выполнение[/success]")
    print("  [error]❌ Ошибка выполнения[/error]") 
    print("  [warning]⚠️  Предупреждение[/warning]")
    print("  [info]ℹ️  Информационное сообщение[/info]")
    
    # Python код с нашим стилем
    print("\n[bold]Python код (кастомный стиль):[/bold]")
    python_code = '''
def process_data(items: list, debug: bool = False) -> dict:
    """Обрабатывает список элементов"""
    result = {"processed": 0, "errors": 0}
    
    for item in items:
        try:
            # Обработка элемента
            if item.is_valid():
                item.process()
                result["processed"] += 1
            else:
                raise ValueError("Invalid item")
        except Exception as e:
            if debug:
                print(f"Error: {e}")
            result["errors"] += 1
    
    return result

# Использование
data = [Item("test"), Item("example")]
result = process_data(data, debug=True)
'''
    print_code(python_code, "python")
    
    # PowerShell код
    print("\n[bold]PowerShell код (кастомный стиль):[/bold]")
    powershell_code = '''
# PowerShell script example
function Get-ProcessInfo {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ProcessName,
        [switch]$Detailed
    )
    
    $processes = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    
    if ($processes) {
        foreach ($proc in $processes) {
            $info = @{
                Name = $proc.Name
                Id = $proc.Id
                CPU = $proc.CPU
                WorkingSet = [math]::Round($proc.WorkingSet / 1MB, 2)
            }
            
            if ($Detailed) {
                $info.StartTime = $proc.StartTime
                $info.Path = $proc.Path
            }
            
            Write-Output $info
        }
    } else {
        Write-Warning "Process '$ProcessName' not found"
    }
}

# Usage
Get-ProcessInfo -ProcessName "notepad" -Detailed
'''
    print_powershell_code(powershell_code)
    
    # JSON данные
    print("\n[bold]JSON данные (Rich стили):[/bold]")
    print({
        "status": "success",
        "data": {
            "processed": 150,
            "errors": 0,
            "time": 1.25,
            "active": True,
            "cache": None
        }
    })

# ==================== АВТОИНИЦИАЛИЗАЦИЯ ====================

# Автоматически настраиваем при импорте
setup_unified_theme()

# Экспорт
__all__ = [
    'PowerShellStyle', 'ColorPalette', 'SYNCHRONIZED_RICH_THEME',
    'setup_unified_theme', 'print_code', 'print_powershell_code',
    'show_color_palette', 'demo_unified_theme'
]

# ==================== ПРИМЕР ИСПОЛЬЗОВАНИЯ ====================

if __name__ == "__main__":
    # Демонстрация всех возможностей
    demo_unified_theme()
    
    print("\n" + "="*60)
    show_color_palette()
    print("="*60)
    
    # Проверка, что обычные Rich функции работают с нашей темой
    from rich import print
    print("\n✅ [success]Всё настроено! Rich и Pygments используют единую тему.[/success]")
    print("🎨 [accent]Кастомный стиль доступен как 'powershell-custom'[/accent]")
    print("🔧 [info]Используйте print_code() для кода с кастомным стилем[/info]")
