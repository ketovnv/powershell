#function ultra { oh-my-posh init pwsh --config "C:\Users\ketov\Documents\PowerShell\ua-ultra.omp.yaml" | Invoke-Expression }
#function ultraultra { oh-my-posh init pwsh --config "C:\Users\ketov\Documents\PowerShell\ultraultra.omp.yaml" | Invoke-Expression }
#function gpt { oh-my-posh init pwsh --config "C:\Users\ketov\Documents\PowerShell\ua-gpt.omp.yaml" | Invoke-Expression }
#function deb { oh-my-posh init pwsh --config "CC:\Users\ketov\Documents\PowerShell\free-ukraine-debug.omp.yaml" | Invoke-Expression }
#
#function fr  { oh-my-posh init pwsh --config "C:\Users\ketov\Documents\PowerShell\OmpThemes\froczh.omp.json" | Invoke-Expression }
#function grr  { oh-my-posh init pwsh --config "C:\Users\ketov\Documents\PowerShell\glowsticks.omp.yaml" | Invoke-Expression }
#$configPath = "C:\Users\ketov\Documents\PowerShell\ua-gpt.omp.yaml"
$configPath = "C:\Users\ketov\Documents\PowerShell\ultra.omp.toml"

$global:initStartScripts =  @()
$global:initEndScripts =  @()

$global:profilePath = "${PSScriptRoot}\Profile\"
. "${global:profilePath}Utils\Init.ps1"


#$items = @("Файл", "Редактировать", "Просмотр", "Справка")
#$gradientSettings = @{
#    StartColor = "#FF0000"
#    EndColor = "#0000FF"
#    GradientType = "Linear"
#    RedCoefficient = 1.2
#}
#Show-GradientMenu -MenuItems $items -Title "Главное меню" -GradientOptions $gradientSettings

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
        wezterm cli send-text  --no-paste "${Title}:${Message}"
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


# ===== УЛУЧШЕННЫЙ LS С RGB И ИКОНКАМИ =====
function lss
{
    param(
        [string]$Path = ".",
        [string]$StartColor = "#8B00FF",
        [string]$EndColor = "#00BFFF"
    )

    Write-RGB "`n📁 " -FC CyanRGB
    Write-RGB "Directory: " -FC CyanRGB
    Write-RGB (Resolve-Path $Path).Path -FC Yellow -newline

    # Градиентная линия
    $lineLength = 60
    for ($i = 0; $i -lt $lineLength; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems $lineLength -StartColor $StartColor -EndColor  $EndColor
        Write-RGB "─" -FC $color
    }
    Write-RGB "" -newline

    $items = Get-ChildItem $Path | Sort-Object PSIsContainer -Descending

    $col = 0
    foreach ($item in $items)
    {


        $color = Get-GradientColor -Index $col -TotalItems $items.length -StartColor "#8B00FF" -EndColor "#00BFFF"
        $col++
        if ($item.PSIsContainer)
        {
            Write-RGB "📂 " -FC Ocean1RGB
            Write-RGB ("{0,-35}" -f $item.Name) -FC Ocean1RGB
            Write-RGB " <DIR>" -FC $color  -newline
        }
        else
        {
            $icon = Get-FileIcon  $item.Extension
            $color = Get-FileColor $item.Extension

            $sizeColor = if ($item.Length -gt 1GB)
            {
                "#FF0000"
            }
            elseif ($item.Length -gt 100MB)
            {
                "Sunset1RGB"
            }
            elseif ($item.Length -gt 10MB)
            {
                "NeonRedRGB"
            }
            elseif ($item.Length -gt 1MB)
            {
                "OrangeRGB"
            }
            elseif ($item.Length -gt 100KB)
            {
                "LimeRGB"
            }
            else
            {
                "TealRGB"
            }

            Write-RGB "$icon " -FC White
            Write-RGB ("{0,-35}" -f $item.Name) -FC $color
            Write-RGB (" {0,10:N2} KB" -f ($item.Length / 1KB)) -FC $sizeColor
            Write-RGB ("  {0}" -f $item.LastWriteTime.ToString("yyyy-MM-dd HH:mm"),,[System.Globalization.CultureInfo]::GetCultureInfo("ru-RU")) -FC TealRGB -newline
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
    $title = "👻👻  POWERSHELL ULTRA MENU  🥷🥷"
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



# Oh My Posh инициализация
try
{
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue)
    {
        #        $configPath = "C:\Program Files (x86)\oh-my-posh\themes\freeu.omp.json"
        if (Test-Path $configPath)
        {
#            oh-my-posh init pwsh --config ~/custom.omp.json | Invoke-Expression
            oh-my-posh init pwsh --config $configPath | Invoke-Expression
        }
        else
        {
            Write-Warning "Oh My Posh theme file not found: $configPath"
        }
    }
    else
    {
        Write-Warning "Oh My Posh not found in PATH"
    }
}
catch
{
    Write-Warning "Failed to initialize Oh My Posh: $_"
}

foreach ($script in $scriptsAfter)
{
    . "${global:profilePath}${script}.ps1"
}
Write-Host ""
Switch-KeyboardLayout en-Us
Write-Host ""
foreach ($scriptInitStart in $global:initStartScripts)
{
     if($global:initEndScripts -contains $scriptInitStart){
         Write-Status -Success $scriptInitStart"  "
     } else {
         Write-Status -Problem $scriptInitStart"  "
     }
}
Write-Host ""

#$VerbosePreference = "Continue"

# SIG # Begin signature block
# MIIFuQYJKoZIhvcNAQcCoIIFqjCCBaYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDvZHvp8zN9rynb
# S4lfOj1+3Fri94W5Q/xa+vDHVehvg6CCAyIwggMeMIICBqADAgECAhBiLIVmAdNa
# pEvbYvK7Awv6MA0GCSqGSIb3DQEBCwUAMCcxJTAjBgNVBAMMHFBvd2VyU2hlbGwg
# Q29kZSBTaWduaW5nIENlcnQwHhcNMjUwNzIzMDU0NjM4WhcNMjYwNzIzMDYwNjM4
# WjAnMSUwIwYDVQQDDBxQb3dlclNoZWxsIENvZGUgU2lnbmluZyBDZXJ0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxFnljrxXVoCqg6r4XZALR44aR12G
# rWwVYrmXATeVt8/QiZE6bENceCyrUQ68Iy+O2hkJTX4RUMkLc7nX8UuWtaCNZAAr
# pxIciCmT1XQ7aoSCxeH4fTShKD3jiCWH8tukLeuotNLJ4kIVPwy6qKM8mZ3sGJvr
# 28Pmi89ykAP2Ng9KXK5t/bCsLb/gEspB7WcRDI8adp+7LSTbtfCsE453jtwn+cAy
# Uyfg8x7JxtCpgKWC4nD7kphfhZzLf/MlS0aRmCiRpJzqSZ2F+UydwwPa8yD0PC9n
# fqzYOUEMN9/gAxVI7X5KFLHmj4y05vaNHgeedI3fi9s7ee/2oZkJGnyXPQIDAQAB
# o0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0O
# BBYEFBCYx/NaWY00AODmjDhwnH6Tqs2MMA0GCSqGSIb3DQEBCwUAA4IBAQB+Pfz3
# w45mLd+hLvPiX0hdI9QsK6vlR1fVeB3C+wPzETE1NvVrWUYy0uqXm7Mjfv8APO9Y
# tq7tciaKashJI60fBC0x+SK6sbzuwFltMaYhA8CuYEsH/GJV7cY8zU1bInsz8fP7
# W7HG4pgIyhPTBC93vgsmMsBB6Ffn6m/X/TJ3VrlsfdF2YH0kGRm03Tr7NWO5eHTE
# 3J0kQ1l3G2Z/O4rAfhLDcwMV6QgOI8JLmsum7aLnTPmKyT2M/hYW1glPwMN/U5H+
# crCAfaRaK2nFXev7l20dyJ+3oyY6cpE8g2sCLDC0n7YbZmOysua0xaScw8mfnpT7
# XUvG/pJIlq0ovXwPMYIB7TCCAekCAQEwOzAnMSUwIwYDVQQDDBxQb3dlclNoZWxs
# IENvZGUgU2lnbmluZyBDZXJ0AhBiLIVmAdNapEvbYvK7Awv6MA0GCWCGSAFlAwQC
# AQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwG
# CisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZI
# hvcNAQkEMSIEIJf0HHz6GGnz4zBS2XPckLHLH8eBFubG/RVjZqytQJQuMA0GCSqG
# SIb3DQEBAQUABIIBAF5hdPVzK0Pd4jTuyjx2njdlt24iH5TXQBEwYsB8qedv/P7C
# oVAGGygqZIMgkEuAoyYo1lqF1cUiD5IsEKDpGgfm+5+CxQiiciSvCjt7MiJRBfq7
# 1ZR6Oa0dPhvE2JuRHut4O+GdWViQtAMbOpS7ZXNbYdMedXbV83eFPxUXZRN2WX5w
# eKxrjL5xq+Gywprm7e/+ockaBV+FXZcCmdNa8EIERQtITfdir2GRetBO8Ynt0KsT
# Zv7Rn3TCV3MrsdY2EOZsMyxvRXDlGrir5OsRX46H7yTytJAun5KU/uexBiV4ODrV
# ZRINZTarsj//rs8OCOhYmDT5MO54J995HnH+tFY=
# SIG # End signature block

##f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module
#Import-Module -Name Microsoft.WinGet.CommandNotFound
##f45873b3-b655-43a6-b217-97c00aa0db58


