
importProcess  $MyInvocation.MyCommand.Name.trim(".ps1") -start

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                   🌈 ENHANCED RAINBOW & INTEGRATION                         ║
# ║                 Объединение всех систем парсинга и эффектов                ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#region Улучшенная функция Rainbow
function Write-Rainbow {
    <#
    .SYNOPSIS
        Создает радужный текст с различными режимами и эффектами

    .DESCRIPTION
        Продвинутая функция для создания радужных эффектов с поддержкой
        анимации, различных палитр и режимов применения

    .PARAMETER Text
        Текст для радужного отображения

    .PARAMETER Mode
        Режим применения: Char (по символам), Word (по словам), Line (построчно)

    .PARAMETER Palette
        Палитра цветов или предустановленный стиль

    .PARAMETER Speed
        Скорость анимации (если включена)

    .PARAMETER Reverse
        Обратный порядок цветов

    .PARAMETER Wave
        Волновой эффект

    .EXAMPLE
        "Hello World" | Write-Rainbow

    .EXAMPLE
        Write-Rainbow -Text "PowerShell Rocks!" -Mode Word -Palette Fire -Animated
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string]$Text,

        [ValidateSet("Char", "Word", "Line", "Gradient", "Wave")]
        [string]$Mode = "Char",

        [string[]]$Palette,

        [ValidateSet("Rainbow", "Fire", "Ocean", "Forest", "Sunset", "Neon", "Pastel", "Ukraine", "Custom")]
        [string]$Style = "Rainbow",

        [switch]$Bold,
        [switch]$Italic,
        [switch]$Animated,

        [int]$Speed = 50,
        [switch]$Reverse,
        [switch]$Loop,
        [int]$LoopCount = 1,

        [switch]$Wave,
        [double]$WaveAmplitude = 0.5,
        [double]$WaveFrequency = 0.2
    )

    begin {
        # Предустановленные палитры
        $palettes = @{
            Rainbow = @("#FF0000", "#FF7F00", "#FFFF00", "#00FF00", "#0000FF", "#4B0082", "#9400D3")
            Fire = @("#8B0000", "#FF0000", "#FF4500", "#FFA500", "#FFD700", "#FFFF00", "#FFFACD")
            Ocean = @("#000080", "#0000CD", "#0000FF", "#0080FF", "#00BFFF", "#00CED1", "#00FFFF")
            Forest = @("#013220", "#228B22", "#32CD32", "#00FF00", "#7CFC00", "#ADFF2F", "#9ACD32")
            Sunset = @("#FF1744", "#FF6E40", "#FF9100", "#FFC400", "#FFD740", "#FFE57F")
            Neon = @("#FF00FF", "#FF00AA", "#FF0080", "#FF0040", "#FF0000", "#FF4000", "#FF8000", "#FFFF00")
            Pastel = @("#FFB3BA", "#FFDFBA", "#FFFFBA", "#BAFFC9", "#BAE1FF", "#E0BBE4", "#FFDFD3")
            Ukraine = @("#0057B7", "#0057B7", "#FFD500", "#FFD500")
        }




        # Выбираем палитру
        if ($Style -eq "Custom" -and $Palette) {
            $colors = $Palette
        } else {
            $colors = $palettes[$Style]
        }

        if ($Reverse) {
            [array]::Reverse($colors)
        }

        $index = 0
        $styles = @()
        if ($Bold) { $styles += 'Bold' }
        if ($Italic) { $styles += 'Italic' }
        if ($styles.Count -eq 0) { $styles = @('Normal') }
    }

    process {
        if (-not $Text) { return }

        if ($Animated) {
            # Анимированный режим
            for ($loop = 0; $loop -lt $(if ($Loop) { $LoopCount } else { 1 }); $loop++) {
                for ($shift = 0; $shift -lt $colors.Count; $shift++) {
                    # Сохраняем позицию курсора
                    $pos = $Host.UI.RawUI.CursorPosition

                    switch ($Mode) {
                        "Char" {
                            $chars = $Text.ToCharArray()
                            for ($i = 0; $i -lt $chars.Length; $i++) {
                                $colorIndex = ($i + $shift) % $colors.Length

                                if ($Wave) {
                                    # Волновой эффект
                                    $waveOffset = [Math]::Sin($i * $WaveFrequency + $shift * 0.5) * $WaveAmplitude
                                    $colorIndex = [Math]::Abs([int](($colorIndex + $waveOffset * $colors.Length) % $colors.Length))
                                }

                                wrgb $chars[$i] -FC $colors[$colorIndex] -Style $styles
                            }
                        }

                        "Word" {
                            $words = $Text -split '\s+'
                            for ($i = 0; $i -lt $words.Length; $i++) {
                                $colorIndex = ($i + $shift) % $colors.Length
                                wrgb "$($words[$i]) " -FC $colors[$colorIndex] -Style $styles
                            }
                        }
                    }

                    Start-Sleep -Milliseconds $Speed

                    # Возвращаемся к началу строки
                    $Host.UI.RawUI.CursorPosition = $pos
                }
            }

            # Финальный вывод
            $shift = 0
        }

        # Статичный вывод
        switch ($Mode) {
            "Char" {
                $chars = $Text.ToCharArray()
                foreach ($char in $chars) {
                    $color = $colors[$index % $colors.Length]
                    wrgb $char -FC $color -Style $styles
                    $index++
                }
                Write-Host ""
            }

            "Word" {
                $words = $Text -split '\s+'
                foreach ($word in $words) {
                    $color = $colors[$index % $colors.Length]
                    wrgb "$word " -FC $color -Style $styles
                    $index++
                }
                Write-Host ""
            }

            "Line" {
                $color = $colors[$index % $colors.Length]
                wrgb $Text -FC $color -Style $styles -newline
                $index++
            }

            "Gradient" {
                # Градиентный режим между цветами палитры
                $length = $Text.Length
                $chars = $Text.ToCharArray()

                for ($i = 0; $i -lt $length; $i++) {
                    $progress = $i / [Math]::Max(1, $length - 1)
                    $paletteProgress = $progress * ($colors.Length - 1)
                    $colorIndex = [Math]::Floor($paletteProgress)
                    $localProgress = $paletteProgress - $colorIndex

                    $startColor = $colors[[Math]::Min($colorIndex, $colors.Length - 1)]
                    $endColor = $colors[[Math]::Min($colorIndex + 1, $colors.Length - 1)]

                    $color = Get-GradientColor -Position $localProgress `
                                              -StartColor $startColor `
                                              -EndColor $endColor

                    wrgb $chars[$i] -FC $color -Style $styles
                }
                Write-Host ""
            }

            "Wave" {
                # Волновой режим
                $chars = $Text.ToCharArray()
                for ($i = 0; $i -lt $chars.Length; $i++) {
                    $wave = [Math]::Sin($i * $WaveFrequency) * 0.5 + 0.5
                    $colorIndex = [int]($wave * ($colors.Length - 1))
                    $color = $colors[$colorIndex]
                    wrgb $chars[$i] -FC $color -Style $styles
                }
                Write-Host ""
            }
        }
    }
}
#endregion

#region Интеграция с файловой системой
function Watch-ParsedFile {
    <#
    .SYNOPSIS
        Следит за изменениями файла и автоматически перепарсит его
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [int]$RefreshInterval = 1000,

        [string]$Type = 'Auto'
    )

    if (-not (Test-Path $Path)) {
        Write-Status -Error "Файл не найден: $Path"
        return
    }

    Write-Status -Info "Отслеживание файла: $Path"
    wrgb "Нажмите Ctrl+C для остановки" -FC "DarkGray" -newline

    $lastWriteTime = (Get-Item $Path).LastWriteTime

    try {
        while ($true) {
            $currentWriteTime = (Get-Item $Path -ErrorAction SilentlyContinue).LastWriteTime

            if ($currentWriteTime -ne $lastWriteTime) {
#                Clear-Host
                Write-Status -Info "Файл изменен, обновление..."
                Out-ParsedFile -Path $Path -Type $Type -ShowLineNumbers
                $lastWriteTime = $currentWriteTime
            }

            Start-Sleep -Milliseconds $RefreshInterval
        }
    } catch {
        Write-Status -Warning "Мониторинг остановлен"
    }
}

function Compare-ParsedFiles {
    <#
    .SYNOPSIS
        Сравнивает два файла с подсветкой различий
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path1,

        [Parameter(Mandatory)]
        [string]$Path2,

        [switch]$SideBySide
    )

    if (-not (Test-Path $Path1) -or -not (Test-Path $Path2)) {
        Write-Status -Error "Один или оба файла не найдены"
        return
    }

    $content1 = Get-Content $Path1
    $content2 = Get-Content $Path2

    $diff = Compare-Object $content1 $content2 -IncludeEqual

    Write-GradientHeader -Title "FILE COMPARISON" -StartColor "#FF6B6B" -EndColor "#4ECDC4"

    wrgb "📄 Файл 1: " -FC "Cyan"
    wrgb $Path1 -FC "White" -newline
    wrgb "📄 Файл 2: " -FC "Cyan"
    wrgb $Path2 -FC "White" -newline
    wrgb "" -newline

    foreach ($line in $diff) {
        switch ($line.SideIndicator) {
            '<=' {
                wrgb "- " -FC "Red" -Style Bold
                wrgb $line.InputObject -FC "Material_Red" -newline
            }
            '=>' {
                wrgb "+ " -FC "Green" -Style Bold
                wrgb $line.InputObject -FC "Material_Green" -newline
            }
            '==' {
                wrgb "  " -FC "Gray"
                wrgb $line.InputObject -FC "DarkGray" -newline
            }
        }
    }
}
#endregion

#region Продвинутый Pipeline парсинг
function ConvertTo-ParsedOutput {
    <#
    .SYNOPSIS
        Конвертирует вывод любой команды в парсированный цветной вывод

    .EXAMPLE
        Get-Process | ConvertTo-ParsedOutput
        Get-Service | ConvertTo-ParsedOutput -HighlightProperty Status
    #>
    param(
        [Parameter(ValueFromPipeline)]
        $InputObject,

        [string]$HighlightProperty,

        [hashtable]$ColorMap = @{
        Running = "LimeGreen"
        Stopped = "Red"
        True = "Green"
        False = "Red"
    },

        [switch]$ShowType
    )

    process {
        if ($InputObject -is [string]) {
            $InputObject | Out-ParsedText
        } else {
            # Форматируем объект
            $props = $InputObject.PSObject.Properties

            if ($ShowType) {
                wrgb "[$($InputObject.GetType().Name)]" -FC "DarkCyan" -newline
            }

            foreach ($prop in $props) {
                wrgb "$($prop.Name): " -FC "Material_Purple" -Style Bold

                $value = $prop.Value
                $valueStr = if ($null -eq $value) { "<null>" } else { $value.ToString() }

                # Определяем цвет
                $color = "White"
                if ($prop.Name -eq $HighlightProperty -or $ColorMap.ContainsKey($valueStr)) {
                    $color = $ColorMap[$valueStr] ?? "Yellow"
                }

                # Специальная обработка для разных типов
                switch ($prop.TypeNameOfValue) {
                    { $_ -match 'DateTime' } { $color = "Material_Cyan" }
                    { $_ -match 'Int|Long|Double' } { $color = "Material_Pink" }
                    { $_ -match 'Bool' } { $color = if ($value) { "LimeGreen" } else { "Red" } }
                }

                wrgb $valueStr -FC $color -newline
            }

            wrgb "" -newline
        }
    }
}

# Pipeline-friendly версия парсера
filter Parse {
    param(
        [string]$Type = 'Auto'
    )

    $_ | Out-ParsedText -Type $Type
}
#endregion

#region Мега-демонстрация всех возможностей
function Show-MegaParserDemo {
#    Clear-Host

    # Заголовок с анимацией
    $title = "MEGA PARSER DEMONSTRATION"
    Write-Rainbow -Text $title -Mode Gradient -Style Neon -Animated -Speed 30

    wrgb "`n🚀 Добро пожаловать в мир продвинутого парсинга!" -FC "GoldRGB" -Style Bold -newline

    # Меню демонстраций
    $demos = @(
        "🌈 Rainbow эффекты и анимации"
        "📊 Прогресс-бары всех видов"
        "📝 Интеллектуальный парсинг текста"
        "📁 Парсинг файлов с автоопределением"
        "🔍 Интерактивный режим парсера"
        "⚡ Pipeline интеграция"
        "🎨 Все вместе - комбо демо"
        "❌ Выход"
    )

    do {
        wrgb "`nВыберите демонстрацию:" -FC "Cyan" -Style Bold -newline

        for ($i = 0; $i -lt $demos.Length; $i++) {
            $color = Get-MenuGradientColor -Index $i -Total $demos.Length -Style Ocean
            wrgb "  [$($i + 1)] " -FC "White"
            wrgb $demos[$i] -FC $color -newline
        }

        wrgb "`nВаш выбор: " -FC "Yellow"
        $choice = Read-Host

        switch ($choice) {
            "1" {
                # Rainbow демо
#                Clear-Host
                Write-GradientHeader -Title "RAINBOW EFFECTS"

                wrgb "`nБазовый Rainbow:" -FC "Cyan" -newline
                "Hello, PowerShell World!" | Write-Rainbow

                wrgb "`nRainbow по словам:" -FC "Cyan" -newline
                "The quick brown fox jumps over the lazy dog" | Write-Rainbow -Mode Word -Bold

                wrgb "`nГрадиентный Rainbow:" -FC "Cyan" -newline
                "Gradient Rainbow Effect" | Write-Rainbow -Mode Gradient -Style Fire

                wrgb "`nВолновой эффект:" -FC "Cyan" -newline
                "~~~~ Wave Effect Demo ~~~~" | Write-Rainbow -Mode Wave -Style Ocean

                wrgb "`nАнимированный Rainbow:" -FC "Cyan" -newline
                "Animated Magic!" | Write-Rainbow -Animated -Speed 100 -Loop -LoopCount 3

                wrgb "`nНажмите Enter..." -FC "DarkGray"
                Read-Host
            }

            "2" {
                # Прогресс-бары
#                Clear-Host
                Show-ProgressDemo
                wrgb "`nНажмите Enter..." -FC "DarkGray"
                Read-Host
            }

            "3" {
                # Парсинг текста
#                Clear-Host
                Show-ParserDemo
                wrgb "`nНажмите Enter..." -FC "DarkGray"
                Read-Host
            }

            "4" {
                # Парсинг файлов
#                Clear-Host
                Write-GradientHeader -Title "FILE PARSING DEMO"

                # Создаем временный файл для демо
                $demoFile = "$env:TEMP\parser_demo.ps1"
                @'

# Demo PowerShell Script
function Get-DemoData {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [int]$Count = 10
    )

    Write-Host "Processing $Name..." -ForegroundColor Cyan

    $results = @()
    for ($i = 1; $i -le $Count; $i++) {
        $results += @{
            Index = $i
            Name = $Name
            Value = Get-Random -Maximum 100
            Status = if ($i % 2) { "Active" } else { "Inactive" }
            Timestamp = Get-Date
        }
    }

    return $results | ConvertTo-Json
}

# TODO: Add error handling
$data = Get-DemoData -Name "Test" -Count 5
Write-Output $data
'@ | Out-File $demoFile

                Out-ParsedFile -Path $demoFile -ShowFileInfo -ShowLineNumbers

                Remove-Item $demoFile -Force
                wrgb "`nНажмите Enter..." -FC "DarkGray"
                Read-Host
            }

            "5" {
                # Интерактивный режим
                Start-InteractiveParser
            }

            "6" {
                # Pipeline демо
#                Clear-Host
                Write-GradientHeader -Title "PIPELINE INTEGRATION"

                wrgb "Get-Process (top 5 by CPU):" -FC "Cyan" -Style Bold -newline
                Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 |
                        ConvertTo-ParsedOutput -HighlightProperty CPU -ShowType

                wrgb "`nНажмите Enter..." -FC "DarkGray"
                Read-Host
            }

            "7" {
                # Комбо демо
#                Clear-Host
                Write-Rainbow "ULTIMATE COMBO DEMO" -Mode Gradient -Style Rainbow -Bold -Animated

                wrgb "`n📊 Загрузка системы парсинга..." -FC "Cyan" -newline
                Show-AnimatedProgress -Activity "Инициализация" -TotalSteps 30

                wrgb "`n✨ Система готова!" -FC "LimeGreen" -Style Bold -newline

                # Парсим лог с Rainbow заголовком
                "=== SYSTEM LOG ===" | Write-Rainbow -Mode Line -Style Fire -Bold

                @"
2024-01-15 10:30:00 [INFO] System initialization started
2024-01-15 10:30:01 [SUCCESS] ✅ Database connection established
2024-01-15 10:30:02 [WARNING] ⚠️ Low memory detected: 512MB available
2024-01-15 10:30:03 [ERROR] ❌ Failed to connect to API endpoint
2024-01-15 10:30:04 [INFO] Retrying connection...
2024-01-15 10:30:05 [SUCCESS] ✅ Connection restored successfully!
"@ -split "`n" | Out-ParsedText

                wrgb "`nНажмите Enter..." -FC "DarkGray"
                Read-Host
            }
        }
    } while ($choice -ne "8")

    # Прощальное сообщение
#    Clear-Host
    "Thanks for using MEGA PARSER!" | Write-Rainbow -Mode Gradient -Style Rainbow -Animated
    wrgb "`n👋 До встречи!" -FC "GoldRGB" -Style Bold -newline
}
#endregion

# Финальная инициализация
Write-GradientHeader -Title "PARSER SYSTEM READY" -StartColor "#00C851" -EndColor "#00FF00"

wrgb "🎯 Все системы парсинга загружены и готовы к работе!" -FC "LimeGreen" -Style Bold -newline

wrgb "`n📚 Доступные команды:" -FC "Cyan" -Style Bold -newline

$commands = @(
    @{ Cmd = "Write-Rainbow"; Desc = "Радужный текст с эффектами" }
    @{ Cmd = "Out-ParsedText"; Desc = "Универсальный парсинг текста" }
    @{ Cmd = "Out-ParsedFile"; Desc = "Парсинг файлов с автоопределением" }
    @{ Cmd = "Show-RGBProgress"; Desc = "Красивые прогресс-бары" }
    @{ Cmd = "Start-InteractiveParser"; Desc = "Интерактивный режим" }
    @{ Cmd = "Show-MegaParserDemo"; Desc = "Полная демонстрация" }
)

foreach ($cmd in $commands) {
    wrgb "  • " -FC "DarkGray"
    wrgb $cmd.Cmd -FC "Yellow" -Style Bold
    wrgb " - " -FC "DarkGray"
    wrgb $cmd.Desc -FC "White" -newline
}

wrgb "`n💡 Совет: " -FC "Material_Orange"
wrgb "Используйте " -FC "Gray"
wrgb "Show-MegaParserDemo" -FC "Cyan" -Style Bold
wrgb " для полной демонстрации!" -FC "Gray" -newline

# Экспортируем все функции если это модуль
if ($MyInvocation.MyCommand.Path -match '\.psm1$') {
    Export-ModuleMember -Function * -Alias *
}
importProcess  $MyInvocation.MyCommand.Name.trim(".ps1")
