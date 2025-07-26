#function ultra { oh-my-posh init pwsh --config "C:\Users\ketov\Documents\PowerShell\ua-ultra.omp.yaml" | Invoke-Expression }
#function ultraultra { oh-my-posh init pwsh --config "C:\Users\ketov\Documents\PowerShell\ultraultra.omp.yaml" | Invoke-Expression }
#function gpt { oh-my-posh init pwsh --config "C:\Users\ketov\Documents\PowerShell\ua-gpt.omp.yaml" | Invoke-Expression }
#function deb { oh-my-posh init pwsh --config "CC:\Users\ketov\Documents\PowerShell\free-ukraine-debug.omp.yaml" | Invoke-Expression }
#
#function fr  { oh-my-posh init pwsh --config "C:\Users\ketov\Documents\PowerShell\OmpThemes\froczh.omp.json" | Invoke-Expression }
#function grr  { oh-my-posh init pwsh --config "C:\Users\ketov\Documents\PowerShell\glowsticks.omp.yaml" | Invoke-Expression }
#$configPath = "C:\Users\ketov\Documents\PowerShell\ua-gpt.omp.yaml"
$configPath = "C:\Users\ketov\Documents\PowerShell\ultra.omp.toml"

# ==============================================
# БЫСТРАЯ ИНИЦИАЛИЗАЦИЯ - ТОЛЬКО КРИТИЧНОЕ
# ==============================================

$global:openWeatherKey = 'bd0d5e697cb1c55014d0f8d84d96700b' #🔑
$global:profilePath = "${PSScriptRoot}\Profile\"

# Загружаем только самое необходимое для быстрого запуска
. "${global:profilePath}Utils\Init.ps1"

# Переносим тяжелые функции в отложенную загрузку
# Openwe - будет загружена в фоне
#$items = @("Файл", "Редактировать", "Просмотр", "Справка")
#$gradientSettings = @{
#    StartColor = "#FF0000"
#    EndColor = "#0000FF"
#    GradientType = "Linear"
#    RedCoefficient = 1.2
#}
#Show-GradientMenu -MenuItems $items -Title "Главное меню" -GradientOptions $gradientSettings




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

#    Write-RGB "`n$icon $Title`: $Message" -FC $color -newline

    # Wezterm notification если доступен
    if (Get-Command wezterm -ErrorAction SilentlyContinue)
    {

        wezterm cli send-text  --no-paste "${Title}:${Message}"
    }
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


# ==============================================
# ФОНОВАЯ ЗАГРУЗКА ТЯЖЕЛЫХ МОДУЛЕЙ
# ==============================================

# Проверяем наличие ThreadJob модуля
if (-not (Get-Module -ListAvailable -Name ThreadJob)) {
    Write-Warning "ThreadJob module not found. Installing..."
    try {
        Install-Module -Name ThreadJob -Force -Scope CurrentUser
    } catch {
        Write-Warning "Failed to install ThreadJob: $_"
    }
}

# Запускаем фоновую инициализацию
$global:BackgroundInitJob = $null
try {
    if (Get-Module -ListAvailable -Name ThreadJob) {
        $global:BackgroundInitJob = Start-ThreadJob -Name "ProfileBackgroundInit" -ScriptBlock {
            & "${using:PSScriptRoot}\Profile\Utils\Background-Init.ps1" -Verbose
        }
        
        # Регистрируем обработчик завершения фоновой загрузки
        Register-EngineEvent -SourceIdentifier "BackgroundInitComplete" -Action {
            $message = $Event.MessageData
            if ($message -like "Error:*") {
                Write-Warning "Background initialization failed: $($message -replace '^Error: ')"
            } else {
                Write-Host "✅ Background modules loaded successfully" -ForegroundColor Green
            }
        }
        
        Write-Host "🚀 Background initialization started..." -ForegroundColor Yellow
    } else {
        # Fallback: обычная загрузка если ThreadJob недоступен
        . "${PSScriptRoot}\Profile\Segments\SegmentUpdater.ps1"
        . "${PSScriptRoot}\Profile\OmpCommands.ps1"
        Start-OmpSegmentUpdater -IntervalSeconds 30
    }
} catch {
    Write-Warning "Failed to start background initialization: $_"
    # Fallback к синхронной загрузке
    try {
        . "${PSScriptRoot}\Profile\Segments\SegmentUpdater.ps1"
        . "${PSScriptRoot}\Profile\OmpCommands.ps1"
        Start-OmpSegmentUpdater -IntervalSeconds 30
    } catch {
        Write-Warning "Failed to initialize OMP custom segments: $_"
    }
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

Switch-KeyboardLayout en-Us

# ==============================================
# ОТЛОЖЕННАЯ ИНИЦИАЛИЗАЦИЯ
# ==============================================

# Таймер для отложенной загрузки менее критичных модулей
$delayedInitTimer = New-Object System.Timers.Timer
$delayedInitTimer.Interval = 3000  # 3 секунды после запуска
$delayedInitTimer.Add_Elapsed({
    try {
        # Отложенная инициализация тяжелых функций
        if (Test-Path "${PSScriptRoot}\Profile\Utils\Heavy-Functions.ps1") {
            . "${PSScriptRoot}\Profile\Utils\Heavy-Functions.ps1"
        }
        
        # Проверяем статус фоновой загрузки
        if ($global:BackgroundInitJob) {
            $jobState = $global:BackgroundInitJob.State
            if ($jobState -eq "Completed") {
                Write-Host "✅ All background processes completed" -ForegroundColor Green
            } elseif ($jobState -eq "Failed") {
                Write-Warning "Background initialization failed"
            }
        }
        
        Write-Host "⏰ Delayed initialization completed" -ForegroundColor Cyan
    } catch {
        Write-Warning "Delayed initialization error: $_"
    } finally {
        $delayedInitTimer.Stop()
        $delayedInitTimer.Dispose()
    }
})
$delayedInitTimer.Start()

# Очистка при выходе из PowerShell
Register-EngineEvent -SourceIdentifier "PowerShell.Exiting" -Action {
    # Останавливаем фоновые задачи
    if ($global:BackgroundInitJob) {
        $global:BackgroundInitJob | Stop-Job -PassThru | Remove-Job -Force
    }
    
    # Очищаем таймеры
    if ($delayedInitTimer) {
        $delayedInitTimer.Stop()
        $delayedInitTimer.Dispose()
    }
    
    # Очищаем события
    Get-EventSubscriber | Unregister-Event
}

importProcess -finalInitialiazation


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


