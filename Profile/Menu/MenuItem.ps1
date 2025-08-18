Trace-ImportProcess  $MyInvocation.MyCommand.Name.trim(".ps1") -start

function Show-DevToolsMenu {
    $menuItems = @(
        @{ Text = "🦀 Rust: обновить до nightly"; Data = "rust-update" },
        @{ Text = "📦 Cargo: обновить пакеты"; Data = "cargo-update" },
        @{ Text = "⚡ Bun: обновить пакеты"; Data = "bun-update" },
        @{ Text = "🚀 Bun: dev server"; Data = "bun-dev" },
        @{ Text = "🏗️  Bun: build проект"; Data = "bun-build" },
        @{ Text = "📝 Zed: обновить (scoop)"; Data = "zed-update" },
        @{ Text = "📦 Winget: обновить все"; Data = "winget-update" },
        @{ Text = "💾 Базы данных"; Data = "db-ops" },
        @{ Text = "🔍 Поиск портов"; Data = "port-scan" },
        @{ Text = "📊 Системный мониторинг"; Data = "sys-monitor" },
        @{ Text = "🎯 Сетевые инструменты"; Data = "net-tools" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $gradientOptions = @{
        StartColor = "#FF8C00"
        EndColor = "#FF1493"
        GradientType = "Linear"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "🛠️  ИНСТРУМЕНТЫ РАЗРАБОТЧИКА" -Prompt "Выберите действие" -GradientOptions $gradientOptions

    switch ($selected.Data) {
        "rust-update" {
            wrgb "`n🦀 Обновление Rust..." -FC OrangeRGB -newline
            Show-RGBLoader -Text "Updating Rust to nightly" -Duration 2
            rustup update nightly
            wrgb "✅ Rust обновлен!" -FC LimeRGB -newline
            Pause
                        Show-DevToolsMenu
        }
        "cargo-update" {
            wrgb "`n📦 Обновление Cargo пакетов..." -FC NeonBlueRGB -newline
            cargo update -v
            wrgb "✅ Пакеты обновлены!" -FC LimeRGB -newline
            Pause
            Show-DevToolsMenu
        }
        "bun-update" {
            wrgb "`n⚡ Обновление Bun пакетов..." -FC YellowRGB -newline
            bun update
            wrgb "✅ Bun пакеты обновлены!" -FC LimeRGB -newline
            Pause
            Show-DevToolsMenu
        }
        "bun-dev" {
            $projectDir = Read-Host "`nВведите путь к проекту (Enter для текущей)"
            if (-not $projectDir) { $projectDir = Get-Location }
            Set-Location $projectDir
            wrgb "🚀 Запуск Bun dev server..." -FC LimeRGB -newline
            bun run dev
        }
        "bun-build" {
            $projectDir = Read-Host "`nВведите путь к проекту (Enter для текущей)"
            if (-not $projectDir) { $projectDir = Get-Location }
            Set-Location $projectDir
            wrgb "🏗️  Сборка проекта..." -FC CyanRGB -newline
            Show-RGBProgress -Activity "Building project" -TotalSteps 100 -Gradient
            bun run build
            wrgb "✅ Сборка завершена!" -FC LimeRGB -newline
            Pause
            Show-DevToolsMenu
        }
        "port-scan" {
            Show-PortScanner
            Pause
            Show-DevToolsMenu
        }
        "sys-monitor" {
            Show-SystemMonitor
            Pause
            Show-DevToolsMenu
        }
        "db-ops" {
            Show-DatabaseMenu
        }
        "net-tools" {
            Show-NetworkToolsMenu
        }
        "zed-update" {
            wrgb "`n📝 Обновление Zed через Scoop..." -FC CyanRGB -newline
            scoop update zed
            wrgb "✅ Zed обновлен!" -FC LimeRGB -newline
            Pause
            Show-DevToolsMenu
        }
        "winget-update" {
            wrgb "`n📦 Обновление всех пакетов Winget..." -FC MagentaRGB -newline
            winget upgrade --all
            wrgb "✅ Все пакеты обновлены!" -FC LimeRGB -newline
            Pause
            Show-DevToolsMenu
        }
        "back" {
            Show-MainMenu
        }
    }
}

# ===== МЕНЮ БАЗ ДАННЫХ =====
function Show-DatabaseMenu {
    $menuItems = @(
        @{ Text = "🐘 PostgreSQL управление"; Data = "postgres" },
        @{ Text = "🦭 MySQL управление"; Data = "mysql" },
        @{ Text = "🍃 MongoDB управление"; Data = "mongodb" },
        @{ Text = "🔴 Redis управление"; Data = "redis" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $gradientOptions = @{
        StartColor = "#32CD32"
        EndColor = "#00FA9A"
        GradientType = "Linear"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "💾 УПРАВЛЕНИЕ БАЗАМИ ДАННЫХ" -Prompt "Выберите БД" -GradientOptions $gradientOptions

    switch ($selected.Data) {
        "postgres" {
            wrgb "`n🐘 PostgreSQL операции:" -FC CyanRGB -newline
            wrgb "1. Запустить сервер: pg_ctl start" -FC White -newline
            wrgb "2. Остановить сервер: pg_ctl stop" -FC White -newline
            wrgb "3. Подключиться: psql -U username -d database" -FC White -newline
            Pause
            Show-DatabaseMenu
        }
        "mysql" {
            wrgb "`n🦭 MySQL операции:" -FC YellowRGB -newline
            wrgb "1. Запустить: net start mysql" -FC White -newline
            wrgb "2. Подключиться: mysql -u root -p" -FC White -newline
            Pause
            Show-DatabaseMenu
        }
        "mongodb" {
            wrgb "`n🍃 MongoDB операции:" -FC LimeRGB -newline
            wrgb "1. Запустить: mongod" -FC White -newline
            wrgb "2. Подключиться: mongosh" -FC White -newline
            Pause
            Show-DatabaseMenu
        }
        "redis" {
            wrgb "`n🔴 Redis операции:" -FC Red -newline
            wrgb "1. Запустить: redis-server" -FC White -newline
            wrgb "2. CLI: redis-cli" -FC White -newline
            Pause
            Show-DatabaseMenu
        }
        "back" {
            Show-DevToolsMenu
        }
    }
}


# ===== МЕНЮ НАСТРОЙКИ POWERSHELL =====
function Show-PowerShellConfigMenu {
    $menuItems = @(
        @{ Text = "🎨 Изменить цветовую схему"; Data = "colors" },
        @{ Text = "📝 Редактировать профиль"; Data = "edit-profile" },
        @{ Text = "🔄 Перезагрузить профиль"; Data = "reload" },
        @{ Text = "📦 Установить модули"; Data = "install-modules" },
        @{ Text = "⚙️  Настройки PSReadLine"; Data = "psreadline" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $gradientOptions = @{
        StartColor = "#8A2BE2"
        EndColor = "#4169E1"
        GradientType = "Sine"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "⚙️  НАСТРОЙКА POWERSHELL" -Prompt "Выберите действие" -GradientOptions $gradientOptions

    switch ($selected.Data) {
        "colors" {
            Show-ColorSchemeMenu
        }
        "edit-profile" {
            if (Get-Command code -ErrorAction SilentlyContinue) {
                code $PROFILE
            } else {
                notepad $PROFILE
            }
            Show-PowerShellConfigMenu
        }
        "reload" {
            wrgb "`n🔄 Перезагрузка профиля..." -FC YellowRGB -newline
            . $PROFILE
            wrgb "✅ Профиль перезагружен!" -FC LimeRGB -newline
            Pause
            Show-PowerShellConfigMenu
        }
        "install-modules" {
            Show-ModuleInstallMenu
        }
        "psreadline" {
            wrgb "`n⚙️  Текущие настройки PSReadLine:" -FC CyanRGB -newline
            Get-PSReadLineOption | Format-List
            Pause
            Show-PowerShellConfigMenu
        }
        "back" {
            Show-MainMenu
        }
    }
}

# ===== МЕНЮ УСТАНОВКИ МОДУЛЕЙ =====
function Show-ModuleInstallMenu {
    $modules = @(
        @{ Text = "📊 ImportExcel - работа с Excel"; Data = "ImportExcel" },
        @{ Text = "🎨 PowerColorLS - цветной ls"; Data = "PowerColorLS" },
        @{ Text = "📁 z - быстрая навигация"; Data = "z" },
        @{ Text = "🔍 PSEverything - поиск файлов"; Data = "PSEverything" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $selected = Show-Menu -MenuItems $modules -MenuTitle "📦 УСТАНОВКА МОДУЛЕЙ" -Prompt "Выберите модуль"

    if ($selected.Data -eq "back") {
        Show-PowerShellConfigMenu
    } else {
        wrgb "`n📦 Установка модуля $($selected.Data)..." -FC CyanRGB -newline
        Install-Module -Name $selected.Data -Scope CurrentUser -Force
        wrgb "✅ Модуль установлен!" -FC LimeRGB -newline
        Import-Module $selected.Data
        Pause
        Show-ModuleInstallMenu
    }
}


# ===== МЕНЮ ОЧИСТКИ СИСТЕМЫ =====
function Show-CleanupMenu {
    $menuItems = @(
        @{ Text = "🗑️  Очистить временные файлы"; Data = "temp" },
        @{ Text = "📁 Очистить кэш"; Data = "cache" },
        @{ Text = "🧹 Очистить корзину"; Data = "recycle" },
        @{ Text = "💾 Анализ дискового пространства"; Data = "disk-space" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $gradientOptions = @{
        StartColor = "#228B22"
        EndColor = "#FF6347"
        GradientType = "Linear"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "🧹 ОБСЛУЖИВАНИЕ СИСТЕМЫ" -Prompt "Выберите действие" -GradientOptions $gradientOptions

    switch ($selected.Data) {
        "temp" {
            wrgb "`n🗑️  Очистка временных файлов..." -FC YellowRGB -newline
            $tempFolders = @($env:TEMP, "C:\Windows\Temp")
            foreach ($folder in $tempFolders) {
                Get-ChildItem $folder -Recurse -Force -ErrorAction SilentlyContinue |
                        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            }
            wrgb "✅ Временные файлы очищены!" -FC LimeRGB -newline
            Pause
            Show-CleanupMenu
        }
        "cache" {
            wrgb "`n📁 Очистка кэша..." -FC OrangeRGB -newline
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            wrgb "✅ Кэш очищен!" -FC LimeRGB -newline
            Pause
            Show-CleanupMenu
        }
        "recycle" {
            wrgb "`n🧹 Очистка корзины..." -FC CyanRGB -newline
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            wrgb "✅ Корзина очищена!" -FC LimeRGB -newline
            Pause
            Show-CleanupMenu
        }
        "disk-space" {
            Show-DiskSpaceAnalysis
            Pause
            Show-CleanupMenu
        }
        "back" {
            Show-MainMenu
        }
    }
}

# ===== АНАЛИЗ ДИСКОВОГО ПРОСТРАНСТВА =====
function Show-DiskSpaceAnalysis {
    wrgb "`n💾 АНАЛИЗ ДИСКОВОГО ПРОСТРАНСТВА" -FC GoldRGB -newline

    Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        if ($_.Used -gt 0) {
            $usedPercent = [Math]::Round(($_.Used / ($_.Used + $_.Free)) * 100, 2)

            wrgb "`n📁 Диск " -FC White
            wrgb "$($_.Name):" -FC CyanRGB -newline

            # Градиентный прогресс бар
            $filled = [int]($usedPercent / 3.33)
            for ($i = 0; $i -lt $filled; $i++) {
                $color = Get-GradientColor -Index $i -TotalItems 30 -StartColor "#00FF00" -EndColor "#FF0000"
                wrgb "█" -FC $color
            }
            Write-Host ("░" * (30 - $filled)) -NoNewline

            wrgb " $usedPercent%" -FC White -newline
            wrgb "   Использовано: " -FC White
            wrgb "$([Math]::Round($_.Used / 1GB, 2)) GB" -FC YellowRGB
            wrgb " | Свободно: " -FC White
            wrgb "$([Math]::Round($_.Free / 1GB, 2)) GB" -FC LimeRGB -newline
        }
    }
}

function proj {
    param([string]$Name)

    $projects = @{
        "tauri"  = "C:\Projects\TauriApp"
        "react"  = "C:\Projects\ReactApp"
        "rust"   = "C:\Projects\RustProject"
        "web3"   = "C:\Projects\Web3App"
        "vite"   = "C:\Projects\ViteApp"
    }

    if ($Name -and $projects.ContainsKey($Name)) {
        Set-Location $projects[$Name]
        wrgb "📁 Switched to project: " -FC White
        wrgb $Name -FC NeonMaterial_LightGreen -newline
        lss
    } else {
        wrgb "📁 Available projects:" -FC CyanRGB -newline
        $i = 0
        $projects.Keys | Sort-Object | ForEach-Object {
            $color = Get-GradientColor -Index $i -TotalItems $projects.Count -StartColor "#00FF00" -EndColor "#FF00FF"
            wrgb "   • " -FC White
            wrgb $_ -FC $color
            wrgb " → " -FC White
            wrgb $projects[$_] -FC DarkGray -newline
            $i++
        }
    }
}

if (-not (Get-Command Show-DevToolsMenu Check-InitScripts -ErrorAction SilentlyContinue)) { wrgb 'Show-DevToolsMenu Error' -FC NeonRedRGB}
if (-not (Get-Command Show-DatabaseMenu Trace-ImportProcess -ErrorAction SilentlyContinue)) {  wrgb ' Show-DatabaseMenu Error' -FC  NeonRedRGB}

Trace-ImportProcess  $MyInvocation.MyCommand.Name.trim(".ps1")
