# === Power Theme для Python ===
$global:RichPath = "${global:profilePath}Rich"
$global:PowerThemePath = "${global:profilePath}Rich"

# Создаём структуру папок
if (-not (Test-Path $global:PowerThemePath))
{
    New-Item -ItemType Directory -Path $global:PowerThemePath -Force
}

# Функция установки темы
function Install-PowerTheme
{
    $themeFile = Join-Path $global:PowerThemePath "\power_theme.py"

    # Сохраняем файл темы (содержимое из power_theme.py выше)
    # ... код темы ...

    # Устанавливаем глобально
    python -c @"
import sys
sys.path.insert(0, r"${$global:RichPath}")
from power_theme_loader import install_theme
install_theme()
"@
}

# Функция для запуска Python с темой
function Invoke-ThemedPython
{
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )

    $env:PYTHONPATH = "$global:RichPath;$env:PYTHONPATH"
    $env:FORCE_COLOR = "1"

    # Добавляем автоимпорт темы
    $initCode = @"
import sys
sys.path.insert(0, f"${global:Rich}")
from power_theme import console, print as rprint
"@

    if ($Arguments[0] -eq "-c")
    {
        # Если это inline код, добавляем инициализацию
        $code = $initCode + "`n" + $Arguments[1]
        python -c $code
    }
    else
    {
        python @Arguments
    }
}

Install-PowerTheme

function Import-PythonModule
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [string[]]$Functions = @(),

        [switch]$AsGlobal,

        [string]$Prefix = ""
    )

    # Resolve full path
    if (-not [System.IO.Path]::IsPathRooted($Path))
    {
        $Path = Join-Path $global:RichPath $Path
    }

    if (-not $Path.EndsWith('.py'))
    {
        $Path = "$Path.py"
    }

    if (-not (Test-Path $Path))
    {
        Write-Error "Python module not found: $Path"
        return
    }

    # Get available functions
    $availableFuncs = python $global:PythonBridgePath list $Path |
            Where-Object { $_ -like "function:*" } |
            ForEach-Object { ($_ -split ':')[1].Split('(')[0].Trim() }

    # Import specific or all functions
    $targetFuncs = if ($Functions.Count -gt 0)
    { $Functions }
    else
    { $availableFuncs }

    foreach ($funcName in $targetFuncs)
    {
        $psName = if ($Prefix)
        { "$Prefix$funcName" }
        else
        { $funcName }

        # Create PowerShell function wrapper
        $functionDef = @"
function ${psName} {
    param(
        [Parameter(ValueFromRemainingArguments)]
        `$Arguments
    )

    # Подготовка аргументов
    `$pyArgs = @()
    `$pyKwargs = @{}

    foreach (`$arg in `$Arguments) {
        if (`$arg -match '^--(\w+)=(.*)$') {
            `$pyKwargs[`$matches[1]] = `$matches[2]
        } else {
            `$pyArgs += `$arg
        }
    }

    # Вызов Python функции
    `$argString = (`$pyArgs | ForEach-Object { `"'`$_'`" }) -join ' '
    `$kwargString = if (`$pyKwargs.Count -gt 0) {
        '--kwargs "' + (`$pyKwargs | ConvertTo-Json -Compress).Replace('"', '\"') + '"'
    } else { '' }

    `$cmd = "python `"$global:PythonBridgePath`" execute `"$Path`" --function $funcName"
    if (`$argString) { `$cmd += " --args `$argString" }
    if (`$kwargString) { `$cmd += " `$kwargString" }

    `$result = Invoke-Expression `$cmd

    # Попытка распарсить JSON
    try {
        `$result | ConvertFrom-Json
    } catch {
        `$result
    }
}
"@

        if ($AsGlobal)
        {
            Invoke-Expression $functionDef
            Write-Host "✅ Imported: $psName" -ForegroundColor Green
        }
        else
        {
            # Return function definition for local scope
            $functionDef
        }
    }
}

# Алиас для быстрого импорта
Set-Alias pyimport Import-PythonModule



function Test-Theme
{

    $themeScript = @"
#from rich.console import Console
#from rich.theme import Theme
#from rich.syntax import Syntax
from rich.table import Table
from rich.json import JSON
from rich.panel import Panel
#from rich.progress import Progress, TextColumn, BarColumn, TaskProgressColumn
#from rich.tree import Tree
#import json
#import time

try:

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
except ZeroDivisionError:
    # Handle the specific exception
    print("Error: Cannot divide by zero!")
except Exception as e:
    # Handle any other exceptions
    rprint("[gradient]An unexpected error occurred: [/]")
    rprint(f"[red]{e}[/]")
"@

    python -c $themeScript
    Write-Host "" -ForegroundColor Green
    ggrad " 🎯 Тема $Theme установлена! ✨" -color1 $colors.primary  -color2 $colors.gradient  -justify start
    spt $colors
}

Set-Alias tt Test-Theme



Set-Alias py Invoke-ThemedPython -Force