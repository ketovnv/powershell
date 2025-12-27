Trace-ImportProcess ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

# MenuBehavior.ps1 - Глобальная система управления поведением функций меню
<#
.SYNOPSIS
    Централизованная система для управления поведением функций меню в зависимости от контекста вызова

.DESCRIPTION
    Этот модуль предоставляет функции для интеллектуального определения контекста вызова
    и соответствующего управления поведением функций меню. Решает проблему автоматического
    возврата в меню при прямом вызове функций из консоли.

.NOTES
    Author: PowerShell Profile System
    Version: 1.0.0
#>

#region Конфигурация системы
$script:MenuBehaviorConfig = @{
    Version = "1.0.0"
    AutoDetectionEnabled = $true
    DebugMode = $false

    # Паттерны для определения вызова из меню
    MenuPatterns = @(
        "*Menu*",
        "Show-*Menu*",
        "Show-MainMenu",
        "Show-*Menu",
        "*ShowMenu*",
        "Menu*"
    )

    # Функции, которые должны возвращаться в меню
    MenuReturnFunctions = @(
        "Show-PowerShellConfigMenu",
        "Show-ProfileSettingsMenu",
        "Show-MainMenu",
        "Show-ColorSchemeMenu"
    )

    # Функции, которые не должны возвращаться в меню
    NoReturnFunctions = @(
        "Exit",
        "Quit",
        "Stop-Process"
    )
}

# Глобальная переменная для принудительного управления поведением
$global:MenuBehaviorForceMode = $null  # null=auto, "menu"=force menu, "console"=force console
#endregion

#region Основные функции определения контекста
function Test-CalledFromMenu {
    <#
    .SYNOPSIS
        Определяет, была ли функция вызвана из меню

    .DESCRIPTION
        Анализирует стек вызовов и определяет, была ли текущая функция
        вызвана из какого-либо меню системы.

    .EXAMPLE
        if (Test-CalledFromMenu) {
            # Вернуться в меню после выполнения
            Show-PowerShellConfigMenu
        } else {
            # Завершить выполнение в консоли
            Write-Host "Функция завершена" -ForegroundColor Green
        }
    #>

    if (-not $script:MenuBehaviorConfig.AutoDetectionEnabled) {
        return $false
    }

    # Принудительный режим
    if ($global:MenuBehaviorForceMode -eq "menu") { return $true }
    if ($global:MenuBehaviorForceMode -eq "console") { return $false }

    $callStack = Get-PSCallStack

    # Пропускаем текущую функцию
    $relevantStack = $callStack | Select-Object -Skip 1

    foreach ($call in $relevantStack) {
        $command = $call.Command

        # Проверяем паттерны меню
        foreach ($pattern in $script:MenuBehaviorConfig.MenuPatterns) {
            if ($command -like $pattern) {
                if ($script:MenuBehaviorConfig.DebugMode) {
                    Write-Host "[MenuBehavior] Обнаружен вызов из меню: $command" -ForegroundColor Yellow
                }
                return $true
            }
        }

        # Проверяем функции, которые не должны возвращаться
        if ($command -in $script:MenuBehaviorConfig.NoReturnFunctions) {
            if ($script:MenuBehaviorConfig.DebugMode) {
                Write-Host "[MenuBehavior] Обнаружена функция без возврата: $command" -ForegroundColor Yellow
            }
            return $false
        }
    }

    return $false
}

function Get-CallingContext {
    <#
    .SYNOPSIS
        Возвращает подробную информацию о контексте вызова

    .DESCRIPTION
        Анализирует стек вызовов и возвращает структурированную информацию
        о том, откуда была вызвана текущая функция.

    .OUTPUTS
        PSCustomObject с информацией о контексте вызова
    #>

    $callStack = Get-PSCallStack | Select-Object -Skip 1

    $context = [PSCustomObject]@{
        CalledFromMenu = $false
        CallingFunction = $callStack[0].Command
        FullCallStack = $callStack
        MenuFunctions = @()
        Depth = $callStack.Count
    }

    foreach ($call in $callStack) {
        foreach ($pattern in $script:MenuBehaviorConfig.MenuPatterns) {
            if ($call.Command -like $pattern) {
                $context.CalledFromMenu = $true
                $context.MenuFunctions += $call.Command
                break
            }
        }
    }

    return $context
}
#endregion

#region Функции управления поведением
function Invoke-MenuAwareAction {
    <#
    .SYNOPSIS
        Выполняет действие с автоматическим определением поведения после завершения

    .DESCRIPTION
        Универсальная функция для выполнения действий, которая автоматически
        определяет, нужно ли возвращаться в меню после завершения.

    .PARAMETER Action
        Скриптблок с действием для выполнения

    .PARAMETER SuccessMessage
        Сообщение, которое будет показано при успешном завершении

    .PARAMETER ReturnMenu
        Меню, в которое нужно вернуться (по умолчанию определяется автоматически)

    .PARAMETER ForceBehavior
        Принудительно задает поведение: "menu", "console" или "auto"

    .EXAMPLE
        Invoke-MenuAwareAction -Action {
            Show-AllColors
        } -SuccessMessage "Демонстрация цветов завершена"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Action,

        [string]$SuccessMessage = "Действие завершено",

        [string]$ReturnMenu,

        [ValidateSet("menu", "console", "auto")]
        [string]$ForceBehavior = "auto"
    )

    # Сохраняем текущий режим и устанавливаем принудительный если нужно
    $previousForceMode = $global:MenuBehaviorForceMode
    if ($ForceBehavior -ne "auto") {
        $global:MenuBehaviorForceMode = $ForceBehavior
    }

    try {
        # Выполняем действие
        & $Action

        # Определяем поведение после выполнения
        $shouldReturnToMenu = Test-CalledFromMenu

        if ($shouldReturnToMenu) {
            # Определяем меню для возврата
            $targetMenu = $ReturnMenu
            if (-not $targetMenu) {
                $context = Get-CallingContext
                $targetMenu = if ($context.MenuFunctions.Count -gt 0) {
                    $context.MenuFunctions[0]
                } else {
                    "Show-MainMenu"
                }
            }

            # Пауза и возврат в меню
            Write-Host "`n⏎ Нажмите любую клавишу для продолжения..." -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

            if (Get-Command $targetMenu -ErrorAction SilentlyContinue) {
                & $targetMenu
            } else {
                Write-Host "❌ Меню '$targetMenu' не найдено" -ForegroundColor Red
                Write-Host "💡 Возврат в главное меню..." -ForegroundColor Yellow
                if (Get-Command "Show-MainMenu" -ErrorAction SilentlyContinue) {
                    Show-MainMenu
                }
            }
        } else {
            # Завершение в консоли
            Write-Host "`n✅ $SuccessMessage" -ForegroundColor Green
            if (-not $ReturnMenu) {
                Write-Host "💡 Для возврата в меню используйте Show-MainMenu" -ForegroundColor Cyan
            }
        }
    }
    catch {
        Write-Host "❌ Ошибка при выполнении действия: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
    finally {
        # Восстанавливаем предыдущий режим
        $global:MenuBehaviorForceMode = $previousForceMode
    }
}

function Register-MenuFunction {
    <#
    .SYNOPSIS
        Регистрирует функцию как меню-функцию с автоматическим поведением

    .DESCRIPTION
        Создает обертку вокруг функции, которая автоматически управляет
        поведением после выполнения.

    .PARAMETER FunctionName
        Имя функции для регистрации

    .PARAMETER ReturnMenu
        Меню для возврата (по умолчанию определяется автоматически)

    .EXAMPLE
        Register-MenuFunction -FunctionName "Show-AllColors" -ReturnMenu "Show-PowerShellConfigMenu"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$FunctionName,

        [string]$ReturnMenu
    )

    if (-not (Get-Command $FunctionName -ErrorAction SilentlyContinue)) {
        Write-Warning "Функция '$FunctionName' не найдена. Регистрация пропущена."
        return
    }

    # Создаем обертку
    $wrapperName = "${FunctionName}_MenuAware"

    if (Get-Command $wrapperName -ErrorAction SilentlyContinue) {
        Write-Verbose "Обертка для '$FunctionName' уже существует"
        return
    }



    $wrapperScript = @"
    function $wrapperName {
        param(`$ForceBehavior = "auto")

        Invoke-MenuAwareAction -Action {
            $FunctionName @args
        } -SuccessMessage "Функция `$($FunctionName) завершена" -ReturnMenu "$ReturnMenu" -ForceBehavior `$ForceBehavior
    }
"@

    # Создаем обертку
    Invoke-Expression $wrapperScript

    # Создаем алиас для обратной совместимости
    Set-Alias -Name $FunctionName -Value $wrapperName -Scope Global


    Write-Verbose "Зарегистрирована меню-функция: $FunctionName -> $wrapperName"
}
#endregion

#region Утилиты отладки и диагностики
function Show-MenuBehaviorInfo {
    <#
    .SYNOPSIS
        Показывает информацию о текущем состоянии системы поведения меню

    .DESCRIPTION
        Выводит диагностическую информацию о контексте вызова,
        зарегистрированных функциях и текущих настройках.
    #>

    Write-Host "`n🔍 ИНФОРМАЦИЯ О ПОВЕДЕНИИ МЕНЮ" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Cyan
    Write-Host ""

    # Текущий контекст
    $context = Get-CallingContext
    Write-Host "📋 ТЕКУЩИЙ КОНТЕКСТ:" -ForegroundColor Green
    Write-Host "   Вызвано из меню: " -NoNewline
    Write-Host $(if ($context.CalledFromMenu) { "✅ Да" } else { "❌ Нет" }) -ForegroundColor $(if ($context.CalledFromMenu) { "Green" } else { "Yellow" })
    Write-Host "   Вызывающая функция: $($context.CallingFunction)" -ForegroundColor Gray
    Write-Host "   Глубина стека: $($context.Depth)" -ForegroundColor Gray

    if ($context.MenuFunctions.Count -gt 0) {
        Write-Host "   Обнаруженные меню:" -ForegroundColor Gray
        foreach ($menu in $context.MenuFunctions) {
            Write-Host "     - $menu" -ForegroundColor Gray
        }
    }

    Write-Host ""

    # Настройки системы
    Write-Host "⚙️  НАСТРОЙКИ СИСТЕМЫ:" -ForegroundColor Green
    Write-Host "   Версия: $($script:MenuBehaviorConfig.Version)" -ForegroundColor Gray
    Write-Host "   Авто-определение: " -NoNewline
    Write-Host $(if ($script:MenuBehaviorConfig.AutoDetectionEnabled) { "✅ Включено" } else { "❌ Выключено" }) -ForegroundColor $(if ($script:MenuBehaviorConfig.AutoDetectionEnabled) { "Green" } else { "Red" })
    Write-Host "   Режим отладки: " -NoNewline
    Write-Host $(if ($script:MenuBehaviorConfig.DebugMode) { "✅ Включен" } else { "❌ Выключен" }) -ForegroundColor $(if ($script:MenuBehaviorConfig.DebugMode) { "Yellow" } else { "Gray" })
    Write-Host "   Принудительный режим: " -NoNewline
    Write-Host $(if ($global:MenuBehaviorForceMode) { $global:MenuBehaviorForceMode } else { "auto" }) -ForegroundColor Gray

    Write-Host ""
    Write-Host "💡 РЕКОМЕНДАЦИИ:" -ForegroundColor Cyan
    Write-Host "   - Используйте Invoke-MenuAwareAction для новых функций" -ForegroundColor Gray
    Write-Host "   - Используйте Register-MenuFunction для существующих функций" -ForegroundColor Gray
    Write-Host "   - Для отладки включите DebugMode" -ForegroundColor Gray

    Write-Host ""
    Write-Host "=" * 50 -ForegroundColor Cyan
    Write-Host "🔍 ИНФОРМАЦИЯ ПОКАЗАНА" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Cyan
    Write-Host ""
}

function Set-MenuBehaviorMode {
    <#
    .SYNOPSIS
        Устанавливает режим поведения системы меню

    .PARAMETER Mode
        Режим работы: "auto", "menu", "console"

    .PARAMETER EnableDebug
        Включает режим отладки

    .PARAMETER DisableAutoDetection
        Отключает автоматическое определение контекста
    #>

    [CmdletBinding()]
    param(
        [ValidateSet("auto", "menu", "console")]
        [string]$Mode = "auto",

        [switch]$EnableDebug,

        [switch]$DisableAutoDetection
    )

    $global:MenuBehaviorForceMode = if ($Mode -eq "auto") { $null } else { $Mode }
    $script:MenuBehaviorConfig.DebugMode = $EnableDebug.IsPresent
    $script:MenuBehaviorConfig.AutoDetectionEnabled = -not $DisableAutoDetection.IsPresent

    Write-Host "✅ Настройки поведения меню обновлены:" -ForegroundColor Green
    Write-Host "   Режим: $Mode" -ForegroundColor Gray
    Write-Host "   Отладка: $(if ($script:MenuBehaviorConfig.DebugMode) { 'включена' } else { 'выключена' })" -ForegroundColor Gray
    Write-Host "   Авто-определение: $(if ($script:MenuBehaviorConfig.AutoDetectionEnabled) { 'включено' } else { 'выключено' })" -ForegroundColor Gray
}
#endregion

#region Инициализация системы
function Initialize-MenuBehaviorSystem {
    <#
    .SYNOPSIS
        Инициализирует систему поведения меню

    .DESCRIPTION
        Регистрирует основные функции меню для автоматического управления поведением.
        Эта функция должна вызываться при загрузке профиля.
    #>

    Write-Verbose "Инициализация системы поведения меню..."

    # Регистрация меню-функций отключена - обработка происходит напрямую в ModernMainMenu.ps1
    # Это позволяет вызывать функции как из меню, так и из командной строки
    Write-Verbose "Система поведения меню инициализирована (прямой режим)"

    # Write-Verbose "Система поведения меню инициализирована ($($menuFunctions.Count) функций зарегистрировано)"
}

# Отложенная инициализация - вызывается после загрузки всех функций
function Initialize-MenuBehaviorSystemDelayed {
    <#
    .SYNOPSIS
        Отложенная инициализация системы поведения меню

    .DESCRIPTION
        Регистрирует основные функции меню для автоматического управления поведением.
        Эта функция должна вызываться после загрузки всех функций меню.
    #>

    Write-Verbose "Отложенная инициализация системы поведения меню..."

    # Регистрация меню-функций отключена - обработка происходит напрямую в ModernMainMenu.ps1
    # Это позволяет вызывать функции как из меню, так и из командной строки
    Write-Verbose "Система поведения меню инициализирована (прямой режим)"
}

# Экспортируем функцию для внешнего вызова
# Export-ModuleMember -Function Initialize-MenuBehaviorSystemDelayed
#endregion


Write-Verbose "MenuBehavior загружен - версия $($script:MenuBehaviorConfig.Version)"

Trace-ImportProcess ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))
