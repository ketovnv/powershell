from rich import print

# Простой текст с форматированием в стиле BBCode
print("Hello, [bold magenta]World[/bold magenta]!", ":vampire:")

# Красивый вывод словарей и списков
my_dict = {"name": "John Doe", "age": 30, "is_active": True}
my_list = [1, 2, "a", "b"]
print(my_dict)
print(my_list)

# Можно использовать и объект Console для большего контроля
from rich.console import Console
from rich.text import Text

console = Console()
text: Text = Text("Hello, [bold red]world![/bold red]")
console.print(text)
console.print("Добро пожаловать в [bold magenta]Rich[/bold magenta]! 🌟🇺🇦'")
console.print("Это [underline green]PowerShell 7.6[/underline green]!", style="blink yellow on blue")


from rich.table import Table

table = Table(title="Список дел")
table.add_column("№", style="#1177DD")
table.add_column("Задача", style="#2299FF")
table.add_column("Статус", style="#55aacc")

table.add_row("1", "Установить Rich", "[✓] Готово ")
table.add_row("2", "Написать скрипт", "[⌛] В процессе ")
table.add_row("3", "Запустить в PowerShell", "[🐑 ] Ожидает ")

console.print(table)

from rich.progress import track
import time

for step in track(range(10), description="Обработка..."):
    time.sleep(0.2)  # Имитация работы
console.print("[bold green]Готово![/bold green]")

from rich.markdown import Markdown
md_text = "# Заголовок\n- Список\n- Элементы"
console.print(Markdown(md_text))

# Часть 1: Текст
console.print("[bold]Привет, PowerShell![/bold]", style="on white")
console.print("Это [italic yellow]пример Rich[/italic yellow] :snake:", emoji=True)

# Часть 2: Таблица
table = Table(title="Демо-таблица")
table.add_column("ID", justify="right")
table.add_column("Описание")
table.add_row("1", "[blink]Анимация[/blink] :rocket:", style="bold red")
table.add_row("2", "[underline]Форматирование[/underline] :sparkles:")
console.print(table)

# Часть 3: Прогресс-бар
with console.status("[magenta]Работаю...") as status:
    for _ in track(range(5)):
        time.sleep(0.5)
console.print("[green]Готово![/green]")


from rich.layout import Layout
from rich.panel import Panel
from rich.live import Live
from rich.table import Table
import time

console = Console()
layout = Layout()

# Создаем структуру интерфейса
layout.split(
    Layout(name="header", size=3),
    Layout(name="main", ratio=1),
    Layout(name="footer", size=3)
)
layout["main"].split_row(
    Layout(name="side", size=20),
    Layout(name="body", ratio=2)
)


def generate_dashboard() -> Layout:
    # Обновляем данные в реальном времени
    layout["header"].update(
        Panel(f"[bold]Dashboard[/] | [green]System Online[/] | {time.strftime('%X')}",
              style="white on blue")
    )

    # Боковая панель с метриками
    metrics = Table.grid(padding=1)
    metrics.add_column(style="cyan")
    metrics.add_row("[bold]CPU:[/] 42%")
    metrics.add_row("[bold]MEM:[/] 78%")
    metrics.add_row("[bold]NET:[/] 1.2Gbps")
    layout["side"].update(Panel(metrics, title="Metrics"))

    # Основное тело с таблицей
    main_table = Table(title="Active Processes")
    main_table.add_column("PID", justify="right")
    main_table.add_column("Name")
    main_table.add_column("Status")
    main_table.add_row("1289", "python.exe", "[green]Running")
    main_table.add_row("4521", "powershell.exe", "[yellow]Waiting")
    layout["body"].update(Panel(main_table))

    # Футер
    layout["footer"].update(
        Panel("[bold]F1[/]: Help | [bold]F2[/]: Refresh | [bold]ESC[/]: Exit",
              style="black on yellow")
    )
    return layout


# Обновление интерфейса каждые 0.5 сек
with Live(generate_dashboard(), refresh_per_second=4, screen=True) as live:
    while True:
        time.sleep(0.5)
        live.update(generate_dashboard())

from rich.console import Console
from rich.plot import Plot
from rich import box
import numpy as np

console = Console()


# Создаем кастомный график
def create_plot():
    plot = Plot(title="3D Surface", width=60, height=20)

    # Генерируем 3D данные
    x = np.linspace(-5, 5, 50)
    y = np.linspace(-5, 5, 50)
    X, Y = np.meshgrid(x, y)
    Z = np.sin(np.sqrt(X ** 2 + Y ** 2))

    # Конвертируем в координаты для Rich
    for i in range(len(Z)):
        line = []
        for j in range(len(Z[i])):
            height = int((Z[i][j] + 1) * 5)  # Нормализуем высоту
            line.append((height, f"{height:02d}"))  # (значение, отображение)
        plot.add_line(line, style="gradient(200, 40)")

    return plot


# Панель с анимированным графиком
with console.screen(style="white on black") as screen:
    frames = 30
    for frame in range(frames):
        angle = 2 * np.pi * frame / frames
        rotated_plot = create_plot()
        rotated_plot.title = f"3D Surface Rotation | Angle: {angle:.2f} rad"

        screen.update(
            Panel(
                rotated_plot,
                title="[bold]Scientific Visualization[/]",
                subtitle=f"Frame {frame + 1}/{frames}",
                box=box.DOUBLE,
                padding=1,
                style="bright_yellow"
            )
        )
        time.sleep(0.1)