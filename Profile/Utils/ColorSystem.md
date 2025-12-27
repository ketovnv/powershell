# ColorSystem Documentation

## Обзор системы цветов

Модернизированная система цветов PowerShell профиля представляет собой централизованную архитектуру управления цветами, темами и градиентами. Система состоит из трех основных компонентов:

- **ColorManager.ps1** - Централизованный менеджер цветов и тем
- **Colors.ps1** - Базовая цветовая система и утилиты
- **NiceColors.ps1** - Высокоуровневые функции для работы с цветами

## Архитектура

### ColorManager.ps1
Централизованный модуль управления цветами с поддержкой:
- **Цветовых палитр** (Nord, Dracula, Material, Cyber, OneDark, Ukraine)
- **Цветовых тем** (Default, Dark, Ukraine, Nord, Dracula)
- **Градиентной системы** с 5 алгоритмами
- **Кеширования** для производительности
- **Диагностики** и тестирования

### Colors.ps1
Базовая система с:
- Инициализацией поддержки PSStyle
- Функциями для работы с файлами и директориями
- Радужными градиентами
- Обратной совместимостью

### NiceColors.ps1
Высокоуровневые функции:
- `Write-RGB` - универсальный вывод цветного текста
- Градиентные эффекты и анимация
- Радужные тексты
- Статусные сообщения
- Заголовки и UI элементы

## Основные функции

### Управление темами

```powershell
# Установка темы
Set-ColorTheme -ThemeName "Nord"

# Получение цвета из темы
$primaryColor = Get-ThemeColor -ColorType "Primary"

# Просмотр всех тем
Show-ColorThemes
```

### Вывод цветного текста

```powershell
# Простой вывод
Write-RGB "Hello World" -FC "Material_Blue" -Style Bold

# Градиентный текст
Write-GradientText "PowerShell" -StartColor "#FF0000" -EndColor "#0000FF"

# Радужный текст
"Rainbow Text" | Write-Rainbow -Mode Char

# Статусные сообщения
Write-Status "Операция завершена" -Success
```

### Градиентная система

```powershell
# Создание градиентной палитры
$palette = New-GradientPalette -Steps 256 -StartColor "#FF0000" -EndColor "#0000FF"

# Предустановленные градиенты
$gradient = Get-PresetGradient -Style "Ocean"

# Градиенты для меню
$menuColor = Get-MenuGradientColor -Index 2 -Total 10 -Style "Fire"
```

## Цветовые палитры

### Доступные палитры

1. **Nord** - Спокойные арктические тона
2. **Dracula** - Яркая контрастная палитра
3. **Material** - Google Material Design
4. **Cyber** - Неоновые синтвейв цвета
5. **OneDark** - Популярная VS Code тема
6. **Ukraine** - Украинские национальные цвета

### Цветовые темы

- **Default** - Стандартная тема с синими акцентами
- **Dark** - Темная тема для комфортной работы
- **Ukraine** - Тема в украинских цветах
- **Nord** - Тема в стиле Nord
- **Dracula** - Тема в стиле Dracula

## Производительность

### Кеширование
Система автоматически кеширует:
- Конвертации HEX ↔ RGB
- Градиентные цвета
- Цвета тем
- Цвета файлов

```powershell
# Просмотр статистики кеша
Get-ColorCacheStats

# Очистка кеша
Clear-ColorCache -CacheType All

# Оптимизация системы
Optimize-ColorSystem -PrecomputeCommonGradients
```

### Диагностика
```powershell
# Тестирование системы
Test-ColorSystem

# Просмотр всех цветов
Show-ColorThemes
```

## Примеры использования

### Создание красивого заголовка
```powershell
Show-RGBHeader -Title "МОЯ ПРОГРАММА" -StartColor "#FF6B6B" -EndColor "#4ECDC4"
```

### Градиентное меню
```powershell
$items = @("Опция 1", "Опция 2", "Опция 3", "Опция 4")
for ($i = 0; $i -lt $items.Count; $i++) {
    $color = Get-MenuGradientColor -Index $i -Total $items.Count -Style "Ocean"
    Write-RGB "$($i+1). $($items[$i])" -FC $color
}
```

### Анимированный текст
```powershell
Write-Rainbow -Text "ЗАГРУЗКА..." -Mode Char -Animated -Speed 100 -Loop
```

### Статусная панель
```powershell
Write-Status "Проверка системы..." -Info
Write-Status "Файлы загружены" -Success
Write-Status "Обнаружены ошибки" -Warning
Write-Status "Критическая ошибка" -Critical
```

## Расширяемость

### Добавление новой палитры
```powershell
$newPalette = @{
    CustomColor1 = "#FF5733"
    CustomColor2 = "#33FF57"
    CustomColor3 = "#3357FF"
}

Register-ColorPalette -Name "Custom" -Palette $newPalette
```

### Создание новой темы
```powershell
$customTheme = @{
    Primary = "#FF5733"
    Secondary = "#33FF57"
    Success = "#00FF00"
    Warning = "#FFFF00"
    Error = "#FF0000"
    Info = "#00FFFF"
    Background = "#1E1E1E"
    Foreground = "#FFFFFF"
}

Register-ColorTheme -Name "CustomTheme" -Theme $customTheme
Set-ColorTheme -ThemeName "CustomTheme"
```

## Совместимость

Система поддерживает обратную совместимость со старым кодом:
- Все старые имена цветов продолжают работать
- Функции `Write-RGB` поддерживают старые параметры
- Глобальная переменная `$global:RGB` сохраняется

## Производительные советы

1. Используйте `-UseCache` для часто вызываемых градиентов
2. Предварительно генерируйте палитры для статических элементов
3. Очищайте кеш при смене темы
4. Используйте системные цвета для максимальной производительности

## Отладка

```powershell
# Проверка поддержки PSStyle
Test-ColorSupport

# Тестирование конвертации цветов
Test-ColorSystem

# Просмотр доступных цветов
Show-ColorThemes
```

Эта документация охватывает основные аспекты работы с новой системой цветов. Для более детальной информации смотрите комментарии в исходном коде функций.