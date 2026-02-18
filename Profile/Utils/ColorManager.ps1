Trace-ImportProcess ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

#region ColorManager.ps1 - Централизованная система управления цветовыми темами
<#
.SYNOPSIS
    Централизованный менеджер цветовых тем для PowerShell профиля

.DESCRIPTION
    Унифицированная система управления цветовыми палитрами, темами и градиентами.
    Обеспечивает консистентность, производительность и расширяемость цветовой системы.

.NOTES
    Author: PowerShell Profile System
    Version: 1.0.0
#>

#region Конфигурация системы
$script:ColorManagerConfig = @{
    # Основные настройки
    Version = "1.0.0"
    AutoCacheEnabled = $true
    PerformanceMode = $true

    # Кеширование
    Cache = @{
        ColorConversions = @{}
        GradientColors = @{}
        ThemeColors = @{}
        FileColors = @{}
    }

    # Текущая тема
    CurrentTheme = "Default"

    # Настройки производительности
    Performance = @{
        MaxCacheSize = 1000
        PrecomputeGradients = $true
        LazyLoading = $true
    }
}

# Ленивая инициализация поддержки цветов
$script:ColorSupportChecked = $false
$script:ColorSupportResult = $null
#endregion

#region Утилитарные функции
function Test-ColorSupport {
    <#
    .SYNOPSIS
        Проверяет поддержку PSStyle в текущей версии PowerShell
    #>
    if (-not $script:ColorSupportChecked) {
        $script:ColorSupportResult = $null -ne $PSStyle
        $script:ColorSupportChecked = $true
    }
    return $script:ColorSupportResult
}

function ConvertTo-RGBComponents {
    <#
    .SYNOPSIS
        Конвертирует HEX цвет в RGB компоненты с кешированием
    #>
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$HexColor
    )

    # Проверка кеша
    $cacheKey = $HexColor.ToUpper()
    if ($script:ColorManagerConfig.AutoCacheEnabled -and
        $script:ColorManagerConfig.Cache.ColorConversions.ContainsKey($cacheKey)) {
        return $script:ColorManagerConfig.Cache.ColorConversions[$cacheKey]
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
    if ($script:ColorManagerConfig.AutoCacheEnabled) {
        $script:ColorManagerConfig.Cache.ColorConversions[$cacheKey] = $result
    }

    return $result
}

function ConvertFrom-RGBToHex {
    <#
    .SYNOPSIS
        Конвертирует RGB компоненты в HEX строку
    #>
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

#region Система тем
# Глобальная палитра цветов
$global:ColorPalettes = @{
    # Основные палитры
    Nord = @{
        PolarNight = "#2E3440"
        DarkBlue = "#3B4252"
        SteelBlue = "#4C566A"
        LightGray = "#D8DEE9"
        White = "#ECEFF4"
        FrostBlue = "#88C0D0"
        FrostGreen = "#8FBCBB"
        AuroraRed = "#BF616A"
        AuroraOrange = "#D08770"
        AuroraYellow = "#EBCB8B"
        AuroraGreen = "#A3BE8C"
        AuroraPurple = "#B48EAD"
    }

    Dracula = @{
        Background = "#282A36"
        CurrentLine = "#44475A"
        Foreground = "#F8F8F2"
        Comment = "#6272A4"
        Cyan = "#8BE9FD"
        Green = "#50FA7B"
        Orange = "#FFB86C"
        Pink = "#FF79C6"
        Purple = "#BD93F9"
        Red = "#FF5555"
        Yellow = "#F1FA8C"
    }

    Material = @{
        Red = "#F44336"
        Pink = "#DD99C6"
        Purple = "#9C27B0"
        DeepPurple = "#673AB7"
        Indigo = "#3F51B5"
        Blue = "#2196F3"
        LightBlue = "#03A9F4"
        Cyan = "#00BCD4"
        Teal = "#009688"
        Green = "#4CAF50"
        LightGreen = "#8BC34A"
        Lime = "#CDDC39"
        Yellow = "#FFEB3B"
        Amber = "#FFC107"
        Orange = "#FF9800"
        DeepOrange = "#FF5722"
        Brown = "#795548"
        Grey = "#9E9E9E"
        Comment = "#3E3E3E"
        BlueGrey = "#607D8B"
    }

    Cyber = @{
        Neon = "#00FFFF"
        Pink = "#DD44C6"
        Purple = "#8338EC"
        Blue = "#006FFF"
        Green = "#00F5FF"
        Orange = "#FF9500"
        Background = "#0D1117"
        Dark = "#161B22"
    }

    OneDark = @{
        Background = "#282C34"
        Red = "#E06C75"
        Green = "#98C379"
        Yellow = "#E5C07B"
        Blue = "#61AFEF"
        Purple = "#C678DD"
        Cyan = "#56B6C2"
        White = "#ABB2BF"
    }

    # Украинская палитра
    Ukraine = @{
        Blue = "#0057B7"
        Yellow = "#FFD500"
        LightBlue = "#4A90E2"
        LightYellow = "#FFE680"
    }

    # Дополнительные цвета
    Additional = @{
        PastelPink = "#FFD1DC"
        PastelBlue = "#AEC6CF"
        PastelGreen = "#77DD77"
        PastelYellow = "#FDFD96"
        PastelPurple = "#B19CD9"
        Silver = "#C0C0C0"
        Bronze = "#CD7F32"
        Copper = "#B87333"
        SkyBlue = "#87CEEB"
        SeaGreen = "#2E8B57"
        ElectricLime = "#CCFF00"
        LaserRed = "#FF0F0F"
        NeonOrange = "#FF6600"
        PlasmaViolet = "#8B00FF"
        ElectricBlue = "#7DF9FF"
        NeonGreen = "#39FF14"
        HotPink = "#FF69B4"
    }
}

# Предопределенные темы
$global:ColorThemes = @{
    Default = @{
        Primary = "#0080FF"
        Secondary = "#FF0080"
        Success = "#00FF00"
        Warning = "#FFD700"
        Error = "#FF0000"
        Info = "#00BFFF"
        Background = "#1E1E1E"
        Foreground = "#FFFFFF"
    }

    Dark = @{
        Primary = "#4A90E2"
        Secondary = "#E91E63"
        Success = "#4CAF50"
        Warning = "#FFC107"
        Error = "#F44336"
        Info = "#2196F3"
        Background = "#121212"
        Foreground = "#E0E0E0"
    }

    Ukraine = @{
        Primary = "#0057B7"
        Secondary = "#FFD500"
        Success = "#0057B7"
        Warning = "#FFD500"
        Error = "#FF0000"
        Info = "#0057B7"
        Background = "#0A0A2A"
        Foreground = "#FFFFFF"
    }

    Nord = @{
        Primary = "#88C0D0"
        Secondary = "#8FBCBB"
        Success = "#A3BE8C"
        Warning = "#EBCB8B"
        Error = "#BF616A"
        Info = "#81A1C1"
        Background = "#2E3440"
        Foreground = "#D8DEE9"
    }

    Dracula = @{
        Primary = "#BD93F9"
        Secondary = "#FF79C6"
        Success = "#50FA7B"
        Warning = "#F1FA8C"
        Error = "#FF5555"
        Info = "#8BE9FD"
        Background = "#282A36"
        Foreground = "#F8F8F2"
    }
}

function Get-ColorTheme {
    <#
    .SYNOPSIS
        Получает текущую цветовую тему
    #>
    param(
        [string]$ThemeName = $script:ColorManagerConfig.CurrentTheme
    )

    if ($global:ColorThemes.ContainsKey($ThemeName)) {
        return $global:ColorThemes[$ThemeName]
    } else {
        Write-Warning "Тема '$ThemeName' не найдена. Используется тема по умолчанию."
        return $global:ColorThemes["Default"]
    }
}

function Set-ColorTheme {
    <#
    .SYNOPSIS
        Устанавливает активную цветовую тему
    #>
    param(
        [Parameter(Mandatory)]
        [ValidateSet("Default", "Dark", "Ukraine", "Nord", "Dracula", "Custom")]
        [string]$ThemeName,

        [hashtable]$CustomTheme
    )

    if ($ThemeName -eq "Custom" -and $CustomTheme) {
        $global:ColorThemes["Custom"] = $CustomTheme
    }

    if ($global:ColorThemes.ContainsKey($ThemeName) -or ($ThemeName -eq "Custom" -and $CustomTheme)) {
        $script:ColorManagerConfig.CurrentTheme = $ThemeName
        Write-Host "Цветовая тема установлена: $ThemeName" -ForegroundColor Green
    } else {
        Write-Warning "Тема '$ThemeName' не найдена"
    }
}

function Get-ThemeColor {
    <#
    .SYNOPSIS
        Получает цвет из текущей темы по типу
    #>
    param(
        [Parameter(Mandatory)]
        [ValidateSet("Primary", "Secondary", "Success", "Warning", "Error", "Info", "Background", "Foreground")]
        [string]$ColorType,

        [string]$ThemeName = $script:ColorManagerConfig.CurrentTheme
    )

    $theme = Get-ColorTheme -ThemeName $ThemeName
    return $theme[$ColorType]
}

function Register-ColorPalette {
    <#
    .SYNOPSIS
        Регистрирует новую цветовую палитру
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [hashtable]$Palette
    )

    $global:ColorPalettes[$Name] = $Palette
    Write-Host "Палитра '$Name' зарегистрирована" -ForegroundColor Green
}

function Register-ColorTheme {
    <#
    .SYNOPSIS
        Регистрирует новую цветовую тему
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [hashtable]$Theme
    )

    $global:ColorThemes[$Name] = $Theme
    Write-Host "Тема '$Name' зарегистрирована" -ForegroundColor Green
}
#endregion

#region Градиентная система
function Get-GradientColor {
    <#
    .SYNOPSIS
        Генерирует цвет градиента для указанной позиции
    #>
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
    if ($UseCache -or $script:ColorManagerConfig.AutoCacheEnabled) {
        $cacheKey = "$Index|$TotalItems|$StartColor|$EndColor|$GradientType"
        if ($script:ColorManagerConfig.Cache.GradientColors.ContainsKey($cacheKey)) {
            return $script:ColorManagerConfig.Cache.GradientColors[$cacheKey]
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
    if ($UseCache -or $script:ColorManagerConfig.AutoCacheEnabled) {
        $script:ColorManagerConfig.Cache.GradientColors[$cacheKey] = $result
    }

    return $result
}

function New-GradientPalette {
    <#
    .SYNOPSIS
        Создает палитру градиентных цветов
    #>
    param(
        [int]$Steps = 256,
        [string]$StartColor = "#FF0000",
        [string]$EndColor = "#0000FF",
        [string]$GradientType = "Linear"
    )

    $palette = @()
    for ($i = 0; $i -lt $Steps; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems $Steps `
            -StartColor $StartColor -EndColor $EndColor `
            -GradientType $GradientType -UseCache
        $palette += $color
    }
    return $palette
}

function Get-PresetGradient {
    <#
    .SYNOPSIS
        Получает предустановленные градиенты
    #>
    param(
        [Parameter(Mandatory)]
        [ValidateSet("Ocean", "Fire", "Nature", "Neon", "Pastel", "Ukraine", "Dracula", "Rainbow")]
        [string]$Style
    )

    $presets = @{
        Ocean = @{ Start = "#0080FF"; End = "#00FFD4" }
        Fire = @{ Start = "#FF0000"; End = "#FFD700" }
        Nature = @{ Start = "#00FF00"; End = "#90EE90" }
        Neon = @{ Start = "#FF00FF"; End = "#00FFFF" }
        Pastel = @{ Start = "#FFB6C1"; End = "#E6E6FA" }
        Ukraine = @{ Start = "#0057B7"; End = "#FFD500" }
        Dracula = @{ Start = "#FF79C6"; End = "#BD93F9" }
        Rainbow = @{ Start = "#FF0000"; End = "#0000FF" }
    }

    return $presets[$Style]
}
#endregion

#region Управление производительностью
function Clear-ColorCache {
    <#
    .SYNOPSIS
        Очищает кеши цветов
    #>
    param(
        [ValidateSet('All', 'Colors', 'Gradients', 'Themes', 'Files')]
        [string]$CacheType = 'All'
    )

    switch ($CacheType) {
        'All' {
            $script:ColorManagerConfig.Cache.ColorConversions.Clear()
            $script:ColorManagerConfig.Cache.GradientColors.Clear()
            $script:ColorManagerConfig.Cache.ThemeColors.Clear()
            $script:ColorManagerConfig.Cache.FileColors.Clear()
        }
        'Colors' { $script:ColorManagerConfig.Cache.ColorConversions.Clear() }
        'Gradients' { $script:ColorManagerConfig.Cache.GradientColors.Clear() }
        'Themes' { $script:ColorManagerConfig.Cache.ThemeColors.Clear() }
        'Files' { $script:ColorManagerConfig.Cache.FileColors.Clear() }
    }

    Write-Host "Кеш очищен: $CacheType" -ForegroundColor Yellow
}

function Get-ColorCacheStats {
    <#
    .SYNOPSIS
        Показывает статистику кеширования
    #>
    return [PSCustomObject]@{
        ColorConversions = $script:ColorManagerConfig.Cache.ColorConversions.Count
        GradientColors = $script:ColorManagerConfig.Cache.GradientColors.Count
        ThemeColors = $script:ColorManagerConfig.Cache.ThemeColors.Count
        FileColors = $script:ColorManagerConfig.Cache.FileColors.Count
        TotalCacheSize = ($script:ColorManagerConfig.Cache | ConvertTo-Json -Compress).Length
        CurrentTheme = $script:ColorManagerConfig.CurrentTheme
        AutoCacheEnabled = $script:ColorManagerConfig.AutoCacheEnabled
    }
}

function Optimize-ColorSystem {
    <#
    .SYNOPSIS
        Оптимизирует систему цветов для производительности
    #>
    param(
        [switch]$PrecomputeCommonGradients,
        [int]$MaxCacheSize = 1000
    )

    $script:ColorManagerConfig.PerformanceMode = $true
    $script:ColorManagerConfig.Performance.MaxCacheSize = $MaxCacheSize

    if ($PrecomputeCommonGradients) {
        # Предварительная генерация популярных градиентов
        $commonGradients = @("Ocean", "Fire", "Rainbow", "Ukraine")
        foreach ($gradient in $commonGradients) {
            $preset = Get-PresetGradient -Style $gradient
            $palette = New-GradientPalette -Steps 256 -StartColor $preset.Start -EndColor $preset.End
            # Сохраняем в кеш для быстрого доступа
        }
    }

    Write-Host "Система цветов оптимизирована" -ForegroundColor Green
}
#endregion

#region Утилиты диагностики
function Show-ColorThemes {
    <#
    .SYNOPSIS
        Показывает все доступные цветовые темы
    #>
    Write-Host "`n=== Доступные цветовые темы ===" -ForegroundColor Cyan

    foreach ($themeName in $global:ColorThemes.Keys) {
        $isCurrent = $themeName -eq $script:ColorManagerConfig.CurrentTheme
        $prefix = if ($isCurrent) { "→ " } else { "  " }

        Write-Host "$prefix$themeName" -ForegroundColor $(if ($isCurrent) { "Green" } else { "White" })

        # Показываем цвета темы
        $theme = $global:ColorThemes[$themeName]
        foreach ($colorType in $theme.Keys) {
            $color = $theme[$colorType]
            Write-Host "    ${colorType}: " -NoNewline
            Write-RGB $color -FC $color -newline
        }
        Write-Host ""
    }
}

function Test-ColorSystem {
    <#
    .SYNOPSIS
        Тестирует работу системы цветов
    #>
    Write-Host "`n=== Тестирование системы цветов ===" -ForegroundColor Cyan

    # Проверка поддержки PSStyle
    $colorSupport = Test-ColorSupport
    Write-Host "PSStyle поддержка: " -NoNewline
    Write-Host $(if ($colorSupport) { "✓ Доступна" } else { "✗ Недоступна" }) -ForegroundColor $(if ($colorSupport) { "Green" } else { "Red" })

    # Тест конвертации цветов
    Write-Host "`nТест конвертации:" -ForegroundColor Yellow
    $testColors = @("#FF0000", "#00FF00", "#0000FF", "#FFFFFF", "#000000")
    foreach ($color in $testColors) {
        $rgb = ConvertTo-RGBComponents -HexColor $color
        $hex = ConvertFrom-RGBToHex -R $rgb.R -G $rgb.G -B $rgb.B
        Write-RGB "  $color → RGB($($rgb.R),$($rgb.G),$($rgb.B)) → $hex" -FC $color -newline
    }

    # Тест градиентов
    Write-Host "`nТест градиентов:" -ForegroundColor Yellow
    $gradientText = "ГРАДИЕНТ"
    for ($i = 0; $i -lt $gradientText.Length; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems $gradientText.Length -StartColor "#FF0000" -EndColor "#0000FF"
        Write-RGB $gradientText[$i] -FC $color
    }
    Write-Host ""

    # Статистика кеша
    Write-Host "`nСтатистика кеша:" -ForegroundColor Yellow
    $stats = Get-ColorCacheStats
    $stats | Format-Table -AutoSize
}
#endregion

# Инициализация системы
Write-Verbose "ColorManager инициализирован - версия $($script:ColorManagerConfig.Version)"

Trace-ImportProcess ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))
