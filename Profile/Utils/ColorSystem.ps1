Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start
# ColorSystem.psm1 - Централизованный модуль управления цветами

#region Configuration
$script:ColorSystemConfig = @{
# Кеширование для производительности
    Cache = @{
        Enabled = $true
        ColorConversions = @{}
        FileColors = @{}
        GradientColors = @{}
    }

    # Настройки по умолчанию
    Defaults = @{
        ForegroundColor = 'White'
        BackgroundColor = $null
        GradientSteps = 256
        AnimationSpeed = 50
    }

    # Поддержка тем
    CurrentTheme = 'Default'
    Themes = @{
        Default = @{
            Primary = '#0080FF'
            Secondary = '#FF0080'
            Success = '#00FF00'
            Warning = '#FFD700'
            Error = '#FF0000'
            Info = '#00BFFF'
        }
        Dark = @{
            Primary = '#4A90E2'
            Secondary = '#E91E63'
            Success = '#4CAF50'
            Warning = '#FFC107'
            Error = '#F44336'
            Info = '#2196F3'
        }
        Ukraine = @{
            Primary = '#0057B7'
            Secondary = '#FFD500'
            Success = '#0057B7'
            Warning = '#FFD500'
            Error = '#FF0000'
            Info = '#0057B7'
        }
    }
}

# Ленивая инициализация поддержки цветов
$script:ColorSupportChecked = $false
$script:ColorSupportResult = $null

function Test-ColorSupport {
    if (-not $script:ColorSupportChecked) {
        $script:ColorSupportResult = $null -ne $PSStyle
        $script:ColorSupportChecked = $true
    }
    return $script:ColorSupportResult
}
#endregion

#region Color Conversion with Caching
function ConvertTo-RGBComponents {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$HexColor
    )

    # Проверка кеша
    $cacheKey = $HexColor.ToUpper()
    if ($script:ColorSystemConfig.Cache.Enabled -and
            $script:ColorSystemConfig.Cache.ColorConversions.ContainsKey($cacheKey)) {
        return $script:ColorSystemConfig.Cache.ColorConversions[$cacheKey]
    }

    $hex = $HexColor.TrimStart('#')

    # Поддержка 3-символьного формата
    if ($hex.Length -eq 3) {
        $hex = "$($hex[0])$($hex[0])$($hex[1])$($hex[1])$($hex[2])$($hex[2])"
    }

    # Валидация
    if ($hex -notmatch '^[0-9A-Fa-f]{6}$') {
        throw "Invalid hex color format: $HexColor"
    }

    $result = @{
        R = [Convert]::ToInt32($hex.Substring(0, 2), 16)
        G = [Convert]::ToInt32($hex.Substring(2, 2), 16)
        B = [Convert]::ToInt32($hex.Substring(4, 2), 16)
    }

    # Сохранение в кеш
    if ($script:ColorSystemConfig.Cache.Enabled) {
        $script:ColorSystemConfig.Cache.ColorConversions[$cacheKey] = $result
    }

    return $result
}

function ConvertFrom-RGBToHex {
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

    if ($PSCmdlet.ParameterSetName -eq 'Object') {
        $R = $RGB.R
        $G = $RGB.G
        $B = $RGB.B
    }

    return '#{0:X2}{1:X2}{2:X2}' -f $R, $G, $B
}
#endregion

#region Theme Management
function Set-ColorTheme {
    param(
        [ValidateSet('Default', 'Dark', 'Ukraine', 'Custom')]
        [string]$Theme,

        [hashtable]$CustomTheme
    )

    if ($Theme -eq 'Custom' -and $CustomTheme) {
        $script:ColorSystemConfig.Themes.Custom = $CustomTheme
    }

    $script:ColorSystemConfig.CurrentTheme = $Theme

    # Очистка кешей при смене темы
    Clear-ColorCache
}

function Get-ThemeColor {
    param(
        [ValidateSet('Primary', 'Secondary', 'Success', 'Warning', 'Error', 'Info')]
        [string]$ColorType
    )

    $theme = $script:ColorSystemConfig.Themes[$script:ColorSystemConfig.CurrentTheme]
    return $theme[$ColorType]
}
#endregion

#region Optimized Gradient System
function Get-GradientColor {
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

    # Генерация ключа кеша
    if ($UseCache) {
        $cacheKey = "$Index|$TotalItems|$StartColor|$EndColor|$GradientType"
        if ($script:ColorSystemConfig.Cache.GradientColors.ContainsKey($cacheKey)) {
            return $script:ColorSystemConfig.Cache.GradientColors[$cacheKey]
        }
    }

    # Оптимизация для крайних случаев
    if ($TotalItems -le 1) { return $StartColor }
    if ($Index -eq 0) { return $StartColor }
    if ($Index -eq $TotalItems - 1) { return $EndColor }

    # Расчет позиции
    $position = switch ($GradientType) {
        'Linear' { $Index / ($TotalItems - 1) }
        'Exponential' { [Math]::Pow($Index / ($TotalItems - 1), 2) }
        'Sine' { [Math]::Sin($Index / ($TotalItems - 1) * [Math]::PI / 2) }
        'Cosine' { 1 - [Math]::Cos($Index / ($TotalItems - 1) * [Math]::PI / 2) }
        'Quadratic' {
            $t = $Index / ($TotalItems - 1)
            if ($t -lt 0.5) { 2 * $t * $t } else { 1 - [Math]::Pow(-2 * $t + 2, 2) / 2 }
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
    if ($UseCache) {
        $script:ColorSystemConfig.Cache.GradientColors[$cacheKey] = $result
    }

    return $result
}

# Предварительная генерация градиентной палитры
function New-GradientPalette {
    param(
        [int]$Steps = 256,
        [string]$StartColor,
        [string]$EndColor,
        [string]$GradientType = 'Linear'
    )

    $palette = New-Object 'System.Collections.Generic.List[string]'

    for ($i = 0; $i -lt $Steps; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems $Steps `
            -StartColor $StartColor -EndColor $EndColor `
            -GradientType $GradientType -UseCache
        $palette.Add($color)
    }

    return $palette.ToArray()
}
#endregion

#region Performance Utilities
function Clear-ColorCache {
    param(
        [ValidateSet('All', 'Colors', 'Files', 'Gradients')]
        [string]$CacheType = 'All'
    )

    switch ($CacheType) {
        'All' {
            $script:ColorSystemConfig.Cache.ColorConversions.Clear()
            $script:ColorSystemConfig.Cache.FileColors.Clear()
            $script:ColorSystemConfig.Cache.GradientColors.Clear()
        }
        'Colors' { $script:ColorSystemConfig.Cache.ColorConversions.Clear() }
        'Files' { $script:ColorSystemConfig.Cache.FileColors.Clear() }
        'Gradients' { $script:ColorSystemConfig.Cache.GradientColors.Clear() }
    }
}

function Get-ColorCacheStats {
    return [PSCustomObject]@{
        ColorConversions = $script:ColorSystemConfig.Cache.ColorConversions.Count
        FileColors = $script:ColorSystemConfig.Cache.FileColors.Count
        GradientColors = $script:ColorSystemConfig.Cache.GradientColors.Count
        TotalSize = ($script:ColorSystemConfig.Cache | ConvertTo-Json).Length
    }
}
#endregion

#region Batch Operations
function Write-RGBBatch {
    <#
    .SYNOPSIS
    Оптимизированный вывод множества цветных элементов
    #>
    param(
        [Parameter(Mandatory)]
        [array]$Items,

        [scriptblock]$ColorSelector = { $_.Color },
        [scriptblock]$TextSelector = { $_.ToString() },

        [switch]$NoNewline
    )

    if (-not (Test-ColorSupport)) {
        Write-Host ($Items | ForEach-Object { & $TextSelector $_ }) -NoNewline:$NoNewline
        return
    }

    $output = [System.Text.StringBuilder]::new()

    foreach ($item in $Items) {
        $text = & $TextSelector $item
        $color = & $ColorSelector $item

        if ($color) {
            $rgb = ConvertTo-RGBComponents $color
            $ansi = $PSStyle.Foreground.FromRgb($rgb.R, $rgb.G, $rgb.B)
            [void]$output.Append($ansi).Append($text).Append($PSStyle.Reset)
        } else {
            [void]$output.Append($text)
        }
    }

    Write-Host $output.ToString() -NoNewline:$NoNewline
}
#endregion
Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))
