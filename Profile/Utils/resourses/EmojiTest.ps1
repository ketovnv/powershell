




return











# Исправленная функция для обработки диапазонов эмоджи

# Функция для обработки отдельных Unicode значений
function Convert-EmojiArray {
    param([object[]]$UnicodeArray)

    $results = @()

    foreach ($item in $UnicodeArray) {
        # Проверяем тип входного объекта
        if ($item -is [System.Tuple]) {
            # Если это Tuple - обрабатываем как диапазон
            Write-Host "Обнаружен диапазон: 0x$($item.Item1.ToString('X')) - 0x$($item.Item2.ToString('X'))" -ForegroundColor Yellow
            $rangeResults = Convert-EmojiRange -StartCode $item.Item1 -EndCode $item.Item2
            $results += $rangeResults
        }
        elseif ($item -is [string]) {
            # Строковое представление Unicode
            try {
                $codePoint = [Convert]::ToInt32($item.Replace("U+", ""), 16)
                $results += Convert-SingleEmoji -CodePoint $codePoint -Unicode $item
            }
            catch {
                $results += [PSCustomObject]@{
                    Unicode = $item
                    CodePoint = $null
                    Emoji = $null
                    Status = "Ошибка парсинга: $($_.Exception.Message)"
                    Type = "String"
                }
            }
        }
        elseif ($item -is [int] -or $item -is [long]) {
            # Числовое значение code point
            $results += Convert-SingleEmoji -CodePoint $item -Unicode "0x$($item.ToString('X'))"
        }
        else {
            # Неизвестный тип
            $results += [PSCustomObject]@{
                Unicode = $item.ToString()
                CodePoint = $null
                Emoji = $null
                Status = "Неподдерживаемый тип: $($item.GetType().Name)"
                Type = $item.GetType().Name
            }
        }
    }

    return $results
}

# Функция для обработки диапазонов эмоджи
function Convert-EmojiRange {
    param(
        [int]$StartCode,
        [int]$EndCode,
        [int]$MaxSamples = 10,  # Максимум примеров из диапазона
        [switch]$ShowAll
    )

    $results = @()
    $totalInRange = $EndCode - $StartCode + 1

    Write-Host "  Обрабатывается диапазон: $totalInRange символов" -ForegroundColor Gray

    if ($ShowAll -or $totalInRange -le $MaxSamples) {
        # Показываем все символы если диапазон маленький или явно запрошено
        for ($code = $StartCode; $code -le $EndCode; $code++) {
            $results += Convert-SingleEmoji -CodePoint $code -Unicode "0x$($code.ToString('X'))"
        }
    }
    else {
        # Показываем только образцы из диапазона
        $step = [Math]::Max(1, [Math]::Floor($totalInRange / $MaxSamples))

        for ($i = 0; $i -lt $MaxSamples; $i++) {
            $code = $StartCode + ($i * $step)
            if ($code -le $EndCode) {
                $results += Convert-SingleEmoji -CodePoint $code -Unicode "0x$($code.ToString('X'))"
            }
        }

        # Добавляем информацию о диапазоне
        $results += [PSCustomObject]@{
            Unicode = "Range Info"
            CodePoint = $null
            Emoji = "..."
            Status = "Показано $($results.Count) из $totalInRange символов диапазона"
            Type = "RangeInfo"
            IsSupported = $null
            Category = "Info"
        }
    }

    return $results
}

# Функция для обработки одного эмоджи
function Convert-SingleEmoji {
    param(
        [int]$CodePoint,
        [string]$Unicode
    )

    try {
        # Проверяем валидность code point
        if ($CodePoint -lt 0 -or $CodePoint -gt 0x10FFFF) {
            throw "Code point вне допустимого диапазона Unicode"
        }

        if ($CodePoint -ge 0xD800 -and $CodePoint -le 0xDFFF) {
            throw "Code point в диапазоне суррогатных пар"
        }

        $emoji = [char]::ConvertFromUtf32($CodePoint)

        # Определяем категорию эмоджи
        $category = Get-EmojiCategory -CodePoint $CodePoint

        # Проверяем поддержку отображения
        $isSupported = Test-EmojiSupport -Emoji $emoji -CodePoint $CodePoint

        return [PSCustomObject]@{
            Unicode = $Unicode
            CodePoint = $CodePoint
            Emoji = $emoji
            Status = if ($isSupported) { "Поддерживается" } else { "Может не отображаться" }
            Type = "Emoji"
            IsSupported = $isSupported
            Category = $category
        }
    }
    catch {
        return [PSCustomObject]@{
            Unicode = $Unicode
            CodePoint = $CodePoint
            Emoji = "❌"
            Status = "Ошибка: $($_.Exception.Message)"
            Type = "Error"
            IsSupported = $false
            Category = "Error"
        }
    }
}

# Функция для определения категории эмоджи
function Get-EmojiCategory {
    param([int]$CodePoint)

    $emojiRanges = @{
        @{Start = 0x1F600; End = 0x1F64F} = "Emoticons (лица)"
        @{Start = 0x1F300; End = 0x1F5FF} = "Misc Symbols (разное)"
        @{Start = 0x1F680; End = 0x1F6FF} = "Transport (транспорт)"
        @{Start = 0x1F700; End = 0x1F77F} = "Alchemical Symbols"
        @{Start = 0x1F780; End = 0x1F7FF} = "Geometric Shapes Extended"
        @{Start = 0x1F800; End = 0x1F8FF} = "Supplemental Arrows-C"
        @{Start = 0x1F900; End = 0x1F9FF} = "Supplemental Symbols (доп.символы)"
        @{Start = 0x1FA00; End = 0x1FA6F} = "Chess Symbols"
        @{Start = 0x1FA70; End = 0x1FAFF} = "Symbols and Pictographs Extended-A"
        @{Start = 0x2600; End = 0x26FF} = "Miscellaneous Symbols"
        @{Start = 0x2700; End = 0x27BF} = "Dingbats"
        @{Start = 0x1F1E6; End = 0x1F1FF} = "Regional Indicators (флаги)"
    }

    foreach ($range in $emojiRanges.Keys) {
        if ($CodePoint -ge $range.Start -and $CodePoint -le $range.End) {
            return $emojiRanges[$range]
        }
    }

    return "Unknown"
}

# Улучшенная проверка поддержки эмоджи
function Test-EmojiSupport {
    param([string]$Emoji, [int]$CodePoint)

    # Базовые проверки на явно неподдерживаемые символы
    if ($Emoji -eq "�" -or $Emoji -eq "" -or $null -eq $Emoji) {
        return $false
    }

    # Проверка корректности кодирования UTF-8
    $byteLength = [System.Text.Encoding]::UTF8.GetByteCount($Emoji)

    # Если символ кодируется одним байтом, но code point больше ASCII - подозрительно
    if ($byteLength -eq 1 -and $CodePoint -gt 0x7F) {
        return $false
    }

    # Для эмоджи диапазонов - более мягкая проверка
    if ($CodePoint -ge 0x1F000) {
        # В диапазоне эмоджи - считаем поддерживаемым если не replacement character
        return $Emoji -ne "�" -and $Emoji -ne "?"
    }

    # Для остальных символов - стандартная проверка
    return $true
}

# ПРАВИЛЬНЫЕ примеры использования
Write-Host "=== Примеры правильного использования ===" -ForegroundColor Green

# 1. Обработка смешанных данных (строки, числа, диапазоны)
Write-Host "`n1. Смешанные данные:" -ForegroundColor Cyan
$mixedData = @(
    "U+1F600",  # Строка
    0x1F601,    # Число
    [System.Tuple]::Create(0x1F602, 0x1F605),  # Диапазон (маленький)
    "U+2764",   # Строка
    [System.Tuple]::Create(0x1F680, 0x1F685)   # Диапазон
)

$results = Convert-EmojiArray $mixedData
$results | Format-Table Unicode, Emoji, Status, Category -AutoSize

# 2. Обработка только диапазонов
Write-Host "`n2. Диапазоны эмоджи:" -ForegroundColor Cyan
$emojiRanges = @(
    [System.Tuple]::Create(0x1F600, 0x1F64F),  # Emoticons - БОЛЬШОЙ диапазон
    [System.Tuple]::Create(0x1F680, 0x1F6FF),  # Transport
    [System.Tuple]::Create(0x2764, 0x2764)     # Одиночный символ как диапазон
)

$rangeResults = Convert-EmojiArray $emojiRanges
Write-Host "Обработано диапазонов: $($emojiRanges.Count)"
Write-Host "Получено результатов: $($rangeResults.Count)"

# 3. Детальная обработка одного диапазона
Write-Host "`n3. Подробный анализ диапазона Emoticons:" -ForegroundColor Cyan
$detailedResults = Convert-EmojiRange -StartCode 0x1F600 -EndCode 0x1F610 -ShowAll
$detailedResults | Where-Object { $_.Type -eq "Emoji" } |
    Format-Table Unicode, Emoji, IsSupported, Category -AutoSize

# 4. Функция-помощник для создания диапазонов
function New-EmojiRange {
    param(
        [string]$Name,
        [int]$Start,
        [int]$End,
        [string]$Description = ""
    )

    return [PSCustomObject]@{
        Name = $Name
        Range = [System.Tuple]::Create($Start, $End)
        Description = $Description
        Count = $End - $Start + 1
    }
}

Write-Host "`n4. Предопределённые диапазоны:" -ForegroundColor Cyan
$predefinedRanges = @(
    New-EmojiRange "Emoticons" 0x1F600 0x1F64F "Смайлики и лица"
    New-EmojiRange "Transport" 0x1F680 0x1F6FF "Транспорт и места"
    New-EmojiRange "Symbols" 0x2600 0x26FF "Различные символы"
)

$predefinedRanges | Format-Table Name, Count, Description -AutoSize

# Обрабатываем только диапазоны
$rangeOnlyResults = Convert-EmojiArray ($predefinedRanges | ForEach-Object { $_.Range })
Write-Host "Processed $($rangeOnlyResults.Count) items from predefined ranges"

# Улучшенная безопасная функция для пользователей
function Get-EmojisFromRange {
    param(
        [int]$StartHex,
        [int]$EndHex,
        [int]$SampleSize = 5,
        [switch]$OnlySupported = $false
    )

    Write-Host "Получение эмоджи из диапазона 0x$($StartHex.ToString('X')) - 0x$($EndHex.ToString('X'))" -ForegroundColor Yellow

    $range = [System.Tuple]::Create($StartHex, $EndHex)
    $results = Convert-EmojiArray @($range)

    # Фильтруем только эмоджи (исключаем информационные записи)
    $emojiResults = $results | Where-Object { $_.Type -eq "Emoji" }

    if ($OnlySupported) {
        $validEmojis = $emojiResults | Where-Object { $_.IsSupported }
        Write-Host "Найдено эмоджи: $($emojiResults.Count), поддерживаемых: $($validEmojis.Count)" -ForegroundColor Green
        return $validEmojis
    } else {
        Write-Host "Найдено эмоджи: $($emojiResults.Count)" -ForegroundColor Green
        return $emojiResults
    }
}

# Пример использования улучшенной функции
Write-Host "`n5. Исправленное получение эмоджи:" -ForegroundColor Cyan

# Показываем ВСЕ эмоджи из диапазона (не только поддерживаемые)
$allEmojis = Get-EmojisFromRange -StartHex 0x1F600 -EndHex 0x1F610
$allEmojis | Select-Object -First 10 | Format-Table Unicode, Emoji, IsSupported, Category -AutoSize

# Показываем только поддерживаемые
Write-Host "`nТолько поддерживаемые эмоджи:" -ForegroundColor Cyan
$supportedOnly = Get-EmojisFromRange -StartHex 0x1F600 -EndHex 0x1F610 -OnlySupported
$supportedOnly | Select-Object -First 10 | Format-Table Unicode, Emoji, Category -AutoSize

# Alternative: простая функция без фильтрации
function Get-AllEmojisFromRange {
    param([int]$Start, [int]$End)

    $results = @()
    for ($i = $Start; $i -le $End; $i++) {
        try {
            $emoji = [char]::ConvertFromUtf32($i)
            $results += [PSCustomObject]@{
                CodePoint = "0x$($i.ToString('X'))"
                Emoji = $emoji
                Decimal = $i
                Status = "OK"
            }
        }
        catch {
            $results += [PSCustomObject]@{
                CodePoint = "0x$($i.ToString('X'))"
                Emoji = "❌"
                Decimal = $i
                Status = "Error"
            }
        }
    }
    return $results
}

Write-Host "`nАльтернативный простой подход:" -ForegroundColor Cyan
$simpleResults = Get-AllEmojisFromRange -Start 0x1F600 -End 0x1F610
$simpleResults | Format-Table CodePoint, Emoji, Status -AutoSize
