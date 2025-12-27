Trace-ImportProcess ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

# ColorDiagnostics.ps1 - Простой диагностический скрипт для системы цветов
<#
.SYNOPSIS
    Простой диагностический скрипт для проверки системы цветов

.DESCRIPTION
    Этот скрипт проверяет базовую функциональность системы цветов
    без сложных зависимостей.

.NOTES
    Author: PowerShell Profile System
    Version: 1.0.0
#>

function Test-ColorBasic {
    <#
    .SYNOPSIS
        Базовая проверка системы цветов
    #>

    Write-Host "`n🎨 БАЗОВАЯ ДИАГНОСТИКА СИСТЕМЫ ЦВЕТОВ" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Cyan
    Write-Host ""

    # 1. Проверка PSStyle
    Write-Host "1. PSStyle поддержка:" -ForegroundColor Green
    if ($null -ne $PSStyle) {
        Write-Host "   ✓ ДОСТУПЕН" -ForegroundColor Green
    } else {
        Write-Host "   ✗ НЕДОСТУПЕН" -ForegroundColor Red
    }

    # 2. Проверка глобальной палитры
    Write-Host "2. Глобальная палитра:" -ForegroundColor Green
    if ($global:RGB -and $global:RGB.Count -gt 0) {
        Write-Host "   ✓ ЗАГРУЖЕНА ($($global:RGB.Count) цветов)" -ForegroundColor Green
    } else {
        Write-Host "   ✗ НЕ ЗАГРУЖЕНА" -ForegroundColor Red
    }

    # 3. Простой тест цветов
    Write-Host "3. Тест основных цветов:" -ForegroundColor Green

    $testColors = @(
        @{ Name = "Красный"; Color = "Red" },
        @{ Name = "Зеленый"; Color = "Green" },
        @{ Name = "Синий"; Color = "Blue" },
        @{ Name = "Желтый"; Color = "Yellow" },
        @{ Name = "Белый"; Color = "White" }
    )

    foreach ($test in $testColors) {
        Write-Host "   $($test.Name): " -NoNewline -ForegroundColor White
        Write-Host "████" -NoNewline -ForegroundColor $test.Color
        Write-Host " ✓" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "=" * 50 -ForegroundColor Cyan
    Write-Host "🎨 ДИАГНОСТИКА ЗАВЕРШЕНА" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Cyan
    Write-Host ""
}

# Экспорт функции
Export-ModuleMember -Function Test-ColorBasic

Write-Verbose "ColorDiagnostics загружен"

Trace-ImportProcess ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))
