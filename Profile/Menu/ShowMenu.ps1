# ===== УЛУЧШЕННАЯ ФУНКЦИЯ МЕНЮ С ГРАДИЕНТАМИ =====
function Show-Menu
{
    param(
        [Parameter(Mandatory = $true)]
        [array]$MenuItems,
        [string]$MenuTitle = "Menu",
        [string]$Prompt = "Select option",
        [hashtable]$GradientOptions = @{
        StartColor = "#01BB01"
        EndColor = "#0099cc"
        GradientType = "Linear"
    }

    )

    while ($true)
    {
        if ($MenuTitle)
        {
            Write-RGB "`n$MenuTitle" -FC GoldRGB -newline
            Write-RGB ("─" * 60) -FC PurpleRGB -newline
        }

        for ($i = 0; $i -lt $MenuItems.Count; $i++) {
            $num = $i + 1
            $numberColor = ($num -lt $MenuItems.Count) ? "Ocean2RGB": "#FF5522"
            $hexColor = ($num -lt $MenuItems.Count) ? (Get-GradientColor -Index $i -TotalItems $MenuItems.Count @GradientOptions):  "#FF5522"

            Write-RGB "[" -FC NeonMaterial_LightGreen
            Write-RGB $num -FC $numberColor
            Write-RGB "] " -FC NeonMaterial_LightGreen
            Write-RGB $MenuItems[$i].Text -FC $hexColor -newline
            Start-Sleep -Milliseconds 50
        }


        Write-RGB "`n" -newline
        Write-RGB "➤ " -FC NeonMaterial_LightGreen
        Write-RGB "$Prompt (1-$( $MenuItems.Count )): " -FC  "99CCFF"

        # ИСПРАВЛЕНИЕ: правильное чтение ввода
        $menuInput = [Console]::ReadLine()

        if ($menuInput -match '^\d+$')
        {
            $choice = [int]$menuInput
            if ($choice -ge 1 -and $choice -le $MenuItems.Count)
            {
                # Анимация выбора
                Write-RGB "`n✨ " -FC YelloWrite-RGB
                Write-RGB "Выбрано: " -FC White
                Write-RGB $MenuItems[$choice - 1].Text -FC NeonMaterial_LightGreen -newline
                Start-Sleep -Milliseconds 750
                return $MenuItems[$choice - 1]
            }
        }

        Write-RGB "❌ Неверный выбор! Попробуйте снова." -FC Red -newline
        Start-Sleep -Seconds 1
        #cd -Host
    }
}

function Show-RGBLoader
{
    param(
        [string]$Text = "Loading",
        [int]$Duration = 3
    )

    $frames = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
    $colors = @('NeonBlueRGB', 'NeonMaterial_LightGreen', 'NeonPinkRGB', 'CyanRGB', 'MagentaRGB')

    $endTime = (Get-Date).AddSeconds($Duration)
    $i = 0

    while ((Get-Date) -lt $endTime)
    {
        $frame = $frames[$i % $frames.Length]
        $color = $colors[$i % $colors.Length]

        Write-RGB "`r$frame $Text..." -FC $color
        Start-Sleep -Milliseconds 100
        $i++
    }
    Write-RGB "`r✨ Done!    " -FC LimeRGB -newline
}

function Show-RGBProgress
{
    param(
        [string]$Activity = "Processing",
        [int]$TotalSteps = 100,
        [switch]$Gradient
    )

    for ($i = 0; $i -le $TotalSteps; $i++) {
        $percent = [int](($i / $TotalSteps) * 100)
        $filled = [int](($i / $TotalSteps) * 30)
        $empty = 30 - $filled
        Color
        if ($Gradient)
        {
            # Градиентный прогресс бар
            $bar = ""
            for ($j = 0; $j -lt $filled; $j++) {
                $color = Get-GradientColor -Index $j -TotalItems 30 -StartColor "#00FF00" -EndColor "#FF0000"
                $bar += "█"
            }
            $bar += "░" * $empty

            Write-Host "`r$Activity [" -NoNewline
            for ($j = 0; $j -lt $filled; $j++) {
                $color = Get-GradientColor -Index $j -TotalItems 30 -StartColor "#00FF00" -EndColor "#FF0000"
                Write-RGB "█" -FC $color
            }
            Write-Host ("░" * $empty + "] $percent%") -NoNewline
        }
        else
        {
            $r = [int](255 * ($i / $TotalSteps))
            $g = [int](255 * (1 - $i / $TotalSteps))
            $b = 128

            $bar = "█" * $filled + "░" * $empty
            Write-RGB "`r$Activity [$bar] $percent%" -FC $PSStyle.Foreground.FromRgb($r, $g, $b)
        }

        Start-Sleep -Milliseconds 20
    }
    Write-RGB "`n✅ Complete!" -FC LimeRGB -newline
}

function Show-RGBDemo
{
    #Clear-Host
    #    Write-RGB "`n🌈 RGB COLOR DEMONSTRATION 🌈" -FC UkraineBlueRGB -newline

    # Градиентная линия
    #    for ($i = 0; $i -lt 60; $i++) {
    #        $color = Get-GradientColor -Index $i -TotalItems 60 -StartColor "#FF0000" -EndColor "#0000FF" -GradientType "Sine"
    #        Write-RGB "═" -FC $color
    #    }
    #    Write-RGB "" -newline

    # Цветовая волна
    #    Write-RGB "`n🎨 Color Wave:" -FC White -newline
    #    for ($i = 0; $i -lt 360; $i += 5) {
    #        $r = [Math]::Sin($i * [Math]::PI / 180)  + 128
    #        $g = [Math]::Sin($i * [Math]::PI / 180)  + 128
    #        $b = [Math]::Sin($i  * [Math]::PI / 180)  + 128
    #        Write-RGB "█" -FC $PSStyle.Foreground.FromRgb([int]$r, [int]$g, [int]$b)
    #    }
    #    Write-RGB "" -newline

    # Матрица с градиентом
    Write-RGB "`n💻 Matrix Effect:" -FC LimeRGB -newline
    for ($row = 0; $row -lt 5; $row++) {
        for ($col = 0; $col -lt 40; $col++) {
            $char = [char](Get-Random -Minimum 33 -Maximum 126)
            $greenShade = Get-GradientColor -Index $col -TotalItems 40 -StartColor "#00FF00" -EndColor "#001100"
            Write-RGB $char -FC $greenShade
        }
        Write-RGB "" -newline
    }

    # Неоновые цвета
    Write-RGB "`n✨ Neon Colors:" -FC White -newline
    $neonColors = @("NeonBlueRGB", "NeonMaterial_LightGreen", "NeonPinkRGB", "NeonRedRGB", "CyanRGB", "MagentaRGB", "YelloWrite-RGB", "OrangeRGB")
    foreach ($colorName in $neonColors)
    {
        Write-RGB "████ " -FC $colorName
        Write-RGB $colorName -FC $colorName -newline
    }

    # Градиентный текст
    Write-RGB "`n🎯 Gradient Text:" -FC White -newline
    $text = "POWERSHELL ROCKS!"
    for ($i = 0; $i -lt $text.Length; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems $text.Length -StartColor "#FF00FF" -EndColor "#00FFFF" -GradientType "Exponential"
        Write-RGB $text[$i] -FC $color
    }
    Write-RGB "" -newline

    Write-RGB "`nНажмите любую клавишу..." -FC CyanRGB -newline
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-MainMenu
}


if (Get-Module -ListAvailable -Name SecurityWatcher)
{
    Import-Module SecurityWatcher -ErrorAction SilentlyContinue
    Write-RGB "🛡️  SecurityWatcher loaded" -FC LimeRGB -newline
}