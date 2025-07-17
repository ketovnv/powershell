# Hex to OKLCH Color Converter
# Преобразует hex цвета в строке в формат oklch()

function Convert-HexToRgb {
    param([string]$hex)
    
    # Удаляем # если есть
    $hex = $hex -replace '#', ''
    
    # Обрабатываем короткий формат (#fff -> #ffffff)
    if ($hex.Length -eq 3) {
        $hex = $hex[0] + $hex[0] + $hex[1] + $hex[1] + $hex[2] + $hex[2]
    }
    
    $r = [Convert]::ToInt32($hex.Substring(0, 2), 16) / 255.0
    $g = [Convert]::ToInt32($hex.Substring(2, 2), 16) / 255.0
    $b = [Convert]::ToInt32($hex.Substring(4, 2), 16) / 255.0
    
    return @($r, $g, $b)
}

function Convert-RgbToLinear {
    param([double]$value)
    
    if ($value -le 0.04045) {
        return $value / 12.92
    } else {
        return [Math]::Pow(($value + 0.055) / 1.055, 2.4)
    }
}

function Convert-RgbToXyz {
    param([double]$r, [double]$g, [double]$b)
    
    # Преобразуем в линейное RGB
    $r = Convert-RgbToLinear $r
    $g = Convert-RgbToLinear $g
    $b = Convert-RgbToLinear $b
    
    # sRGB to XYZ матрица (D65)
    $x = $r * 0.4124564 + $g * 0.3575761 + $b * 0.1804375
    $y = $r * 0.2126729 + $g * 0.7151522 + $b * 0.0721750
    $z = $r * 0.0193339 + $g * 0.1191920 + $b * 0.9503041
    
    return @($x, $y, $z)
}

function Convert-XyzToOklab {
    param([double]$x, [double]$y, [double]$z)
    
    # XYZ to LMS матрица
    $l = $x * 0.8189330101 + $y * 0.3618667424 + $z * -0.1288597137
    $m = $x * 0.0329845436 + $y * 0.9293118715 + $z * 0.0361456387
    $s = $x * 0.0482003018 + $y * 0.2643662691 + $z * 0.6338517070
    
    # Применяем кубический корень
    $l = if ($l -ge 0) { [Math]::Pow($l, 1.0/3.0) } else { -[Math]::Pow(-$l, 1.0/3.0) }
    $m = if ($m -ge 0) { [Math]::Pow($m, 1.0/3.0) } else { -[Math]::Pow(-$m, 1.0/3.0) }
    $s = if ($s -ge 0) { [Math]::Pow($s, 1.0/3.0) } else { -[Math]::Pow(-$s, 1.0/3.0) }
    
    # LMS to Oklab
    $lightness = $l * 0.2104542553 + $m * 0.7936177850 + $s * -0.0040720468
    $a = $l * 1.9779984951 + $m * -2.4285922050 + $s * 0.4505937099
    $b = $l * 0.0259040371 + $m * 0.7827717662 + $s * -0.8086757660
    
    return @($lightness, $a, $b)
}

function Convert-OklabToOklch {
    param([double]$l, [double]$a, [double]$b)
    
    $c = [Math]::Sqrt($a * $a + $b * $b)
    $h = [Math]::Atan2($b, $a) * 180 / [Math]::PI
    
    # Нормализуем угол к положительному значению
    if ($h -lt 0) {
        $h += 360
    }
    
    return @($l, $c, $h)
}

function Convert-HexToOklch {
    param([string]$hexColor)
    
    try {
        $rgb = Convert-HexToRgb $hexColor
        $xyz = Convert-RgbToXyz $rgb[0] $rgb[1] $rgb[2]
        $oklab = Convert-XyzToOklab $xyz[0] $xyz[1] $xyz[2]
        $oklch = Convert-OklabToOklch $oklab[0] $oklab[1] $oklab[2]
        
        # Форматируем значения
        $l = [Math]::Round($oklch[0], 4)
        $c = [Math]::Round($oklch[1], 4)
        $h = [Math]::Round($oklch[2], 1)
        
        return "oklch($l $c $h)"
    }
    catch {
        Write-Warning "Ошибка при преобразовании цвета $hexColor : $_"
        return $hexColor  # Возвращаем исходный цвет в случае ошибки
    }
}

function Convert-HexColorsInString {
    param([string]$inputString)
    
    # Регулярное выражение для поиска hex цветов
    # Поддерживает форматы: #fff, #ffffff, #ffff, #ffffffff (с альфа-каналом)
    $hexPattern = '#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{4}|[0-9a-fA-F]{8})\b'
    
    $result = [regex]::Replace($inputString, $hexPattern, {
        param($match)
        $hexColor = $match.Value
        
        # Проверяем, есть ли альфа-канал
        $cleanHex = $hexColor -replace '#', ''
        if ($cleanHex.Length -eq 4 -or $cleanHex.Length -eq 8) {
            # Для цветов с альфа-каналом пока возвращаем исходный цвет
            # так как OKLCH не поддерживает альфа напрямую
            return $hexColor
        }
        
        $oklchColor = Convert-HexToOklch $hexColor
        Write-Host "Преобразовано: $hexColor -> $oklchColor" -ForegroundColor Green
        return $oklchColor
    })
    
    return $result
}

# Основная логика скрипта
#Write-Host "=== Преобразователь Hex цветов в OKLCH ===" -ForegroundColor Cyan
#Write-Host "Введите строку с hex цветами (или нажмите Ctrl+C для выхода):" -ForegroundColor Yellow
#Write-Host ""
#
#while ($true) {
#    try {
#        # Запрашиваем ввод
#        $inputString = Read-Host "Введите строку"
#
#        if ([string]::IsNullOrWhiteSpace($inputString)) {
#            Write-Host "Пустая строка. Попробуйте ещё раз." -ForegroundColor Yellow
#            continue
#        }
#
#        Write-Host "`nОбработка..." -ForegroundColor Cyan
#
#        # Преобразуем цвета
#        $convertedString = Convert-HexColorsInString $inputString
#
#        # Выводим результат
#        Write-Host "`n=== РЕЗУЛЬТАТ ===" -ForegroundColor Green
#        Write-Host $convertedString
#        Write-Host "`n=== РЕЗУЛЬТАТ СКОПИРОВАН В БУФЕР ОБМЕНА ===" -ForegroundColor Green
#
#        # Копируем в буфер обмена
#        $convertedString | Set-Clipboard
#
#        Write-Host "`n" + "="*50 + "`n" -ForegroundColor Gray
#    }
#    catch {
#        Write-Host "Произошла ошибка: $_" -ForegroundColor Red
#        Write-Host "Попробуйте ещё раз.`n" -ForegroundColor Yellow
#    }
#}


Convert-OklabToOklch 100 200 15
