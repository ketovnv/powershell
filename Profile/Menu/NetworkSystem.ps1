Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start
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
            wrgb "`n📡 Проверка скорости интернета..." -FC YellowRGB -newline
            if (Get-Command speedtest -ErrorAction SilentlyContinue) {
                speedtest
            } else {
                wrgb "⚠️  Speedtest CLI не установлен" -FC OrangeRGB -newline
                wrgb "Установите: winget install Ookla.Speedtest" -FC CyanRGB -newline
            }
            Pause
            Show-NetworkMenu
        }
        "external-ip" {
            try {
                wrgb "`n🌍 Получение внешнего IP..." -FC CyanRGB -newline
                $ip = (Invoke-RestMethod -Uri "https://api.ipify.org?format=json").ip
                $ipInfo = Invoke-RestMethod -Uri "http://ip-api.com/json/$ip"

                wrgb "📍 IP: " -FC White
                wrgb $ip -FC NeonMaterial_LightGreen -newline
                wrgb "🌍 Страна: " -FC White
                wrgb $ipInfo.country -FC YellowRGB -newline
                wrgb "🏙️  Город: " -FC White
                wrgb $ipInfo.city -FC CyanRGB -newline
                wrgb "🏢 Провайдер: " -FC White
                wrgb $ipInfo.isp -FC MagentaRGB -newline
            } catch {
                wrgb "❌ Ошибка получения информации" -FC Red -newline
            }
            Pause
            Show-NetworkMenu
        }
        "back" { Show-MainMenu }
    }
}

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
                wrgb "`n📋 HTTP Headers для $url`:" -FC CyanRGB -newline
                $response.Headers | Format-Table -AutoSize
            } catch {
                wrgb "❌ Ошибка получения заголовков" -FC Red -newline
            }
            Pause
            Show-NetworkToolsMenu
        }
        "ssl-check" {
            $host1 = Read-Host "`nВведите домен"
            wrgb "`n🔓 Проверка SSL для $host1`..." -FC YellowRGB -newline
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            try {
                $tcpClient.Connect($host1, 443)
                $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream())
                $sslStream.AuthenticateAsClient($host1)
                $cert = $sslStream.RemoteCertificate
                wrgb "✅ SSL сертификат действителен до: $($cert.GetExpirationDateString())" -FC LimeRGB -newline
            } catch {
                wrgb "❌ Ошибка проверки SSL" -FC Red -newline
            } finally {
                $tcpClient.Close()
            }
            Pause
            Show-NetworkToolsMenu
        }
        "dns-lookup" {
            $domain = Read-Host "`nВведите домен"
            wrgb "`n📡 DNS lookup для $domain`:" -FC MagentaRGB -newline
            Resolve-DnsName $domain | Format-Table -AutoSize
            Pause
            Show-NetworkToolsMenu
        }
        "traceroute" {
            $target = Read-Host "`nВведите адрес"
            wrgb "`n🔍 Traceroute к $target`:" -FC OrangeRGB -newline
            Test-NetConnection -ComputerName $target -TraceRoute
            Pause
            Show-NetworkToolsMenu
        }
        "netstat" {
            wrgb "`n📊 Активные соединения:" -FC CyanRGB -newline
            netstat -an | Select-String "ESTABLISHED|LISTENING" | Select-Object -First 20
            Pause
            Show-NetworkToolsMenu
        }
        "back" {
            Show-DevToolsMenu
        }
    }
}

function Show-SystemInfo {
    wrgb "`n💻 SYSTEM INFORMATION" -FC NeonPinkRGB -newline

    # Градиентная линия
    for ($i = 0; $i -lt 50; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems 50 -StartColor "#FF1493" -EndColor "#00CED1"
        wrgb "═" -FC $color
    }
    wrgb "" -newline

    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $mem = Get-CimInstance Win32_PhysicalMemory
    $gpu = Get-CimInstance Win32_VideoController

    # OS Info
    wrgb "🖥️  OS: " -FC CyanRGB
    wrgb $os.Caption -FC White -newline

    # CPU Info
    wrgb "🔧 CPU: " -FC YellowRGB
    wrgb "$($cpu.Name) ($($cpu.NumberOfCores) cores)" -FC White -newline

    # Memory
    $totalMem = ($mem | Measure-Object -Property Capacity -Sum).Sum / 1GB
    wrgb "💾 RAM: " -FC LimeRGB
    wrgb "$([Math]::Round($totalMem, 2)) GB" -FC White -newline

    # GPU
    wrgb "🎮 GPU: " -FC OrangeRGB
    wrgb $gpu.Name -FC White -newline

    # Uptime
    $uptime = (Get-Date) - $os.LastBootUpTime
    wrgb "⏱️  Uptime: " -FC MagentaRGB
    wrgb "$($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" -FC White -newline

    # Градиентная линия
    for ($i = 0; $i -lt 50; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems 50 -StartColor "#00CED1" -EndColor "#FF1493"
        wrgb "═" -FC $color
    }
    wrgb "" -newline
}

function Show-NetworkInfo {
    wrgb "`n🌐 NETWORK INFORMATION" -FC Ocean1RGB -newline
    wrgb ("═" * 50) -FC Ocean2RGB -newline

    # IP адреса
    $ips = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" }

    foreach ($ip in $ips) {
        wrgb "🔌 Interface: " -FC CyanRGB
        wrgb $ip.InterfaceAlias -FC White -newline
        wrgb "   IP: " -FC YellowRGB
        wrgb $ip.IPAddress -FC LimeRGB -newline
    }

    # Внешний IP
    try {
        wrgb "`n🌍 External IP: " -FC NeonMaterial_LightGreen
        $extIP = (Invoke-RestMethod -Uri "https://api.ipify.org?format=json" -TimeoutSec 5).ip
        wrgb $extIP -FC GoldRGB -newline
    } catch {
        wrgb "Unable to fetch" -FC Red -newline
    }

    wrgb ("═" * 50) -FC Ocean2RGB -newline
}

# ===== БЫСТРЫЙ PING С ВИЗУАЛИЗАЦИЕЙ =====
function Test-ConnectionVisual {
    param(
        [string]$ComputerName = "google.com",
        [int]$Count = 4
    )

    wrgb "`n🏓 PING $ComputerName" -FC NeonBlueRGB -newline
    wrgb ("─" * 40) -FC PurpleRGB -newline

    for ($i = 1; $i -le $Count; $i++) {
        try {
            $result = Test-Connection -ComputerName $ComputerName -Count 1 -ErrorAction Stop
            $time = $result.ResponseTime
            Write-RGB $time -fc "#FF0000"
            $color = if ($time -lt 50) { "LimeRGB" }
            elseif ($time -lt 100) { "YellowRGB" }
            else { "NeonRedRGB" }

            $bar = "█" * [Math]::Min([int]($time / 10), 20)

            wrgb "[$i] " -FC White
            wrgb $bar -FC $color
            wrgb " ${time}ms" -FC $color -newline
        } catch {
            wrgb "[$i] ❌ Timeout" -FC Red -newline
        }

        Start-Sleep -Milliseconds 500
    }

    wrgb ("─" * 40) -FC PurpleRGB -newline
}

# ===== WEATHER WIDGET =====
function Get-Weather {
    param([string]$City = "Lvov")

    try {
        wrgb "`n🌤️  Getting weather..." -FC CyanRGB -newline
        $weather = Invoke-RestMethod -Uri "https://wttr.in/${City}?format=j1" -TimeoutSec 5
        $current = $weather.current_condition[0]

        wrgb "`r🌤️  Weather in $City  " -FC CyanRGB -newline
        wrgb "   🌡️  Temp: $($current.temp_C)°C" -FC YellowRGB -newline
        wrgb "   💨 Wind: $($current.windspeedKmph) km/h" -FC LimeRGB -newline
        wrgb "   💧 Humidity: $($current.humidity)%" -FC Ocean1RGB -newline
    } catch {
        wrgb "⚠️  Unable to fetch weather" -FC Yellow -newline
    }
}

function Show-PortScanner {
    wrgb "`n🔍 PORT SCANNER" -FC NeonPinkRGB -newline

    # Градиентная линия
    for ($i = 0; $i -lt 50; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems 50 -StartColor "#FF69B4" -EndColor "#FF1493"
        wrgb "─" -FC $color
    }
    wrgb "" -newline

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
            wrgb "✅ Port " -FC White
            wrgb $port -FC $portColor
            wrgb " - " -FC White
            wrgb "OPEN" -FC NeonMaterial_LightGreen
            wrgb " ($($commonPorts[$port]))" -FC CyanRGB -newline
        } else {
            wrgb "❌ Port " -FC White
            wrgb $port -FC DarkGray
            wrgb " - " -FC White
            wrgb "CLOSED" -FC Gray
            wrgb " ($($commonPorts[$port]))" -FC DarkGray -newline
        }
        $i++
    }
}

function Show-SystemMonitor {
    wrgb "`n📊 SYSTEM MONITOR" -FC GoldRGB -newline

    # Градиентная линия
    for ($i = 0; $i -lt 60; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems 60 -StartColor "#FFD700" -EndColor "#FF4500"
        wrgb "═" -FC $color
    }
    wrgb "" -newline

#    # CPU
#    $cpu = Get-CimInstance Win32_Processor
#    $cpuLoad = (Get-Counter "\Processor(_Total)\% Processor Time" -ErrorAction SilentlyContinue).CounterSamples.CookedValue
#    $cpuColor = if ($cpuLoad -gt 80) { "NeonRedRGB" }
#    elseif ($cpuLoad -gt 50) { "OrangeRGB" }
#    else { "LimeRGB" }
#
#    wrgb "`n🔧 CPU Usage: " -FC CyanRGB
#
#    # Градиентный прогресс бар для CPU
#    $cpuBar = ""
#    $cpuFilled = [int]($cpuLoad / 5)
#    for ($j = 0; $j -lt $cpuFilled; $j++) {
#        $barColor = Get-GradientColor -Index $j -TotalItems 20 -StartColor "#00FF00" -EndColor "#FF0000"
#        wrgb "█" -FC $barColor
#    }
#    Write-Host ("░" * (20 - $cpuFilled)) -NoNewline
#    wrgb " $([Math]::Round($cpuLoad, 1))%" -FC $cpuColor -newline

    # Memory
    $os = Get-CimInstance Win32_OperatingSystem
    $totalMem = $os.TotalVisibleMemorySize / 1MB
    $freeMem = $os.FreePhysicalMemory / 1MB
    $usedMem = $totalMem - $freeMem
    $memPercent = [int](($usedMem / $totalMem) * 100)

    wrgb "⚜️ Memory Usage: " -FC YellowRGB

    # Градиентный прогресс бар для памяти
    $memFilled = [int]($memPercent / 5)
    for ($j = 0; $j -lt $memFilled; $j++) {
        $barColor = Get-GradientColor -Index $j -TotalItems 20 -StartColor "#0080FF" -EndColor "#FF0080"
        wrgb "█" -FC $barColor
    }
    Write-Host ("░" * (20 - $memFilled)) -NoNewline
    wrgb " $memPercent% " -FC White
    wrgb "($([Math]::Round($usedMem, 1))GB / $([Math]::Round($totalMem, 1))GB)" -FC White -newline

    # Top processes с градиентом
    wrgb "`n 🔝 PROCESSES BY OEM:" -FC "#5599DD" -newline
    $topProcesses = Get-Process | Sort-Object WS -Descending | Select-Object -First 5
    $procIndex = 0
    foreach ($proc in $topProcesses) {
        $procColor = Get-GradientColor -Index $procIndex -TotalItems 5 -StartColor "#7700FF" -EndColor "#00FFFF"
        $memColor = ($proc.WS -gt 1GB) ? 'OrangeRGB' : 'YellowRGB'
        wrgb "   • " -FC TealRGB
        wrgb ("{0,-25}" -f $proc.ProcessName) -FC $procColor
        wrgb ("{0,-20}" -f "$([Math]::Round($proc.WS / 1GB, 1))GB") -FC $memColor
        wrgb "CPU: $([Math]::Round($proc.CPU, 1))s " -FC CyanRGB -newline
        $procIndex++
    }
}

Set-Alias -Name ssm -Value Show-SystemMonitor
Trace-ImportProcess  $MyInvocation.MyCommand.Name.trim(".ps1")
