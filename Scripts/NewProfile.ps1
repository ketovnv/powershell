# Импорт модулей
Import-Module Parser
Import-Module ColoredText

# Инициализация глобальной палитры RGB цветов
$global:RGB = @{
    "DeepPurple" = "#6A0DAD"
    "OceanBlue" = "#006994"
    "ForestGreen" = "#228B22"
    "SunsetOrange" = "#FF8C00"
    "RoyalPurple" = "#7851A9"
    "ElectricBlue" = "#7DF9FF"
    "LimeGreen" = "#32CD32"
    "HotPink" = "#FF69B4"
    "GoldYellow" = "#FFD700"
    "CrimsonRed" = "#DC143C"
    "TealBlue" = "#008080"
    "Lavender" = "#E6E6FA"
    "Coral" = "#FF7F50"
    "Mint" = "#98FB98"
    "Salmon" = "#FA8072"
}

# Функция для получения RGB цвета
function Get-RGBColor
{
    param([string]$hexColor)
    $r = [Convert]::ToInt32($hexColor.Substring(1, 2), 16)
    $g = [Convert]::ToInt32($hexColor.Substring(3, 2), 16)
    $b = [Convert]::ToInt32($hexColor.Substring(5, 2), 16)
    return $PSStyle.Foreground.FromRgb($r, $g, $b)
}

# Улучшенная функция Write-RGB с поддержкой фона
function Write-RGB
{
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromRemainingArguments = $true)]
        [string[]] $Text,
        [string] $FC = 'White',
        [string] $BC = $null,
        [switch] $newline = $false,
        [switch] $Bold = $false
    )
    $fullText = $Text -join ' '
    $systemColors = @(
        "Black", "DarkBlue", "DarkGreen", "DarkCyan",
        "DarkRed", "DarkMagenta", "DarkYellow", "Gray",
        "DarkGray", "Blue", "Green", "Cyan",
        "Red", "Magenta", "Yellow", "White"
    )

    $output = ""

    # Добавляем жирный шрифт если нужно
    if ($Bold)
    {
        $output += $PSStyle.Bold
    }

    # Обработка цвета переднего плана
    if ($FC -in $systemColors)
    {
        $fgColor = ""
    }
    elseif ($global:RGB.ContainsKey($FC))
    {
        $fgColor = Get-RGBColor $global:RGB[$FC]
        $output += $fgColor
    }
    elseif ($FC -match '^#[0-9A-Fa-f]{6}

# Улучшенная функция для создания красивого заголовка с градиентом
function Show-Header {
    param(
        [string]$Title,
        [string]$StartColor = "#FF6B6B",
        [string]$EndColor = "#4ECDC4"
    )

    $border = "═" * ($Title.Length + 4)

    # Создаем градиент для заголовка
    $titleChars = $Title.ToCharArray()
    $totalChars = $titleChars.Length

    Write-RGB $border -FC "DeepPurple" -newline
    Write-RGB "  " -FC "White" -BC "#2C3E50"

    for ($i = 0; $i -lt $totalChars; $i++) {
        $ratio = if ($totalChars -eq 1) { 0 } else { $i / ($totalChars - 1) }
        $gradientColor = Get-GradientColor $StartColor $EndColor $ratio
        Write-RGB $titleChars[$i] -FC $gradientColor -BC "#2C3E50"
    }

    Write-RGB "  " -FC "White" -BC "#2C3E50" -newline
    Write-RGB $border -FC "DeepPurple" -newline
    Write-Host ""
}

# Функция для создания градиентного цвета
function Get-GradientColor {
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

# Улучшенная функция статуса с RGB поддержкой
function Show-Status {
    param(
        [string]$Message,
        [string]$Status,
        [string]$StatusColor = "Green",
        [string]$Icon = "●"
    )

    $statusColors = @{
        "OK" = "LimeGreen"
        "SUCCESS" = "ForestGreen"
        "РАБОТАЕТ" = "ElectricBlue"
        "НЕДОСТУПЕН" = "CrimsonRed"
        "ОШИБКА" = "#FF4444"
        "ВНИМАНИЕ" = "GoldYellow"
        "WARNING" = "SunsetOrange"
        "ERROR" = "CrimsonRed"
    }

    $iconColor = if ($statusColors.ContainsKey($Status)) { $statusColors[$Status] } else { $StatusColor }

    Write-RGB $Icon -FC $iconColor -Bold
    Write-RGB " [" -FC "Gray"
    Write-RGB $Status -FC $iconColor -Bold
    Write-RGB "] " -FC "Gray"
    Write-RGB $Message -FC "White" -newline
}

# Улучшенная функция прогресс-бара с RGB
function Show-Progress {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Activity = "Обработка",
        [string]$ProgressColor = "#00FF7F",
        [string]$BackgroundColor = "#333333"
    )

    $percent = [math]::Round(($Current / $Total) * 100)
    $barWidth = 40
    $filled = [math]::Floor(($percent / 100) * $barWidth)
    $empty = $barWidth - $filled

    Write-RGB "$Activity (" -FC "Lavender"
    Write-RGB "$Current" -FC "GoldYellow" -Bold
    Write-RGB "/" -FC "Lavender"
    Write-RGB "$Total" -FC "GoldYellow" -Bold
    Write-RGB ") [" -FC "Lavender"

    # Создаем градиентный прогресс-бар
    for ($i = 0; $i -lt $filled; $i++) {
        $ratio = if ($filled -eq 0) { 0 } else { $i / $filled }
        $gradientColor = Get-GradientColor "#FF6B6B" $ProgressColor $ratio
        Write-RGB "█" -FC $gradientColor
    }

    Write-RGB ("░" * $empty) -FC $BackgroundColor
    Write-RGB "] " -FC "Lavender"
    Write-RGB "$percent%" -FC "ElectricBlue" -Bold -newline
}

# Улучшенные правила для парсинга с RGB поддержкой
$logRules = @(
    @{
        Pattern = "ERROR|ОШИБКА|FATAL"
        Action = { param($match) Write-RGB $match -FC "CrimsonRed" -BC "#2C0000" -Bold }
    }
    @{
        Pattern = "SUCCESS|УСПЕШНО|OK"
        Action = { param($match) Write-RGB $match -FC "LimeGreen" -Bold }
    }
    @{
        Pattern = "WARNING|ВНИМАНИЕ|WARN"
        Action = { param($match) Write-RGB $match -FC "GoldYellow" -Bold }
    }
    @{
        Pattern = "INFO|ИНФОРМАЦИЯ"
        Action = { param($match) Write-RGB $match -FC "ElectricBlue" }
    }
    @{
        Pattern = "\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}"
        Action = { param($match) Write-RGB $match -FC "#666666" }
    }
)

# Функция для парсинга с RGB поддержкой
function Parse-TextRGB {
    param(
        [string]$Text,
        [array]$Rules
    )

    $lines = $Text -split "`n"
    foreach ($line in $lines) {
        $processedLine = $line
        $matches = @()

        foreach ($rule in $Rules) {
            if ($processedLine -match $rule.Pattern) {
                $matchInfo = $Matches[0]
                $matches += @{
                    Match = $matchInfo
                    Action = $rule.Action
                    Start = $processedLine.IndexOf($matchInfo)
                    Length = $matchInfo.Length
                }
            }
        }

        if ($matches.Count -gt 0) {
            $sortedMatches = $matches | Sort-Object Start
            $lastIndex = 0

            foreach ($match in $sortedMatches) {
                # Выводим текст до совпадения
                if ($match.Start -gt $lastIndex) {
                    $beforeText = $processedLine.Substring($lastIndex, $match.Start - $lastIndex)
                    Write-RGB $beforeText -FC "White"
                }

                # Выводим совпадение с форматированием
                & $match.Action $match.Match

                $lastIndex = $match.Start + $match.Length
            }

            # Выводим оставшийся текст
            if ($lastIndex -lt $processedLine.Length) {
                $afterText = $processedLine.Substring($lastIndex)
                Write-RGB $afterText -FC "White"
            }
        } else {
            Write-RGB $processedLine -FC "White"
        }

        Write-Host ""
    }
}

# Функция для создания RGB панели
function Show-RGBPanel {
    param(
        [string]$Title,
        [hashtable]$Data,
        [string]$PanelColor = "#2C3E50"
    )

    $maxLength = ($Data.Keys | Measure-Object -Property Length -Maximum).Maximum
    $panelWidth = [math]::Max($maxLength + 20, $Title.Length + 4)

    # Верхняя граница
    Write-RGB "╔" -FC "DeepPurple"
    Write-RGB ("═" * ($panelWidth - 2)) -FC "DeepPurple"
    Write-RGB "╗" -FC "DeepPurple" -newline

    # Заголовок
    $padding = [math]::Floor(($panelWidth - $Title.Length - 2) / 2)
    Write-RGB "║" -FC "DeepPurple"
    Write-RGB (" " * $padding) -FC "White" -BC $PanelColor
    Write-RGB $Title -FC "GoldYellow" -BC $PanelColor -Bold
    Write-RGB (" " * ($panelWidth - $Title.Length - $padding - 2)) -FC "White" -BC $PanelColor
    Write-RGB "║" -FC "DeepPurple" -newline

    # Разделитель
    Write-RGB "╠" -FC "DeepPurple"
    Write-RGB ("═" * ($panelWidth - 2)) -FC "DeepPurple"
    Write-RGB "╣" -FC "DeepPurple" -newline

    # Данные
    foreach ($key in $Data.Keys) {
        $value = $Data[$key]
        $valueColor = switch ($value) {
            { $_ -match "^\d+$" -and [int]$_ -gt 100 } { "CrimsonRed" }
            { $_ -match "^\d+$" -and [int]$_ -gt 50 } { "GoldYellow" }
            { $_ -match "^\d+$" } { "LimeGreen" }
            { $_ -match "ОК|SUCCESS|УСПЕШНО" } { "ForestGreen" }
            { $_ -match "ERROR|ОШИБКА" } { "CrimsonRed" }
            { $_ -match "WARNING|ВНИМАНИЕ" } { "SunsetOrange" }
            default { "ElectricBlue" }
        }

        Write-RGB "║ " -FC "DeepPurple"
        Write-RGB $key -FC "Lavender" -Bold
        Write-RGB ": " -FC "White"
        Write-RGB $value -FC $valueColor -Bold
        $spacesToFill = $panelWidth - $key.Length - $value.Length - 5
        Write-RGB (" " * $spacesToFill) -FC "White"
        Write-RGB "║" -FC "DeepPurple" -newline
    }

    # Нижняя граница
    Write-RGB "╚" -FC "DeepPurple"
    Write-RGB ("═" * ($panelWidth - 2)) -FC "DeepPurple"
    Write-RGB "╝" -FC "DeepPurple" -newline
}

# Главная функция демонстрации с RGB поддержкой
function Start-Demo {
    Clear-Host

    # Показать заголовок с градиентом
    Show-Header "СИСТЕМА МОНИТОРИНГА ПРИЛОЖЕНИЙ" "#FF6B6B" "#4ECDC4"

    # Показать статусы системы с иконками
    Show-Status "Подключение к базе данных" "OK" "Green" "●"
    Show-Status "Статус веб-сервера" "РАБОТАЕТ" "Blue" "▲"
    Show-Status "Доступность API" "НЕДОСТУПЕН" "Red" "✗"
    Show-Status "Уровень памяти" "ВНИМАНИЕ" "Yellow" "⚠"

    Write-Host ""

    # Показать прогресс с градиентом
    Show-Header "ОБРАБОТКА ДАННЫХ" "#9B59B6" "#3498DB"

    for ($i = 1; $i -le 10; $i++) {
        Show-Progress $i 10 "Обработка файлов" "#00FF7F" "#2C3E50"
        Start-Sleep -Milliseconds 300
    }

    Write-Host ""

    # Показать лог с RGB подсветкой
    Show-Header "ЖУРНАЛ СОБЫТИЙ" "#E74C3C" "#F39C12"

    $sampleLog = @"
2024-01-15 10:30:15 INFO: Приложение запущено успешно
2024-01-15 10:30:16 SUCCESS: Подключение к базе данных установлено
2024-01-15 10:30:17 INFO: Загрузка конфигурации
2024-01-15 10:30:18 WARNING: Низкий уровень свободной памяти (15%)
2024-01-15 10:30:19 ERROR: Не удалось подключиться к внешнему API
2024-01-15 10:30:20 INFO: Попытка переподключения через 30 секунд
2024-01-15 10:30:21 SUCCESS: Переподключение к API выполнено успешно
"@

    # Применить RGB правила парсинга к логу
    Parse-TextRGB -Text $sampleLog -Rules $logRules

    Write-Host ""

    # Показать RGB панель со статистикой
    $stats = @{
        "Всего событий" = "156"
        "Успешные операции" = "142"
        "Предупреждения" = "12"
        "Ошибки" = "2"
        "Время работы" = "24:15:32"
        "Использование CPU" = "67%"
    }

    Show-RGBPanel "ИТОГОВАЯ СТАТИСТИКА" $stats "#34495E"

    Write-Host ""

    # Демонстрация цветовой палитры
    Show-Header "ЦВЕТОВАЯ ПАЛИТРА" "#8E44AD" "#2ECC71"

    Write-RGB "Доступные RGB цвета:" -FC "Lavender" -Bold -newline
    $colorCount = 0
    foreach ($colorName in $global:RGB.Keys) {
        Write-RGB "$colorName " -FC $colorName -Bold
        $colorCount++
        if ($colorCount % 4 -eq 0) { Write-Host "" }
    }

    Write-Host ""
    Write-Host ""

    # Демонстрация градиента
    Write-RGB "Градиентный текст: " -FC "White" -Bold
    $gradientText = "КРАСИВЫЙ POWERSHELL"
    $chars = $gradientText.ToCharArray()
    for ($i = 0; $i -lt $chars.Length; $i++) {
        $ratio = if ($chars.Length -eq 1) { 0 } else { $i / ($chars.Length - 1) }
        $color = Get-GradientColor "#FF0080" "#00FFFF" $ratio
        Write-RGB $chars[$i] -FC $color -Bold
    }

    Write-Host ""
    Write-Host ""

    Write-RGB "Нажмите любую клавишу для выхода..." -FC "#666666" -newline
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Дополнительные функции для работы с RGB

# Функция для создания радужного текста
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

# Функция для создания RGB рамки
function Write-RGBBox {
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
    Write-RGB "╗" -FC $BorderColor -newline

    # Содержимое
    foreach ($line in $Content) {
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

# Функция для тестирования Write-RGB
function Test-WriteRGB {
    Write-Host "=== ТЕСТИРОВАНИЕ Write-RGB ===" -ForegroundColor Yellow
    Write-Host ""

    # Тест 1: Стандартные цвета
    Write-Host "1. Стандартные цвета:" -ForegroundColor Cyan
    Write-RGB "Красный текст" -FC Red -newline
    Write-RGB "Зеленый текст" -FC Green -newline
    Write-RGB "Синий текст" -FC Blue -newline
    Write-Host ""

    # Тест 2: HEX цвета
    Write-Host "2. HEX цвета:" -ForegroundColor Cyan
    Write-RGB "Пурпурный #FF00FF" -FC "#FF00FF" -newline
    Write-RGB "Оранжевый #FFA500" -FC "#FFA500" -newline
    Write-RGB "Голубой #00FFFF" -FC "#00FFFF" -newline
    Write-Host ""

    # Тест 3: Именованные RGB цвета
    Write-Host "3. Именованные RGB цвета:" -ForegroundColor Cyan
    Write-RGB "DeepPurple" -FC "DeepPurple" -newline
    Write-RGB "ElectricBlue" -FC "ElectricBlue" -newline
    Write-RGB "ForestGreen" -FC "ForestGreen" -newline
    Write-Host ""

    # Тест 4: Жирный шрифт
    Write-Host "4. Жирный шрифт:" -ForegroundColor Cyan
    Write-RGB "Обычный текст" -FC "White" -newline
    Write-RGB "Жирный текст" -FC "White" -Bold -newline
    Write-RGB "Жирный цветной" -FC "GoldYellow" -Bold -newline
    Write-Host ""

    # Тест 5: Фоновые цвета
    Write-Host "5. Фоновые цвета:" -ForegroundColor Cyan
    Write-RGB "Белый на черном" -FC "White" -BC "#000000" -newline
    Write-RGB "Желтый на синем" -FC "Yellow" -BC "#000080" -newline
    Write-RGB "Зеленый на сером" -FC "LimeGreen" -BC "#404040" -newline
    Write-Host ""

    # Тест 6: Комбинированный вывод
    Write-Host "6. Комбинированный вывод:" -ForegroundColor Cyan
    Write-RGB "Статус: " -FC "Gray"
    Write-RGB "УСПЕШНО" -FC "LimeGreen" -Bold -newline
    Write-RGB "Ошибка: " -FC "Gray"
    Write-RGB "КРИТИЧЕСКАЯ" -FC "CrimsonRed" -BC "#2C0000" -Bold -newline
    Write-Host ""

    Write-Host "=== ТЕСТ ЗАВЕРШЕН ===" -ForegroundColor Yellow
}

# Запуск демонстрации
Start-Demo) {
        $r = [Convert]::ToInt32($FC.Substring(1, 2), 16)
        $g = [Convert]::ToInt32($FC.Substring(3, 2), 16)
        $b = [Convert]::ToInt32($FC.Substring(5, 2), 16)
        $fgColor = $PSStyle.Foreground.FromRgb($r, $g, $b)
        $output += $fgColor
    }

    # Обработка цвета фона
    if ($BC) {
        if ($BC -match '^#[0-9A-Fa-f]{6}

    # Функция для создания красивого заголовка
    function Show-Header
    {
        param([string]$Title)

        $border = "═" * ($Title.Length + 4)

        Write-ColoredText $border -Color Cyan
        Write-ColoredText "  $Title  " -Color White -BackgroundColor DarkBlue
        Write-ColoredText $border -Color Cyan
        Write-Host ""
    }

    # Функция для создания статусного сообщения
    function Show-Status
    {
        param(
            [string]$Message,
            [string]$Status,
            [string]$StatusColor = "Green"
        )

        Write-ColoredText "[" -Color Gray -NoNewline
        Write-ColoredText $Status -Color $StatusColor -NoNewline
        Write-ColoredText "] " -Color Gray -NoNewline
        Write-ColoredText $Message -Color White
    }

    # Функция для создания прогресс-бара
    function Show-Progress
    {
        param(
            [int]$Current,
            [int]$Total,
            [string]$Activity = "Обработка"
        )

        $percent = [math]::Round(($Current / $Total) * 100)
        $barWidth = 50
        $filled = [math]::Floor(($percent / 100) * $barWidth)
        $empty = $barWidth - $filled

        Write-ColoredText "$Activity (" -Color White -NoNewline
        Write-ColoredText "$Current" -Color Yellow -NoNewline
        Write-ColoredText "/" -Color White -NoNewline
        Write-ColoredText "$Total" -Color Yellow -NoNewline
        Write-ColoredText ") [" -Color White -NoNewline
        Write-ColoredText ("█" * $filled) -Color Green -NoNewline
        Write-ColoredText ("░" * $empty) -Color DarkGray -NoNewline
        Write-ColoredText "] " -Color White -NoNewline
        Write-ColoredText "$percent%" -Color Cyan
    }

    # Настройка правил для парсинга логов
    $logRules = @(
        @{
            Pattern = "ERROR|ОШИБКА|FATAL"
            Color = "Red"
            BackgroundColor = "Black"
            Bold = $true
        }
        @{
            Pattern = "SUCCESS|УСПЕШНО|OK"
            Color = "Green"
            Bold = $true
        }
        @{
            Pattern = "WARNING|ВНИМАНИЕ|WARN"
            Color = "Yellow"
            Bold = $true
        }
        @{
            Pattern = "INFO|ИНФОРМАЦИЯ"
            Color = "Cyan"
        }
        @{
            Pattern = "\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}"
            Color = "DarkGray"
        }
    )

    # Главная функция демонстрации
    function Start-Demo
    {
        Clear-Host

        # Показать заголовок
        Show-Header "СИСТЕМА МОНИТОРИНГА ПРИЛОЖЕНИЙ"

        # Показать статусы системы
        Show-Status "Подключение к базе данных" "OK" "Green"
        Show-Status "Статус веб-сервера" "РАБОТАЕТ" "Green"
        Show-Status "Доступность API" "НЕДОСТУПЕН" "Red"
        Show-Status "Уровень памяти" "ВНИМАНИЕ" "Yellow"

        Write-Host ""

        # Показать прогресс
        Show-Header "ОБРАБОТКА ДАННЫХ"

        for ($i = 1; $i -le 10; $i++) {
            Show-Progress $i 10 "Обработка файлов"
            Start-Sleep -Milliseconds 500
        }

        Write-Host ""

        # Показать лог с подсветкой
        Show-Header "ЖУРНАЛ СОБЫТИЙ"

        $sampleLog = @"
2024-01-15 10:30:15 INFO: Приложение запущено успешно
2024-01-15 10:30:16 SUCCESS: Подключение к базе данных установлено
2024-01-15 10:30:17 INFO: Загрузка конфигурации
2024-01-15 10:30:18 WARNING: Низкий уровень свободной памяти (15%)
2024-01-15 10:30:19 ERROR: Не удалось подключиться к внешнему API
2024-01-15 10:30:20 INFO: Попытка переподключения через 30 секунд
2024-01-15 10:30:21 SUCCESS: Переподключение к API выполнено успешно
"@

        # Применить правила парсинга к логу
        Parse-Text -Text $sampleLog -Rules $logRules

        Write-Host ""

        # Показать итоговую информацию
        Show-Header "ИТОГОВАЯ СТАТИСТИКА"

        $stats = @(
            @{ Label = "Всего событий"; Value = "156"; Color = "White" }
            @{ Label = "Успешные операции"; Value = "142"; Color = "Green" }
            @{ Label = "Предупреждения"; Value = "12"; Color = "Yellow" }
            @{ Label = "Ошибки"; Value = "2"; Color = "Red" }
        )

        foreach ($stat in $stats)
        {
            Write-ColoredText ($stat.Label + ": ") -Color Gray -NoNewline
            Write-ColoredText $stat.Value -Color $stat.Color
        }

        Write-Host ""
        Write-ColoredText "Нажмите любую клавишу для выхода..." -Color DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }

    # Запуск демонстрации
    Start-Demo) {
    $r = [Convert]::ToInt32($BC.Substring(1, 2), 16)
    $g = [Convert]::ToInt32($BC.Substring(3, 2), 16)
    $b = [Convert]::ToInt32($BC.Substring(5, 2), 16)
    $bgColor = $PSStyle.Background.FromRgb($r, $g, $b)
    $output += $bgColor
    } elseif ($global: RGB.ContainsKey($BC)) {
    $bgColor = Get-RGBColor $global: RGB[$BC]
    $output += $bgColor.Replace($PSStyle.Foreground.FromRgb, $PSStyle.Background.FromRgb)
    }
}

$output += $fullText + $PSStyle.Reset

if ($FC -in $systemColors -and -not $BC)
{
    Write-Host $fullText -ForegroundColor $FC -NoNewline:(-not $newline)
}
else
{
    Write-Host $output -NoNewline:(-not $newline)
}
}

# Функция для создания красивого заголовка
function Show-Header {
param([string]$Title)

$border = "═" * ($Title.Length + 4)

Write-ColoredText $border -Color Cyan
Write-ColoredText "  $Title  " -Color White -BackgroundColor DarkBlue
Write-ColoredText $border -Color Cyan
Write-Host ""
}

# Функция для создания статусного сообщения
function Show-Status {
param(
[string]$Message,
[string]$Status,
[string]$StatusColor = "Green"
)

Write-ColoredText "[" -Color Gray -NoNewline
Write-ColoredText $Status -Color $StatusColor -NoNewline
Write-ColoredText "] " -Color Gray -NoNewline
Write-ColoredText $Message -Color White
}

# Функция для создания прогресс-бара
function Show-Progress {
param(
[int]$Current,
[int]$Total,
[string]$Activity = "Обработка"
)

$percent = [math]::Round(($Current / $Total) * 100)
$barWidth = 50
$filled = [math]::Floor(($percent / 100) * $barWidth)
$empty = $barWidth - $filled

Write-ColoredText "$Activity (" -Color White -NoNewline
Write-ColoredText "$Current" -Color Yellow -NoNewline
Write-ColoredText "/" -Color White -NoNewline
Write-ColoredText "$Total" -Color Yellow -NoNewline
Write-ColoredText ") [" -Color White -NoNewline
Write-ColoredText ("█" * $filled) -Color Green -NoNewline
Write-ColoredText ("░" * $empty) -Color DarkGray -NoNewline
Write-ColoredText "] " -Color White -NoNewline
Write-ColoredText "$percent%" -Color Cyan
}

# Настройка правил для парсинга логов
$logRules = @(
@{
Pattern = "ERROR|ОШИБКА|FATAL"
Color = "Red"
BackgroundColor = "Black"
Bold = $true
}
@{
Pattern = "SUCCESS|УСПЕШНО|OK"
Color = "Green"
Bold = $true
}
@{
Pattern = "WARNING|ВНИМАНИЕ|WARN"
Color = "Yellow"
Bold = $true
}
@{
Pattern = "INFO|ИНФОРМАЦИЯ"
Color = "Cyan"
}
@{
Pattern = "\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}"
Color = "DarkGray"
}
)

# Главная функция демонстрации
function Start-Demo {
Clear-Host

# Показать заголовок
Show-Header "СИСТЕМА МОНИТОРИНГА ПРИЛОЖЕНИЙ"

# Показать статусы системы
Show-Status "Подключение к базе данных" "OK" "Green"
Show-Status "Статус веб-сервера" "РАБОТАЕТ" "Green"
Show-Status "Доступность API" "НЕДОСТУПЕН" "Red"
Show-Status "Уровень памяти" "ВНИМАНИЕ" "Yellow"

Write-Host ""

# Показать прогресс
Show-Header "ОБРАБОТКА ДАННЫХ"

for ($i = 1; $i -le 10; $i++) {
Show-Progress $i 10 "Обработка файлов"
Start-Sleep -Milliseconds 500
}

Write-Host ""

# Показать лог с подсветкой
Show-Header "ЖУРНАЛ СОБЫТИЙ"

$sampleLog = @"
2024-01-15 10:30:15 INFO: Приложение запущено успешно
2024-01-15 10:30:16 SUCCESS: Подключение к базе данных установлено
2024-01-15 10:30:17 INFO: Загрузка конфигурации
2024-01-15 10:30:18 WARNING: Низкий уровень свободной памяти (15%)
2024-01-15 10:30:19 ERROR: Не удалось подключиться к внешнему API
2024-01-15 10:30:20 INFO: Попытка переподключения через 30 секунд
2024-01-15 10:30:21 SUCCESS: Переподключение к API выполнено успешно
"@

# Применить правила парсинга к логу
Parse-Text -Text $sampleLog -Rules $logRules

Write-Host ""

# Показать итоговую информацию
Show-Header "ИТОГОВАЯ СТАТИСТИКА"

$stats = @(
@{
Label = "Всего событий"; Value = "156"; Color = "White"
}
@{
Label = "Успешные операции"; Value = "142"; Color = "Green"
}
@{
Label = "Предупреждения"; Value = "12"; Color = "Yellow"
}
@{
Label = "Ошибки"; Value = "2"; Color = "Red"
}
)

foreach ($stat in $stats) {
Write-ColoredText ($stat.Label + ": ") -Color Gray -NoNewline
Write-ColoredText $stat.Value -Color $stat.Color
}

Write-Host ""
Write-ColoredText "Нажмите любую клавишу для выхода..." -Color DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Запуск демонстрации
Start-Demo