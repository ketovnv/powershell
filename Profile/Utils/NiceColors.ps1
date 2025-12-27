Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

#region Утилитарные функции



function ConvertFrom-RGBToHex
{
    param(
        [Parameter(ParameterSetName = 'Components')]
        [ValidateRange(0, 255)][int]$R,

        [Parameter(ParameterSetName = 'Components')]
        [ValidateRange(0, 255)][int]$G,

        [Parameter(ParameterSetName = 'Components')]
        [ValidateRange(0, 255)][int]$B,

        [Parameter(ParameterSetName = 'Object')]
        [ValidateNotNull()]
        [object]$RGB
    )

    if ($PSCmdlet.ParameterSetName -eq 'Object')
    {
        $R = $RGB.R
        $G = $RGB.G
        $B = $RGB.B
    }

    return '#{0:X2}{1:X2}{2:X2}' -f $R, $G, $B
}

function ConvertTo-RGBComponents
{
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$HexColor
    )

    # Проверка инициализации кеша
    if (-not $script:ColorSystemConfig) {
        # Инициализация по умолчанию если ColorSystem не загружен
        $script:ColorSystemConfig = @{
            Cache = @{
                Enabled = $true
                ColorConversions = @{}
                FileColors = @{}
                GradientColors = @{}
            }
        }
    }

    # Проверка кеша
    $cacheKey = $HexColor.ToUpper()
    if ($script:ColorSystemConfig.Cache.Enabled -and
            $script:ColorSystemConfig.Cache.ColorConversions.ContainsKey($cacheKey))
    {
        return $script:ColorSystemConfig.Cache.ColorConversions[$cacheKey]
    }

    $hex = $HexColor.TrimStart('#')

    # Поддержка 3-символьного формата
    if ($hex.Length -eq 3)
    {
        $hex = "$($hex[0])$($hex[0])$($hex[1])$($hex[1])$($hex[2])$($hex[2])"
    }

    # Валидация
    if ($hex -notmatch '^[0-9A-Fa-f]{6}$')
    {
        throw "Invalid hex color format: $HexColor"
    }

    $result = @{
        R = [Convert]::ToInt32($hex.Substring(0, 2), 16)
        G = [Convert]::ToInt32($hex.Substring(2, 2), 16)
        B = [Convert]::ToInt32($hex.Substring(4, 2), 16)
    }

    # Сохранение в кеш
    if ($script:ColorSystemConfig.Cache.Enabled)
    {
        $script:ColorSystemConfig.Cache.ColorConversions[$cacheKey] = $result
    }

    return $result
}

# function ConvertFrom-RGBToHex
# {
#     <#
#     .SYNOPSIS
#         Конвертирует RGB компоненты в HEX
#     #>
#     param(
#         [Parameter(ParameterSetName = 'Separate')]
#         [ValidateRange(0, 255)][int]$R,

#         [Parameter(ParameterSetName = 'Separate')]
#         [ValidateRange(0, 255)][int]$G,

#         [Parameter(ParameterSetName = 'Separate')]
#         [ValidateRange(0, 255)][int]$B,

#         [Parameter(ParameterSetName = 'Hashtable')]
#         [hashtable]$Color
#     )

#     if ($PSCmdlet.ParameterSetName -eq 'Hashtable')
#     {
#         $R = $Color.R
#         $G = $Color.G
#         $B = $Color.B
#     }

#     return "#{0:X2}{1:X2}{2:X2}" -f $R, $G, $B
# }

function Get-RGBColor
{
    <#
    .SYNOPSIS
        Получает ANSI последовательность для RGB цвета
    #>
    param($Color)

    if (-not (Test-ColorSupport))
    {
        return ""
    }

    if ($Color -is [hashtable] -and $Color.ContainsKey('R') -and $Color.ContainsKey('G') -and $Color.ContainsKey('B'))
    {
        return $PSStyle.Foreground.FromRgb($Color.R, $Color.G, $Color.B)
    }
    elseif ($Color -is [string] -and $Color -match '^#?[0-9A-Fa-f]{3,6}$')
    {
        $rgb = ConvertTo-RGBComponents -HexColor $Color
        return $PSStyle.Foreground.FromRgb($rgb.R, $rgb.G, $rgb.B)
    }
    else
    {
        Write-Warning "Неверный формат цвета: $Color"
        return ""
    }
}

function Get-RGBBackgroundColor
{
    <#
    .SYNOPSIS
        Получает ANSI последовательность для RGB цвета фона
    #>
    param($Color)

    if (-not (Test-ColorSupport))
    {
        return ""
    }

    if ($Color -is [hashtable] -and $Color.ContainsKey('R') -and $Color.ContainsKey('G') -and $Color.ContainsKey('B'))
    {
        return $PSStyle.Background.FromRgb($Color.R, $Color.G, $Color.B)
    }
    elseif ($Color -is [string] -and $Color -match '^#?[0-9A-Fa-f]{3,6}$')
    {
        $rgb = ConvertTo-RGBComponents -HexColor $Color
        return $PSStyle.Background.FromRgb($rgb.R, $rgb.G, $rgb.B)
    }
    else
    {
        Write-Warning "Неверный формат цвета фона: $Color"
        return ""
    }
}
#endregion

#region Инициализация цветовых палитр
# Объединяем все цвета (используем глобальные переменные из Colors.ps1)
if ($global:additionalColors -and $global:newHexColors) {
    $allHexColors = $global:additionalColors + $global:newHexColors

    # Добавляем в глобальную палитру
    foreach ($color in $allHexColors.GetEnumerator()) {
        if ($color.Value -is [string] -and -not $global:RGB.ContainsKey($color.Key)) {
            $global:RGB[$color.Key] = ConvertTo-RGBComponents -HexColor $color.Value
        }
    }
}

if ($global:colorsRGB) {
    foreach ($color in $global:colorsRGB.GetEnumerator()) {
        if (-not $global:RGB.ContainsKey($color.Key)) {
            $global:RGB[$color.Key] = $color.Value
        }
    }
}
#endregion

# Копируем градиенты в глобальную область
if ($global:RAINBOWGRADIENT) { $global:RainbowGradient = $global:RAINBOWGRADIENT }
if ($global:RAINBOWGRADIENT2) { $global:RainbowGradientVariant = $global:RAINBOWGRADIENT2 }
#region Основная функция Write-RGB (улучшенная)

function Write-RGB
{
    <#
    .SYNOPSIS
        Выводит текст с поддержкой RGB цветов

    .DESCRIPTION
        Универсальная функция для вывода текста с RGB цветами переднего плана и фона,
        поддержкой стилей и различных режимов вывода

    .PARAMETER Text
        Текст для вывода

    .PARAMETER FC
        Цвет текста (имя из палитры или HEX)

    .PARAMETER BC
        Цвет фона (имя из палитры или HEX)

    .PARAMETER Style
        Стиль текста: Bold, Italic, Underline, Blink

    .PARAMETER newline
         Перевод строки

    .EXAMPLE
        Write-RGB "Hello World" -FC "#FF6B6B" -Style Bold

    .EXAMPLE
        Write-RGB "Warning!"  -BC "#2C0000"  -FC "ElectricLime" -Style Blink
    #>

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromRemainingArguments = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]$Text = '',

        [string]$FC = 'White',
        [string]$BC,

        [ValidateSet('Normal', 'Bold', 'Italic', 'Underline', 'Blink')]
        [string[]]$Style = 'Normal',


    # Для совместимости со старым кодом
        [switch]$newline,
        [switch]$Bold
    )

    begin {
        # Инициализация глобальной палитры цветов если не существует
        if (-not $global:RGB) {
            $global:RGB = @{}
        }

        if (-not (Test-ColorSupport))
        {
            Write-Warning "PSStyle не поддерживается в данной версии PowerShell"
            # Fallback к обычному Write-Host
            $fallbackParams = @{
            }
            if ($FC -and $FC -in @('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White'))
            {
                $fallbackParams['ForegroundColor'] = $FC
            }
            if ($BC -and $BC -in @('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White'))
            {
                $fallbackParams['BackgroundColor'] = $BC
            }

            Write-Host ($Text -join ' ') @fallbackParams
            return
        }
    }

    process {
        $fullText = $Text -join ' '

        # Обработка параметров совместимости
        # Ensure $Style is always an array
        if ($Style -is [string]) {
            $Style = @($Style)
        }

        if ($Bold -and $Style -notcontains 'Bold')
        {
            $Style += 'Bold'
        }

        $output = ""

        # Применение стилей
        foreach ($s in $Style)
        {
            switch ($s)
            {
                'Bold' {
                    $output += $PSStyle.Bold
                }
                'Italic' {
                    $output += $PSStyle.Italic
                }
                'Underline' {
                    $output += $PSStyle.Underline
                }
                'Blink' {
                    $output += $PSStyle.Blink
                }
            }
        }

        # Системные цвета PowerShell
        $systemColors = @('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')

        # Применение цвета переднего плана
        if ($FC -in $systemColors)
        {
            $output += $PSStyle.Foreground.$FC
        }
        elseif ($global:RGB -and $global:RGB.ContainsKey($FC))
        {
            $output += Get-RGBColor $global:RGB[$FC]
        }
        elseif ($FC -match '^#?[0-9A-Fa-f]{3,6}$')
        {
            $output += Get-RGBColor $FC
        }
        else
        {
            # Пытаемся найти без суффикса RGB
            $baseName = $FC -replace 'RGB$', ''
            if ($global:RGB -and $global:RGB.ContainsKey($baseName))
            {
                $output += Get-RGBColor $global:RGB[$baseName]
            }
            else
            {
                Write-Warning "Неизвестный цвет: $FC. Используется белый."
                $output += $PSStyle.Foreground.White
            }
        }

        # Применение цвета фона
        if ($BC)
        {
            if ($BC -in $systemColors)
            {
                $output += $PSStyle.Background.$BC
            }
            elseif ($global:RGB -and $global:RGB.ContainsKey($BC))
            {
                $output += Get-RGBBackgroundColor $global:RGB[$BC]
            }
            elseif ($BC -match '^#?[0-9A-Fa-f]{3,6}$')
            {
                $output += Get-RGBBackgroundColor $BC
            }
            else
            {
                Write-Warning "Неизвестный цвет фона: $BC"
            }
        }

        # Добавляем текст и сброс стилей
        $output += $fullText + $PSStyle.Reset

        # Вывод
        Write-Host $output  -NoNewline:(-not $newline)

    }
}
#endregion

function Get-GradientColor
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$Index,

        [Parameter(Mandatory)]
        [int]$TotalItems,

        [string]$StartColor = '#FF0000',
        [string]$EndColor = '#0000FF',

        [ValidateSet('Linear', 'Exponential', 'Sine', 'Cosine', 'Quadratic')]
        [string]$GradientType = 'Linear',

        [switch]$UseCache
    )

    # Проверка инициализации конфига
    if (-not $script:ColorSystemConfig) {
        $script:ColorSystemConfig = @{
            Cache = @{
                Enabled = $true
                ColorConversions = @{}
                FileColors = @{}
                GradientColors = @{}
            }
        }
    }

    # Генерация ключа кеша
    if ($UseCache)
    {
        $cacheKey = "$Index|$TotalItems|$StartColor|$EndColor|$GradientType"
        if ( $script:ColorSystemConfig.Cache.GradientColors.ContainsKey($cacheKey))
        {
            return $script:ColorSystemConfig.Cache.GradientColors[$cacheKey]
        }
    }

    # Оптимизация для крайних случаев
    if ($TotalItems -le 1)
    { return $StartColor }
    if ($Index -eq 0)
    { return $StartColor }
    if ($Index -eq $TotalItems - 1)
    { return $EndColor }

    # Расчет позиции
    $position = switch ($GradientType)
    {
        'Linear' { $Index / ($TotalItems - 1) }
        'Exponential' { [Math]::Pow($Index / ($TotalItems - 1), 2) }
        'Sine' { [Math]::Sin($Index / ($TotalItems - 1) * [Math]::PI / 2) }
        'Cosine' { 1 - [Math]::Cos($Index / ($TotalItems - 1) * [Math]::PI / 2) }
        'Quadratic' {
            $t = $Index / ($TotalItems - 1)
            if ($t -lt 0.5)
            { 2 * $t * $t }
            else
            { 1 - [Math]::Pow(-2 * $t + 2, 2) / 2 }
        }
    }

    # Конвертация цветов
    $startRGB = ConvertTo-RGBComponents $StartColor
    $endRGB = ConvertTo-RGBComponents $EndColor

    # Интерполяция
    $r = [int]($startRGB.R + ($endRGB.R - $startRGB.R) * $position)
    $g = [int]($startRGB.G + ($endRGB.G - $startRGB.G) * $position)
    $b = [int]($startRGB.B + ($endRGB.B - $startRGB.B) * $position)

    $result = ConvertFrom-RGBToHex -R $r -G $g -B $b

    # Сохранение в кеш
    if ($UseCache)
    {
        $script:ColorSystemConfig.Cache.GradientColors[$cacheKey] = $result
    }

    return $result
}


#function Get-GradientColor
#{
#    <#
#    .SYNOPSIS
#        Создает градиентные цвета для элементов меню
#
#    .DESCRIPTION
#        Функция генерирует цвета в шестнадцатеричном формате для создания градиентных эффектов
#        в меню PowerShell. Поддерживает различные типы градиентов и настройки цветовых переходов.
#
#    .PARAMETER Index
#        Текущий индекс элемента меню (начиная с 0)
#
#    .PARAMETER TotalItems
#        Общее количество элементов в меню
#
#    .PARAMETER StartColor
#        Начальный цвет градиента в шестнадцатеричном формате (например, "#FF0000")
#
#    .PARAMETER EndColor
#        Конечный цвет градиента в шестнадцатеричном формате (например, "#0000FF")
#
#    .PARAMETER GradientType
#        Тип градиента: Linear, Exponential, Sine, Custom
#
#    .PARAMETER RedCoefficient
#        Коэффициент изменения красного канала (по умолчанию 1.0)
#
#    .PARAMETER GreenCoefficient
#        Коэффициент изменения зеленого канала (по умолчанию 1.0)
#
#    .PARAMETER BlueCoefficient
#        Коэффициент изменения синего канала (по умолчанию 1.0)
#
#    .PARAMETER CustomFunction
#        Пользовательская функция для расчета градиента (скрипт-блок)
#
#    .PARAMETER Reverse
#        Обратить направление градиента
#
#    .EXAMPLE
#        Get-GradientColor -Index 0 -TotalItems 5 -StartColor "#FF0000" -EndColor "#0000FF"
#        Возвращает первый цвет в градиенте от красного к синему
#
#    .EXAMPLE
#        Get-GradientColor -Index 2 -TotalItems 10 -StartColor "#00FF00" -EndColor "#FF00FF" -GradientType Exponential
#        Возвращает цвет с экспоненциальным градиентом
#
#    .EXAMPLE
#        Get-GradientColor -Index 3 -TotalItems 8 -StartColor "#FFFF00" -EndColor "#FF0080" -RedCoefficient 0.5 -BlueCoefficient 2.0
#        Возвращает цвет с пользовательскими коэффициентами для каналов
#    #>
#
#    [CmdletBinding()]
#    param(
#        [Parameter(Mandatory = $true)]
#        [int]$Index,
#
#        [Parameter(Mandatory = $true)]
#        [int]$TotalItems,
#
#        [Parameter(Mandatory = $false)]
#        [string]$StartColor = "#01BB01",
#
#        [Parameter(Mandatory = $false)]
#        [string]$EndColor = "#FF9955",
#
#        [Parameter(Mandatory = $false)]
#        [ValidateSet("Linear", "Exponential", "Sine", "Custom")]
#        [string]$GradientType = "Linear",
#
#        [Parameter(Mandatory = $false)]
#        [double]$RedCoefficient = 1.0,
#
#        [Parameter(Mandatory = $false)]
#        [double]$GreenCoefficient = 1.0,
#
#        [Parameter(Mandatory = $false)]
#        [double]$BlueCoefficient = 1.0,
#
#        [Parameter(Mandatory = $false)]
#        [scriptblock]$CustomFunction = $null,
#
#        [Parameter(Mandatory = $false)]
#        [switch]$Reverse,
#
#        [Parameter(Mandatory = $false)]
#        [int]$Saturation = 100,
#
#        [Parameter(Mandatory = $false)]
#        [int]$Brightness = 100
#    )
#
#
#
#
#
#    # Реверс если нужно
#    if ($Reverse)
#    {
#        $temp = $StartColor
#        $StartColor = $EndColor
#        $EndColor = $temp
#    }
#
#    # Конвертация цветов
#    $startRGB = ConvertFrom-HexToRGB $StartColor
#    $endRGB = ConvertFrom-HexToRGB $EndColor
#
#    # Расчет позиции в градиенте
#    $position = Get-GradientPosition -Index $Index -Total $TotalItems -Type $GradientType -CustomFunc $CustomFunction
#
#    # Применение коэффициентов к каналам
#    $redDiff = ($endRGB.R - $startRGB.R) * $position * $RedCoefficient
#    $greenDiff = ($endRGB.G - $startRGB.G) * $position * $GreenCoefficient
#    $blueDiff = ($endRGB.B - $startRGB.B) * $position * $BlueCoefficient
#
#    # Расчет итоговых значений RGB
#    $finalR = [int]($startRGB.R + $redDiff)
#    $finalG = [int]($startRGB.G + $greenDiff)
#    $finalB = [int]($startRGB.B + $blueDiff)
#
#    # Применение насыщенности и яркости
#    if ($Saturation -ne 100 -or $Brightness -ne 100)
#    {
#        $satFactor = $Saturation / 100.0
#        $brightFactor = $Brightness / 100.0
#
#        # Простая коррекция насыщенности и яркости
#        $gray = ($finalR + $finalG + $finalB) / 3
#        $finalR = [int](($finalR - $gray) * $satFactor + $gray) * $brightFactor
#        $finalG = [int](($finalG - $gray) * $satFactor + $gray) * $brightFactor
#        $finalB = [int](($finalB - $gray) * $satFactor + $gray) * $brightFactor
#    }
#
#}

function Get-MenuGradientColor
{
    <#
    .SYNOPSIS
        Упрощенная функция для градиентов в меню
    #>
    param(
        [int]$Index,
        [int]$Total,
        [string]$Style = "Ocean"  # Ocean, Fire, Nature, Neon, Pastel
    )

    $styles = @{
        Ocean = @{
            Start = "#0080FF"; End = "#00FFD4"
        }
        Fire = @{
            Start = "#FF0000"; End = "#FFD700"
        }
        Nature = @{
            Start = "#00FF00"; End = "#90EE90"
        }
        Neon = @{
            Start = "#FF00FF"; End = "#00FFFF"
        }
        Pastel = @{
            Start = "#FFB6C1"; End = "#E6E6FA"
        }
        Ukraine = @{
            Start = "#0057B7"; End = "#FFD500"
        }
        Dracula = @{
            Start = "#FF79C6"; End = "#BD93F9"
        }
    }

    $colors = $styles[$Style]
    Get-GradientColor -Index $Index -TotalItems $Total `
        -StartColor $colors.Start -EndColor $colors.End
}



# Функция для создания палитры градиентных цветов
function New-GradientPalette
{
    <#
    .SYNOPSIS
        Создает палитру цветов для градиента
    #>
    param(
        [int]$Count = 10,
        [string]$StartColor = "#FF0000",
        [string]$EndColor = "#0000FF",
        [string]$GradientType = "Linear"
    )

    $palette = @()
    for ($i = 0; $i -lt $Count; $i++) {
        $palette += Get-GradientColor -Index $i -TotalItems $Count `
            -StartColor $StartColor -EndColor $EndColor `
            -GradientType $GradientType
    }
    $palette
}


function Write-RGBLine
{
    <#
    .SYNOPSIS
        Write-RGB с переводом строки (явное имя)
    #>
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string[]]$Text,
        [string]$FC = 'White',
        [string]$BC,
        [string[]]$Style = 'Normal'
    )

    Write-RGB @PSBoundParameters -newline
}

function Write-RGBNoNewLine
{
    <#
    .SYNOPSIS
        Write-RGB без перевода строки (явное имя)
    #>
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string[]]$Text,
        [string]$FC = 'White',
        [string]$BC,
        [string[]]$Style = 'Normal'
    )

    Write-RGB @PSBoundParameters
}

function Test-GradientText
{
    <#
    .SYNOPSIS
        Демонстрирует градиентный текст
    #>

    Write-RGB "`n=== Градиентный текст ===" -FC "Cyan" -Style Bold -newline

    # Простой градиент
    Write-RGB "`nПростой: " -FC "White"
    Write-GradientText "PowerShell Gradient Magic!" -StartColor "#FF0000" -EndColor "#0000FF"

    # С эффектом Sine
    Write-RGB "`nSine: " -FC "White"
    Write-GradientText "Smooth Sine Wave Gradient" -StartColor "#00FF00" -EndColor "#FF00FF" -GradientType Sine

    # Реверсивный
    Write-RGB "`nReverse: " -FC "White"
    Write-GradientText "Reversed Gradient Direction" -StartColor "#FFD700" -EndColor "#FF1493" -Reverse

    # С задержкой (эффект печатной машинки)
    Write-RGB "`nTypewriter: " -FC "White"
    Write-GradientText "Loading..." -StartColor "#00FFFF" -EndColor "#FF00FF" -CharDelay 100

    Write-Host ""
}

function Write-GradientFull
{
    param (
        [string]$Text,
        [int]$R1, [int]$G1, [int]$B1, # Цвет текста от
        [int]$R2, [int]$G2, [int]$B2, # Цвет текста до
        [int]$BR1, [int]$BG1, [int]$BB1, # Цвет фона от
        [int]$BR2, [int]$BG2, [int]$BB2    # Цвет фона до
    )


    $textElements = [System.Globalization.StringInfo]::GetTextElementEnumerator($Text)
    $elements = @()
    while ( $textElements.MoveNext())
    {
        $elements += $textElements.GetTextElement()
    }

    $length = $elements.Count
    if ($length -eq 0) { return }

    # Защита от деления на ноль
    $divisor = [Math]::Max(1, $length - 1)

    for ($i = 0; $i -lt $length; $i++) {
        $r = [int]($R1 + ($R2 - $R1) * $i / $divisor)
        $g = [int]($G1 + ($G2 - $G1) * $i / $divisor)
        $b = [int]($B1 + ($B2 - $B1) * $i / $divisor)

        $br = [int]($BR1 + ($BR2 - $BR1) * $i / $divisor)
        $bg = [int]($BG1 + ($BG2 - $BG1) * $i / $divisor)
        $bb = [int]($BB1 + ($BB2 - $BB1) * $i / $divisor)

        $ansi = "`e[38;2;${r};${g};${b}m`e[48;2;${br};${bg};${bb}m"
        Write-Host "$ansi$( $elements[$i] )" -NoNewline
    }
    Write-Host "`e[0m"  # Сброс стиля
}

function Write-GradientText
{
    <#
    .SYNOPSIS
        Выводит текст с градиентом по символам

    .DESCRIPTION
        Каждый символ текста окрашивается в свой цвет из градиента

    .PARAMETER Text
        Текст для вывода

    .PARAMETER StartColor
        Начальный цвет градиента

    .PARAMETER EndColor
        Конечный цвет градиента

    .PARAMETER Style
        Стили текста (Bold, Italic, Underline)

    .PARAMETER GradientType
        Тип градиента

    .PARAMETER NoNewline
        Не добавлять перевод строки в конце

    .PARAMETER CharDelay
        Задержка между символами (мс) для эффекта печатной машинки

    .EXAMPLE
        Write-GradientText "Hello PowerShell!" -StartColor "#FF0000" -EndColor "#0000FF"

    .EXAMPLE
        Write-GradientText "LOADING..." -GradientType Sine -CharDelay 50
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [string]$StartColor = "#FFFF00",
        [string]$EndColor = "#0000FF",

        [string[]]$Style = @('Normal'),

        [ValidateSet("Linear", "Exponential", "Sine", "Logarithmic", "Quadratic")]
        [string]$GradientType = "Linear",

        [switch]$NoNewline,

        [int]$CharDelay = 0,

        [switch]$Reverse
    )

    if ( [string]::IsNullOrEmpty($Text))
    {
        Write-Warning "Текст не может быть пустым"
        return
    }


    $textElements = [System.Globalization.StringInfo]::GetTextElementEnumerator($Text)
    $elements = @()
    while ( $textElements.MoveNext())
    {
        $elements += $textElements.GetTextElement()
    }
    $length = $elements.Count

    for ($i = 0; $i -lt $length; $i++) {
        # Получаем цвет для текущего символа
        $color = Get-GradientColor -Index $i -TotalItems $length `
            -StartColor $StartColor -EndColor $EndColor `
            -GradientType $GradientType

        # Выводим символ (теперь это полноценная графема)
        Write-RGB -Text $elements[$i] -FC $color -Style $Style

        # Задержка для эффекта печатной машинки
        if ($CharDelay -gt 0)
        {
            Start-Sleep -Milliseconds $CharDelay
        }
    }

    if (-not $NoNewline)
    {
        Write-Host ""
    }
}

#region Утилитарные функции для работы с палитрой

# Вспомогательная функция для приблизительного соответствия консольным цветам
function Get-ConsoleColor
{
    param([string]$HexColor)

    $rgb = ConvertTo-RGBComponents -HexColor $HexColor

    # Простая логика выбора ближайшего консольного цвета
    $colors = @{
        "Red" = @{
            R = 255; G = 0; B = 0
        }
        "Green" = @{
            R = 0; G = 255; B = 0
        }
        "Blue" = @{
            R = 0; G = 0; B = 255
        }
        "Yellow" = @{
            R = 255; G = 255; B = 0
        }
        "Cyan" = @{
            R = 0; G = 255; B = 255
        }
        "Magenta" = @{
            R = 255; G = 0; B = 255
        }
        "White" = @{
            R = 255; G = 255; B = 255
        }
        "Gray" = @{
            R = 128; G = 128; B = 128
        }
        "DarkRed" = @{
            R = 128; G = 0; B = 0
        }
        "DarkGreen" = @{
            R = 0; G = 128; B = 0
        }
        "DarkBlue" = @{
            R = 0; G = 0; B = 128
        }
        "DarkYellow" = @{
            R = 128; G = 128; B = 0
        }
        "DarkCyan" = @{
            R = 0; G = 128; B = 128
        }
        "DarkMagenta" = @{
            R = 128; G = 0; B = 128
        }
        "DarkGray" = @{
            R = 64; G = 64; B = 64
        }
    }

    $minDistance = [double]::MaxValue
    $closestColor = "White"

    foreach ($colorName in $colors.Keys)
    {
        $distance = [Math]::Sqrt(
                [Math]::Pow($rgb.R - $colors[$colorName].R, 2) +
                        [Math]::Pow($rgb.G - $colors[$colorName].G, 2) +
                        [Math]::Pow($rgb.B - $colors[$colorName].B, 2)
        )

        if ($distance -lt $minDistance)
        {
            $minDistance = $distance
            $closestColor = $colorName
        }
    }

    return $closestColor
}


function Show-Colors
{
    <#
    .SYNOPSIS
        Показывает все доступные цвета
    #>
    param(
        [int]$ColumnsPerRow = 4,
        [string]$Filter = "*"
    )

    Write-Host "`n=== Доступные цвета ===`n" -ForegroundColor Cyan

    $filteredColors = $global:RGB.Keys | Where-Object {
        $_ -like $Filter
    } | Sort-Object
    $colorIndex = 0

    foreach ($colorName in $filteredColors)
    {
        # Показываем образец цвета
        Write-RGB "  $colorName " -FC $colorName

        $colorIndex++
        if ($colorIndex % $ColumnsPerRow -eq 0)
        {
            Write-Host ""
        }
    }

    Write-Host "`n"
    Write-Host "Всего цветов: $( $filteredColors.Count )" -ForegroundColor Yellow
}


function Test-GradientDemo
{
    Write-GradientText  "`n=== Демонстрация градиентов ===`n" -StartColor "#ffffff" -EndColor "#000000"

    $gradientTypes = @("Linear", "Exponential", "Sine", "Cosine")
    $colorPairs = @(
        @{ Start = "#FF0000"; End = "#0000FF"; Name = "Красный → Синий" },
        @{ Start = "#FFFF00"; End = "#FF00FF"; Name = "Желтый → Пурпурный" },
        @{ Start = "#00FF00"; End = "#FF8000"; Name = "Зеленый → Оранжевый" },
        @{ Start = "#00FFFF"; End = "#FF0080"; Name = "Голубой → Розовый" }
    )

    foreach ($colorPair in $colorPairs)
    {
        Write-GradientText  $colorPair.Name  -StartColor $colorPair.Start -EndColor $colorPair.End
        Write-GradientLine -Length 50 -Char "█" -StartColor $colorPair.Start -EndColor $colorPair.End
    }
    Write-RGB "" -newline
}



function Show-Palette
{
    <#
    .SYNOPSIS
        Показывает цвета определенной палитры
    #>
    param(
        [ValidateSet("Nord", "Dracula", "Material", "Cyber", "OneDark", "Pastel", "Neon", "All")]
        [string]$Palette = "All",
        [switch]$withoutNames
    )

    $paletteColors = switch ($Palette)
    {
        "NordKeys" {
            $global:RGB.Keys | Where-Object {
                $_ -like "Nord_*"
            }
        }
        "Dracula" {
            $global:RGB.Keys | Where-Object {
                $_ -like "Dracula_*"
            }
        }
        "Material" {
            $global:RGB.Keys | Where-Object {
                $_ -like "Material_*"
            }
        }
        "Cyber" {
            $global:RGB.Keys | Where-Object {
                $_ -like "Cyber_*"
            }
        }
        "OneDark" {
            $global:RGB.Keys | Where-Object {
                $_ -like "OneDark_*"
            }
        }
        "Pastel" {
            $global:RGB.Keys | Where-Object {
                $_ -like "Pastel*"
            }
        }
        "Neon" {
            $global:RGB.Keys | Where-Object {
                $_ -like "*Neon*" -or $_ -like "*Electric*"
            }
        }
        "All" {
            $global:RGB.Keys
        }
    }


    Write-Host "`n = = = Палитра: $Palette = = = `n" -ForegroundColor Cyan


    for ($i = 0; $i -lt $paletteColors.Count; $i++) {

        $key = $paletteColors[$i]
        if ($key -eq 0)
        {
            $keyPrev = $paletteColors[$paletteColors.Count - 1]
        }
        else
        {
            $keyPrev = $paletteColors[$i - 1]
        }

        $valuePrev = $global:RGB[$keyPrev]
        $value = $global:RGB[$key]
        if (!$withoutNames)
        {
            Write-RGB "■ $keyPrev ■           " -FC $keyPrev
            Write-RGB "■ $key ■" -FC $key -newline
        }
        Write-GradientLine -Length 50 -Char "██" -StartColor $valuePrev -EndColor  $value
        # Write-RGB  "" -newline
    }
}


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
        $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = $currentY }

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


function Write-GradientLine
{
    <#
    .SYNOPSIS
        Рисует градиентную линию из символов

    .EXAMPLE
        Write-GradientLine -Length 50 -Char "█" -StartColor "#FF0000" -EndColor "#00FF00"
    #>
    param(
        [int]$Length = 40,
        [string]$Char = "━",
        [string]$StartColor = "#0080FF",
        [string]$EndColor = "#FF0080",
        [string]$GradientType = "Linear"
    )

    Write-GradientText -Text ($Char * $Length) `
        -StartColor $StartColor `
        -EndColor $EndColor `
        -GradientType $GradientType
}

# Функция для градиентного заголовка с рамкой
function Write-GradientHeader
{
    <#
    .SYNOPSIS
        Создает красивый заголовок с градиентным текстом и рамкой
    #>
    param(
        [string]$Title,
        [string]$StartColor = "#FFD700",
        [string]$EndColor = "#FF1493",
        [string]$BorderColor = "Cyan",
        [int]$Padding = 2
    )

    $width = $Title.Length + ($Padding * 2) + 2

    # Верхняя граница
    Write-RGB "╔" -FC $BorderColor
    Write-RGB ("═" * ($width - 2)) -FC $BorderColor
    Write-RGB "╗" -FC $BorderColor -newline

    # Строка с заголовком
    Write-RGB "║" -FC $BorderColor
    Write-RGB (" " * $Padding)
    Write-GradientText -Text $Title -StartColor $StartColor -EndColor $EndColor -Style Bold  -CharDelay 10 -NoNewline
    Write-RGB (" " * $Padding)
    Write-RGB "║" -FC $BorderColor -newline

    # Нижняя граница
    Write-RGB "╚" -FC $BorderColor
    Write-RGB ("═" * ($width - 2)) -FC $BorderColor
    Write-RGB "╝" -FC $BorderColor -newline
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

function NumberToHexPair
{
    param (
        [Parameter(Mandatory = $true)]
        [int]$Number,
        [int]$minimum = 0
    )

    $Number = [Math]::Abs($Number)
    # Берём остаток от деления на 256 (0..255)
    # Берём остаток от деления на 510 (0..509)
    $remainder = $Number % 510

    # Если в первой половине (0..255) — растёт, иначе — падает
    $adjustedValue = if ($remainder -le 255)
    {
        $remainder
    }
    else
    {
        510 - $remainder  # 510 - 256 = 254, 510 - 257 = 253, ..., 510 - 510 = 0
    }

    # Корректируем, если вышли за 255 (может быть при 256 - 0 = 256 → должно стать 0)
    $adjustedValue = $adjustedValue % 256

    # Форматируем в HEX с ведущим нулём, если нужно
    if ($adjustedValue -lt 16)
    {
        "0{0:X}" -f $adjustedValue
    }
    else
    {
        "{0:X}" -f $adjustedValue
    }
}


function Get-GradientList
{
    param(
        [Parameter(ValueFromPipeline = $true)]
        $list = (Get-Command)
    )
    $i = 0
    $list | ForEach-Object {
        $cmd = $_.Name ?? $_.PSPath ?? $_
        $hex1 = NumberToHexPair $i
        $hex2 = NumberToHexPair (256 - $i)
        $hex3 = NumberToHexPair ($i - 256 / 2 + $i)
        Write-GradientText $cmd  -StartColor "#${hex3}${hex1}${hex2}" -EndColor "#${hex2}${hex2}${hex1}"
        $i++
    }

    Write-Host""
}

function Get-GradientTerminalIcons
{
    if (-not $global:icons)
    {
        $psd1Content = Get-Content -Raw "$global:profilePath/Utils/resourses/glyphs.psd1"
        $global:icons = Invoke-Expression $psd1Content
    }

    $list = $icons.GetEnumerator() | ForEach-Object { "$( $_.Key ) $( $_.Value )" }
    Get-GradientList $list
}


function Find-Icon
{
    param(
        [string]$SearchQuery
    )

    # Загружаем иконки (если $icons еще не определен)
    if (-not $global:icons)
    {
        $psd1Content = Get-Content -Raw "$global:profilePath/Utils/resourses/glyphs.psd1"
        $global:icons = Invoke-Expression $psd1Content
    }

    # Фильтрация по запросу (без учета регистра)
    $results = $global:icons.GetEnumerator() |
            Where-Object { $_.Key -like "*$SearchQuery*" } |
            Sort-Object Key

    # Вывод результатов

    $c = 1
    $results | ForEach-Object {
        $red = NumberToHexPair ($c / 2)
        $green = NumberToHexPair (256 - $c)
        $icon = $_.Value
        Write-RGB -Text "${icon}     " -FC "#${red}AA${green}"
        $c = $c + 11
    }

    Write-Host "`nНайдено иконок: $( $results.Count )" -ForegroundColor Cyan
}



function Write-Status
{
    param(
        [string]$Message,
        [switch]$Success,
        [switch]$Warning,
        [switch]$Problem,
        [switch]$Critical,
        [switch]$Info,
        [switch]$returnRow
    )

    $icon = "📌"
    $color = "White"

    if ($Success)
    {
        $icon = Get-StatusIcon('success'); $color = "Material_Green"
    }
    elseif ($Warning)
    {
        $icon = Get-StatusIcon('warning'); $color = "Material_Amber"
    }
    elseif ($Problem)
    {
        $icon = Get-StatusIcon('problem'); $color = "Material_Red"
    }
    elseif ($Critical)
    {
        $icon = Get-StatusIcon('critical'); $color = "#FF0000"
    }
    elseif ($Info)
    {
        $icon = "ℹ️"; $color = "Cyan"
    }

    if ($returnRow)
    {
        return "${icon} ${Message}"
    }
    else
    {
        Write-RGB $icon
        Write-RGB $Message -FC $color
    }
}

function Show-TestGradientFull
{
    Write-GradientFull "┌────────────────────────────────────────┐" 0 255 255 0 100 255 0 0 0 20 20 60
    Write-GradientFull "│  🌐  NET INTERFACE v0.8                │" 0 255 128 0 120 255 0 0 0 20 20 60
    Write-GradientFull "│  📡  SCANNING: 192.168.1.1/24          │" 155 255 255 200 255 128 0 0 0 40 0 60
    Write-GradientFull "│  🔓  STATUS: INTRUSION CHECK...        │" 55 128 0 255 0 128 0 0 0 30 20 60
    Write-GradientFull "│  🧪  PROGRESS: 50%                     │" 0 255 0 255 0 255 0 0 0 30 0 50
    Write-GradientFull "└────────────────────────────────────────┘" 0 255 255 0 100 255 0 0 0 20 20 60


    Write-GradientFull " ✔️  SCAN COMPLETE — HOSTS FOUND: 12" 0 255 0 0 150 255 0 0 0 0 80 0
    Write-GradientFull " 💥  VULNERABILITIES: SMBv1, SSH 6.2" 255 0 0 255 255 0 0 0 0 40 0 0
}

function Write-Rainbow
{
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
            Rainbow = $global:RAINBOWGRADIENT
            Fire = @("#8B0000", "#FF0000", "#FF4500", "#FFA500", "#FFD700", "#FFFF00", "#FFFACD")
            Ocean = @("#000080", "#0000CD", "#0000FF", "#0080FF", "#00BFFF", "#00CED1", "#00FFFF")
            Forest = @("#013220", "#228B22", "#32CD32", "#00FF00", "#7CFC00", "#ADFF2F", "#9ACD32")
            Sunset = @("#FF1744", "#FF6E40", "#FF9100", "#FFC400", "#FFD740", "#FFE57F")
            Neon = @("#FF00FF", "#FF00AA", "#FF0080", "#FF0040", "#FF0000", "#FF4000", "#FF8000", "#FFFF00")
            Pastel = @("#FFB3BA", "#FFDFBA", "#FFFFBA", "#BAFFC9", "#BAE1FF", "#E0BBE4", "#FFDFD3")
            Ukraine = @("#0057B7", "#0057B7", "#FFD500", "#FFD500")
        }


        # Выбираем палитру
        if ($Style -eq "Custom" -and $Palette)
        {
            $colors = $Palette
        }
        else
        {
            $colors = $palettes[$Style]
        }

        if ($Reverse)
        {
            [array]::Reverse($colors)
        }

        $index = 0
        $styles = @()
        if ($Bold)
        {
            $styles += 'Bold'
        }
        if ($Italic)
        {
            $styles += 'Italic'
        }
        if ($styles.Count -eq 0)
        {
            $styles = @('Normal')
        }
    }

    process {
        if (-not $Text)
        {
            return
        }

        if ($Animated)
        {
            $originalText = $Text

            # Изменил $loop на $iteration чтобы избежать конфликта с параметром $Loop
            for ($iteration = 0; $iteration -lt $( if ($Loop)
            {
                $LoopCount
            }
            else
            {
                1
            } ); $iteration++) {
                for ($shift = 0; $shift -lt $colors.Count; $shift++) {
                    # Очищаем строку
                    [Console]::Write("`r" + (" " * $originalText.Length) + "`r")

                    switch ($Mode)
                    {
                        "Char" {
                            $chars = $originalText.ToCharArray()
                            for ($i = 0; $i -lt $chars.Length; $i++) {
                                $colorIndex = ($i + $shift) % $colors.Count
                                Write-RGB $chars[$i] -FC $colors[$colorIndex] -Style $styles
                            }
                        }
                        "Word" {
                            $words = $originalText -split '\s+'
                            for ($i = 0; $i -lt $words.Length; $i++) {
                                $colorIndex = ($i + $shift) % $colors.Count
                                Write-RGB "$( $words[$i] ) " -FC $colors[$colorIndex] -Style $styles
                            }
                        }
                        default {
                            $colorIndex = $shift % $colors.Count
                            Write-RGB $originalText -FC $colors[$colorIndex] -Style $styles
                        }
                    }

                    Start-Sleep -Milliseconds $Speed
                }
                [Console]::Write("`r" + (" " * $originalText.Length) + "`r")
            }

            # Финальный вывод
            $shift = 0
        }

        # Статичный вывод
        switch ($Mode)
        {
            "Char" {
                $chars = $Text.ToCharArray()
                foreach ($char in $chars)
                {
                    $color = $colors[$index % $colors.Length]
                    Write-RGB $char -FC $color -Style $styles
                    $index++
                }
                Write-Host ""
            }

            "Word" {
                $words = $Text -split '\s+'
                foreach ($word in $words)
                {
                    $color = $colors[$index % $colors.Length]
                    Write-RGB "$word " -FC $color -Style $styles
                    $index++
                }
                Write-Host ""
            }

            "Line" {
                $color = $colors[$index % $colors.Length]
                Write-RGB $Text -FC $color -Style $styles -newline
                $index++
            }

            "Gradient" {
                # Градиентный режим между цветами палитры
                $chars = $Text.ToCharArray()
                $length = $chars.Length

                for ($i = 0; $i -lt $length; $i++) {
                    $progress = $i / [Math]::Max(1, ($length - 1))
                    $paletteProgress = $progress * ($colors.Count - 1)
                    $colorIndex = [Math]::Floor($paletteProgress)
                    $localProgress = $paletteProgress - $colorIndex

                    $startIdx = [Math]::Min($colorIndex, $colors.Count - 1)
                    $endIdx = [Math]::Min($colorIndex + 1, $colors.Count - 1)

                    $color = Get-GradientColor -Index $i -TotalItems $length -StartColor $colors[$startIdx] -EndColor $colors[$endIdx] -GradientType Linear
                    Write-RGB $chars[$i] -FC $color -Style $styles
                }
            }

            "Wave" {
                $colors = $global:RAINBOWGRADIENT
                # Волновой режим
                $chars = $Text.ToCharArray()
                for ($i = 0; $i -lt $chars.Length; $i++) {
                    $waveValue = [Math]::Sin($i * $WaveFrequency) * 0.5 + 0.5
                    $colorIndex = [int]($waveValue * ($colors.Count - 1))
                    Write-RGB $chars[$i] -FC $colors[$colorIndex] -Style $styles
                }
                Write-Host ""
            }
        }
    }
}


function Out-Color {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        $InputObject,

        [switch]$NoHeader,
        [switch]$Compact,
        [int]$MaxColumns = 6
    )

    begin {
        $items = @()

        $colors = @{
            Header    = 'Magenta'
            String    = 'Blue'
            Number    = 'Yellow'
            Date      = 'Green'
            Bool      = 'Red'
            Null      = 'DarkGray'
            Path      = 'Blue'
            Default   = 'White'
            Arrow     = 'DarkGray'
            Key       = 'Blue'
            Value     = 'Yellow'
        }

        # Пары свойств для компактного вывода (key -> value)
        $knownPairs = @(
            @('Name', 'Definition'),      # Get-Alias
            @('Name', 'Value'),           # Get-Variable, env:
            @('Key', 'Value'),            # Hashtable
            @('Name', 'Path'),            # Get-Command
            @('Alias', 'Command')
        )
    }

    process {
        $items += $InputObject
    }

    end {
        if ($items.Count -eq 0) { return }

        $firstItem = $items[0]
        $allProps = $firstItem.PSObject.Properties |
            Where-Object { $_.MemberType -match 'Property|NoteProperty|ScriptProperty' } |
            ForEach-Object { $_.Name }

        # Проверяем, есть ли известная пара для компактного вывода
        $pairFound = $null
        foreach ($pair in $knownPairs) {
            if ($allProps -contains $pair[0] -and $allProps -contains $pair[1]) {
                $pairFound = $pair
                break
            }
        }

        # Компактный вывод для пар key -> value
        if ($pairFound -or $Compact) {
            $keyProp = if ($pairFound) { $pairFound[0] } else { $allProps[0] }
            $valProp = if ($pairFound) { $pairFound[1] } else { $allProps[1] }

            # Вычисляем ширину для выравнивания
            $maxKeyLen = ($items | ForEach-Object { "$($_.$keyProp)".Length } | Measure-Object -Maximum).Maximum

            foreach ($item in $items) {
                $key = "$($item.$keyProp)"
                $val = "$($item.$valProp)"

                Write-Host $key.PadRight($maxKeyLen + 1) -ForegroundColor $colors.Key -NoNewline
                Write-Host " -> " -ForegroundColor $colors.Arrow -NoNewline
                Write-Host $val -ForegroundColor $colors.Value
            }
            return
        }

        # Табличный вывод
        $props = $allProps | Select-Object -First $MaxColumns

        if (-not $props) {
            foreach ($item in $items) {
                $color = Get-ValueColor $item $colors
                Write-Host $item -ForegroundColor $color
            }
            return
        }

        # Ширина колонок
        $widths = @{}
        foreach ($prop in $props) {
            $maxLen = $prop.Length
            foreach ($item in $items) {
                $val = "$($item.$prop)"
                if ($val.Length -gt $maxLen) { $maxLen = $val.Length }
            }
            $widths[$prop] = [Math]::Min($maxLen + 2, 40)
        }

        # Заголовок
        if (-not $NoHeader) {
            foreach ($prop in $props) {
                Write-Host ($prop.PadRight($widths[$prop])) -ForegroundColor $colors.Header -NoNewline
            }
            Write-Host ""
            foreach ($prop in $props) {
                Write-Host (("-" * ($widths[$prop] - 1)) + " ") -ForegroundColor DarkGray -NoNewline
            }
            Write-Host ""
        }

        # Данные
        $rowNum = 0
        foreach ($item in $items) {
            foreach ($prop in $props) {
                $val = $item.$prop
                $str = if ($null -eq $val) { "<null>" } else { "$val" }

                if ($str.Length -gt $widths[$prop] - 1) {
                    $str = $str.Substring(0, $widths[$prop] - 4) + "..."
                }
                $str = $str.PadRight($widths[$prop])

                $color = Get-ValueColor $val $colors
                Write-Host $str -ForegroundColor $color -NoNewline
            }
            Write-Host ""
            $rowNum++
        }
    }
}

function Get-ValueColor($val, $colors) {
    if ($null -eq $val) { return $colors.Null }

    $type = $val.GetType().Name

    switch -Regex ($type) {
        'Int|Double|Decimal|Float|Long|Short|Byte' { return $colors.Number }
        'DateTime' { return $colors.Date }
        'Boolean' { return $colors.Bool }
        'String' {
            if ($val -match '^[A-Z]:\\|^/|^~/' ) { return $colors.Path }
            return $colors.String
        }
        default { return $colors.Default }
    }
}

Set-Alias -Name oc -Value Out-Color

function Get-ValueColor($val, $colors) {
    if ($null -eq $val) { return $colors.Null }

    $type = $val.GetType().Name

    switch -Regex ($type) {
        'Int|Double|Decimal|Float|Long|Short|Byte' { return $colors.Number }
        'DateTime' { return $colors.Date }
        'Boolean' { return $colors.Bool }
        'String' {
            if ($val -match '^[A-Z]:\\|^/|^~/' ) { return $colors.Path }
            return $colors.String
        }
        default { return $colors.Default }
    }
}

# Алиас
Set-Alias -Name oc -Value Out-Color



Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))
