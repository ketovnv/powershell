importProcess  $MyInvocation.MyCommand.Name.trim('.ps1') -start

# Команды для управления Oh My Posh кастомными сегментами

function Show-OmpSegments {
    <#
    .SYNOPSIS
    Показывает текущие значения всех кастомных сегментов
    #>
    Write-Host "`n🎨 Oh My Posh Custom Segments Status" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Cyan
    
    $segments = @{
        "Weather" = $env:OMP_WEATHER
        "Network" = $env:OMP_NETWORK  
        "System Health" = $env:OMP_SYSTEM_HEALTH
        "Disk Usage" = $env:OMP_DISK_USAGE
        "Process Info" = $env:OMP_PROCESS_INFO
        "Last Update" = $env:OMP_LAST_UPDATE
    }
    
    foreach ($segment in $segments.GetEnumerator()) {
        $value = if ($segment.Value) { $segment.Value } else { "Not set" }
        Write-Host "$($segment.Key): " -NoNewline -ForegroundColor Yellow
        Write-Host $value -ForegroundColor White
    }
    Write-Host ""
}

function Reset-OmpSegments {
    <#
    .SYNOPSIS
    Сбрасывает все переменные сегментов и перезапускает updater
    #>
    Write-Host "🔄 Resetting OMP segments..." -ForegroundColor Yellow
    
    # Останавливаем старый updater
    Stop-OmpSegmentUpdater
    
    # Очищаем переменные
    $env:OMP_WEATHER = $null
    $env:OMP_NETWORK = $null
    $env:OMP_SYSTEM_HEALTH = $null
    $env:OMP_DISK_USAGE = $null
    $env:OMP_PROCESS_INFO = $null
    $env:OMP_LAST_UPDATE = $null
    
    # Перезапускаем
    Start-OmpSegmentUpdater -IntervalSeconds 30
    
    Write-Host "✅ OMP segments reset complete" -ForegroundColor Green
}

function Test-OmpSegments {
    <#
    .SYNOPSIS
    Тестирует каждый сегмент индивидуально
    #>
    Write-Host "`n🧪 Testing OMP Segments" -ForegroundColor Cyan
    Write-Host "=" * 30 -ForegroundColor Cyan
    
    Write-Host "Testing Weather segment..." -ForegroundColor Yellow
    try {
        $weather = Get-WeatherSegment
        Write-Host "✅ Weather: $weather" -ForegroundColor Green
    } catch {
        Write-Host "❌ Weather failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "Testing Network segment..." -ForegroundColor Yellow
    try {
        $network = Get-NetworkSegment
        Write-Host "✅ Network: $network" -ForegroundColor Green
    } catch {
        Write-Host "❌ Network failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "Testing System Health segment..." -ForegroundColor Yellow
    try {
        $health = Get-SystemHealthSegment
        Write-Host "✅ System Health: $health" -ForegroundColor Green
    } catch {
        Write-Host "❌ System Health failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "Testing Disk Usage segment..." -ForegroundColor Yellow
    try {
        $disk = Get-DiskUsageSegment
        Write-Host "✅ Disk Usage: $disk" -ForegroundColor Green
    } catch {
        Write-Host "❌ Disk Usage failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "Testing Process Info segment..." -ForegroundColor Yellow
    try {
        $process = Get-ProcessInfoSegment
        Write-Host "✅ Process Info: $process" -ForegroundColor Green
    } catch {
        Write-Host "❌ Process Info failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Set-WeatherApiKey {
    <#
    .SYNOPSIS
    Устанавливает API ключ для Weather сегмента
    .PARAMETER ApiKey
    API ключ от OpenWeatherMap
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ApiKey
    )
    
    $env:WEATHER_API_KEY = $ApiKey
    Write-Host "✅ Weather API key set. Updating weather segment..." -ForegroundColor Green
    Update-WeatherSegment
}

function Show-OmpHelp {
    <#
    .SYNOPSIS
    Показывает справку по командам OMP сегментов
    #>
    Write-Host "`n📚 Oh My Posh Custom Segments Commands" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Cyan
    
    $commands = @(
        @{ Name = "Show-OmpSegments"; Description = "Показать текущие значения всех сегментов" }
        @{ Name = "Reset-OmpSegments"; Description = "Сбросить и перезапустить все сегменты" }
        @{ Name = "Test-OmpSegments"; Description = "Протестировать каждый сегмент" }
        @{ Name = "Update-WeatherSegment"; Description = "Обновить сегмент погоды" }
        @{ Name = "Update-NetworkSegment"; Description = "Обновить сегмент сети" }
        @{ Name = "Update-SystemHealthSegment"; Description = "Обновить сегмент системы" }
        @{ Name = "Update-DiskUsageSegment"; Description = "Обновить сегмент диска" }
        @{ Name = "Update-ProcessInfoSegment"; Description = "Обновить сегмент процессов" }
        @{ Name = "Set-WeatherApiKey"; Description = "Установить API ключ для погоды" }
        @{ Name = "Start-OmpSegmentUpdater"; Description = "Запустить фоновое обновление" }
        @{ Name = "Stop-OmpSegmentUpdater"; Description = "Остановить фоновое обновление" }
    )
    
    foreach ($cmd in $commands) {
        Write-Host "$($cmd.Name)" -ForegroundColor Yellow -NoNewline
        Write-Host " - $($cmd.Description)" -ForegroundColor White
    }
    
    Write-Host "`n💡 Tip: Установите WEATHER_API_KEY для получения реальной погоды:" -ForegroundColor Magenta
    Write-Host "Set-WeatherApiKey 'your_api_key_here'" -ForegroundColor Gray
    Write-Host "API ключ можно получить бесплатно на openweathermap.org" -ForegroundColor Gray
}

# Алиасы для удобства
Set-Alias -Name omps -Value Show-OmpSegments
Set-Alias -Name ompr -Value Reset-OmpSegments
Set-Alias -Name ompt -Value Test-OmpSegments
Set-Alias -Name omph -Value Show-OmpHelp

Export-ModuleMember -Function Show-OmpSegments, Reset-OmpSegments, Test-OmpSegments, Set-WeatherApiKey, Show-OmpHelp -Alias omps, ompr, ompt, omph

importProcess  $MyInvocation.MyCommand.Name.trim('.ps1')