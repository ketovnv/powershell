Write-RGB "" -newline
Write-RGB "`nДоступные виды ошибок:" -FC Dracula_Orange -newline
$ErrorViews = (Get-Command ConvertTo-*ErrorView).Name -replace "ConvertTo-(.*)ErrorView", '$1'
$ErrorViews | ForEach-Object { Write-RGB  "  - $_" -FC Dracula_Red}
# Очищаем коллекцию ошибок
$Error.Clear()

# Создаем различные типы ошибок для демонстрации
try {
    # Ошибка деления на ноль
    $result = 10 / 0
}
catch {
    # Ошибка уже добавлена в $Error
}

try {
    # Ошибка доступа к несуществующему файлу
    Get-Content "C:\NonExistentFile.txt" -ErrorAction Stop
}
catch {
    # Ошибка уже добавлена в $Error
}

try {
    # Ошибка парсинга JSON
    '{"invalid": json}' | ConvertFrom-Json -ErrorAction Stop
}
catch {
    # Ошибка уже добавлена в $Error
}

# Ошибка внешней команды (если ping доступен)
ping invalid-host-name-that-does-not-exist 2>$null

Write-RGB "Создано несколько тестовых ошибок для демонстрации" -FC Green

Write-RGB "`n=== Демонстрация различных видов отображения ошибок ===" -FC Cyan


# Демонстрация Simple view (по умолчанию)
Write-RGB "`n--- Simple ErrorView (текущий) ---" -FC Yellow
Write-RGB "Текущий вид ошибок: $global:ErrorView"
if ($Error.Count -gt 0) {
    $Error[0]
}

# Демонстрация Normal view
Write-RGB "`n--- Normal ErrorView ---" -FC
if ($Error.Count -gt 0) {
    $Error[0] | Format-Error Normal
}

# Демонстрация Category view
Write-RGB "`n--- Category ErrorView ---" -FC Yellow
if ($Error.Count -gt 0) {
    $Error[0] | Format-Error Category
}

# Демонстрация Full view
Write-RGB "`n--- Full ErrorView ---" -FC Yellow
if ($Error.Count -gt 0) {
    $Error[0] | Format-Error Full
}



if ($Error.Count -ge 3) {
    Write-RGB "`n--- Последние 3 ошибки (Normal view) ---" -FC Yellow
    $Error[0..2] | Format-Error Normal
} else {
    $Error | Format-Error Normal
}

# Показать ошибку с рекурсией во внутренние исключения
Write-RGB "`n--- Ошибка с рекурсией во внутренние исключения ---" -FC Yellow
if ($Error.Count -gt 0) {
    $Error[0] | Format-Error Full -Recurse
}

# Демонстрируем кастомный вид
Write-RGB "`n--- Кастомный SingleLine ErrorView ---" -FC Yellow
if ($Error.Count -gt 0) {
    $Error[0] | Format-Error SingleLine
}


# Демонстрируем смену вида
#Write-RGB "`nМеняем на вид:"  -FC Gray
#Set-MyErrorView -View "Colorful"
#Write-RGB    "Colorful" -FC Green
Write-RGB "`n--- Ошибка в установленном SingleLine виде ---" -FC Yellow
if ($Error.Count -gt 0) {
    $Error[0]
}

Write-RGB "`n--- Демонстрация компактного вида ---" -FC Yellow
if ($Error.Count -gt 0) {
    $Error[0] | Format-Error Compact
}



# Тестируем разные типы ошибок
try { Get-Content "C:\NonexistentFile.txt" -ErrorAction Stop } catch { }
try { Invoke-Command -ScriptBlock { throw [UnauthorizedAccessException]"Access denied to secure resource" } } catch { }
try { $null.SomeProperty } catch { }
try { [int]"not_a_number" } catch { }
try { Get-NonexistentCommand } catch { }

Write-RGB "`n--- Показываем ошибки с умной обработкой ---" -FC Yellow
# Показываем первые несколько ошибок
if ($Error.Count -gt 0) {
    for ($i = 0; $i -lt [Math]::Min(3, $Error.Count); $i++) {
        Write-RGB "`nОшибка $($i + 1):" -FC White
        Write-ColoredError ($Error[$i] | ConvertTo-SmartErrorView) -Color "Red"
        Write-RGB ("-" * 50) -FC Gray
    }
}


Write-RGB "`n=== Заключение и рекомендации ===" -FC Cyan

$help=@"

Модуль ErrorView предоставляет мощные возможности для кастомизации отображения ошибок:

1. Встроенные виды ошибок:
   - Simple: компактный двустрочный вид (по умолчанию)
   - Normal: стандартный вид с дополнительной информацией
   - Category: только категория ошибки
   - Full: полная информация об ошибке

2. Команды для работы:
   - Format-Error: временное изменение вида для просмотра
   - Set-ErrorView: установка постоянного вида
   - Import-Module ErrorView -Args <View>: установка вида при импорте

3. Создание кастомных видов:
   - Функция должна называться ConvertTo-<Name>ErrorView
   - Должна принимать параметр InputObject типа ErrorRecord
   - Может использовать глобальную переменную `$ErrorViewRecurse

4. Полезные алиасы:
   - fe = Format-Error

Рекомендации:
- Используйте Simple вид для повседневной работы
- Переключайтесь на Normal или Full при отладке
- Создавайте кастомные виды для специфических потребностей
- Используйте Format-Error -Recurse для анализа вложенных исключений

"@
Write-RGB $help -FC "#1199FF"


