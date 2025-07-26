function Get-NetworkSegment {
    try {
        # Проверяем активные подключения
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        $internetTest = Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        
        if (-not $adapters) {
            return "📡 Offline"
        }
        
        $wifiAdapter = $adapters | Where-Object { $_.PhysicalMediaType -eq "Native 802.11" }
        $ethernetAdapter = $adapters | Where-Object { $_.PhysicalMediaType -eq "802.3" }
        
        $connectionType = if ($ethernetAdapter) { "🖥️" } elseif ($wifiAdapter) { "📶" } else { "🔌" }
        
        if ($internetTest) {
            # Проверяем скорость (упрощенно через пинг)
            $ping = Test-NetConnection -ComputerName "8.8.8.8" -InformationLevel Quiet
            $status = if ($ping) { "Online" } else { "Limited" }
            return "$connectionType $status"
        } else {
            return "$connectionType Limited"
        }
    }
    catch {
        return "📡 Unknown"
    }
}

Export-ModuleMember -Function Get-NetworkSegment