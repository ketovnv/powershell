# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                       🎨 NICE PARSER v2.1 - RGB Edition                    ║
# ║                     Enhanced PowerShell Text Parser                         ║
# ║                         With Full RGB Support 🌈                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

#region Инициализация и зависимости

# Проверка и импорт необходимых модулей
$requiredModules = @('Parser', 'ColoredText')
foreach ($module in $requiredModules)
{
    if (-not (Get-Module -ListAvailable -Name $module))
    {
        Write-Warning "Модуль $module не найден. Установите: Install-Module $module"
    }
    else
    {
        Import-Module $module -ErrorAction SilentlyContinue
    }
}

# Импорт цветов
            . (Join-Path $PSScriptRoot 'NiceColors.ps1')
#endregion

if (-not $global:RGB)
{
    $global:RGB = @{ }
}


# Функция для получения цвета (совместимость со старым кодом)


#endregion

#region Визуальные компоненты - Заголовки

function Show-RGBHeader
{
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
        'Single' = @{ TL = "┌"; TR = "┐"; BL = "└"; BR = "┘"; H = "─"; V = "│" }
        'Double' = @{ TL = "╔"; TR = "╗"; BL = "╚"; BR = "╝"; H = "═"; V = "║" }
        'Rounded' = @{ TL = "╭"; TR = "╮"; BL = "╰"; BR = "╯"; H = "─"; V = "│" }
        'Heavy' = @{ TL = "┏"; TR = "┓"; BL = "┗"; BR = "┛"; H = "━"; V = "┃" }
        'Dashed' = @{ TL = "┌"; TR = "┐"; BL = "└"; BR = "┘"; H = "╌"; V = "┆" }
    }

    $border = $borders[$BorderStyle]

    # Вычисление ширины
    if ($Width -eq 0)
    {
        $Width = $Title.Length + 6
    }
    $Width = [Math]::Max($Width, $Title.Length + 6)

    # Отступы для центрирования
    $padding = [Math]::Max(0, ($Width - $Title.Length - 2) / 2)
    $leftPad = [Math]::Floor($padding)
    $rightPad = [Math]::Ceiling($padding)

    # Верхняя граница
    Write-RGB -Text $border.TL -FC $BorderColor
    Write-RGB -Text ($border.H * ($Width - 2)) -FC $BorderColor
    Write-RGB -Text $border.TR -FC $BorderColor

    # Строка с заголовком
    Write-RGB -Text $border.V -FC $BorderColor
    Write-RGB -Text (" " * $leftPad)

    # Градиентный заголовок
    if ($TitleColor.StartColor -and $TitleColor.EndColor)
    {
        # Сохраняем текущую позицию
        $currentY = $Host.UI.RawUI.CursorPosition.Y

        # Выводим градиентный заголовок
#

        # Возвращаемся на ту же строку
        $Host.UI.RawUI.CursorPosition = @{X = 0; Y = $currentY}

        # Перерисовываем всю строку правильно
        Write-RGB -Text $border.V -FC $BorderColor
        Write-RGB -Text (" " * $leftPad)
        Write-GradientText -Text $Title -StartColor $TitleColor.StartColor -EndColor $TitleColor.EndColor
#        Write-RGB -Text $Title -FC "#1177FF"
        Write-RGB -Text (" " * $rightPad)
    }
    else
    {
        $titleColorName = if ($TitleColor -is [string])
        {
            $TitleColor
        }
        else
        {
            "White"
        }
        Write-RGB -Text $Title -FC $titleColorName -Style Bold
        Write-RGB -Text (" " * $rightPad)
    }

    Write-RGB -Text $border.V -FC $BorderColor -newline

    # Нижняя граница
    Write-RGB -Text $border.BL -FC $BorderColor
    Write-RGB -Text ($border.H * ($Width - 2)) -FC $BorderColor
    Write-RGB -Text $border.BR -FC $BorderColor -newline
}

# Альтернативная функция для простых заголовков (совместимость)
function Show-Header
{
    param(
        [string]$Title,
        [string]$StartColor = "#FF6B6B",
        [string]$EndColor = "#4ECDC4"
    )

    Show-RGBHeader -Title $Title -TitleColor @{
        StartColor = $StartColor
        EndColor = $EndColor
    }
}

#endregion

#region Визуальные компоненты - Прогресс-бары

function Show-RGBProgress
{
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

        [int]$Width = 30,

        [switch]$ShowPercentage,

        [ValidateSet('Blocks', 'Gradient', 'Dots', 'Lines')]
        [string]$BarStyle = 'Gradient'
    )

    # Символы для разных стилей
    $styles = @{
        'Blocks' = @{ Full = "█"; Empty = "░" }
        'Gradient' = @{ Full = "█"; Empty = "░" }
        'Dots' = @{ Full = "●"; Empty = "○" }
        'Lines' = @{ Full = "━"; Empty = "╌" }
    }

    $chars = $styles[$BarStyle]
    $filled = [Math]::Floor(($PercentComplete / 100) * $Width)
    $empty = $Width - $filled

    # Вывод активности
    Write-RGB -Text "$Activity " -FC "Lavender" -Style Bold -newline

    if ($Status)
    {
        Write-RGB -Text "($Status) " -FC "PastelYellow"
    }

    # Открывающая скобка
    Write-RGB -Text "[" -FC "Silver"

    # Прогресс-бар
    if ($BarStyle -eq 'Gradient')
    {
        for ($i = 0; $i -lt $filled; $i++) {
            $position = $i / $Width
            $color = Get-GradientColor -StartColor "#FF0000" -EndColor "#00FF00" -Position $position
            Write-RGB -Text $chars.Full -FC $color
        }
    }
    else
    {
        $progressColor = if ($PercentComplete -lt 33)
        {
            "#FF6B6B"
        }
        elseif ($PercentComplete -lt 66)
        {
            "#FFD93D"
        }
        else
        {
            "#6BCF7F"
        }

        Write-RGB -Text ($chars.Full * $filled) -FC $progressColor
    }

    # Пустая часть
    Write-RGB -Text ($chars.Empty * $empty) -FC "#333333" -newline

    # Закрывающая скобка
    Write-RGB -Text "]" -FC "Silver" -newline

    # Процент
    if ($ShowPercentage)
    {
        Write-RGB -Text " $PercentComplete%" -FC "ElectricBlue" -Style Bold
    }
    else
    {
        Write-Host ""
    }

    # Дополнительное сообщение о завершении
    if ($PercentComplete -eq 100)
    {
        Write-RGB "✅ Complete!" -FC "LimeGreen" -Style Bold
    }
}

# Совместимость со старым кодом
function Show-Progress
{
    param(
        [int]$Current,
        [int]$Total,
        [string]$Activity = "Обработка",
        [string]$ProgressColor = "#00FF7F",
        [string]$BC = "#333333"
    )

    $percent = if ($Total -gt 0)
    {
        [Math]::Round(($Current / $Total) * 100)
    }
    else
    {
        0
    }
    Show-RGBProgress -Activity $Activity -PercentComplete $percent -ShowPercentage
}

#endregion

#region Парсинг текста с RGB правилами

# Глобальные правила для парсинга
$script:RGBParsingRules = @(
    @{
        Name = "Errors"
        Pattern = '\b(ERROR|ОШИБКА|FATAL|КРИТИЧНО|EXCEPTION)\b'
        FC = "LaserRed"
        BC = "#2C0000"
        Style = @('Bold')
    },
    @{
        Name = "Success"
        Pattern = '\b(SUCCESS|УСПЕШНО|OK|COMPLETE|ГОТОВО)\b'
        FC = "LimeGreen"
        Style = @('Bold')
    },
    @{
        Name = "Warnings"
        Pattern = '\b(WARNING|ВНИМАНИЕ|WARN|ПРЕДУПРЕЖДЕНИЕ)\b'
        FC = "GoldYellow"
        Style = @('Bold')
    },
    @{
        Name = "Info"
        Pattern = '\b(INFO|ИНФОРМАЦИЯ|СВЕДЕНИЯ|NOTE)\b'
        FC = "ElectricBlue"
    },
    @{
        Name = "Timestamps"
        Pattern = '\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}'
        FC = "Silver"
    },
    @{
        Name = "IPAddresses"
        Pattern = '\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b'
        FC = "Turquoise"
    },
    @{
        Name = "URLs"
        Pattern = 'https?://[^\s]+'
        FC = "SkyBlue"
        Style = @('Underline')
    },
    @{
        Name = "Paths"
        Pattern = '(?:[A-Za-z]:)?[\\/](?:[^\\/\s]+[\\/])*[^\\/\s]+'
        FC = "PastelGreen"
    }
)

function Out-RGBParsed
{
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
        foreach ($line in $InputText)
        {
            $segments = @()
            $lastIndex = 0

            # Находим все совпадения
            $matches = @()
            foreach ($rule in $Rules)
            {
                $regex = [regex]$rule.Pattern
                $regexMatches = $regex.Matches($line)

                foreach ($match in $regexMatches)
                {
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
            foreach ($match in $matches)
            {
                # Добавляем текст до совпадения
                if ($match.Index -gt $lastIndex)
                {
                    $segments += @{
                        Text = $line.Substring($lastIndex, $match.Index - $lastIndex)
                        FC = "White"
                        Style = @('Normal')
                    }
                }

                # Добавляем совпадение
                $segments += @{
                    Text = $match.Value
                    FC = $match.Rule.FC
                    BC = $match.Rule.BC
                    Style = $match.Rule.Style
                }

                $lastIndex = $match.Index + $match.Length
            }

            # Добавляем оставшийся текст
            if ($lastIndex -lt $line.Length)
            {
                $segments += @{
                    Text = $line.Substring($lastIndex)
                    FC = "White"
                    Style = @('Normal')
                }
            }

            # Выводим сегменты
            if ($PassThru)
            {
                return $segments
            }
            else
            {
                foreach ($segment in $segments)
                {
                    $params = @{
                        Text = $segment.Text
                        FC = $segment.FC
                        newline = $false
                    }

                    if ($segment.BC)
                    {
                        $params.BC = $segment.BC
                    }

                    if ($segment.Style)
                    {
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

#region Дополнительные визуальные эффекты

# Функция для создания радужного текста
function Write-Rainbow
{
    param([string]$Text)

    $rainbowColors = @("#FF0000", "#FF7F00", "#FFFF00", "#00FF00", "#0000FF", "#4B0082", "#9400D3")
    $chars = $Text.ToCharArray()

    for ($i = 0; $i -lt $chars.Length; $i++) {
        $colorIndex = $i % $rainbowColors.Length
        Write-RGB $chars[$i] -FC $rainbowColors[$colorIndex] -Bold -NoNewLine
    }
    Write-Host ""
}

# Функция для создания мигающего RGB текста
function Write-BlinkingRGB
{
    param(
        [string]$Text,
        [int]$Times = 5,
        [string]$Color1 = "#FF0080",
        [string]$Color2 = "#00FFFF"
    )

    for ($i = 0; $i -lt $Times; $i++) {
        $color = if ($i % 2 -eq 0)
        {
            $Color1
        }
        else
        {
            $Color2
        }
        Write-RGB $Text -FC $color -Bold
        Start-Sleep -Milliseconds 500
        Write-Host ("`r" + (" " * $Text.Length) + "`r") -NoNewline
    }
}

# Функция для создания RGB рамки
function Write-RGBBox
{
    param(
        [string[]]$Content,
        [string]$BorderColor = "#00FFFF",
        [string]$TextColor = "#FFFFFF"
    )

    $maxLength = ($Content | Measure-Object -Property Length -Maximum).Maximum
    $boxWidth = $maxLength + 4

    # Верхняя граница
    Write-RGB "╔" -FC $BorderColor
    Write-RGB ("═" * ($boxWidth - 2)) -FC $BorderColor
    Write-RGB "╗" -FC $BorderColor

    # Содержимое
    foreach ($line in $Content)
    {
        $padding = $boxWidth - $line.Length - 3
        Write-RGB "║ " -FC $BorderColor
        Write-RGB $line -FC $TextColor
        Write-RGB (" " * $padding) -FC $TextColor
        Write-RGB "║" -FC $BorderColor -newline
    }

    # Нижняя граница
    Write-RGB "╚" -FC $BorderColor
    Write-RGB ("═" * ($boxWidth - 2)) -FC $BorderColor
    Write-RGB "╝" -FC $BorderColor -newline
}

#endregion

#region Демонстрация возможностей

function Show-NiceParserDemo
{
    <#
    .SYNOPSIS
        Демонстрирует возможности NiceParser
    #>

    Clear-Host

    # Заголовок
    Show-RGBHeader -Title "NICE PARSER RGB DEMO" -BorderStyle Double
    Write-Host ""

    # Градиентный текст
    Write-RGB "Градиентный текст:" -FC "SeaGreen" -Style Bold -newline
    Write-GradientText -Text "PowerShell RGB Paradise!" -StartColor "#FF00FF" -EndColor "#00FFFF"
    Write-Host ""

    # Цветовая палитра
    Write-RGB "Доступные цвета:" -FC "SeaGreen" -Style Bold -newline
    showColors

    # Прогресс-бары
    Write-RGB "Примеры прогресс-баров:" -FC "Lavender" -Style Bold

    Show-RGBProgress -Activity "Загрузка данных" -PercentComplete 25 -ShowPercentage
    Show-RGBProgress -Activity "Обработка" -PercentComplete 60 -BarStyle Dots -ShowPercentage
    Show-RGBProgress -Activity "Завершение" -PercentComplete 100 -BarStyle Lines -ShowPercentage
    Write-Host ""

    # Парсинг логов
    Write-RGB "Пример парсинга логов:" -FC "SeaGreen" -Style Bold

    $sampleLog = @"
2024-01-15 10:30:15 INFO: Приложение запущено успешно
2024-01-15 10:30:16 SUCCESS: Подключение к базе данных установлено на 192.168.1.100
2024-01-15 10:30:17 INFO: Загрузка конфигурации из C:\Config\app.json
2024-01-15 10:30:18 WARNING: Низкий уровень свободной памяти (15%)
2024-01-15 10:30:19 ERROR: Не удалось подключиться к https://api.example.com
2024-01-15 10:30:20 INFO: Попытка переподключения через 30 секунд
2024-01-15 10:30:51 SUCCESS: Переподключение выполнено успешно
"@

    $sampleLog -split "`n" | Out-RGBParsed

    Write-Host "`nНажмите любую клавишу для выхода..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

#endregion

# Экспорт функций (если используется как модуль)
if ($MyInvocation.MyCommand.Path -match '\.psm1$')
{
    Export-ModuleMember -Function @(
        'Write-RGB',
        'Write-GradientText',
        'Get-GradientColor',
        'Show-RGBHeader',
        'Show-Header',
        'Show-RGBProgress',
        'Show-Progress',
        'Out-RGBParsed',
        'Write-Rainbow',
        'Write-BlinkingRGB',
        'Write-RGBBox',
        'Show-NiceParserDemo'
    )
}

# Алиасы для удобства
Set-Alias -Name wrgb -Value Write-RGB -Scope Global -Force
Set-Alias -Name wgrad -Value Write-GradientText -Scope Global -Force
Set-Alias -Name orgb -Value Out-RGBParsed -Scope Global -Force

# Сообщение о загрузке
#Write-RGB "`n✨ NiceParser v2.1 загружен успешно!" -FC "ElectricLime" -Style Bold
#Write-RGB "Введите " -FC "Silver" -NoNewLine
#Write-RGB "Show-NiceParserDemo" -FC "SkyBlue" -Style @('Bold', 'Underline') -NoNewLine
#Write-RGB " для демонстрации возможностей`n" -FC "Silver"