# Улучшенный скрипт для работы с цветами в PowerShell
# Версия: 2.0
# Исправления и улучшения

#region Инициализация
$global:RGB = @{}

# Проверяем поддержку ANSI/PSStyle сразу
$global:ColorSupport = $null -ne $PSStyle

if (-not $global:ColorSupport) {
    Write-Warning "Ваша версия PowerShell не поддерживает PSStyle. Некоторые функции будут недоступны."
}
#endregion

#region Цветовые палитры
# Палитры в формате HEX (упорядочены и дополнены)
$newHexColors = @{
# Палитра Nord (спокойные и элегантные тона)
    "Nord_PolarNight"   = "#2E3440" # Очень темный сине-серый
    "Nord_DarkBlue"     = "#3B4252" # Темно-синий
    "Nord_SteelBlue"    = "#4C566A" # Стальной синий
    "Nord_LightGray"    = "#D8DEE9" # Светло-серый
    "Nord_Snow"         = "#D8DEE9" # Снежный (дубликат убран)
    "Nord_White"        = "#ECEFF4" # Почти белый
    "Nord_FrostBlue"    = "#88C0D0" # Морозный голубой
    "Nord_FrostGreen"   = "#8FBCBB" # Морозный зеленый
    "Nord_AuroraRed"    = "#BF616A" # Аврора (красный)
    "Nord_AuroraOrange" = "#D08770" # Аврора (оранжевый)
    "Nord_AuroraYellow" = "#EBCB8B" # Аврора (желтый)
    "Nord_AuroraGreen"  = "#A3BE8C" # Аврора (зеленый)
    "Nord_AuroraPurple" = "#B48EAD" # Аврора (фиолетовый)

    # Палитра Dracula (яркая и контрастная)
    "Dracula_Background"  = "#282A36" # Фон
    "Dracula_CurrentLine" = "#44475A" # Выделение строки
    "Dracula_Foreground"  = "#F8F8F2" # Текст
    "Dracula_Comment"     = "#6272A4" # Комментарий
    "Dracula_Cyan"        = "#8BE9FD" # Циан
    "Dracula_Green"       = "#50FA7B" # Зеленый
    "Dracula_Orange"      = "#FFB86C" # Оранжевый
    "Dracula_Pink"        = "#FF79C6" # Розовый
    "Dracula_Purple"      = "#BD93F9" # Фиолетовый
    "Dracula_Red"         = "#FF5555" # Красный
    "Dracula_Yellow"      = "#F1FA8C" # Желтый

    # Палитра Material Design
    "Material_Red"        = "#F44336"
    "Material_Pink"       = "#E91E63"
    "Material_Purple"     = "#9C27B0"
    "Material_DeepPurple" = "#673AB7"
    "Material_Indigo"     = "#3F51B5"
    "Material_Blue"       = "#2196F3"
    "Material_LightBlue"  = "#03A9F4"
    "Material_Cyan"       = "#00BCD4"
    "Material_Teal"       = "#009688"
    "Material_Green"      = "#4CAF50"
    "Material_LightGreen" = "#8BC34A"
    "Material_Lime"       = "#CDDC39"
    "Material_Yellow"     = "#FFEB3B"
    "Material_Amber"      = "#FFC107"
    "Material_Orange"     = "#FF9800"
    "Material_DeepOrange" = "#FF5722"
    "Material_Brown"      = "#795548"
    "Material_Grey"       = "#9E9E9E"
    "Material_BlueGrey"   = "#607D8B"

    # Новая палитра - Cyber/Synthwave
    "Cyber_Neon"          = "#00FFFF"
    "Cyber_Pink"          = "#FF006E"
    "Cyber_Purple"        = "#8338EC"
    "Cyber_Blue"          = "#006FFF"
    "Cyber_Green"         = "#00F5FF"
    "Cyber_Orange"        = "#FF9500"
    "Cyber_Background"    = "#0D1117"
    "Cyber_Dark"          = "#161B22"

    # Палитра One Dark (популярна в VS Code)
    "OneDark_Background"  = "#282C34"
    "OneDark_Red"         = "#E06C75"
    "OneDark_Green"       = "#98C379"
    "OneDark_Yellow"      = "#E5C07B"
    "OneDark_Blue"        = "#61AFEF"
    "OneDark_Purple"      = "#C678DD"
    "OneDark_Cyan"        = "#56B6C2"
    "OneDark_White"       = "#ABB2BF"
}

$additionalColors = @{
# Пастельные тона
    "PastelPink"     = "#FFD1DC"
    "PastelBlue"     = "#AEC6CF"
    "PastelGreen"    = "#77DD77"
    "PastelYellow"   = "#FDFD96"
    "PastelPurple"   = "#B19CD9"
    "PastelLavender" = "#E6E6FA"
    "PastelMint"     = "#F5FFFA"
    "PastelPeach"    = "#FFCBA4"

    # Металлические оттенки
    "Silver"         = "#C0C0C0"
    "Bronze"         = "#CD7F32"
    "Copper"         = "#B87333"
    "Platinum"       = "#E5E4E2"
    "Rose Gold"      = "#E8B4B8"
    "Champagne"      = "#F7E7CE"

    # Природные цвета
    "SkyBlue"        = "#87CEEB"
    "SeaGreen"       = "#2E8B57"
    "SandyBrown"     = "#F4A460"
    "Turquoise"      = "#40E0D0"
    "Olive"          = "#808000"
    "Maroon"         = "#800000"
    "Navy"           = "#000080"

    # Энергетические/неоновые цвета
    "ElectricLime"   = "#CCFF00"
    "LaserRed"       = "#FF0F0F"
    "NeonOrange"     = "#FF6600"
    "PlasmaViolet"   = "#8B00FF"
    "ElectricBlue"   = "#7DF9FF"
    "NeonGreen"      = "#39FF14"
    "HotPink"        = "#FF69B4"

    # Дополнительные популярные цвета
    "Lavender"       = "#E6E6FA"
    "Coral"          = "#FF7F50"
    "Mint"           = "#98FB98"
    "Salmon"         = "#FA8072"
    "DeepPurple"     = "#6A0DAD"
    "OceanBlue"      = "#006994"
    "ForestGreen"    = "#228B22"
    "SunsetOrange"   = "#FF8C00"
    "RoyalPurple"    = "#7851A9"
    "LimeGreen"      = "#32CD32"
    "GoldYellow"     = "#FFD700"
    "CrimsonRed"     = "#DC143C"
    "TealBlue"       = "#008080"
    "Violet"         = "#8A2BE2"
    "Indigo"         = "#4B0082"

    # Украинские цвета 🇺🇦
    "UkraineBlue"    = "#0057B7"
    "UkraineYellow"  = "#FFD500"
}

# RGB версии цветов (оптимизированы)
$colorsRGB = @{
# Основные цвета (исправлены для лучшего отображения)
    "WhiteRGB"        = @{ R = 255; G = 255; B = 255 }
    "CyanRGB"         = @{ R = 0; G = 255; B = 255 }
    "MagentaRGB"      = @{ R = 255; G = 0; B = 255 }
    "YellowRGB"       = @{ R = 255; G = 255; B = 0 }
    "OrangeRGB"       = @{ R = 255; G = 165; B = 0 }
    "PinkRGB"         = @{ R = 255; G = 192; B = 203 }
    "PurpleRGB"       = @{ R = 128; G = 0; B = 128 }
    "LimeRGB"         = @{ R = 0; G = 255; B = 0 }
    "TealRGB"         = @{ R = 0; G = 128; B = 128 }
    "GoldRGB"         = @{ R = 255; G = 215; B = 0 }
    "CocoaBeanRGB"    = @{ R = 79; G = 56; B = 53 }

    # Неоновые цвета
    "NeonBlueRGB"     = @{ R = 77; G = 200; B = 255 }
    "NeonGreenRGB"    = @{ R = 57; G = 255; B = 20 }
    "NeonPinkRGB"     = @{ R = 255; G = 70; B = 200 }
    "NeonRedRGB"      = @{ R = 255; G = 55; B = 100 }

    # Градиентные цвета
    "Sunset1RGB"      = @{ R = 255; G = 94; B = 77 }
    "Sunset2RGB"      = @{ R = 255; G = 154; B = 0 }
    "Ocean1RGB"       = @{ R = 0; G = 119; B = 190 }
    "Ocean2RGB"       = @{ R = 0; G = 180; B = 216 }
    "Ocean3RGB"       = @{ R = 0; G = 150; B = 160 }
    "Ocean4RGB"       = @{ R = 0; G = 205; B = 230 }

    # Украинские цвета (исправленные)
    "UkraineBlueRGB"  = @{ R = 0; G = 87; B = 183 }
    "UkraineYellowRGB"= @{ R = 255; G = 213; B = 0 }
}
#endregion

#region Утилитарные функции

function Test-ColorSupport {
    <#
    .SYNOPSIS
        Проверяет поддержку цветов в текущем окружении
    #>
    return $null -ne $PSStyle
}

function ConvertTo-RGBComponents {
    <#
    .SYNOPSIS
        Конвертирует HEX цвет в RGB компоненты
    
    .PARAMETER HexColor
        HEX цвет (например, #FF0000 или FF0000)
    #>
    param([string]$HexColor)

    if ([string]::IsNullOrEmpty($HexColor)) {
        throw "Цвет не может быть пустым"
    }

    $hex = $HexColor.TrimStart('#')

    # Поддержка сокращенного формата (#RGB -> #RRGGBB)
    if ($hex.Length -eq 3) {
        $hex = $hex[0] + $hex[0] + $hex[1] + $hex[1] + $hex[2] + $hex[2]
    }

    if ($hex.Length -ne 6) {
        throw "Неверный формат HEX цвета: $HexColor"
    }

    try {
        return @{
            R = [Convert]::ToInt32($hex.Substring(0, 2), 16)
            G = [Convert]::ToInt32($hex.Substring(2, 2), 16)
            B = [Convert]::ToInt32($hex.Substring(4, 2), 16)
        }
    }
    catch {
        throw "Ошибка при конвертации цвета $HexColor : $_"
    }
}

function ConvertFrom-RGBToHex {
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

    if ($PSCmdlet.ParameterSetName -eq 'Hashtable') {
        $R = $Color.R
        $G = $Color.G
        $B = $Color.B
    }

    return "#{0:X2}{1:X2}{2:X2}" -f $R, $G, $B
}

function Get-RGBColor {
    <#
    .SYNOPSIS
        Получает ANSI последовательность для RGB цвета
    #>
    param($Color)

    if (-not (Test-ColorSupport)) {
        return ""
    }

    if ($Color -is [hashtable] -and $Color.ContainsKey('R') -and $Color.ContainsKey('G') -and $Color.ContainsKey('B')) {
        return $PSStyle.Foreground.FromRgb($Color.R, $Color.G, $Color.B)
    }
    elseif ($Color -is [string] -and $Color -match '^#?[0-9A-Fa-f]{3,6}$') {
        $rgb = ConvertTo-RGBComponents -HexColor $Color
        return $PSStyle.Foreground.FromRgb($rgb.R, $rgb.G, $rgb.B)
    }
    else {
        Write-Warning "Неверный формат цвета: $Color"
        return ""
    }
}

function Get-RGBBackgroundColor {
    <#
    .SYNOPSIS
        Получает ANSI последовательность для RGB цвета фона
    #>
    param($Color)

    if (-not (Test-ColorSupport)) {
        return ""
    }

    if ($Color -is [hashtable] -and $Color.ContainsKey('R') -and $Color.ContainsKey('G') -and $Color.ContainsKey('B')) {
        return $PSStyle.Background.FromRgb($Color.R, $Color.G, $Color.B)
    }
    elseif ($Color -is [string] -and $Color -match '^#?[0-9A-Fa-f]{3,6}$') {
        $rgb = ConvertTo-RGBComponents -HexColor $Color
        return $PSStyle.Background.FromRgb($rgb.R, $rgb.G, $rgb.B)
    }
    else {
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
foreach ($color in $allHexColors.GetEnumerator()) {
    if (-not $global:RGB.ContainsKey($color.Key)) {
        $global:RGB[$color.Key] = $color.Value
    }
}

foreach ($color in $allRgbColors.GetEnumerator()) {
    if (-not $global:RGB.ContainsKey($color.Key)) {
        $global:RGB[$color.Key] = $color.Value
    }
}
#endregion

#region Основная функция Write-RGB (улучшенная)
function Write-RGB {
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
        Write-RGB "Warning!" -FC "ElectricLime" -BC "#2C0000" -Style Blink
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
        if (-not (Test-ColorSupport)) {
            Write-Warning "PSStyle не поддерживается в данной версии PowerShell"
            # Fallback к обычному Write-Host
            $fallbackParams = @{}
            if ($FC -and $FC -in @('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')) {
                $fallbackParams['ForegroundColor'] = $FC
            }
            if ($BC -and $BC -in @('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')) {
                $fallbackParams['BackgroundColor'] = $BC
            }

            Write-Host ($Text -join ' ') @fallbackParams
            return
        }
    }

    process {
        $fullText = $Text -join ' '

        # Обработка параметров совместимости

        if ($Bold -and $Style -notcontains 'Bold') { $Style += 'Bold' }

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

        # Системные цвета PowerShell
        $systemColors = @('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')

        # Применение цвета переднего плана
        if ($FC -in $systemColors) {
            $output += $PSStyle.Foreground.$FC
        } elseif ($global:RGB.ContainsKey($FC)) {
            $output += Get-RGBColor $global:RGB[$FC]
        } elseif ($FC -match '^#?[0-9A-Fa-f]{3,6}$') {
            $output += Get-RGBColor $FC
        } else {
            # Пытаемся найти без суффикса RGB
            $baseName = $FC -replace 'RGB$', ''
            if ($global:RGB.ContainsKey($baseName)) {
                $output += Get-RGBColor $global:RGB[$baseName]
            } else {
                Write-Warning "Неизвестный цвет: $FC. Используется белый."
                $output += $PSStyle.Foreground.White
            }
        }

        # Применение цвета фона
        if ($BC) {
            if ($BC -in $systemColors) {
                $output += $PSStyle.Background.$BC
            } elseif ($global:RGB.ContainsKey($BC)) {
                $output += Get-RGBBackgroundColor $global:RGB[$BC]
            } elseif ($BC -match '^#?[0-9A-Fa-f]{3,6}$') {
                $output += Get-RGBBackgroundColor $BC
            } else {
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

#region Функции для градиентов (улучшенные)
function Get-GradientColor {
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
    function ConvertFrom-HexToRGB {
        param([string]$HexColor)

        $HexColor = $HexColor.TrimStart('#')
        if ($HexColor.Length -eq 3) {
            $HexColor = $HexColor[0] + $HexColor[0] + $HexColor[1] + $HexColor[1] + $HexColor[2] + $HexColor[2]
        }

        $R = [Convert]::ToInt32($HexColor.Substring(0, 2), 16)
        $G = [Convert]::ToInt32($HexColor.Substring(2, 2), 16)
        $B = [Convert]::ToInt32($HexColor.Substring(4, 2), 16)

        return @{ R = $R; G = $G; B = $B }
    }

    # Функция для конвертации RGB в hex
    function ConvertFrom-RGBToHex {
        param([int]$R, [int]$G, [int]$B)

        $R = [Math]::Max(0, [Math]::Min(255, $R))
        $G = [Math]::Max(0, [Math]::Min(255, $G))
        $B = [Math]::Max(0, [Math]::Min(255, $B))

        return "#{0:X2}{1:X2}{2:X2}" -f $R, $G, $B
    }

    # Функция для расчета позиции в градиенте
    function Get-GradientPosition {
        param([int]$Index, [int]$Total, [string]$Type, [scriptblock]$CustomFunc)

        if ($Total -le 1) { return 0 }

        $normalizedIndex = $Index / ($Total - 1)

        switch ($Type) {
            "Linear" { return $normalizedIndex }
            "Exponential" { return [Math]::Pow($normalizedIndex, 2) }
            "Sine" { return [Math]::Sin($normalizedIndex * [Math]::PI / 2) }
            "Custom" {
                if ($CustomFunc) {
                    return & $CustomFunc $normalizedIndex
                } else {
                    return $normalizedIndex
                }
            }
            default { return $normalizedIndex }
        }
    }

    # Обработка особых случаев
    if ($TotalItems -eq 1) {
        return $StartColor
    }

    if ($Index -eq 0 -and -not $Reverse) {
        return $StartColor
    }

    if ($Index -eq ($TotalItems - 1) -and -not $Reverse) {
        return $EndColor
    }

    # Реверс если нужно
    if ($Reverse) {
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
    if ($Saturation -ne 100 -or $Brightness -ne 100) {
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

function Write-GradientText {
    <#
    .SYNOPSIS
        Выводит текст с градиентом
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Text,
        [string]$StartColor = "#FFFF00",
        [string]$EndColor = "#0000FF",
        [string[]]$Style = @('Normal'),
        [ValidateSet("Linear", "Exponential", "Sine", "Cosine")]
        [string]$GradientType = "Linear",
        [switch]$NoNewline
    )

    if ([string]::IsNullOrEmpty($Text)) {
        Write-Warning "Текст не может быть пустым"
        return
    }

    $chars = $Text.ToCharArray()
    $length = $chars.Length

    for ($i = 0; $i -lt $length; $i++) {
        $position = if ($length -eq 1) { 0.5 } else { $i / ($length - 1) }
        $color = Get-GradientColor -StartColor $StartColor -EndColor $EndColor -Position $position -GradientType $GradientType

        Write-RGB -Text $chars[$i] -FC $color -Style $Style
    }

    if (-not $NoNewline) {
        Write-Host ""
    }
}
#endregion


#region Утилитарные функции для работы с палитрой
# Вспомогательная функция для приблизительного соответствия консольным цветам
function Get-ConsoleColor {
    param([string]$HexColor)

    $rgb = ConvertFrom-HexToRGB $HexColor

    # Простая логика выбора ближайшего консольного цвета
    $colors = @{
        "Red" = @{R=255; G=0; B=0}
        "Green" = @{R=0; G=255; B=0}
        "Blue" = @{R=0; G=0; B=255}
        "Yellow" = @{R=255; G=255; B=0}
        "Cyan" = @{R=0; G=255; B=255}
        "Magenta" = @{R=255; G=0; B=255}
        "White" = @{R=255; G=255; B=255}
        "Gray" = @{R=128; G=128; B=128}
        "DarkRed" = @{R=128; G=0; B=0}
        "DarkGreen" = @{R=0; G=128; B=0}
        "DarkBlue" = @{R=0; G=0; B=128}
        "DarkYellow" = @{R=128; G=128; B=0}
        "DarkCyan" = @{R=0; G=128; B=128}
        "DarkMagenta" = @{R=128; G=0; B=128}
        "DarkGray" = @{R=64; G=64; B=64}
    }

    $minDistance = [double]::MaxValue
    $closestColor = "White"

    foreach ($colorName in $colors.Keys) {
        $distance = [Math]::Sqrt(
                [Math]::Pow($rgb.R - $colors[$colorName].R, 2) +
                        [Math]::Pow($rgb.G - $colors[$colorName].G, 2) +
                        [Math]::Pow($rgb.B - $colors[$colorName].B, 2)
        )

        if ($distance -lt $minDistance) {
            $minDistance = $distance
            $closestColor = $colorName
        }
    }

    return $closestColor
}


function Show-Colors {
    <#
    .SYNOPSIS
        Показывает все доступные цвета
    #>
    param(
        [int]$ColumnsPerRow = 4,
        [string]$Filter = "*"
    )

    Write-Host "`n=== Доступные цвета ===`n" -ForegroundColor Cyan

    $filteredColors = $global:RGB.Keys | Where-Object { $_ -like $Filter } | Sort-Object
    $colorIndex = 0

    foreach ($colorName in $filteredColors) {
        # Показываем образец цвета
        Write-RGB "  $colorName " -FC $colorName

        $colorIndex++
        if ($colorIndex % $ColumnsPerRow -eq 0) {
            Write-Host ""
        }
    }

    Write-Host "`n"
    Write-Host "Всего цветов: $($filteredColors.Count)" -ForegroundColor Yellow
}

function Show-Palette {
    <#
    .SYNOPSIS
        Показывает цвета определенной палитры
    #>
    param(
        [ValidateSet("Nord", "Dracula", "Material", "Cyber", "OneDark", "Pastel", "Neon", "All")]
        [string]$Palette = "All"
    )

    $paletteColors = switch ($Palette) {
        "Nord" { $global:RGB.Keys | Where-Object { $_ -like "Nord_*" } }
        "Dracula" { $global:RGB.Keys | Where-Object { $_ -like "Dracula_*" } }
        "Material" { $global:RGB.Keys | Where-Object { $_ -like "Material_*" } }
        "Cyber" { $global:RGB.Keys | Where-Object { $_ -like "Cyber_*" } }
        "OneDark" { $global:RGB.Keys | Where-Object { $_ -like "OneDark_*" } }
        "Pastel" { $global:RGB.Keys | Where-Object { $_ -like "Pastel*" } }
        "Neon" { $global:RGB.Keys | Where-Object { $_ -like "*Neon*" -or $_ -like "*Electric*" } }
        "All" { $global:RGB.Keys }
    }

    Write-Host "`n=== Палитра: $Palette ===`n" -ForegroundColor Cyan

    foreach ($colorName in ($paletteColors | Sort-Object)) {
        Write-RGB "■ $colorName " -FC $colorName
    }

    Write-Host ""
}

function Test-GradientDemo
{
    <#
    .SYNOPSIS
        Демонстрация градиентов
    #>
    param(
        [string]$Text = "Gradient Demo!"
    )

    Write-Host "`n=== Демонстрация градиентов ===`n" -ForegroundColor Cyan

    $gradientTypes = @("Linear", "Exponential", "Sine", "Cosine")
    $colorPairs = @(
        @{ Start = "#FF0000"; End = "#0000FF"; Name = "Красный → Синий" },
        @{ Start = "#FFFF00"; End = "#FF00FF"; Name = "Желтый → Пурпурный" },
        @{ Start = "#00FF00"; End = "#FF8000"; Name = "Зеленый → Оранжевый" }
    )

    foreach ($colorPair in ( $colorPairs | Sort-Object))
    {
        Get-GradientColor "■ $colorPair.Name " $colorPair.Start $colorPair.End
    }
}