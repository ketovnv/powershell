Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

$global:richFolder = "${global:profilePath}/Rich/"


function gradd
{
    param(
        [string]$text = "RICH GRADIENT",
        [string]$color1 = "#ff0080",
        [string]$color2 = "#7928ca",
        [string]$justify = "center"
    )

    if (-not $FilePath)
    {
        # Если файл не указан, показываем пример
        $py = @"
from rich.console import Console, Group
from rich.panel import Panel
from rich.text import Text
from rich.color import Color
from rich.style import Style
from time import sleep
import math

console = Console(width=70)

def make_gradient_bg(width, height, color1, color2):
    # Возвращает список строк с фоновым градиентом
    bg_lines = []
    for y in range(height):
        ratio = y / max(height-1, 1)
        r1, g1, b1 = Color.parse(color1).triplet
        r2, g2, b2 = Color.parse(color2).triplet
        r = int(r1 + (r2 - r1) * ratio)
        g = int(g1 + (g2 - g1) * ratio)
        b = int(b1 + (b2 - b1) * ratio)
        bg_lines.append(f"[on #{r:02x}{g:02x}{b:02x}]{' ' * width}[/]")
    return "\n".join(bg_lines)

def make_blur_bg(width, height, colors):
    # Делает "размытый" фон: несколько полупрозрачных слоев разных оттенков
    bg = [[" "]*width for _ in range(height)]
    for y in range(height):
        for x in range(width):
            # Эмулируем размытие: хаотично смешиваем цвета
            ratio = (math.sin(x/width*math.pi + y/height*math.pi)+1)/2
            c1 = Color.parse(colors[0]).triplet
            c2 = Color.parse(colors[1]).triplet
            c3 = Color.parse(colors[2]).triplet
            r = int(c1[0]*(1-ratio) + c2[0]*ratio*0.7 + c3[0]*ratio*0.3)
            g = int(c1[1]*(1-ratio) + c2[1]*ratio*0.7 + c3[1]*ratio*0.3)
            b = int(c1[2]*(1-ratio) + c2[2]*ratio*0.7 + c3[2]*ratio*0.3)
            bg[y][x] = f"[on #{r:02x}{g:02x}{b:02x}] [/]"

    return "\n".join("".join(row) for row in bg)

def gradient_text(text, color1, color2):
    length = len(text)
    out = Text()
    for i, char in enumerate(text):
        ratio = i / max(length-1, 1)
        r1, g1, b1 = Color.parse(color1).triplet
        r2, g2, b2 = Color.parse(color2).triplet
        r = int(r1 + (r2 - r1) * ratio)
        g = int(g1 + (g2 - g1) * ratio)
        b = int(b1 + (b2 - b1) * ratio)
        style = Style(color=f"#{r:02x}{g:02x}{b:02x}", bold=True)
        out.append(char, style=style)
    return out

def gradient_border(i, total, colors):
    # Создает стиль рамки на основе прогресса и цветов
    ratio = i / max(total-1, 1)
    c1 = Color.parse(colors[0]).triplet
    c2 = Color.parse(colors[1]).triplet
    r = int(c1[0] + (c2[0] - c1[0]) * ratio)
    g = int(c1[1] + (c2[1] - c1[1]) * ratio)
    b = int(c1[2] + (c2[2] - c1[2]) * ratio)
    return f"#{r:02x}{g:02x}{b:02x}"

def main_demo():
    width, height = 62, 18
    blur_colors = ["#c471f5", "#fa71cd", "#48c6ef"]
    border_colors = ["#43cea2", "#185a9d"]
    text_colors = ["#ffe53b", "#ff2525"]
    panel_text = gradient_text("✨ RICH: Вау-эффект прямо в консоли! ✨", *text_colors)

    for tick in range(30):  # анимация: 30 кадров
        bg = make_blur_bg(width, height, blur_colors)
        # динамический border: градиент гуляет по цветам
        border_style = gradient_border(tick % height, height, border_colors)
        # панель с прозрачным фоном, на фоне blur-bg
        panel = Panel(
            Group(panel_text, "\n" + " " * ((width-len(panel_text.plain))//2) + "Тут градиент, blur и цветная рамка!"),
            width=width-2,
            border_style=border_style,
            padding=(3, 4),
            style="on #ffffff10"  # легкая белая «дымка» поверх blur
        )
        # Выводим "размытый" фон + панель поверх
        console.clear()
        console.print(bg)
        console.print("\n" * 2)
        console.print(panel, justify="center")
        sleep(0.13)

if __name__ == "__main__":
    main_demo()
"@
    }

    python -c $py
}



function grad
{
    param(
        [string]$text = "RICH GRADIENT",
        [string]$color1 = "#ff0080",
        [string]$color2 = "#7928ca",
        [string]$justify = "center"
    )

    if (-not $FilePath)
    {
        # Если файл не указан, показываем пример
        $py = @"
# Градиентный текст
def gradient_text():
    from rich.text import Text
    
    text = Text()
    colors = ["red", "orange", "yellow", "green", "blue", "purple"]
    message = "Градиентный текст в Rich!"
    
    for i, char in enumerate(message):
        color = colors[i % len(colors)]
        text.append(char, style=color)
    
    console.print(Panel(text, title="🌈 Gradient Effect"))

"@
    }

    python -c $py
}

function ggrad
{
    param(
        [string]$text = "RICH GRADIENT",
        [string]$color1 = "#ff0080",
        [string]$color2 = "#7928ca",
        [string]$justify = "center"
    )

    $colors = $global:RAINBOWGRADIENT
    $colors_json = $colors| ConvertTo-Json -Compress
    if (-not $FilePath)
    {   
        $py = @"
from rich.console import Console
from rich.panel import Panel
from rich.text import Text
import json

colors_json = '$colors_json'
gradient_colors = json.loads(colors_json)
console = Console(width=60)
#gradient_colors = ["#FF0000", "#FF7F00", "#FFFF00", "#00FF00", "#0000FF", "#4B0082", "#9400D3"]
def gradient_simple(text, colors):
    colored_chars = []
    step = len(colors) / max(len(text), 1)
    for i, char in enumerate(text):
        color = colors[int(i * step)]
        colored_chars.append(f"[{color}]{char}[/]")
    return "".join(colored_chars)

def gradient_text(text, color1, color2):
    from rich.color import Color
    length = len(text)
    result = ""
    for i, char in enumerate(text):
        ratio = i / max(length-1, 1)
        r1, g1, b1 = Color.parse(color1).triplet
        r2, g2, b2 = Color.parse(color2).triplet
        r = int(r1 + (r2 - r1) * ratio)
        g = int(g1 + (g2 - g1) * ratio)
        b = int(b1 + (b2 - b1) * ratio)
        result += f"[#{r:02x}{g:02x}{b:02x}]{char}[/]"
    return result

title = gradient_text(" Градиентная панель ", "#2288EE", "#fee140")
content="Powershell"
gradient_content = gradient_simple(content, gradient_colors)
panel = Panel(gradient_content, title=title, expand=True,
border_style="bold white on #050922")
console.print(panel)
console = Console(width=110)
for i in range(22):
    ratio = i / 88
    r = int(50 * (1 - ratio) + 100 * ratio)
    g = int(100 * (1 - ratio) + 255 * ratio)
    b = int(200 * (1 - ratio) + 150 * ratio)
#    console.print(f"[on #{r:02x}{g:02x}{b:02x}]{' ' * 78}[/]")
"@
    }

    python -c $py
}

function Show-PrettyObject
{
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        $InputObject,

        [int]$Depth = 5,
        [ValidateSet('KeyValue', 'Tree', 'Table', 'Json')]
        [string]$View = 'Json',
        [switch]$valuesIsColors
    )

    # Вспомогательная функция рекурсивного key=value
    function Convert-ToKeyValueString
    {
        param(
            [Parameter(Mandatory = $true)]
            $Obj,

            [int]$Depth = 5,
            [string]$KeyPath = '',
            [string]$Separator = ', '
        )

        if ($null -eq $Obj)
        {
            if ($KeyPath -ne '')
            {
                return "$KeyPath=<null>"
            }
            else
            {
                return "Value=<null>"
            }
        }

        if ($Depth -le 0)
        {
            if ($KeyPath -ne '')
            {
                return "$KeyPath=<max depth>"
            }
            else
            {
                return "<max depth>"
            }
        }

        if ($Obj -is [string])
        {
            if ($KeyPath -ne '')
            {
                return "$KeyPath=$Obj"
            }
            else
            {
                return "Value=$Obj"
            }
        }

        if ($Obj -is [System.Collections.IDictionary])
        {
            $out = @()
            foreach ($k in $Obj.Keys)
            {
                $newPath = if ($KeyPath)
                {
                    "$KeyPath.$k"
                }
                else
                {
                    "$k"
                }
                $out += Convert-ToKeyValueString -Obj $Obj[$k] -Depth ($Depth - 1) -KeyPath $newPath -Separator $Separator
            }
            return $out -join $Separator
        }

        if ($Obj -is [System.Collections.IEnumerable])
        {
            $out = @()
            $i = 0
            foreach ($elem in $Obj)
            {
                $newPath = if ($KeyPath)
                {
                    "$KeyPath`[$i`]"
                }
                else
                {
                    "[$i]"
                }
                $out += Convert-ToKeyValueString -Obj $elem -Depth ($Depth - 1) -KeyPath $newPath -Separator $Separator
                $i++
            }
            return $out -join $Separator
        }

        if ($Obj -is [object] -and $Obj.PSObject.Properties.Count -gt 0)
        {
            $ht = @{ }
            foreach ($p in $Obj.PSObject.Properties)
            {
                $ht[$p.Name] = $p.Value
            }
            return Convert-ToKeyValueString -Obj $ht -Depth ($Depth - 1) -KeyPath $KeyPath -Separator $Separator
        }

        if ($KeyPath -ne '')
        {
            return "$KeyPath=$Obj"
        }
        else
        {
            return "Value=$Obj"
        }
    }

    # Основная логика функции
    # Генерация key=value строки (для KeyValue view)
    $kvStr = Convert-ToKeyValueString -Obj $InputObject -Depth $Depth

    # Генерация JSON
    $json = $InputObject | ConvertTo-Json -Depth $Depth -Compress

    $pyScript = switch ($View)
    {
        'Json' {
            @"
from rich.json import JSON
json_obj = JSON.from_data($json)
console.print(json_obj)
"@
        }
        'Tree' {
            @"
from rich.tree import Tree
import json
import re
def is_hex_color(value):
    """Проверяет, является ли строка HEX-цветом (#RGB или #RRGGBB)."""
    if not isinstance(value, str):
        return False
    return re.match(r'^#(?:[0-9a-fA-F]{3}){1,2}$', value) is not None

data = json.loads('''$json''')

def build_tree(node, tree):
    if isinstance(node, dict):
        for k, v in node.items():
            branch = tree.add(f'[bold]{k}[/]:')
            build_tree(v, branch)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            branch = tree.add(f'[hot_pink][{i}][/]')
            build_tree(v, branch)
    elif node is None:
        tree.add('[red]<null>[/]')
    elif isinstance(node, bool):
        tree.add(f'[yellow]{node}[/]')
    elif isinstance(node, (int, float)):
        tree.add(f'[light_yellow3]{node}[/]')
    elif is_hex_color(node):
        tree.add(f'[#{node[1:]}]{node}[/]')
    else:
        tree.add(f'[info]{node}[/]')

root = Tree('[bold bright_yellow]Object[/]')
build_tree(data, root)
console.print(root)
"@
        }
        'Table' {
            @"
from rich import print
from rich.table import Table
from rich.text import Text
import json
import re

def is_hex_color(value):
    """Проверяет, является ли строка HEX-цветом (#RGB или #RRGGBB)."""
    if not isinstance(value, str):
        return False
    return re.match(r'^#(?:[0-9a-fA-F]{3}){1,2}$', value) is not None
data = json.loads('''$json''')
if isinstance(data, dict):
    table = Table(show_header=False, show_lines=False, show_edge=False,  style='#050711')
#    table.add_column('Key',  no_wrap=True)
#    table.add_column('Value')
    for k, v in data.items():
        if isinstance(v, (dict, list)):
            v_str = json.dumps(v)
        elif v is None:
            v_str = '<null>'
        elif  is_hex_color(v):
            v_str = Text(v, style=f"#{v[1:]}")
            table.add_row(Text(k, style=f"#{v[1:]}"), v_str)
        else:
            v_str = Text(v, style="white")
            table.add_row(str(k), v_str)
    print(table)
else:
    print('[red]Not a dictionary[/]')
"@
        }
        'KeyValue' {
            @"
from rich import print
from rich.text import Text

kv = '''$kvStr'''.split(', ')

txt = Text()
for i, item in enumerate(kv):
    if '=' in item:
        key, val = item.split('=', 1)
        txt.append(key, style='bold cornflower_blue')
        txt.append('=')
        # Цвет для значений по типу
        if val.lower() in ('true', 'false'):
            txt.append(val, style='yellow')
        elif val.isdigit():
            txt.append(val, style='light_yellow3')
        elif val == '<null>':
            txt.append(val, style='red')
        else:
            txt.append(val, style='white')
    else:
        txt.append(item, style='white')

    if i < len(kv) - 1:
        txt.append(', ')

rprint(txt)
"@
        }
    }

    # Запускаем Python с rich
    python -c $pyScript
}


function spt
{
    Show-PrettyObject @args  -View Table
}

function spj
{
    Show-PrettyObject @args  -View Json
}

function sptr
{
    Show-PrettyObject @args  -View Tree
}

function spkv
{
    Show-PrettyObject @args  -View KeyValue
}


$global:data = @{
    System = "Windows 11"
    Version = "24H2"
    CPU = "Intel i7-9700K"
    RAM = "16GB DDR5"
}


function pex
{
    param(
        [string]$FilePath,
        [string]$Language = "python",
        [string]$Theme = "rrt"
    )

    if (-not $FilePath)
    {
        # Если файл не указан, показываем пример
        $py = @"
from rich.console import Console
from rich.syntax import Syntax

console = Console()
code = '''
# Пример Python кода
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

print([fibonacci(i) for i in range(10)])
'''

syntax = Syntax(code, "$Language", theme="$Theme", line_numbers=True)
console.print(syntax)
"@
    }
    else
    {
        # Показываем содержимое файла
        $py = @"
from rich.console import Console
from rich.syntax import Syntax
import os

console = Console()
file_path = r'$FilePath'

if os.path.exists(file_path):
    syntax = Syntax.from_path(file_path, theme="$Theme", line_numbers=True)
    console.print(syntax)
else:
    console.print(f'[red]Файл не найден: {file_path}[/red]')
"@
    }

    python -c $py
}

function pexPS
{
    $currentFile = $PSCommandPath
    if (-not $currentFile)
    {
        $currentFile = "${global:profilePath}Utils\Aliases.ps1"
    }

    $py = @"
from rich.console import Console
from rich.syntax import Syntax
import os

console = Console()
file_path = r'$currentFile'

if os.path.exists(file_path):
    syntax = Syntax.from_path(file_path, theme="rrt", line_numbers=True, word_wrap=True)
    console.print(syntax)
else:
    console.print(f'[red]Файл не найден: {file_path}[/red]')
"@
    python -c $py
}

function pexFZF
{
    $selectedFile = Get-ChildItem -File -Recurse | Where-Object { $_.Extension -in @('.ps1', '.py', '.js', '.ts', '.json', '.xml', '.html', '.css') } | fzf

    if ($selectedFile)
    {
        $extension = $selectedFile.Extension.TrimStart('.')
        $language = switch ($extension)
        {
            'ps1' {
                'powershell'
            }
            'py' {
                'python'
            }
            'js' {
                'javascript'
            }
            'ts' {
                'typescript'
            }
            'json' {
                'json'
            }
            'xml' {
                'xml'
            }
            'html' {
                'html'
            }
            'css' {
                'css'
            }
            default {
                'text'
            }
        }

        $py = @"
from rich.console import Console
from rich.syntax import Syntax

console = Console()
syntax = Syntax.from_path(r'$( $selectedFile.FullName )', theme="rrt", line_numbers=True, word_wrap=True)
console.print(syntax)
"@
        python -c $py
    }
}

function pepex
{
    param(
        [string]$FilePath,
        [string]$Language = "python",
        [string]$Theme = "rrt"
    )

    if (-not $FilePath)
    {
        # Если файл не указан, показываем пример
        $py = @"
from rich.console import Console
from rich.syntax import Syntax
from rich import inspect
my_list = ["foo", "bar"]
inspect(r'$( $data )', methods=True)
"@
    }

    python -c $py
}


$global:data = @{
    System = "Windows 11"
    Version = "24H2"
    CPU = "Intel i7-9700K"
    RAM = "16GB DDR5"
}

Set-Alias -Name tpt -Value Test-PygmentsTheme -Force
Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))