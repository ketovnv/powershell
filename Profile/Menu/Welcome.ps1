Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

function Show-Welcome
{
    #        Clear-Host
    #    wrgb "Type " -FC Material_Grey
    #    wrgb "Show-MainMenu" -FC NeonPinkRGB
    #    wrgb " or " -FC Material_Grey
    #    wrgb "menu" -FC LimeRGB
    #    wrgb " to open the main menu " -FC Material_Grey -newline

    # Анимированный заголовок
    $title = "POWERSHELL PROFILE "
    #           wgt $title -StartColor  UkraineBlueRGB  -EndColor 'UkraineYellowRGB'
    #        spj  $global:RGB
    for ($i = 0; $i -lt $title.Length; $i++) {

        #            $color =Get-GradientColor  $title[$i]  -Index $i   -TotalItems $title.Length  -StartColor $global:RGB['UkraineBlueRGB']    -EndColor  $global:RGB['UkraineYellowRGB']
        #            wrgb $title[$i] -FC $color
        #            Start-Sleep -Milliseconds 30
    }
    #    wrgb " 🇺🇦 🇺🇦 🇺🇦 🇺🇦 🇺🇦"   -FC UkraineBlueRGB -newline
    #    wrgb " 🇺🇦 🇺🇦 🇺🇦 🇺🇦 🇺🇦"  -FC UkraineYellowRGB -newline
    #    pres --ukraine
    #    wrgb "══════════════════════════════════════════════════════════" -FC UkraineYellowRGB -newline
    #    wrgb "❀ ☘ ✿ ☘ ❀ ☘ ✿ ☘ ❀ ☘ ✿ ☘ ❀ ☘ ✿ ☘ ❀ ☘ ✿ ☘ ❀ ☘ ✿ ☘ ❀ ☘ ✿ ☘ ❀"  -FC UkraineBlueRGB -newline

    Write-Host "🖥️  " -NoNewline
    wrgb "Windows 11" -FC CyanRGB
    Write-Host " 🪐" -NoNewline
    wrgb " PowerShell " -FC YellowRGB
    wrgb "$( $PSVersionTable.PSVersion )" -FC NeonMaterial_LightGreen


    # Системная информация
    Write-Host "  📅 " -NoNewline
    wrgb (Get-Date -Format " dd.MM.yyyy ") -FC LimeRGB
    Write-Host "                ⏰ " -NoNewline
    wrgb (Get-Date -Format "HH:mm") -FC WhiteRGB -newline

    # Статистика
    #    $processCount = (Get-Process).Count
    #    wrgb "⚙️  Processes: " -FC OrangeRGB
    #    wrgb "$processCount" -FC NeonBlueRGB
    #    wrgb " running" -FC OrangeRGB -newline
    #    wrgb "══════════════════════════════════════════════════════════" -FC UkraineBlueRGB -newline
    #    wrgb "❀ ☘ ✿ ☘ ❀ ☘ ✿ ☘ ❀ ☘ ✿ ☘ ❀ ☘ ✿ ☘ ❀ ☘ ✿ ☘ ❀ ☘ ✿ ☘ ❀ ☘ ✿ ☘ ❀" -FC UkraineYellowRGB -newline

     if (!$env:WEZTERM_CONFIG_DIR)
     {
        wrgbn "💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛💙💛"
     }
     else
     {
        wrgbn  "🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦🇺🇦"
     }


    # wrgb ""  -newline
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

    #    wrgb "Текущий ErrorView: " -FC Material_Yellow
    #    wrgb    $global:ErrorView -FC Green -newline
    if ($Error.Count -ge 3)
    {
        wrgb "`n`n---- Последние 3 ошибки ---" -FC Red -newline
        Show-RecentErrors -Count 3

        Get-ErrorSummary
        wrgb "`n" -newline
    }

    #    Show-ErrorBrowser
    #    Show-ParserDemo

}


Show-Welcome
#Show-PygmentsThemes
#Show-AllGradientDemos
Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))
