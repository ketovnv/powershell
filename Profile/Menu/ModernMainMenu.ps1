Trace-ImportProcess ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

# Helper: запуск приложений — корректно обрабатывает .ps1 скрипты (Start-Process открывает их в VSCode)
function Start-App {
    param(
        [string]$Name,
        [string[]]$Arguments
    )
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        Write-RGB "❌ Команда '$Name' не найдена" -FC Material_Red -newline
        return
    }
    if ($cmd.CommandType -eq 'ExternalScript') {
        # .ps1 скрипт — запускаем через pwsh, а не через ShellExecute
        if ($Arguments) { & $cmd.Source @Arguments } else { & $cmd.Source }
    } else {
        if ($Arguments) {
            Start-Process $cmd.Source -ArgumentList $Arguments -ErrorAction SilentlyContinue
        } else {
            Start-Process $cmd.Source -ErrorAction SilentlyContinue
        }
    }
}

# Helper функция для ожидания нажатия клавиши (убирает дублирование кода)
function Wait-KeyPress {
    param(
        [string]$Message = "`n⏎ Нажмите любую клавишу для продолжения...",
        [string]$Color = "CyanRGB"
    )
    Write-RGB $Message -FC $Color
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Show-ModernMainMenu {
    <#
    .SYNOPSIS
    Современное главное меню PowerShell с актуальными функциями
    #>

    # Очистка экрана для чистого интерфейса
    Clear-Host

    # Современный заголовок с украинской тематикой
    Write-GradientHeader -Title "🚀 СОВРЕМЕННЫЙ POWERSHELL PROFILE 🇺🇦" -StartColor "#0057B7" -EndColor "#FFD500" -BorderColor Nord_DarkBlue -padding 1

    # Информационная строка
    Write-RGB "  Версия: PowerShell $($PSVersionTable.PSVersion)" -FC Material_Blue -newline
    Write-RGB "  Пользователь: $env:USERNAME" -FC Material_Green -newline
    Write-RGB "  Время: $(Get-Date -Format 'HH:mm')" -FC Material_Amber -newline

    # Разделитель
    Write-RGB ("─" * 60) -FC UkraineBlueRGB -newline

    # Основное меню с актуальными функциями
    $menuItems = @(
        @{ Text = "📁 Файловый менеджер"; Data = "file-manager"; Description = "Управление файлами и директориями" },
        @{ Text = "🌐 Сетевые инструменты"; Data = "network-tools"; Description = "Диагностика сети и портов" },
        @{ Text = "💻 Системный мониторинг"; Data = "system-monitor"; Description = "Информация о системе и процессах" },
        @{ Text = "🛠️  Инструменты разработки"; Data = "dev-tools"; Description = "Rust, Bun, Git и другие инструменты" },
        @{ Text = "⚡ Bun справка"; Data = "bun-help"; Description = "Справка по Bun командам" },
        @{ Text = "🎨 Показать цвета"; Data = "show-colors"; Description = "Демонстрация цветовой палитры" },
        @{ Text = "😊 Показать эмодзи"; Data = "show-emojis"; Description = "Показать все доступные эмодзи" },
        @{ Text = "🚀 Быстрый запуск приложений"; Data = "quick-launch"; Description = "Запуск IDE и приложений" },
        @{ Text = "⚙️  Настройки профиля"; Data = "profile-settings"; Description = "Управление профилем PowerShell" },
        @{ Text = "🎨 Цветовая система"; Data = "color-system"; Description = "Демонстрация RGB цветов" },
        @{ Text = "📊 Базы данных"; Data = "databases"; Description = "PostgreSQL и Redis управление" },
        @{ Text = "🌐 Сайты"; Data = "sites"; Description = "Быстрый доступ к популярным сайтам" },
        @{ Text = "❓ Справка и диагностика"; Data = "help-diagnostics"; Description = "Помощь и проверка системы" },
        @{ Text = "🚪 Выход"; Data = "exit"; Description = "Закрыть меню" }
    )

    $gradientOptions = @{
        StartColor = "#0057B7"
        EndColor = "#FFD500"
        GradientType = "Linear"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "📋 ГЛАВНОЕ МЕНЮ" -Prompt "Выберите категорию" -GradientOptions $gradientOptions -ShowDescriptions

    if (-not $selected) { return }

    switch ($selected.Data) {
        "file-manager" {
            Show-FileManagerMenu
        }
        "network-tools" {
            Show-NetworkToolsMenu
        }
        "system-monitor" {
            Show-SystemMonitorMenu
        }
        "dev-tools" {
            Show-DevToolsMenu
        }
        "quick-launch" {
            Show-QuickLaunchMenu
        }
        "profile-settings" {
            Show-ProfileSettingsMenu
        }
        "color-system" {
            Show-ColorSystemDemo
        }
        "databases" {
            Show-DatabaseMenu
        }
        "sites" {
            Show-SitesMenu
        }
        "help-diagnostics" {
            Show-HelpDiagnosticsMenu
        }
        "bun-help" {
            Show-BunHelp
        }
        "show-colors" {
            Show-AllColors
            Wait-KeyPress
            Show-ModernMainMenu
        }
        "show-emojis" {
            Show-AllEmojis
            Wait-KeyPress
            Show-ModernMainMenu
        }
        "exit" {
            Show-ExitAnimation
            return
        }
    }
}

function Show-FileManagerMenu {
    while ($true) {
        $menuItems = @(
            @{ Text = "📂 Total Commander (tc)"; Data = "total-commander" },
            @{ Text = "🖥️  Midnight Commander (mc)"; Data = "midnight-commander" },
            @{ Text = "🎨 LS (красивый вывод)"; Data = "ls-beautiful" },
            @{ Text = "📝 VS Code (code)"; Data = "vscode" },
            @{ Text = "🚀 Cursor (cursor)"; Data = "cursor" },
            @{ Text = "🤖 DeepChat (deepchat)"; Data = "deepchat" },
            @{ Text = "🧠 LobeHub (lobehub)"; Data = "lobehub" },
            @{ Text = "🖼️  Rio (rio)"; Data = "rio" },
            @{ Text = "⚡ Alacritty (alacritty)"; Data = "alacritty" },
            @{ Text = "🔍 Поиск файлов"; Data = "find-files" },
            @{ Text = "📊 Информация о дисках"; Data = "disk-info" },
            @{ Text = "🗑️  Очистка временных файлов"; Data = "clean-temp" },
            @{ Text = "🔙 Назад"; Data = "back" }
        )

        $selected = Show-Menu -MenuItems $menuItems -MenuTitle "📁 ФАЙЛОВЫЙ МЕНЕДЖЕР"

        if (-not $selected) { return }

        switch ($selected.Data) {
            "total-commander" {
                Start-App "tc"
                Write-RGB "🚀 Запускаем Total Commander..." -FC Material_Blue -newline
                Wait-KeyPress
                continue
            }
            "midnight-commander" {
                Start-App "mc"
                Write-RGB "🚀 Запускаем Midnight Commander..." -FC Material_Blue -newline
                Wait-KeyPress
                continue
            }
            "ls-beautiful" {
                # Используем ваш красивый LS
                if (Get-Command ls -ErrorAction SilentlyContinue) {
                    ls
                } else {
                    Get-ChildItem | Format-Table -AutoSize
                }
                Wait-KeyPress
                continue
            }
            "vscode" {
                Start-App "code"
                Write-RGB "🚀 Запускаем VS Code..." -FC Material_Blue -newline
                Wait-KeyPress
                continue
            }
            "cursor" {
                Start-App "cursor"
                Write-RGB "🚀 Запускаем Cursor..." -FC Material_Blue -newline
                Wait-KeyPress
                continue
            }
            "deepchat" {
                Start-App "deepchat"
                Write-RGB "🚀 Запускаем DeepChat..." -FC Material_Blue -newline
                Wait-KeyPress
                continue
            }
            "lobehub" {
                Start-App "lobehub"
                Write-RGB "🚀 Запускаем LobeHub..." -FC Material_Blue -newline
                Wait-KeyPress
                continue
            }
            "rio" {
                Start-App "rio"
                Write-RGB "🚀 Запускаем Rio..." -FC Material_Blue -newline
                Wait-KeyPress
                continue
            }
            "alacritty" {
                Start-App "alacritty"
                Write-RGB "🚀 Запускаем Alacritty..." -FC Material_Blue -newline
                Wait-KeyPress
                continue
            }
            "find-files" {
                $pattern = Read-Host "Введите шаблон поиска"
                if ($pattern) {
                    Get-ChildItem -Recurse -Filter "*$pattern*" -ErrorAction SilentlyContinue | Select-Object -First 20
                }
                Wait-KeyPress
                continue
            }
            "disk-info" {
                Get-Volume | Format-Table -AutoSize
                Wait-KeyPress
                continue
            }
            "clean-temp" {
                Write-RGB "🧹 Очистка временных файлов..." -FC Material_Amber -newline
                Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                Write-RGB "✅ Временные файлы очищены" -FC Material_Green -newline
                Wait-KeyPress
                continue
            }
            "back" {
                Show-ModernMainMenu
                return
            }
        }
    }
}

function Show-NetworkToolsMenu {
    while ($true) {
        $menuItems = @(
            @{ Text = "🌐 Информация о сети"; Data = "network-info" },
            @{ Text = "🏓 Ping тест"; Data = "ping-test" },
            @{ Text = "🔍 Сканирование портов"; Data = "port-scan" },
            @{ Text = "📡 Внешний IP"; Data = "external-ip" },
            @{ Text = "🔙 Назад"; Data = "back" }
        )

        $selected = Show-Menu -MenuItems $menuItems -MenuTitle "🌐 СЕТЕВЫЕ ИНСТРУМЕНТЫ"

        if (-not $selected) { return }

        switch ($selected.Data) {
            "network-info" {
                Get-NetIPConfiguration | Format-Table -AutoSize
                Wait-KeyPress
                continue
            }
            "ping-test" {
                $target = Read-Host "Введите адрес для ping (по умолчанию: google.com)"
                if (-not $target) { $target = "google.com" }
                Test-Connection $target -Count 4
                Wait-KeyPress
                continue
            }
            "port-scan" {
                $target = Read-Host "Введите адрес для сканирования (по умолчанию: localhost)"
                if (-not $target) { $target = "localhost" }
                Write-RGB "🔍 Сканирование портов $target..." -FC Material_Amber -newline
                1..1024 | ForEach-Object {
                    if (Test-NetConnection $target -Port $_ -InformationLevel Quiet -TimeoutSeconds 1) {
                        Write-RGB "✅ Порт $_ открыт" -FC Material_Green
                    }
                }
                Wait-KeyPress
                continue
            }
            "external-ip" {
                try {
                    $ip = (Invoke-RestMethod "http://ipinfo.io/ip").Trim()
                    Write-RGB "🌍 Ваш внешний IP: $ip" -FC Material_Blue -newline
                } catch {
                    Write-RGB "❌ Не удалось получить внешний IP" -FC Material_Red -newline
                }
                Wait-KeyPress
                continue
            }
            "back" {
                Show-ModernMainMenu
                return
            }
        }
    }
}

function Show-SystemMonitorMenu {
    while ($true) {
        $menuItems = @(
            @{ Text = "💻 Информация о системе"; Data = "system-info" },
            @{ Text = "📊 Загрузка процессора"; Data = "cpu-usage" },
            @{ Text = "🧠 Использование памяти"; Data = "memory-usage" },
            @{ Text = "📈 Активные процессы"; Data = "active-processes" },
            @{ Text = "🔙 Назад"; Data = "back" }
        )

        $selected = Show-Menu -MenuItems $menuItems -MenuTitle "💻 СИСТЕМНЫЙ МОНИТОРИНГ"

        if (-not $selected) { return }

        switch ($selected.Data) {
            "system-info" {
                Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, TotalPhysicalMemory, CSProcessors | Format-List
                Wait-KeyPress
                continue
            }
            "cpu-usage" {
                Get-Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 5
                Wait-KeyPress
                continue
            }
            "memory-usage" {
                Get-Counter "\Memory\Available MBytes" -SampleInterval 1 -MaxSamples 5
                Wait-KeyPress
                continue
            }
            "active-processes" {
                Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, WorkingSet | Format-Table -AutoSize
                Wait-KeyPress
                continue
            }
            "back" {
                Show-ModernMainMenu
                return
            }
        }
    }
}

function Show-DevToolsMenu {
    $menuItems = @(
        @{ Text = "🦀 Rust инструменты"; Data = "rust-tools" },
        @{ Text = "⚡ Bun менеджер"; Data = "bun-tools" },
        @{ Text = "📦 Git операции"; Data = "git-tools" },
        @{ Text = "🐍 Python окружение"; Data = "python-tools" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "🛠️  ИНСТРУМЕНТЫ РАЗРАБОТКИ"

    if (-not $selected) { return }

    switch ($selected.Data) {
        "rust-tools" {
            if (Get-Command rustc -ErrorAction SilentlyContinue) {
                Write-RGB "🦀 Rust установлен:" -FC Material_Green -newline
                rustc --version
                cargo --version
            } else {
                Write-RGB "❌ Rust не установлен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DevToolsMenu
        }
        "bun-tools" {
            if (Get-Command bun -ErrorAction SilentlyContinue) {
                Write-RGB "⚡ Bun установлен:" -FC Material_Green -newline
                bun --version
            } else {
                Write-RGB "❌ Bun не установлен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DevToolsMenu
        }
        "git-tools" {
            if (Get-Command git -ErrorAction SilentlyContinue) {
                Write-RGB "📦 Git статус:" -FC Material_Green -newline
                git status
            } else {
                Write-RGB "❌ Git не установлен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DevToolsMenu
        }
        "python-tools" {
            if (Get-Command python -ErrorAction SilentlyContinue) {
                Write-RGB "🐍 Python установлен:" -FC Material_Green -newline
                python --version
            } else {
                Write-RGB "❌ Python не установлен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DevToolsMenu
        }
        "back" {
            Show-ModernMainMenu
        }
    }
}

function Show-QuickLaunchMenu {
    $menuItems = @(
        @{ Text = "📝 Zed Editor"; Data = "zed" },
        @{ Text = "💻 WebStorm"; Data = "webstorm" },
        @{ Text = "🖥️  WezTerm"; Data = "wezterm" },
        @{ Text = "🌐 Браузер"; Data = "browser" },
        @{ Text = "🔙 Назад"; Data = "back" }    )

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "🚀 БЫСТРЫЙ ЗАПУСК"

    if (-not $selected) { return }

    switch ($selected.Data) {
        "zed" {
            Start-App "zed"
            Write-RGB "🚀 Запускаем Zed..." -FC Material_Blue -newline
        }
        "webstorm" {
            Start-App "webstorm64"
            Write-RGB "🚀 Запускаем WebStorm..." -FC Material_Blue -newline
        }
        "wezterm" {
            Start-App "wezterm-gui"
            Write-RGB "🚀 Запускаем WezTerm..." -FC Material_Blue -newline
        }
        "browser" {
            Start-Process "https://google.com" -ErrorAction SilentlyContinue
            Write-RGB "🚀 Открываем браузер..." -FC Material_Blue -newline
        }
        "back" {
            Show-ModernMainMenu
        }
    }
    Wait-KeyPress
    Show-ModernMainMenu
}

function Show-ProfileSettingsMenu {
    $menuItems = @(
        @{ Text = "🔄 Перезагрузить профиль"; Data = "reload-profile" },
        @{ Text = "📊 Диагностика профиля"; Data = "profile-diagnostics" },
        @{ Text = "🎭 Сменить тему Oh My Posh"; Data = "change-theme" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "⚙️  НАСТРОЙКИ ПРОФИЛЯ"

    if (-not $selected) { return }

    switch ($selected.Data) {
        "reload-profile" {
            Write-RGB "🔄 Перезагрузка профиля..." -FC Material_Amber -newline
            . $PROFILE
            Write-RGB "✅ Профиль перезагружен" -FC Material_Green -newline
            Wait-KeyPress
            Show-ProfileSettingsMenu
        }
        "profile-diagnostics" {
            Write-RGB "📊 Запуск диагностики..." -FC Material_Amber -newline
            if (Get-Command Test-InitScripts -ErrorAction SilentlyContinue) {
                Test-InitScripts
            } else {
                Write-RGB "❌ Test-InitScripts не доступен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-ProfileSettingsMenu
        }
        "change-theme" {
            Write-RGB "🎭 Смена темы временно недоступна" -FC Material_Amber -newline
            Wait-KeyPress
            Show-ProfileSettingsMenu
        }
        "back" {
            Show-ModernMainMenu
        }
    }
}

function Show-ColorSystemDemo {
    Write-RGB "🎨 ДЕМОНСТРАЦИЯ ЦВЕТОВОЙ СИСТЕМЫ" -FC Material_Blue -Style Bold -newline
    Write-RGB ("─" * 40) -FC UkraineBlueRGB -newline

    # Демонстрация основных цветов
    $colors = @(
        @{Name = "Material Green"; Color = "Material_Green"},
        @{Name = "Material Red"; Color = "Material_Red"},
        @{Name = "Material Blue"; Color = "Material_Blue"},
        @{Name = "Material Amber"; Color = "Material_Amber"},
        @{Name = "Ukraine Blue"; Color = "UkraineBlueRGB"},
        @{Name = "Ukraine Yellow"; Color = "UkraineYellowRGB"}
    )

    foreach ($color in $colors) {
        Write-RGB "  $($color.Name)" -FC $color.Color -newline
    }

    Wait-KeyPress
    Show-ModernMainMenu
}

function Show-BunHelp {
    Write-RGB "⚡ BUN - БЫСТРЫЙ JAVASCRIPT RUNTIME" -FC Material_Amber -Style Bold -newline
    Write-RGB ("─" * 50) -FC Material_Blue -newline

    Write-RGB "📋 ОСНОВНЫЕ КОМАНДЫ:" -FC Material_Green -Style Bold -newline
    Write-RGB "  bun install                    📦 Установить зависимости" -FC White -newline
    Write-RGB "  bun run <script>               🚀 Запустить скрипт" -FC White -newline
    Write-RGB "  bun dev                        🔥 Запуск dev сервера" -FC White -newline
    Write-RGB "  bun build                      🏗️  Сборка проекта" -FC White -newline
    Write-RGB "  bun test                       🧪 Запуск тестов" -FC White -newline
    Write-RGB "  bun upgrade                    ⬆️  Обновить Bun" -FC White -newline
    Write-RGB "" -newline

    Write-RGB "🎯 ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ:" -FC Material_Green -Style Bold -newline
    Write-RGB "  bun run dev                    # Запуск dev скрипта" -FC Gray -newline
    Write-RGB "  bun run build                  # Сборка проекта" -FC Gray -newline
    Write-RGB "  bun install react react-dom    # Установка пакетов" -FC Gray -newline
    Write-RGB "  bunx create-react-app my-app   # Создание проекта" -FC Gray -newline
    Write-RGB "" -newline

    Write-RGB "⚡ ПРЕИМУЩЕСТВА BUN:" -FC Material_Green -Style Bold -newline
    Write-RGB "  ✅ В 4 раза быстрее Node.js" -FC Material_Green -newline
    Write-RGB "  ✅ Встроенный пакетный менеджер" -FC Material_Green -newline
    Write-RGB "  ✅ Нативный TypeScript" -FC Material_Green -newline
    Write-RGB "  ✅ Встроенный тест-раннер" -FC Material_Green -newline
    Write-RGB "  ✅ Совместимость с Node.js" -FC Material_Green -newline

    Wait-KeyPress
    Show-ModernMainMenu
}

function Show-AllColors {
    Write-RGB "🎨 ПОЛНАЯ ЦВЕТОВАЯ ПАЛИТРА" -FC Material_Blue -Style Bold -newline
    Write-RGB ("─" * 40) -FC UkraineBlueRGB -newline

    # Material Design Colors
    Write-RGB "🎨 MATERIAL DESIGN:" -FC Material_Blue -Style Bold -newline
    $materialColors = @(
        "Material_Red", "Material_Pink", "Material_Purple", "Material_DeepPurple",
        "Material_Indigo", "Material_Blue", "Material_LightBlue", "Material_Cyan",
        "Material_Teal", "Material_Green", "Material_LightGreen", "Material_Lime",
        "Material_Yellow", "Material_Amber", "Material_Orange", "Material_DeepOrange"
    )

    foreach ($color in $materialColors) {
        Write-RGB "  $color" -FC $color -newline
    }

    Write-RGB "" -newline
    Write-RGB "🇺🇦 УКРАИНСКИЕ ЦВЕТА:" -FC Material_Blue -Style Bold -newline
    Write-RGB "  UkraineBlueRGB" -FC UkraineBlueRGB -newline
    Write-RGB "  UkraineYellowRGB" -FC UkraineYellowRGB -newline

    Write-RGB "" -newline
    Write-RGB "🌈 ОСНОВНЫЕ ЦВЕТА:" -FC Material_Blue -Style Bold -newline
    $basicColors = @("Red", "Green", "Blue", "Yellow", "Cyan", "Magenta", "White", "Gray")
    foreach ($color in $basicColors) {
        Write-RGB "  $color" -FC $color -newline
    }

}

function Show-AllEmojis {
    Write-RGB "😊 ПОЛНЫЙ СПИСОК ЭМОДЗИ" -FC Material_Blue -Style Bold -newline
    Write-RGB ("─" * 40) -FC UkraineBlueRGB -newline

    if (Get-Command Get-Emoji -ErrorAction SilentlyContinue) {
        # Используем существующую функцию для показа эмодзи
        Write-RGB "📋 Категории эмодзи:" -FC Material_Green -newline
        Write-RGB "  🗄️  Database    - Иконки баз данных" -FC White -newline
        Write-RGB "  🌐 Network     - Сетевые иконки" -FC White -newline
        Write-RGB "  🔒 Security    - Иконки безопасности" -FC White -newline
        Write-RGB "  📊 Status      - Статусные иконки" -FC White -newline
        Write-RGB "  🛠️  Development - Иконки разработки" -FC White -newline
        Write-RGB "  🇺🇦 Ukraine     - Украинские символы" -FC White -newline
        Write-RGB "" -newline

        Write-RGB "🔍 Примеры эмодзи:" -FC Material_Green -newline
        $exampleEmojis = @(
            @{Name = "success"; Emoji = "✅"},
            @{Name = "error"; Emoji = "❌"},
            @{Name = "warning"; Emoji = "⚠️"},
            @{Name = "docker"; Emoji = "🐳"},
            @{Name = "python"; Emoji = "🐍"},
            @{Name = "database"; Emoji = "🗄️"},
            @{Name = "ukraine"; Emoji = "🇺🇦"}
        )

        foreach ($example in $exampleEmojis) {
            Write-RGB "  $($example.Emoji) $($example.Name)" -FC White -newline
        }

        Write-RGB "" -newline
        Write-RGB "ℹ️  Используйте Get-Emoji <имя> для поиска" -FC Material_Amber -newline
    } else {
        Write-RGB "❌ Система эмодзи не загружена" -FC Material_Red -newline
        Write-RGB "💡 Проверьте загрузку EmojiSystem.ps1" -FC Material_Amber -newline
    }

}

function Show-DatabaseMenu {
    $menuItems = @(
        @{ Text = "🐘 PostgreSQL статус"; Data = "postgres-status" },
        @{ Text = "🚀 PostgreSQL запуск"; Data = "postgres-start" },
        @{ Text = "⏹️  PostgreSQL остановка"; Data = "postgres-stop" },
        @{ Text = "🔄 PostgreSQL перезапуск"; Data = "postgres-restart" },
        @{ Text = "🔧 PostgreSQL служба запуск"; Data = "postgres-start-service" },
        @{ Text = "⏹️  PostgreSQL служба остановка"; Data = "postgres-stop-service" },
        @{ Text = "🔄 PostgreSQL служба перезапуск"; Data = "postgres-restart-service" },
        @{ Text = "🗄️  Redis статус"; Data = "redis-status" },
        @{ Text = "🚀 Redis запуск"; Data = "redis-start" },
        @{ Text = "⏹️  Redis остановка"; Data = "redis-stop" },
        @{ Text = "🔄 Redis перезапуск"; Data = "redis-restart" },
        @{ Text = "🔧 Redis служба запуск"; Data = "redis-start-service" },
        @{ Text = "⏹️  Redis служба остановка"; Data = "redis-stop-service" },
        @{ Text = "🔄 Redis служба перезапуск"; Data = "redis-restart-service" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "📊 БАЗЫ ДАННЫХ"

    if (-not $selected) { return }

    switch ($selected.Data) {
        "postgres-status" {
            if (Get-Command Get-PostgreSQLStatus -ErrorAction SilentlyContinue) {
                Get-PostgreSQLStatus
            } else {
                Write-RGB "❌ PostgreSQL модуль не загружен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DatabaseMenu
        }
        "postgres-start" {
            if (Get-Command Start-PostgreSQL -ErrorAction SilentlyContinue) {
                Start-PostgreSQL
            } else {
                Write-RGB "❌ PostgreSQL модуль не загружен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DatabaseMenu
        }
        "postgres-stop" {
            if (Get-Command Stop-PostgreSQL -ErrorAction SilentlyContinue) {
                Stop-PostgreSQL
            } else {
                Write-RGB "❌ PostgreSQL модуль не загружен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DatabaseMenu
        }
        "postgres-restart" {
            if (Get-Command Restart-PostgreSQL -ErrorAction SilentlyContinue) {
                Restart-PostgreSQL
            } else {
                Write-RGB "❌ PostgreSQL модуль не загружен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DatabaseMenu
        }
        "postgres-start-service" {
            if (Get-Command Start-PostgreSQLService -ErrorAction SilentlyContinue) {
                Start-PostgreSQLService
            } else {
                Write-RGB "❌ PostgreSQL модуль не загружен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DatabaseMenu
        }
        "postgres-stop-service" {
            if (Get-Command Stop-PostgreSQLService -ErrorAction SilentlyContinue) {
                Stop-PostgreSQLService
            } else {
                Write-RGB "❌ PostgreSQL модуль не загружен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DatabaseMenu
        }
        "postgres-restart-service" {
            if (Get-Command Restart-PostgreSQLService -ErrorAction SilentlyContinue) {
                Restart-PostgreSQLService
            } else {
                Write-RGB "❌ PostgreSQL модуль не загружен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DatabaseMenu
        }
        "redis-status" {
            if (Get-Command Get-RedisStatus -ErrorAction SilentlyContinue) {
                Get-RedisStatus
            } else {
                Write-RGB "❌ Redis модуль не загружен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DatabaseMenu
        }
        "redis-start" {
            if (Get-Command Start-Redis -ErrorAction SilentlyContinue) {
                Start-Redis
            } else {
                Write-RGB "❌ Redis модуль не загружен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DatabaseMenu
        }
        "redis-stop" {
            if (Get-Command Stop-Redis -ErrorAction SilentlyContinue) {
                Stop-Redis
            } else {
                Write-RGB "❌ Redis модуль не загружен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DatabaseMenu
        }
        "redis-restart" {
            if (Get-Command Restart-Redis -ErrorAction SilentlyContinue) {
                Restart-Redis
            } else {
                Write-RGB "❌ Redis модуль не загружен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DatabaseMenu
        }
        "redis-start-service" {
            if (Get-Command Start-RedisService -ErrorAction SilentlyContinue) {
                Start-RedisService
            } else {
                Write-RGB "❌ Redis модуль не загружен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DatabaseMenu
        }
        "redis-stop-service" {
            if (Get-Command Stop-RedisService -ErrorAction SilentlyContinue) {
                Stop-RedisService
            } else {
                Write-RGB "❌ Redis модуль не загружен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DatabaseMenu
        }
        "redis-restart-service" {
            if (Get-Command Restart-RedisService -ErrorAction SilentlyContinue) {
                Restart-RedisService
            } else {
                Write-RGB "❌ Redis модуль не загружен" -FC Material_Red -newline
            }
            Wait-KeyPress
            Show-DatabaseMenu
        }
        "back" {
            Show-ModernMainMenu
        }
    }
}

function Show-HelpDiagnosticsMenu {
    $menuItems = @(
        @{ Text = "📋 Список команд"; Data = "command-list" },
        @{ Text = "🔍 Проверка системы"; Data = "system-check" },
        @{ Text = "📖 О программе"; Data = "about" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "❓ СПРАВКА И ДИАГНОСТИКА"

    if (-not $selected) { return }

    switch ($selected.Data) {
        "command-list" {
            Write-RGB "📋 ДОСТУПНЫЕ КОМАНДЫ:" -FC Material_Blue -Style Bold -newline
            Write-RGB "  menu / mm  - Открыть главное меню" -FC Material_Green -newline
            Write-RGB "  fm         - Файловый менеджер" -FC Material_Green -newline
            Write-RGB "  nt         - Сетевые инструменты" -FC Material_Green -newline
            Write-RGB "  sm         - Системный мониторинг" -FC Material_Green -newline
            Write-RGB "  dt         - Инструменты разработки" -FC Material_Green -newline
            Write-RGB "  ql         - Быстрый запуск приложений" -FC Material_Green -newline
            Write-RGB "  ps         - Настройки профиля" -FC Material_Green -newline
            Write-RGB "  cs         - Цветовая система" -FC Material_Green -newline
            Write-RGB "  db         - Базы данных" -FC Material_Green -newline
            Write-RGB "  hd         - Справка и диагностика" -FC Material_Green -newline
            Write-RGB "" -newline
            Write-RGB "🗄️  БАЗЫ ДАННЫХ:" -FC Material_Blue -Style Bold -newline
            Write-RGB "  pg / PSQL  - PostgreSQL" -FC Material_Green -newline
            Write-RGB "  rd / RDS   - Redis" -FC Material_Green -newline
            Write-RGB "" -newline
            Write-RGB "📁 ФАЙЛОВЫЕ МЕНЕДЖЕРЫ:" -FC Material_Blue -Style Bold -newline
            Write-RGB "  tc         - Total Commander" -FC Material_Green -newline
            Write-RGB "  mc         - Midnight Commander" -FC Material_Green -newline
            Write-RGB "  ls         - Красивый вывод файлов" -FC Material_Green -newline
            Write-RGB "  code       - VS Code" -FC Material_Green -newline
            Write-RGB "  cursor     - Cursor AI Editor" -FC Material_Green -newline
            Write-RGB "  deepchat   - DeepChat" -FC Material_Green -newline
            Write-RGB "  lobehub    - LobeHub" -FC Material_Green -newline
            Write-RGB "  rio        - Rio Terminal" -FC Material_Green -newline
            Write-RGB "  alacritty  - Alacritty Terminal" -FC Material_Green -newline
            Write-RGB "" -newline
            Write-RGB "🎨 ДОПОЛНИТЕЛЬНЫЕ КОМАНДЫ:" -FC Material_Blue -Style Bold -newline
            Write-RGB "  bun-help   - Справка по Bun" -FC Material_Green -newline
            Write-RGB "  show-colors - Показать цвета" -FC Material_Green -newline
            Write-RGB "  show-emojis - Показать эмодзи" -FC Material_Green -newline
            Write-RGB "" -newline
            Write-RGB "🛠️  СИСТЕМНЫЕ КОМАНДЫ:" -FC Material_Blue -Style Bold -newline
            Write-RGB "  chs        - Проверить статус загрузки" -FC Material_Green -newline
            Write-RGB "  wrgb       - Цветной вывод текста" -FC Material_Green -newline
            Wait-KeyPress
            Show-HelpDiagnosticsMenu
        }
        "system-check" {
            Write-RGB "🔍 ПРОВЕРКА СИСТЕМЫ:" -FC Material_Blue -Style Bold -newline
            Write-RGB "  PowerShell: $($PSVersionTable.PSVersion)" -FC Material_Green -newline
            Write-RGB "  Память: $([math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize/1MB, 2)) GB" -FC Material_Green -newline
            Write-RGB "  Диски:" -FC Material_Green -newline
            Get-Volume | Where-Object {$_.DriveLetter} | ForEach-Object {
                Write-RGB "    $($_.DriveLetter): $([math]::Round($_.Size/1GB, 2)) GB" -FC Material_Green
            }
            Wait-KeyPress
            Show-HelpDiagnosticsMenu
        }
        "about" {
            Write-RGB "📖 О ПРОГРАММЕ:" -FC Material_Blue -Style Bold -newline
            Write-RGB "  Modern PowerShell Profile" -FC Material_Green -newline
            Write-RGB "  Версия: 2.0" -FC Material_Green -newline
            Write-RGB "  Создано с ❤️ для удобной работы" -FC Material_Green -newline
            Write-RGB "  🇺🇦 Слава Україні!" -FC UkraineBlueRGB -newline
            Wait-KeyPress
            Show-HelpDiagnosticsMenu
        }
        "back" {
            Show-ModernMainMenu
        }
    }
}

function Show-ExitAnimation {
    Write-RGB "`n👋 " -FC White
    $goodbye = "До свидания! Слава Україні! 🇺🇦"
    for ($i = 0; $i -lt $goodbye.Length; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems $goodbye.Length -StartColor "#FFD700" -EndColor "#0057B7"
        Write-RGB $goodbye[$i] -FC $color
        Start-Sleep -Milliseconds 50
    }
    Write-RGB "" -newline
}



# Экспорт функций не требуется для скриптов
# Все функции доступны автоматически после загрузки файла

# Обновление алиасов для новой версии
if (Get-Command Set-Alias -ErrorAction SilentlyContinue) {
    Set-Alias -Name menu -Value Show-ModernMainMenu -Force
    Set-Alias -Name mm -Value Show-ModernMainMenu -Force
}

Trace-ImportProcess ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))
