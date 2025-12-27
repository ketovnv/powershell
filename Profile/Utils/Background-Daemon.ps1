# Background-Daemon.ps1
# Постоянный фоновый демон для обновления данных

param(
    [string]$DataPath = "${env:TEMP}\PSProfile_Data.json",
    [int]$WeatherInterval = 300,    # 5 минут
    [int]$SystemInterval = 60,      # 1 минута
    [switch]$Verbose
)

function Write-Log {
    param([string]$Message, [string]$Level = "Info")
    if ($Verbose) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        $color = switch ($Level) {
            "Error" { "Red" }
            "Warning" { "Yellow" }
            "Success" { "Green" }
            default { "Cyan" }
        }
        Write-Host "[$timestamp] [Daemon] $Message" -ForegroundColor $color
    }
}

function Get-WeatherData {
    try {
        $weatherUrl = "http://api.openweathermap.org/data/2.5/weather?q=Kiev&appid=bd0d5e697cb1c55014d0f8d84d96700b&units=metric&lang=ru"
        $weather = Invoke-RestMethod -Uri $weatherUrl -TimeoutSec 10
        Write-Log "Weather data updated successfully" "Success"
        return @{
            Temperature = [math]::Round($weather.main.temp, 1)
            Description = $weather.weather[0].description
            Humidity = $weather.main.humidity
            Pressure = $weather.main.pressure
            WindSpeed = $weather.wind.speed
            City = $weather.name
            Country = $weather.sys.country
            UpdateTime = Get-Date
            Status = "Success"
        }
    } catch {
        Write-Log "Failed to get weather: $_" "Error"
        return @{
            Status = "Error"
            Error = $_.ToString()
            UpdateTime = Get-Date
        }
    }
}

function Get-SystemData {
    try {
        # Быстрые системные данные
        $cpu = Get-Counter "\Processor(_Total)\% Processor Time" | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue
        $memory = Get-CimInstance -ClassName Win32_OperatingSystem
        $memoryUsed = [math]::Round(($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / 1KB, 2)
        $memoryTotal = [math]::Round($memory.TotalVisibleMemorySize / 1KB, 2)
        
        Write-Log "System data updated successfully" "Success"
        return @{
            CPU = [math]::Round($cpu, 1)
            MemoryUsed = $memoryUsed
            MemoryTotal = $memoryTotal
            MemoryPercent = [math]::Round(($memoryUsed / $memoryTotal) * 100, 1)
            UpdateTime = Get-Date
            Status = "Success"
        }
    } catch {
        Write-Log "Failed to get system data: $_" "Error"
        return @{
            Status = "Error"
            Error = $_.ToString()
            UpdateTime = Get-Date
        }
    }
}

function Save-Data {
    param([hashtable]$Data)
    try {
        $json = $Data | ConvertTo-Json -Depth 3
        $json | Out-File -FilePath $DataPath -Encoding UTF8 -Force
        Write-Log "Data saved to $DataPath"
    } catch {
        Write-Log "Failed to save data: $_" "Error"
    }
}

# Инициализация данных
$data = @{
    Weather = @{ Status = "Initializing"; UpdateTime = Get-Date }
    System = @{ Status = "Initializing"; UpdateTime = Get-Date }
    DaemonStart = Get-Date
    LastUpdate = Get-Date
}

Write-Log "Background daemon started" "Success"
Write-Log "Weather update interval: $WeatherInterval seconds"
Write-Log "System update interval: $SystemInterval seconds"
Write-Log "Data file: $DataPath"

# Сразу получаем начальные данные
$data.Weather = Get-WeatherData
$data.System = Get-SystemData
Save-Data $data

$weatherTimer = 0
$systemTimer = 0

# Основной цикл демона
while ($true) {
    Start-Sleep -Seconds 10  # Основной цикл каждые 10 секунд
    
    $weatherTimer += 10
    $systemTimer += 10
    
    $updated = $false
    
    # Обновляем погоду
    if ($weatherTimer -ge $WeatherInterval) {
        $data.Weather = Get-WeatherData
        $weatherTimer = 0
        $updated = $true
    }
    
    # Обновляем системные данные
    if ($systemTimer -ge $SystemInterval) {
        $data.System = Get-SystemData
        $systemTimer = 0
        $updated = $true
    }
    
    # Сохраняем если что-то обновилось
    if ($updated) {
        $data.LastUpdate = Get-Date
        Save-Data $data
    }
    
    # Проверяем файл стопа
    if (Test-Path "${env:TEMP}\PSProfile_Stop.flag") {
        Write-Log "Stop flag detected, shutting down daemon" "Warning"
        Remove-Item "${env:TEMP}\PSProfile_Stop.flag" -Force
        break
    }
}

Write-Log "Background daemon stopped" "Warning"