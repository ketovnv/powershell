function Show-Welcome {
    Clear-Host

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
        $color = Get-GradientColor -Index $i -TotalItems $title.Length -StartColor "#0057B7" -EndColor "#FFD700"
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
    Write-RGB "$($PSVersionTable.PSVersion)" -FC NeonGreenRGB -newline

    # Статистика
    $processCount = (Get-Process).Count
    Write-RGB "⚙️  Processes: " -FC OrangeRGB
    Write-RGB "$processCount" -FC NeonBlueRGB
    Write-RGB " running" -FC OrangeRGB -newline

    #     @"
    # CPU: $( (Get-Counter "\Процессор(_Total)\% загруженности процессора").CounterSamples.CookedValue )%
    # RAM: $([math]::Round((Get-Counter "\Память\Доступно МБ").CounterSamples.CookedValue / 1024, 1) ) GB
    # "@

    # CPU и RAM с анимацией
    # Write-RGB "📊 " -FC White
    # Write-RGB "CPU: " -FC CyanRGB
    # $cpuUsage = [math]::Round((Get-Counter -ErrorAction SilentlyContinue).CounterSamples, 1)
    # Write-RGB "$cpuUsage%" -FC NeonGreenRGB
    # Write-RGB " | " -FC White
    # Write-RGB "RAM: " -FC MagentaRGB
    # $availableRam = [math]::Round((Get-Counter "\Memory\Available MBytes" -ErrorAction SilentlyContinue).CounterSamples.CookedValue / 1024, 1)
    # Write-RGB "$availableRam GB free" -FC NeonPinkRGB -newline
    Write-RGB "═════════════════════════════════════════════════════" -FC UkraineYellowRGB -newline
}