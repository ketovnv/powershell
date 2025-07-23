# Исправленная функция Show-RGBProgress
function Show-RGBProgress {
    <#
    .SYNOPSIS
        Отображает красивый прогресс-бар с градиентом
    
    .PARAMETER Activity
        Описание выполняемой операции
    
    .PARAMETER PercentComplete
        Процент выполнения (0-100)
    
    .PARAMETER Status
        Дополнительный статус
    
    .PARAMETER Width
        Ширина прогресс-бара
    
    .PARAMETER ShowPercentage
        Показывать процент
    
    .PARAMETER BarStyle
        Стиль прогресс-бара
    
    .PARAMETER GradientStyle
        Стиль градиента для прогресс-бара
    #>

    param(
        [string]$Activity = "Processing",

        [ValidateRange(0, 100)]
        [int]$PercentComplete = 0,

        [string]$Status = "",

        [int]$Width = 30,

        [switch]$ShowPercentage,

        [ValidateSet('Blocks', 'Gradient', 'Dots', 'Lines', 'Smooth', 'Fire')]
        [string]$BarStyle = 'Gradient',

        [ValidateSet('RedToGreen', 'BlueToGreen', 'Rainbow', 'Fire', 'Ocean', 'Custom')]
        [string]$GradientStyle = 'RedToGreen',

        [string]$CustomStartColor,
        [string]$CustomEndColor,

        [switch]$Animated
    )

    # Символы для разных стилей
    $styles = @{
        'Blocks' = @{ Full = "█"; Empty = "░"; Partial = "▓" }
        'Gradient' = @{ Full = "█"; Empty = "░"; Partial = "▓" }
        'Dots' = @{ Full = "●"; Empty = "○"; Partial = "◐" }
        'Lines' = @{ Full = "━"; Empty = "╌"; Partial = "─" }
        'Smooth' = @{ Full = "▰"; Empty = "▱"; Partial = "▰" }
        'Fire' = @{ Full = "🔥"; Empty = "💨"; Partial = "🔸" }
    }

    # Градиентные схемы
    $gradientSchemes = @{
        'RedToGreen' = @{
            Colors = @("#FF0000", "#FF4500", "#FFA500", "#FFFF00", "#ADFF2F", "#00FF00")
        }
        'BlueToGreen' = @{
            Colors = @("#0000FF", "#0080FF", "#00FFFF", "#00FF80", "#00FF00")
        }
        'Rainbow' = @{
            Colors = @("#FF0000", "#FF7F00", "#FFFF00", "#00FF00", "#0000FF", "#4B0082", "#9400D3")
        }
        'Fire' = @{
            Colors = @("#8B0000", "#FF0000", "#FF4500", "#FFA500", "#FFD700", "#FFFF00")
        }
        'Ocean' = @{
            Colors = @("#000080", "#0000FF", "#0080FF", "#00FFFF", "#40E0D0")
        }
        'Custom' = @{
            Colors = @($CustomStartColor, $CustomEndColor)
        }
    }

    $chars = $styles[$BarStyle]
    $filled = [Math]::Floor(($PercentComplete / 100) * $Width)
    $empty = $Width - $filled

    # Анимация начала (если включена)
    if ($Animated) {
        $spinners = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
        foreach ($spinner in $spinners) {
            Write-Host "`r$spinner $Activity" -NoNewline -ForegroundColor Cyan
            Start-Sleep -Milliseconds 50
        }
        Write-Host "`r" -NoNewline
    }

    # Вывод активности
    Write-RGB "$Activity" -FC "Lavender" -Style Bold

    if ($Status) {
        Write-RGB " ($Status)" -FC "PastelYellow"
    }
    Write-Host ""  # Новая строка после активности

    # Открывающая скобка
    Write-RGB "[" -FC "Silver"

    # Прогресс-бар
    if ($BarStyle -eq 'Gradient' -or $BarStyle -eq 'Smooth') {
        $scheme = $gradientSchemes[$GradientStyle]
        $colorCount = $scheme.Colors.Count

        for ($i = 0; $i -lt $filled; $i++) {
            $colorIndex = [Math]::Floor(($i / $Width) * ($colorCount - 1))
            $nextColorIndex = [Math]::Min($colorIndex + 1, $colorCount - 1)

            $localPosition = (($i / $Width) * ($colorCount - 1)) - $colorIndex

            $color = if ($GradientStyle -eq 'Custom' -and $CustomStartColor -and $CustomEndColor) {
                Get-GradientColor -Index $i  -TotalItems 100`
                                 -StartColor $CustomStartColor `
                                 -EndColor $CustomEndColor
            } else {
                Get-GradientColor -Index $i  -TotalItems 100`
                                 -StartColor $scheme.Colors[$colorIndex] `
                                 -EndColor $scheme.Colors[$nextColorIndex]
            }

            Write-RGB $chars.Full -FC $color
        }
    } else {
        # Простой цвет на основе процента
        $progressColor = if ($PercentComplete -lt 33) {
            "#FF6B6B"
        } elseif ($PercentComplete -lt 66) {
            "#FFD93D"
        } else {
            "#6BCF7F"
        }

        Write-RGB ($chars.Full * $filled) -FC $progressColor
    }

    # Пустая часть
    Write-RGB ($chars.Empty * $empty) -FC "#333333"

    # Закрывающая скобка и процент на той же строке
    Write-RGB "]" -FC "Silver"

    # Процент
    if ($ShowPercentage) {
        Write-RGB " $PercentComplete%" -FC "ElectricBlue" -Style Bold
    }

    Write-Host ""  # Новая строка в конце

    # Дополнительное сообщение о завершении
    if ($PercentComplete -eq 100) {
        Write-RGB "✅ Complete!" -FC "LimeGreen" -Style Bold -newline
    }
}

# Улучшенная функция для анимированных прогресс-баров
function Show-AnimatedProgress {
    <#
    .SYNOPSIS
        Показывает анимированный прогресс с обновлением в реальном времени
    #>
    param(
        [string]$Activity = "Processing",
        [int]$TotalSteps = 100,
        [int]$CurrentStep = 0,
        [scriptblock]$Action,
        [int]$UpdateInterval = 100
    )

    $startTime = Get-Date

    for ($i = $CurrentStep; $i -le $TotalSteps; $i++) {
        $percent = [Math]::Round(($i / $TotalSteps) * 100)
        $elapsed = (Get-Date) - $startTime
        $speed = if ($i -gt 0) { $i / $elapsed.TotalSeconds } else { 0 }
        $eta = if ($speed -gt 0) {
            [TimeSpan]::FromSeconds(($TotalSteps - $i) / $speed)
        } else {
            [TimeSpan]::Zero
        }

        # Очищаем строку
        Write-Host "`r$(' ' * 100)`r" -NoNewline

        # Показываем прогресс
        $status = "Step $i/$TotalSteps | Speed: $([Math]::Round($speed, 2))/s | ETA: $($eta.ToString('mm\:ss'))"

        # Сохраняем позицию курсора
        $pos = $Host.UI.RawUI.CursorPosition
        $pos.Y -= 2  # Поднимаемся на 2 строки вверх
        if ($pos.Y -ge 0) {
            $Host.UI.RawUI.CursorPosition = $pos
        }

        Show-RGBProgress -Activity $Activity `
                        -PercentComplete $percent `
                        -Status $status `
                        -BarStyle Gradient `
                        -GradientStyle $(if ($percent -lt 50) { 'Fire' } else { 'Ocean' }) `
                        -ShowPercentage

        # Выполняем действие если указано
        if ($Action) {
            & $Action $i
        }

        Start-Sleep -Milliseconds $UpdateInterval
    }
}


# Функция для создания составных прогресс-баров
function Show-MultiProgress {
    <#
    .SYNOPSIS
        Показывает несколько прогресс-баров одновременно
    #>
    param(
        [hashtable[]]$Tasks
    )

    # Сохраняем начальную позицию
    $startPos = $Host.UI.RawUI.CursorPosition

    while ($true) {
        # Возвращаемся к начальной позиции
        $Host.UI.RawUI.CursorPosition = $startPos

        $allComplete = $true

        foreach ($task in $Tasks) {
            if ($task.Current -lt $task.Total) {
                $allComplete = $false
                $task.Current++
            }

            $percent = [Math]::Round(($task.Current / $task.Total) * 100)

            Show-RGBProgress -Activity $task.Name `
                            -PercentComplete $percent `
                            -BarStyle $task.Style `
                            -GradientStyle $task.GradientStyle `
                            -Width 25 `
                            -ShowPercentage
        }

        if ($allComplete) {
            break
        }

        Start-Sleep -Milliseconds 100
    }

    Write-RGB "`n🎉 All tasks completed!" -FC "LimeGreen" -Style Bold -newline
}

# Демонстрация прогресс-баров
function Show-ProgressDemo {
    Clear-Host

    Write-GradientHeader -Title "PROGRESS BAR SHOWCASE"

    Write-RGB "`n1️⃣ Различные стили прогресс-баров:" -FC "Cyan" -Style Bold -newline

    $styles = @('Blocks', 'Gradient', 'Dots', 'Lines', 'Smooth')
    $percent = 0

    foreach ($style in $styles) {
        $percent += 20
        Write-RGB "`nСтиль: $style" -FC "Yellow" -newline
        Show-RGBProgress -Activity "Demo $style" `
                        -PercentComplete $percent `
                        -BarStyle $style `
                        -ShowPercentage
    }

    Write-RGB "`n`n2️⃣ Градиентные схемы:" -FC "Cyan" -Style Bold -newline

    $gradients = @('RedToGreen', 'BlueToGreen', 'Rainbow', 'Fire', 'Ocean')

    foreach ($gradient in $gradients) {
        Write-RGB "`n$gradient`:" -FC "Yellow" -newline
        Show-RGBProgress -Activity "Gradient Demo" `
                        -PercentComplete 75 `
                        -BarStyle Gradient `
                        -GradientStyle $gradient `
                        -ShowPercentage
    }

    Write-RGB "`n`n3️⃣ Анимированный прогресс:" -FC "Cyan" -Style Bold -newline
    Write-RGB "Нажмите Enter для запуска анимации..." -FC "DarkGray"
    Read-Host

    Show-AnimatedProgress -Activity "Downloading files" -TotalSteps 50

    Write-RGB "`n`n4️⃣ Мультипрогресс:" -FC "Cyan" -Style Bold -newline
    Write-RGB "Нажмите Enter для запуска..." -FC "DarkGray"
    Read-Host

    $tasks = @(
        @{ Name = "Download"; Current = 0; Total = 100; Style = "Gradient"; GradientStyle = "Ocean" }
        @{ Name = "Process"; Current = 0; Total = 80; Style = "Dots"; GradientStyle = "Fire" }
        @{ Name = "Upload"; Current = 0; Total = 60; Style = "Lines"; GradientStyle = "Rainbow" }
    )

#    Show-MultiProgress -Tasks $tasks
}

# Исправленный вызов примеров прогресс-баров
function Show-ProgressExamples {
    Write-RGB "Примеры прогресс-баров:" -FC "Lavender" -Style Bold -newline

    Show-RGBProgress -Activity "Загрузка данных" -PercentComplete 25 -ShowPercentage
    Show-RGBProgress -Activity "Обработка" -PercentComplete 60 -BarStyle Dots -ShowPercentage
    Show-RGBProgress -Activity "Завершение" -PercentComplete 100 -BarStyle Lines -ShowPercentage
    Write-Host ""
}

#Show-ProgressExamples