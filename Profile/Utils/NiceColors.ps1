importProcess  $MyInvocation.MyCommand.Name.trim('.ps1') -start

#region Утилитарные функции
function Test-ColorSupport
{
    <#
    .SYNOPSIS
        Проверяет поддержку цветов в текущем окружении
    #>
    return $null -ne $PSStyle
}

function ConvertTo-RGBComponents
{
    <#
    .SYNOPSIS
        Конвертирует HEX цвет в RGB компоненты
    
    .PARAMETER HexColor
        HEX цвет (например, #FF0000 или FF0000)
    #>
    param([string]$HexColor)

    if ( [string]::IsNullOrEmpty($HexColor))
    {
        throw "Цвет не может быть пустым"
    }

    $hex = $HexColor.TrimStart('#')

    # Поддержка сокращенного формата (#RGB -> #RRGGBB)
    if ($hex.Length -eq 3)
    {
        $hex = $hex[0] + $hex[0] + $hex[1] + $hex[1] + $hex[2] + $hex[2]
    }

    if ($hex.Length -ne 6)
    {
        throw "Неверный формат HEX цвета: $HexColor"
    }

    try
    {
        return @{
            R = [Convert]::ToInt32($hex.Substring(0, 2), 16)
            G = [Convert]::ToInt32($hex.Substring(2, 2), 16)
            B = [Convert]::ToInt32($hex.Substring(4, 2), 16)
        }
    }
    catch
    {
        throw "Ошибка при конвертации цвета $HexColor : $_"
    }
}

function ConvertFrom-RGBToHex
{
    <#
    .SYNOPSIS
        Конвертирует RGB компоненты в HEX
    #>
    param(
        [Parameter(ParameterSetName = 'Separate')]
        [ValidateRange(0, 255)][int]$R,

        [Parameter(ParameterSetName = 'Separate')]
        [ValidateRange(0, 255)][int]$G,

        [Parameter(ParameterSetName = 'Separate')]
        [ValidateRange(0, 255)][int]$B,

        [Parameter(ParameterSetName = 'Hashtable')]
        [hashtable]$Color
    )

    if ($PSCmdlet.ParameterSetName -eq 'Hashtable')
    {
        $R = $Color.R
        $G = $Color.G
        $B = $Color.B
    }

    return "#{0:X2}{1:X2}{2:X2}" -f $R, $G, $B
}

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
# Объединяем все цвета
$allHexColors = $additionalColors + $newHexColors
$allRgbColors = $colorsRGB

# Добавляем в глобальную палитру
foreach ($color in $allHexColors.GetEnumerator())
{
    if (-not $global:RGB.ContainsKey($color.Key))
    {
        $global:RGB[$color.Key] = $color.Value
    }
}

foreach ($color in $allRgbColors.GetEnumerator())
{
    if (-not $global:RGB.ContainsKey($color.Key))
    {
        $global:RGB[$color.Key] = $color.Value
    }
}
#endregion
$global:RainbowGradient = $RAINBOWGRADIENT
$global:RainbowGradientVariant = $RAINBOWGRADIENT2
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
                'Bold'      {
                    $output += $PSStyle.Bold
                }
                'Italic'    {
                    $output += $PSStyle.Italic
                }
                'Underline' {
                    $output += $PSStyle.Underline
                }
                'Blink'     {
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
        elseif ($global:RGB.ContainsKey($FC))
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
            if ( $global:RGB.ContainsKey($baseName))
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
            elseif ($global:RGB.ContainsKey($BC))
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
    <#
    .SYNOPSIS
        Создает градиентные цвета для элементов меню

    .DESCRIPTION
        Функция генерирует цвета в шестнадцатеричном формате для создания градиентных эффектов
        в меню PowerShell. Поддерживает различные типы градиентов и настройки цветовых переходов.

    .PARAMETER Index
        Текущий индекс элемента меню (начиная с 0)

    .PARAMETER TotalItems
        Общее количество элементов в меню

    .PARAMETER StartColor
        Начальный цвет градиента в шестнадцатеричном формате (например, "#FF0000")

    .PARAMETER EndColor
        Конечный цвет градиента в шестнадцатеричном формате (например, "#0000FF")

    .PARAMETER GradientType
        Тип градиента: Linear, Exponential, Sine, Custom

    .PARAMETER RedCoefficient
        Коэффициент изменения красного канала (по умолчанию 1.0)

    .PARAMETER GreenCoefficient
        Коэффициент изменения зеленого канала (по умолчанию 1.0)

    .PARAMETER BlueCoefficient
        Коэффициент изменения синего канала (по умолчанию 1.0)

    .PARAMETER CustomFunction
        Пользовательская функция для расчета градиента (скрипт-блок)

    .PARAMETER Reverse
        Обратить направление градиента

    .EXAMPLE
        Get-GradientColor -Index 0 -TotalItems 5 -StartColor "#FF0000" -EndColor "#0000FF"
        Возвращает первый цвет в градиенте от красного к синему

    .EXAMPLE
        Get-GradientColor -Index 2 -TotalItems 10 -StartColor "#00FF00" -EndColor "#FF00FF" -GradientType Exponential
        Возвращает цвет с экспоненциальным градиентом

    .EXAMPLE
        Get-GradientColor -Index 3 -TotalItems 8 -StartColor "#FFFF00" -EndColor "#FF0080" -RedCoefficient 0.5 -BlueCoefficient 2.0
        Возвращает цвет с пользовательскими коэффициентами для каналов
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$Index,

        [Parameter(Mandatory = $true)]
        [int]$TotalItems,

        [Parameter(Mandatory = $false)]
        [string]$StartColor = "#01BB01",

        [Parameter(Mandatory = $false)]
        [string]$EndColor = "#FF9955",

        [Parameter(Mandatory = $false)]
        [ValidateSet("Linear", "Exponential", "Sine", "Custom")]
        [string]$GradientType = "Linear",

        [Parameter(Mandatory = $false)]
        [double]$RedCoefficient = 1.0,

        [Parameter(Mandatory = $false)]
        [double]$GreenCoefficient = 1.0,

        [Parameter(Mandatory = $false)]
        [double]$BlueCoefficient = 1.0,

        [Parameter(Mandatory = $false)]
        [scriptblock]$CustomFunction = $null,

        [Parameter(Mandatory = $false)]
        [switch]$Reverse,

        [Parameter(Mandatory = $false)]
        [int]$Saturation = 100,

        [Parameter(Mandatory = $false)]
        [int]$Brightness = 100
    )

    # Функция для конвертации hex в RGB
    function ConvertFrom-HexToRGB
    {
        param(
            [Parameter(Mandatory = $true)]
            [string]$HexColor
        )

        # Проверка на null и пустую строку
        if ( [string]::IsNullOrWhiteSpace($HexColor))
        {
            Write-Error "Hex color string cannot be empty or null"
            return $null
        }

        # Нормализация: удаление решетки и пробелов, перевод в верхний регистр
        $cleanHex = $HexColor.Trim().ToUpper() -replace '^#', ''

        # Валидация формата с помощью регулярного выражения
        if (-not ($cleanHex -match '^([A-F0-9]{3}|[A-F0-9]{6})$'))
        {

            $stringRepresentation = ""
            foreach ($key in $HexColor.Keys)
            {
                $value = $HexColor[$key]
                $stringRepresentation += "$key=$value;"
            }

            # Remove the trailing semicolon if present
            if ( $stringRepresentation.EndsWith(";"))
            {
                $stringRepresentation = $stringRepresentation.TrimEnd(";")
            }

            Write-RGB $stringRepresentation  -FC "#1177CC"


            #            Write-Error "Invalid hex color format. Valid formats: #RGB, #RRGGBB"
            return $null
        }

        # Расширение сокращенной формы (3 символа -> 6)
        if ($cleanHex.Length -eq 3)
        {
            $cleanHex = $cleanHex -replace '(.)(.)(.)', '$1$1$2$2$3$3'
        }

        # Извлечение компонентов с помощью регулярного выражения
        if ($cleanHex -match '^([A-F0-9]{2})([A-F0-9]{2})([A-F0-9]{2})$')
        {
            try
            {
                return [PSCustomObject]@{
                    R = [Convert]::ToInt32($Matches[1], 16)
                    G = [Convert]::ToInt32($Matches[2], 16)
                    B = [Convert]::ToInt32($Matches[3], 16)
                }
            }
            catch
            {
                Write-Error "Conversion error: $_"
                return $null
            }
        }

        Write-Error "Unexpected error during hex parsing"
        return $null
    }

    # Функция для конвертации RGB в hex
    function ConvertFrom-RGBToHex
    {
        param([int]$R, [int]$G, [int]$B)

        $R = [Math]::Max(0,[Math]::Min(255, $R))
        $G = [Math]::Max(0,[Math]::Min(255, $G))
        $B = [Math]::Max(0,[Math]::Min(255, $B))

        return "#{0:X2}{1:X2}{2:X2}" -f $R, $G, $B
    }

    # Функция для расчета позиции в градиенте
    function Get-GradientPosition
    {
        param([int]$Index, [int]$Total, [string]$Type, [scriptblock]$CustomFunc)

        if ($Total -le 1)
        {
            return 0
        }

        $normalizedIndex = $Index / ($Total - 1)

        switch ($Type)
        {
            "Linear" {
                return $normalizedIndex
            }
            "Exponential" {
                return [Math]::Pow($normalizedIndex, 2)
            }
            "Sine" {
                return [Math]::Sin($normalizedIndex * [Math]::PI / 2)
            }
            "Custom" {
                if ($CustomFunc)
                {
                    return & $CustomFunc $normalizedIndex
                }
                else
                {
                    return $normalizedIndex
                }
            }
            default {
                return $normalizedIndex
            }
        }
    }

    # Обработка особых случаев
    if ($TotalItems -eq 1)
    {
        return $StartColor
    }

    if ($Index -eq 0 -and -not $Reverse)
    {
        return $StartColor
    }

    if ($Index -eq ($TotalItems - 1) -and -not $Reverse)
    {
        return $EndColor
    }

    # Реверс если нужно
    if ($Reverse)
    {
        $temp = $StartColor
        $StartColor = $EndColor
        $EndColor = $temp
    }

    # Конвертация цветов
    $startRGB = ConvertFrom-HexToRGB $StartColor
    $endRGB = ConvertFrom-HexToRGB $EndColor

    # Расчет позиции в градиенте
    $position = Get-GradientPosition -Index $Index -Total $TotalItems -Type $GradientType -CustomFunc $CustomFunction

    # Применение коэффициентов к каналам
    $redDiff = ($endRGB.R - $startRGB.R) * $position * $RedCoefficient
    $greenDiff = ($endRGB.G - $startRGB.G) * $position * $GreenCoefficient
    $blueDiff = ($endRGB.B - $startRGB.B) * $position * $BlueCoefficient

    # Расчет итоговых значений RGB
    $finalR = [int]($startRGB.R + $redDiff)
    $finalG = [int]($startRGB.G + $greenDiff)
    $finalB = [int]($startRGB.B + $blueDiff)

    # Применение насыщенности и яркости
    if ($Saturation -ne 100 -or $Brightness -ne 100)
    {
        $satFactor = $Saturation / 100.0
        $brightFactor = $Brightness / 100.0

        # Простая коррекция насыщенности и яркости
        $gray = ($finalR + $finalG + $finalB) / 3
        $finalR = [int](($finalR - $gray) * $satFactor + $gray) * $brightFactor
        $finalG = [int](($finalG - $gray) * $satFactor + $gray) * $brightFactor
        $finalB = [int](($finalB - $gray) * $satFactor + $gray) * $brightFactor
    }

    return ConvertFrom-RGBToHex $finalR $finalG $finalB
}

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

#function Test-GradientIntensity
#{
#    <#
#    .SYNOPSIS
#        Показывает эффект параметра Intensity
#    #>
#    param(
#        [string]$StartColor = "#FFFF00",
#        [string]$EndColor = "#FF00FF"
#    )
#
#    Write-RGB "`n=== Интенсивность градиента ===" -FC "Cyan" -Style Bold -newline
#
#    $intensities = @(0.5, 1.0, 2.0, 5.0)
#
#    foreach ($intensity in $intensities)
#    {
#        Write-RGB "`nIntensity $intensity`: " -FC "White"
#
#        for ($i = 0; $i -lt 20; $i++) {
#            $color = Get-GradientColor -Index $i -TotalItems 20 `
#                                     -StartColor $StartColor -EndColor $EndColor `
#                                     -GradientType "Exponential" `
#                                     -Intensity $intensity
#            Write-RGB "█" -FC $color
#        }
#    }
#    Write-Host ""
#}

function Show-GradientPalettes
{
    <#
    .SYNOPSIS
        Показывает предустановленные градиентные палитры
    #>

    Write-RGB "`n=== Градиентные палитры ===" -FC "Cyan" -Style Bold -newline

    $palettes = @{
        "🌊 Ocean" = @{ Start = "#0080FF"; End = "#00FFD4" }
        "🔥 Fire" = @{ Start = "#FF0000"; End = "#FFD700" }
        "🌿 Nature" = @{ Start = "#00FF00"; End = "#90EE90" }
        "💜 Neon" = @{ Start = "#FF00FF"; End = "#00FFFF" }
        "🌸 Pastel" = @{ Start = "#FFB6C1"; End = "#E6E6FA" }
        "🇺🇦 Ukraine" = @{ Start = "#0057B7"; End = "#FFD500" }
        "🦇 Dracula" = @{ Start = "#FF79C6"; End = "#BD93F9" }
        "🌅 Sunset" = @{ Start = "#FF5E3A"; End = "#FF2A68" }
        "🌌 Galaxy" = @{ Start = "#667EEA"; End = "#764BA2" }
        "🍭 Candy" = @{ Start = "#F093FB"; End = "#F5576C" }
    }

    foreach ($palette in $palettes.GetEnumerator())
    {
        Write-RGB "`n$( $palette.Key ): " -FC "White" -Style Bold

        for ($i = 0; $i -lt 30; $i++) {
            $color = Get-GradientColor -Index $i -TotalItems 30 `
                                     -StartColor $palette.Value.Start `
                                     -EndColor $palette.Value.End
            Write-RGB "█" -FC $color
        }
    }
    Write-Host "`n"
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


function Write-RBGLine
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

function Write-RBGNoNewLine
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

    $chars = $Text.ToCharArray()
    $length = $chars.Length
    for ($i = 0; $i -lt $length; $i++) {
        # Получаем цвет для текущего символа
        $color = Get-GradientColor -Index $i -TotalItems $length `
                                  -StartColor $StartColor -EndColor $EndColor `
                                  -GradientType $GradientType
        #        $GradientType -Reverse:$Reverse

        # Выводим символ
        Write-RGB -Text $chars[$i] -FC $color -Style $Style

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

    $rgb = ConvertFrom-HexToRGB $HexColor

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
        @{
            Start = "#FF0000"; End = "#0000FF"; Name = "Красный → Синий"
        },
        @{
            Start = "#FFFF00"; End = "#FF00FF"; Name = "Желтый → Пурпурный"
        },
        @{
            Start = "#00FF00"; End = "#FF8000"; Name = "Зеленый → Оранжевый"
        }
        @{
            Start = "#00FF00"; End = "#FF8000"; Name = "Зеленый → Оранжевый"
        }
    )

    foreach ($colorPair in ( $colorPairs | Sort-Object))
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
        [string]$Palette = "All"
    )

    $paletteColors = switch ($Palette)
    {
        "NordKeys" {
            $global:RGB.Keys | Where-Object {
                $_ -like "Nord_*"
            }
        }
        "Dracula"  {
            $global:RGB.Keys | Where-Object {
                $_ -like "Dracula_*"
            }
        }
        "Material" {
            $global:RGB.Keys | Where-Object {
                $_ -like "Material_*"
            }
        }
        "Cyber"    {
            $global:RGB.Keys | Where-Object {
                $_ -like "Cyber_*"
            }
        }
        "OneDark"  {
            $global:RGB.Keys | Where-Object {
                $_ -like "OneDark_*"
            }
        }
        "Pastel"   {
            $global:RGB.Keys | Where-Object {
                $_ -like "Pastel*"
            }
        }
        "Neon"     {
            $global:RGB.Keys | Where-Object {
                $_ -like "*Neon*" -or $_ -like "*Electric*"
            }
        }
        "All"      {
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
        Write-RGB "■ $keyPrev ■           " -FC $keyPrev
        Write-RGB "■ $key ■" -FC $key -newline
        Write-GradientLine -Length 50 -Char "██" -StartColor $valuePrev -EndColor  $value
        Write-RGB  "" -newline
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
    Write-GradientText -Text $Title -StartColor $StartColor -EndColor $EndColor -NoNewline
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
        $list = (Get-Command)
    )
    $i = 0
    $list | ForEach-Object {
        $cmd = $_.Name
        $hex1 = NumberToHexPair $i
        $hex2 = NumberToHexPair (256 - $i)
        $hex3 = NumberToHexPair ($i - 256/2 + $i)
        Write-GradientText $cmd  -StartColor "#${hex3}${hex1}${hex2}" -EndColor "#${hex2}${hex2}${hex1}"
        $i++
    }

    Write-Host""
}

function GetGradientIcons{


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

    $len = $Text.Length
    for ($i = 0; $i -lt $len; $i++) {
        $r = [int]($R1 + ($R2 - $R1) * $i / ($len - 1))
        $g = [int]($G1 + ($G2 - $G1) * $i / ($len - 1))
        $b = [int]($B1 + ($B2 - $B1) * $i / ($len - 1))

        $br = [int]($BR1 + ($BR2 - $BR1) * $i / ($len - 1))
        $bg = [int]($BG1 + ($BG2 - $BG1) * $i / ($len - 1))
        $bb = [int]($BB1 + ($BB2 - $BB1) * $i / ($len - 1))

        $ansi = "`e[38;2;${r};${g};${b}m`e[48;2;${br};${bg};${bb}m"
        Write-Host "$ansi$( $Text[$i] )" -NoNewline
    }
    Write-Host "`e[0m"  # Сброс стиля
}


function Write-Status
{
    param(
        [string]$Message,
        [switch]$Success,
        [switch]$Warning,
        [switch]$Problem,
        [switch]$Critical,
        [switch]$Info
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

    Write-RGB $icon  -FC $color
    Write-RGB $Message -FC $color
}

#Get-GradientList
#Write-Host""
importProcess  $MyInvocation.MyCommand.Name.trim('.ps1')






