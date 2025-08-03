importProcess  $MyInvocation.MyCommand.Name.trim('.ps1') -start

function Get-DiskUsageSegment {
    try {
        # Получаем информацию о диске C:
        $disk = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
        
        if ($disk) {
            $usedPercent = [math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100, 0)
            $freeGB = [math]::Round($disk.FreeSpace / 1GB, 1)
            
            $icon = if ($usedPercent -gt 90) { "🔴" } 
                   elseif ($usedPercent -gt 80) { "🟡" } 
                   elseif ($usedPercent -gt 70) { "🟠" }
                   else { "🟢" }
            
            return "$icon $usedPercent% ($freeGB GB free)"
        } else {
            return "💾 N/A"
        }
    }
    catch {
        return "💾 Error"
    }
}

Export-ModuleMember -Function Get-DiskUsageSegment

importProcess  $MyInvocation.MyCommand.Name.trim('.ps1')