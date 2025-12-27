# Скрипт для добавления выделенного текста в файл по горячей клавише
# Версия 2.0 - Исправлена ошибка с Windows.Forms

# Настройки
$TARGET_FILE = "F:\20a.txt"  # Укажите путь к вашему файлу
$HOTKEY = "F9"  # Горячая клавиша

# Загружаем необходимые сборки
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Создаем файл, если он не существует
if (!(Test-Path $TARGET_FILE)) {
    New-Item -Path $TARGET_FILE -ItemType File -Force
    Write-Host "Создан файл: $TARGET_FILE" -ForegroundColor Green
}

Write-Host "=== СБОРЩИК ТЕКСТА ===" -ForegroundColor Cyan
Write-Host "Файл назначения: $TARGET_FILE" -ForegroundColor Yellow
Write-Host "Горячая клавиша: $HOTKEY" -ForegroundColor Yellow
Write-Host ""
Write-Host "Инструкция:" -ForegroundColor White
Write-Host "1. Выделите текст в браузере" -ForegroundColor Gray
Write-Host "2. Скопируйте его (Ctrl+C)" -ForegroundColor Gray
Write-Host "3. Нажмите $HOTKEY в этом окне" -ForegroundColor Gray
Write-Host "4. Нажмите ESC для выхода" -ForegroundColor Gray
Write-Host ""
Write-Host "Скрипт запущен. Нажимайте клавиши в этом окне..." -ForegroundColor Green

# Функция для добавления текста в файл
function Add-TextToFile {
    try {
        # Получаем текст из буфера обмена
        $clipboardText = [System.Windows.Forms.Clipboard]::GetText()

        if ([string]::IsNullOrWhiteSpace($clipboardText)) {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Буфер обмена пуст или содержит не текст" -ForegroundColor Red
            [Console]::Beep(400, 200)
            return
        }

        # Добавляем разделитель и текст в файл
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $separator = "`n--- Добавлено $timestamp ---`n"
        $content = $separator + $clipboardText + "`n"

        Add-Content -Path $TARGET_FILE -Value $content -Encoding UTF8

        # Выводим подтверждение
        $preview = if ($clipboardText.Length -gt 80) {
            $clipboardText.Substring(0, 80) + "..."
        } else {
            $clipboardText
        }

        $previewClean = $preview -replace "`r`n", " " -replace "`n", " " -replace "`r", " "
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✓ Добавлено: $previewClean" -ForegroundColor Green

        # Звуковой сигнал успеха
        [Console]::Beep(800, 100)

    } catch {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Ошибка: $($_.Exception.Message)" -ForegroundColor Red
        [Console]::Beep(400, 200)
    }
}

# Функция для открытия файла
function Open-TargetFile {
    try {
        if (Test-Path $TARGET_FILE) {
            Start-Process notepad.exe -ArgumentList $TARGET_FILE
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Файл открыт в Блокноте" -ForegroundColor Green
        } else {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Файл не существует" -ForegroundColor Red
        }
    } catch {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Ошибка открытия файла: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Основной цикл мониторинга клавиш
try {
    while ($true) {
        # Ждем нажатия клавиши
        if ([Console]::KeyAvailable) {
            $keyInfo = [Console]::ReadKey($true)
            $key = $keyInfo.Key

            # Обработка клавиш
            switch ($key) {
                "F9" {
                    if ($HOTKEY -eq "F9") { Add-TextToFile }
                }
                "F10" {
                    if ($HOTKEY -eq "F10") { Add-TextToFile }
                }
                "F11" {
                    if ($HOTKEY -eq "F11") { Add-TextToFile }
                }
                "F12" {
                    if ($HOTKEY -eq "F12") { Add-TextToFile }
                }
                "F1" {
                    Write-Host "`n--- Помощь ---" -ForegroundColor Cyan
                    Write-Host "$HOTKEY - добавить текст из буфера в файл" -ForegroundColor Gray
                    Write-Host "F2 - открыть файл в Блокноте" -ForegroundColor Gray
                    Write-Host "F3 - показать последние 5 строк файла" -ForegroundColor Gray
                    Write-Host "ESC - выход" -ForegroundColor Gray
                    Write-Host ""
                }
                "F2" {
                    Open-TargetFile
                }
                "F3" {
                    try {
                        if (Test-Path $TARGET_FILE) {
                            $lastLines = Get-Content $TARGET_FILE -Tail 5 -Encoding UTF8
                            Write-Host "`n--- Последние записи ---" -ForegroundColor Cyan
                            $lastLines | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
                            Write-Host ""
                        } else {
                            Write-Host "Файл пуст или не существует" -ForegroundColor Yellow
                        }
                    } catch {
                        Write-Host "Ошибка чтения файла: $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
                "Escape" {
                    Write-Host "`nВыход из программы..." -ForegroundColor Yellow
                    return
                }
                default {
                    # Показываем какая клавиша была нажата (для отладки)
                    # Write-Host "Нажата клавиша: $key" -ForegroundColor DarkGray
                }
            }
        }

        # Небольшая пауза
        Start-Sleep -Milliseconds 100
    }
} catch {
    Write-Host "Критическая ошибка: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Write-Host "Скрипт завершен." -ForegroundColor Yellow
}


# Дополнительные функции клавиатуры:
# F1 - показать помощь
# F2 - открыть файл в блокноте
# F3 - показать последние записи
# ESC - выход
