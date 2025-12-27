<#
.SYNOPSIS
    Проверка состояния системы поведения меню

.DESCRIPTION
    Проверяет корректность работы системы MenuBehavior и наличие всех необходимых функций

.NOTES
    Автор: Claude Code
    Дата: 12.10.2025
#>

function Check-MenuBehavior {
    Write-Host "`n🔍 ПРОВЕРКА СИСТЕМЫ ПОВЕДЕНИЯ МЕНЮ" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Cyan
    Write-Host ""

    # Список функций для проверки
    $functionsToCheck = @(
        "Show-ColorThemes",
        "Show-TestGradientFull",
        "Show-ColorSystemDemo",
        "Show-AllColors",
        "Show-AllEmojis"
    )

    # Проверка основных функций
    Write-Host "📋 ОСНОВНЫЕ ФУНКЦИИ:" -ForegroundColor Green
    $missingFunctions = @()

    foreach ($func in $functionsToCheck) {
        $exists = Get-Command $func -ErrorAction SilentlyContinue
        Write-Host "   $func: " -NoNewline
        if ($exists) {
            Write-Host "✅ Найдена" -ForegroundColor Green
        } else {
            Write-Host "❌ Не найдена" -ForegroundColor Red
            $missingFunctions += $func
        }
    }

    Write-Host ""

    # Проверка оберток _MenuAware
    Write-Host "📋 ОБЕРТКИ _MenuAware:" -ForegroundColor Green
    $missingWrappers = @()

    foreach ($func in $functionsToCheck) {
        $wrapperName = "${func}_MenuAware"
        $wrapperExists = Get-Command $wrapperName -ErrorAction SilentlyContinue

        Write-Host "   $wrapperName: " -NoNewline
        if ($wrapperExists) {
            Write-Host "✅ Найдена" -ForegroundColor Green
        } else {
            Write-Host "❌ Не найдена" -ForegroundColor Red
            $missingWrappers += $wrapperName
        }
    }

    Write-Host ""

    # Проверка алиасов
    Write-Host "📋 АЛИАСЫ:" -ForegroundColor Green
    $missingAliases = @()

    foreach ($func in $functionsToCheck) {
        $alias = Get-Alias $func -ErrorAction SilentlyContinue
        Write-Host "   Алиас $func: " -NoNewline
        if ($alias) {
            Write-Host "✅ Найден -> $($alias.Definition)" -ForegroundColor Green
        } else {
            Write-Host "❌ Не найден" -ForegroundColor Red
            $missingAliases += $func
        }
    }

    Write-Host ""

    # Проверка инициализации
    Write-Host "📋 СИСТЕМА ИНИЦИАЛИЗАЦИИ:" -ForegroundColor Green

    $initFunc = Get-Command "Initialize-MenuBehaviorSystemDelayed" -ErrorAction SilentlyContinue
    Write-Host "   Initialize-MenuBehaviorSystemDelayed: " -NoNewline
    if ($initFunc) {
        Write-Host "✅ Найдена" -ForegroundColor Green
    } else {
        Write-Host "❌ Не найдена" -ForegroundColor Red
    }

    Write-Host ""

    # Сводка и рекомендации
    Write-Host "🎯 СВОДКА И РЕКОМЕНДАЦИИ:" -ForegroundColor Cyan

    if ($missingFunctions.Count -eq 0 -and $missingWrappers.Count -eq 0) {
        Write-Host "   ✅ Все функции и обертки найдены!" -ForegroundColor Green
        Write-Host "   💡 Система MenuBehavior работает корректно" -ForegroundColor Green
    } else {
        if ($missingFunctions.Count -gt 0) {
            Write-Host "   ❌ Отсутствуют функции: $($missingFunctions -join ', ')" -ForegroundColor Red
            Write-Host "   💡 Решение: Проверьте порядок загрузки в Init.ps1" -ForegroundColor Yellow
        }

        if ($missingWrappers.Count -gt 0) {
            Write-Host "   ❌ Отсутствуют обертки: $($missingWrappers -join ', ')" -ForegroundColor Red
            Write-Host "   💡 Решение: Запустите команду: Initialize-MenuBehaviorSystemDelayed" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "🏁 ПРОВЕРКА ЗАВЕРШЕНА" -ForegroundColor Cyan
}

# Экспортируем функцию
Export-ModuleMember -Function Check-MenuBehavior

# Создаем алиас для удобства
Set-Alias -Name cmb -Value Check-MenuBehavior

Write-Host "✅ Скрипт Check-MenuBehavior загружен" -ForegroundColor Green
Write-Host "   Используйте команду: Check-MenuBehavior или cmb" -ForegroundColor Gray
