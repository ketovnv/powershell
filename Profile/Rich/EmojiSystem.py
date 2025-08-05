"""
EmojiSystem.py - Централизованная система управления эмодзи с поддержкой Rich
Обеспечивает красивое отображение эмодзи во всех терминалах
"""

from typing import Dict, List, Optional, Union
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.columns import Columns
from rich.text import Text
from rich import print as rprint
import re


class EmojiSystem:
    """Централизованная система управления эмодзи с Rich поддержкой"""

    def __init__(self):
        self.console = Console()
        self.database = {
            # Файловые иконки с поддержкой множественных расширений
            "file_icons": {
                # Скрипты и код
                '.ps1': '🔮', '.psm1': '🔮', '.psd1': '🔮',
                '.py': '🐍', '.js': '💖', '.jsx': '⚛️', '.ts': '💘', '.tsx': '⚛️',
                '.rs': '🦀', '.go': '🐹', '.cpp': '🔵', '.c': '🔷', '.cs': '🟣',
                '.java': '☕', '.rb': '💎', '.php': '🐘', '.swift': '🦉', '.kt': '🟠',
                '.lua': '🌙', '.dart': '🎯', '.r': '📊', '.jl': '🟩', '.scala': '🔴',
                '.clj': '🟢',

                # Исполняемые
                '.exe': '💻', '.msi': '📦', '.app': '🍎', '.deb': '📦', '.rpm': '📦',
                '.apk': '🤖', '.com': '🖥️', '.bat': '🦇', '.cmd': '⚡', '.sh': '🐚',
                '.dll': '🔧', '.so': '🔗',

                # Документы
                '.txt': '📜', '.md': '📝', '.doc': '📄', '.docx': '📄', '.pdf': '📕',
                '.odt': '📄', '.rtf': '📄', '.tex': '📐',

                # Данные и конфиги
                '.json': '💾', '.yaml': '💛', '.yml': '💛', '.toml': '💙', '.xml': '📋',
                '.csv': '📊', '.sql': '🗄️', '.db': '🗃️', '.env': '🔐', '.config': '⚙️',
                '.ini': '🔧',

                # Веб
                '.html': '🌍', '.htm': '🌍', '.css': '🎨', '.scss': '🎨', '.sass': '🎨',
                '.less': '🎨', '.vue': '🖼️', '.svelte': '🧡',

                # Медиа
                '.jpg': '🖼️', '.jpeg': '🖼️', '.png': '🖼️', '.gif': '🎞️', '.svg': '🎨',
                '.bmp': '🖼️', '.ico': '🎭', '.webp': '🖼️', '.mp4': '🎬', '.avi': '🎬',
                '.mov': '🎬', '.mkv': '🎬', '.mp3': '🎵', '.wav': '🎵', '.flac': '🎵',
                '.ogg': '🎵',

                # Архивы
                '.zip': '📦', '.rar': '📦', '.7z': '📦', '.tar': '📦', '.gz': '📦',
                '.bz2': '📦', '.xz': '📦',

                # Системные
                '.log': '📋', '.lock': '🔒', '.bak': '💾', '.tmp': '⏳', '.cache': '💾',
                '.swp': '🔄',

                # Default
                '': '📄'
            },

            # Категоризированные иконки
            "categories": {
                "network": {
                    'net': '🌐', 'wifi': '📶', 'signal': '📶', 'online': '🟢', 'offline': '🔴',
                    'server': '🖥️', 'cloud': '☁️', 'vpn': '🛡️', 'firewall': '🧱', 'proxy': '🔀',
                    'dns': '🧭', 'ip': '🌍', 'port': '🚪', 'socket': '🔌', 'packet': '📦',
                    'ping': '📶', 'latency': '⏱️', 'bandwidth': '📊', 'upload': '⬆️',
                    'download': '⬇️', 'stream': '📡', 'broadcast': '📢', 'router': '📡',
                    'switch': '🔀', 'hub': '🎯', 'gateway': '🚪'
                },

                "security": {
                    'secure': '🔐', 'insecure': '🔓', 'lock': '🔒', 'unlock': '🔓',
                    'key': '🔑', 'password': '🔑', 'auth': '🔐', '2fa': '🔢', 'shield': '🛡️',
                    'armor': '🛡️', 'protect': '🛡️', 'hack': '💀', 'breach': '⚠️',
                    'exploit': '💣', 'vulnerability': '🐛', 'patch': '🩹', 'audit': '🔍',
                    'cert': '📜', 'certificate': '📜', 'ssl': '🔒', 'tls': '🔒',
                    'encryption': '🔐', 'malware': '👾', 'virus': '🦠', 'antivirus': '🛡️',
                    'pentest': '🗡️', 'forensics': '🔍'
                },

                "git": {
                    'branch': '🌿', 'merge': '🔀', 'commit': '📌', 'push': '📤', 'pull': '📥',
                    'fork': '🍴', 'clone': '🐑', 'tag': '🏷️', 'release': '🎉', 'issue': '🐛',
                    'pr': '🔄', 'conflict': '⚔️', 'stash': '📦', 'diff': '🔄', 'rebase': '🔧',
                    'cherry': '🍒', 'cherry-pick': '🍒', 'submodule': '📚', 'gitignore': '🚫',
                    'workflow': '🔄', 'action': '⚡'
                },

                "devops": {
                    'docker': '🐳', 'kubernetes': '☸️', 'k8s': '☸️', 'container': '📦',
                    'pod': '🥛', 'helm': '⎈', 'pipeline': '🔗', 'ci': '🔄', 'cd': '🚀',
                    'deploy': '🚀', 'rollback': '⏪', 'build': '🏗️', 'test': '🧪',
                    'monitor': '📊', 'metric': '📈', 'log': '📋', 'alert': '🚨',
                    'backup': '💾', 'restore': '♻️', 'scale': '📏', 'terraform': '🏗️',
                    'ansible': '🔧', 'jenkins': '🎩'
                },

                "database": {
                    'database': '🗄️', 'db': '🗄️', 'table': '📊', 'query': '🔍',
                    'index': '📇', 'key': '🔑', 'primarykey': '🔑', 'foreignkey': '🔗',
                    'record': '📝', 'row': '📝', 'column': '📏', 'cache': '💾',
                    'redis': '🔴', 'mongo': '🍃', 'mongodb': '🍃', 'postgres': '🐘',
                    'postgresql': '🐘', 'mysql': '🐬', 'mariadb': '🐬', 'sqlite': '🪶',
                    'oracle': '🔮', 'mssql': '🟦', 'elasticsearch': '🔍', 'backup': '💿',
                    'sync': '🔄', 'replication': '📋'
                },

                "os": {
                    'windows': '🪟', 'linux': '🐧', 'ubuntu': '🟠', 'debian': '🌀',
                    'fedora': '🎩', 'centos': '💠', 'arch': '🏛️', 'manjaro': '🟢',
                    'suse': '🦎', 'redhat': '🎩', 'mac': '🍎', 'macos': '🍎',
                    'android': '🤖', 'ios': '📱', 'wsl': '🐧', 'vm': '💻',
                    'virtualbox': '📦', 'vmware': '🟦', 'hyperv': '🟦', 'terminal': '⬛',
                    'shell': '🐚', 'bash': '🐚', 'zsh': '🐚', 'powershell': '🔷',
                    'cmd': '⬛', 'kernel': '🌰'
                },

                "status": {
                    'running': '🟢', 'stopped': '🔴', 'paused': '⏸️', 'pending': '🟡',
                    'starting': '🔵', 'stopping': '🟠', 'error': '❌', 'warning': '⚠️',
                    'success': '✅', 'failed': '❌', 'info': 'ℹ️', 'debug': '🐛',
                    'critical': '🚨', 'healthy': '💚', 'unhealthy': '💔', 'unknown': '❓',
                    'ok': '👍', 'bad': '👎', 'good': '👍', 'excellent': '🌟', 'poor': '💩'
                },

                "performance": {
                    'cpu': '🧠', 'ram': '💾', 'memory': '💾', 'disk': '💿', 'storage': '💿',
                    'network': '🌐', 'temp': '🌡️', 'temperature': '🌡️', 'hot': '🔥',
                    'cold': '❄️', 'speed': '⚡', 'slow': '🐌', 'fast': '🚀',
                    'chart': '📊', 'graph': '📈', 'metric': '📊', 'battery': '🔋',
                    'power': '🔌', 'energy': '⚡', 'usage': '📊', 'load': '⚖️'
                },

                "development": {
                    'code': '💻', 'bug': '🐛', 'fix': '🔨', 'feature': '✨',
                    'refactor': '♻️', 'optimize': '⚡', 'document': '📚', 'test': '🧪',
                    'debug': '🐛', 'breakpoint': '🔴', 'todo': '📝', 'fixme': '🚨',
                    'hack': '🔨', 'review': '👀', 'approve': '✅', 'reject': '❌',
                    'comment': '💬', 'question': '❓', 'idea': '💡', 'plan': '📋',
                    'design': '🎨', 'architecture': '🏛️'
                },

                "package": {
                    'npm': '📦', 'yarn': '🧶', 'pnpm': '🚀', 'pip': '🐍', 'pipenv': '🐍',
                    'poetry': '📜', 'cargo': '📦', 'gem': '💎', 'composer': '🎼',
                    'apt': '📋', 'yum': '📋', 'dnf': '📋', 'pacman': '👾', 'brew': '🍺',
                    'homebrew': '🍺', 'choco': '🍫', 'chocolatey': '🍫', 'scoop': '🥄',
                    'winget': '📥', 'nuget': '📦', 'maven': '🏛️', 'gradle': '🐘',
                    'bundler': '💎'
                },

                "ukraine": {
                    'ukraine': '🇺🇦', 'flag': '🇺🇦', 'peace': '☮️', 'heart': '💙💛',
                    'strong': '💪', 'victory': '✌️', 'support': '🤝', 'freedom': '🕊️',
                    'hope': '🌻', 'sunflower': '🌻', 'unity': '🤲', 'courage': '🦁',
                    'brave': '🦁', 'home': '🏠', 'love': '❤️', 'pray': '🙏',
                    'light': '🕯️', 'slava': '🇺🇦', 'heroiam': '🌟'
                },

                "communication": {
                    'email': '📧', 'mail': '✉️', 'chat': '💬', 'message': '💬',
                    'call': '📞', 'phone': '📱', 'video': '📹', 'camera': '📷',
                    'microphone': '🎤', 'speaker': '🔊', 'notification': '🔔',
                    'bell': '🔔', 'mute': '🔕', 'broadcast': '📢', 'stream': '📡',
                    'podcast': '🎙️', 'forum': '💭', 'social': '👥', 'share': '🔗',
                    'like': '❤️', 'follow': '👣', 'subscribe': '🔔'
                },

                "time": {
                    'clock': '🕐', 'time': '⏰', 'timer': '⏱️', 'stopwatch': '⏱️',
                    'alarm': '⏰', 'calendar': '📅', 'date': '📆', 'deadline': '⏳',
                    'schedule': '📋', 'morning': '🌅', 'noon': '☀️', 'afternoon': '🌤️',
                    'evening': '🌆', 'night': '🌙', 'midnight': '🌃', 'weekend': '🎉',
                    'holiday': '🎄', 'birthday': '🎂', 'anniversary': '💍',
                    'today': '📍', 'tomorrow': '📍', 'yesterday': '📍'
                },

                "weather": {
                    'sunny': '☀️', 'cloudy': '☁️', 'rainy': '🌧️', 'stormy': '⛈️',
                    'snowy': '❄️', 'windy': '💨', 'foggy': '🌫️', 'rainbow': '🌈',
                    'hot': '🔥', 'cold': '🥶', 'warm': '🌤️', 'cool': '🌬️',
                    'humid': '💧', 'dry': '🏜️', 'weather': '🌤️', 'forecast': '📊',
                    'temperature': '🌡️', 'season': '🍂', 'spring': '🌸', 'summer': '☀️',
                    'autumn': '🍂', 'fall': '🍂', 'winter': '❄️'
                },

                "crypto": {
                    'bitcoin': '₿', 'btc': '₿', 'ethereum': 'Ξ', 'eth': 'Ξ',
                    'crypto': '🪙', 'coin': '🪙', 'wallet': '👛', 'blockchain': '⛓️',
                    'nft': '🖼️', 'defi': '🏦', 'gas': '⛽', 'mining': '⛏️',
                    'miner': '⛏️', 'stake': '🥩', 'staking': '🥩', 'swap': '🔄',
                    'exchange': '💱', 'bridge': '🌉', 'dao': '🏛️', 'smart': '📜',
                    'contract': '📜', 'token': '🪙', 'yield': '🌾'
                },

                "fun": {
                    'happy': '😊', 'sad': '😢', 'angry': '😠', 'cool': '😎',
                    'love': '😍', 'think': '🤔', 'shock': '😱', 'sleep': '😴',
                    'sick': '🤒', 'party': '🥳', 'work': '💼', 'coffee': '☕',
                    'beer': '🍺', 'wine': '🍷', 'pizza': '🍕', 'burger': '🍔',
                    'cake': '🍰', 'cookie': '🍪', 'game': '🎮', 'music': '🎵',
                    'movie': '🎬', 'book': '📚', 'sport': '⚽', 'travel': '✈️'
                }
            },

            # Алиасы для обратной совместимости
            "aliases": {
                'internet': 'net', 'www': 'net', 'web': 'net',
                'security': 'shield', 'protected': 'lock',
                'pullrequest': 'pr', 'mergerequest': 'pr',
                'k8': 'k8s', 'kube': 'k8s',
                'pg': 'postgres', 'psql': 'postgres',
                'win': 'windows', 'osx': 'mac',
                'fail': 'failed', 'err': 'error', 'warn': 'warning',
                'folder': 'dir', 'directory': 'dir'
            }
        }

    def get_emoji(self, name: str, category: Optional[str] = None, default: str = '❓') -> str:
        """
        Универсальная функция для получения эмодзи по имени или категории

        Args:
            name: Имя эмодзи для поиска
            category: Категория для поиска
            default: Эмодзи по умолчанию, если не найдено

        Returns:
            Строка с эмодзи
        """
        if category and name:
            # Поиск в конкретной категории
            if category.lower() in self.database["categories"]:
                category_emojis = self.database["categories"][category.lower()]

                # Прямое совпадение
                if name.lower() in category_emojis:
                    return category_emojis[name.lower()]

                # Проверка алиасов
                if name.lower() in self.database["aliases"]:
                    alias_name = self.database["aliases"][name.lower()]
                    if alias_name in category_emojis:
                        return category_emojis[alias_name]

        elif name:
            # Поиск по всем категориям
            lower_name = name.lower()

            # Сначала проверяем алиасы
            if lower_name in self.database["aliases"]:
                lower_name = self.database["aliases"][lower_name]

            # Поиск во всех категориях
            for cat_data in self.database["categories"].values():
                if lower_name in cat_data:
                    return cat_data[lower_name]

        return default

    def get_file_icon(self, extension: str, default: str = '📄') -> str:
        """
        Получение иконки для файла по расширению

        Args:
            extension: Расширение файла
            default: Иконка по умолчанию

        Returns:
            Строка с эмодзи
        """
        ext = extension.lower()
        if not ext.startswith('.'):
            ext = f".{ext}"

        return self.database["file_icons"].get(ext, default)

    def find_emoji(self, search_query: str, show_categories: bool = False) -> List[Dict]:
        """
        Поиск эмодзи по ключевому слову

        Args:
            search_query: Строка для поиска
            show_categories: Показывать результаты по категориям

        Returns:
            Список найденных эмодзи
        """
        results = []

        # Поиск в категориях
        for category, items in self.database["categories"].items():
            for name, emoji in items.items():
                if search_query.lower() in name.lower():
                    results.append({
                        'category': category,
                        'name': name,
                        'emoji': emoji
                    })

        # Поиск в файлах
        for ext, emoji in self.database["file_icons"].items():
            if search_query.lower() in ext.lower():
                results.append({
                    'category': 'files',
                    'name': ext,
                    'emoji': emoji
                })

        return results

    def print_search_results(self, search_query: str, show_categories: bool = False):
        """Красивый вывод результатов поиска с помощью Rich"""
        results = self.find_emoji(search_query, show_categories)

        if not results:
            self.console.print(f"[red]Ничего не найдено для запроса: {search_query}[/red]")
            return

        if show_categories:
            # Группировка по категориям
            from collections import defaultdict
            grouped = defaultdict(list)
            for result in results:
                grouped[result['category']].append(result)

            for category, items in grouped.items():
                panel_content = []
                for item in items:
                    panel_content.append(f"{item['emoji']} {item['name']}")

                panel = Panel(
                    "\n".join(panel_content),
                    title=f"[bold cyan]{category.title()}[/bold cyan]",
                    border_style="cyan"
                )
                self.console.print(panel)
        else:
            # Простой список
            table = Table(show_header=True, header_style="bold magenta")
            table.add_column("Emoji", width=8)
            table.add_column("Name", width=20)
            table.add_column("Category", width=15)

            for result in results:
                table.add_row(
                    result['emoji'],
                    result['name'],
                    f"[dim]{result['category']}[/dim]"
                )

            self.console.print(table)

        self.console.print(f"\n[yellow]Найдено: {len(results)}[/yellow]")

    def show_all_emojis(self, category: str = '*'):
        """Отображение всех эмодзи по категориям с Rich форматированием"""
        if category == '*':
            categories = list(self.database["categories"].keys())
        else:
            categories = [cat for cat in self.database["categories"].keys()
                          if category.lower() in cat.lower()]

        for cat in sorted(categories):
            items = self.database["categories"][cat]

            # Создаем таблицу для категории
            table = Table(show_header=False, box=None, padding=(0, 1))
            table.add_column(width=25)
            table.add_column(width=25)
            table.add_column(width=25)
            table.add_column(width=25)

            sorted_items = sorted(items.items())
            rows = []
            current_row = []

            for name, emoji in sorted_items:
                current_row.append(f"{emoji} {name}")
                if len(current_row) == 4:
                    table.add_row(*current_row)
                    current_row = []

            # Добавляем последнюю неполную строку
            if current_row:
                while len(current_row) < 4:
                    current_row.append("")
                table.add_row(*current_row)

            panel = Panel(
                table,
                title=f"[bold cyan]{cat.title()}[/bold cyan]",
                border_style="cyan"
            )
            self.console.print(panel)

        # Показываем файловые расширения если нужно
        if category == '*' or 'file' in category.lower():
            file_items = list(self.database["file_icons"].items())[:24]  # Первые 24

            table = Table(show_header=False, box=None, padding=(0, 1))
            for _ in range(4):
                table.add_column(width=20)

            rows = []
            current_row = []

            for ext, emoji in file_items:
                current_row.append(f"{emoji} {ext}")
                if len(current_row) == 4:
                    table.add_row(*current_row)
                    current_row = []

            if current_row:
                while len(current_row) < 4:
                    current_row.append("")
                table.add_row(*current_row)

            remaining = len(self.database["file_icons"]) - len(file_items)
            if remaining > 0:
                table.add_row(f"[dim]... и еще {remaining} расширений[/dim]", "", "", "")

            panel = Panel(
                table,
                title="[bold cyan]File Extensions[/bold cyan]",
                border_style="cyan"
            )
            self.console.print(panel)

    def get_category_emoji(self, category: str, name: str) -> str:
        """Получение эмодзи из конкретной категории"""
        return self.get_emoji(name, category)

    # Обертки для совместимости с PowerShell версией
    def get_net_icon(self, name: str) -> str:
        return self.get_emoji(name, "network")

    def get_git_icon(self, name: str) -> str:
        return self.get_emoji(name, "git")

    def get_devops_icon(self, name: str) -> str:
        return self.get_emoji(name, "devops")

    def get_database_icon(self, name: str) -> str:
        return self.get_emoji(name, "database")

    def get_os_icon(self, name: str) -> str:
        return self.get_emoji(name, "os")

    def get_status_icon(self, name: str) -> str:
        return self.get_emoji(name, "status")

    def get_security_icon(self, name: str) -> str:
        return self.get_emoji(name, "security")

    def get_perf_icon(self, name: str) -> str:
        return self.get_emoji(name, "performance")

    def get_package_icon(self, name: str) -> str:
        return self.get_emoji(name, "package")

    def get_ukraine_icon(self, name: str) -> str:
        return self.get_emoji(name, "ukraine")

    def get_time_icon(self, name: str) -> str:
        return self.get_emoji(name, "time")

    def get_weather_icon(self, name: str) -> str:
        return self.get_emoji(name, "weather")

    def get_crypto_icon(self, name: str) -> str:
        return self.get_emoji(name, "crypto")

    def get_mood_icon(self, name: str) -> str:
        return self.get_emoji(name, "fun")

    def get_comms_icon(self, name: str) -> str:
        return self.get_emoji(name, "communication")


# Глобальный экземпляр для удобства использования
emoji_system = EmojiSystem()


# Удобные функции для быстрого доступа
def get_emoji(name: str, category: Optional[str] = None, default: str = '❓') -> str:
    return emoji_system.get_emoji(name, category, default)


def get_file_icon(extension: str, default: str = '📄') -> str:
    return emoji_system.get_file_icon(extension, default)


def find_emoji(search_query: str, show_categories: bool = False):
    emoji_system.print_search_results(search_query, show_categories)


def show_all_emojis(category: str = '*'):
    emoji_system.show_all_emojis(category)


# Демонстрация использования
if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Система эмодзи с Rich поддержкой")
    parser.add_argument("--search", "-s", help="Поиск эмодзи")
    parser.add_argument("--category", "-c", help="Показать эмодзи категории")
    parser.add_argument("--show-all", "-a", action="store_true", help="Показать все эмодзи")
    parser.add_argument("--file", "-f", help="Получить иконку для файла")
    parser.add_argument("--get", "-g", help="Получить конкретный эмодзи")
    parser.add_argument("--from-cat", help="Категория для --get")
    parser.add_argument("--groups", action="store_true", help="Показать результаты поиска по группам")

    args = parser.parse_args()

    console = Console()

    # Красивое приветствие
    console.print(Panel.fit(
        "[bold magenta]🎨 EmojiSystem.py[/bold magenta]\n"
        "[cyan]Централизованная система управления эмодзи с Rich поддержкой[/cyan]",
        border_style="magenta"
    ))

    if args.search:
        console.print(f"\n[bold]🔍 Поиск эмодзи: '{args.search}'[/bold]")
        find_emoji(args.search, args.groups)

    elif args.category:
        console.print(f"\n[bold]📂 Категория: '{args.category}'[/bold]")
        show_all_emojis(args.category)

    elif args.show_all:
        console.print("\n[bold]🌟 Все доступные эмодзи:[/bold]")
        show_all_emojis()

    elif args.file:
        icon = get_file_icon(args.file)
        console.print(f"\n[bold]📁 Иконка для файла '{args.file}': {icon}[/bold]")

    elif args.get:
        emoji = get_emoji(args.get, args.from_cat)
        category_text = f" из категории '{args.from_cat}'" if args.from_cat else ""
        console.print(f"\n[bold]✨ Эмодзи '{args.get}'{category_text}: {emoji}[/bold]")

    else:
        # Интерактивная демонстрация
        console.print("\n[bold green]🚀 Демонстрация возможностей:[/bold green]")

        # Примеры использования
        examples = [
            ("Файловые иконки", [
                (get_file_icon("py"), "Python файл (.py)"),
                (get_file_icon("js"), "JavaScript файл (.js)"),
                (get_file_icon("docker"), "Docker файл"),
                (get_file_icon("json"), "JSON файл"),
            ]),
            ("Network", [
                (get_emoji("server", "network"), "Сервер"),
                (get_emoji("wifi", "network"), "WiFi"),
                (get_emoji("cloud", "network"), "Облако"),
                (get_emoji("vpn", "network"), "VPN"),
            ]),
            ("DevOps", [
                (get_emoji("docker", "devops"), "Docker"),
                (get_emoji("kubernetes", "devops"), "Kubernetes"),
                (get_emoji("pipeline", "devops"), "Pipeline"),
                (get_emoji("deploy", "devops"), "Deploy"),
            ]),
            ("Статусы", [
                (get_emoji("running", "status"), "Запущено"),
                (get_emoji("error", "status"), "Ошибка"),
                (get_emoji("success", "status"), "Успех"),
                (get_emoji("warning", "status"), "Предупреждение"),
            ]),
            ("Git", [
                (get_emoji("commit", "git"), "Коммит"),
                (get_emoji("branch", "git"), "Ветка"),
                (get_emoji("merge", "git"), "Слияние"),
                (get_emoji("conflict", "git"), "Конфликт"),
            ]),
            ("Украина 🇺🇦", [
                (get_emoji("ukraine", "ukraine"), "Украина"),
                (get_emoji("peace", "ukraine"), "Мир"),
                (get_emoji("sunflower", "ukraine"), "Подсолнух"),
                (get_emoji("victory", "ukraine"), "Победа"),
            ])
        ]

        for category_name, items in examples:
            table = Table(show_header=False, box=None, padding=(0, 1))
            table.add_column(width=8)
            table.add_column(width=30)

            for emoji, description in items:
                table.add_row(emoji, description)

            panel = Panel(
                table,
                title=f"[bold yellow]{category_name}[/bold yellow]",
                border_style="yellow"
            )
            console.print(panel)

        # Инструкции по использованию
        usage_panel = Panel(
            """[bold cyan]Примеры использования:[/bold cyan]

[yellow]В коде:[/yellow]
```python
from emoji_system import get_emoji, get_file_icon

# Получить эмодзи
docker_emoji = get_emoji("docker", "devops")  # 🐳
file_emoji = get_file_icon("requirements.txt")  # 📜

# Использовать в выводе
print(f"{docker_emoji} Запуск контейнера...")
print(f"{file_emoji} Обновление зависимостей...")
```

[yellow]Из командной строки:[/yellow]
```bash
python emoji_system.py --search docker
python emoji_system.py --category network
python emoji_system.py --file script.py
python emoji_system.py --get server --from-cat network
python emoji_system.py --show-all
```

[yellow]Поиск с группировкой:[/yellow]
```bash
python emoji_system.py --search git --groups
```""",
            title="[bold green]📖 Руководство[/bold green]",
            border_style="green"
        )
        console.print(usage_panel)

        # Статистика
        total_categories = len(emoji_system.database["categories"])
        total_emojis = sum(len(cat) for cat in emoji_system.database["categories"].values())
        total_files = len(emoji_system.database["file_icons"])
        total_aliases = len(emoji_system.database["aliases"])

        stats_text = f"""📊 [bold]Статистика:[/bold]
• Категорий: {total_categories}
• Эмодзи: {total_emojis}
• Файловых расширений: {total_files}
• Алиасов: {total_aliases}
• Всего символов: {total_emojis + total_files}"""

        console.print(stats_panel)