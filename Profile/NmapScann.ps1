# 🔥 ADVANCED NMAP SCANNER WITH REAL-TIME PARSER
# Автор: PowerShell Ninja 🥷

#region Helper Functions
function Write-RGB {
    param(
        [string]$Text,
        [string]$FC = "White",      # ForegroundColor
        [string]$BC = "",            # BackgroundColor
        [string]$Style = "",         # Bold, Underline, Blink
        [switch]$NoNewline
    )

    $output = switch ($Style) {
        "Bold" { $PSStyle.Bold + $Text + $PSStyle.BoldOff }
        "Underline" { $PSStyle.Underline + $Text + $PSStyle.UnderlineOff }
        "Blink" { $PSStyle.Blink + $Text + $PSStyle.BlinkOff }
        default { $Text }
    }

    $params = @{
        Object = $output
        ForegroundColor = $FC
        NoNewline = $NoNewline
    }
    if ($BC) { $params.BackgroundColor = $BC }

    Write-Host @params
}

function Write-Status {
    param(
        [string]$Message,
        [switch]$Success,
        [switch]$Warning,
        [switch]$Error,
        [switch]$Info
    )

    $icon = "📌"
    $color = "White"

    if ($Success) { $icon = "✅"; $color = "Green" }
    elseif ($Warning) { $icon = "⚠️"; $color = "Yellow" }
    elseif ($Error) { $icon = "❌"; $color = "Red" }
    elseif ($Info) { $icon = "ℹ️"; $color = "Cyan" }

    Write-RGB "$icon " -FC $color -NoNewline
    Write-RGB $Message -FC $color
}

# Наш модифицированный Out-Default для красивого вывода
function Out-Default {
    [CmdletBinding()]
    param(
        [switch]$Transcript,
        [Parameter(ValueFromPipeline=$true)]
        [psobject]$InputObject
    )

    begin {
        $realOutDefault = $ExecutionContext.InvokeCommand.GetCommand(
                'Microsoft.PowerShell.Core\Out-Default',
                [System.Management.Automation.CommandTypes]::Cmdlet
        )
        $steppablePipeline = { & $realOutDefault @PSBoundParameters }.GetSteppablePipeline()
        $steppablePipeline.Begin($PSCmdlet)
    }

    process {
        # Обрабатываем наши кастомные объекты
        if ($InputObject.PSObject.TypeNames -contains 'Nmap.PortInfo') {
            Format-NmapPort $InputObject
            return
        }
        elseif ($InputObject.PSObject.TypeNames -contains 'Nmap.ServiceInfo') {
            Format-ServiceInfo $InputObject
            return
        }
        else {
            $steppablePipeline.Process($InputObject)
        }
    }

    end {
        $steppablePipeline.End()
    }
}
#endregion

#region Nmap Functions
function Invoke-NmapScan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Target,

        [string]$Ports = "1-1000",

        [ValidateSet('TCP', 'UDP', 'SYN', 'ACK', 'Window', 'Maimon')]
        [string]$ScanType = 'TCP',

        [switch]$ServiceDetection,
        [switch]$OSDetection,
        [switch]$AggressiveScan,
        [switch]$LiveAnalysis
    )

    # Проверяем наличие nmap
    if (-not (Get-Command nmap -ErrorAction SilentlyContinue)) {
        Write-Status -Error "Nmap не найден! Установите: https://nmap.org/download.html"
        return
    }

    Write-RGB "`n🎯 NMAP ADVANCED SCANNER 3000 🎯`n" -FC "Cyan" -Style Bold
    Write-RGB ("═" * 60) -FC "DarkCyan"

    # Формируем команду
    $nmapArgs = @()

    switch ($ScanType) {
        'TCP' { $nmapArgs += '-sT' }
        'UDP' { $nmapArgs += '-sU' }
        'SYN' { $nmapArgs += '-sS' }
        'ACK' { $nmapArgs += '-sA' }
        'Window' { $nmapArgs += '-sW' }
        'Maimon' { $nmapArgs += '-sM' }
    }

    if ($ServiceDetection) { $nmapArgs += '-sV' }
    if ($OSDetection) { $nmapArgs += '-O' }
    if ($AggressiveScan) { $nmapArgs += '-A' }

    $nmapArgs += @(
        '-p', $Ports,
        '--open',
        '-Pn',
        '--stats-every', '1s',
        $Target
    )

    Write-Status -Info "Запускаем сканирование: nmap $($nmapArgs -join ' ')"
    Write-RGB "`nTarget: " -FC "Yellow" -NoNewline
    Write-RGB $Target -FC "Cyan" -Style Bold
    Write-RGB "Ports: " -FC "Yellow" -NoNewline
    Write-RGB $Ports -FC "Green"
    Write-RGB ("─" * 60) -FC "DarkGray"

    # Глобальные счетчики
    $script:ScanStats = @{
        OpenPorts = 0
        ClosedPorts = 0
        Services = @{}
        Vulnerabilities = @()
        HttpServers = @()
        Databases = @()
        StartTime = Get-Date
    }

    # Запускаем nmap с обработкой в реальном времени
    $nmapProcess = Start-Process -FilePath "nmap" -ArgumentList $nmapArgs -NoNewWindow -PassThru -RedirectStandardOutput "nmap_temp.txt" -RedirectStandardError "nmap_error.txt"

    # Следим за выводом в реальном времени
    $reader = [System.IO.File]::OpenText("nmap_temp.txt")
    $buffer = ""

    try {
        while (-not $nmapProcess.HasExited -or $reader.Peek() -ne -1) {
            $line = $reader.ReadLine()
            if ($line) {
                $buffer += $line + "`n"

                # Парсим строку в реальном времени
                if ($LiveAnalysis) {
                    Process-NmapLine -Line $line
                }

                # Ищем информацию о портах
                if ($line -match '^(\d+)/(tcp|udp)\s+(\w+)\s+(\w+)\s*(.*)$') {
                    $portInfo = [PSCustomObject]@{
                        PSTypeName = 'Nmap.PortInfo'
                        Port = [int]$Matches[1]
                        Protocol = $Matches[2]
                        State = $Matches[3]
                        Service = $Matches[4]
                        Version = $Matches[5]
                        Target = $Target
                    }

                    # Обновляем статистику
                    if ($portInfo.State -eq 'open') {
                        $script:ScanStats.OpenPorts++
                        $script:ScanStats.Services[$portInfo.Service]++

                        # Автоматические проверки для открытых портов
                        Invoke-PortAnalysis -PortInfo $portInfo
                    }

                    # Выводим через наш красивый форматтер
                    $portInfo | Out-Default
                }
            }

            Start-Sleep -Milliseconds 100
        }
    }
    finally {
        $reader.Close()
        Remove-Item "nmap_temp.txt", "nmap_error.txt" -ErrorAction SilentlyContinue
    }

    # Финальный анализ
    Show-ScanSummary
}

function Process-NmapLine {
    param([string]$Line)

    # Прогресс сканирования
    if ($Line -match 'Stats: .*\((\d+\.?\d*)% done\)') {
        $percent = [double]$Matches[1]
        $completed = [int]($percent / 2)
        $remaining = 50 - $completed

        Write-Host "`r" -NoNewline
        Write-RGB "Progress: [" -FC "Gray" -NoNewline
        Write-RGB ("█" * $completed) -FC "Green" -NoNewline
        Write-RGB ("░" * $remaining) -FC "DarkGray" -NoNewline
        Write-RGB "] $percent%" -FC "Yellow" -NoNewline
    }

    # Обнаружение ОС
    if ($Line -match 'OS details: (.+)') {
        Write-Host "`n" -NoNewline
        Write-Status -Info "OS Detected: $($Matches[1])"
    }

    # Предупреждения
    if ($Line -match 'Warning:' -or $Line -match 'ERROR:') {
        Write-Status -Warning $Line
    }
}

function Invoke-PortAnalysis {
    param($PortInfo)

    # Определяем тип сервиса и делаем дополнительные проверки
    switch -Regex ($PortInfo.Port) {
        '^(80|8080|8000|8888)$' {
            # HTTP серверы
            $script:ScanStats.HttpServers += $PortInfo
            Test-HttpServer -Target $PortInfo.Target -Port $PortInfo.Port
        }
        '^(443|8443)$' {
            # HTTPS серверы
            Test-HttpsServer -Target $PortInfo.Target -Port $PortInfo.Port
        }
        '^(3306|5432|1433|1521)$' {
            # Базы данных
            $script:ScanStats.Databases += $PortInfo
            Test-DatabaseServer -PortInfo $PortInfo
        }
        '^(21|22|23|3389)$' {
            # Сервисы удаленного доступа
            Test-RemoteAccess -PortInfo $PortInfo
        }
        '^(445|139|135)$' {
            # SMB/NetBIOS
            Test-SmbService -Target $PortInfo.Target -Port $PortInfo.Port
        }
    }
}

function Test-HttpServer {
    param($Target, $Port)

    $uri = "http://${Target}:${Port}"

    Write-RGB "`n  🌐 " -FC "Blue" -NoNewline
    Write-RGB "Проверяем HTTP сервер на порту $Port..." -FC "Cyan"

    try {
        # Используем наш улучшенный Invoke-WebRequest
        $response = Invoke-AdvancedWebRequest -Uri $uri -TimeoutSec 5 -Method HEAD -ErrorAction Stop

        Write-RGB "    ✓ " -FC "Green" -NoNewline
        Write-RGB "Server: " -FC "Gray" -NoNewline
        Write-RGB ($response.Headers.Server ?? "Unknown") -FC "Yellow"

        # Проверяем технологии
        if ($response.Headers.'X-Powered-By') {
            Write-RGB "    ✓ " -FC "Green" -NoNewline
            Write-RGB "Powered by: " -FC "Gray" -NoNewline
            Write-RGB $response.Headers.'X-Powered-By' -FC "Magenta"
        }

        # Проверяем безопасность заголовков
        $securityHeaders = @(
            'X-Frame-Options',
            'X-Content-Type-Options',
            'Strict-Transport-Security',
            'Content-Security-Policy'
        )

        $missingHeaders = $securityHeaders | Where-Object { -not $response.Headers.$_ }
        if ($missingHeaders) {
            Write-RGB "    ⚠️  " -FC "Yellow" -NoNewline
            Write-RGB "Missing security headers: " -FC "Yellow" -NoNewline
            Write-RGB ($missingHeaders -join ", ") -FC "Red"

            $script:ScanStats.Vulnerabilities += @{
                Type = "Missing Security Headers"
                Target = "${Target}:${Port}"
                Details = $missingHeaders
            }
        }

        # Пробуем найти интересные пути
        $interestingPaths = @(
            '/.git/config',
            '/.env',
            '/admin',
            '/api',
            '/swagger',
            '/.well-known/security.txt'
        )

        Write-RGB "    🔍 " -FC "Blue" -NoNewline
        Write-RGB "Checking paths..." -FC "Gray"

        foreach ($path in $interestingPaths) {
            try {
                $checkUrl = "${uri}${path}"
                $pathResponse = Invoke-AdvancedWebRequest -Uri $checkUrl -TimeoutSec 2 -Method HEAD -ErrorAction SilentlyContinue

                if ($pathResponse.StatusCode -lt 400) {
                    Write-RGB "      💎 " -FC "Yellow" -NoNewline
                    Write-RGB "Found: " -FC "Green" -NoNewline
                    Write-RGB $path -FC "Cyan" -NoNewline
                    Write-RGB " [$($pathResponse.StatusCode)]" -FC "Gray"
                }
            } catch {}
        }

    } catch {
        Write-RGB "    ❌ " -FC "Red" -NoNewline
        Write-RGB "HTTP check failed: $($_.Exception.Message)" -FC "DarkRed"
    }
}

function Test-HttpsServer {
    param($Target, $Port)

    Write-RGB "`n  🔒 " -FC "Green" -NoNewline
    Write-RGB "Проверяем HTTPS/SSL на порту $Port..." -FC "Cyan"

    try {
        # Проверяем сертификат
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($Target, $Port)

        $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, {$true})
        $sslStream.AuthenticateAsClient($Target)

        $cert = $sslStream.RemoteCertificate
        $cert2 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($cert)

        Write-RGB "    ✓ " -FC "Green" -NoNewline
        Write-RGB "Issuer: " -FC "Gray" -NoNewline
        Write-RGB $cert2.Issuer -FC "Yellow"

        Write-RGB "    ✓ " -FC "Green" -NoNewline
        Write-RGB "Valid until: " -FC "Gray" -NoNewline

        $daysLeft = ($cert2.NotAfter - (Get-Date)).Days
        $dateColor = if ($daysLeft -lt 30) { "Red" } elseif ($daysLeft -lt 90) { "Yellow" } else { "Green" }
        Write-RGB "$($cert2.NotAfter.ToString('yyyy-MM-dd')) ($daysLeft days)" -FC $dateColor

        Write-RGB "    ✓ " -FC "Green" -NoNewline
        Write-RGB "Protocol: " -FC "Gray" -NoNewline
        Write-RGB $sslStream.SslProtocol -FC "Cyan"

        Write-RGB "    ✓ " -FC "Green" -NoNewline
        Write-RGB "Cipher: " -FC "Gray" -NoNewline
        Write-RGB "$($sslStream.CipherAlgorithm) ($($sslStream.CipherStrength) bits)" -FC "Magenta"

        $tcpClient.Close()

    } catch {
        Write-RGB "    ❌ " -FC "Red" -NoNewline
        Write-RGB "SSL check failed: $($_.Exception.Message)" -FC "DarkRed"
    }
}

function Test-DatabaseServer {
    param($PortInfo)

    $dbType = switch ($PortInfo.Port) {
        3306 { "MySQL/MariaDB" }
        5432 { "PostgreSQL" }
        1433 { "MS SQL Server" }
        1521 { "Oracle" }
        default { "Unknown" }
    }

    Write-RGB "`n  🗄️  " -FC "Blue" -NoNewline
    Write-RGB "Обнаружена база данных: " -FC "Cyan" -NoNewline
    Write-RGB $dbType -FC "Yellow" -Style Bold

    # Проверяем анонимный доступ
    Write-RGB "    🔐 " -FC "Red" -NoNewline
    Write-RGB "Checking anonymous access..." -FC "Gray"

    # Здесь можно добавить специфичные проверки для каждой БД
    switch ($PortInfo.Port) {
        3306 {
            # MySQL проверки
            try {
                $tcpClient = New-Object System.Net.Sockets.TcpClient
                $tcpClient.Connect($PortInfo.Target, $PortInfo.Port)
                $stream = $tcpClient.GetStream()

                # Читаем приветствие MySQL
                $buffer = New-Object byte[] 1024
                $read = $stream.Read($buffer, 0, 1024)

                if ($read -gt 0) {
                    $greeting = [System.Text.Encoding]::ASCII.GetString($buffer, 0, $read)
                    if ($greeting -match 'mysql|mariadb') {
                        Write-RGB "      ℹ️  " -FC "Blue" -NoNewline
                        Write-RGB "MySQL version detected in banner" -FC "Cyan"
                    }
                }

                $tcpClient.Close()
            } catch {}
        }
    }
}

function Format-NmapPort {
    param($Port)

    $stateColor = switch ($Port.State) {
        'open' { 'Green' }
        'closed' { 'Red' }
        'filtered' { 'Yellow' }
        default { 'Gray' }
    }

    $serviceIcon = switch -Regex ($Port.Service) {
        'http' { '🌐' }
        'https|ssl' { '🔒' }
        'ssh' { '🔑' }
        'ftp' { '📁' }
        'smtp|mail' { '📧' }
        'mysql|postgres|mssql|oracle' { '🗄️' }
        'rdp|vnc' { '🖥️' }
        'smb|netbios' { '🗂️' }
        default { '📡' }
    }

    Write-RGB "  $serviceIcon " -FC $stateColor -NoNewline
    Write-RGB ("{0,5}/{1}" -f $Port.Port, $Port.Protocol) -FC "Cyan" -NoNewline
    Write-RGB " │ " -FC "DarkGray" -NoNewline
    Write-RGB ("{0,-10}" -f $Port.State) -FC $stateColor -Style Bold -NoNewline
    Write-RGB " │ " -FC "DarkGray" -NoNewline
    Write-RGB ("{0,-15}" -f $Port.Service) -FC "Yellow" -NoNewline

    if ($Port.Version) {
        Write-RGB " │ " -FC "DarkGray" -NoNewline
        Write-RGB $Port.Version -FC "Magenta"
    } else {
        Write-Host
    }
}

function Show-ScanSummary {
    Write-RGB "`n`n🏁 SCAN COMPLETE! 🏁" -FC "Cyan" -Style Bold
    Write-RGB ("═" * 60) -FC "DarkCyan"

    $duration = (Get-Date) - $script:ScanStats.StartTime

    # Основная статистика
    Write-RGB "`n📊 STATISTICS:" -FC "Yellow" -Style Bold
    Write-RGB "  ⏱️  Scan duration: " -FC "Gray" -NoNewline
    Write-RGB $duration.ToString() -FC "Cyan"

    Write-RGB "  ✅ Open ports: " -FC "Gray" -NoNewline
    Write-RGB $script:ScanStats.OpenPorts -FC "Green" -Style Bold

    # Топ сервисов
    if ($script:ScanStats.Services.Count -gt 0) {
        Write-RGB "`n🔝 TOP SERVICES:" -FC "Yellow" -Style Bold
        $script:ScanStats.Services.GetEnumerator() |
                Sort-Object Value -Descending |
                Select-Object -First 5 |
                ForEach-Object {
                    $bar = "█" * $_.Value
                    Write-RGB ("  {0,-15} {1} ({2})" -f $_.Key, $bar, $_.Value) -FC "Cyan"
                }
    }

    # HTTP серверы
    if ($script:ScanStats.HttpServers.Count -gt 0) {
        Write-RGB "`n🌐 WEB SERVERS:" -FC "Blue" -Style Bold
        $script:ScanStats.HttpServers | ForEach-Object {
            Write-RGB "  • Port " -FC "Gray" -NoNewline
            Write-RGB $_.Port -FC "Cyan" -NoNewline
            Write-RGB " - " -FC "Gray" -NoNewline
            Write-RGB $_.Service -FC "Yellow"
        }
    }

    # Базы данных
    if ($script:ScanStats.Databases.Count -gt 0) {
        Write-RGB "`n🗄️  DATABASES:" -FC "Magenta" -Style Bold
        $script:ScanStats.Databases | ForEach-Object {
            Write-RGB "  • Port " -FC "Gray" -NoNewline
            Write-RGB $_.Port -FC "Cyan" -NoNewline
            Write-RGB " - " -FC "Gray" -NoNewline
            Write-RGB $_.Service -FC "Yellow"
        }
    }

    # Уязвимости
    if ($script:ScanStats.Vulnerabilities.Count -gt 0) {
        Write-RGB "`n⚠️  POTENTIAL ISSUES:" -FC "Red" -Style Bold
        $script:ScanStats.Vulnerabilities | ForEach-Object {
            Write-RGB "  • " -FC "Red" -NoNewline
            Write-RGB $_.Type -FC "Yellow" -NoNewline
            Write-RGB " on " -FC "Gray" -NoNewline
            Write-RGB $_.Target -FC "Cyan"
        }
    }

    # Рекомендации
    Write-RGB "`n🤖 RECOMMENDATIONS:" -FC "Magenta" -Style Bold

    if ($script:ScanStats.OpenPorts -gt 50) {
        Write-RGB "  ⚠️  Many open ports detected. Consider firewall hardening." -FC "Yellow"
    }

    if ($script:ScanStats.Databases.Count -gt 0) {
        Write-RGB "  🔒 Database services exposed. Ensure strong authentication." -FC "Yellow"
    }

    if ($script:ScanStats.HttpServers.Count -gt 0) {
        Write-RGB "  🌐 Web services found. Run web vulnerability scanner." -FC "Cyan"
    }

    Write-RGB "`n" -FC "White"
    Write-RGB ("═" * 60) -FC "DarkCyan"
}

# Улучшенный Invoke-WebRequest с retry и прогрессом
function Invoke-AdvancedWebRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Uri,

        [string]$Method = 'GET',
        [int]$TimeoutSec = 30,
        [int]$RetryCount = 2,
        [hashtable]$Headers = @{},
        [switch]$SkipCertificateCheck
    )

    $attempt = 0
    $success = $false

    # Добавляем стандартные заголовки для избежания блокировок
    if (-not $Headers['User-Agent']) {
        $Headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) PowerShell/7.0 Security-Scanner/1.0'
    }

    while ($attempt -le $RetryCount -and -not $success) {
        try {
            $params = @{
                Uri = $Uri
                Method = $Method
                TimeoutSec = $TimeoutSec
                Headers = $Headers
                ErrorAction = 'Stop'
                UseBasicParsing = $true
            }

            if ($SkipCertificateCheck) {
                $params.SkipCertificateCheck = $true
            }

            $response = Invoke-WebRequest @params
            $success = $true
            return $response

        } catch {
            $attempt++
            if ($attempt -le $RetryCount) {
                Start-Sleep -Seconds 1
            } else {
                throw $_
            }
        }
    }
}
#endregion

# Экспорт функций
Export-ModuleMember -Function @(
    'Invoke-NmapScan',
    'Write-RGB',
    'Write-Status'
)

# Примеры использования:
Write-RGB @"

ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ:
━━━━━━━━━━━━━━━━━━━━━

# Базовое сканирование
Invoke-NmapScan -Target 192.168.1.1

# Сканирование с определением сервисов
Invoke-NmapScan -Target scanme.nmap.org -ServiceDetection -LiveAnalysis

# Агрессивное сканирование определённых портов
Invoke-NmapScan -Target 10.0.0.1 -Ports "80,443,3306,8080" -AggressiveScan

# Полное сканирование с определением ОС
Invoke-NmapScan -Target example.com -OSDetection -ServiceDetection -Ports "1-65535"

"@ -FC "DarkCyan"