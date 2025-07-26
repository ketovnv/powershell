# Oh My Posh Custom Segments

Система кастомных сегментов для Oh My Posh, использующая переменные окружения для быстрого отображения системной информации.

## Возможности

- 🌤️ **Weather**: Погода с OpenWeatherMap API
- 🌐 **Network**: Статус сетевого подключения
- 💻 **System Health**: CPU, память, температура
- 💾 **Disk Usage**: Использование диска C:
- ⚙️ **Process Info**: Информация о процессах

## Установка

Сегменты автоматически инициализируются при запуске PowerShell через профиль.

## Команды управления

```powershell
# Показать текущие значения сегментов
Show-OmpSegments  # или omps

# Протестировать все сегменты
Test-OmpSegments  # или ompt

# Сбросить и перезапустить
Reset-OmpSegments  # или ompr

# Справка по командам
Show-OmpHelp  # или omph

# Ручное обновление отдельных сегментов
Update-WeatherSegment
Update-NetworkSegment
Update-SystemHealthSegment
Update-DiskUsageSegment
Update-ProcessInfoSegment
```

## Настройка API погоды

Для получения реальной погоды:

1. Зарегистрируйтесь на [OpenWeatherMap](https://openweathermap.org/api)
2. Получите бесплатный API ключ
3. Установите его:
```powershell
Set-WeatherApiKey "your_api_key_here"
```

## Архитектура

### Файлы системы:
- `Weather.ps1` - Сегмент погоды
- `Network.ps1` - Сегмент сети
- `SystemHealth.ps1` - Сегмент системного здоровья
- `DiskUsage.ps1` - Сегмент использования диска
- `ProcessInfo.ps1` - Сегмент процессов
- `SegmentUpdater.ps1` - Главный updater
- `OmpCommands.ps1` - Команды управления

### Переменные окружения:
- `$env:OMP_WEATHER` - Погода
- `$env:OMP_NETWORK` - Сеть
- `$env:OMP_SYSTEM_HEALTH` - Система
- `$env:OMP_DISK_USAGE` - Диск
- `$env:OMP_PROCESS_INFO` - Процессы
- `$env:OMP_LAST_UPDATE` - Время обновления

### Фоновое обновление:
Система автоматически обновляет переменные каждые 30 секунд в фоновом режиме, обеспечивая мгновенный отклик prompt'а без задержек.

## Производительность

- ✅ Мгновенный отклик prompt'а
- ✅ Фоновое обновление данных
- ✅ Устойчивость к ошибкам
- ✅ Кэширование результатов

## Кастомизация

Каждый сегмент можно легко модифицировать:

1. Отредактируйте соответствующий `.ps1` файл
2. Запустите `Reset-OmpSegments` для применения изменений

## Устранение неполадок

```powershell
# Проверить работу всех сегментов
Test-OmpSegments

# Посмотреть текущие значения
Show-OmpSegments

# Перезапустить систему
Reset-OmpSegments

# Остановить фоновое обновление
Stop-OmpSegmentUpdater

# Запустить заново
Start-OmpSegmentUpdater
```

## Логи

Система выводит информационные сообщения о статусе инициализации и обновлений в консоль PowerShell.