# Data-Reader.ps1
# Функции для чтения данных из фонового демона

$global:DataFilePath = "${env:TEMP}\PSProfile_Data.json"
$global:CachedData = $null
$global:LastDataRead = $null

function Get-BackgroundData {
    param([switch]$Force)
    
    # Кэшируем данные на 5 секунд, чтобы не читать файл постоянно
    if (-not $Force -and $global:CachedData -and $global:LastDataRead -and ((Get-Date) - $global:LastDataRead).TotalSeconds -lt 5) {
        return $global:CachedData
    }
    
    try {
        if (Test-Path $global:DataFilePath) {
            $jsonContent = Get-Content $global:DataFilePath -Raw -Encoding UTF8
            $global:CachedData = $jsonContent | ConvertFrom-Json
            $global:LastDataRead = Get-Date
            return $global:CachedData
        } else {
            return @{
                Weather = @{ Status = "NoData"; Message = "Daemon not started" }
                System = @{ Status = "NoData"; Message = "Daemon not started" }
            }
        }
    } catch {
        return @{
            Weather = @{ Status = "Error"; Error = $_.ToString() }
            System = @{ Status = "Error"; Error = $_.ToString() }
        }
    }
}

function Get-WeatherInfo {
    param([switch]$Detailed)
    
    $data = Get-BackgroundData
    $weather = $data.Weather
    
    if ($weather.Status -eq "Success") {
        if ($Detailed) {
            return @{
                Temperature = "$($weather.Temperature)°C"
                Description = $weather.Description
                Humidity = "$($weather.Humidity)%"
                Pressure = "$($weather.Pressure) hPa"
                WindSpeed = "$($weather.WindSpeed) м/с"
                Location = "$($weather.City), $($weather.Country)"
                LastUpdate = $weather.UpdateTime
            }
        } else {
            return "$($weather.Temperature)°C, $($weather.Description)"
        }
    } else {
        return if ($weather.Status -eq "Error") { "Weather Error" } else { "Weather Loading..." }
    }
}

function Get-SystemInfo {
    param([switch]$Detailed)
    
    $data = Get-BackgroundData
    $system = $data.System
    
    if ($system.Status -eq "Success") {
        if ($Detailed) {
            return @{
                CPU = "$($system.CPU)%"
                Memory = "$($system.MemoryUsed)/$($system.MemoryTotal) GB ($($system.MemoryPercent)%)"
                LastUpdate = $system.UpdateTime
            }
        } else {
            return "CPU: $($system.CPU)% | RAM: $($system.MemoryPercent)%"
        }
    } else {
        return if ($system.Status -eq "Error") { "System Error" } else { "System Loading..." }
    }
}

function Start-BackgroundDaemon {
    param(
        [int]$WeatherInterval = 300,  # 5 минут
        [int]$SystemInterval = 60,    # 1 минута
        [switch]$Verbose
    )
    
    # Проверяем, не запущен ли уже демон
    $existingJob = Get-Job -Name "PSProfileDaemon" -ErrorAction SilentlyContinue
    if ($existingJob) {
        Write-Host "Background daemon already running (Job ID: $($existingJob.Id))" -ForegroundColor Yellow
        return $existingJob
    }
    
    # Запускаем демон
    $daemonScript = "${PSScriptRoot}\Background-Daemon.ps1"
    $verboseFlag = if ($Verbose) { "-Verbose" } else { "" }
    
    $job = Start-ThreadJob -Name "PSProfileDaemon" -ScriptBlock {
        param($ScriptPath, $WeatherInterval, $SystemInterval, $VerboseFlag)
        
        $params = @{
            WeatherInterval = $WeatherInterval
            SystemInterval = $SystemInterval
        }
        if ($VerboseFlag) { $params.Verbose = $true }
        
        & $ScriptPath @params
    } -ArgumentList $daemonScript, $WeatherInterval, $SystemInterval, $Verbose
    
    Write-Host "🚀 Background daemon started (Job ID: $($job.Id))" -ForegroundColor Green
    Write-Host "   Weather updates every $WeatherInterval seconds" -ForegroundColor Cyan
    Write-Host "   System updates every $SystemInterval seconds" -ForegroundColor Cyan
    
    return $job
}

function Stop-BackgroundDaemon {
    # Создаем флаг остановки
    "stop" | Out-File -FilePath "${env:TEMP}\PSProfile_Stop.flag" -Force
    
    # Ждем завершения
    $job = Get-Job -Name "PSProfileDaemon" -ErrorAction SilentlyContinue
    if ($job) {
        Write-Host "Stopping background daemon..." -ForegroundColor Yellow
        Wait-Job $job -Timeout 10
        Remove-Job $job -Force
        Write-Host "✅ Background daemon stopped" -ForegroundColor Green
    }
    
    # Очищаем файлы
    if (Test-Path $global:DataFilePath) {
        Remove-Item $global:DataFilePath -Force
    }
}

function Get-DaemonStatus {
    $job = Get-Job -Name "PSProfileDaemon" -ErrorAction SilentlyContinue
    $data = Get-BackgroundData
    
    $status = @{
        JobRunning = $job -ne $null -and $job.State -eq "Running"
        JobState = if ($job) { $job.State } else { "Not Started" }
        JobId = if ($job) { $job.Id } else { "N/A" }
        DataFileExists = Test-Path $global:DataFilePath
        WeatherStatus = $data.Weather.Status
        SystemStatus = $data.System.Status
        LastUpdate = $data.LastUpdate
        DaemonStart = $data.DaemonStart
    }
    
    return $status
}

# Экспортируем функции
Export-ModuleMember -Function Get-WeatherInfo, Get-SystemInfo, Start-BackgroundDaemon, Stop-BackgroundDaemon, Get-DaemonStatus, Get-BackgroundData