# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    🎨 POWERSHELL PROFILE v4.0 ULTRA RGB                   ║
# ║                         Ukraine Edition 🇺🇦                                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

$newModulePath = "C:\Users\ketov\Documents\PowerShell\Modules"
$env:PSModulePath = $newModulePath
[Environment]::SetEnvironmentVariable("PSModulePath", $newModulePath, "User")
$env:POSH_IGNORE_ALLUSER_PROFILES = $true

# ===== ИМПОРТ GRADIENT ФУНКЦИЙ =====
# Загружаем градиентные функции
$gradientPath = "C:\scripts\GradientTable.Ps1"
if (Test-Path $gradientPath) {
    . $gradientPath
}

# ===== МОДУЛИ =====
$modules = @(
    'Aliases',
    'Terminal-Icons',
    'PSReadLine',
    'PSFzf',
    'PoshColor',
    'syntax-highlighting'
)

foreach ($module in $modules) {
    if (Get-Module -ListAvailable -Name $module) {
        Import-Module -Name $module -ErrorAction SilentlyContinue
    } else {
        Write-RGB "[!] Модуль $module отсутствует. Установите: Install-Module $module" -FC Yellow
    }
}

# ===== OH-MY-POSH =====
$ompConfig = 'C:\scripts\OhMyPosh\free-ukraine.omp.json'
if (Test-Path $ompConfig) {
    oh-my-posh init pwsh --config $ompConfig | Invoke-Expression
}

# ===== RGB ЦВЕТОВАЯ ПАЛИТРА =====
$global:RGB = @{
# Основные цвета
    WhiteRGB         = @{ R = 255; G = 255; B = 255 }
    CyanRGB          = @{ R = 0; G = 150; B = 255 }
    MagentaRGB       = @{ R = 255; G = 0; B = 255 }
    YellowRGB        = @{ R = 255; G = 255; B = 0 }
    OrangeRGB        = @{ R = 255; G = 165; B = 0 }
    PinkRGB          = @{ R = 255; G = 20; B = 147 }
    PurpleRGB        = @{ R = 138; G = 43; B = 226 }
    LimeRGB          = @{ R = 50; G = 205; B = 50 }
    TealRGB          = @{ R = 0; G = 128; B = 128 }
    GoldRGB          = @{ R = 255; G = 215; B = 0 }
    CocoaBeanRGB     = @{ R = 79; G = 56; B = 53 }

    # Неоновые цвета
    NeonBlueRGB      = @{ R = 77; G = 200; B = 255 }
    NeonGreenRGB     = @{ R = 57; G = 255; B = 20 }
    NeonPinkRGB      = @{ R = 255; G = 20; B = 240 }
    NeonRedRGB       = @{ R = 255; G = 55; B = 100 }

    # Градиентные цвета
    Sunset1RGB       = @{ R = 255; G = 94; B = 77 }
    Sunset2RGB       = @{ R = 255; G = 154; B = 0 }
    Ocean1RGB        = @{ R = 0; G = 119; B = 190 }
    Ocean2RGB        = @{ R = 0; G = 180; B = 216 }
    Ocean3RGB        = @{ R = 0; G = 150; B = 160 }
    Ocean4RGB        = @{ R = 0; G = 205; B = 230 }

    # Украинские цвета 🇺🇦
    UkraineBlueRGB   = @{ R = 0; G = 87; B = 183 }
    UkraineYellowRGB = @{ R = 255; G = 213; B = 0 }
}

# Функция для создания RGB цвета
function Get-RGBColor {
    param($Color)
    return $PSStyle.Foreground.FromRgb($Color.R, $Color.G, $Color.B)
}

function Write-RGB {
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

    if ($FC -in $systemColors) {
        Write-Host $fullText -ForegroundColor $FC -NoNewline:(-not $newline)
    }
    elseif ($global:RGB.ContainsKey($FC)) {
        $rgbColor = Get-RGBColor $global:RGB[$FC]
        Write-Host "${rgbColor}${fullText}${PSStyle.Reset}" -NoNewline:(-not $newline)
    }
    elseif ($FC -match '^#[0-9A-Fa-f]{6}$') {
        $r = [Convert]::ToInt32($FC.Substring(1, 2), 16)
        $g = [Convert]::ToInt32($FC.Substring(3, 2), 16)
        $b = [Convert]::ToInt32($FC.Substring(5, 2), 16)
        $rgbColor = $PSStyle.Foreground.FromRgb($r, $g, $b)
        Write-Host "${rgbColor}${fullText}${PSStyle.Reset}" -NoNewline:(-not $newline)
    }
    else {
        Write-Host $fullText -ForegroundColor White -NoNewline:(-not $newline)
    }
}

# ===== УЛУЧШЕННАЯ ФУНКЦИЯ МЕНЮ С ГРАДИЕНТАМИ =====
function Show-Menu {
    param(
        [Parameter(Mandatory = $true)]
        [array]$MenuItems,
        [string]$MenuTitle = "Menu",
        [string]$Prompt = "Select option",
        [hashtable]$GradientOptions = @{
        StartColor = "#01BB01"
        EndColor = "#FF9955"
        GradientType = "Linear"
    },
        [switch]$UseAnimation
    )

    while ($true) {
        if ($MenuTitle) {
            Write-RGB "`n$MenuTitle" -FC GoldRGB -newline
            Write-RGB ("─" * 60) -FC PurpleRGB -newline
        }

        # Анимация появления меню
        if ($UseAnimation) {
            for ($i = 0; $i -lt $MenuItems.Count; $i++) {
                $num = $i + 1
                $hexColor = Get-GradientColor -Index $i -TotalItems $MenuItems.Count @GradientOptions

                Write-RGB "[" -FC NeonGreenRGB
                Write-RGB $num -FC Ocean2RGB
                Write-RGB "] " -FC NeonGreenRGB
                Write-RGB $MenuItems[$i].Text -FC $hexColor -newline

                Start-Sleep -Milliseconds 50
            }
        } else {
            for ($i = 0; $i -lt $MenuItems.Count; $i++) {
                $num = $i + 1
                $hexColor = Get-GradientColor -Index $i -TotalItems $MenuItems.Count @GradientOptions

                Write-RGB "[" -FC NeonGreenRGB
                Write-RGB $num -FC Ocean2RGB
                Write-RGB "] " -FC NeonGreenRGB
                Write-RGB $MenuItems[$i].Text -FC $hexColor -newline
            }
        }

        Write-RGB "`n" -newline
        Write-RGB "➤ " -FC NeonGreenRGB
        Write-RGB "$Prompt (1-$($MenuItems.Count)): " -FC White

        # ИСПРАВЛЕНИЕ: правильное чтение ввода
        $input = [Console]::ReadLine()

        if ($input -match '^\d+$') {
            $choice = [int]$input
            if ($choice -ge 1 -and $choice -le $MenuItems.Count) {
                # Анимация выбора
                Write-RGB "`n✨ " -FC YellowRGB
                Write-RGB "Выбрано: " -FC White
                Write-RGB $MenuItems[$choice - 1].Text -FC NeonGreenRGB -newline
                Start-Sleep -Milliseconds 300
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
    Command            = $PSStyle.Foreground.FromRgb(0, 255, 157)
    Parameter          = $PSStyle.Foreground.FromRgb(255, 101, 69)
    Operator           = $PSStyle.Foreground.FromRgb(255, 215, 0)
    Variable           = $PSStyle.Foreground.FromRgb(139, 43, 255)
    String             = $PSStyle.Foreground.FromRgb(15, 188, 249)
    Number             = $PSStyle.Foreground.FromRgb(240, 31, 255)
    Member             = $PSStyle.Foreground.FromRgb(0, 191, 255)
    Type               = $PSStyle.Foreground.FromRgb(255, 255, 255)
    Emphasis           = $PSStyle.Foreground.FromRgb(255, 145, 0)
    Error              = $PSStyle.Foreground.FromRgb(255, 0, 0)
    Selection          = $PSStyle.Background.FromRgb(64, 64, 64)
    InlinePrediction   = $PSStyle.Foreground.FromRgb(102, 102, 102)
    ListPrediction     = $PSStyle.Foreground.FromRgb(185, 185, 185)
    ContinuationPrompt = $PSStyle.Foreground.FromRgb(255, 255, 0)
}

# ===== ФУНКЦИИ УВЕДОМЛЕНИЙ =====
function Show-Notification {
    param(
        [string]$Title,
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Type = "Info"
    )

    $icon = switch ($Type) {
        "Success" { "✅" }
        "Warning" { "⚠️" }
        "Error" { "❌" }
        default { "ℹ️" }
    }

    $color = switch ($Type) {
        "Success" { "LimeRGB" }
        "Warning" { "OrangeRGB" }
        "Error" { "NeonRedRGB" }
        default { "CyanRGB" }
    }

    Write-RGB "`n$icon $Title`: $Message" -FC $color -newline

    # Wezterm notification если доступен
    if (Get-Command wezterm -ErrorAction SilentlyContinue) {
        wezterm cli send-text "--[\x1b]9;${Title}:${Message}\x1b\\"
    }
}

# ===== АНИМИРОВАННАЯ ЗАГРУЗКА =====
function Show-RGBLoader {
    param(
        [string]$Text = "Loading",
        [int]$Duration = 3
    )

    $frames = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
    $colors = @('NeonBlueRGB', 'NeonGreenRGB', 'NeonPinkRGB', 'CyanRGB', 'MagentaRGB')

    $endTime = (Get-Date).AddSeconds($Duration)
    $i = 0

    while ((Get-Date) -lt $endTime) {
        $frame = $frames[$i % $frames.Length]
        $color = $colors[$i % $colors.Length]

        Write-RGB "`r$frame $Text..." -FC $color
        Start-Sleep -Milliseconds 100
        $i++
    }
    Write-RGB "`r✨ Done!    " -FC LimeRGB -newline
}

# ===== ПРОГРЕСС БАР С RGB =====
function Show-RGBProgress {
    param(
        [string]$Activity = "Processing",
        [int]$TotalSteps = 100,
        [switch]$Gradient
    )

    for ($i = 0; $i -le $TotalSteps; $i++) {
        $percent = [int](($i / $TotalSteps) * 100)
        $filled = [int](($i / $TotalSteps) * 30)
        $empty = 30 - $filled

        if ($Gradient) {
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
        } else {
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
if (Test-Path($ChocolateyProfile)) {
    Write-RGB "🍫 Chocolatey Profile Loaded" -FC CocoaBeanRGB -newline
    Import-Module "$ChocolateyProfile"
}

# ===== УЛУЧШЕННЫЙ LS С RGB И ИКОНКАМИ =====
function ls {
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

    foreach ($item in $items) {
        if ($item.PSIsContainer) {
            Write-RGB "📂 " -FC Ocean1RGB
            Write-RGB ("{0,-35}" -f $item.Name) -FC Ocean1RGB
            Write-RGB " <DIR>" -FC Ocean2RGB -newline
        } else {
            $icon = switch -Wildcard ($item.Extension.ToLower()) {
                ".ps1" { "📜" }
                ".exe" { "⚙️" }
                ".dll" { "🔧" }
                ".txt" { "📄" }
                ".md" { "📝" }
                ".json" { "🔮" }
                ".xml" { "📋" }
                ".zip" { "📦" }
                ".rar" { "📦" }
                ".7z" { "📦" }
                ".pdf" { "📕" }
                ".jpg" { "🖼️" }
                ".png" { "🖼️" }
                ".gif" { "🎞️" }
                ".mp4" { "🎬" }
                ".mp3" { "🎵" }
                ".js" { "🟨" }
                ".jsx" { "⚛️" }
                ".ts" { "🔷" }
                ".tsx" { "⚛️" }
                ".rs" { "🦀" }
                ".py" { "🐍" }
                ".cpp" { "🔵" }
                ".cs" { "🟣" }
                ".html" { "🌐" }
                ".css" { "🎨" }
                ".scss" { "🎨" }
                ".vue" { "💚" }
                ".svelte" { "🧡" }
                default { "📄" }
            }

            $sizeColor = if ($item.Length -gt 1MB) { "NeonRedRGB" }
            elseif ($item.Length -gt 100KB) { "OrangeRGB" }
            else { "LimeRGB" }

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

# ===== АЛИАСЫ =====
Set-Alias -Name g -Value git
Set-Alias -Name touch -Value New-Item
Set-Alias -Name ll -Value ls
Set-Alias -Name cls -Value #Clear-Host
Set-Alias -Name which -Value Get-Command

# Быстрая навигация
function cd.. { Set-Location .. }
function cd... { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }
function ~ { Set-Location $HOME }
function desktop { Set-Location "$HOME\Desktop" }
function downloads { Set-Location "$HOME\Downloads" }
function docs { Set-Location "$HOME\Documents" }

# ===== СИСТЕМНАЯ ИНФОРМАЦИЯ С RGB =====
function Show-SystemInfo {
    Write-RGB "`n💻 SYSTEM INFORMATION" -FC NeonPinkRGB -newline

    # Градиентная линия
    for ($i = 0; $i -lt 50; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems 50 -StartColor "#FF1493" -EndColor "#00CED1"
        Write-RGB "═" -FC $color
    }
    Write-RGB "" -newline

    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $mem = Get-CimInstance Win32_PhysicalMemory
    $gpu = Get-CimInstance Win32_VideoController

    # OS Info
    Write-RGB "🖥️  OS: " -FC CyanRGB
    Write-RGB $os.Caption -FC White -newline

    # CPU Info
    Write-RGB "🔧 CPU: " -FC YellowRGB
    Write-RGB "$($cpu.Name) ($($cpu.NumberOfCores) cores)" -FC White -newline

    # Memory
    $totalMem = ($mem | Measure-Object -Property Capacity -Sum).Sum / 1GB
    Write-RGB "💾 RAM: " -FC LimeRGB
    Write-RGB "$([Math]::Round($totalMem, 2)) GB" -FC White -newline

    # GPU
    Write-RGB "🎮 GPU: " -FC OrangeRGB
    Write-RGB $gpu.Name -FC White -newline

    # Uptime
    $uptime = (Get-Date) - $os.LastBootUpTime
    Write-RGB "⏱️  Uptime: " -FC MagentaRGB
    Write-RGB "$($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" -FC White -newline

    # Градиентная линия
    for ($i = 0; $i -lt 50; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems 50 -StartColor "#00CED1" -EndColor "#FF1493"
        Write-RGB "═" -FC $color
    }
    Write-RGB "" -newline
}

# ===== СЕТЕВЫЕ УТИЛИТЫ =====
function Show-NetworkInfo {
    Write-RGB "`n🌐 NETWORK INFORMATION" -FC Ocean1RGB -newline
    Write-RGB ("═" * 50) -FC Ocean2RGB -newline

    # IP адреса
    $ips = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" }

    foreach ($ip in $ips) {
        Write-RGB "🔌 Interface: " -FC CyanRGB
        Write-RGB $ip.InterfaceAlias -FC White -newline
        Write-RGB "   IP: " -FC YellowRGB
        Write-RGB $ip.IPAddress -FC LimeRGB -newline
    }

    # Внешний IP
    try {
        Write-RGB "`n🌍 External IP: " -FC NeonGreenRGB
        $extIP = (Invoke-RestMethod -Uri "https://api.ipify.org?format=json" -TimeoutSec 5).ip
        Write-RGB $extIP -FC GoldRGB -newline
    } catch {
        Write-RGB "Unable to fetch" -FC Red -newline
    }

    Write-RGB ("═" * 50) -FC Ocean2RGB -newline
}

# ===== БЫСТРЫЙ PING С ВИЗУАЛИЗАЦИЕЙ =====
function Test-ConnectionVisual {
    param(
        [string]$ComputerName = "google.com",
        [int]$Count = 4
    )

    Write-RGB "`n🏓 PING $ComputerName" -FC NeonBlueRGB -newline
    Write-RGB ("─" * 40) -FC PurpleRGB -newline

    for ($i = 1; $i -le $Count; $i++) {
        try {
            $result = Test-Connection -ComputerName $ComputerName -Count 1 -ErrorAction Stop
            $time = $result.ResponseTime

            $color = if ($time -lt 50) { "LimeRGB" }
            elseif ($time -lt 100) { "YellowRGB" }
            else { "NeonRedRGB" }

            $bar = "█" * [Math]::Min([int]($time / 10), 20)

            Write-RGB "[$i] " -FC White
            Write-RGB $bar -FC $color
            Write-RGB " ${time}ms" -FC $color -newline
        } catch {
            Write-RGB "[$i] ❌ Timeout" -FC Red -newline
        }

        Start-Sleep -Milliseconds 500
    }

    Write-RGB ("─" * 40) -FC PurpleRGB -newline
}

# ===== WEATHER WIDGET =====
function Get-Weather {
    param([string]$City = "Lviv")

    try {
        Write-RGB "`n🌤️  Getting weather..." -FC CyanRGB -newline
        $weather = Invoke-RestMethod -Uri "https://wttr.in/${City}?format=j1" -TimeoutSec 5
        $current = $weather.current_condition[0]

        Write-RGB "`r🌤️  Weather in $City  " -FC CyanRGB -newline
        Write-RGB "   🌡️  Temp: $($current.temp_C)°C" -FC YellowRGB -newline
        Write-RGB "   💨 Wind: $($current.windspeedKmph) km/h" -FC LimeRGB -newline
        Write-RGB "   💧 Humidity: $($current.humidity)%" -FC Ocean1RGB -newline
    } catch {
        Write-RGB "⚠️  Unable to fetch weather" -FC Yellow -newline
    }
}

# ===== УЛУЧШЕННАЯ ФУНКЦИЯ ПРИВЕТСТВИЯ =====
function Show-Welcome {
    #Clear-Host

    # Анимированный заголовок
    $title = "POWERSHELL PROFILE v4.0"
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

    # CPU и RAM с анимацией
    Write-RGB "📊 " -FC White
    Write-RGB "CPU: " -FC CyanRGB
    $cpuUsage = [math]::Round((Get-Counter "\Processor(_Total)\% Processor Time" -ErrorAction SilentlyContinue).CounterSamples.CookedValue, 1)
    Write-RGB "$cpuUsage%" -FC NeonGreenRGB
    Write-RGB " | " -FC White
    Write-RGB "RAM: " -FC MagentaRGB
    $availableRam = [math]::Round((Get-Counter "\Memory\Available MBytes" -ErrorAction SilentlyContinue).CounterSamples.CookedValue / 1024, 1)
    Write-RGB "$availableRam GB free" -FC NeonPinkRGB -newline

    # Подсказка с градиентом
    Write-RGB "`n💡 " -FC White
    Write-RGB "Type " -FC Gray
    Write-RGB "Show-MainMenu" -FC NeonPinkRGB
    Write-RGB " or " -FC Gray
    Write-RGB "menu" -FC LimeRGB
    Write-RGB " to open the main menu" -FC Gray -newline

    Write-RGB "═════════════════════════════════════════════════════" -FC UkraineYellowRGB -newline
}

# ===== ИСПРАВЛЕННАЯ ФУНКЦИЯ ЗАПУСКА ПРИЛОЖЕНИЙ =====
function Run-Application {
    $menuItems = @(
        @{ Text = "💻 WebStorm 2025.2 EAP"; Data = @{ Path = "C:\Users\ketov\AppData\Local\Programs\WebStorm\bin\webstorm64.exe" } },
        @{ Text = "📝 Zed"; Data = @{ Path = "zed" } },
        @{ Text = "🖥️  Wezterm"; Data = @{ Path = "C:\Program Files\WezTerm\wezterm-gui.exe" } },
        @{ Text = "🪟 Windows Terminal Preview"; Data = @{ Path = "wt" } },
        @{ Text = "💬 Telegram"; Data = @{ Path = "telegram" } },
        @{ Text = "📘 VS Code"; Data = @{ Path = "code" } },
        @{ Text = "📗 VS Code Insiders"; Data = @{ Path = "code-insiders" } },
        @{ Text = "🦀 RustRover"; Data = @{ Path = "rustrover" } },
        @{ Text = "🌐 Запустить браузер"; Data = @{ Action = "browser" } },
        @{ Text = "🔙 Назад"; Data = @{ Action = "back" } }
    )

    $gradientOptions = @{
        StartColor = "#00FF00"
        EndColor = "#FF00FF"
        GradientType = "Sine"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "🚀 ЗАПУСК ПРИЛОЖЕНИЙ" -Prompt "Выберите приложение" -GradientOptions $gradientOptions

    if ($selected.Data.Action -eq "browser") {
        Run-Browser
    } elseif ($selected.Data.Action -eq "back") {
        Show-MainMenu
    } else {
        try {
            Write-RGB "`n🚀 Запускаю " -FC White
            Write-RGB $selected.Text -FC NeonGreenRGB -newline
            Start-Process $selected.Data.Path -ErrorAction Stop
            Show-Notification -Title "Приложение запущено" -Message $selected.Text -Type "Success"
        } catch {
            Show-Notification -Title "Ошибка" -Message "Не удалось запустить приложение" -Type "Error"
        }
    }
}

# ===== МЕНЮ БРАУЗЕРОВ С RGB =====
function Run-Browser {
    $browsers = @(
        @{ Text = "🦊 Firefox Nightly"; Data = "firefox"; Args = "-P nightly" },
        @{ Text = "🦊 Firefox Developer"; Data = "firefox"; Args = "-P dev-edition-default" },
        @{ Text = "🦊 Firefox"; Data = "firefox" },
        @{ Text = "🔶 Chrome Canary"; Data = "chrome"; Args = "--chrome-canary" },
        @{ Text = "🔷 Chrome Dev"; Data = "chrome"; Args = "--chrome-dev" },
        @{ Text = "🔵 Chrome"; Data = "chrome" },
        @{ Text = "🟦 Edge Canary"; Data = "msedge-canary" },
        @{ Text = "🟦 Edge Dev"; Data = "msedge-dev" },
        @{ Text = "🟦 Edge"; Data = "msedge" },
        @{ Text = "🎭 Opera"; Data = "opera" },
        @{ Text = "🎨 Vivaldi"; Data = "vivaldi" },
        @{ Text = "🧅 Tor"; Data = "tor" },
        @{ Text = "🔷 Chromium"; Data = "chromium" },
        @{ Text = "🦁 Brave"; Data = "brave" },
        @{ Text = "🌊 Floorp"; Data = "floorp" },
        @{ Text = "💧 Waterfox"; Data = "waterfox" },
        @{ Text = "⚡ Thorium"; Data = "thorium" },
        @{ Text = "🐺 LibreWolf"; Data = "librewolf" },
        @{ Text = "🟡 Yandex"; Data = "yandex" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $gradientOptions = @{
        StartColor = "#FF6B6B"
        EndColor = "#4ECDC4"
        GradientType = "Exponential"
    }

    $selected = Show-Menu -MenuItems $browsers -MenuTitle "🌐 ВЫБОР БРАУЗЕРА" -Prompt "Выберите браузер" -GradientOptions $gradientOptions

    if ($selected.Data -eq "back") {
        Run-Application
    } else {
        try {
            Write-RGB "`n🌐 Запускаю " -FC White
            Write-RGB $selected.Text -FC Ocean1RGB -newline

            if ($selected.Args) {
                Start-Process $selected.Data -ArgumentList $selected.Args -ErrorAction Stop
            } else {
                Start-Process $selected.Data -ErrorAction Stop
            }

            Show-Notification -Title "Браузер запущен" -Message $selected.Text -Type "Success"
        } catch {
            Show-Notification -Title "Ошибка" -Message "Браузер не найден" -Type "Error"
        }
    }
}

# ===== УЛУЧШЕННОЕ МЕНЮ РАЗРАБОТЧИКА =====
function Show-DevToolsMenu {
    $menuItems = @(
        @{ Text = "🦀 Rust: обновить до nightly"; Data = "rust-update" },
        @{ Text = "📦 Cargo: обновить пакеты"; Data = "cargo-update" },
        @{ Text = "⚡ Bun: обновить пакеты"; Data = "bun-update" },
        @{ Text = "🚀 Bun: dev server"; Data = "bun-dev" },
        @{ Text = "🏗️  Bun: build проект"; Data = "bun-build" },
        @{ Text = "📝 Zed: обновить (scoop)"; Data = "zed-update" },
        @{ Text = "📦 Winget: обновить все"; Data = "winget-update" },
        @{ Text = "💾 Базы данных"; Data = "db-ops" },
        @{ Text = "🔍 Поиск портов"; Data = "port-scan" },
        @{ Text = "📊 Системный мониторинг"; Data = "sys-monitor" },
        @{ Text = "🎯 Сетевые инструменты"; Data = "net-tools" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $gradientOptions = @{
        StartColor = "#FF8C00"
        EndColor = "#FF1493"
        GradientType = "Linear"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "🛠️  ИНСТРУМЕНТЫ РАЗРАБОТЧИКА" -Prompt "Выберите действие" -GradientOptions $gradientOptions -UseAnimation

    switch ($selected.Data) {
        "rust-update" {
            Write-RGB "`n🦀 Обновление Rust..." -FC OrangeRGB -newline
            Show-RGBLoader -Text "Updating Rust to nightly" -Duration 2
            rustup update nightly
            Write-RGB "✅ Rust обновлен!" -FC LimeRGB -newline
            Pause
            Show-DevToolsMenu
        }
        "cargo-update" {
            Write-RGB "`n📦 Обновление Cargo пакетов..." -FC NeonBlueRGB -newline
            cargo update -v
            Write-RGB "✅ Пакеты обновлены!" -FC LimeRGB -newline
            Pause
            Show-DevToolsMenu
        }
        "bun-update" {
            Write-RGB "`n⚡ Обновление Bun пакетов..." -FC YellowRGB -newline
            bun update
            Write-RGB "✅ Bun пакеты обновлены!" -FC LimeRGB -newline
            Pause
            Show-DevToolsMenu
        }
        "bun-dev" {
            $projectDir = Read-Host "`nВведите путь к проекту (Enter для текущей)"
            if (-not $projectDir) { $projectDir = Get-Location }
            Set-Location $projectDir
            Write-RGB "🚀 Запуск Bun dev server..." -FC LimeRGB -newline
            bun run dev
        }
        "bun-build" {
            $projectDir = Read-Host "`nВведите путь к проекту (Enter для текущей)"
            if (-not $projectDir) { $projectDir = Get-Location }
            Set-Location $projectDir
            Write-RGB "🏗️  Сборка проекта..." -FC CyanRGB -newline
            Show-RGBProgress -Activity "Building project" -TotalSteps 100 -Gradient
            bun run build
            Write-RGB "✅ Сборка завершена!" -FC LimeRGB -newline
            Pause
            Show-DevToolsMenu
        }
        "port-scan" {
            Show-PortScanner
            Pause
            Show-DevToolsMenu
        }
        "sys-monitor" {
            Show-SystemMonitor
            Pause
            Show-DevToolsMenu
        }
        "db-ops" {
            Show-DatabaseMenu
        }
        "net-tools" {
            Show-NetworkToolsMenu
        }
        "zed-update" {
            Write-RGB "`n📝 Обновление Zed через Scoop..." -FC CyanRGB -newline
            scoop update zed
            Write-RGB "✅ Zed обновлен!" -FC LimeRGB -newline
            Pause
            Show-DevToolsMenu
        }
        "winget-update" {
            Write-RGB "`n📦 Обновление всех пакетов Winget..." -FC MagentaRGB -newline
            winget upgrade --all
            Write-RGB "✅ Все пакеты обновлены!" -FC LimeRGB -newline
            Pause
            Show-DevToolsMenu
        }
        "back" {
            Show-MainMenu
        }
    }
}

# ===== НОВОЕ МЕНЮ СЕТЕВЫХ ИНСТРУМЕНТОВ =====
function Show-NetworkToolsMenu {
    $menuItems = @(
        @{ Text = "🌐 Анализ HTTP заголовков"; Data = "http-headers" },
        @{ Text = "🔓 Проверка SSL сертификата"; Data = "ssl-check" },
        @{ Text = "📡 DNS lookup"; Data = "dns-lookup" },
        @{ Text = "🔍 Traceroute"; Data = "traceroute" },
        @{ Text = "📊 Netstat анализ"; Data = "netstat" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $gradientOptions = @{
        StartColor = "#1E90FF"
        EndColor = "#00CED1"
        GradientType = "Linear"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "🎯 СЕТЕВЫЕ ИНСТРУМЕНТЫ" -Prompt "Выберите инструмент" -GradientOptions $gradientOptions

    switch ($selected.Data) {
        "http-headers" {
            $url = Read-Host "`nВведите URL"
            try {
                $response = Invoke-WebRequest -Uri $url -Method Head
                Write-RGB "`n📋 HTTP Headers для $url`:" -FC CyanRGB -newline
                $response.Headers | Format-Table -AutoSize
            } catch {
                Write-RGB "❌ Ошибка получения заголовков" -FC Red -newline
            }
            Pause
            Show-NetworkToolsMenu
        }
        "ssl-check" {
            $host = Read-Host "`nВведите домен"
            Write-RGB "`n🔓 Проверка SSL для $host`..." -FC YellowRGB -newline
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            try {
                $tcpClient.Connect($host, 443)
                $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream())
                $sslStream.AuthenticateAsClient($host)
                $cert = $sslStream.RemoteCertificate
                Write-RGB "✅ SSL сертификат действителен до: $($cert.GetExpirationDateString())" -FC LimeRGB -newline
            } catch {
                Write-RGB "❌ Ошибка проверки SSL" -FC Red -newline
            } finally {
                $tcpClient.Close()
            }
            Pause
            Show-NetworkToolsMenu
        }
        "dns-lookup" {
            $domain = Read-Host "`nВведите домен"
            Write-RGB "`n📡 DNS lookup для $domain`:" -FC MagentaRGB -newline
            Resolve-DnsName $domain | Format-Table -AutoSize
            Pause
            Show-NetworkToolsMenu
        }
        "traceroute" {
            $target = Read-Host "`nВведите адрес"
            Write-RGB "`n🔍 Traceroute к $target`:" -FC OrangeRGB -newline
            Test-NetConnection -ComputerName $target -TraceRoute
            Pause
            Show-NetworkToolsMenu
        }
        "netstat" {
            Write-RGB "`n📊 Активные соединения:" -FC CyanRGB -newline
            netstat -an | Select-String "ESTABLISHED|LISTENING" | Select-Object -First 20
            Pause
            Show-NetworkToolsMenu
        }
        "back" {
            Show-DevToolsMenu
        }
    }
}

# ===== МЕНЮ БАЗ ДАННЫХ =====
function Show-DatabaseMenu {
    $menuItems = @(
        @{ Text = "🐘 PostgreSQL управление"; Data = "postgres" },
        @{ Text = "🦭 MySQL управление"; Data = "mysql" },
        @{ Text = "🍃 MongoDB управление"; Data = "mongodb" },
        @{ Text = "🔴 Redis управление"; Data = "redis" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $gradientOptions = @{
        StartColor = "#32CD32"
        EndColor = "#00FA9A"
        GradientType = "Linear"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "💾 УПРАВЛЕНИЕ БАЗАМИ ДАННЫХ" -Prompt "Выберите БД" -GradientOptions $gradientOptions

    switch ($selected.Data) {
        "postgres" {
            Write-RGB "`n🐘 PostgreSQL операции:" -FC CyanRGB -newline
            Write-RGB "1. Запустить сервер: pg_ctl start" -FC White -newline
            Write-RGB "2. Остановить сервер: pg_ctl stop" -FC White -newline
            Write-RGB "3. Подключиться: psql -U username -d database" -FC White -newline
            Pause
            Show-DatabaseMenu
        }
        "mysql" {
            Write-RGB "`n🦭 MySQL операции:" -FC YellowRGB -newline
            Write-RGB "1. Запустить: net start mysql" -FC White -newline
            Write-RGB "2. Подключиться: mysql -u root -p" -FC White -newline
            Pause
            Show-DatabaseMenu
        }
        "mongodb" {
            Write-RGB "`n🍃 MongoDB операции:" -FC LimeRGB -newline
            Write-RGB "1. Запустить: mongod" -FC White -newline
            Write-RGB "2. Подключиться: mongosh" -FC White -newline
            Pause
            Show-DatabaseMenu
        }
        "redis" {
            Write-RGB "`n🔴 Redis операции:" -FC Red -newline
            Write-RGB "1. Запустить: redis-server" -FC White -newline
            Write-RGB "2. CLI: redis-cli" -FC White -newline
            Pause
            Show-DatabaseMenu
        }
        "back" {
            Show-DevToolsMenu
        }
    }
}

# ===== СКАНЕР ПОРТОВ =====
function Show-PortScanner {
    Write-RGB "`n🔍 PORT SCANNER" -FC NeonPinkRGB -newline

    # Градиентная линия
    for ($i = 0; $i -lt 50; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems 50 -StartColor "#FF69B4" -EndColor "#FF1493"
        Write-RGB "─" -FC $color
    }
    Write-RGB "" -newline

    $commonPorts = @{
        "3000"  = "Node.js / React"
        "3001"  = "Node.js Alt"
        "5173"  = "Vite"
        "5432"  = "PostgreSQL"
        "3306"  = "MySQL"
        "6379"  = "Redis"
        "27017" = "MongoDB"
        "8080"  = "HTTP Alt"
        "8000"  = "Django/Python"
        "4200"  = "Angular"
        "8081"  = "HTTP Alt 2"
        "5174"  = "Vite Alt"
        "1234"  = "Debug Port"
        "9229"  = "Node Debug"
    }

    $i = 0
    foreach ($port in $commonPorts.Keys | Sort-Object) {
        $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue -InformationLevel Quiet

        $portColor = Get-GradientColor -Index $i -TotalItems $commonPorts.Count -StartColor "#00FF00" -EndColor "#FF0000"

        if ($connection) {
            Write-RGB "✅ Port " -FC White
            Write-RGB $port -FC $portColor
            Write-RGB " - " -FC White
            Write-RGB "OPEN" -FC NeonGreenRGB
            Write-RGB " ($($commonPorts[$port]))" -FC CyanRGB -newline
        } else {
            Write-RGB "❌ Port " -FC White
            Write-RGB $port -FC DarkGray
            Write-RGB " - " -FC White
            Write-RGB "CLOSED" -FC Gray
            Write-RGB " ($($commonPorts[$port]))" -FC DarkGray -newline
        }
        $i++
    }
}

# ===== СИСТЕМНЫЙ МОНИТОР =====
function Show-SystemMonitor {
    Write-RGB "`n📊 SYSTEM MONITOR" -FC GoldRGB -newline

    # Градиентная линия
    for ($i = 0; $i -lt 60; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems 60 -StartColor "#FFD700" -EndColor "#FF4500"
        Write-RGB "═" -FC $color
    }
    Write-RGB "" -newline

    # CPU
    $cpu = Get-CimInstance Win32_Processor
    $cpuLoad = (Get-Counter "\Processor(_Total)\% Processor Time" -ErrorAction SilentlyContinue).CounterSamples.CookedValue
    $cpuColor = if ($cpuLoad -gt 80) { "NeonRedRGB" }
    elseif ($cpuLoad -gt 50) { "OrangeRGB" }
    else { "LimeRGB" }

    Write-RGB "`n🔧 CPU Usage: " -FC CyanRGB

    # Градиентный прогресс бар для CPU
    $cpuBar = ""
    $cpuFilled = [int]($cpuLoad / 5)
    for ($j = 0; $j -lt $cpuFilled; $j++) {
        $barColor = Get-GradientColor -Index $j -TotalItems 20 -StartColor "#00FF00" -EndColor "#FF0000"
        Write-RGB "█" -FC $barColor
    }
    Write-Host ("░" * (20 - $cpuFilled)) -NoNewline
    Write-RGB " $([Math]::Round($cpuLoad, 1))%" -FC $cpuColor -newline

    # Memory
    $os = Get-CimInstance Win32_OperatingSystem
    $totalMem = $os.TotalVisibleMemorySize / 1MB
    $freeMem = $os.FreePhysicalMemory / 1MB
    $usedMem = $totalMem - $freeMem
    $memPercent = [int](($usedMem / $totalMem) * 100)

    Write-RGB "💾 Memory Usage: " -FC YellowRGB

    # Градиентный прогресс бар для памяти
    $memFilled = [int]($memPercent / 5)
    for ($j = 0; $j -lt $memFilled; $j++) {
        $barColor = Get-GradientColor -Index $j -TotalItems 20 -StartColor "#0080FF" -EndColor "#FF0080"
        Write-RGB "█" -FC $barColor
    }
    Write-Host ("░" * (20 - $memFilled)) -NoNewline
    Write-RGB " $memPercent% " -FC White
    Write-RGB "($([Math]::Round($usedMem, 1))GB / $([Math]::Round($totalMem, 1))GB)" -FC White -newline

    # Top processes с градиентом
    Write-RGB "`n🏃 TOP PROCESSES BY CPU:" -FC MagentaRGB -newline
    $topProcesses = Get-Process | Sort-Object CPU -Descending | Select-Object -First 5
    $procIndex = 0
    foreach ($proc in $topProcesses) {
        $procColor = Get-GradientColor -Index $procIndex -TotalItems 5 -StartColor "#FF00FF" -EndColor "#00FFFF"
        Write-RGB "   • " -FC PurpleRGB
        Write-RGB ("{0,-20}" -f $proc.ProcessName) -FC $procColor
        Write-RGB "CPU: $([Math]::Round($proc.CPU, 2))s " -FC CyanRGB
        Write-RGB "Mem: $([Math]::Round($proc.WS / 1MB, 1))MB" -FC YellowRGB -newline
        $procIndex++
    }
}

# ===== МЕНЮ НАСТРОЙКИ POWERSHELL =====
function Show-PowerShellConfigMenu {
    $menuItems = @(
        @{ Text = "🎨 Изменить цветовую схему"; Data = "colors" },
        @{ Text = "📝 Редактировать профиль"; Data = "edit-profile" },
        @{ Text = "🔄 Перезагрузить профиль"; Data = "reload" },
        @{ Text = "📦 Установить модули"; Data = "install-modules" },
        @{ Text = "⚙️  Настройки PSReadLine"; Data = "psreadline" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $gradientOptions = @{
        StartColor = "#8A2BE2"
        EndColor = "#4169E1"
        GradientType = "Sine"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "⚙️  НАСТРОЙКА POWERSHELL" -Prompt "Выберите действие" -GradientOptions $gradientOptions

    switch ($selected.Data) {
        "colors" {
            Show-ColorSchemeMenu
        }
        "edit-profile" {
            if (Get-Command code -ErrorAction SilentlyContinue) {
                code $PROFILE
            } else {
                notepad $PROFILE
            }
            Show-PowerShellConfigMenu
        }
        "reload" {
            Write-RGB "`n🔄 Перезагрузка профиля..." -FC YellowRGB -newline
            . $PROFILE
            Write-RGB "✅ Профиль перезагружен!" -FC LimeRGB -newline
            Pause
            Show-PowerShellConfigMenu
        }
        "install-modules" {
            Show-ModuleInstallMenu
        }
        "psreadline" {
            Write-RGB "`n⚙️  Текущие настройки PSReadLine:" -FC CyanRGB -newline
            Get-PSReadLineOption | Format-List
            Pause
            Show-PowerShellConfigMenu
        }
        "back" {
            Show-MainMenu
        }
    }
}

# ===== МЕНЮ УСТАНОВКИ МОДУЛЕЙ =====
function Show-ModuleInstallMenu {
    $modules = @(
        @{ Text = "📊 ImportExcel - работа с Excel"; Data = "ImportExcel" },
        @{ Text = "🎨 PowerColorLS - цветной ls"; Data = "PowerColorLS" },
        @{ Text = "📁 z - быстрая навигация"; Data = "z" },
        @{ Text = "🔍 PSEverything - поиск файлов"; Data = "PSEverything" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $selected = Show-Menu -MenuItems $modules -MenuTitle "📦 УСТАНОВКА МОДУЛЕЙ" -Prompt "Выберите модуль"

    if ($selected.Data -eq "back") {
        Show-PowerShellConfigMenu
    } else {
        Write-RGB "`n📦 Установка модуля $($selected.Data)..." -FC CyanRGB -newline
        Install-Module -Name $selected.Data -Scope CurrentUser -Force
        Write-RGB "✅ Модуль установлен!" -FC LimeRGB -newline
        Import-Module $selected.Data
        Pause
        Show-ModuleInstallMenu
    }
}

# ===== МЕНЮ ОЧИСТКИ СИСТЕМЫ =====
function Show-CleanupMenu {
    $menuItems = @(
        @{ Text = "🗑️  Очистить временные файлы"; Data = "temp" },
        @{ Text = "📁 Очистить кэш"; Data = "cache" },
        @{ Text = "🧹 Очистить корзину"; Data = "recycle" },
        @{ Text = "💾 Анализ дискового пространства"; Data = "disk-space" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $gradientOptions = @{
        StartColor = "#228B22"
        EndColor = "#FF6347"
        GradientType = "Linear"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "🧹 ОБСЛУЖИВАНИЕ СИСТЕМЫ" -Prompt "Выберите действие" -GradientOptions $gradientOptions

    switch ($selected.Data) {
        "temp" {
            Write-RGB "`n🗑️  Очистка временных файлов..." -FC YellowRGB -newline
            $tempFolders = @($env:TEMP, "C:\Windows\Temp")
            foreach ($folder in $tempFolders) {
                Get-ChildItem $folder -Recurse -Force -ErrorAction SilentlyContinue |
                        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            }
            Write-RGB "✅ Временные файлы очищены!" -FC LimeRGB -newline
            Pause
            Show-CleanupMenu
        }
        "cache" {
            Write-RGB "`n📁 Очистка кэша..." -FC OrangeRGB -newline
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            Write-RGB "✅ Кэш очищен!" -FC LimeRGB -newline
            Pause
            Show-CleanupMenu
        }
        "recycle" {
            Write-RGB "`n🧹 Очистка корзины..." -FC CyanRGB -newline
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            Write-RGB "✅ Корзина очищена!" -FC LimeRGB -newline
            Pause
            Show-CleanupMenu
        }
        "disk-space" {
            Show-DiskSpaceAnalysis
            Pause
            Show-CleanupMenu
        }
        "back" {
            Show-MainMenu
        }
    }
}

# ===== АНАЛИЗ ДИСКОВОГО ПРОСТРАНСТВА =====
function Show-DiskSpaceAnalysis {
    Write-RGB "`n💾 АНАЛИЗ ДИСКОВОГО ПРОСТРАНСТВА" -FC GoldRGB -newline

    Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        if ($_.Used -gt 0) {
            $usedPercent = [Math]::Round(($_.Used / ($_.Used + $_.Free)) * 100, 2)

            Write-RGB "`n📁 Диск " -FC White
            Write-RGB "$($_.Name):" -FC CyanRGB -newline

            # Градиентный прогресс бар
            $filled = [int]($usedPercent / 3.33)
            for ($i = 0; $i -lt $filled; $i++) {
                $color = Get-GradientColor -Index $i -TotalItems 30 -StartColor "#00FF00" -EndColor "#FF0000"
                Write-RGB "█" -FC $color
            }
            Write-Host ("░" * (30 - $filled)) -NoNewline

            Write-RGB " $usedPercent%" -FC White -newline
            Write-RGB "   Использовано: " -FC White
            Write-RGB "$([Math]::Round($_.Used / 1GB, 2)) GB" -FC YellowRGB
            Write-RGB " | Свободно: " -FC White
            Write-RGB "$([Math]::Round($_.Free / 1GB, 2)) GB" -FC LimeRGB -newline
        }
    }
}

# ===== ГЛАВНОЕ МЕНЮ С RGB =====
function Show-MainMenu {
    #Clear-Host

    # Анимированный заголовок с градиентом
    $title = "🌈 POWERSHELL ULTRA MENU 🌈"
    $padding = " " * ((60 - $title.Length) / 2)

    Write-Host $padding -NoNewline
    for ($i = 0; $i -lt $title.Length; $i++) {
        if ($title[$i] -ne ' ') {
            $color = Get-GradientColor -Index $i -TotalItems $title.Length -StartColor "#FF0080" -EndColor "#00FFFF"
            Write-RGB $title[$i] -FC $color
        } else {
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
        EndColor = "#FF9955"
        GradientType = "Linear"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "" -Prompt "Выберите действие" -GradientOptions $gradientOptions

    switch ($selected.Data) {
        "dev-tools" { Show-DevToolsMenu }
        "run-application" { Run-Application }
        "powershell-config" { Show-PowerShellConfigMenu }
        "system-cleanup" { Show-CleanupMenu }
        "system-info" {
            Show-SystemInfo
            Write-RGB "`nНажмите любую клавишу..." -FC CyanRGB -newline
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Show-MainMenu
        }
        "network-utils" { Show-NetworkMenu }
        "rgb-demo" { Show-RGBDemo }
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

# ===== СЕТЕВОЕ МЕНЮ =====
function Show-NetworkMenu {
    $menuItems = @(
        @{ Text = "🌐 Показать сетевую информацию"; Data = "info" },
        @{ Text = "🏓 Ping тест"; Data = "ping" },
        @{ Text = "🔍 Сканировать порты"; Data = "ports" },
        @{ Text = "📡 Проверить скорость интернета"; Data = "speed" },
        @{ Text = "🌍 Проверить внешний IP"; Data = "external-ip" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $gradientOptions = @{
        StartColor = "#1E90FF"
        EndColor = "#00FA9A"
        GradientType = "Exponential"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "🌐 СЕТЕВЫЕ УТИЛИТЫ" -Prompt "Выберите действие" -GradientOptions $gradientOptions

    switch ($selected.Data) {
        "info" {
            Show-NetworkInfo
            Pause
            Show-NetworkMenu
        }
        "ping" {
            $target = Read-Host "`nВведите адрес (по умолчанию google.com)"
            if (-not $target) { $target = "google.com" }
            Test-ConnectionVisual -ComputerName $target
            Pause
            Show-NetworkMenu
        }
        "ports" {
            Show-PortScanner
            Pause
            Show-NetworkMenu
        }
        "speed" {
            Write-RGB "`n📡 Проверка скорости интернета..." -FC YellowRGB -newline
            if (Get-Command speedtest -ErrorAction SilentlyContinue) {
                speedtest
            } else {
                Write-RGB "⚠️  Speedtest CLI не установлен" -FC OrangeRGB -newline
                Write-RGB "Установите: winget install Ookla.Speedtest" -FC CyanRGB -newline
            }
            Pause
            Show-NetworkMenu
        }
        "external-ip" {
            try {
                Write-RGB "`n🌍 Получение внешнего IP..." -FC CyanRGB -newline
                $ip = (Invoke-RestMethod -Uri "https://api.ipify.org?format=json").ip
                $ipInfo = Invoke-RestMethod -Uri "http://ip-api.com/json/$ip"

                Write-RGB "📍 IP: " -FC White
                Write-RGB $ip -FC NeonGreenRGB -newline
                Write-RGB "🌍 Страна: " -FC White
                Write-RGB $ipInfo.country -FC YellowRGB -newline
                Write-RGB "🏙️  Город: " -FC White
                Write-RGB $ipInfo.city -FC CyanRGB -newline
                Write-RGB "🏢 Провайдер: " -FC White
                Write-RGB $ipInfo.isp -FC MagentaRGB -newline
            } catch {
                Write-RGB "❌ Ошибка получения информации" -FC Red -newline
            }
            Pause
            Show-NetworkMenu
        }
        "back" { Show-MainMenu }
    }
}

# ===== RGB DEMO =====
function Show-RGBDemo {
    #Clear-Host
    Write-RGB "`n🌈 RGB COLOR DEMONSTRATION 🌈" -FC UkraineBlueRGB -newline

    # Градиентная линия
    for ($i = 0; $i -lt 60; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems 60 -StartColor "#FF0000" -EndColor "#0000FF" -GradientType "Sine"
        Write-RGB "═" -FC $color
    }
    Write-RGB "" -newline

    # Цветовая волна
    Write-RGB "`n🎨 Color Wave:" -FC White -newline
    for ($i = 0; $i -lt 360; $i += 5) {
        $r = [Math]::Sin($i * [Math]::PI / 180) * 127 + 128
        $g = [Math]::Sin(($i + 120) * [Math]::PI / 180) * 127 + 128
        $b = [Math]::Sin(($i + 240) * [Math]::PI / 180) * 127 + 128
        Write-RGB "█" -FC $PSStyle.Foreground.FromRgb([int]$r, [int]$g, [int]$b)
    }
    Write-RGB "" -newline

    # Матрица с градиентом
    Write-RGB "`n💻 Matrix Effect:" -FC LimeRGB -newline
    for ($row = 0; $row -lt 5; $row++) {
        for ($col = 0; $col -lt 40; $col++) {
            $char = [char](Get-Random -Minimum 33 -Maximum 126)
            $greenShade = Get-GradientColor -Index $col -TotalItems 40 -StartColor "#00FF00" -EndColor "#003300"
            Write-RGB $char -FC $greenShade
        }
        Write-RGB "" -newline
    }

    # Неоновые цвета
    Write-RGB "`n✨ Neon Colors:" -FC White -newline
    $neonColors = @("NeonBlueRGB", "NeonGreenRGB", "NeonPinkRGB", "NeonRedRGB", "CyanRGB", "MagentaRGB", "YellowRGB", "OrangeRGB")
    foreach ($colorName in $neonColors) {
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
function proj {
    param([string]$Name)

    $projects = @{
        "tauri"  = "C:\Projects\TauriApp"
        "react"  = "C:\Projects\ReactApp"
        "rust"   = "C:\Projects\RustProject"
        "web3"   = "C:\Projects\Web3App"
        "vite"   = "C:\Projects\ViteApp"
    }

    if ($Name -and $projects.ContainsKey($Name)) {
        Set-Location $projects[$Name]
        Write-RGB "📁 Switched to project: " -FC White
        Write-RGB $Name -FC NeonGreenRGB -newline
        ls
    } else {
        Write-RGB "📁 Available projects:" -FC CyanRGB -newline
        $i = 0
        $projects.Keys | Sort-Object | ForEach-Object {
            $color = Get-GradientColor -Index $i -TotalItems $projects.Count -StartColor "#00FF00" -EndColor "#FF00FF"
            Write-RGB "   • " -FC White
            Write-RGB $_ -FC $color
            Write-RGB " → " -FC White
            Write-RGB $projects[$_] -FC DarkGray -newline
            $i++
        }
    }
}

# ===== АЛИАС ДЛЯ БЫСТРОГО ДОСТУПА К МЕНЮ =====
Set-Alias -Name menu -Value Show-MainMenu

# ===== ИНТЕГРАЦИЯ С SECURITYWATCHER =====
if (Get-Module -ListAvailable -Name SecurityWatcher) {
    Import-Module SecurityWatcher -ErrorAction SilentlyContinue
    Write-RGB "🛡️  SecurityWatcher loaded" -FC LimeRGB -newline
}

# ===== ПОКАЗАТЬ ПРИВЕТСТВИЕ =====
Show-Welcome