"""Power Theme for Rich and Pygments - standalone theme without dependencies"""

import os
import sys
from rich.console import Console
from rich.theme import Theme

# Принудительно устанавливаем UTF-8 для Windows
if sys.platform == 'win32':
    import subprocess
    try:
        subprocess.run(['chcp', '65001'], shell=True, capture_output=True)
    except:
        pass
    os.environ['PYTHONIOENCODING'] = 'utf-8'
    os.environ['PYTHONUTF8'] = '1'



# Цветовая палитра
COLORS = {
    'primary': '#F1F2AB',
    'background': '#030608',
    'gradient': '#CCC570',
    'secondary': '#ffffff',
    'accent': '#B277BF',
    'secondary_accent': '#9247FF',
    'info': '#8FBBDF',
    'comment': '#555555',
    'faded': '#151819',
    'highlight': '#FFFF00',
    'success': '#05AF35',
    'warning': '#FFBD55',
    'error': '#FF0000',
    'subtle': '#404040',
}

# Rich Theme определение
POWER_RICH_THEME = Theme({
    # Основные стили
    'default': COLORS['primary'],
    'bold': f"bold {COLORS['primary']}",
    'italic': f"italic {COLORS['info']}",
    'underline': f"underline {COLORS['accent']}",

    # Уровни логирования
    'logging.level.debug': f"dim {COLORS['comment']}",
    'logging.level.info': COLORS['info'],
    'logging.level.warning': f"bold {COLORS['warning']}",
    'logging.level.error': f"bold {COLORS['error']}",
    'logging.level.critical': f"bold reverse {COLORS['error']}",

    # JSON стили
    'json.brace': COLORS['secondary'],
    'json.bracket': COLORS['secondary'],
    'json.comma': COLORS['secondary'],
    'json.colon': COLORS['secondary'],
    'json.key': f"bold {COLORS['primary']}",
    'json.str': COLORS['info'],
    'json.number': COLORS['secondary'],
    'json.bool_true': f"bold {COLORS['success']}",
    'json.bool_false': f"bold {COLORS['error']}",
    'json.null': f"italic {COLORS['accent']}",

    # Таблицы
    'table.header': f"bold {COLORS['secondary_accent']}",
    'table.footer': f"bold {COLORS['info']}",
    'table.cell': COLORS['primary'],
    'table.border': COLORS['faded'],
    'table.title': f"bold {COLORS['accent']}",
    'table.caption': f"italic {COLORS['info']}",

    # Панели
    'panel.title': f"bold {COLORS['accent']}",
    'panel.border': f"{COLORS['primary']} on {COLORS['background']}",
    'panel.style': f"bold {COLORS['info']}",
    'panel.subtitle': f"italic {COLORS['info']}",

    # Деревья
    'tree': COLORS['primary'],
    'tree.line': COLORS['secondary'],
    'tree.guide': COLORS['comment'],

    # Progress bars
    'progress.description': COLORS['info'],
    'progress.percentage': f"bold {COLORS['accent']}",
    'progress.bar.complete': f"{COLORS['success']} on {COLORS['faded']}",
    'progress.bar.incomplete': COLORS['faded'],
    'progress.bar.pulse': COLORS['warning'],

    # Статусы
    'status.spinner': COLORS['accent'],
    'status.text': COLORS['info'],

    # Rule (разделители)
    'rule.line': COLORS['comment'],
    'rule.text': f"bold {COLORS['primary']}",

    # Markdown
    'markdown.h1': f"bold {COLORS['accent']}",
    'markdown.h2': f"bold {COLORS['secondary_accent']}",
    'markdown.h3': f"bold {COLORS['info']}",
    'markdown.bold': f"bold {COLORS['primary']}",
    'markdown.italic': f"italic {COLORS['info']}",
    'markdown.code': COLORS['success'],
    'markdown.code_block': f"{COLORS['success']} on {COLORS['faded']}",
    'markdown.link': f"underline {COLORS['info']}",

    # Специальные
    'repr.number': COLORS['secondary'],
    'repr.str': COLORS['success'],
    'repr.bool_true': COLORS['success'],
    'repr.bool_false': COLORS['warning'],
    'repr.none': COLORS['comment'],
    'repr.url': f"underline {COLORS['info']}",
    'repr.path': f"bold {COLORS['gradient']}",

    # Промпты
    'prompt': f"bold {COLORS['accent']}",
    'prompt.choices': COLORS['info'],
    'prompt.default': f"dim {COLORS['comment']}",

    # Кастомные стили для ваших задач
    'success': f"bold {COLORS['success']}",
    'warning': f"bold {COLORS['warning']}",
    'error': f"bold {COLORS['error']}",
    'info': COLORS['info'],
    'debug': f"dim {COLORS['comment']}",
    'network': f"bold {COLORS['gradient']}",
    'web3': f"bold {COLORS['accent']}",
})

from pygments.style import Style
from pygments.token import *
# Pygments Style - полностью независимый
class PowerStyle(Style):
    """Кастомный стиль для подсветки синтаксиса"""
    # ВАЖНО: добавляем aliases для стиля
    aliases = ['power', 'powerstyle']

    name = 'power'
    background_color = COLORS['background']
    highlight_color = COLORS['highlight']
    line_number_color = COLORS['info']
    line_number_background_color = COLORS['faded']
    line_number_special_color = COLORS['accent']
    line_number_special_background_color = COLORS['comment']

    styles = {
        # Базовые токены
        Token: COLORS['primary'],
        Text: COLORS['primary'],
        Whitespace: '',
        Error: f"border:{COLORS['error']}",
        Other: COLORS['accent'],

        # Комментарии
        Comment: f"italic {COLORS['comment']}",
        Comment.Hashbang: f"bold {COLORS['comment']}",
        Comment.Multiline: f"italic {COLORS['comment']}",
        Comment.Preproc: f"bold {COLORS['warning']}",
        Comment.PreprocFile: COLORS['info'],
        Comment.Single: f"italic {COLORS['comment']}",
        Comment.Special: f"bold italic {COLORS['warning']}",

        # Ключевые слова
        Keyword: f"bold {COLORS['secondary_accent']}",
        Keyword.Constant: COLORS['secondary_accent'],
        Keyword.Declaration: f"bold {COLORS['secondary_accent']}",
        Keyword.Namespace: COLORS['secondary_accent'],
        Keyword.Pseudo: COLORS['secondary_accent'],
        Keyword.Reserved: f"bold {COLORS['secondary_accent']}",
        Keyword.Type: COLORS['gradient'],

        # Имена
        Name: COLORS['primary'],
        Name.Attribute: COLORS['gradient'],
        Name.Builtin: COLORS['info'],
        Name.Builtin.Pseudo: COLORS['info'],
        Name.Class: f"bold {COLORS['gradient']}",
        Name.Constant: COLORS['accent'],
        Name.Decorator: f"bold {COLORS['warning']}",
        Name.Entity: COLORS['gradient'],
        Name.Exception: f"bold {COLORS['error']}",
        Name.Function: f"bold {COLORS['gradient']}",
        Name.Function.Magic: f"bold {COLORS['accent']}",
        Name.Label: COLORS['info'],
        Name.Namespace: COLORS['primary'],
        Name.Other: COLORS['primary'],
        Name.Property: COLORS['gradient'],
        Name.Tag: COLORS['secondary_accent'],
        Name.Variable: COLORS['info'],
        Name.Variable.Class: COLORS['info'],
        Name.Variable.Global: f"bold {COLORS['info']}",
        Name.Variable.Instance: COLORS['info'],
        Name.Variable.Magic: f"bold {COLORS['accent']}",

        # Литералы
        Literal: COLORS['success'],
        Literal.Date: COLORS['success'],

        # Строки
        String: COLORS['success'],
        String.Affix: COLORS['success'],
        String.Backtick: COLORS['success'],
        String.Char: COLORS['success'],
        String.Delimiter: COLORS['secondary'],
        String.Doc: f"italic {COLORS['success']}",
        String.Double: COLORS['success'],
        String.Escape: COLORS['warning'],
        String.Heredoc: COLORS['success'],
        String.Interpol: COLORS['warning'],
        String.Other: COLORS['success'],
        String.Regex: COLORS['warning'],
        String.Single: COLORS['success'],
        String.Symbol: f"bold {COLORS['info']}",

        # Числа
        Number: COLORS['secondary'],
        Number.Bin: COLORS['gradient'],
        Number.Float: COLORS['secondary'],
        Number.Hex: COLORS['gradient'],
        Number.Integer: COLORS['secondary'],
        Number.Integer.Long: COLORS['secondary'],
        Number.Oct: COLORS['gradient'],

        # Операторы
        Operator: COLORS['warning'],
        Operator.Word: f"bold {COLORS['secondary_accent']}",

        # Пунктуация
        Punctuation: COLORS['info'],

        # Generic
        Generic: COLORS['primary'],
        Generic.Deleted: f"bg:{COLORS['error']} {COLORS['primary']}",
        Generic.Emph: 'italic',
        Generic.Error: COLORS['error'],
        Generic.Heading: f"bold {COLORS['accent']}",
        Generic.Inserted: f"bg:{COLORS['success']} {COLORS['primary']}",
        Generic.Output: COLORS['faded'],
        Generic.Prompt: f"bold {COLORS['info']}",
        Generic.Strong: 'bold',
        Generic.Subheading: f"bold {COLORS['gradient']}",
        Generic.Traceback: COLORS['error'],
        Generic.Underline: 'underline',
    }

def register_power_style():
    """Принудительно регистрирует Power Style в Pygments"""
    try:
        from pygments.styles import STYLE_MAP

        current_module = __name__
        STYLE_MAP['power'] = f'{current_module}:PowerStyle'
        STYLE_MAP['powerstyle'] = f'{current_module}:PowerStyle'

        print(f"[Power Style] Registered as: {current_module}:PowerStyle")

        from pygments.styles import get_style_by_name
        style = get_style_by_name('power')
        print(f"[Power Style] Test load successful: {style}")

        return True

    except Exception as e:
        print(f"[Power Style] Registration failed: {e}")
        return False

# СОЗДАЕМ ГЛОБАЛЬНУЮ КОНСОЛЬ
console = Console(
    theme=POWER_RICH_THEME,
    force_terminal=True,
    legacy_windows=False
)

def get_console():
    """Возвращает настроенную Rich консоль"""
    global console
    return console

def init_power_theme():
    """Initialize Power theme globally"""
    os.environ['PYTHONIOENCODING'] = 'utf-8'
    os.environ['FORCE_COLOR'] = '1'
    os.environ['PYTHONUTF8'] = '1'

    register_power_style()
    return get_console()

# Автоматически регистрируем при импорте
register_power_style()

# Экспортируемые символы
__all__ = ['console', 'get_console', 'register_power_style', 'PowerStyle', 'POWER_RICH_THEME', 'init_power_theme']

# Проверяем, что все функции существуют
print(f"[Debug] Available functions: {__all__}")
