# importProcess  $MyInvocation.MyCommand.Name.trim('.ps1') -start
Write-Host "[Background] Background initialization started" -ForegroundColor Cyan
# Background-Init.ps1
# Файл для тяжелых модулей, загружаемых в фоновом режиме

param(
    [switch]$Verbose
)

if ($Verbose) {
    Write-Host "[Background] Начинаем фоновую инициализацию..." -ForegroundColor Yellow
}

try {
    # Предварительная загрузка данных (не функций!)
    if ($Verbose) { Write-Host "[Background] Предзагружаем погодные данные..." -ForegroundColor Cyan }
    
    # Загружаем погоду заранее
    $weatherData = $null
    try {
        $weatherUrl = "http://api.openweathermap.org/data/2.5/weather?q=Kiev&appid=bd0d5e697cb1c55014d0f8d84d96700b&units=metric&lang=ru"
        $weatherData = Invoke-RestMethod -Uri $weatherUrl -TimeoutSec 5
        if ($Verbose) { Write-Host "[Background] ✅ Погода предзагружена" -ForegroundColor Green }
    } catch {
        if ($Verbose) { Write-Host "[Background] ⚠️ Не удалось предзагрузить погоду: $_" -ForegroundColor Yellow }
    }
    
    # Предзагружаем системную информацию
    if ($Verbose) { Write-Host "[Background] Предзагружаем системную информацию..." -ForegroundColor Cyan }
    $systemInfo = @{
        OS = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
        RAM = [math]::Round((Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2)
        CPU = (Get-CimInstance -ClassName Win32_Processor).Name
        LoadTime = Get-Date
    }
    
    if ($Verbose) {
        Write-Host "[Background] ✅ Фоновая инициализация завершена успешно" -ForegroundColor Green
    }
    
    # Возвращаем данные (они будут доступны через Receive-Job)
    return @{
        Weather = $weatherData
        SystemInfo = $systemInfo
        Status = "Success"
    }
    
} catch {
    if ($Verbose) {
        Write-Host "[Background] ❌ Ошибка при фоновой инициализации: $_" -ForegroundColor Red
    }
    return @{
        Weather = $null
        SystemInfo = $null
        Status = "Error"
        Error = $_.ToString()
    }
}

# importProcess  $MyInvocation.MyCommand.Name.trim('.ps1')