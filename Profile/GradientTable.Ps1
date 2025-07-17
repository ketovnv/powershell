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

# Функция для создания градиентного меню
function Show-GradientMenu {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$MenuItems,

        [Parameter(Mandatory = $false)]
        [string]$Title = "Меню",

        [Parameter(Mandatory = $false)]
        [hashtable]$GradientOptions = @{}
    )

    Write-Host "`n$Title" -ForegroundColor Yellow
    Write-Host ("=" * $Title.Length) -ForegroundColor Yellow

    for ($i = 0; $i -lt $MenuItems.Count; $i++) {
        $colorParams = @{
            Index = $i
            TotalItems = $MenuItems.Count
        }

        # Объединение с пользовательскими настройками
        foreach ($key in $GradientOptions.Keys) {
            $colorParams[$key] = $GradientOptions[$key]
        }

        $color = Get-GradientColor @colorParams

        # Конвертация hex в консольный цвет (приблизительно)
        $consoleColor = Get-ConsoleColor $color

        Write-Host "$($i + 1). $($MenuItems[$i])" -ForegroundColor $consoleColor
    }

    Write-Host "`nВыберите пункт меню (1-$($MenuItems.Count)): " -NoNewline -ForegroundColor Gray
}

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

# Функция для конвертации hex в RGB (дублирование для доступности вне основной функции)
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


#>