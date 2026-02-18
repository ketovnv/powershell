Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

function Get-SystemHealthSegment {
    try {
        # CPU загрузка (последние 5 секунд)
        $cpu = Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 1 | 
                Select-Object -ExpandProperty CounterSamples | 
                Select-Object -ExpandProperty CookedValue
        $cpuPercent = [math]::Round($cpu, 0)
        
        # Память
        $memory = Get-CimInstance -ClassName Win32_OperatingSystem
        $memUsed = [math]::Round((($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / $memory.TotalVisibleMemorySize) * 100, 0)
        
        # Температура (если доступно)
        $temp = try {
            $tempSensor = Get-CimInstance -ClassName MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" -ErrorAction SilentlyContinue
            if ($tempSensor) {
                $tempC = [math]::Round(($tempSensor[0].CurrentTemperature / 10) - 273.15, 0)
                if ($tempC -gt 0 -and $tempC -lt 100) { "$tempC°C" } else { "" }
            } else { "" }
        } catch { "" }
        
        # Определяем общий статус
        $cpuIcon = if ($cpuPercent -gt 80) { "🔥" } elseif ($cpuPercent -gt 60) { "⚡" } else { "💚" }
        $memIcon = if ($memUsed -gt 85) { "🔴" } elseif ($memUsed -gt 70) { "🟡" } else { "🟢" }
        
        $result = "$cpuIcon$cpuPercent% $memIcon$memUsed%"
        if ($temp) { $result += " 🌡️$temp" }
        
        return $result
    }
    catch {
        return "💚 OK"
    }
}


Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))