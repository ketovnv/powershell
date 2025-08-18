#= = = Power Theme для Python = = =
$global:PythonModulesPath = "${global:profilePath}Rich\python"
$global:PowerThemePath = "${global:PythonModulesPath}\.config\power_theme"

# Создаём структуру папок
if (-not (Test-Path $global:PowerThemePath))
{
    New-Item -ItemType Directory -Path $global:PowerThemePath -Force
}

# Функция установки темы - БЕЗ Unicode символов
function Install-PowerTheme
{
    try
    {
        $themeTestScript = @"
import sys
import os

# Принудительно устанавливаем UTF-8 для Windows
if sys.platform == 'win32':
    import subprocess
    subprocess.run(['chcp', '65001'], shell=True, capture_output=True)
    os.environ['PYTHONIOENCODING'] = 'utf-8'
    os.environ['PYTHONUTF8'] = '1'

sys.path.insert(0, r'$global:PowerThemePath')

try:
    from power_theme import console, get_console
    print('[SUCCESS] Power Theme loading...')

    # Тест регистрации стиля
    from power_theme import register_power_style
    register_power_style()

    print('[SUCCESS] Power Theme activated!')
except ImportError as e:
    print(f'[ERROR] Import error: {e}')
except Exception as e:
    print(f'[ERROR] Theme error: {e}')
"@

        $env:PYTHONIOENCODING = "utf-8"
        $env:PYTHONUTF8 = "1"

        $result = python -c $themeTestScript
        if ($LASTEXITCODE -eq 0)
        {
            Write-Host "[SUCCESS] Power Theme инициализирована" -ForegroundColor Green
        }
        else
        {
            Write-Warning "[WARNING] Ошибка инициализации Power Theme"
        }
    }
    catch
    {
        Write-Warning "[ERROR] Ошибка установки Power Theme: $_"
    }
}

# Функция для запуска Python с темой
function Invoke-ThemedPython
{
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )

    # Устанавливаем переменные окружения
    $env:PYTHONPATH = "$global:PowerThemePath;$env:PYTHONPATH"
    $env:FORCE_COLOR = "1"
    $env:PYTHONIOENCODING = "utf-8"
    $env:PYTHONUTF8 = "1"

    # Добавляем автоимпорт темы
    $initCode = @"
import sys
import os

# Принудительно устанавливаем UTF-8
if sys.platform == 'win32':
    import subprocess
    subprocess.run(['chcp', '65001'], shell=True, capture_output=True)
    os.environ['PYTHONIOENCODING'] = 'utf-8'
    os.environ['PYTHONUTF8'] = '1'

sys.path.insert(0, r'$global:PowerThemePath')

try:
    from power_theme import console, get_console
    # Делаем console доступной глобально для скрипта
    globals()['console'] = console
    globals()['rprint'] = console.print
except ImportError:
    # Fallback к стандартному Rich
    from rich.console import Console
    console = Console()
    globals()['console'] = console
    globals()['rprint'] = console.print
"@

    if ($Arguments.Count -gt 0 -and $Arguments[0] -eq "-c")
    {
        # Если это inline код, добавляем инициализацию
        $code = $initCode + "`n" + $Arguments[1]
        python -c $code
    }
    else
    {
        # Для файлов создаем временный запускатель
        $tempScript = [System.IO.Path]::GetTempFileName() + ".py"
        $initCode | Out-File -FilePath $tempScript -Encoding UTF8

        if ($Arguments.Count -gt 0)
        {
            # Добавляем содержимое файла
            Get-Content $Arguments[0] | Add-Content $tempScript
            python $tempScript
        }
        else
        {
            python $tempScript
        }

        Remove-Item $tempScript -ErrorAction SilentlyContinue
    }
}

# Запуск установки темы
Install-PowerTheme

function Test-Theme
{
    $Theme = 'Power'
    $themeScript = @"
import sys
import os

# Принудительно устанавливаем UTF-8
if sys.platform == 'win32':
    import subprocess
    subprocess.run(['chcp', '65001'], shell=True, capture_output=True)
    os.environ['PYTHONIOENCODING'] = 'utf-8'
    os.environ['PYTHONUTF8'] = '1'

sys.path.insert(0, r'$global:PowerThemePath')

try:
    from power_theme import console, get_console
    from rich.syntax import Syntax
    from rich.table import Table
    from rich.json import JSON
    from rich.panel import Panel
    from rich.progress import Progress, TextColumn, BarColumn, TaskProgressColumn
    from rich.tree import Tree
    import json
    import time

    # === ДЕМОНСТРАЦИЯ БЕЗ ПРОБЛЕМНЫХ СИМВОЛОВ ===
    console.print(Panel(f"Power Theme: {Theme}", style="bold", title="Power Theme Test"))

    # 1. Код с правильной темой
    console.print(Panel("[bold]Синтаксис кода[/bold]"))
    code = '''
def analyze_data(dataset):
    '''Анализирует набор данных'''
    # Подсчитываем статистику
    total = len(dataset)
    average = sum(dataset) / total if total > 0 else 0
    return {"total": total, "average": average}
    '''

    syntax = Syntax(code, 'python', theme='power', line_numbers=True)
    console.print(syntax)

    # 2. JSON
    console.print(Panel("[bold]JSON структура[/bold]"))
    data = {
        "server": "production",
        "active": True,
        "connections": 1250,
        "load": 0.85,
        "errors": None,
        "services": ["api", "web", "db"]
    }
    json_obj = JSON.from_data(data)
    console.print(json_obj)

    # 3. Таблица
    console.print(Panel("[bold]Таблица метрик[/bold]"))
    table = Table(title="Мониторинг системы")
    table.add_column("Сервис", style="cyan")
    table.add_column("Статус", justify="center")
    table.add_column("CPU", justify="right", style="magenta")
    table.add_column("RAM", justify="right", style="magenta")

    table.add_row("API", "[green]Работает[/green]", "[blue]23%[/blue]", "[blue]45%[/blue]")
    table.add_row("Database", "[yellow]Загружена[/yellow]", "[yellow]78%[/yellow]", "[yellow]89%[/yellow]")
    table.add_row("Cache", "[red]Ошибка[/red]", "[blue]5%[/blue]", "[blue]12%[/blue]")
    console.print(table)

    # 4. Дерево файлов
    console.print(Panel("[bold]Структура проекта[/bold]"))
    tree = Tree("project")
    src_branch = tree.add("src")
    src_branch.add("[blue]main.py[/blue]")
    test_branch = tree.add("tests")
    test_branch.add("[blue]test_main.py[/blue]")
    tree.add("[green]README.md[/green]")
    console.print(tree)

    console.print(f"[bold green]Тема {Theme} работает отлично![/bold green]")

except ImportError as e:
    print(f"[ERROR] Import error: {e}")

except Exception as e:
    print(f"[ERROR] Theme error: {e}")
"@

    try
    {
        $env:PYTHONIOENCODING = "utf-8"
        $env:PYTHONUTF8 = "1"
        python -c $themeScript
        Write-Host "[SUCCESS] Тестирование Power Theme завершено!" -ForegroundColor Green
    }
    catch
    {
        Write-Warning "[ERROR] Ошибка тестирования темы: $_"
    }
}

Set-Alias tt Test-Theme
Set-Alias py Invoke-ThemedPython -Force

# Остальные функции без изменений...
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
    # Функция остается без изменений
}

Set-Alias pyimport Import-PythonModule


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
        $Path = Join-Path $global:PythonModulesPath $Path
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
        if (`$arg -match '^--(\\w+)=(.*)$') {
            `$pyKwargs[`$matches[1]] = `$matches[2]
        } else {
            `$pyArgs += `$arg
        }
    }

    # Вызов Python функции
    `$argString = (`$pyArgs | ForEach-Object { `"'`$_'`" }) -join ' '
    `$kwargString = if (`$pyKwargs.Count -gt 0) {
        '--kwargs "' + (`$pyKwargs | ConvertTo-Json -Compress).Replace('"', '\\"') + '"'
    } else { '' }

    `$cmd = "python `"`$global:PythonBridgePath`" execute `"`$Path`" --function $funcName"
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

