function Show-AllGradientDemos {
    <#
    .SYNOPSIS
        Запускает все демонстрации градиентов
    #>

    Clear-Host

    Write-GradientHeader -Title "POWERSHELL RGB GRADIENTS SHOWCASE" `
                        -StartColor "#FF00FF" -EndColor "#00FFFF"

    # Типы градиентов
    Test-GradientTypes
    Write-RGB "`nНажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host

    # Интенсивность

    Write-RGB "`nНажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host

    # Палитры
    Show-GradientPalettes
    Write-RGB "`nНажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host

    # Текст
    Test-GradientText
    Write-RGB "`nНажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host

    # Меню
    $menuItems = @("🎨 Цвета", "📊 Графики", "⚙️ Настройки", "❌ Выход")
    New-GradientMenu -Items $menuItems -Title "Главное меню" -Style "Neon"

    Write-RGB "`n✨ Демонстрация завершена!" -FC "LimeGreen" -Style Bold -newline
}

# Быстрая проверка градиента между двумя цветами
function Test-QuickGradient {
    param(
        [string]$Start = "#FF0000",
        [string]$End = "#0000FF"
    )

    Write-RGB "Градиент от " -FC "White"
    Write-RGB "■" -FC $Start
    Write-RGB " до " -FC "White"
    Write-RGB "■" -FC $End
    Write-RGB ": " -FC "White"

    for ($i = 0; $i -lt 20; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems 20 -StartColor $Start -EndColor $End
        Write-RGB "█" -FC $color
    }
    Write-Host ""
}



function Show-Welcome
{
    #    Clear-Host

    # Подсказка с градиентом
    #    Write-RGB "`n💡 " -FC White
    #    Write-RGB "Type " -FC Gray
    #    Write-RGB "Show-MainMenu" -FC NeonPinkRGB
    #    Write-RGB " or " -FC Gray
    #    Write-RGB "menu" -FC LimeRGB
    #    Write-RGB " to open the main menu 💡`n`n" -FC Gray -newline

    # Анимированный заголовок
    $title = "POWERSHELL PROFILE "
    for ($i = 0; $i -lt $title.Length; $i++) {

        Write-RGB $title[$i] -FC $color
        Start-Sleep -Milliseconds 30
    }
    Write-RGB " 🇺🇦" -newline

    Write-RGB "═════════════════════════════════════════════════════" -FC UkraineBlueRGB -newline

    # Системная информация
    Write-Host "⏰ " -NoNewline
    Write-RGB (Get-Date -Format "dd.MM.yyyy ") -FC LimeRGB
    Write-RGB (Get-Date -Format "HH:mm") -FC WhiteRGB -newline

    Write-Host "🖥️  " -NoNewline
    Write-RGB "Windows 11 " -FC CyanRGB -newline
    Write-Host "⚡ " -NoNewline
    Write-RGB "PowerShell " -FC YellowRGB
    Write-RGB "$( $PSVersionTable.PSVersion )" -FC NeonMaterial_LightGreen -newline

    # Статистика
    $processCount = (Get-Process).Count
    Write-RGB "⚙️  Processes: " -FC OrangeRGB
    Write-RGB "$processCount" -FC NeonBlueRGB
    Write-RGB " running" -FC OrangeRGB -newline

    #     @"
    # CPU: $( (Get-Counter "\Процессор(_Total)\% загруженности процессора").CounterSamples.CookedValue )%
    # RAM: $([math]::Round((Get-Counter "\Память\Доступно МБ").CounterSamples.CookedValue / 1024, 1) ) GB
    # "@

#     CPU и RAM с анимацией
#     Write-RGB "📊 " -FC White
#     Write-RGB "CPU: " -FC CyanRGB
#     $cpuUsage = [math]::Round((Get-Counter -ErrorAction SilentlyContinue).CounterSamples, 1)
#     Write-RGB "$cpuUsage%" -FC NeonMaterial_LightGreen
#     Write-RGB " | " -FC White
#     Write-RGB "RAM: " -FC MagentaRGB
#     $availableRam = [math]::Round((Get-Counter "\Memory\Available MBytes" -ErrorAction SilentlyContinue).CounterSamples.CookedValue / 1024, 1)
#     Write-RGB "$availableRam GB free" -FC NeonPinkRGB -newline

    Write-RGB "═════════════════════════════════════════════════════`n" -FC UkraineYellowRGB -newline

    Write-RGB "Текущий ErrorView: " -FC Dracula_Yellow
    Write-RGB    $global:ErrorView -FC Green -newline
    if ($Error.Count -ge 3)
    {
        Write-RGB "`n`n---- Последние 3 ошибки ---" -FC Red -newline
        Show-RecentErrors -Count 3

        Get-ErrorSummary
        Write-RGB "`n" -newline
    }

#    Show-Palette Dracula
#    Show-GradientPalettes

#    Show-ErrorBrowser


#    Test-GradientDemo
#    Show-ParserDemo
#    Test-GradientIntensity
}
#Show-AllGradientDemos