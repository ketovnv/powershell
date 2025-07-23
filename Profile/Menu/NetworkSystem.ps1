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
                Write-RGB $ip -FC NeonMaterial_LightGreen -newline
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
            $host1 = Read-Host "`nВведите домен"
            Write-RGB "`n🔓 Проверка SSL для $host1`..." -FC YellowRGB -newline
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            try {
                $tcpClient.Connect($host1, 443)
                $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream())
                $sslStream.AuthenticateAsClient($host1)
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
        Write-RGB "`n🌍 External IP: " -FC NeonMaterial_LightGreen
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
            Write-Rbg $time -fc "#FF0000"
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
    param([string]$City = "Lvov")

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
            Write-RGB "OPEN" -FC NeonMaterial_LightGreen
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