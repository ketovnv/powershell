# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    🎨 POWERSHELL PROFILE v4.0 ULTRA RGB                   ║
# ║                         Ukraine Edition 🇺🇦                                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module
Import-Module -Name Microsoft.WinGet.CommandNotFound -ErrorAction SilentlyContinue
#f45873b3-b655-43a6-b217-97c00aa0db58
Import-Module Microsoft.PowerShell.PSResourceGet -Force


$newModulePath = "C:\Users\ketov\Documents\PowerShell\Modules"
$env:PSModulePath = $newModulePath
[Environment]::SetEnvironmentVariable("PSModulePath", $newModulePath, "User")
$env:POSH_IGNORE_ALLUSER_PROFILES = $true

# ===== ИМПОРТ Aliases и GRADIENT ФУНКЦИЙ =====


$scripts = @( 
    'Aliases',
    'GradientTable',
    'NetworkSystem',
    'Wellcome',
    'MenuItems',
    'AppsBrowsersMenu'
    # 'AnalizeModuleFunctions'
)


foreach ($script in $scripts) {
    . "$PSScriptRoot/Profile/$script.ps1"
}


# ===== МОДУЛИ =====
$modules = @( 
    'PSColor',
    'Terminal-Icons',
    'PSFzf',
    'syntax-highlighting'
)

foreach ($module in $modules)
{
    if (Get-Module -ListAvailable -Name $module)
    {
        Import-Module -Name $module -ErrorAction SilentlyContinue
    }
    else
    {
        Write-Host "[!] Модуль $module отсутствует. Установите: Install-Module $module" -ForegroundColor    Red
    }
}





# ===== OH-MY-POSH =====
$ompConfig = 'C:\scripts\OhMyPosh\free-ukraine.omp.json'
if (Test-Path $ompConfig)
{
    oh-my-posh init pwsh --config $ompConfig | Invoke-Expression
}

# ===== RGB ЦВЕТОВАЯ ПАЛИТРА =====
$global:RGB = @{
# Основные цвета
    WhiteRGB = @{ R = 255; G = 255; B = 255 }
    CyanRGB = @{ R = 0; G = 150; B = 255 }
    MagentaRGB = @{ R = 255; G = 0; B = 255 }
    YellowRGB = @{ R = 255; G = 255; B = 0 }
    OrangeRGB = @{ R = 255; G = 165; B = 0 }
    PinkRGB = @{ R = 255; G = 20; B = 147 }
    PurpleRGB = @{ R = 138; G = 43; B = 226 }
    LimeRGB = @{ R = 50; G = 205; B = 50 }
    TealRGB = @{ R = 0; G = 128; B = 128 }
    GoldRGB = @{ R = 255; G = 215; B = 0 }
    CocoaBeanRGB = @{ R = 79; G = 56; B = 53 }

    # Неоновые цвета
    NeonBlueRGB = @{ R = 77; G = 200; B = 255 }
    NeonGreenRGB = @{ R = 57; G = 255; B = 20 }
    NeonPinkRGB = @{ R = 255; G = 70; B = 200 }
    NeonRedRGB = @{ R = 255; G = 55; B = 100 }

    # Градиентные цвета
    Sunset1RGB = @{ R = 255; G = 94; B = 77 }
    Sunset2RGB = @{ R = 255; G = 154; B = 0 }
    Ocean1RGB = @{ R = 0; G = 119; B = 190 }
    Ocean2RGB = @{ R = 0; G = 180; B = 216 }
    Ocean3RGB = @{ R = 0; G = 150; B = 160 }
    Ocean4RGB = @{ R = 0; G = 205; B = 230 }

    # Украинские цвета 🇺🇦
    UkraineBlueRGB = @{ R = 0; G = 87; B = 183 }
    UkraineYellowRGB = @{ R = 255; G = 213; B = 0 }
}

# Функция для создания RGB цвета
function Get-RGBColor
{
    param($Color)
    return $PSStyle.Foreground.FromRgb($Color.R, $Color.G, $Color.B)
}

function Write-RGB
{
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromRemainingArguments = $true)]
        [string[]] $Text,
        [string] $FC = 'White',
        [switch] $newline = $false
    )

    $fullText = $Text -join ' '

    $systemColors = @(
        "Black", "DarkBlue", "DarkGreen", "DarkCyan",
        "DarkRed", "DarkMagenta", "DarkYellow", "Gray",
        "DarkGray", "Blue", "Green", "Cyan",
        "Red", "Magenta", "Yellow", "White"
    )

    if ($FC -in $systemColors)
    {
        Write-Host $fullText -ForegroundColor $FC -NoNewline:(-not $newline)
    }
    elseif ($global:RGB.ContainsKey($FC))
    {
        $rgbColor = Get-RGBColor $global:RGB[$FC]
        Write-Host "${rgbColor}${fullText}${PSStyle.Reset}" -NoNewline:(-not $newline)
    }
    elseif ($FC -match '^#[0-9A-Fa-f]{6}$')
    {
        $r = [Convert]::ToInt32($FC.Substring(1, 2), 16)
        $g = [Convert]::ToInt32($FC.Substring(3, 2), 16)
        $b = [Convert]::ToInt32($FC.Substring(5, 2), 16)
        $rgbColor = $PSStyle.Foreground.FromRgb($r, $g, $b)
        Write-Host "${rgbColor}${fullText}${PSStyle.Reset}" -NoNewline:(-not $newline)
    }
    else
    {
        Write-Host $fullText -ForegroundColor White -NoNewline:(-not $newline)
    }
}

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
        EndColor = "#FF9955"
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
            $numberColor = ($num -lt $MenuItems.Count) ? "Ocean2RGB ": "#FF5522"
            $hexColor = ($num -lt $MenuItems.Count) ? (Get-GradientColor -Index $i -TotalItems $MenuItems.Count @GradientOptions):  "#FF5522"

            Write-RGB "[" -FC NeonGreenRGB
            Write-RGB $num -FC $numberColor
            Write-RGB "] " -FC NeonGreenRGB
            Write-RGB $MenuItems[$i].Text -FC $hexColor -newline
            Start-Sleep -Milliseconds 50
        }


        Write-RGB "`n" -newline
        Write-RGB "➤ " -FC NeonGreenRGB
        Write-RGB "$Prompt (1-$( $MenuItems.Count )): " -FC  "99CCFF"

        # ИСПРАВЛЕНИЕ: правильное чтение ввода
        $input = [Console]::ReadLine()

        if ($input -match '^\d+$')
        {
            $choice = [int]$input
            if ($choice -ge 1 -and $choice -le $MenuItems.Count)
            {
                # Анимация выбора
                Write-RGB "`n✨ " -FC YellowRGB
                Write-RGB "Выбрано: " -FC White
                Write-RGB $MenuItems[$choice - 1].Text -FC NeonGreenRGB -newline
                Start-Sleep -Milliseconds 750
                return $MenuItems[$choice - 1]
            }
        }

        Write-RGB "❌ Неверный выбор! Попробуйте снова." -FC Red -newline
        Start-Sleep -Seconds 1
        #Clear-Host
    }
}

# ===== РАСШИРЕННЫЕ НАСТРОЙКИ PSREADLINE =====
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -ShowToolTips
Set-PSReadLineOption -BellStyle Visual
Set-PSReadLineOption -EditMode Windows

# Горячие клавиши
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Ctrl+z -Function Undo
Set-PSReadLineKeyHandler -Key Ctrl+y -Function Redo
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteChar
Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Key Alt+d -Function DeleteWord

# RGB цветовая схема для PSReadLine
Set-PSReadLineOption -Colors @{
    Command = $PSStyle.Foreground.FromRgb(0, 255, 157)
    Parameter = $PSStyle.Foreground.FromRgb(255, 101, 69)
    Operator = $PSStyle.Foreground.FromRgb(255, 215, 0)
    Variable = $PSStyle.Foreground.FromRgb(139, 43, 255)
    String = $PSStyle.Foreground.FromRgb(15, 188, 249)
    Number = $PSStyle.Foreground.FromRgb(240, 31, 255)
    Member = $PSStyle.Foreground.FromRgb(0, 191, 255)
    Type = $PSStyle.Foreground.FromRgb(255, 255, 255)
    Emphasis = $PSStyle.Foreground.FromRgb(255, 145, 0)
    Error = $PSStyle.Foreground.FromRgb(255, 0, 0)
    Selection = $PSStyle.Background.FromRgb(64, 64, 64)
    InlinePrediction = $PSStyle.Foreground.FromRgb(102, 102, 102)
    ListPrediction = $PSStyle.Foreground.FromRgb(185, 185, 185)
    ContinuationPrompt = $PSStyle.Foreground.FromRgb(100, 255, 0)
}

# ===== ФУНКЦИИ УВЕДОМЛЕНИЙ =====
function Show-Notification
{
    param(
        [string]$Title,
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Type = "Info"
    )

    $icon = switch ($Type)
    {
        "Success" {
            "✅"
        }
        "Warning" {
            "⚠️"
        }
        "Error" {
            "❌"
        }
        default {
            "ℹ️"
        }
    }

    $color = switch ($Type)
    {
        "Success" {
            "LimeRGB"
        }
        "Warning" {
            "OrangeRGB"
        }
        "Error" {
            "NeonRedRGB"
        }
        default {
            "CyanRGB"
        }
    }

    Write-RGB "`n$icon $Title`: $Message" -FC $color -newline

    # Wezterm notification если доступен
    if (Get-Command wezterm -ErrorAction SilentlyContinue)
    {
        wezterm cli send-text "--[\x1b]9;${Title}:${Message}\x1b\\"
    }
}

# ===== АНИМИРОВАННАЯ ЗАГРУЗКА =====
function Show-RGBLoader
{
    param(
        [string]$Text = "Loading",
        [int]$Duration = 3
    )

    $frames = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
    $colors = @('NeonBlueRGB', 'NeonGreenRGB', 'NeonPinkRGB', 'CyanRGB', 'MagentaRGB')

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

# ===== ПРОГРЕСС БАР С RGB =====
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

# ===== CHOCOLATEY =====
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile))
{
    Write-RGB "🍫 Chocolatey Profile Loaded" -FC CocoaBeanRGB -newline
    Import-Module "$ChocolateyProfile"
}

# ===== УЛУЧШЕННЫЙ LS С RGB И ИКОНКАМИ =====
function lss
{
    param([string]$Path = ".")

    Write-RGB "`n📁 " -FC CyanRGB
    Write-RGB "Directory: " -FC CyanRGB
    Write-RGB (Resolve-Path $Path).Path -FC YellowRGB -newline

    # Градиентная линия
    $lineLength = 60
    for ($i = 0; $i -lt $lineLength; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems $lineLength -StartColor "#8B00FF" -EndColor "#00BFFF"
        Write-RGB "─" -FC $color
    }
    Write-RGB "" -newline

    $items = Get-ChildItem $Path | Sort-Object PSIsContainer -Descending

    foreach ($item in $items)
    {
        if ($item.PSIsContainer)
        {
            Write-RGB "📂 " -FC Ocean1RGB
            Write-RGB ("{0,-35}" -f $item.Name) -FC Ocean1RGB
            Write-RGB " <DIR>" -FC Ocean2RGB -newline
        }
        else
        {
            $icon = switch -Wildcard ( $item.Extension.ToLower())
            {
                ".ps1" {
                    "📜"
                }
                ".exe" {
                    "⚙️"
                }
                ".dll" {
                    "🔧"
                }
                ".txt" {
                    "📄"
                }
                ".md" {
                    "📝"
                }
                ".json" {
                    "🔮"
                }
                ".xml" {
                    "📋"
                }
                ".zip" {
                    "📦"
                }
                ".rar" {
                    "📦"
                }
                ".7z" {
                    "📦"
                }
                ".pdf" {
                    "📕"
                }
                ".jpg" {
                    "🖼️"
                }
                ".png" {
                    "🖼️"
                }
                ".gif" {
                    "🎞️"
                }
                ".mp4" {
                    "🎬"
                }
                ".mp3" {
                    "🎵"
                }
                ".js" {
                    "🟨"
                }
                ".jsx" {
                    "⚛️"
                }
                ".ts" {
                    "🔷"
                }
                ".tsx" {
                    "⚛️"
                }
                ".rs" {
                    "🦀"
                }
                ".py" {
                    "🐍"
                }
                ".cpp" {
                    "🔵"
                }
                ".cs" {
                    "🟣"
                }
                ".html" {
                    "🌐"
                }
                ".css" {
                    "🎨"
                }
                ".scss" {
                    "🎨"
                }
                ".vue" {
                    "💚"
                }
                ".svelte" {
                    "🧡"
                }
                default {
                    "📄"
                }
            }

            $sizeColor = if ($item.Length -gt 1MB)
            {
                "NeonRedRGB"
            }
            elseif ($item.Length -gt 100KB)
            {
                "OrangeRGB"
            }
            else
            {
                "LimeRGB"
            }

            Write-RGB "$icon " -FC White
            Write-RGB ("{0,-35}" -f $item.Name) -FC NeonGreenRGB
            Write-RGB (" {0,10:N2} KB" -f ($item.Length / 1KB)) -FC $sizeColor
            Write-RGB ("  {0}" -f $item.LastWriteTime.ToString("yyyy-MM-dd HH:mm")) -FC TealRGB -newline
        }
    }

    # Градиентная линия
    for ($i = 0; $i -lt $lineLength; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems $lineLength -StartColor "#00BFFF" -EndColor "#8B00FF"
        Write-RGB "─" -FC $color
    }
    Write-RGB "" -newline

    $count = $items.Count
    $dirs = ($items | Where-Object PSIsContainer).Count
    $files = $count - $dirs

    Write-RGB "📊 Total: " -FC GoldRGB
    Write-RGB "$count items " -FC White
    Write-RGB "(📂 $dirs dirs, 📄 $files files)" -FC CyanRGB -newline
}


# ===== ГЛАВНОЕ МЕНЮ С RGB =====
function Show-MainMenu
{
    #Clear-Host

    # Анимированный заголовок с градиентом
    $title = "🔵🔵 POWERSHELL ULTRA MENU 🟡🟡"
    $padding = " " * ((60 - $title.Length) / 2)

    Write-Host $padding -NoNewline
    for ($i = 0; $i -lt $title.Length; $i++) {
        if ($title[$i] -ne ' ')
        {
            $color = Get-GradientColor -Index $i -TotalItems $title.Length -StartColor "#FF0080" -EndColor "#00FFFF"
            Write-RGB $title[$i] -FC $color
        }
        else
        {
            Write-Host " " -NoNewline
        }
    }
    Write-RGB "" -newline

    # Градиентная линия
    for ($i = 0; $i -lt 60; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems 60 -StartColor "#FFD700" -EndColor "#0057B7"
        Write-RGB "═" -FC $color
    }
    Write-RGB "" -newline

    $menuItems = @(
        @{ Text = "🛠️  Инструменты разработчика"; Data = "dev-tools" },
        @{ Text = "🚀 Запуск приложений"; Data = "run-application" },
        @{ Text = "⚙️  Настройка PowerShell"; Data = "powershell-config" },
        @{ Text = "🧹 Обслуживание системы"; Data = "system-cleanup" },
        @{ Text = "💻 Информация о системе"; Data = "system-info" },
        @{ Text = "🌐 Сетевые утилиты"; Data = "network-utils" },
        @{ Text = "🎨 RGB Demo"; Data = "rgb-demo" },
        @{ Text = "🚪 Выход"; Data = "exit" }
    )

    $gradientOptions = @{
        StartColor = "#01BB01"
        EndColor = "#FF7755"
        GradientType = "Linear"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "" -Prompt "Выберите действие" -GradientOptions $gradientOptions

    switch ($selected.Data)
    {
        "dev-tools" {
            Show-DevToolsMenu
        }
        "run-application" {
            Run-Application
        }
        "powershell-config" {
            Show-PowerShellConfigMenu
        }
        "system-cleanup" {
            Show-CleanupMenu
        }
        "system-info" {
            Show-SystemInfo
            Write-RGB "`nНажмите любую клавишу..." -FC CyanRGB -newline
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Show-MainMenu
        }
        "network-utils" {
            Show-NetworkMenu
        }
        "rgb-demo" {
            Show-RGBDemo
        }
        "exit" {
            # Анимация выхода
            Write-RGB "`n👋 " -FC White
            $goodbye = "До свидания!"
            for ($i = 0; $i -lt $goodbye.Length; $i++) {
                $color = Get-GradientColor -Index $i -TotalItems $goodbye.Length -StartColor "#FFD700" -EndColor "#FF1493"
                Write-RGB $goodbye[$i] -FC $color
                Start-Sleep -Milliseconds 100
            }
            Write-RGB "" -newline
            return
        }
    }
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
    $neonColors = @("NeonBlueRGB", "NeonGreenRGB", "NeonPinkRGB", "NeonRedRGB", "CyanRGB", "MagentaRGB", "YellowRGB", "OrangeRGB")
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

# ===== БЫСТРЫЕ ФУНКЦИИ ДЛЯ ПРОЕКТОВ =====


# ===== АЛИАС ДЛЯ БЫСТРОГО ДОСТУПА К МЕНЮ =====
Set-Alias -Name menu -Value Show-MainMenu
Set-Alias -Name mm -Value Show-MainMenu

# ===== ИНТЕГРАЦИЯ С SECURITYWATCHER =====
if (Get-Module -ListAvailable -Name SecurityWatcher)
{
    Import-Module SecurityWatcher -ErrorAction SilentlyContinue
    Write-RGB "🛡️  SecurityWatcher loaded" -FC LimeRGB -newline
}

# ===== ПОКАЗАТЬ ПРИВЕТСТВИЕ =====
Show-Welcome