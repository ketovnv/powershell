# Database Management Script for Windows 11
# PostgreSQL, Redis, NSSM Service Manager
# Автор: Для управления базами данных через Scoop + NSSM
#
# 👁️ ВАЖНО: Redis с NSSM и Cygwin paths
# При установке Redis как службы через NSSM НЕОБХОДИМО использовать
# относительный путь к redis.conf (просто "redis.conf"), а не полный Windows путь.
# Полные пути приводят к ошибке: '/cygdrive/c/...' и служба переходит в PAUSED.
# AppDirectory в NSSM должен быть установлен на папку с Redis, а AppParameters - только "redis.conf".

# ===== Пути к приложениям =====
$PG_DATA = "$env:USERPROFILE\Scoop\apps\postgresql\current\data"
$PG_BIN = "$env:USERPROFILE\Scoop\apps\postgresql\current\bin"
$REDIS_BIN = "$env:USERPROFILE\Scoop\apps\redis\current"
$REDIS_CONF = "$REDIS_BIN\redis.conf"
$BACKUP_DIR = "$env:USERPROFILE\pg_backups"



# ===== NSSM Service Manager =====

function Test-NSSMInstalled {
    $nssm = Get-Command nssm -ErrorAction SilentlyContinue
    return $null -ne $nssm
}

function Install-NSSMService {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServiceName,
        [Parameter(Mandatory=$true)]
        [string]$ExecutablePath,
        [string]$Arguments = "",
        [string]$DisplayName = "",
        [string]$Description = ""
    )

    if (-not (Test-NSSMInstalled)) {
        wrgb "⚠️  NSSM не установлен. Установка..." -FC "Yellow"
        scoop install nssm
    }

    wrgb "`n🔧 Установка службы $ServiceName через NSSM..." -FC "Cyan"

    # Удаляем службу если уже существует
    $existingService = Get-Service $ServiceName -ErrorAction SilentlyContinue
    if ($existingService) {
        wrgb "⚠️  Служба $ServiceName уже существует, удаляю..." -FC "Yellow"
        nssm stop $ServiceName
        nssm remove $ServiceName confirm
    }

    # Устанавливаем службу
    if ($Arguments) {
        nssm install $ServiceName $ExecutablePath $Arguments
    } else {
        nssm install $ServiceName $ExecutablePath
    }

    # Настраиваем службу
    if ($DisplayName) {
        nssm set $ServiceName DisplayName $DisplayName
    }
    if ($Description) {
        nssm set $ServiceName Description $Description
    }

    nssm set $ServiceName Start SERVICE_AUTO_START
    nssm set $ServiceName AppStdout "$env:TEMP\$ServiceName-stdout.log"
    nssm set $ServiceName AppStderr "$env:TEMP\$ServiceName-stderr.log"

    wrgb "✓ Служба $ServiceName установлена" -FC "Green"
}

function Remove-NSSMService {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServiceName
    )

    wrgb "`n🗑️  Удаление службы $ServiceName..." -FC "Cyan"

    $service = Get-Service $ServiceName -ErrorAction SilentlyContinue
    if ($service) {
        nssm stop $ServiceName
        nssm remove $ServiceName confirm
        wrgb "✓ Служба $ServiceName удалена" -FC "Green"
    } else {
        wrgb "⚠️  Служба $ServiceName не найдена" -FC "Yellow"
    }
}

function Get-NSSMServiceStatus {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServiceName
    )

    $service = Get-Service $ServiceName -ErrorAction SilentlyContinue
    if ($service) {
        wrgb "`n📊 Статус службы ${ServiceName}:" -FC "Cyan"
        wrgb "  Статус: $($service.Status)" -FC "White"
        wrgb "  Режим запуска: $($service.StartType)" -FC "White"
    } else {
        wrgb "⚠️  Служба $ServiceName не найдена" -FC "Yellow"
    }
}

# ===== PostgreSQL Management =====

function Get-PostgreSQLStatus {
    wrgbn "`n🔍 Проверка статуса PostgreSQL..." -FC "Cyan"

    # Проверяем службу NSSM
    $service = Get-Service PostgreSQL -ErrorAction SilentlyContinue
    if ($service) {
        wrgbn "  NSSM служба: $($service.Status)" -FC "Gray"
    }

    # Проверяем через pg_ctl
    $status = & "$PG_BIN\pg_ctl.exe" status -D $PG_DATA 2>&1
    if ($LASTEXITCODE -eq 0) {
        wrgbn "✓ PostgreSQL работает" -FC "Green"
        wrgb $status -FC "Gray"
    } else {
        wrgbn "✗ PostgreSQL не запущен" -FC "Red"
    }
}

function Start-PostgreSQL {
    wrgbn "🚀 Запуск PostgreSQL..." -FC "Cyan"

    & "$PG_BIN\pg_ctl.exe" start -D $PG_DATA
    if ($LASTEXITCODE -eq 0) {
        wrgbn "✓ PostgreSQL успешно запущен" -FC "Green"
    } else {
        wrgbn "✗ Ошибка при запуске PostgreSQL" -FC "Red"
    }

    Get-PostgreSQLStatus
}

function Start-PostgreSQLService {
    wrgb "`n🚀 Запуск PostgreSQL службы..." -FC "Cyan"

    $service = Get-Service PostgreSQL -ErrorAction SilentlyContinue
    if ($service) {
        Start-Service PostgreSQL
        wrgb "✓ PostgreSQL служба запущена" -FC "Green"
    } else {
        wrgb "⚠️  Служба не установлена." -FC "Yellow"
        wrgb "  Используйте: PSQL install-service" -FC "Yellow"
        return
    }

    Get-PostgreSQLStatus
}

function Stop-PostgreSQL {
    wrgb "`n⏹️  Остановка PostgreSQL..." -FC "Cyan"

    & "$PG_BIN\pg_ctl.exe" stop -D $PG_DATA -m fast
    if ($LASTEXITCODE -eq 0) {
        wrgb "✓ PostgreSQL остановлен" -FC "Green"
    } else {
        wrgb "✗ Ошибка при остановке PostgreSQL" -FC "Red"
    }
}

function Stop-PostgreSQLService {
    wrgb "`n⏹️  Остановка PostgreSQL службы..." -FC "Cyan"

    $service = Get-Service PostgreSQL -ErrorAction SilentlyContinue
    if ($service) {
        Stop-Service PostgreSQL
        wrgb "✓ PostgreSQL служба остановлена" -FC "Green"
    } else {
        wrgb "⚠️  Служба не установлена" -FC "Yellow"
    }
}

function Restart-PostgreSQL {
    wrgb "`n🔄 Перезапуск PostgreSQL..." -FC "Cyan"

    & "$PG_BIN\pg_ctl.exe" restart -D $PG_DATA -m fast
    if ($LASTEXITCODE -eq 0) {
        wrgb "✓ PostgreSQL перезапущен" -FC "Green"
    } else {
        wrgb "✗ Ошибка при перезапуске PostgreSQL" -FC "Red"
    }

    Get-PostgreSQLStatus
}

function Restart-PostgreSQLService {
    wrgb "`n🔄 Перезапуск PostgreSQL службы..." -FC "Cyan"

    $service = Get-Service PostgreSQL -ErrorAction SilentlyContinue
    if ($service) {
        Restart-Service PostgreSQL
        wrgb "✓ PostgreSQL служба перезапущена" -FC "Green"
    } else {
        wrgb "⚠️  Служба не установлена" -FC "Yellow"
    }

    Get-PostgreSQLStatus
}

function Install-PostgreSQLService {
    $pgExe = "$PG_BIN\postgres.exe"
    Install-NSSMService -ServiceName "PostgreSQL" `
                        -ExecutablePath $pgExe `
                        -Arguments "-D $PG_DATA" `
                        -DisplayName "PostgreSQL Database Server" `
                        -Description "PostgreSQL Database Server managed by NSSM"

    wrgb "`n✓ PostgreSQL настроен как служба Windows" -FC "Green"
    wrgb "  Используйте: PSQL start -service" -FC "Gray"
}

function Get-Users {
    wrgb "`n👥 Список пользователей и баз данных:" -FC "Cyan"
    & "$PG_BIN\psql.exe" -U postgres -c "\du"
    wrgb "`n📊 Список баз данных:" -FC "Cyan"
    & "$PG_BIN\psql.exe" -U postgres -c "\l"
}

function Backup-Database {
    wrgb "`n💾 Создание бэкапа..." -FC "Cyan"
    if (-not (Test-Path $BACKUP_DIR)) {
        New-Item -ItemType Directory -Path $BACKUP_DIR | Out-Null
        wrgb "✓ Создана директория бэкапов: $BACKUP_DIR" -FC "Green"
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = "$BACKUP_DIR\pg_backup_$timestamp.sql"

    & "$PG_BIN\pg_dumpall.exe" -U postgres -f $backupFile

    if ($LASTEXITCODE -eq 0) {
        $size = (Get-Item $backupFile).Length / 1MB
        wrgb "✓ Бэкап создан: $backupFile" -FC "Green"
        wrgb "  Размер: $([math]::Round($size, 2)) MB" -FC "Gray"
    } else {
        wrgb "✗ Ошибка при создании бэкапа" -FC "Red"
    }
}

function Show-PostgreSQLLogs {
    wrgb "`n📋 Последние 50 строк логов PostgreSQL:" -FC "Cyan"
    $logFile = Get-ChildItem "$PG_DATA\log" -Filter "*.log" -ErrorAction SilentlyContinue |
               Sort-Object LastWriteTime -Descending |
               Select-Object -First 1
    if ($logFile) {
        Get-Content $logFile.FullName -Tail 50
    } else {
        wrgb "✗ Лог файлы не найдены" -FC "Red"
    }
}

# ===== Redis Management =====

function Get-RedisStatus {
    wrgb "`n🔍 Проверка статуса Redis..." -FC "Cyan"

    # Проверяем службу NSSM
    $service = Get-Service RedisService -ErrorAction SilentlyContinue
    if ($service) {
        wrgb "  NSSM служба: $($service.Status)" -FC "Gray"
    }

    # Проверяем процесс
    $process = Get-Process redis-server -ErrorAction SilentlyContinue
    if ($process) {
        wrgb "✓ Redis работает (PID: $($process.Id))" -FC "Green"
    } else {
        wrgb "✗ Redis не запущен" -FC "Red"
    }

    # Пингуем Redis
    try {
        $ping = redis-cli ping 2>&1
        if ($ping -match "PONG") {
            wrgb "✓ Redis отвечает: $ping" -FC "Green"
        }
    } catch {
        wrgb "⚠️  Redis не отвечает на ping" -FC "Yellow"
    }
}

function Start-Redis {
    wrgb "`n🚀 Запуск Redis..." -FC "Cyan"

    # Проверяем не запущен ли уже
    $process = Get-Process redis-server -ErrorAction SilentlyContinue
    if ($process) {
        wrgb "⚠️  Redis уже запущен (PID: $($process.Id))" -FC "Yellow"
        return
    }

    Start-Process -FilePath "$REDIS_BIN\redis-server.exe" -ArgumentList $REDIS_CONF -WindowStyle Hidden
    Start-Sleep -Seconds 2

    $process = Get-Process redis-server -ErrorAction SilentlyContinue
    if ($process) {
        wrgb "✓ Redis запущен (PID: $($process.Id))" -FC "Green"
    } else {
        wrgb "✗ Ошибка при запуске Redis" -FC "Red"
    }

    Get-RedisStatus
}

function Start-RedisService {
    wrgb "`n🚀 Запуск Redis службы..." -FC "Cyan"

    $service = Get-Service RedisService -ErrorAction SilentlyContinue
    if ($service) {
        # Проверяем статус службы
        if ($service.Status -eq 'Paused') {
            wrgb "  🔄 Служба приостановлена, останавливаем и запускаем заново..." -FC "Yellow"
            nssm stop RedisService | Out-Null
            Start-Sleep -Seconds 1
            nssm start RedisService | Out-Null
        } elseif ($service.Status -eq 'Running') {
            wrgb "⚠️  Redis служба уже запущена" -FC "Yellow"
        } else {
            Start-Service RedisService
        }
        wrgb "✓ Redis служба запущена" -FC "Green"
    } else {
        wrgb "⚠️  Служба не установлена. Используйте: RDS install-service" -FC "Yellow"
        return
    }

    Get-RedisStatus
}

function Stop-Redis {
    wrgb "`n⏹️  Остановка Redis..." -FC "Cyan"

    $process = Get-Process redis-server -ErrorAction SilentlyContinue
    if ($process) {
        Stop-Process -Id $process.Id -Force
        wrgb "✓ Redis остановлен" -FC "Green"
    } else {
        wrgb "⚠️  Redis не запущен" -FC "Yellow"
    }
}

function Stop-RedisService {
    wrgb "`n⏹️  Остановка Redis службы..." -FC "Cyan"

    $service = Get-Service RedisService -ErrorAction SilentlyContinue
    if ($service) {
        Stop-Service RedisService
        wrgb "✓ Redis служба остановлена" -FC "Green"
    } else {
        wrgb "⚠️  Служба не установлена" -FC "Yellow"
    }
}

function Restart-Redis {
    wrgb "`n🔄 Перезапуск Redis..." -FC "Cyan"
    Stop-Redis
    Start-Sleep -Seconds 1
    Start-Redis
}

function Restart-RedisService {
    wrgb "`n🔄 Перезапуск Redis службы..." -FC "Cyan"
    Stop-RedisService
    Start-Sleep -Seconds 1
    Start-RedisService
}

function Install-RedisService {
    $redisExe = "$REDIS_BIN\redis-server.exe"
    # ВАЖНО: Используем относительный путь для конфига, чтобы избежать проблем с Cygwin путями
    Install-NSSMService -ServiceName "RedisService" `
                        -ExecutablePath $redisExe `
                        -Arguments "redis.conf" `
                        -DisplayName "Redis Cache Server" `
                        -Description "Redis in-memory data store managed by NSSM"

    wrgb "`n✓ Redis настроен как служба Windows" -FC "Green"
    wrgb "  Используйте: RDS start-service" -FC "Gray"
}

function Get-RedisInfo {
    wrgb "`n📊 Информация о Redis:" -FC "Cyan"
    try {
        redis-cli info server | Select-String -Pattern "redis_version|os|uptime_in_seconds"
    } catch {
        wrgb "✗ Не удалось получить информацию. Redis не запущен?" -FC "Red"
    }
}

function Show-RedisLogs {
    wrgb "`n📋 Последние логи Redis из NSSM:" -FC "Cyan"

    $stdoutLog = "$env:TEMP\RedisService-stdout.log"
    $stderrLog = "$env:TEMP\RedisService-stderr.log"

    if (Test-Path $stdoutLog) {
        wrgb "`nSTDOUT:" -FC "Yellow"
        Get-Content $stdoutLog -Tail 30
    }

    if (Test-Path $stderrLog) {
        wrgb "`nSTDERR:" -FC "Red"
        Get-Content $stderrLog -Tail 30
    }

    if (-not (Test-Path $stdoutLog) -and -not (Test-Path $stderrLog)) {
        wrgb "⚠️  Логи не найдены. Redis запущен как служба?" -FC "Yellow"
    }
}

function Clear-RedisCache {
    wrgb "`n🗑️  Очистка Redis кэша..." -FC "Yellow"
    wrgb "⚠️  Это удалит ВСЕ данные из Redis!" -FC "Red"
    $confirm = Read-Host "Продолжить? (yes/no)"

    if ($confirm -eq "yes") {
        redis-cli FLUSHALL
        wrgb "✓ Redis кэш очищен" -FC "Green"
    } else {
        wrgb "❌ Отменено" -FC "Gray"
    }
}

# ===== Help Functions =====

function Show-PostgreSQLHelp {
    wrgb "🐘 PostgreSQL Manager для Windows 11 🐘" -FC "Yellow" -newline
    wrgb "" -newline

    wrgb "Использование: PSQL <команда> [-service]" -FC "Cyan" -newline
    wrgb "" -newline

    wrgb "Доступные команды:" -FC "White" -newline
    wrgb "" -newline

    wrgbn "  start              " -FC "Green"
    wrgb "🚀 Запустить PostgreSQL" -FC "White" -newline

    wrgbn "  stop               " -FC "Green"
    wrgb "⏹️  Остановить PostgreSQL" -FC "White" -newline

    wrgbn "  restart            " -FC "Green"
    wrgb "🔄 Перезапустить PostgreSQL" -FC "White" -newline

    wrgbn "  start-service      " -FC "Green"
    wrgb "🚀 Запустить службу" -FC "White" -newline

    wrgbn "  stop-service       " -FC "Green"
    wrgb "⏹️  Остановить службу" -FC "White" -newline

    wrgbn "  restart-service    " -FC "Green"
    wrgb "🔄 Перезапустить службу" -FC "White" -newline

    wrgbn "  status             " -FC "Green"
    wrgb "🔍 Проверить статус" -FC "White" -newline

    wrgbn "  users              " -FC "Green"
    wrgb "👥 Показать пользователей и базы" -FC "White" -newline

    wrgbn "  backup             " -FC "Green"
    wrgb "💾 Создать полный бэкап" -FC "White" -newline

    wrgbn "  logs               " -FC "Green"
    wrgb "📋 Показать последние логи" -FC "White" -newline

    wrgbn "  install-service    " -FC "Green"
    wrgb "🔧 Установить как службу Windows (NSSM)" -FC "White" -newline

    wrgbn "  remove-service     " -FC "Green"
    wrgb "🗑️  Удалить службу Windows" -FC "White" -newline

    wrgbn "  help               " -FC "Green"
    wrgb "❓ Показать эту справку" -FC "White" -newline

    wrgb "" -newline
    wrgb "Флаги:" -FC "White" -newline
    wrgbn "  -service           " -FC "Yellow"
    wrgb "Использовать службу Windows вместо pg_ctl" -FC "White" -newline

    wrgb "" -newline
    wrgb "Примеры:" -FC "White" -newline
    wrgb "  PSQL start                    # Запуск через pg_ctl" -FC "Gray" -newline
    wrgb "  PSQL start -service           # Запуск службы" -FC "Gray" -newline
    wrgb "  PSQL start-service            # Запуск службы (новый синтаксис)" -FC "Gray" -newline
    wrgb "  PSQL install-service          # Установить службу NSSM" -FC "Gray" -newline
    wrgb "  PSQL status" -FC "Gray" -newline
    wrgb "  PSQL backup" -FC "Gray" -newline

    wrgb "" -newline
    wrgb "Расположение данных: $PG_DATA" -FC "Cyan" -newline
    wrgb "Расположение бэкапов: $BACKUP_DIR" -FC "Cyan" -newline
}

function Show-RedisHelp {
    wrgb "🔴 Redis Manager для Windows 11 🔴" -FC "#1177DD" -newline
    wrgb "" -newline

    wrgb "Использование: RDS <команда> [-service]" -FC "Cyan" -newline
    wrgb "" -newline

    wrgb "Доступные команды:" -FC "White" -newline
    wrgb "" -newline

    wrgbn "  start              " -FC "Green"
    wrgb "🚀 Запустить Redis" -FC "White" -newline

    wrgbn "  stop               " -FC "Green"
    wrgb "⏹️  Остановить Redis" -FC "White" -newline

    wrgbn "  restart            " -FC "Green"
    wrgb "🔄 Перезапустить Redis" -FC "White" -newline

    wrgbn "  start-service      " -FC "Green"
    wrgb "🚀 Запустить службу" -FC "White" -newline

    wrgbn "  stop-service       " -FC "Green"
    wrgb "⏹️  Остановить службу" -FC "White" -newline

    wrgbn "  restart-service    " -FC "Green"
    wrgb "🔄 Перезапустить службу" -FC "White" -newline

    wrgbn "  status             " -FC "Green"
    wrgb "🔍 Проверить статус" -FC "White" -newline

    wrgbn "  info               " -FC "Green"
    wrgb "📊 Показать информацию о сервере" -FC "White" -newline

    wrgbn "  logs               " -FC "Green"
    wrgb "📋 Показать логи" -FC "White" -newline

    wrgbn "  clear              " -FC "Green"
    wrgb "🗑️  Очистить весь кэш (FLUSHALL)" -FC "White" -newline

    wrgbn "  install-service    " -FC "Green"
    wrgb "🔧 Установить как службу Windows (NSSM)" -FC "White" -newline

    wrgbn "  remove-service     " -FC "Green"
    wrgb "🗑️  Удалить службу Windows" -FC "White" -newline

    wrgbn "  help               " -FC "Green"
    wrgb "❓ Показать эту справку" -FC "White" -newline

    wrgb "" -newline
    wrgb "Флаги:" -FC "White" -newline
    wrgbn "  -service           " -FC "Yellow"
    wrgb "Использовать службу Windows" -FC "White" -newline

    wrgb "" -newline
    wrgb "Примеры:" -FC "White" -newline
    wrgb "  RDS start                     # Запуск в фоне" -FC "Gray" -newline
    wrgb "  RDS start -service            # Запуск службы" -FC "Gray" -newline
    wrgb "  RDS start-service             # Запуск службы (новый синтаксис)" -FC "Gray" -newline
    wrgb "  RDS install-service           # Установить службу NSSM" -FC "Gray" -newline
    wrgb "  RDS status" -FC "Gray" -newline
    wrgb "  RDS info" -FC "Gray" -newline
    wrgb "  RDS clear" -FC "Gray" -newline

    wrgb "" -newline
    wrgb "Конфигурация: $REDIS_CONF" -FC "Cyan" -newline
    wrgb "Порт: 6379" -FC "Cyan" -newline
}

# ===== Main Commands =====

function PSQL {
    param(
        [Parameter(Position=0)]
        [ValidateSet('start', 'stop', 'restart', 'status', 'backup', 'users', 'logs',
                     'start-service', 'stop-service', 'restart-service',
                     'install-service', 'remove-service', 'help')]
        [string]$Action = 'help'
    )

    switch ($Action) {
        'start'           { Start-PostgreSQL }
        'stop'            { Stop-PostgreSQL }
        'restart'         { Restart-PostgreSQL }
        'start-service'   { Start-PostgreSQLService }
        'stop-service'    { Stop-PostgreSQLService }
        'restart-service' { Restart-PostgreSQLService }
        'status'          { Get-PostgreSQLStatus }
        'users'           { Get-Users }
        'backup'          { Backup-Database }
        'logs'            { Show-PostgreSQLLogs }
        'install-service' { Install-PostgreSQLService }
        'remove-service'  { Remove-NSSMService -ServiceName "PostgreSQL" }
        'help'            { Show-PostgreSQLHelp }
        default           { Show-PostgreSQLHelp }
    }

    wrgb "" # Пустая строка в конце
}

function RDS {
    param(
        [Parameter(Position=0)]
        [ValidateSet('start', 'stop', 'restart', 'status', 'info', 'logs', 'clear',
                     'start-service', 'stop-service', 'restart-service',
                     'install-service', 'remove-service', 'help')]
        [string]$Action = 'help'
    )

    switch ($Action) {
        'start'           { Start-Redis }
        'stop'            { Stop-Redis }
        'restart'         { Restart-Redis }
        'start-service'   { Start-RedisService }
        'stop-service'    { Stop-RedisService }
        'restart-service' { Restart-RedisService }
        'status'          { Get-RedisStatus }
        'info'            { Get-RedisInfo }
        'logs'            { Show-RedisLogs }
        'clear'           { Clear-RedisCache }
        'install-service' { Install-RedisService }
        'remove-service'  { Remove-NSSMService -ServiceName "RedisService" }
        'help'            { Show-RedisHelp }
        default           { Show-RedisHelp }
    }
}

# Функции PSQL и RDS автоматически доступны после загрузки скрипта
