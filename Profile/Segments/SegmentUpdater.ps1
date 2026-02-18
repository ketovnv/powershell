Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

# Главный скрипт для обновления переменных окружения для Oh My Posh сегментов

# Импортируем все сегменты
$segmentPath = $PSScriptRoot
Get-ChildItem -Path $segmentPath -Filter "*.ps1" -Exclude "SegmentUpdater.ps1" | ForEach-Object {
    . $_.FullName
}

function Update-OmpEnvironmentVariables {
    try {
        # Обновляем переменные окружения
        $env:OMP_WEATHER = Get-WeatherSegment -ErrorAction SilentlyContinue
        $env:OMP_NETWORK = Get-NetworkSegment -ErrorAction SilentlyContinue  
        $env:OMP_SYSTEM_HEALTH = Get-SystemHealthSegment -ErrorAction SilentlyContinue
        $env:OMP_DISK_USAGE = Get-DiskUsageSegment -ErrorAction SilentlyContinue
        $env:OMP_PROCESS_INFO = Get-ProcessInfoSegment -ErrorAction SilentlyContinue
        
        # Добавляем timestamp последнего обновления
        $env:OMP_LAST_UPDATE = Get-Date -Format "HH:mm:ss"
        
        Write-Host "OMP segments updated at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Green
    }
    catch {
        Write-Warning "Error updating OMP segments: $($_.Exception.Message)"
    }
}

function Start-OmpSegmentUpdater {
    param(
        [int]$IntervalSeconds = 30
    )

    # Первоначальное обновление
    Update-OmpEnvironmentVariables

    # Используем System.Timers.Timer — колбэк выполняется в текущем процессе,
    # поэтому изменения $env:OMP_* видны Oh My Posh
    $timer = [System.Timers.Timer]::new($IntervalSeconds * 1000)
    $timer.AutoReset = $true

    Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action {
        try {
            $env:OMP_WEATHER = Get-WeatherSegment -ErrorAction SilentlyContinue
            $env:OMP_NETWORK = Get-NetworkSegment -ErrorAction SilentlyContinue
            $env:OMP_SYSTEM_HEALTH = Get-SystemHealthSegment -ErrorAction SilentlyContinue
            $env:OMP_DISK_USAGE = Get-DiskUsageSegment -ErrorAction SilentlyContinue
            $env:OMP_PROCESS_INFO = Get-ProcessInfoSegment -ErrorAction SilentlyContinue
            $env:OMP_LAST_UPDATE = Get-Date -Format "HH:mm:ss"
        }
        catch {
            # Тихо игнорируем ошибки в фоновом режиме
        }
    } | Out-Null

    $timer.Start()
    $global:OmpUpdaterTimer = $timer

    Write-Host "OMP Segment Updater started (Timer interval: ${IntervalSeconds}s)" -ForegroundColor Cyan
}

function Stop-OmpSegmentUpdater {
    if ($global:OmpUpdaterTimer) {
        $global:OmpUpdaterTimer.Stop()
        $global:OmpUpdaterTimer.Dispose()
        $global:OmpUpdaterTimer = $null
        Write-Host "OMP Segment Updater stopped" -ForegroundColor Yellow
    }
}

# Функции для ручного обновления отдельных сегментов
function Update-WeatherSegment { $env:OMP_WEATHER = Get-WeatherSegment }
function Update-NetworkSegment { $env:OMP_NETWORK = Get-NetworkSegment }
function Update-SystemHealthSegment { $env:OMP_SYSTEM_HEALTH = Get-SystemHealthSegment }
function Update-DiskUsageSegment { $env:OMP_DISK_USAGE = Get-DiskUsageSegment }
function Update-ProcessInfoSegment { $env:OMP_PROCESS_INFO = Get-ProcessInfoSegment }

Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))