# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                       🎨 NICE PARSER v2.0 - RGB Edition                    ║
# ║                     Enhanced PowerShell Text Parser                         ║
# ║                         With Full RGB Support 🌈                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

#region Инициализация и зависимости

# Проверка и импорт необходимых модулей
$requiredModules = @('Parser', 'ColoredText')
foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Warning "Модуль $module не найден. Установите: Install-Module $module"
    } else {
        Import-Module $module -ErrorAction SilentlyContinue
    }
}

#endregion

#region RGB Палитра и базовые функции

# Расширенная RGB палитра с дополнительными цветами
if (-not $global:RGB) {
    $global:RGB = @{}
}

# Добавляем новые цвета к существующей палитре
$additionalColors = @{
# Пастельные тона
    "PastelPink"     = "#FFD1DC"
    "PastelBlue"     = "#AEC6CF"
    "PastelGreen"    = "#77DD77"
    "PastelYellow"   = "#FDFD96"
    "PastelPurple"   = "#B19CD9"

    # Металлические оттенки
    "Silver"         = "#C0C0C0"
    "Bronze"         = "#CD7F32"
    "Copper"         = "#B87333"
    "Platinum"       = "#E5E4E2"

    # Природные цвета
    "SkyBlue"        = "#87CEEB"
    "SeaGreen"       = "#2E8B57"
    "SandyBrown"     = "#F4A460"
    "Turquoise"      = "#40E0D0"

    # Энергетические цвета
    "ElectricLime"   = "#CCFF00"
    "LaserRed"       = "#FF0F0F"
    "NeonOrange"     = "#FF6600"
    "PlasmaViolet"   = "#8B00FF"
}

foreach ($color in $additionalColors.GetEnumerator()) {
    if (-not $global:RGB.ContainsKey($color.Key)) {
        $global:RGB[$color.Key] = $color.Value
    }
}

# Функция конвертации HEX в RGB компоненты
function ConvertTo-RGBComponents {
    param([string]$HexColor)

    $hex = $HexColor.TrimStart('#')
    if ($hex.Length -eq 3) {
        $hex = $hex[0] + $hex[0] + $hex[1] + $hex[1] + $hex[2] + $hex[2]
    }

    return @{
        R = [Convert]::ToInt32($hex.Substring(0, 2), 16)
        G = [Convert]::ToInt32($hex.Substring(2, 2), 16)
        B = [Convert]::ToInt32($hex.Substring(4, 2), 16)
    }
}

# Функция создания ANSI escape последовательности для RGB
function Get-RGBAnsiSequence {
    param(
        [string]$HexColor,
        [switch]$Background
    )

    $rgb = ConvertTo-RGBComponents -HexColor $HexColor
    $type = if ($Background) { 48 } else { 38 }

    return "`e[${type};2;$($rgb.R);$($rgb.G);$($rgb.B)m"
}

#endregion

#region Основная функция Write-RGB

function Write-RGB {
    <#
    .SYNOPSIS
        Выводит текст с поддержкой RGB цветов
    
    .DESCRIPTION
        Универсальная функция для вывода текста с RGB цветами переднего плана и фона,
        поддержкой стилей и различных режимов вывода
    
    .PARAMETER Text
        Текст для вывода
    
    .PARAMETER ForegroundColor
        Цвет текста (имя из палитры или HEX)
    
    .PARAMETER BackgroundColor
        Цвет фона (имя из палитры или HEX)
    
    .PARAMETER Style
        Стиль текста: Bold, Italic, Underline, Blink
    
    .PARAMETER NoNewLine
        Не добавлять перевод строки
    
    .EXAMPLE
        Write-RGB "Hello World" -ForegroundColor "#FF6B6B" -Style Bold
    
    .EXAMPLE
        Write-RGB "Warning!" -ForegroundColor "ElectricLime" -BackgroundColor "#2C0000" -Style Blink
    #>

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string]$Text,

        [Alias('FC', 'FG')]
        [string]$ForegroundColor = 'White',

        [Alias('BC', 'BG')]
        [string]$BackgroundColor,

        [ValidateSet('Normal', 'Bold', 'Italic', 'Underline', 'Blink')]
        [string[]]$Style = 'Normal',

        [Alias('NNL')]
        [switch]$NoNewLine
    )

    begin {
        # Проверка поддержки ANSI
        if (-not $PSStyle) {
            Write-Warning "PSStyle не поддерживается в данной версии PowerShell"
            return
        }
    }

    process {
        $output = ""

        # Применение стилей
        foreach ($s in $Style) {
            switch ($s) {
                'Bold'      { $output += $PSStyle.Bold }
                'Italic'    { $output += $PSStyle.Italic }
                'Underline' { $output += $PSStyle.Underline }
                'Blink'     { $output += $PSStyle.Blink }
            }
        }

        # Применение цвета переднего плана
        if ($global:RGB.ContainsKey($ForegroundColor)) {
            $output += Get-RGBAnsiSequence -HexColor $global:RGB[$ForegroundColor]
        } elseif ($ForegroundColor -match '^#[0-9A-Fa-f]{3,6}$') {
            $output += Get-RGBAnsiSequence -HexColor $ForegroundColor
        } else {
            # Попытка использовать системные цвета
            try {
                $output += $PSStyle.Foreground.$ForegroundColor
            } catch {
                # Используем белый по умолчанию
                $output += $PSStyle.Foreground.White
            }
        }

        # Применение цвета фона
        if ($BackgroundColor) {
            if ($global:RGB.ContainsKey($BackgroundColor)) {
                $output += Get-RGBAnsiSequence -HexColor $global:RGB[$BackgroundColor] -Background
            } elseif ($BackgroundColor -match '^#[0-9A-Fa-f]{3,6}$') {
                $output += Get-RGBAnsiSequence -HexColor $BackgroundColor -Background
            } else {
                try {
                    $output += $PSStyle.Background.$BackgroundColor
                } catch {
                    # Игнорируем ошибку
                }
            }
        }

        # Добавляем текст и сброс стилей
        $output += $Text + $PSStyle.Reset

        # Вывод
        if ($NoNewLine) {
            Write-Host $output -NoNewline
        } else {
            Write-Host $output
        }
    }
}

#endregion

#region Функции для создания градиентов

function Get-GradientColor {
    <#
    .SYNOPSIS
        Вычисляет цвет в градиенте между двумя цветами
    
    .PARAMETER StartColor
        Начальный цвет градиента
    
    .PARAMETER EndColor
        Конечный цвет градиента
    
    .PARAMETER Position
        Позиция в градиенте (0.0 - 1.0)
    
    .PARAMETER Steps
        Количество шагов в градиенте (для дискретных градиентов)
    #>

    param(
        [string]$StartColor,
        [string]$EndColor,
        [double]$Position,
        [int]$Steps = 0
    )

    # Конвертируем цвета в RGB
    $start = ConvertTo-RGBComponents -HexColor $StartColor
    $end = ConvertTo-RGBComponents -HexColor $EndColor

    # Если указаны шаги, квантуем позицию
    if ($Steps -gt 0) {
        $Position = [Math]::Floor($Position * $Steps) / $Steps
    }

    # Интерполяция
    $r = [Math]::Round($start.R + ($end.R - $start.R) * $Position)
    $g = [Math]::Round($start.G + ($end.G - $start.G) * $Position)
    $b = [Math]::Round($start.B + ($end.B - $start.B) * $Position)

    # Возвращаем HEX цвет
    return "{0:X2}{1:X2}{2:X2}" -f [int][double]$r, [int][double]$g, [int][double]$b
}

function Get-GradientColorVariant {
    param(
        [string]$StartColor,
        [string]$EndColor,
        [double]$Ratio
    )

    $startR = [Convert]::ToInt32($StartColor.Substring(1, 2), 16)
    $startG = [Convert]::ToInt32($StartColor.Substring(3, 2), 16)
    $startB = [Convert]::ToInt32($StartColor.Substring(5, 2), 16)

    $endR = [Convert]::ToInt32($EndColor.Substring(1, 2), 16)
    $endG = [Convert]::ToInt32($EndColor.Substring(3, 2), 16)
    $endB = [Convert]::ToInt32($EndColor.Substring(5, 2), 16)

    $newR = [int]($startR + ($endR - $startR) * $Ratio)
    $newG = [int]($startG + ($endG - $startG) * $Ratio)
    $newB = [int]($startB + ($endB - $startB) * $Ratio)

    return "#{0:X2}{1:X2}{2:X2}" -f $newR, $newG, $newB
}

function Write-GradientText {
    <#
    .SYNOPSIS
        Выводит текст с градиентом
    
    .PARAMETER Text
        Текст для вывода
    
    .PARAMETER StartColor
        Начальный цвет градиента
    
    .PARAMETER EndColor
        Конечный цвет градиента
    
    .PARAMETER Style
        Стиль текста
    #>

    param(
        [string]$Text,
        [string]$StartColor = "#FF0000",
        [string]$EndColor = "#0000FF",
        [string[]]$Style = 'Normal'
    )

    $chars = $Text.ToCharArray()
    $length = $chars.Length

    for ($i = 0; $i -lt $length; $i++) {
        $position = if ($length -eq 1) { 0.5 } else { $i / ($length - 1) }
        $color = Get-GradientColor -StartColor $StartColor -EndColor $EndColor -Position $position

        Write-RGB -Text $chars[$i] -ForegroundColor $color -Style $Style -NoNewLine
    }

    Write-Host ""  # Перевод строки в конце
}

#endregion

#region Визуальные компоненты - Заголовки

function Show-RGBHeader {
    <#
    .SYNOPSIS
        Отображает красивый заголовок с градиентом и рамкой
    
    .PARAMETER Title
        Текст заголовка
    
    .PARAMETER Width
        Ширина заголовка (по умолчанию авто)
    
    .PARAMETER BorderStyle
        Стиль рамки: Single, Double, Rounded, Heavy, Dashed
    
    .PARAMETER TitleColor
        Цвет заголовка или градиент
    
    .PARAMETER BorderColor
        Цвет рамки
    #>

    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [int]$Width = 0,

        [ValidateSet('Single', 'Double', 'Rounded', 'Heavy', 'Dashed')]
        [string]$BorderStyle = 'Double',

        [hashtable]$TitleColor = @{
        StartColor = "#FF6B6B"
        EndColor = "#4ECDC4"
    },

        [string]$BorderColor = "DeepPurple"
    )

    # Определение символов рамки
    $borders = @{
        'Single'  = @{ TL = "┌"; TR = "┐"; BL = "└"; BR = "┘"; H = "─"; V = "│" }
        'Double'  = @{ TL = "╔"; TR = "╗"; BL = "╚"; BR = "╝"; H = "═"; V = "║" }
        'Rounded' = @{ TL = "╭"; TR = "╮"; BL = "╰"; BR = "╯"; H = "─"; V = "│" }
        'Heavy'   = @{ TL = "┏"; TR = "┓"; BL = "┗"; BR = "┛"; H = "━"; V = "┃" }
        'Dashed'  = @{ TL = "┌"; TR = "┐"; BL = "└"; BR = "┘"; H = "╌"; V = "┆" }
    }

    $border = $borders[$BorderStyle]

    # Вычисление ширины
    if ($Width -eq 0) {
        $Width = $Title.Length + 6
    }
    $Width = [Math]::Max($Width, $Title.Length + 6)

    # Отступы для центрирования
    $padding = [Math]::Max(0, ($Width - $Title.Length - 2) / 2)
    $leftPad = [Math]::Floor($padding)
    $rightPad = [Math]::Ceiling($padding)

    # Верхняя граница
    Write-RGB -Text $border.TL -ForegroundColor $BorderColor -NoNewLine
    Write-RGB -Text ($border.H * ($Width - 2)) -ForegroundColor $BorderColor -NoNewLine
    Write-RGB -Text $border.TR -ForegroundColor $BorderColor

    # Строка с заголовком
    Write-RGB -Text $border.V -ForegroundColor $BorderColor -NoNewLine
    Write-RGB -Text (" " * $leftPad) -NoNewLine

    # Градиентный заголовок
    if ($TitleColor.StartColor -and $TitleColor.EndColor) {
        Write-GradientText -Text $Title -StartColor $TitleColor.StartColor -EndColor $TitleColor.EndColor -Style Bold
        # Курсор уже на новой строке после Write-GradientText
        Write-RGB -Text ("`r" + $border.V + (" " * $leftPad + $Title + " " * $rightPad)) -ForegroundColor $BorderColor -NoNewLine
    } else {
        Write-RGB -Text $Title -ForegroundColor $TitleColor -Style Bold -NoNewLine
        Write-RGB -Text (" " * $rightPad) -NoNewLine
    }

    Write-RGB -Text $border.V -ForegroundColor $BorderColor

    # Нижняя граница
    Write-RGB -Text $border.BL -ForegroundColor $BorderColor -NoNewLine
    Write-RGB -Text ($border.H * ($Width - 2)) -ForegroundColor $BorderColor -NoNewLine
    Write-RGB -Text $border.BR -ForegroundColor $BorderColor
}

#endregion

#region Визуальные компоненты - Прогресс-бары

function Show-RGBProgress {
    <#
    .SYNOPSIS
        Отображает красивый прогресс-бар с градиентом
    
    .PARAMETER Activity
        Описание выполняемой операции
    
    .PARAMETER PercentComplete
        Процент выполнения (0-100)
    
    .PARAMETER Status
        Дополнительный статус
    
    .PARAMETER Width
        Ширина прогресс-бара
    
    .PARAMETER ShowPercentage
        Показывать процент
    
    .PARAMETER BarStyle
        Стиль прогресс-бара
    #>

    param(
        [string]$Activity = "Processing",

        [ValidateRange(0, 100)]
        [int]$PercentComplete = 0,

        [string]$Status = "",

        [int]$Width = 50,

        [switch]$ShowPercentage,

        [ValidateSet('Blocks', 'Gradient', 'Dots', 'Lines')]
        [string]$BarStyle = 'Gradient'
    )

    # Символы для разных стилей
    $styles = @{
        'Blocks'   = @{ Full = "█"; Empty = "░" }
        'Gradient' = @{ Full = "█"; Empty = "░" }
        'Dots'     = @{ Full = "●"; Empty = "○" }
        'Lines'    = @{ Full = "━"; Empty = "╌" }
    }

    $chars = $styles[$BarStyle]
    $filled = [Math]::Floor(($PercentComplete / 100) * $Width)
    $empty = $Width - $filled

    # Вывод активности
    Write-RGB -Text "$Activity " -ForegroundColor "Lavender" -Style Bold -NoNewLine

    if ($Status) {
        Write-RGB -Text "($Status) " -ForegroundColor "PastelYellow" -NoNewLine
    }

    # Открывающая скобка
    Write-RGB -Text "[" -ForegroundColor "Silver" -NoNewLine

    # Прогресс-бар
    if ($BarStyle -eq 'Gradient') {
        for ($i = 0; $i -lt $filled; $i++) {
            $position = $i / $Width
            $color = Get-GradientColor -StartColor "#FF0000" -EndColor "#00FF00" -Position $position
            Write-RGB -Text $chars.Full -ForegroundColor $color -NoNewLine
        }
    } else {
        $progressColor = if ($PercentComplete -lt 33) { "#FF6B6B" }
        elseif ($PercentComplete -lt 66) { "#FFD93D" }
        else { "#6BCF7F" }

        Write-RGB -Text ($chars.Full * $filled) -ForegroundColor $progressColor -NoNewLine
    }

    # Пустая часть
    Write-RGB -Text ($chars.Empty * $empty) -ForegroundColor "#333333" -NoNewLine

    # Закрывающая скобка
    Write-RGB -Text "]" -ForegroundColor "Silver" -NoNewLine

    # Процент
    if ($ShowPercentage) {
        Write-RGB -Text " $PercentComplete%" -ForegroundColor "ElectricBlue" -Style Bold
    } else {
        Write-Host ""
    }
}

#endregion

#region Парсинг текста с RGB правилами

# Глобальные правила для парсинга
$script:RGBParsingRules = @(
    @{
        Name = "Errors"
        Pattern = '\b(ERROR|ОШИБКА|FATAL|КРИТИЧНО|EXCEPTION)\b'
        ForegroundColor = "LaserRed"
        BackgroundColor = "#2C0000"
        Style = @('Bold')
    },
    @{
        Name = "Success"
        Pattern = '\b(SUCCESS|УСПЕШНО|OK|COMPLETE|ГОТОВО)\b'
        ForegroundColor = "LimeGreen"
        Style = @('Bold')
    },
    @{
        Name = "Warnings"
        Pattern = '\b(WARNING|ВНИМАНИЕ|WARN|ПРЕДУПРЕЖДЕНИЕ)\b'
        ForegroundColor = "GoldYellow"
        Style = @('Bold')
    },
    @{
        Name = "Info"
        Pattern = '\b(INFO|ИНФОРМАЦИЯ|СВЕДЕНИЯ|NOTE)\b'
        ForegroundColor = "ElectricBlue"
    },
    @{
        Name = "Timestamps"
        Pattern = '\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}'
        ForegroundColor = "Silver"
    },
    @{
        Name = "IPAddresses"
        Pattern = '\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b'
        ForegroundColor = "Turquoise"
    },
    @{
        Name = "URLs"
        Pattern = 'https?://[^\s]+'
        ForegroundColor = "SkyBlue"
        Style = @('Underline')
    },
    @{
        Name = "Paths"
        Pattern = '(?:[A-Za-z]:)?[\\/](?:[^\\/\s]+[\\/])*[^\\/\s]+'
        ForegroundColor = "PastelGreen"
    }
)

function Out-RGBParsed {
    <#
    .SYNOPSIS
        Парсит и выводит текст с RGB подсветкой согласно правилам
    
    .PARAMETER InputText
        Текст для парсинга
    
    .PARAMETER Rules
        Массив правил парсинга
    
    .PARAMETER PassThru
        Вернуть обработанный текст вместо вывода
    #>

    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$InputText,

        [array]$Rules = $script:RGBParsingRules,

        [switch]$PassThru
    )

    process {
        foreach ($line in $InputText) {
            $segments = @()
            $lastIndex = 0

            # Находим все совпадения
            $matches = @()
            foreach ($rule in $Rules) {
                $regex = [regex]$rule.Pattern
                $regexMatches = $regex.Matches($line)

                foreach ($match in $regexMatches) {
                    $matches += @{
                        Index = $match.Index
                        Length = $match.Length
                        Value = $match.Value
                        Rule = $rule
                    }
                }
            }

            # Сортируем по позиции
            $matches = $matches | Sort-Object Index

            # Обрабатываем совпадения
            foreach ($match in $matches) {
                # Добавляем текст до совпадения
                if ($match.Index -gt $lastIndex) {
                    $segments += @{
                        Text = $line.Substring($lastIndex, $match.Index - $lastIndex)
                        ForegroundColor = "White"
                        Style = @('Normal')
                    }
                }

                # Добавляем совпадение
                $segments += @{
                    Text = $match.Value
                    ForegroundColor = $match.Rule.ForegroundColor
                    BackgroundColor = $match.Rule.BackgroundColor
                    Style = $match.Rule.Style
                }

                $lastIndex = $match.Index + $match.Length
            }

            # Добавляем оставшийся текст
            if ($lastIndex -lt $line.Length) {
                $segments += @{
                    Text = $line.Substring($lastIndex)
                    ForegroundColor = "White"
                    Style = @('Normal')
                }
            }

            # Выводим сегменты
            if ($PassThru) {
                return $segments
            } else {
                foreach ($segment in $segments) {
                    $params = @{
                        Text = $segment.Text
                        ForegroundColor = $segment.ForegroundColor
                        NoNewLine = $true
                    }

                    if ($segment.BackgroundColor) {
                        $params.BackgroundColor = $segment.BackgroundColor
                    }

                    if ($segment.Style) {
                        $params.Style = $segment.Style
                    }

                    Write-RGB @params
                }
                Write-Host ""  # Новая строка
            }
        }
    }
}

#endregion
function Write-Rainbow {
    param([string]$Text)

    $rainbowColors = @("#FF0000", "#FF7F00", "#FFFF00", "#00FF00", "#0000FF", "#4B0082", "#9400D3")
    $chars = $Text.ToCharArray()

    for ($i = 0; $i -lt $chars.Length; $i++) {
        $colorIndex = $i % $rainbowColors.Length
        Write-RGB $chars[$i] -FC $rainbowColors[$colorIndex] -Bold
    }
    Write-Host ""
}

# Функция для создания мигающего RGB текста
function Write-BlinkingRGB {
    param(
        [string]$Text,
        [int]$Times = 5,
        [string]$Color1 = "#FF0080",
        [string]$Color2 = "#00FFFF"
    )

    for ($i = 0; $i -lt $Times; $i++) {
        $color = if ($i % 2 -eq 0) { $Color1 } else { $Color2 }
        Write-RGB $Text -FC $color -Bold
        Start-Sleep -Milliseconds 500
        Write-Host ("`r" + (" " * $Text.Length) + "`r") -NoNewline
    }
}
#region Демонстрация возможностей

function Show-NiceParserDemo {
    <#
    .SYNOPSIS
        Демонстрирует возможности NiceParser
    #>

    Clear-Host

    # Заголовок
    Show-RGBHeader -Title "NICE PARSER RGB DEMO" -BorderStyle Double
    Write-Host ""

    # Градиентный текст
    Write-RGB "Градиентный текст:" -ForegroundColor "Lavender" -Style Bold
    Write-GradientText -Text "PowerShell RGB Paradise!" -StartColor "#FF00FF" -EndColor "#00FFFF"
    Write-Host ""

    # Цветовая палитра
    Write-RGB "Доступные цвета:" -ForegroundColor "Lavender" -Style Bold
    $colorIndex = 0
    foreach ($colorName in $global:RGB.Keys | Select-Object -First 20) {
        Write-RGB "  $colorName " -ForegroundColor $colorName -NoNewLine
        $colorIndex++
        if ($colorIndex % 4 -eq 0) { Write-Host "" }
    }
    Write-Host "`n"

    # Прогресс-бары
    Write-RGB "Примеры прогресс-баров:" -ForegroundColor "Lavender" -Style Bold

    Show-RGBProgress -Activity "Загрузка данных" -PercentComplete 25 -ShowPercentage
    Show-RGBProgress -Activity "Обработка" -PercentComplete 60 -BarStyle Dots -ShowPercentage
    Show-RGBProgress -Activity "Завершение" -PercentComplete 95 -BarStyle Lines -ShowPercentage
    Write-Host ""

    # Парсинг логов
    Write-RGB "Пример парсинга логов:" -ForegroundColor "Lavender" -Style Bold

    $sampleLog = @"
2024-01-15 10:30:15 INFO: Приложение запущено успешно
2024-01-15 10:30:16 SUCCESS: Подключение к базе данных установлено на 192.168.1.100
2024-01-15 10:30:17 INFO: Загрузка конфигурации из C:\Config\app.json
2024-01-15 10:30:18 WARNING: Низкий уровень свободной памяти (15%)
2024-01-15 10:30:19 ERROR: Не удалось подключиться к https://api.example.com
2024-01-15 10:30:20 INFO: Попытка переподключения через 30 секундОШИБКА
2024-01-15 10:30:51 SUCCESS: Переподключение выполнено успешно
"@

    $sampleLog -split "`n" | Out-RGBParsed

    Write-Host "`nНажмите любую клавишу для выхода..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

#endregion

# Экспорт функций
#if ($MyInvocation.MyCommand.Path -match '\.psm1) {
#    Export-ModuleMember -Function @(
#        'Write-RGB',
#        'Write-GradientText',
#        'Get-GradientColor',
#        'Show-RGBHeader',
#        'Show-RGBProgress',
#        'Out-RGBParsed',
#        'Show-NiceParserDemo'
#)


# Алиасы для удобства
Set-Alias -Name wrgb -Value Write-RGB
Set-Alias -Name wgrad -Value Write-GradientText
Set-Alias -Name orgb -Value Out-RGBParsed

Write-RGB "`n✨ NiceParser v2.0 загружен успешно!" -ForegroundColor "ElectricLime" -Style Bold
Write-RGB "Введите " -ForegroundColor "Silver" -NoNewLine
Write-RGB "Show-NiceParserDemo" -ForegroundColor "SkyBlue" -Style @('Bold', 'Underline') -NoNewLine
Write-RGB " для демонстрации возможностей`n" -ForegroundColor "Silver"