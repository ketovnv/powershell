
importProcess  $MyInvocation.MyCommand.Name.trim(".ps1") -start

#region Инициализация
if (-not $global:RGB) {
    $global:RGB = @{}
}

# Загружаем цвета если еще не загружены
if (Test-Path (Join-Path $PSScriptRoot 'NiceColors.ps1')) {
    . (Join-Path $PSScriptRoot 'NiceColors.ps1')
}
#endregion

#region Расширенная система правил парсинга
$script:ParserRules = @{
# Системные сообщения
    Errors = @{
        Patterns = @(
            @{ Regex = '\b(ERROR|ОШИБКА|FATAL|КРИТИЧНО|EXCEPTION|FAILED|FAIL)\b'; Priority = 100 }
            @{ Regex = '(?i)\berr(or)?\s*[:=]\s*\S+'; Priority = 90 }
            @{ Regex = '❌|❗|⚠️|🚨|💀|☠️|🔥'; Priority = 95 }
            @{ Regex = '\[\s*FAIL(ED)?\s*\]'; Priority = 95 }
        )
        Style = @{
            FC = "LaserRed"
            BC = "#2C0000"
            Effects = @('Bold', 'Blink')
            Icon = "❌"
        }
    }

    Success = @{
        Patterns = @(
            @{ Regex = '\b(SUCCESS|УСПЕШНО|SUCCESSFUL|OK|COMPLETE|ГОТОВО|DONE|PASSED?)\b'; Priority = 90 }
            @{ Regex = '✅|✓|👍|🎉|🎯|💚|🟢'; Priority = 85 }
            @{ Regex = '\[\s*(OK|PASS(ED)?|DONE)\s*\]'; Priority = 85 }
        )
        Style = @{
            FC = "LimeGreen"
            Effects = @('Bold')
            Icon = "✅"
        }
    }

    Warnings = @{
        Patterns = @(
            @{ Regex = '\b(WARNING|ВНИМАНИЕ|WARN|ПРЕДУПРЕЖДЕНИЕ|CAUTION|ALERT)\b'; Priority = 80 }
            @{ Regex = '⚠️|⚡|🔔|🟡|⚠'; Priority = 75 }
            @{ Regex = '\[\s*WARN(ING)?\s*\]'; Priority = 75 }
        )
        Style = @{
            FC = "GoldYellow"
            Effects = @('Bold')
            Icon = "⚠️"
        }
    }

    # Технические элементы
    Code = @{
        Patterns = @(
        # PowerShell cmdlets
            @{ Regex = '\b(Get|Set|New|Remove|Add|Clear|Copy|Move|Rename|Test|Start|Stop|Restart|Select|Where|ForEach|Sort|Group|Measure|Export|Import|ConvertTo|ConvertFrom|Out|Write|Read)-[A-Z]\w+\b'; Priority = 70 }
        # Переменные
            @{ Regex = '\$[A-Za-z_]\w*'; Priority = 65 }
        # Параметры
            @{ Regex = '\B-[A-Za-z]\w*\b'; Priority = 65 }
        # Операторы
            @{ Regex = '(-eq|-ne|-gt|-lt|-ge|-le|-like|-match|-contains|-in|-notin|-and|-or|-not)'; Priority = 60 }
        )
        Style = @{
            FC = "Material_Purple"
            Effects = @('Italic')
        }
    }

    # Данные и значения
    Numbers = @{
        Patterns = @(
            @{ Regex = '\b\d+(\.\d+)?([eE][+-]?\d+)?\b'; Priority = 50 }
            @{ Regex = '\b0x[0-9A-Fa-f]+\b'; Priority = 55 }  # Hex
            @{ Regex = '\b\d+[KMG]B?\b'; Priority = 55 }  # Размеры
        )
        Style = @{
            FC = "Material_Pink"
        }
    }

    Strings = @{
        Patterns = @(
            @{ Regex = '"[^"]*"'; Priority = 60 }
            @{ Regex = "'[^']*'"; Priority = 60 }
            @{ Regex = '@"[\s\S]*?"@'; Priority = 65 }  # Here-strings
            @{ Regex = "@'[\s\S]*?'@"; Priority = 65 }
        )
        Style = @{
            FC = "Material_Green"
        }
    }

    # Сетевые элементы
    Network = @{
        Patterns = @(
        # IP адреса
            @{ Regex = '\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'; Priority = 70 }
        # Порты
            @{ Regex = ':\d{1,5}\b'; Priority = 65 }
        # MAC адреса
            @{ Regex = '\b([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})\b'; Priority = 70 }
        # URLs
            @{ Regex = 'https?://[^\s]+'; Priority = 75 }
        # Email
            @{ Regex = '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'; Priority = 70 }
        )
        Style = @{
            FC = "Turquoise"
            Effects = @('Underline')
        }
    }

    # Пути и файлы
    Paths = @{
        Patterns = @(
        # Windows пути
            @{ Regex = '(?:[A-Za-z]:)?\\(?:[^\\/:*?"<>|\r\n]+\\)*[^\\/:*?"<>|\r\n]*'; Priority = 60 }
        # Unix пути
            @{ Regex = '(?:/[^/\s]+)+/?'; Priority = 60 }
        # UNC пути
            @{ Regex = '\\\\[^\\]+\\[^\\]+(?:\\[^\\]+)*'; Priority = 65 }
        # Расширения файлов
            @{ Regex = '\.\w{1,4}\b'; Priority = 50 }
        )
        Style = @{
            FC = "PastelGreen"
            Effects = @('Italic')
        }
    }

    # Временные метки
    DateTime = @{
        Patterns = @(
        # ISO формат
            @{ Regex = '\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})?'; Priority = 70 }
        # Обычный формат
            @{ Regex = '\d{4}[-/]\d{2}[-/]\d{2}\s+\d{2}:\d{2}:\d{2}'; Priority = 65 }
        # Только время
            @{ Regex = '\b\d{1,2}:\d{2}(:\d{2})?\s*(AM|PM)?\b'; Priority = 60 }
        )
        Style = @{
            FC = "Silver"
        }
    }

    # Специальные маркеры
    Markers = @{
        Patterns = @(
        # TO_DO, FIX_ME, etc
            @{ Regex = '\b(TODO|FIXME|HACK|BUG|XXX|NOTE|IMPORTANT|DEPRECATED)\b:?'; Priority = 85 }
        # Версии
            @{ Regex = '\bv?\d+\.\d+(\.\d+)?(-\w+)?'; Priority = 60 }
        # GUIDs
            @{ Regex = '\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b'; Priority = 70 }
        )
        Style = @{
            FC = "Material_Orange"
            Effects = @('Bold')
        }
    }

    # Секции и заголовки
    Headers = @{
        Patterns = @(
        # Markdown заголовки
            @{ Regex = '^#{1,6}\s+.+$'; Priority = 90 }
        # Заголовки в верхнем регистре
            @{ Regex = '^[A-Z][A-Z\s\d\W]+:?\s*$'; Priority = 85 }
        # Разделители
            @{ Regex = '^[-=_*]{3,}\s*$'; Priority = 80 }
        )
        Style = @{
            FC = "Material_Cyan"
            Effects = @('Bold', 'Underline')
        }
    }
}

# Дополнительные контекстные правила
$script:ContextualRules = @{
# PowerShell Help
    PSHelp = @{
        Patterns = @{
            Sections = '^(NAME|SYNOPSIS|SYNTAX|DESCRIPTION|PARAMETERS|INPUTS|OUTPUTS|NOTES|EXAMPLES?|RELATED LINKS).*$'
            Parameters = '\s+-\w+\s+<\w+>'
            Types = '\[[\w.]+\]'
            Required = '\[?Required\]?'
            Position = 'Position:\s*\d+'
        }
    }

    # JSON
    JSON = @{
        Patterns = @{
            Keys = '"[^"]+"\s*:'
            Values = ':\s*"[^"]*"'
            Numbers = ':\s*\d+\.?\d*'
            Booleans = ':\s*(true|false|null)'
            Arrays = '\[|\]'
            Objects = '\{|\}'
        }
    }

    # Логи
    Logs = @{
        Patterns = @{
            Severity = '\[(ERROR|WARN|INFO|DEBUG|TRACE)\]'
            Thread = '\[Thread-\d+\]'
            Component = '\[[\w\.]+\]'
            Correlation = '\{[0-9a-f-]+\}'
        }
    }
}
#endregion

#region Основная функция парсинга
function Out-ParsedText {
    <#
    .SYNOPSIS
        Универсальная функция парсинга текста с продвинутой подсветкой

    .DESCRIPTION
        Парсит любой текст, автоматически определяя его тип и применяя
        соответствующие правила подсветки с поддержкой приоритетов и контекста

    .PARAMETER InputText
        Текст для парсинга (поддерживает pipeline)

    .PARAMETER Type
        Тип текста для специализированного парсинга

    .PARAMETER CustomRules
        Дополнительные пользовательские правила

    .PARAMETER NoIcon
        Не добавлять иконки к распознанным элементам

    .PARAMETER PassThru
        Вернуть результат вместо вывода

    .EXAMPLE
        Get-Content log.txt | Out-ParsedText

    .EXAMPLE
        Get-Help Get-Process | Out-String | Out-ParsedText -Type PSHelp
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$InputText,

        [ValidateSet('Auto', 'PSHelp', 'JSON', 'XML', 'Log', 'Code', 'Custom')]
        [string]$Type = 'Auto',

        [hashtable]$CustomRules = @{},

        [switch]$NoIcon,

        [switch]$PassThru,

        [switch]$ShowLineNumbers,

        [int]$LineNumberWidth = 4,

        [string]$LineNumberColor = "DarkGray"
    )

    begin {
        $lineCount = 0
        $allRules = $script:ParserRules

        # Добавляем пользовательские правила
        if ($CustomRules.Count -gt 0) {
            foreach ($ruleName in $CustomRules.Keys) {
                $allRules[$ruleName] = $CustomRules[$ruleName]
            }
        }

        # Подготавливаем все правила с приоритетами
        $compiledRules = @()
        foreach ($category in $allRules.Keys) {
            $categoryRules = $allRules[$category]
            foreach ($pattern in $categoryRules.Patterns) {
                $compiledRules += @{
                    Category = $category
                    Pattern = [regex]$pattern.Regex
                    Priority = $pattern.Priority
                    Style = $categoryRules.Style
                }
            }
        }

        # Сортируем по приоритету (высший приоритет первый)
        $compiledRules = $compiledRules | Sort-Object -Property Priority -Descending
    }

    process {
        foreach ($line in $InputText) {
            $lineCount++

            # Показываем номер строки если нужно
            if ($ShowLineNumbers) {
                $lineNum = $lineCount.ToString().PadLeft($LineNumberWidth)
                wrgb "$lineNum " -FC $LineNumberColor
                wrgb "│ " -FC $LineNumberColor
            }

            # Анализируем строку
            $segments = Get-ParsedSegments -Text $line -Rules $compiledRules

            # Выводим или возвращаем результат
            if ($PassThru) {
                $segments
            } else {
                foreach ($segment in $segments) {
                    $outputParams = @{
                        Text = $segment.Text
                        FC = $segment.Style.FC
                    }

                    if ($segment.Style.BC) {
                        $outputParams.BC = $segment.Style.BC
                    }

                    if ($segment.Style.Effects) {
                        $outputParams.Style = $segment.Style.Effects
                    }

                    # Добавляем иконку если есть и не отключено
                    if (-not $NoIcon -and $segment.Style.Icon -and $segment.IsStart) {
                        wrgb "$($segment.Style.Icon) " -FC $segment.Style.FC
                    }

                    wrgb @outputParams
                }
                Write-Host ""
            }
        }
    }
}

function Get-ParsedSegments {
    param(
        [string]$Text,
        [array]$Rules
    )

    $segments = @()
    $processedRanges = @()

    # Применяем правила по приоритету
    foreach ($rule in $Rules) {
        $matches = $rule.Pattern.Matches($Text)

        foreach ($match in $matches) {
            $start = $match.Index
            $end = $match.Index + $match.Length

            # Проверяем, не обработан ли уже этот диапазон
            $overlap = $false
            foreach ($range in $processedRanges) {
                if (($start -ge $range.Start -and $start -lt $range.End) -or
                        ($end -gt $range.Start -and $end -le $range.End)) {
                    $overlap = $true
                    break
                }
            }

            if (-not $overlap) {
                $segments += @{
                    Start = $start
                    End = $end
                    Text = $match.Value
                    Category = $rule.Category
                    Style = $rule.Style
                    IsStart = $true
                }

                $processedRanges += @{
                    Start = $start
                    End = $end
                }
            }
        }
    }

    # Сортируем сегменты по позиции
    $segments = $segments | Sort-Object -Property Start

    # Добавляем неотформатированные части
    $result = @()
    $lastEnd = 0

    foreach ($segment in $segments) {
        # Добавляем текст между сегментами
        if ($segment.Start -gt $lastEnd) {
            $result += @{
                Text = $Text.Substring($lastEnd, $segment.Start - $lastEnd)
                Style = @{ FC = "White" }
                IsStart = $false
            }
        }

        $result += $segment
        $lastEnd = $segment.End
    }

    # Добавляем оставшийся текст
    if ($lastEnd -lt $Text.Length) {
        $result += @{
            Text = $Text.Substring($lastEnd)
            Style = @{ FC = "White" }
            IsStart = $false
        }
    }

    return $result
}
#endregion

#region Специализированные парсеры
function Out-ParsedHelp {
    <#
    .SYNOPSIS
        Специализированный парсер для PowerShell Help
    #>
    param(
        [Parameter(ValueFromPipeline)]
        [string[]]$InputText,

        [string]$CommandName
    )

    begin {
        $style = @{
            SECTION = @{ FC = "Material_Pink"; Effects = @('Bold', 'Underline') }
            COMMAND = @{ FC = "Material_Yellow"; Effects = @('Bold') }
            PARAM = @{ FC = "Material_Cyan" }
            TYPE = @{ FC = "Material_Purple"; Effects = @('Italic') }
            REQUIRED = @{ FC = "Material_Red"; Effects = @('Bold') }
        }

        $buffer = @()
    }

    process {
        $buffer += $InputText
    }

    end {
        $text = $buffer -join "`n"

        # Определяем имя команды если не указано
        if (-not $CommandName -and $text -match 'NAME\s+(\S+)') {
            $CommandName = $matches[1]
        }

        # Escape для regex
        $commandEscaped = if ($CommandName) { [regex]::Escape($CommandName) } else { '\S+' }

        # Комплексный regex для всех элементов
        $regEx = @(
            "(?m)(?<=^[ \t]*)(?<SECTION>^[A-Z][A-Z \t\d\W]+$)"
            "(?<COMMAND>\b$commandEscaped\b)"
            "(?<PARAM>\B-\w+\b)"
            "(?<TYPE>\[[\w\[\]\.]+\])"
            "(?<REQUIRED>\[?(Required|Mandatory)\]?)"
        ) -join '|'

        # Обрабатываем текст построчно для лучшего контроля
        foreach ($line in ($text -split "`n")) {
            $formatted = [regex]::Replace($line, $regEx, {
                param($match)

                $group = $match.Groups | Where-Object { $_.Success -and $_.Name -ne '0' } | Select-Object -First 1
                if ($group) {
                    $st = $style[$group.Name]

                    # Формируем ANSI последовательность
                    $ansi = ""
                    if ($st.FC -and $global:RGB[$st.FC]) {
                        $color = Get-RGBColor $global:RGB[$st.FC]
                        $ansi += $color
                    }

                    if ($st.Effects -contains 'Bold') {
                        $ansi += $PSStyle.Bold
                    }
                    if ($st.Effects -contains 'Italic') {
                        $ansi += $PSStyle.Italic
                    }
                    if ($st.Effects -contains 'Underline') {
                        $ansi += $PSStyle.Underline
                    }

                    return $ansi + $group.Value + $PSStyle.Reset
                }
                return $match.Value
            })

            Write-Host $formatted
        }
    }
}

# Улучшенная функция gh
function gh {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Name,

        [switch]$Detailed,
        [switch]$Examples,
        [switch]$Full,
        [string[]]$Parameter
    )

    # Получаем help
    $help = Get-Help @PSBoundParameters

    # Конвертируем в строку и парсим
    $help | Out-String | Out-ParsedHelp -CommandName $help.Name
}
#endregion

#region Утилиты для создания правил
function New-ParserRule {
    <#
    .SYNOPSIS
        Создает новое правило парсинга

    .EXAMPLE
        New-ParserRule -Name "Emoji" -Pattern "😀|😁|😂|😃|😄|😅" -Color "Yellow" -Priority 50
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string[]]$Pattern,

        [string]$ForegroundColor = "White",
        [string]$BackgroundColor,
        [string[]]$Effects,
        [string]$Icon,
        [int]$Priority = 50
    )

    $rule = @{
        Patterns = @()
        Style = @{
            FC = $ForegroundColor
        }
    }

    foreach ($p in $Pattern) {
        $rule.Patterns += @{
            Regex = $p
            Priority = $Priority
        }
    }

    if ($BackgroundColor) {
        $rule.Style.BC = $BackgroundColor
    }

    if ($Effects) {
        $rule.Style.Effects = $Effects
    }

    if ($Icon) {
        $rule.Style.Icon = $Icon
    }

    # Добавляем в глобальные правила
    $script:ParserRules[$Name] = $rule

    Write-Status -Success "Правило '$Name' добавлено"

    return $rule
}

function Test-ParserRule {
    <#
    .SYNOPSIS
        Тестирует правило парсинга на тексте
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [string]$RuleName
    )

    if ($RuleName) {
        # Тестируем конкретное правило
        $rule = $script:ParserRules[$RuleName]
        if (-not $rule) {
            Write-Status -Error "Правило '$RuleName' не найдено"
            return
        }

        wrgb "Тестирование правила " -FC "White"
        wrgb $RuleName -FC "Cyan" -Style Bold -newline
        wrgb "Паттерны:" -FC "Yellow" -newline

        foreach ($pattern in $rule.Patterns) {
            wrgb "  • " -FC "DarkGray"
            wrgb $pattern.Regex -FC "Material_Green" -newline

            $matches = [regex]::Matches($Text, $pattern.Regex)
            if ($matches.Count -gt 0) {
                wrgb "    Найдено совпадений: " -FC "Gray"
                wrgb $matches.Count -FC "LimeGreen" -Style Bold -newline

                foreach ($match in $matches) {
                    wrgb "    → " -FC "DarkGray"
                    wrgb $match.Value -FC $rule.Style.FC -newline
                }
            } else {
                wrgb "    Совпадений не найдено" -FC "Red" -newline
            }
        }
    } else {
        # Тестируем все правила
        wrgb "Применение всех правил к тексту:" -FC "Cyan" -Style Bold -newline
        $Text | Out-ParsedText
    }
}
#endregion

#region Демонстрация
function Show-ParserDemo {
    Clear-Host

    Write-GradientHeader -Title "ADVANCED PARSER DEMO" -StartColor "#FF00FF" -EndColor "#00FFFF"

    # Пример 1: Логи
    wrgb "`n📋 Парсинг логов:" -FC "Cyan" -Style Bold -newline

    $sampleLog = @"
2024-01-15 10:30:15 [INFO] Application started successfully ✅
2024-01-15 10:30:16 [SUCCESS] Connected to database at 192.168.1.100:5432
2024-01-15 10:30:17 [INFO] Loading configuration from C:\Config\app.json
2024-01-15 10:30:18 [WARNING] ⚠️ Low memory: 512MB available
2024-01-15 10:30:19 [ERROR] ❌ Failed to connect to https://api.example.com
2024-01-15 10:30:20 [DEBUG] Retry attempt 1/3...
2024-01-15 10:30:51 [SUCCESS] ✅ Connection restored!
"@

    $sampleLog -split "`n" | Out-ParsedText -ShowLineNumbers

    wrgb "`nНажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host

    # Пример 2: PowerShell код
    wrgb "`n💻 Парсинг PowerShell кода:" -FC "Cyan" -Style Bold -newline

    $sampleCode = @'
# TODO: Optimize this function
function Get-SystemInfo {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ComputerName = "localhost",

        [switch]$Detailed
    )

    $result = @{
        Name = $ComputerName
        OS = Get-CimInstance -ClassName Win32_OperatingSystem
        Memory = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
        IP = (Test-Connection -ComputerName $ComputerName -Count 1).IPV4Address.ToString()
    }

    if ($Detailed) {
        Write-Host "Processing detailed info..." -ForegroundColor Yellow
        $result.CPU = Get-CimInstance -ClassName Win32_Processor
    }

    return $result
}

# FIXME: Handle errors properly
$info = Get-SystemInfo -ComputerName "server01" -Detailed
Write-Output "Memory: $($info.Memory) GB"
'@

    $sampleCode -split "`n" | Out-ParsedText

    wrgb "`nНажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host

    # Пример 3: JSON
    wrgb "`n📄 Парсинг JSON:" -FC "Cyan" -Style Bold -newline



    $sampleJSON = @'
{
    "name": "Advanced Parser",
    "version": "3.0.0",
    "features": [
        "Syntax highlighting",
        "Pattern recognition",
        "Context awareness"
    ],
    "settings": {
        "enabled": true,
        "priority": 100,
        "debug": false
    },
    "lastUpdate": "2024-01-15T10:30:00Z"
}
'@

    $sampleJSON -split "`n" | Out-ParsedText

    wrgb "`n✨ Демонстрация завершена!" -FC "LimeGreen" -Style Bold -newline
}
#endregion

# Алиасы для удобства
Set-Alias -Name parse -Value Out-ParsedText -Force
Set-Alias -Name phelp -Value Out-ParsedHelp -Force

# Экспорт функций
if ($MyInvocation.MyCommand.Path -match '\.psm1$') {
    Export-ModuleMember -Function @(
        'Out-ParsedText',
        'Out-ParsedHelp',
        'New-ParserRule',
        'Test-ParserRule',
        'Show-ParserDemo',
        'gh'
    ) -Alias @(
        'parse',
        'phelp'
    )
}

# Проверяем доступность wrgb функции
if (Get-Command wrgb -ErrorAction SilentlyContinue) {
    wrgb "`n🚀 " -FC "GoldRGB"
    Write-GradientText -Text "Advanced Parser System v3.0" `
                       -StartColor "#FF00FF" -EndColor "#00FFFF" `
                       -NoNewline
    wrgb " загружен!" -FC "GoldRGB" -newline

    wrgb "Используйте " -FC "Gray"
    wrgb "Show-ParserDemo" -FC "Cyan" -Style Bold
    wrgb " для демонстрации" -FC "Gray" -newline
} else {
    Write-Host "`n🚀 Advanced Parser System v3.0 загружен!" -ForegroundColor Green
    Write-Host "Используйте Show-ParserDemo для демонстрации" -ForegroundColor Cyan
}




importProcess  $MyInvocation.MyCommand.Name.trim(".ps1")
