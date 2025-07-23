# Функция для создания градиентного меню
function Show-GradientMenu {
    <#
    .SYNOPSIS
        Отображает меню с градиентными цветами
    
    .DESCRIPTION
        Создает интерактивное меню с градиентными цветами для каждого элемента
    
    .PARAMETER MenuItems
        Массив элементов меню
    
    .PARAMETER Title
        Заголовок меню
    
    .PARAMETER GradientOptions
        Хэш-таблица с настройками градиента
    
    .EXAMPLE
        $items = @("Файл", "Редактировать", "Просмотр", "Справка")
        $gradientSettings = @{
            StartColor = "#FF0000"
            EndColor = "#0000FF"
            GradientType = "Linear"
            RedCoefficient = 1.2
        }
        Show-GradientMenu -MenuItems $items -Title "Главное меню" -GradientOptions $gradientSettings
    #>
    
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
    
    Write-Host "`nВыберите пункт меню (1-$($MenuItems.Count)): " -ForegroundColor Gray
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

# Примеры использования:

<#
# Пример 1: Базовое использование
$menuItems = @("Создать файл", "Открыть файл", "Сохранить", "Выход")
for ($i = 0; $i -lt $menuItems.Count; $i++) {
    $color = Get-GradientColor -Index $i -TotalItems $menuItems.Count
    Write-Host "$($i + 1). $($menuItems[$i]) - $color"
}

# Пример 2: Пользовательские цвета и коэффициенты
$color = Get-GradientColor -Index 2 -TotalItems 5 -StartColor "#FF0000" -EndColor "#0000FF" -RedCoefficient 0.5 -BlueCoefficient 2.0
Write-Host "Цвет с коэффициентами: $color"

# Пример 3: Экспоненциальный градиент
$color = Get-GradientColor -Index 3 -TotalItems 8 -StartColor "#00FF00" -EndColor "#FF00FF" -GradientType Exponential
Write-Host "Экспоненциальный градиент: $color"

# Пример 4: Пользовательская функция градиента
$customFunc = { param($x) return [Math]::Sin($x * [Math]::PI) }
$color = Get-GradientColor -Index 4 -TotalItems 10 -StartColor "#FFFF00" -EndColor "#FF0080" -GradientType Custom -CustomFunction $customFunc
Write-Host "Пользовательский градиент: $color"

# Пример 5: Полноценное меню с градиентом
$items = @("Файл", "Редактировать", "Просмотр", "Вставка", "Формат", "Инструменты", "Справка")
$gradientSettings = @{
    StartColor = "#FF6B6B"
    EndColor = "#4ECDC4"
    GradientType = "Linear"
    RedCoefficient = 1.1
    GreenCoefficient = 0.9
    BlueCoefficient = 1.2
}
Show-GradientMenu -MenuItems $items -Title "Главное меню приложения" -GradientOptions $gradientSettings
#>