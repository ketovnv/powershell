# для запуска из другого скрипта
# $watcher = "$env:USERPROFILE\Documents\PowerShell\scripts\WatcherHTML.ps1"
# if (Test-Path $watcher) {
# 	    Start-Job { powershell -ExecutionPolicy Bypass -File $using:watcher }
# 	    }



$logDir = "$env:USERPROFILE\Documents\WatcherLogs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }

$today = (Get-Date).ToString("yyyy-MM-dd")
$logPath = "$logDir\log_$today.html"

if (-not (Test-Path $logPath)) {
@"
<html><head>
  <style>
    body { font-family: Consolas; background: #111; color: #ccc; }
    .suspicious { color: red; font-weight: bold; }
    .ok { color: #7fff7f; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #444; padding: 4px; }
  </style>
</head><body>
<h2>🚨 Temp Execution Log</h2>
<table>
<tr><th>Time</th><th>PID</th><th>Executable</th><th>Command</th><th>IP</th><th>Port</th></tr>
"@ | Set-Content $logPath
}

function Append-LogHtml {
  param ($time, $pid, $exe, $cmd, $ip, $port)

  $rowClass = if ($exe -match 'Temp|AppData|Downloads' -or $ip -match '^(185|45|103|109)\.') {
    "suspicious"
  } else {
    "ok"
  }

  $escapedCmd = $cmd -replace '<', '&lt;' -replace '>', '&gt;'
  $line = "<tr class='$rowClass'><td>$time</td><td>$pid</td><td>$exe</td><td>$escapedCmd</td><td>$ip</td><td>$port</td></tr>"
  Add-Content $logPath $line
}

Import-Module PS-Menu

$menu = Menu -Title "🛡️ TROJAN WATCHER (HTML)" -MenuItems @(
  @{ Key = "1"; Label = "▶ Запустить LiveTempWatch + HTML"; Action = {
    Register-WmiEvent -Query "SELECT * FROM Win32_ProcessStartTrace" -SourceIdentifier "ProcStart" -Action {
      $proc = Get-Process -Id $Event.SourceEventArgs.NewEvent.ProcessID -ErrorAction SilentlyContinue
      $exe  = $Event.SourceEventArgs.NewEvent.ProcessName
      $cmd  = $Event.SourceEventArgs.NewEvent.CommandLine
      $pid  = $Event.SourceEventArgs.NewEvent.ProcessID
      $now  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
      $ip   = ""
      $port = ""

      $recentNet = Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 50 |
        Where-Object { $_.Id -eq 3 -and $_.Message -match "$pid" } |
        Select-Object -First 1

      if ($recentNet) {
        [xml]$x = $recentNet.ToXml()
        $data = $x.Event.EventData.Data
        $ip   = ($data | Where-Object {$_.Name -eq 'DestinationIp'}).'#text'
        $port = ($data | Where-Object {$_.Name -eq 'DestinationPort'}).'#text'
      }

      if ($cmd -match 'Temp|AppData|Downloads') {
        Append-LogHtml -time $now -pid $pid -exe $exe -cmd $cmd -ip $ip -port $port
        Write-Host "`n🚨 [$pid] $exe ← $cmd" -ForegroundColor Red
      }
    }
    Write-Host "▶ LiveTempWatch запущен." -ForegroundColor Green
  }},

  @{ Key = "2"; Label = "⏹ Остановить LiveTempWatch"; Action = {
    Unregister-Event -SourceIdentifier "ProcStart" -ErrorAction SilentlyContinue
    Write-Host "🛑 LiveTempWatch остановлен." -ForegroundColor Yellow
  }},

  @{ Key = "3"; Label = "📂 Открыть HTML-лог в браузере"; Action = {
    Start-Process $logPath
  }},

  @{ Key = "0"; Label = "🚪 Выход"; Action = { return } }
)

$menu.Run()
