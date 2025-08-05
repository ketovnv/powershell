Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

function Get-ProcessInfoSegment {
    try {
        # Количество запущенных процессов
        $processCount = (Get-Process).Count
        
        # Топ процесс по CPU (если доступно)
        $topProcess = Get-Process | Sort-Object CPU -Descending | Select-Object -First 1
        
        # Топ процесс по памяти
        $topMemProcess = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 1
        $topMemMB = [math]::Round($topMemProcess.WorkingSet / 1MB, 0)
        
        # Проверяем критичные процессы
        $criticalProcesses = @("dwm", "winlogon", "csrss", "lsass")
        $criticalRunning = $criticalProcesses | ForEach-Object { 
            if (Get-Process -Name $_ -ErrorAction SilentlyContinue) { $true } else { $false }
        }
        
        $healthIcon = if ($criticalRunning -contains $false) { "⚠️" } else { "✅" }
        
        return "$healthIcon $processCount proc | Top: $($topMemProcess.ProcessName) ($topMemMB MB)"
    }
    catch {
        return "⚙️ Process info unavailable"
    }
}

Export-ModuleMember -Function Get-ProcessInfoSegment

Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))