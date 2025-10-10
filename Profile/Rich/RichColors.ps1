Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

$global:richFolder = "${global:profilePath}/Rich/"



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
content='$text'
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

function Show-PrettyObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        $InputObject,

        [int]$Depth = 5,

        [ValidateSet('Json','Tree','Table','KeyValue')]
        [string]$View = 'Json',

        [switch]$ValuesIsColors
    )

    begin {
        $bag = @()

        function Convert-ToKeyValueString {
            param(
                [Parameter(Mandatory = $true)] $Obj,
                [int]$Depth = 5,
                [string]$KeyPath = '',
                [string]$Separator = ', '
            )
            if ($null -eq $Obj) { return ($KeyPath ? "$KeyPath=<null>" : "Value=<null>") }
            if ($Depth -le 0)   { return ($KeyPath ? "$KeyPath=<max depth>" : "<max depth>") }
            if ($Obj -is [string]) { return ($KeyPath ? "$KeyPath=$Obj" : "Value=$Obj") }

            if ($Obj -is [System.Collections.IDictionary]) {
                $out = @()
                foreach ($k in $Obj.Keys) {
                    $newPath = ($KeyPath ? "$KeyPath.$k" : "$k")
                    $out += Convert-ToKeyValueString -Obj $Obj[$k] -Depth ($Depth - 1) -KeyPath $newPath -Separator $Separator
                }
                return ($out -join $Separator)
            }

            if ($Obj -is [System.Collections.IEnumerable] -and -not ($Obj -is [string])) {
                $out = @(); $i = 0
                foreach ($elem in $Obj) {
                    $newPath = ($KeyPath ? "$KeyPath`[$i`]" : "[$i]")
                    $out += Convert-ToKeyValueString -Obj $elem -Depth ($Depth - 1) -KeyPath $newPath -Separator $Separator
                    $i++
                }
                return ($out -join $Separator)
            }

            if ($Obj -is [object] -and $Obj.PSObject.Properties.Count -gt 0) {
                $ht = @{}
                foreach ($p in $Obj.PSObject.Properties) { $ht[$p.Name] = $p.Value }
                return Convert-ToKeyValueString -Obj $ht -Depth ($Depth - 1) -KeyPath $KeyPath -Separator $Separator
            }

            return ($KeyPath ? "$KeyPath=$Obj" : "Value=$Obj")
        }

        $script:pyJson = @'
from rich.console import Console
from rich.json import JSON
import sys
console = Console()
data = sys.stdin.read().strip()
console.print(JSON(data))
'@

        $script:pyTree = @'
from rich.console import Console
from rich.tree import Tree
import json, sys, re
console = Console()

def parse_hex_mode(argv):
    for a in argv[1:]:
        s = str(a).strip().lower()
        if s in ('--',):  # служебный разделитель — пропускаем
            continue
        if s in ('1','true','yes','on'):  return True
        if s in ('0','false','no','off'): return False
    return False

hex_mode = parse_hex_mode(sys.argv)
data = json.loads(sys.stdin.read())

def is_hex_color(value):
    if not hex_mode: return False
    return isinstance(value, str) and re.match(r'^#(?:[0-9a-fA-F]{3}){1,2}$', value) is not None

def build_tree(node, tree):
    if isinstance(node, dict):
        for k, v in node.items():
            build_tree(v, tree.add(f'[bold medium_purple]{k}[/]:'))
    elif isinstance(node, list):
        for i, v in enumerate(node):
            build_tree(v, tree.add(f'[medium_purple2][{i}][/]' ))
    elif node is None:
        tree.add('[red]<null>[/]')
    elif isinstance(node, bool):
        tree.add(f'[yellow]{node}[/]')
    elif isinstance(node, (int, float)):
        tree.add(f'[light_cyan1]{node}[/]')
    elif is_hex_color(node):
        tree.add(f'[#{value[1:]}]{value}[/]')
    else:
        tree.add(f'[info]{node}[/]')

root = Tree('[bold purple3]Object[/]')
build_tree(data, root)
console.print(root)
'@

        $script:pyTable = @'
from rich import print
from rich.table import Table
from rich.text import Text
import json, sys, re

def parse_hex_mode(argv):
    for a in argv[1:]:
        s = str(a).strip().lower()
        if s in ('--',):  # служебный разделитель — пропускаем
            continue
        if s in ('1','true','yes','on'):  return True
        if s in ('0','false','no','off'): return False
    return False

hex_mode = parse_hex_mode(sys.argv)
data = json.loads(sys.stdin.read())

def is_hex_color(value):
    if not hex_mode: return False
    return isinstance(value, str) and re.match(r'^#(?:[0-9a-fA-F]{3}){1,2}$', value) is not None

def render_kv_table(d: dict):
    table = Table(show_header=False, show_lines=False, show_edge=False, style='#050711')
    for k, v in d.items():
        if isinstance(v, (dict, list)):
            v_str = Text(json.dumps(v, ensure_ascii=False))
            table.add_row(str(k), v_str)
        elif v is None:
            table.add_row(str(k), Text('<null>', style='red'))
        elif isinstance(v, bool):
            table.add_row(str(k), Text(str(v), style='yellow'))
        elif isinstance(v, (int,float)):
            table.add_row(str(k), Text(str(v), style='light_yellow3'))
        elif is_hex_color(v):
            table.add_row(Text(str(k), style=f"#{v[1:]}"), Text(v, style=f"#{v[1:]}"))
        else:
            table.add_row(str(k), Text(str(v), style="white"))
    return table

if isinstance(data, dict):
    print(render_kv_table(data))
elif isinstance(data, list):
    for i, item in enumerate(data):
        print(Text.assemble((str(i))))
        if isinstance(item, dict):
            print(render_kv_table(item))
        else:
            print(Text(str(item), style="white"))
else:
    print('[red]Not a dictionary or list[/]')
'@

        $script:pyKeyValue = @'
from rich import print
from rich.text import Text
import sys

lines = sys.stdin.read().splitlines()

def colorize_pair(pair: str):
    t = Text()
    if "=" in pair:
        k, v = pair.split("=", 1)
        t.append(k, style="bold cornflower_blue")
        t.append("=")
        lv = v.lower()
        if lv in ("true","false"):
            t.append(v, style="yellow")
        elif lv == "<null>":
            t.append(v, style="red")
        elif v.replace(".","",1).isdigit():
            t.append(v, style="white")
        else:
            t.append(v)
    else:
        t.append(pair)
    return t

for line in lines:
    parts = [p for p in (s.strip() for s in line.split(",")) if p]
    out = Text()
    for i, p in enumerate(parts):
        out.append(colorize_pair(p))
        if i < len(parts)-1:
            out.append(", ")
    print(out)
'@
    }

    process { $bag += ,$InputObject }

    end {
        if ($View -eq 'KeyValue') {
            $kvLines = foreach ($o in $bag) {
                Convert-ToKeyValueString -Obj $o -Depth $Depth
            }
            $payload = ($kvLines -join "`n")
            $payload | python -c $script:pyKeyValue
            return
        }

        $json = $bag | ConvertTo-Json -Depth $Depth -Compress
        $flag = if ($ValuesIsColors) { '1' } else { '0' }

        switch ($View) {
            'Json'  { $json | python -c $script:pyJson }
            'Tree'  { $json | python -c $script:pyTree  -- $flag }
            'Table' { $json | python -c $script:pyTable -- $flag }
        }
    }
}




#function Show-PrettyObject
#{
#    param(
#        [Parameter(Mandatory = $true, ValueFromPipeline)]
#        $InputObject,
#
#        [int]$Depth = 5,
#        [ValidateSet('KeyValue', 'Tree', 'Table', 'Json')]
#        [string]$View = 'Json',
#        [switch]$valuesIsColors
#    )
#
#    # Вспомогательная функция рекурсивного key=value
#    function Convert-ToKeyValueString
#    {
#        param(
#            [Parameter(Mandatory = $true)]
#            $Obj,
#
#            [int]$Depth = 5,
#            [string]$KeyPath = '',
#            [string]$Separator = ', '
#        )
#
#        if ($null -eq $Obj)
#        {
#            if ($KeyPath -ne '')
#            {
#                return "$KeyPath=<null>"
#            }
#            else
#            {
#                return "Value=<null>"
#            }
#        }
#
#        if ($Depth -le 0)
#        {
#            if ($KeyPath -ne '')
#            {
#                return "$KeyPath=<max depth>"
#            }
#            else
#            {
#                return "<max depth>"
#            }
#        }
#
#        if ($Obj -is [string])
#        {
#            if ($KeyPath -ne '')
#            {
#                return "$KeyPath=$Obj"
#            }
#            else
#            {
#                return "Value=$Obj"
#            }
#        }
#
#        if ($Obj -is [System.Collections.IDictionary])
#        {
#            $out = @()
#            foreach ($k in $Obj.Keys)
#            {
#                $newPath = if ($KeyPath)
#                {
#                    "$KeyPath.$k"
#                }
#                else
#                {
#                    "$k"
#                }
#                $out += Convert-ToKeyValueString -Obj $Obj[$k] -Depth ($Depth - 1) -KeyPath $newPath -Separator $Separator
#            }
#            return $out -join $Separator
#        }
#
#        if ($Obj -is [System.Collections.IEnumerable])
#        {
#            $out = @()
#            $i = 0
#            foreach ($elem in $Obj)
#            {
#                $newPath = if ($KeyPath)
#                {
#                    "$KeyPath`[$i`]"
#                }
#                else
#                {
#                    "[$i]"
#                }
#                $out += Convert-ToKeyValueString -Obj $elem -Depth ($Depth - 1) -KeyPath $newPath -Separator $Separator
#                $i++
#            }
#            return $out -join $Separator
#        }
#
#        if ($Obj -is [object] -and $Obj.PSObject.Properties.Count -gt 0)
#        {
#            $ht = @{ }
#            foreach ($p in $Obj.PSObject.Properties)
#            {
#                $ht[$p.Name] = $p.Value
#            }
#            return Convert-ToKeyValueString -Obj $ht -Depth ($Depth - 1) -KeyPath $KeyPath -Separator $Separator
#        }
#
#        if ($KeyPath -ne '')
#        {
#            return "$KeyPath=$Obj"
#        }
#        else
#        {
#            return "Value=$Obj"
#        }
#    }
#
#    # Основная логика функции
#    # Генерация key=value строки (для KeyValue view)
#    $kvStr = Convert-ToKeyValueString -Obj $InputObject -Depth $Depth
#
#    # Генерация JSON
#    $json = $InputObject | ConvertTo-Json -Depth $Depth -Compress
#
#    $pyScript = switch ($View)
#    {
#        'Json' {
#            @"
#from rich.console import Console
#console=Console()
#from rich.json import JSON
#json_obj = JSON.from_data($json)
#console.print(json_obj)
#"@
#        }
#        'Tree' {
#            @"
#from rich.tree import Tree
#import json
#import re
#def is_hex_color(value):
#    """Проверяет, является ли строка HEX-цветом (#RGB или #RRGGBB)."""
#    if not isinstance(value, str):
#        return False
#    return re.match(r'^#(?:[0-9a-fA-F]{3}){1,2}$', value) is not None
#
#data = json.loads('''$json''')
#
#def build_tree(node, tree):
#    if isinstance(node, dict):
#        for k, v in node.items():
#            branch = tree.add(f'[bold]{k}[/]:')
#            build_tree(v, branch)
#    elif isinstance(node, list):
#        for i, v in enumerate(node):
#            branch = tree.add(f'[hot_pink][{i}][/]')
#            build_tree(v, branch)
#    elif node is None:
#        tree.add('[red]<null>[/]')
#    elif isinstance(node, bool):
#        tree.add(f'[yellow]{node}[/]')
#    elif isinstance(node, (int, float)):
#        tree.add(f'[light_yellow3]{node}[/]')
#    elif is_hex_color(node):
#        tree.add(f'[#{node[1:]}]{node}[/]')
#    else:
#        tree.add(f'[info]{node}[/]')
#
#root = Tree('[bold bright_yellow]Object[/]')
#build_tree(data, root)
#console.print(root)
#"@
#        }
#        'Table' {
#            @"
#from rich import print
#from rich.table import Table
#from rich.text import Text
#import json
#import re
#
#def is_hex_color(value):
#    """Проверяет, является ли строка HEX-цветом (#RGB или #RRGGBB)."""
#    if not isinstance(value, str):
#        return False
#    return re.match(r'^#(?:[0-9a-fA-F]{3}){1,2}$', value) is not None
#data = json.loads('''$json''')
#if isinstance(data, dict):
#    table = Table(show_header=False, show_lines=False, show_edge=False,  style='#050711')
##    table.add_column('Key',  no_wrap=True)
##    table.add_column('Value')
#    for k, v in data.items():
#        if isinstance(v, (dict, list)):
#            v_str = json.dumps(v)
#        elif v is None:
#            v_str = '<null>'
#        elif  is_hex_color(v):
#            v_str = Text(v, style=f"#{v[1:]}")
#            table.add_row(Text(k, style=f"#{v[1:]}"), v_str)
#        else:
#            v_str = Text(v, style="white")
#            table.add_row(str(k), v_str)
#    print(table)
#else:
#    print('[red]Not a dictionary[/]')
#"@
#        }
#        'KeyValue' {
#            @"
#from rich import print
#from rich.text import Text
#
#kv = '''$kvStr'''.split(', ')
#
#txt = Text()
#for i, item in enumerate(kv):
#    if '=' in item:
#        key, val = item.split('=', 1)
#        txt.append(key, style='bold cornflower_blue')
#        txt.append('=')
#        # Цвет для значений по типу
#        if val.lower() in ('true', 'false'):
#            txt.append(val, style='yellow')
#        elif val.isdigit():
#            txt.append(val, style='light_yellow3')
#        elif val == '<null>':
#            txt.append(val, style='red')
#        else:
#            txt.append(val, style='white')
#    else:
#        txt.append(item, style='white')
#
#    if i < len(kv) - 1:
#        txt.append(', ')
#
#rprint(txt)
#"@
#        }
#    }
#
#    # Запускаем Python с rich
#    python -c $pyScript
#}



function _TryParse-JsonFromPipeline {
    param([object[]]$Chunk)
    if ($Chunk.Count -gt 0 -and ($Chunk[0] -is [string])) {
        $text = ($Chunk -join "`n").Trim()
        if ($text.StartsWith('{') -or $text.StartsWith('[')) {
            try { return ($text | ConvertFrom-Json) } catch { }
        }
    }
    return ,$Chunk  # вернуть как массив объектов
}


function spj {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)] $InputObject,
        [int]$Depth = 5
    )
    begin { $buf=@() }
    process { $buf += ,$PSItem }
    end {
        $obj = _TryParse-JsonFromPipeline $buf
        $obj | Show-PrettyObject -View Json -Depth $Depth
    }
}

function spt {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)] $InputObject,
        [int]$Depth = 5, [switch]$Hex
    )
    begin { $buf=@() }
    process { $buf += ,$PSItem }
    end {
        $obj = _TryParse-JsonFromPipeline $buf
        $obj | Show-PrettyObject -View Tree -Depth $Depth -ValuesIsColors:$Hex
    }
}

function sptb {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)] $InputObject,
        [int]$Depth = 5, [switch]$Hex
    )
    begin { $buf=@() }
    process { $buf += ,$PSItem }
    end {
        $obj = _TryParse-JsonFromPipeline $buf
        $obj | Show-PrettyObject -View Table -Depth $Depth -ValuesIsColors:$Hex
    }
}

function spkv {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)] $InputObject,
        [int]$Depth = 5
    )
    begin { $buf=@() }
    process { $buf += ,$PSItem }
    end {
        $obj = _TryParse-JsonFromPipeline $buf
        $obj | Show-PrettyObject -View KeyValue -Depth $Depth
    }
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