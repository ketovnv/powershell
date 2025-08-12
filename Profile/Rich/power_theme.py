"""Power Theme for Rich and Pygments - standalone theme without dependencies"""

from rich.console import Console
from rich.theme import Theme
from pygments.style import Style
from pygments.token import *
import os

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
POWER_THEME = Theme({
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
    'json.str': COLORS['accent'],
    'json.number': COLORS['secondary'],
    'json.bool_true': f"bold {COLORS['success']}",
    'json.bool_false': f"bold {COLORS['warning']}",
    'json.null': f"italic {COLORS['comment']}",

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
    'panel.border.style': f"bold {COLORS['info']}",
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


# Pygments Style - полностью независимый
class PowerStyle(Style):
    """Кастомный стиль для подсветки синтаксиса"""

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


# Глобальная консоль с кастомной темой
_console = None


def get_console():
    """Get or create the global console with Power theme"""
    global _console
    if _console is None:
        _console = Console(
            theme=POWER_THEME,
            force_terminal=True,
            force_interactive=True,
            width=120,
            legacy_windows=False,
            safe_box=True,
            tab_size=4,
            record=True,  # Для сохранения вывода
            markup=True,
            emoji=True,
            highlight=True,
            log_time=True,
            log_path=True,
        )
    return _console


# Автоматическая инициализация при импорте
def init_power_theme():
    """Initialize Power theme globally"""
    import sys
    import os

    # Устанавливаем переменные окружения для цветов
    os.environ['PYTHONIOENCODING'] = 'utf-8'
    os.environ['FORCE_COLOR'] = '1'

    # Для Windows - включаем ANSI colors
    if sys.platform == 'win32':
        os.system('')  # Включает ANSI escape sequences

    # Регистрируем стиль в Pygments
    from pygments.styles import STYLE_MAP
    STYLE_MAP['power'] = 'power_theme:PowerStyle'

    # Настраиваем Rich глобально
    from rich import reconfigure
    reconfigure(
        theme=POWER_THEME,
        force_terminal=True,
        width=120,
        legacy_windows=False,
        safe_box=True,
        tab_size=4,
        record=True,
        markup=True,
        emoji=True,
        highlight=True,
        log_time=True,
        log_path=True,
    )

    return get_console()


# Удобные алиасы
console = init_power_theme()
print = console.print
log = console.log