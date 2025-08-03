importProcess  $MyInvocation.MyCommand.Name.trim('.ps1') -start
#
function Show-AllGradientDemos {
    <#
   .SYNOPSIS
       Запускает все демонстрации градиентов
   #>

    #    Clear-Host

    Write-GradientHeader -Title "POWERSHELL RGB GRADIENTS SHOWCASE" `
        -StartColor "#FF00FF" -EndColor "#00FFFF"

    # Типы градиентов
    Test-GradientTypes
    wrgb "`nНажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host

    # Интенсивность

    wrgb "`nНажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host

    # Палитры
    Show-GradientPalettes
    wrgb "`nНажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host

    # Текст
    Test-GradientText
   


    
    Show-Palette Dracula
    wrgb "`nНажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host     
    Show-Palette Nord
    wrgb "`nНажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host
    Show-Palette Material
    wrgb "`nНажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host
    Show-Palette Cyber
    wrgb "`nНажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host
    Show-Palette OneDark
    wrgb "`nНажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host
    Show-GradientPalettes
    wrgb "`nНажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host

    # Меню
    $menuItems = @("🎨 Цвета", "📊 Графики", "⚙️ Настройки", "❌ Выход")
    New-GradientMenu -Items $menuItems -Title "Главное меню" -Style "Neon"

    wrgb "`n✨ Демонстрация завершена!" -FC "LimeGreen" -Style Bold -newline
}

# Быстрая проверка градиента между двумя цветами
function Test-QuickGradient {
    param(
        [string]$Start = "#FF0000",
        [string]$End = "#0000FF"
    )

    wrgb "Градиент от " -FC "White"
    wrgb "■" -FC $Start
    wrgb " до " -FC "White"
    wrgb "■" -FC $End
    wrgb ": " -FC "White"

    for ($i = 0; $i -lt 20; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems 20 -StartColor $Start -EndColor $End
        wrgb "█" -FC $color
    }
    Write-Host ""
}



function Show-Welcome {
    #    Clear-Host

    wrgb "`n💡 " -FC White
    wrgb "Type " -FC Material_Grey
    wrgb "Show-MainMenu" -FC NeonPinkRGB
    wrgb " or " -FC Material_Grey
    wrgb "menu" -FC LimeRGB
    wrgb " to open the main menu 💡`n`n" -FC Material_Grey -newline

    # Анимированный заголовок
    $title = "POWERSHELL PROFILE "
    for ($i = 0; $i -lt $title.Length; $i++) {

        #        Get-GradientColor  $title[$i]  -Index $i   -TotalItems $title.Length  -StartColor UkraineBlueRGB    -EndColor  UkraineYellowRGB
        Start-Sleep -Milliseconds 30
    }
    wrgb " 🇺🇦" -newline

    wrgb "═════════════════════════════════════════════════════" -FC UkraineBlueRGB -newline


    # Системная информация
    Write-Host "📅 " -NoNewline
    Write-Host "⏰ " -NoNewline
    wrgb (Get-Date -Format "dd.MM.yyyy ") -FC LimeRGB
    wrgb (Get-Date -Format "HH:mm") -FC WhiteRGB -newline

    Write-Host "🖥️  " -NoNewline
    wrgb "Windows 11 " -FC CyanRGB -newline
    Write-Host "⚡ " -NoNewline
    wrgb "PowerShell " -FC YellowRGB
    wrgb "$( $PSVersionTable.PSVersion )" -FC NeonMaterial_LightGreen -newline

    # Статистика
    $processCount = (Get-Process).Count
    wrgb "⚙️  Processes: " -FC OrangeRGB
    wrgb "$processCount" -FC NeonBlueRGB
    wrgb " running" -FC OrangeRGB -newline
    wrgb "═════════════════════════════════════════════════════" -FC UkraineYellowRGB -newline

    #     @"
    # CPU: $( (Get-Counter "\Процессор(_Total)\% загруженности процессора").CounterSamples.CookedValue )%
    # RAM: $([math]::Round((Get-Counter "\Память\Доступно МБ").CounterSamples.CookedValue / 1024, 1) ) GB
    # "@

    #     CPU и RAM с анимацией
    #     wrgb "📊 " -FC White
    #     wrgb "CPU: " -FC CyanRGB
    #     $cpuUsage = [math]::Round((Get-Counter -ErrorAction SilentlyContinue).CounterSamples, 1)
    #     wrgb "$cpuUsage%" -FC NeonMaterial_LightGreen
    #     wrgb " | " -FC White
    #     wrgb "RAM: " -FC MagentaRGB
    #     $availableRam = [math]::Round((Get-Counter "\Memory\Available MBytes" -ErrorAction SilentlyContinue).CounterSamples.CookedValue / 1024, 1)
    #     wrgb "$availableRam GB free" -FC NeonPinkRGB -newline

    #    wrgb "═════════════════════════════════════════════════════`n" -FC UkraineYellowRGB -newline

    wrgb "Текущий ErrorView: " -FC Material_Yellow
    wrgb    $global:ErrorView -FC Green -newline
    if ($Error.Count -ge 3) {
        wrgb "`n`n---- Последние 3 ошибки ---" -FC Red -newline
        Show-RecentErrors -Count 3

        Get-ErrorSummary
        wrgb "`n" -newline
    }

      

    #    Show-ErrorBrowser


    #   
    #    Show-ParserDemo
    #    Test-GradientIntensity
}


Show-Welcome

#Show-AllGradientDemos
importProcess  $MyInvocation.MyCommand.Name.trim('.ps1')