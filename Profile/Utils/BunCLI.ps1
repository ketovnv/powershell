# Bun CLI Manager для PowerShell
# Интеграция с bun-cli-manager.js для управления Elysia/Redis/MobX стеком
# Автор: Для удобной работы с Bun проектами

# Поднимаемся от Utils -> profile -> PowerShell
$PROJECT_ROOT = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$BUN_CLI_PATH = Join-Path $PROJECT_ROOT "src\source\bun-cli-manager.js"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Invoke-BunCLI {
    param(
        [string]$Command,
        [string[]]$Arguments = @()
    )
    
    if (-not (Test-Path $BUN_CLI_PATH)) {
        Write-ColorOutput "❌ Bun CLI Manager не найден: $BUN_CLI_PATH" "Red"
        return @{ success = $false; error = "CLI file not found" }
    }
    
    try {
        $argString = $Arguments -join " "
        $fullCommand = if ($argString) { "$Command $argString" } else { $Command }
        
        $result = bun run $BUN_CLI_PATH $fullCommand 2>&1
        
        # Пробуем распарсить JSON результат
        try {
            $jsonResult = $result | ConvertFrom-Json
            return $jsonResult
        } catch {
            # Если не JSON, возвращаем как есть
            return @{
                success = $true
                output = $result -join "`n"
            }
        }
    } catch {
        Write-ColorOutput "❌ Ошибка выполнения: $($_.Exception.Message)" "Red"
        return @{ 
            success = $false
            error = $_.Exception.Message 
        }
    }
}

# ===== 🦊 Elysia Commands =====

function Start-ElysiaServer {
    Write-ColorOutput "`n🦊 Запуск Elysia dev сервера..." "Cyan"
    $result = Invoke-BunCLI "dev"
    
    if ($result.success) {
        Write-ColorOutput "✓ Elysia запущен на порту $($result.port)" "Green"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

function Build-ElysiaApp {
    Write-ColorOutput "`n📦 Сборка Elysia приложения..." "Cyan"
    $result = Invoke-BunCLI "build"
    
    if ($result.success) {
        Write-ColorOutput "✓ Сборка завершена: $($result.buildPath)" "Green"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

function Start-ElysiaProduction {
    Write-ColorOutput "`n🚀 Запуск Elysia в production режиме..." "Cyan"
    $result = Invoke-BunCLI "prod"
    
    if ($result.success) {
        Write-ColorOutput "✓ Production сервер запущен: $($result.url)" "Green"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

function Get-ElysiaRoutes {
    Write-ColorOutput "`n🔍 Проверка Elysia роутов..." "Cyan"
    $result = Invoke-BunCLI "routes"
    
    if ($result.success) {
        Write-ColorOutput $result.routes "White"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

# ===== 🔴 Redis Commands =====

function Test-BunRedis {
    Write-ColorOutput "`n🔴 Проверка Redis..." "Cyan"
    $result = Invoke-BunCLI "redis:check"
    
    if ($result.success) {
        Write-ColorOutput "✓ $($result.message) ($($result.host):$($result.port))" "Green"
    } else {
        Write-ColorOutput "✗ Redis недоступен" "Red"
    }
    
    return $result
}

function Get-BunRedisInfo {
    Write-ColorOutput "`n📊 Информация о Redis..." "Cyan"
    $result = Invoke-BunCLI "redis:info"
    
    if ($result.success -and $result.info) {
        Write-ColorOutput "  Redis версия: $($result.info.redis_version)" "White"
        Write-ColorOutput "  OS: $($result.info.os)" "White"
        Write-ColorOutput "  Uptime: $($result.info.uptime_in_seconds) секунд" "White"
    }
}

function Watch-BunRedis {
    Write-ColorOutput "`n👀 Мониторинг Redis (Ctrl+C для выхода)..." "Yellow"
    Invoke-BunCLI "redis:monitor"
}

function Get-BunRedisStats {
    Write-ColorOutput "`n📈 Статистика Redis..." "Cyan"
    Invoke-BunCLI "redis:stats"
}

function Clear-BunRedis {
    Write-ColorOutput "`n⚠️  ВНИМАНИЕ: Это удалит ВСЕ данные из Redis!" "Red"
    $confirm = Read-Host "Продолжить? (yes/no)"
    
    if ($confirm -eq "yes") {
        $result = Invoke-BunCLI "redis:flush"
        if ($result.success) {
            Write-ColorOutput "✓ Redis кэш очищен" "Green"
        }
    } else {
        Write-ColorOutput "❌ Отменено" "Gray"
    }
}

# ===== 🗄️ Drizzle Commands =====

function New-DrizzleMigration {
    Write-ColorOutput "`n🗄️  Генерация миграций Drizzle..." "Cyan"
    $result = Invoke-BunCLI "db:generate"
    
    if ($result.success) {
        Write-ColorOutput "✓ Миграции созданы" "Green"
        Write-ColorOutput $result.output "Gray"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

function Invoke-DrizzleMigration {
    Write-ColorOutput "`n🚀 Применение миграций..." "Cyan"
    $result = Invoke-BunCLI "db:migrate"
    
    if ($result.success) {
        Write-ColorOutput "✓ Миграции применены" "Green"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

function Start-DrizzleStudio {
    Write-ColorOutput "`n📊 Открытие Drizzle Studio..." "Cyan"
    $result = Invoke-BunCLI "db:studio"
    
    if ($result.success) {
        Write-ColorOutput "✓ Drizzle Studio открыт: $($result.url)" "Green"
        Write-ColorOutput "  $($result.message)" "Gray"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

function Invoke-DrizzleIntrospect {
    Write-ColorOutput "`n🔍 Интроспекция базы данных..." "Cyan"
    $result = Invoke-BunCLI "db:introspect"
    
    if ($result.success) {
        Write-ColorOutput "✓ Интроспекция завершена" "Green"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

# ===== ⚛️ React + MobX Commands =====

function Start-ReactDev {
    Write-ColorOutput "`n⚛️  Запуск React dev сервера..." "Cyan"
    $result = Invoke-BunCLI "react:dev"
    
    if ($result.success) {
        Write-ColorOutput "✓ React dev сервер запущен: $($result.url)" "Green"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

function Build-ReactApp {
    Write-ColorOutput "`n📦 Сборка React приложения..." "Cyan"
    $result = Invoke-BunCLI "react:build"
    
    if ($result.success) {
        Write-ColorOutput "✓ React собран: $($result.buildPath)" "Green"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

function Start-ReactPreview {
    Write-ColorOutput "`n👀 Превью production билда..." "Cyan"
    $result = Invoke-BunCLI "react:preview"
    
    if ($result.success) {
        Write-ColorOutput "✓ Preview сервер: $($result.url)" "Green"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

function Get-MobXStores {
    Write-ColorOutput "`n🔍 Поиск MobX stores..." "Cyan"
    $result = Invoke-BunCLI "mobx:stores"
    
    if ($result.success -and $result.stores) {
        Write-ColorOutput "Найдено stores:" "Green"
        $result.stores | ForEach-Object {
            Write-ColorOutput "  - $_" "White"
        }
    } else {
        Write-ColorOutput "Stores не найдены" "Yellow"
    }
}

# ===== 🧪 Testing Commands =====

function Invoke-BunTests {
    param([switch]$Watch, [switch]$Coverage)
    
    Write-ColorOutput "`n🧪 Запуск тестов..." "Cyan"
    
    $cmd = if ($Watch) { 
        "test:watch" 
    } elseif ($Coverage) { 
        "test:coverage" 
    } else { 
        "test" 
    }
    
    $result = Invoke-BunCLI $cmd
    Write-ColorOutput $result.output "White"
}

# ===== 📦 Dependencies Management =====

function Install-BunDependencies {
    Write-ColorOutput "`n📦 Установка зависимостей..." "Cyan"
    $result = Invoke-BunCLI "install"
    
    if ($result.success) {
        Write-ColorOutput "✓ Зависимости установлены" "Green"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

function Update-BunDependencies {
    Write-ColorOutput "`n🔄 Обновление зависимостей..." "Cyan"
    $result = Invoke-BunCLI "update"
    
    if ($result.success) {
        Write-ColorOutput "✓ Зависимости обновлены" "Green"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

function Get-BunOutdated {
    Write-ColorOutput "`n🔍 Проверка устаревших пакетов..." "Cyan"
    $result = Invoke-BunCLI "outdated"
    
    if ($result.success) {
        $result.packages | ForEach-Object {
            Write-ColorOutput "  $_" "Yellow"
        }
    }
}

function Add-BunPackage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageName,
        [switch]$Dev
    )
    
    Write-ColorOutput "`n📦 Добавление пакета: $PackageName..." "Cyan"
    
    $bunArgs = @($PackageName)
    if ($Dev) {
        $bunArgs += "--dev"
    }

    $result = Invoke-BunCLI "add" $bunArgs
    
    if ($result.success) {
        Write-ColorOutput "✓ Пакет добавлен" "Green"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

function Remove-BunPackage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageName
    )
    
    Write-ColorOutput "`n🗑️  Удаление пакета: $PackageName..." "Cyan"
    $result = Invoke-BunCLI "remove" @($PackageName)
    
    if ($result.success) {
        Write-ColorOutput "✓ Пакет удален" "Green"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

# ===== 🛠️ Development Environment =====

function Start-FullDevEnvironment {
    Write-ColorOutput "`n🚀 Запуск полного dev окружения..." "Cyan"
    $result = Invoke-BunCLI "start"
    
    Write-ColorOutput "`n📊 Результаты запуска:" "Yellow"
    
    if ($result.redis) {
        $status = if ($result.redis.success) { "✓" } else { "✗" }
        $color = if ($result.redis.success) { "Green" } else { "Red" }
        Write-ColorOutput "  Redis: $status $($result.redis.message)" $color
    }
    
    if ($result.elysia) {
        $status = if ($result.elysia.success) { "✓" } else { "✗" }
        $color = if ($result.elysia.success) { "Green" } else { "Red" }
        Write-ColorOutput "  Elysia: $status $($result.elysia.message)" $color
        if ($result.elysia.port) {
            Write-ColorOutput "    → http://localhost:$($result.elysia.port)" "Gray"
        }
    }
    
    if ($result.react) {
        $status = if ($result.react.success) { "✓" } else { "✗" }
        $color = if ($result.react.success) { "Green" } else { "Red" }
        Write-ColorOutput "  React: $status $($result.react.message)" $color
        if ($result.react.port) {
            Write-ColorOutput "    → http://localhost:$($result.react.port)" "Gray"
        }
    }
}

function Stop-AllDevProcesses {
    Write-ColorOutput "`n🛑 Остановка всех dev процессов..." "Cyan"
    $result = Invoke-BunCLI "stop"
    
    if ($result.success) {
        Write-ColorOutput "✓ Все процессы остановлены" "Green"
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

function Get-DevProcesses {
    Write-ColorOutput "`n📋 Запущенные dev процессы:" "Cyan"
    $result = Invoke-BunCLI "ps"
    
    if ($result.success -and $result.processes) {
        $result.processes | ForEach-Object {
            $memMB = [math]::Round($_.WorkingSet / 1MB, 2)
            Write-ColorOutput "  [$($_.Id)] $($_.ProcessName) - CPU: $($_.CPU)% - Memory: ${memMB}MB" "White"
        }
    } else {
        Write-ColorOutput "  Нет запущенных процессов" "Gray"
    }
}

function Test-DevHealth {
    Write-ColorOutput "`n🏥 Проверка здоровья сервисов..." "Cyan"
    $result = Invoke-BunCLI "health"
    
    Write-ColorOutput "`n📊 Результаты проверки:" "Yellow"
    
    if ($result.redis) {
        $status = if ($result.redis.success) { "✓" } else { "✗" }
        $color = if ($result.redis.success) { "Green" } else { "Red" }
        Write-ColorOutput "  Redis: $status $($result.redis.message)" $color
    }
    
    if ($result.elysia) {
        $status = if ($result.elysia.success) { "✓" } else { "✗" }
        $color = if ($result.elysia.success) { "Green" } else { "Red" }
        Write-ColorOutput "  Elysia: $status" $color
    }
    
    if ($result.bun) {
        $status = if ($result.bun.success) { "✓" } else { "✗" }
        $color = if ($result.bun.success) { "Green" } else { "Red" }
        Write-ColorOutput "  Bun: $status v$($result.bun.version)" $color
    }
}

# ===== 📊 Analysis =====

function Invoke-BundleAnalysis {
    Write-ColorOutput "`n📊 Анализ размера бандла..." "Cyan"
    $result = Invoke-BunCLI "analyze"
    
    if ($result.success) {
        Write-ColorOutput "✓ Анализ завершен" "Green"
        if ($result.size) {
            Write-ColorOutput "  Общий размер: $($result.size.TotalMB) MB" "White"
        }
    } else {
        Write-ColorOutput "✗ Ошибка: $($result.error)" "Red"
    }
}

function Invoke-BunBenchmark {
    Write-ColorOutput "`n⚡ Запуск бенчмарка производительности..." "Cyan"
    $result = Invoke-BunCLI "benchmark"
    
    if ($result.success) {
        Write-ColorOutput "✓ Бенчмарк завершен" "Green"
        Write-ColorOutput "  Итераций: $($result.iterations)" "White"
        Write-ColorOutput "  Общее время: $($result.totalTime) мс" "White"
        Write-ColorOutput "  Среднее время: $($result.averageTime) мс" "White"
    }
}

# ===== 📖 Help =====

function Show-BunHelp {
    Write-ColorOutput @"

╔══════════════════════════════════════════════════════════╗
║     🦊 Bun CLI Manager - Elysia/Redis/MobX Stack    🦊   ║
╚══════════════════════════════════════════════════════════╝

Использование: BunCLI <команда> [параметры]
Короткий алиас: bcli <команда>

🦊 Elysia:
  dev                    Запуск dev сервера
  build                  Сборка для production
  prod                   Запуск в production режиме
  routes                 Показать роуты

🔴 Redis:
  redis-check            Проверка подключения
  redis-info             Информация о сервере
  redis-monitor          Мониторинг в реальном времени
  redis-stats            Статистика
  redis-flush            Очистка кэша

🗄️  Drizzle:
  db-generate            Создать миграции
  db-migrate             Применить миграции
  db-studio              Открыть Drizzle Studio
  db-introspect          Интроспекция БД

⚛️  React + MobX:
  react-dev              Dev сервер React
  react-build            Сборка React
  react-preview          Превью production
  mobx-stores            Найти MobX stores

🧪 Testing:
  test                   Запуск тестов
  test -Watch            Тесты в watch mode
  test -Coverage         Тесты с coverage

📦 Зависимости:
  install                Установить зависимости
  update                 Обновить зависимости
  outdated               Проверить устаревшие
  add <pkg> [-Dev]       Добавить пакет
  remove <pkg>           Удалить пакет

🛠️  Dev Environment:
  start                  Запустить всё
  stop                   Остановить всё
  ps                     Список процессов
  health                 Проверка здоровья

📊 Анализ:
  analyze                Анализ бандла
  benchmark              Бенчмарк

Примеры:
  BunCLI dev                      # Запуск Elysia
  bcli start                      # Запуск всего окружения (алиас)
  bcli add elysia-cors            # Добавить пакет
  bcli add @types/bun -Dev        # Добавить dev пакет
  bhealth                         # Проверка всех сервисов (алиас)

Быстрые алиасы:
  bcli          - BunCLI
  bdev          - Запуск Elysia dev
  bbuild        - Сборка Elysia
  bstart        - Запуск всего окружения
  bstop         - Остановка всех процессов
  bhealth       - Проверка здоровья

"@ "Yellow"
}

# ===== 🎯 Main Command Function =====

function BunCLI {
    param(
        [Parameter(Position=0)]
        [ValidateSet('dev', 'build', 'prod', 'routes',
                     'redis-check', 'redis-info', 'redis-monitor', 'redis-stats', 'redis-flush',
                     'db-generate', 'db-migrate', 'db-studio', 'db-introspect',
                     'react-dev', 'react-build', 'react-preview', 'mobx-stores',
                     'test', 'install', 'update', 'outdated', 'add', 'remove',
                     'start', 'stop', 'ps', 'health',
                     'analyze', 'benchmark', 'help')]
        [string]$Action = 'help',
        
        [Parameter(Position=1)]
        [string]$Package,
        
        [switch]$Watch,
        [switch]$Coverage,
        [switch]$Dev
    )

    switch ($Action) {
        # Elysia
        'dev'       { Start-ElysiaServer }
        'build'     { Build-ElysiaApp }
        'prod'      { Start-ElysiaProduction }
        'routes'    { Get-ElysiaRoutes }
        
        # Redis
        'redis-check'   { Test-BunRedis }
        'redis-info'    { Get-BunRedisInfo }
        'redis-monitor' { Watch-BunRedis }
        'redis-stats'   { Get-BunRedisStats }
        'redis-flush'   { Clear-BunRedis }
        
        # Drizzle
        'db-generate'   { New-DrizzleMigration }
        'db-migrate'    { Invoke-DrizzleMigration }
        'db-studio'     { Start-DrizzleStudio }
        'db-introspect' { Invoke-DrizzleIntrospect }
        
        # React + MobX
        'react-dev'     { Start-ReactDev }
        'react-build'   { Build-ReactApp }
        'react-preview' { Start-ReactPreview }
        'mobx-stores'   { Get-MobXStores }
        
        # Testing
        'test'      { Invoke-BunTests -Watch:$Watch -Coverage:$Coverage }
        
        # Dependencies
        'install'   { Install-BunDependencies }
        'update'    { Update-BunDependencies }
        'outdated'  { Get-BunOutdated }
        'add'       { 
            if (-not $Package) {
                Write-ColorOutput "❌ Укажите имя пакета: BunCLI add <package-name>" "Red"
            } else {
                Add-BunPackage -PackageName $Package -Dev:$Dev
            }
        }
        'remove'    {
            if (-not $Package) {
                Write-ColorOutput "❌ Укажите имя пакета: BunCLI remove <package-name>" "Red"
            } else {
                Remove-BunPackage -PackageName $Package
            }
        }
        
        # Dev Environment
        'start'     { Start-FullDevEnvironment }
        'stop'      { Stop-AllDevProcesses }
        'ps'        { Get-DevProcesses }
        'health'    { Test-DevHealth }
        
        # Analysis
        'analyze'   { Invoke-BundleAnalysis }
        'benchmark' { Invoke-BunBenchmark }
        
        # Help
        'help'      { Show-BunHelp }
        default     { Show-BunHelp }
    }

    Write-ColorOutput "" # Пустая строка в конце
}

# Алиасы для быстрого доступа
Set-Alias -Name bcli -Value BunCLI
Set-Alias -Name bdev -Value Start-ElysiaServer
Set-Alias -Name bbuild -Value Build-ElysiaApp
Set-Alias -Name bstart -Value Start-FullDevEnvironment
Set-Alias -Name bstop -Value Stop-AllDevProcesses
Set-Alias -Name bhealth -Value Test-DevHealth
