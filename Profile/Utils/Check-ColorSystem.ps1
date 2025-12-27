Trace-ImportProcess ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

# Check-ColorSystem.ps1 - Скрипт проверки работы системы цветов
<#
.SYNOPSIS
    Проверяет корректность работы системы цветов и выводит диагностическую информацию

.DESCRIPTION
    Этот скрипт проверяет все компоненты системы цветов:
    - Поддержку PSStyle
    - Загрузку ColorManager
    - Работу цветовых палитр
    - Функции вывода
    - Градиентную систему
    - Кеширование

.PARAMETER Quick
    Быстрая проверка только основных функций

.PARAMETER Verbose
    Подробный вывод диагностической информации

.EXAMPLE
    Check-ColorSystem

.EXAMPLE
    Check-ColorSystem -Quick

.NOTES
    Author: PowerShell Profile System
    Version: 1.0.0
#>

function Check-ColorSystem {
    [CmdletBinding()]
    param(
        [switch]$Quick,
        [switch]$Verbose
    )

    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Host "🔍 ПРОВЕРКА СИСТЕМЫ ЦВЕТОВ" -ForegroundColor Yellow
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host ""

    # 1. Проверка поддержки PSStyle
    Write-Host "1. ПРОВЕРКА PSStyle" -ForegroundColor Green
    $colorSupport = Test-ColorSupport
    if ($colorSupport) {
        Write-Host "   ✓ PSStyle поддерживается" -ForegroundColor Green
        if ($Verbose) {
            Write-Host "   Версия PowerShell: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
            Write-Host "   PSStyle доступен: $($null -ne $PSStyle)" -ForegroundColor Gray
        }
    } else {
        Write-Host "   ✗ PSStyle не поддерживается" -ForegroundColor Red
        Write-Host "   Используется fallback режим" -ForegroundColor Yellow
    }
    Write-Host ""

    if (-not $colorSupport -and $Quick) {
        Write-Host "⚠️  PSStyle не поддерживается - пропуск дальнейших проверок" -ForegroundColor Yellow
        return
    }

    # 2. Проверка загрузки ColorManager
    Write-Host "2. ПРОВЕРКА ColorManager" -ForegroundColor Green
    $colorManagerLoaded = $null -ne (Get-Command "Get-ColorTheme" -ErrorAction SilentlyContinue)
    if ($colorManagerLoaded) {
        Write-Host "   ✓ ColorManager загружен" -ForegroundColor Green
        if ($Verbose) {
            $currentTheme = Get-ColorTheme
            Write-Host "   Текущая тема: $($script:ColorManagerConfig.CurrentTheme)" -ForegroundColor Gray
            Write-Host "   Доступно тем: $(($global:ColorThemes.Keys).Count)" -ForegroundColor Gray
        }
    } else {
        Write-Host "   ✗ ColorManager не загружен" -ForegroundColor Red
    }
    Write-Host ""

    # 3. Проверка цветовых палитр
    Write-Host "3. ПРОВЕРКА ЦВЕТОВЫХ ПАЛИТР" -ForegroundColor Green
    $palettesLoaded = $null -ne $global:ColorPalettes
    if ($palettesLoaded) {
        Write-Host "   ✓ Цветовые палитры загружены" -ForegroundColor Green
        if ($Verbose) {
            Write-Host "   Доступно палитр: $(($global:ColorPalettes.Keys).Count)" -ForegroundColor Gray
            foreach ($paletteName in $global:ColorPalettes.Keys) {
                Write-Host "     - $paletteName ($(($global:ColorPalettes[$paletteName].Keys).Count) цветов)" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "   ✗ Цветовые палитры не загружены" -ForegroundColor Red
    }
    Write-Host ""

    # 4. Проверка глобальной палитры RGB
    Write-Host "4. ПРОВЕРКА ГЛОБАЛЬНОЙ ПАЛИТРЫ" -ForegroundColor Green
    $rgbPaletteLoaded = $null -ne $global:RGB -and $global:RGB.Count -gt 0
    if ($rgbPaletteLoaded) {
        Write-Host "   ✓ Глобальная палитра RGB загружена" -ForegroundColor Green
        if ($Verbose) {
            Write-Host "   Цветов в палитре: $($global:RGB.Count)" -ForegroundColor Gray
        }
    } else {
        Write-Host "   ✗ Глобальная палитра RGB не загружена" -ForegroundColor Red
    }
    Write-Host ""

    if ($Quick) {
        Write-Host "✅ БАЗОВАЯ ПРОВЕРКА ЗАВЕРШЕНА" -ForegroundColor Green
        return
    }

    # 5. Проверка основных функций вывода
    Write-Host "5. ПРОВЕРКА ФУНКЦИЙ ВЫВОДА" -ForegroundColor Green

    # Проверка Write-RGB
    Write-Host "   Write-RGB: " -NoNewline -ForegroundColor White
    try {
        Write-RGB "✓ Работает" -FC "Material_Green" -NoNewline
        Write-Host "" -ForegroundColor Green
    } catch {
        Write-Host "✗ Ошибка: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Проверка Write-GradientText
    Write-Host "   Write-GradientText: " -NoNewline -ForegroundColor White
    try {
        Write-GradientText "✓ Работает" -StartColor "#FF0000" -EndColor "#0000FF" -NoNewline
        Write-Host "" -ForegroundColor Green
    } catch {
        Write-Host "✗ Ошибка: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Проверка Write-Rainbow
    Write-Host "   Write-Rainbow: " -NoNewline -ForegroundColor White
    try {
        "✓ Работает" | Write-Rainbow -Mode Char -NoNewline
        Write-Host "" -ForegroundColor Green
    } catch {
        Write-Host "✗ Ошибка: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""

    # 6. Проверка градиентной системы
    Write-Host "6. ПРОВЕРКА ГРАДИЕНТНОЙ СИСТЕМЫ" -ForegroundColor Green

    # Проверка Get-GradientColor
    Write-Host "   Get-GradientColor: " -NoNewline -ForegroundColor White
    try {
        $gradientColor = Get-GradientColor -Index 5 -TotalItems 10 -StartColor "#FF0000" -EndColor "#0000FF"
        if ($gradientColor -match '^#[0-9A-Fa-f]{6}$') {
            Write-Host "✓ Работает ($gradientColor)" -ForegroundColor Green
        } else {
            Write-Host "✗ Некорректный результат: $gradientColor" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ Ошибка: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Проверка предустановленных градиентов
    Write-Host "   Предустановленные градиенты: " -NoNewline -ForegroundColor White
    try {
        $presets = @("Ocean", "Fire", "Rainbow")
        foreach ($preset in $presets) {
            $gradient = Get-PresetGradient -Style $preset
            if ($gradient.Start -and $gradient.End) {
                Write-Host "$preset " -NoNewline -ForegroundColor Green
            } else {
                Write-Host "$preset " -NoNewline -ForegroundColor Red
            }
        }
        Write-Host "" -ForegroundColor Green
    } catch {
        Write-Host "✗ Ошибка: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""

    # 7. Проверка кеширования
    Write-Host "7. ПРОВЕРКА КЕШИРОВАНИЯ" -ForegroundColor Green

    try {
        $cacheStats = Get-ColorCacheStats
        Write-Host "   ✓ Система кеширования работает" -ForegroundColor Green
        if ($Verbose) {
            Write-Host "   Конвертации: $($cacheStats.ColorConversions)" -ForegroundColor Gray
            Write-Host "   Градиенты: $($cacheStats.GradientColors)" -ForegroundColor Gray
            Write-Host "   Файлы: $($cacheStats.FileColors)" -ForegroundColor Gray
            Write-Host "   Темы: $($cacheStats.ThemeColors)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "   ✗ Ошибка кеширования: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""

    # 8. Проверка управления темами
    Write-Host "8. ПРОВЕРКА УПРАВЛЕНИЯ ТЕМАМИ" -ForegroundColor Green

    try {
        $themes = @("Default", "Dark", "Ukraine")
        foreach ($theme in $themes) {
            Set-ColorTheme -ThemeName $theme
            $themeColor = Get-ThemeColor -ColorType "Primary"
            if ($themeColor -match '^#[0-9A-Fa-f]{6}$') {
                Write-Host "   $theme: ✓" -ForegroundColor Green
            } else {
                Write-Host "   $theme: ✗" -ForegroundColor Red
            }
        }
        # Возвращаем тему по умолчанию
        Set-ColorTheme -ThemeName "Default"
    } catch {
        Write-Host "   ✗ Ошибка управления темами: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""

    # 9. Итоговый отчет
    Write-Host "9. ИТОГОВЫЙ ОТЧЕТ" -ForegroundColor Green

    $checks = @(
        @{ Name = "PSStyle поддержка"; Result = $colorSupport },
        @{ Name = "ColorManager загрузка"; Result = $colorManagerLoaded },
        @{ Name = "Цветовые палитры"; Result = $palettesLoaded },
        @{ Name = "Глобальная палитра"; Result = $rgbPaletteLoaded }
    )

    $passed = ($checks | Where-Object { $_.Result }).Count
    $total = $checks.Count

    Write-Host "   Пройдено проверок: $passed/$total" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })

    if ($passed -eq $total) {
        Write-Host "   ✅ СИСТЕМА ЦВЕТОВ РАБОТАЕТ КОРРЕКТНО" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  ОБНАРУЖЕНЫ ПРОБЛЕМЫ В СИСТЕМЕ ЦВЕТОВ" -ForegroundColor Yellow
        Write-Host "   Используйте -Verbose для подробной информации" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host "🔍 ПРОВЕРКА ЗАВЕРШЕНА" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host ""
}

# Экспорт функции
Export-ModuleMember -Function Check-ColorSystem

Write-Verbose "Check-ColorSystem загружен"

Trace-ImportProcess ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))
