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
    
    # Запускаем фоновое задание для периодического обновления
    $job = Start-Job -ScriptBlock {
        param($segmentPath, $interval)
        
        # Импортируем сегменты в фоновом задании
        Get-ChildItem -Path $segmentPath -Filter "*.ps1" -Exclude "SegmentUpdater.ps1" | ForEach-Object {
            . $_.FullName
        }
        
        while ($true) {
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
            
            Start-Sleep -Seconds $interval
        }
    } -ArgumentList $segmentPath, $IntervalSeconds
    
    # Сохраняем ID задания для возможности остановки
    $global:OmpUpdaterJob = $job
    
    Write-Host "OMP Segment Updater started (Job ID: $($job.Id))" -ForegroundColor Cyan
}

function Stop-OmpSegmentUpdater {
    if ($global:OmpUpdaterJob) {
        Stop-Job -Job $global:OmpUpdaterJob
        Remove-Job -Job $global:OmpUpdaterJob
        $global:OmpUpdaterJob = $null
        Write-Host "OMP Segment Updater stopped" -ForegroundColor Yellow
    }
}

# Функции для ручного обновления отдельных сегментов
function Update-WeatherSegment { $env:OMP_WEATHER = Get-WeatherSegment }
function Update-NetworkSegment { $env:OMP_NETWORK = Get-NetworkSegment }
function Update-SystemHealthSegment { $env:OMP_SYSTEM_HEALTH = Get-SystemHealthSegment }
function Update-DiskUsageSegment { $env:OMP_DISK_USAGE = Get-DiskUsageSegment }
function Update-ProcessInfoSegment { $env:OMP_PROCESS_INFO = Get-ProcessInfoSegment }

Export-ModuleMember -Function Update-OmpEnvironmentVariables, Start-OmpSegmentUpdater, Stop-OmpSegmentUpdater, Update-WeatherSegment, Update-NetworkSegment, Update-SystemHealthSegment, Update-DiskUsageSegment, Update-ProcessInfoSegment