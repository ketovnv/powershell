# !/usr/bin/env python3
"""
Python Rich Emoji Handler - аналог PowerShell функций для работы с эмоджи
Требует: pip install rich
"""

import sys
from typing import List, Dict, Tuple, Union, Optional, Any
from dataclasses import dataclass
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.columns import Columns
from rich.text import Text
from rich.progress import track
import unicodedata

# Инициализация Rich console
console = Console()


@dataclass
class EmojiResult:
    """Класс для хранения результата обработки эмоджи"""
    unicode: str
    code_point: Optional[int]
    emoji: str
    status: str
    type: str
    is_supported: bool
    category: str


class EmojiHandler:
    """Основной класс для работы с эмоджи в Python Rich"""

    def __init__(self):
        self.emoji_ranges = {
            (0x1F600, 0x1F64F): "Emoticons (лица)",
            (0x1F300, 0x1F5FF): "Misc Symbols (разное)",
            (0x1F680, 0x1F6FF): "Transport (транспорт)",
            (0x1F700, 0x1F77F): "Alchemical Symbols",
            (0x1F780, 0x1F7FF): "Geometric Shapes Extended",
            (0x1F800, 0x1F8FF): "Supplemental Arrows-C",
            (0x1F900, 0x1F9FF): "Supplemental Symbols (доп.символы)",
            (0x1FA00, 0x1FA6F): "Chess Symbols",
            (0x1FA70, 0x1FAFF): "Symbols and Pictographs Extended-A",
            (0x2600, 0x26FF): "Miscellaneous Symbols",
            (0x2700, 0x27BF): "Dingbats",
            (0x1F1E6, 0x1F1FF): "Regional Indicators (флаги)"
        }

    def get_emoji_category(self, code_point: int) -> str:
        """Определяет категорию эмоджи по code point"""
        for (start, end), category in self.emoji_ranges.items():
            if start <= code_point <= end:
                return category
        return "Unknown"

    def test_emoji_support(self, emoji: str, code_point: int) -> bool:
        """Проверяет поддержку эмоджи (улучшенная версия)"""
        if not emoji or emoji in ["�", "?", ""]:
            return False

        try:
            # Проверка кодирования UTF-8
            byte_length = len(emoji.encode('utf-8'))

            # Если символ кодируется одним байтом, но code point больше ASCII
            if byte_length == 1 and code_point > 0x7F:
                return False

            # Для эмоджи диапазонов - более мягкая проверка
            if code_point >= 0x1F000:
                return emoji not in ["�", "?","🛛"]

            # Проверка через unicodedata
            try:
                name = unicodedata.name(emoji, None)
                return name is not None
            except (ValueError, TypeError):
                return True  # Если не можем получить имя, считаем поддерживаемым

        except Exception:
            return False

        return True

    def convert_single_emoji(self, code_point: int, unicode_str: str = None) -> EmojiResult:
        """Конвертирует один code point в эмоджи"""
        if unicode_str is None:
            unicode_str = f"0x{code_point:X}"

        try:
            # Проверка валидности code point
            if code_point < 0 or code_point > 0x10FFFF:
                raise ValueError("Code point вне допустимого диапазона Unicode")

            if 0xD800 <= code_point <= 0xDFFF:
                raise ValueError("Code point в диапазоне суррогатных пар")

            emoji = chr(code_point)
            category = self.get_emoji_category(code_point)
            is_supported = self.test_emoji_support(emoji, code_point)

            return EmojiResult(
                unicode=unicode_str,
                code_point=code_point,
                emoji=emoji,
                status="Поддерживается" if is_supported else "Может не отображаться",
                type="Emoji",
                is_supported=is_supported,
                category=category
            )

        except Exception as e:
            return EmojiResult(
                unicode=unicode_str,
                code_point=code_point,
                emoji="❌",
                status=f"Ошибка: {str(e)}",
                type="Error",
                is_supported=False,
                category="Error"
            )

    def convert_emoji_range(self, start_code: int, end_code: int,
                            max_samples: int = 1000, show_all: bool = True) -> List[EmojiResult]:
        """Обрабатывает диапазон эмоджи"""
        results = []
        total_in_range = end_code - start_code + 1

        console.print(f"  Обрабатывается диапазон: {total_in_range} символов", style="dim")

        if show_all or total_in_range <= max_samples:
            # Показываем все символы
            for code in track(range(start_code, end_code + 1),
                              description="Обработка диапазона..."):
                results.append(self.convert_single_emoji(code))
        else:
            # Показываем только образцы
            step = max(1, total_in_range // max_samples)

            for i in range(max_samples):
                code = start_code + (i * step)
                if code <= end_code:
                    results.append(self.convert_single_emoji(code))

            # Добавляем информацию о диапазоне
            results.append(EmojiResult(
                unicode="Range Info",
                code_point=None,
                emoji="...",
                status=f"Показано {len([r for r in results if r.type == 'Emoji'])} из {total_in_range} символов диапазона",
                type="RangeInfo",
                is_supported=None,
                category="Info"
            ))

        return results

    def convert_emoji_array(self, items: List[Union[str, int, Tuple[int, int]]]) -> List[EmojiResult]:
        """Обрабатывает массив различных типов данных"""
        results = []

        for item in items:
            if isinstance(item, tuple) and len(item) == 2:
                # Диапазон
                start, end = item
                console.print(f"Обнаружен диапазон: 0x{start:X} - 0x{end:X}", style="yellow")
                range_results = self.convert_emoji_range(start, end)
                results.extend(range_results)

            elif isinstance(item, str):
                # Строковое представление Unicode
                try:
                    if item.startswith("U+"):
                        code_point = int(item[2:], 16)
                    elif item.startswith("0x"):
                        code_point = int(item[2:], 16)
                    else:
                        code_point = int(item, 16)

                    results.append(self.convert_single_emoji(code_point, item))
                except ValueError as e:
                    results.append(EmojiResult(
                        unicode=item,
                        code_point=None,
                        emoji="❌",
                        status=f"Ошибка парсинга: {str(e)}",
                        type="String",
                        is_supported=False,
                        category="Error"
                    ))

            elif isinstance(item, int):
                # Числовое значение code point
                results.append(self.convert_single_emoji(item))

            else:
                # Неизвестный тип
                results.append(EmojiResult(
                    unicode=str(item),
                    code_point=None,
                    emoji="❌",
                    status=f"Неподдерживаемый тип: {type(item).__name__}",
                    type=type(item).__name__,
                    is_supported=False,
                    category="Error"
                ))

        return results

    def display_emoji_table(self, results: List[EmojiResult], title: str = "Результаты обработки эмоджи"):
        """Отображает результаты в красивой таблице"""
        table = Table(title=title, show_header=True, header_style="bold magenta")

        table.add_column("Unicode", style="cyan", no_wrap=True)
        table.add_column("Emoji", justify="center", style="bold", no_wrap=True)
        table.add_column("Status", style="green")
        table.add_column("Category", style="blue")

        for result in results:
            # Цвет статуса в зависимости от поддержки
            if result.is_supported:
                status_style = "green"
            elif result.is_supported is False:
                status_style = "red"
            else:
                status_style = "yellow"

            table.add_row(
                result.unicode,
                result.emoji,
                Text(result.status, style=status_style),
                result.category
            )

        console.print(table)

    def display_emoji_grid(self, results: List[EmojiResult], title: str = "Эмоджи Grid"):
        """Отображает эмоджи в виде сетки"""
        emoji_panels = []
        r=0
        g=150
        b=255
        for result in results:
            if result.type == "Emoji":
                style = "green" if result.is_supported else "red"
                # panel = Panel(
                #     f"[bold]{result.emoji}[/bold]\n{result.unicode.strip("0x")}",
                #     style=style,
                #     width=10,
                #     height=4
                # )
                panel = Panel(result.emoji,
                    style=f"#{r:02x}{g:02x}{b:02x}",
                    width=6,
                    height=3
                )
                r = 0 if r >= 215 else r + 2
                g = 255 if g <= 3 else g-2
                b = 255 if b <= 3 else b-2
                emoji_panels.append(panel)

        if emoji_panels:
            console.print(Panel(Columns(emoji_panels, equal=True), title=title))

    def get_emojis_from_range(self, start_hex: int, end_hex: int,
                              only_supported: bool = False, sample_size: int = 0) -> List[EmojiResult]:
        """Получает эмоджи из диапазона (аналог PowerShell функции)"""
        console.print(f"Получение эмоджи из диапазона 0x{start_hex:X} - 0x{end_hex:X}", style="yellow")

        results = self.convert_emoji_array([(start_hex, end_hex)])

        # Фильтруем только эмоджи
        emoji_results = [r for r in results if r.type == "Emoji"]

        if only_supported:
            valid_emojis = [r for r in emoji_results if r.is_supported]
            console.print(f"Найдено эмоджи: {len(emoji_results)}, поддерживаемых: {len(valid_emojis)}",
                          style="green")
            return valid_emojis
        else:
            console.print(f"Найдено эмоджи: {len(emoji_results)}", style="green")
            return emoji_results


def demo_emoji_handler():
    """Демонстрация функциональности"""

    handler = EmojiHandler()

    console.print(Panel.fit("🐍 Python Rich Emoji Handler Demo 🐍", style="bold magenta"))

    # 1. Смешанные данные
    console.print("\n[bold cyan]1. Обработка смешанных данных:[/bold cyan]")
    mixed_data = [
        "U+1F600",  # Строка
        0x1F601,  # Число
        (0x1F602, 0x1F605),  # Диапазон (маленький)
        "0x2764",  # Строка с 0x
        (0x1F680, 0x1F685)  # Диапазон
    ]

    results = handler.convert_emoji_array(mixed_data)
    handler.display_emoji_table(results, "Смешанные данные")

    # 2. Диапазоны эмоджи
    console.print("\n[bold cyan]2. Обработка диапазонов эмоджи:[/bold cyan]")
    emoji_ranges = [
        (0x1F600, 0x1F64F),  # Emoticons - БОЛЬШОЙ диапазон
        (0x1F680, 0x1F6FF),  # Transport
        (0x2764, 0x2764)  # Одиночный символ
    ]

    range_results = handler.convert_emoji_array(emoji_ranges)
    console.print(f"Обработано диапазонов: {len(emoji_ranges)}")
    console.print(f"Получено результатов: {len(range_results)}")

    # 3. Детальный анализ одного диапазона
    console.print("\n[bold cyan]3. Подробный анализ диапазона Emoticons:[/bold cyan]")
    detailed_results = handler.convert_emoji_range(0x1F600, 0x1F610, show_all=True)
    emoji_only = [r for r in detailed_results if r.type == "Emoji"]
    handler.display_emoji_table(emoji_only, "Детальный анализ (первые 10)")

    # 4. Grid отображение
    console.print("\n[bold cyan]4. Grid отображение эмоджи:[/bold cyan]")
    handler.display_emoji_grid(emoji_only, "Emoticons Grid")

    # 5. Предопределенные диапазоны
    console.print("\n[bold cyan]5. Предопределенные диапазоны:[/bold cyan]")

    predefined_ranges = [
        {"name": "Emoticons", "range": (0x1F600, 0x1F64F), "description": "Смайлики и лица"},
        {"name": "Transport", "range": (0x1F680, 0x1F6FF), "description": "Транспорт и места"},
        {"name": "Symbols", "range": (0x2600, 0x26FF), "description": "Различные символы"}
    ]

    # Создаем таблицу диапазонов
    ranges_table = Table(title="Предопределённые диапазоны", show_header=True)
    ranges_table.add_column("Name", style="cyan")
    ranges_table.add_column("Count", justify="right", style="magenta")
    ranges_table.add_column("Description", style="green")

    for range_info in predefined_ranges:
        start, end = range_info["range"]
        count = end - start + 1
        ranges_table.add_row(range_info["name"], str(count), range_info["description"])

    console.print(ranges_table)

    # 6. Безопасное получение эмоджи
    console.print("\n[bold cyan]6. Безопасное получение эмоджи:[/bold cyan]")

    # Все эмоджи
    all_emojis = handler.get_emojis_from_range(0x1F600, 0x1F610)
    handler.display_emoji_table(all_emojis, "Все эмоджи (первые 10)")

    # Только поддерживаемые
    supported_only = handler.get_emojis_from_range(0x1F600, 0x1F610, only_supported=True)
    if supported_only:
        handler.display_emoji_table(supported_only, "Только поддерживаемые")

    # 7. Тестирование различных символов
    console.print("\n[bold cyan]7. Тест различных категорий символов:[/bold cyan]")

    test_sets = {
        "Basic Emoji": ["😀", "❤️", "🚀", "📁", "⭐", "🔥"],
        "Flags": ["🇺🇸", "🇺🇦", "🇷🇺", "🇩🇪", "🇯🇵", "🇨🇳"],
        "Complex Emoji": ["👨‍💻", "👩‍🚀"],
        "Symbols": ["←", "→", "↑", "↓", "⌘"]
    }

    for category, symbols in test_sets.items():
        console.print(f"\n[yellow]{category}:[/yellow]")
        symbol_results = []

        for symbol in symbols:
            # Получаем code point первого символа
            code_point = ord(symbol[0]) if symbol else 0
            result = handler.convert_single_emoji(code_point, symbol)
            result.emoji = symbol  # Используем оригинальный символ
            symbol_results.append(result)

        # Отображаем в одну строку
        display_line = " ".join([f"{r.emoji} ({'✅' if r.is_supported else '❌'})" for r in symbol_results])
        console.print(f"  {display_line}")


# Вспомогательные функции для быстрого использования
def quick_emoji_range(start: int, end: int, show_table: bool = True) -> List[EmojiResult]:
    """Быстрое получение эмоджи из диапазона"""
    handler = EmojiHandler()
    results = handler.get_emojis_from_range(start, end)

    if show_table:
        handler.display_emoji_table(results, f"Диапазон 0x{start:X} - 0x{end:X}")

    return results


def quick_emoji_grid(start: int, end: int):
    """Быстрое отображение эмоджи в grid"""
    handler = EmojiHandler()
    results = handler.get_emojis_from_range(start, end)
    handler.display_emoji_grid(results, f"Grid 0x{start:X} - 0x{end:X}")


def quick_emoji(code: int):
    """Быстрое отображение эмоджи в grid"""
    handler = EmojiHandler()
    result = handler.convert_single_emoji(code)
    if result.type == "Emoji":
        style = "green" if result.is_supported else "red"
        panel = Panel(
            f"[bold]{result.emoji}[/bold]\n{result.unicode}",
            style=style,
            width=10,
            height=4
        )
        console.print(panel)


if __name__ == "__main__":
    import argparse

parser = argparse.ArgumentParser(description="Система эмодзи с Rich поддержкой")
parser.add_argument("--qe", "-e", help="Поиск эмодзи")
parser.add_argument("--qs", "-s", help="Поиск диапазона эмодзи (начало и конец в hex)")
parser.add_argument("--qg", "-g", help="Поиск диапазона эмодзи (начало и конец в hex) grid")
args = parser.parse_args()

if args.qe:
    quick_emoji(int(args.qe,16))
if args.qs:
    start, end = args.qs.split('-')
    quick_emoji_range(int(start, 16), int(end, 16))
if args.qg:
    start, end = args.qg.split('-')
    quick_emoji_grid(int(start, 16), int(end, 16))


    # demo_emoji_handler()
    #
    # # Примеры быстрого использования
    # console.print("\n" + "=" * 50)
    # console.print("[bold green]Примеры быстрого использования:[/bold green]")
    #
    # console.print("\n[cyan]# Быстрая таблица эмоджи:[/cyan]")
    # console.print("quick_emoji_range(0x1F600, 0x1F610)")
    #
    # console.print("\n[cyan]# Быстрая grid эмоджи:[/cyan]")
    # console.print("quick_emoji_grid(0x1F680, 0x1F690)")
    #
    # # Интерактивный режим
    # try:
    #     console.print("\n[yellow]Нажмите Enter для интерактивных примеров или Ctrl+C для выхода...[/yellow]")
    #     input()
    #
    #     console.print("\n[bold]Интерактивные примеры:[/bold]")
    #     quick_emoji_range(0x1F600, 0x1F610)
    #     quick_emoji_grid(0x1F680, 0x1F690)
    #
    # except KeyboardInterrupt:
    #     console.print("\n[red]Завершение работы...[/red]")
    #     sys.exit(0)
    #
    # quick_emoji_range(0x260e, 0x26e9)
    # quick_emoji_grid(0x260e, 0x26e9)
    #
# quick_emoji(int('0x1F680',16))
