# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    🚨 UNIFIED ERROR HANDLER v3.0                           ║
# ║              Объединенная система обработки ошибок PowerShell              ║
# ║                    С полной поддержкой RGB и переводов                     ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

Write-RGB "`nДоступные виды ошибок:" -FC Dracula_Orange -newline
$ErrorViews = (Get-Command ConvertTo-*ErrorView).Name -replace "ConvertTo-(.*)ErrorView", '$1'
$ErrorViews | ForEach-Object { Write-RGB  "  - $_" -FC Dracula_Red}
Write-RGB "`nМеняем на вид:"  -FC Gray
Set-MyErrorView -View "Colorful"
Write-RGB "Colorful"  -FC Dracula_Green
#region Конфигурация
$global:UnifiedErrorConfig = @{
# Основные настройки
    Language = "ru"
    UseColors = $true
    UseEmoji = $true
    UseGradients = $false

    # Уровни детализации
    ShowStackTrace = $false
    ShowInnerExceptions = $true
    ShowScriptLocation = $true
    ShowTimestamp = $true
    ShowErrorId = $true
    ShowCategory = $true
    ShowSuggestions = $true

    # Визуальные настройки
    ColorScheme = "Dracula"  # Dracula, Nord, Material, Cyber, Custom
    GradientStyle = "Fire"   # Fire, Ocean, Nature, Neon
    BorderStyle = "Double"   # Single, Double, Rounded, Heavy, None
    CompactMode = $false

    # Логирование
    LogErrors = $true
    LogPath = "$env:TEMP\PowerShell_Errors_$( Get-Date -Format 'yyyy-MM' ).log"
    LogFormat = "JSON"  # Text, JSON, XML

    # Уведомления
    NotifyOnCritical = $true
    NotificationSound = $false
    DesktopNotification = $false

    # Продвинутые настройки
    MaxErrorWidth = 100
    GroupSimilarErrors = $true
    HistorySize = 50
}

# Цветовые схемы для ошибок
$global:ErrorColorSchemes = @{
    Dracula = @{
        Error = "#FF5555"
        Warning = "#F1FA8C"
        Info = "#8BE9FD"
        Success = "#50FA7B"
        Background = "#282A36"
        Border = "#44475A"
        Text = "#F8F8F2"
        Accent = "#BD93F9"
    }

    Nord = @{
        Error = "#BF616A"
        Warning = "#EBCB8B"
        Info = "#81A1C1"
        Success = "#A3BE8C"
        Background = "#2E3440"
        Border = "#4C566A"
        Text = "#ECEFF4"
        Accent = "#88C0D0"
    }

    Material = @{
        Error = "#F44336"
        Warning = "#FF9800"
        Info = "#2196F3"
        Success = "#4CAF50"
        Background = "#121212"
        Border = "#424242"
        Text = "#FFFFFF"
        Accent = "#BB86FC"
    }

    Cyber = @{
        Error = "#FF006E"
        Warning = "#FFB700"
        Info = "#00FFFF"
        Success = "#00FF88"
        Background = "#0D1117"
        Border = "#30363D"
        Text = "#C9D1D9"
        Accent = "#58A6FF"
    }

    ColorSchemes = @{
        Critical = @{ Start = "#FF0000"; End = "#8B0000"; Icon = "🚨" }
        Error = @{ Start = "#FF6B6B"; End = "#C92A2A"; Icon = "❌" }
        Warning = @{ Start = "#FFD43B"; End = "#FAB005"; Icon = "⚠️" }
        Info = @{ Start = "#4DABF7"; End = "#1C7ED6"; Icon = "ℹ️" }
        Success = @{ Start = "#51CF66"; End = "#37B24D"; Icon = "✅" }
    }

}

# Переводы ошибок (расширенные)
$global:ErrorTranslations = @{
# Общие сообщения
    "Access is denied" = "Доступ запрещён"
    "The term '(.*)' is not recognized" = "Команда '$1' не распознана"
    "Cannot find path '(.*)'" = "Не удается найти путь '$1'"
    "Cannot find drive" = "Не удается найти диск"
    "The file '(.*)' cannot be found" = "Файл '$1' не найден"
    "Cannot convert value" = "Не удается преобразовать значение"
    "Attempted to divide by zero" = "Попытка деления на ноль"
    "Object reference not set" = "Ссылка на объект не установлена"
    "Index was outside the bounds" = "Индекс вышел за пределы массива"
    "The property '(.*)' cannot be found" = "Свойство '$1' не найдено"
    "Cannot validate argument" = "Не удается проверить аргумент"
    "Parameter '(.*)' cannot be found" = "Параметр '$1' не найден"
    "Network path was not found" = "Сетевой путь не найден"
    "Access to the path '(.*)' is denied" = "Доступ к пути '$1' запрещён"
    "Out of memory" = "Недостаточно памяти"
    "Stack overflow" = "Переполнение стека"

    # Типы исключений
    "CommandNotFoundException" = "Команда не найдена"
    "ParameterBindingException" = "Ошибка привязки параметра"
    "ArgumentException" = "Неверный аргумент"
    "UnauthorizedAccessException" = "Нет доступа"
    "FileNotFoundException" = "Файл не найден"
    "DirectoryNotFoundException" = "Папка не найдена"
    "PathTooLongException" = "Слишком длинный путь"
    "InvalidOperationException" = "Недопустимая операция"
    "NotSupportedException" = "Операция не поддерживается"
    "TimeoutException" = "Истекло время ожидания"
    "IOException" = "Ошибка ввода-вывода"
    "NullReferenceException" = "Ссылка на null"
    "OutOfMemoryException" = "Недостаточно памяти"
    "StackOverflowException" = "Переполнение стека"

}



# Расширенные шаблоны ошибок
$global:ErrorTemplates = @{
    CommandNotFoundException = @{
        Icon = "❌"
        Title = "Команда не найдена"
        Pattern = "CommandNotFoundException|term.*not recognized"
        Severity = "Error"
        Suggestions = @(
            "💡 Проверьте правописание команды",
            "💡 Используйте Get-Command для поиска похожих команд",
            "💡 Возможно, нужно установить модуль: Install-Module <имя>"
        )
    }

    UnauthorizedAccessException = @{
        Icon = "🔒"
        Title = "Отказано в доступе"
        Pattern = "UnauthorizedAccessException|Access.*denied"
        Severity = "Critical"
        Suggestions = @(
            "💡 Запустите PowerShell от имени администратора",
            "💡 Проверьте права доступа к файлу/папке",
            "💡 Используйте Get-Acl для просмотра прав"
        )
    }

    FileNotFoundException = @{
        Icon = "📄"
        Title = "Файл не найден"
        Pattern = "FileNotFoundException|cannot find.*file"
        Severity = "Error"
        Suggestions = @(
            "💡 Проверьте путь к файлу",
            "💡 Используйте Test-Path для проверки существования",
            "💡 Проверьте расширение файла"
        )
    }

    NetworkException = @{
        Icon = "🌐"
        Title = "Сетевая ошибка"
        Pattern = "network|connection|timeout"
        Severity = "Warning"
        Suggestions = @(
            "💡 Проверьте интернет-соединение",
            "💡 Проверьте настройки прокси",
            "💡 Попробуйте позже"
        )
    }

    OutOfMemoryException = @{
        Icon = "💾"
        Title = "Недостаточно памяти"
        Pattern = "OutOfMemoryException|memory"
        Severity = "Critical"
        Suggestions = @(
            "💡 Закройте неиспользуемые приложения",
            "💡 Увеличьте размер файла подкачки",
            "💡 Оптимизируйте код для меньшего потребления памяти"
        )
    }

    "ParameterBindingException" = @{
        Icon = "👻"
        Title = "Ошибка привязки параметров"
        Pattern = "ParameterBindingException"
        Severity = "Warning"
        Suggestion = @("💡 Проверьте правильность указания параметров")
    }

    #"Default" = @{
    #    Icon = "👻"
    #     Title = "Ошибка привязки параметров"
    #    Severity = "Info"
    #    Pattern = "ParameterBindingException
    #    Suggestion = @("")
    #    }

}
#endregion

#region Основные функции форматирования

function Format-UnifiedError
{
    <#
    .SYNOPSIS
        Универсальная функция форматирования ошибок

    .PARAMETER ErrorRecord
        Объект ошибки для форматирования

    .PARAMETER Style
        Стиль вывода: Full, Compact, SingleLine, Minimal

    .PARAMETER NoColor
        Отключить цветное форматирование
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,

        [ValidateSet('Full', 'Compact', 'SingleLine', 'Minimal')]
        [string]$Style = 'Full',

        [switch]$NoColor,
        [switch]$AsObject
    )

    process {
        # Получаем шаблон и цвета
        $template = Get-ErrorTemplate -ErrorRecord $ErrorRecord
        $colors = Get-ErrorColors

        # Извлекаем информацию об ошибке
        $errorInfo = Extract-ErrorInfo -ErrorRecord $ErrorRecord

        # Переводим сообщение если нужно

        $errorInfo.Message = Translate-ErrorMessage -Message $errorInfo.Message `
                                                       -ExceptionType $errorInfo.ExceptionType

        # Форматируем в зависимости от стиля
        $formatted = switch ($Style)
        {
            'Full' {
                Format-FullError -ErrorInfo $errorInfo -Template $template -Colors $colors
            }
            'Compact' {
                Format-CompactError -ErrorInfo $errorInfo -Template $template -Colors $colors
            }
            'SingleLine' {
                Format-SingleLineError -ErrorInfo $errorInfo -Template $template -Colors $colors
            }
            'Minimal' {
                Format-MinimalError -ErrorInfo $errorInfo -Template $template -Colors $colors
            }
        }

        # Логируем если нужно
        if ($global:UnifiedErrorConfig.LogErrors)
        {
            Write-ErrorLog -ErrorInfo $errorInfo -FormattedError $formatted
        }

        # Возвращаем объект или выводим
        if ($AsObject)
        {
            return $formatted
        }
        else
        {
            Write-FormattedError -FormattedError $formatted -NoColor:$NoColor
        }
    }
}

function Format-FullError
{
    param($ErrorInfo, $Template, $Colors)

    $result = @{
        Lines = @()
        Raw = ""
    }

    # Заголовок с рамкой
    if ($global:UnifiedErrorConfig.BorderStyle -ne 'None')
    {
        $border = Get-BorderChars -Style $global:UnifiedErrorConfig.BorderStyle
        $width = [Math]::Min($global:UnifiedErrorConfig.MaxErrorWidth, 80)

        # Верхняя граница
        $result.Lines += @{
            Text = $border.TL + ($border.H * ($width - 2)) + $border.TR
            Color = $Colors.Border
        }

        # Заголовок ошибки
        $titleText = " $( $Template.Icon ) $( $Template.Title ) "
        $titlePadding = $width - $titleText.Length - 2
        $leftPad = [Math]::Floor($titlePadding / 2)
        $rightPad = [Math]::Ceiling($titlePadding / 2)

        $result.Lines += @{
            Parts = @(
                @{ Text = $border.V; Color = $Colors.Border }
                @{ Text = " " * $leftPad }
                @{ Text = $titleText; Color = $Colors.Error; Style = 'Bold' }
                @{ Text = " " * $rightPad }
                @{ Text = $border.V; Color = $Colors.Border }
            )
        }

        # Разделитель
        $result.Lines += @{
            Text = $border.V + ($border.H * ($width - 2)) + $border.V
            Color = $Colors.Border
        }
    }

    # Временная метка
    if ($global:UnifiedErrorConfig.ShowTimestamp)
    {
        $result.Lines += @{
            Parts = @(
                @{ Text = "⏰ Время: "; Color = $Colors.Info }
                @{ Text = (Get-Date -Format "yyyy-MM-dd HH: mm: ss"); Color = $Colors.Text }
            )
        }
    }

    # Сообщение об ошибке
    $result.Lines += @{
        Parts = @(
            @{ Text = "📋 Сообщение: "; Color = $Colors.Warning }
            @{ Text = $ErrorInfo.Message; Color = $Colors.Error; Style = 'Bold' }
        )
    }

    # Тип исключения
    $result.Lines += @{
        Parts = @(
            @{ Text = "⚡ Тип: "; Color = $Colors.Info }
            @{ Text = $ErrorInfo.ExceptionType; Color = $Colors.Accent }
        )
    }

    # Категория
    if ($global:UnifiedErrorConfig.ShowCategory)
    {
        $result.Lines += @{
            Parts = @(
                @{ Text = "📂 Категория: "; Color = $Colors.Info }
                @{ Text = $ErrorInfo.Category; Color = $Colors.Text }
            )
        }
    }

    # ID ошибки
    if ($global:UnifiedErrorConfig.ShowErrorId)
    {
        $result.Lines += @{
            Parts = @(
                @{ Text = "🆔 ID: "; Color = $Colors.Info }
                @{ Text = $ErrorInfo.ErrorId; Color = $Colors.Text }
            )
        }
    }

    # Расположение
    if ($global:UnifiedErrorConfig.ShowScriptLocation -and $ErrorInfo.ScriptName)
    {
        $result.Lines += @{
            Parts = @(
                @{ Text = "📍 Расположение: "; Color = $Colors.Info }
                @{ Text = "$( $ErrorInfo.ScriptName ): $( $ErrorInfo.Line ): $( $ErrorInfo.Column )"; Color = $Colors.Accent }
            )
        }

        # Показываем строку кода если возможно
        if (Test-Path $ErrorInfo.ScriptName)
        {
            $codeLines = Get-Content $ErrorInfo.ScriptName -ErrorAction SilentlyContinue
            if ($codeLines -and $ErrorInfo.Line -le $codeLines.Count)
            {
                $codeLine = $codeLines[$ErrorInfo.Line - 1]
                $result.Lines += @{
                    Parts = @(
                        @{ Text = "    "; Color = $Colors.Text }
                        @{ Text = $codeLine.Trim(); Color = $Colors.Warning }
                    )
                }
            }
        }
    }

    # Команда
    if ($ErrorInfo.Command)
    {
        $result.Lines += @{
            Parts = @(
                @{ Text = "🔧 Команда: "; Color = $Colors.Info }
                @{ Text = $ErrorInfo.Command; Color = $Colors.Accent }
            )
        }
    }

    # Внутренние исключения
    if ($global:UnifiedErrorConfig.ShowInnerExceptions -and $ErrorInfo.InnerException)
    {
        $result.Lines += @{
            Text = ""  # Пустая строка
        }
        $result.Lines += @{
            Parts = @(
                @{ Text = "🔍 Внутренние исключения: "; Color = $Colors.Warning; Style = 'Bold' }
            )
        }

        $inner = $ErrorInfo.InnerException
        $level = 1
        while ($inner -and $level -le 5)
        {
            $innerMsg = if ($global:UnifiedErrorConfig.AutoTranslate)
            {
                Translate-ErrorMessage -Message $inner.Message -ExceptionType $inner.GetType().Name
            }
            else
            {
                $inner.Message
            }

            $result.Lines += @{
                Parts = @(
                    @{ Text = "  " * $level + "└─ "; Color = $Colors.Border }
                    @{ Text = $innerMsg; Color = $Colors.Text }
                )
            }
            $inner = $inner.InnerException
            $level++
        }
    }

    # Предложения
    if ($global:UnifiedErrorConfig.ShowSuggestions -and $Template.Suggestions)
    {
        $result.Lines += @{
            Text = ""  # Пустая строка
        }
        $result.Lines += @{
            Parts = @(
                @{ Text = "💡 Рекомендации: "; Color = $Colors.Success; Style = 'Bold' }
            )
        }

        foreach ($suggestion in $Template.Suggestions)
        {
            $result.Lines += @{
                Parts = @(
                    @{ Text = "  • $suggestion"; Color = $Colors.Success }
                )
            }
        }
    }

    # Stack trace
    if ($global:UnifiedErrorConfig.ShowStackTrace -and $ErrorInfo.StackTrace)
    {
        $result.Lines += @{
            Text = ""  # Пустая строка
        }
        $result.Lines += @{
            Parts = @(
                @{ Text = "📊 Stack Trace: "; Color = $Colors.Info; Style = 'Bold' }
            )
        }

        $stackLines = $ErrorInfo.StackTrace -split "`n" | Select-Object -First 10
        foreach ($line in $stackLines)
        {
            $result.Lines += @{
                Parts = @(
                    @{ Text = "  $line"; Color = $Colors.Text }
                )
            }
        }
    }

    # Нижняя граница
    if ($global:UnifiedErrorConfig.BorderStyle -ne 'None')
    {
        $result.Lines += @{
            Text = $border.BL + ($border.H * ($width - 2)) + $border.BR
            Color = $Colors.Border
        }
    }

    return $result
}

function Format-CompactError
{
    param($ErrorInfo, $Template, $Colors)

    $result = @{
        Lines = @()
    }

    # Одна строка с основной информацией
    $result.Lines += @{
        Parts = @(
            @{ Text = "$( $Template.Icon ) "; Color = $Colors.Error }
            @{ Text = "["; Color = $Colors.Border }
            @{ Text = $ErrorInfo.ExceptionType; Color = $Colors.Accent }
            @{ Text = "] "; Color = $Colors.Border }
            @{ Text = $ErrorInfo.Message; Color = $Colors.Error; Style = 'Bold' }
        )
    }

    # Расположение если есть
    if ($ErrorInfo.ScriptName)
    {
        $result.Lines += @{
            Parts = @(
                @{ Text = "   📍 "; Color = $Colors.Info }
                @{ Text = "$( $ErrorInfo.ScriptName ): $( $ErrorInfo.Line )"; Color = $Colors.Text }
            )
        }
    }

    # Первое предложение
    if ($Template.Suggestions -and $Template.Suggestions.Count -gt 0)
    {
        $result.Lines += @{
            Parts = @(
                @{ Text = "   "; }
                @{ Text = $Template.Suggestions[0]; Color = $Colors.Success }
            )
        }
    }

    return $result
}

function Format-SingleLineError
{
    param($ErrorInfo, $Template, $Colors)

    @{
        Lines = @(
            @{
                Parts = @(
                    @{ Text = "$( $Template.Icon ) "; Color = $Colors.Error }
                    @{ Text = $ErrorInfo.Message; Color = $Colors.Error }
                    @{ Text = " ["; Color = $Colors.Border }
                    @{ Text = $ErrorInfo.ExceptionType; Color = $Colors.Accent }
                    @{ Text = "]"; Color = $Colors.Border }
                    @{
                        Text = $( if ($ErrorInfo.ScriptName)
                        {
                            " @ $( $ErrorInfo.ScriptName ):$( $ErrorInfo.Line )"
                        }
                        else
                        {
                            ""
                        } ); Color = $Colors.Info
                    }
                )
            }
        )
    }
}

function Format-MinimalError
{
    param($ErrorInfo, $Template, $Colors)

    @{
        Lines = @(
            @{
                Parts = @(
                    @{ Text = "$( $Template.Icon ) $( $ErrorInfo.Message )"; Color = $Colors.Error }
                )
            }
        )
    }
}

#endregion

#region Вспомогательные функции

function Get-ErrorTemplate
{
    param([System.Management.Automation.ErrorRecord]$ErrorRecord)

    $exceptionType = $ErrorRecord.Exception.GetType().Name
    $message = $ErrorRecord.Exception.Message

    # Ищем подходящий шаблон
    foreach ($templateName in $global:ErrorTemplates.Keys)
    {
        $template = $global:ErrorTemplates[$templateName]

        if ($exceptionType -match $templateName -or
                ($template.Pattern -and $message -match $template.Pattern))
        {
            return $template
        }
    }

    # Шаблон по умолчанию
    return @{
        Icon = "❗"
        Title = "Ошибка"
        Severity = "Error"
        Suggestions = @("💡 Проверьте синтаксис и параметры команды")
    }
}

function Get-ErrorColors
{
    $scheme = $global:ErrorColorSchemes[$global:UnifiedErrorConfig.ColorScheme]
    if (-not $scheme)
    {
        $scheme = $global:ErrorColorSchemes['Dracula']
    }
    return $scheme
}

#region Экспорт и импорт ошибок
function Export-Errors
{
    <#
    .SYNOPSIS
        Экспортирует ошибки в различные форматы
    #>
    param(
        [Parameter(Mandatory)]
        [ValidateSet('JSON', 'XML', 'CSV', 'HTML')]
        [string]$Format,

        [string]$Path = "$env:TEMP\errors_export_$( Get-Date -Format 'yyyyMMdd_HHmmss' ).$($Format.ToLower() )",

    [int]$Last = 0
    )

    if ($Error.Count -eq 0)
    {
    Write-Status -Warning "Нет ошибок для экспорта"
    return
    }

    $errorsToExport = if ($Last -gt 0)
    {
    $Error | Select-Object -First $Last
    }
    else
    {
    $Error
    }

    $exportData = $errorsToExport | ForEach-Object {
    @{
    Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Type = $_.Exception.GetType().Name
    Message = $_.Exception.Message
    Command = if ($_.InvocationInfo.MyCommand)
    {
    $_.InvocationInfo.MyCommand.Name
    }
    else
    {
    "N/A"
    }
    ScriptName = if ($_.InvocationInfo.ScriptName)
    {
    Split-Path $_.InvocationInfo.ScriptName -Leaf
    }
    else
    {
    "N/A"
    }
    Line = $_.InvocationInfo.ScriptLineNumber
    Column = $_.InvocationInfo.OffsetInLine
    FullyQualifiedErrorId = $_.FullyQualifiedErrorId
    Category = $_.CategoryInfo.Category
    }
    }

    switch ($Format)
    {
    'JSON' {
    $exportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $Path -Encoding UTF8
    }
    'XML' {
    $exportData | Export-Clixml -Path $Path
    }
    'CSV' {
    $exportData | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
    }
    'HTML' {
    $html = @"
<!DOCTYPE html>
<html>
<head>
<title>PowerShell Error Report</title>
<style>
body {
font-family: Arial, sans-serif; background: #1e1e1e; color: #fff; }
table {
border-collapse: collapse; width: 100%; margin: 20px 0;
}
th {
background: linear-gradient(45deg, #ff6b6b, #c92a2a); padding: 12px; text-align: left; }
td {
border: 1px solid #444; padding: 8px; }
tr: nth-child(even) {
background: #2a2a2a; }
tr: hover {
background: #3a3a3a; }
.error-type {
color: #ff6b6b; font-weight: bold; }
.timestamp {
color: #4dabf7; }
< /style>
< /head>
<body>
<h1 style = "background: linear-gradient(45deg, #ff6b6b, #c92a2a); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">
PowerShell Error Report
< /h1>
<p>Generated: $( Get-Date -Format 'yyyy-MM-dd HH:mm:ss' )< /p>
<table>
<tr>
<th>Timestamp</th>
<th>Type</th>
<th>Message</th>
<th>Command</th>
<th>Location</th>
< /tr>
"@
    foreach ($err in $exportData)
    {
    $html += @"
<tr>
<td class = "timestamp"> $( $err.Timestamp )< /td>
<td class = "error-type"> $( $err.Type )< /td>
<td>$( $err.Message )< /td>
<td>$( $err.Command )< /td>
<td>Line: $( $err.Line ), Col: $( $err.Column )< /td>
< /tr>
"@
    }
    $html += @"
< /table>
< /body>
< /html>
"@
    $html | Out-File -FilePath $Path -Encoding UTF8
    }
    }

    Write-Status -Success "Ошибки экспортированы в: $Path"

    # Предложение открыть файл
    Write-RGB "Открыть файл? (Y/N): " -FC "Cyan"
    if ((Read-Host) -eq 'Y')
    {
    Invoke-Item $Path
    }
}
#endregion

function Get-ErrorStatistics
{
    <#
    .SYNOPSIS
        Анализирует и показывает статистику по ошибкам
    #>
    param(
        [switch]$ShowGraph,
        [switch]$ExportToFile,
        [string]$FilePath = "$env:EMP\error_stats_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    )

    if ($Error.Count -eq 0) {
    Write-Status -Info "Нет ошибок для анализа"
    return
    }

    Write-RGB "" -newline
    Write-GradientHeader -Title "АНАЛИЗ ОШИБОК" -StartColor "#FF6B6B" -EndColor "#C92A2A"

    # Группировка по типам
    $errorsByType = $Error | Group-Object {
    $_.Exception.GetType().Name
    } |
    Sort-Object Count -Descending

    Write-RGB "`n📊 По типу исключения:" -FC "Cyan" -Style Bold -newline

    $maxCount = ($errorsByType | Measure-Object -Property Count -Maximum).Maximum
    $i = 0

    foreach ($group in $errorsByType) {
    $percentage = [math]::Round(($group.Count / $Error.Count) * 100, 1)
    $barLength = [math]::Round(($group.Count / $maxCount) * 30)

    # Имя типа с градиентом
    $color = Get-MenuGradientColor -Index $i -Total $errorsByType.Count -Style "Fire"
    Write-RGB ("  " + $group.Name.PadRight(30)) -FC $color -Style Bold

    # График
    if ($ShowGraph) {
    Write-RGB " [" -FC "DarkGray"
    for ($j = 0; $j -lt $barLength; $j++) {
    $barColor = Get-GradientColor -Index $j -TotalItems 30 `
                                             -StartColor "#FF0000" -EndColor "#00FF00"
    Write-RGB "█" -FC $barColor
    }
    Write-RGB ("]".PadLeft(31 - $barLength)) -FC "DarkGray"
    }

    # Количество и процент
    Write-RGB " $($group.Count) " -FC "White" -Style Bold
    Write-RGB "($percentage%)" -FC "Gray" -newline

    $i++
    }

    # Группировка по времени
    $recentErrors = $Error | Where-Object {
    $_.InvocationInfo.PositionMessage -match '\d{4}-\d{2}-\d{2}'
    }

    if ($recentErrors) {
    Write-RGB "`n📅 Распределение по времени:" -FC "Cyan" -Style Bold -newline
    # Здесь можно добавить более детальный анализ по времени
    }

    # Самые частые команды с ошибками
    $errorsByCommand = $Error | Where-Object {
    $_.InvocationInfo.MyCommand
    } |
    Group-Object {
    $_.InvocationInfo.MyCommand.Name
    } |
    Sort-Object Count -Descending |
    Select-Object -First 5

    if ($errorsByCommand) {
    Write-RGB "`n🔧 Топ-5 команд с ошибками:" -FC "Cyan" -Style Bold -newline

    foreach ($cmd in $errorsByCommand) {
    Write-RGB "  • " -FC "DarkGray"
    Write-RGB $cmd.Name -FC "Yellow" -Style Bold
    Write-RGB " - " -FC "DarkGray"
    Write-RGB "$($cmd.Count) ошибок" -FC "Red" -newline
    }
    }

    # Сводка
    Write-RGB "`n📈 Общая статистика:" -FC "Cyan" -Style Bold -newline
    Write-RGB "  Всего ошибок: " -FC "Gray"
    Write-RGB $Error.Count -FC "Red" -Style Bold -newline
    Write-RGB "  Уникальных типов: " -FC "Gray"
    Write-RGB $errorsByType.Count -FC "Magenta" -Style Bold -newline
    Write-RGB "  Критических: " -FC "Gray"
    $criticalCount = $Error | Where-Object {
    $_.Exception -is [System.OutOfMemoryException] -or
    $_.Exception -is [System.StackOverflowException] -or
    $_.Exception -is [System.UnauthorizedAccessException]
    } | Measure-Object | Select-Object -ExpandProperty Count
    Write-RGB $criticalCount -FC "Red" -Style Bold -newline

    # Экспорт в файл
    if ($ExportToFile) {
    $report = @"
ОТЧЕТ ПО ОШИБКАМ
Дата: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
=====================================

СТАТИСТИКА ПО ТИПАМ:
$($errorsByType | ForEach-Object {
    "$($_.Name): $($_.Count)"
    } | Out-String)

КОМАНДЫ С ОШИБКАМИ:
$($errorsByCommand | ForEach-Object {
    "$($_.Name): $($_.Count)"
    } | Out-String)

ДЕТАЛИ ПОСЛЕДНИХ 10 ОШИБОК:
$($Error[0..9] | ForEach-Object {
    "---`nТип: $($_.Exception.GetType().Name)`nСообщение: $($_.Exception.Message)`n"
    } | Out-String)
"@

    $report | Out-File -FilePath $FilePath -Encoding UTF8
    Write-Status -Success "Отчет сохранен в: $FilePath"
    }
}

function Find-ErrorPattern
{
    <#
    .SYNOPSIS
        Ищет ошибки по паттерну
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Pattern,

        [ValidateSet('Message', 'Type', 'Command', 'All')]
        [string]$SearchIn = 'All',

        [switch]$RegEx
    )

    $results = @()

    foreach ($err in $Error)
    {
        $match = $false

        switch ($SearchIn)
        {
            'Message' {
                $match = if ($RegEx)
                {
                    $err.Exception.Message -match $Pattern
                }
                else
                {
                    $err.Exception.Message -like "*$Pattern*"
                }
            }
            'Type' {
                $match = if ($RegEx)
                {
                    $err.Exception.GetType().Name -match $Pattern
                }
                else
                {
                    $err.Exception.GetType().Name -like "*$Pattern*"
                }
            }
            'Command' {
                if ($err.InvocationInfo.MyCommand)
                {
                    $match = if ($RegEx)
                    {
                        $err.InvocationInfo.MyCommand.Name -match $Pattern
                    }
                    else
                    {
                        $err.InvocationInfo.MyCommand.Name -like "*$Pattern*"
                    }
                }
            }
            'All' {
                $match = if ($RegEx)
                {
                    $err.Exception.Message -match $Pattern -or
                            $err.Exception.GetType().Name -match $Pattern -or
                            ($err.InvocationInfo.MyCommand -and $err.InvocationInfo.MyCommand.Name -match $Pattern)
                }
                else
                {
                    $err.Exception.Message -like "*$Pattern*" -or
                            $err.Exception.GetType().Name -like "*$Pattern*" -or
                            ($err.InvocationInfo.MyCommand -and $err.InvocationInfo.MyCommand.Name -like "*$Pattern*")
                }
            }
        }

        if ($match)
        {
            $results += $err
        }
    }

    if ($results.Count -eq 0)
    {
        Write-Status -Warning "Ошибки с паттерном '$Pattern' не найдены"
    }
    else
    {
        Write-Status -Success "Найдено $( $results.Count ) ошибок:"
        foreach ($result in $results)
        {
            ConvertTo-Unified ErrorView -InputObject $result -Style Minimal
        }
    }

    return $results
}

function Extract-ErrorInfo
{
    param([System.Management.Automation.ErrorRecord]$ErrorRecord)

    $info = @{
        Message = $ErrorRecord.Exception.Message
        ExceptionType = $ErrorRecord.Exception.GetType().Name
        Category = $ErrorRecord.CategoryInfo.Category
        ErrorId = $ErrorRecord.FullyQualifiedErrorId
        Command = $null
        ScriptName = $null
        Line = 0
        Column = 0
        StackTrace = $ErrorRecord.Exception.StackTrace
        InnerException = $ErrorRecord.Exception.InnerException
        TargetObject = $ErrorRecord.TargetObject
        Timestamp = Get-Date
    }

    # Извлекаем информацию о команде
    if ($ErrorRecord.InvocationInfo)
    {
        $invocation = $ErrorRecord.InvocationInfo
        $info.Command = $invocation.MyCommand.Name
        if (-not $info.Command)
        {
            $info.Command = $invocation.InvocationName
        }

        $info.ScriptName = $invocation.ScriptName
        $info.Line = $invocation.ScriptLineNumber
        $info.Column = $invocation.OffsetInLine
    }

    # Извлекаем дополнительную информацию из сообщения
    if ($info.Message -match "'([^']+)'")
    {
        $info.HighlightedText = $matches[1]
    }

    if ($ErrorRecord.Exception.Message -match "'([^']+)'")
    {
        $path = $matches[1]
        if (Test-Path $path -IsValid)
        {
            $info.Path = $path
            $info.FileName = Split-Path $path -Leaf
        }
    }

    # Специфичные извлечения для разных типов
    if ($ErrorRecord.Exception -is [System.Management.Automation.ParameterBindingException])
    {
        if ($ErrorRecord.Exception.Message -match "parameter\s+'([^']+)'")
        {
            $info.ArgumentName = $matches[1]
        }
    }



    return $info
}

function Show-ErrorBrowser
{
    <#
    .SYNOPSIS
        Интерактивный браузер для просмотра ошибок
    #>
    param(
        [int]$PageSize = 5
    )

    if ($Error.Count -eq 0)
    {
        Write-Status -Info "Нет ошибок для просмотра"
        return
    }

    $currentPage = 0
    $totalPages = [Math]::Ceiling($Error.Count / $PageSize)

    do
    {
        Clear-Host
        Write-GradientHeader -Title "БРАУЗЕР ОШИБОК" -StartColor "#FF6B6B" -EndColor "#C92A2A"

        Write-RGB "`nСтраница " -FC "Gray"
        Write-RGB "$( $currentPage + 1 )" -FC "Cyan" -Style Bold
        Write-RGB " из " -FC "Gray"
        Write-RGB $totalPages -FC "Cyan" -Style Bold
        Write-RGB " (Всего ошибок: " -FC "Gray"
        Write-RGB $Error.Count -FC "Red" -Style Bold
        Write-RGB ")" -FC "Gray" -newline

        Write-GradientLine -Length 60

        # Показываем ошибки текущей страницы
        $startIndex = $currentPage * $PageSize
        $endIndex = [Math]::Min($startIndex + $PageSize - 1, $Error.Count - 1)

        for ($i = $startIndex; $i -le $endIndex; $i++) {
            Write-RGB "`n[$( $i + 1 )] " -FC "DarkCyan" -Style Bold
            ConvertTo-UnifiedErrorView -InputObject $Error[$i] -Style Minimal -NoAnimation
        }

        Write-GradientLine -Length 60

        # Меню навигации
        Write-RGB "`nКоманды: " -FC "Yellow" -Style Bold
        Write-RGB "[N]" -FC "Cyan" -Style Bold
        Write-RGB "ext, " -FC "Gray"
        Write-RGB "[P]" -FC "Cyan" -Style Bold
        Write-RGB "revious, " -FC "Gray"
        Write-RGB "[G]" -FC "Cyan" -Style Bold
        Write-RGB "oto, " -FC "Gray"
        Write-RGB "[D]" -FC "Cyan" -Style Bold
        Write-RGB "etails, " -FC "Gray"
        Write-RGB "[S]" -FC "Cyan" -Style Bold
        Write-RGB "tats, " -FC "Gray"
        Write-RGB "[E]" -FC "Cyan" -Style Bold
        Write-RGB "xport, " -FC "Gray"
        Write-RGB "[Q]" -FC "Cyan" -Style Bold
        Write-RGB "uit" -FC "Gray" -newline

        Write-RGB "`nВыбор: " -FC "White"
        $choice = Read-Host

        switch ( $choice.ToUpper())
        {
            'N' {
                if ($currentPage -lt $totalPages - 1)
                {
                    $currentPage++
                }
                else
                {
                    Write-Status -Warning "Это последняя страница"
                    Start-Sleep -Seconds 1
                }
            }
            'P' {
                if ($currentPage -gt 0)
                {
                    $currentPage--
                }
                else
                {
                    Write-Status -Warning "Это первая страница"
                    Start-Sleep -Seconds 1
                }
            }
            'G' {
                Write-RGB "Введите номер страницы (1-$totalPages): " -FC "Cyan"
                $pageNum = Read-Host
                if ($pageNum -match '^\d+$' -and [int]$pageNum -ge 1 -and [int]$pageNum -le $totalPages)
                {
                    $currentPage = [int]$pageNum - 1
                }
                else
                {
                    Write-Status -Error "Неверный номер страницы"
                    Start-Sleep -Seconds 1
                }
            }
            'D' {
                Write-RGB "Введите номер ошибки для детального просмотра: " -FC "Cyan"
                $errNum = Read-Host
                if ($errNum -match '^\d+$' -and [int]$errNum -ge 1 -and [int]$errNum -le $Error.Count)
                {
                    Clear-Host
                    Write-GradientHeader -Title "ДЕТАЛИ ОШИБКИ #$errNum"
                    ConvertTo-UnifiedErrorView -InputObject $Error[[int]$errNum - 1] -Style Modern
                    Write-RGB "`nНажмите Enter для продолжения..." -FC "DarkGray"
                    Read-Host
                }
            }
            'S' {
                Clear-Host
                Get-ErrorStatistics -ShowGraph
                Write-RGB "`nНажмите Enter для продолжения..." -FC "DarkGray"
                Read-Host
            }
            'E' {
                Write-RGB "Выберите формат экспорта (JSON/XML/CSV/HTML): " -FC "Cyan"
                $format = Read-Host
                if ($format -in @('JSON', 'XML', 'CSV', 'HTML'))
                {
                    Export-Errors -Format $format
                    Start-Sleep -Seconds 2
                }
            }
        }
    } while ($choice.ToUpper() -ne 'Q')

    Clear-Host
    Write-Status -Info "Браузер ошибок закрыт"
}

function Translate-ErrorMessage
{
    param(
        [string]$Message,
        [string]$ExceptionType
    )

    if ($global:UnifiedErrorConfig.Language -ne "ru")
    {
        return $Message
    }

    # Сначала проверяем точное соответствие типу
    if ($global:ErrorTranslations.ContainsKey($ExceptionType))
    {
        return $global:ErrorTranslations[$ExceptionType]
    }

    # Затем проверяем по паттернам
    foreach ($pattern in $global:ErrorTranslations.Keys)
    {
        if ($Message -match $pattern)
        {
            $translation = $global:ErrorTranslations[$pattern]

            # Заменяем группы захвата
            if ($matches.Count -gt 1)
            {
                for ($i = 1; $i -lt $matches.Count; $i++) {
                    $translation = $translation -replace "\$$i", $matches[$i]
                }
            }

            return $translation
        }
    }

    return $Message
}

function Show-CriticalErrorNotification
{
    param([System.Management.Automation.ErrorRecord]$ErrorRecord)

    # Визуальное предупреждение
    5..1 | ForEach-Object {
        Write-RGB "🚨 КРИТИЧЕСКАЯ ОШИБКА! 🚨" -FC "Red" -BC "DarkRed" -Style @('Bold', 'Blink')
        Start-Sleep -Milliseconds 200
        Write-Host "`r                            `r" -NoNewline
        Start-Sleep -Milliseconds 200
    }

    # Звуковой сигнал (если включен)
    if ($global:ErrorViewConfig.PlaySound)
    {
        [console]::beep(1000, 500)
        [console]::beep(800, 500)
    }
}

function Show-ErrorAnimation
{
    # Простая анимация появления ошибки
    $frames = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')

    foreach ($frame in $frames)
    {
        Write-Host "`r$frame Обработка ошибки..." -NoNewline -ForegroundColor Red
        Start-Sleep -Milliseconds 50
    }
    Write-Host "`r                        `r" -NoNewline
}
function ConvertTo-UnifiedErrorView {
    <#
    .SYNOPSIS
        Универсальная функция для красивого отображения ошибок

    .PARAMETER InputObject
        Объект ошибки

    .PARAMETER Style
        Стиль отображения: Modern, Classic, Minimal, Gradient, SingleLine

    .PARAMETER NoAnimation
        Отключить анимацию
    #>
    [CmdletBinding()]
    param(
        [System.Management.Automation.ErrorRecord]$InputObject,

        [ValidateSet('Modern', 'Classic', 'Minimal', 'Gradient', 'SingleLine')]
        [string]$Style = $global:ErrorViewConfig.ErrorStyle,

        [switch]$NoAnimation
    )

    process {
        # Получаем шаблон и детали
        $template = Get-ErrorTemplate -ErrorRecord $InputObject
        $details = Extract-ErrorDetails -ErrorRecord $InputObject
        $colorScheme = $global:ErrorViewConfig.ColorSchemes[$template.Severity]

        # Переводим сообщение
        $details.Message = Translate-ErrorMessage -Message $details.Message `
                                                 -ExceptionType $InputObject.Exception.GetType().Name

        # Применяем стиль отображения
        switch ($Style) {
            'Modern' { Show-ModernError @PSBoundParameters }
            'Classic' { Show-ClassicError @PSBoundParameters }
            'Minimal' { Show-MinimalError @PSBoundParameters }
            'Gradient' { Show-GradientError @PSBoundParameters }
            'SingleLine' { Show-SingleLineError @PSBoundParameters }
        }

        # Логируем если нужно
        if ($global:ErrorViewConfig.LogErrors) {
            Log-Error -ErrorRecord $InputObject -Style $Style
        }

        # Уведомление о критических ошибках
        if ($global:ErrorViewConfig.NotifyOnCritical -and $template.Severity -eq 'Critical') {
            Show-CriticalErrorNotification -ErrorRecord $InputObject
        }
    }
}

# Алиас для обратной совместимости
Set-Alias -Name ConvertTo-ColorfulErrorView -Value ConvertTo-UnifiedErrorView
Set-Alias -Name ConvertTo-SmartErrorView -Value ConvertTo-UnifiedErrorView
#endregion

#region Стили отображения ошибок
function Show-ModernError {
    param($InputObject, $template, $details, $colorScheme, $NoAnimation)

    # Анимация появления (если включена)
    if ($global:ErrorViewConfig.AnimateErrors -and -not $NoAnimation) {
        Show-ErrorAnimation
    }

    # Верхняя граница с градиентом
    Write-GradientLine -Length 60 -Char "━" `
                      -StartColor $colorScheme.Start `
                      -EndColor $colorScheme.End

    # Заголовок с иконкой
    Write-RGB " $($colorScheme.Icon) " -FC $colorScheme.Start -Style Bold
    Write-GradientText -Text "ОШИБКА: " -StartColor $colorScheme.Start -EndColor $colorScheme.End -NoNewline
    Write-RGB $details.Message -FC "White" -Style Bold -newline

    # Детали с отступами
    if ($global:ErrorViewConfig.ShowErrorPosition -and $InputObject.InvocationInfo.ScriptLineNumber) {
        Write-RGB "    📍 " -FC "Silver"
        Write-RGB "Позиция: " -FC "DarkGray"
        Write-RGB "Строка " -FC "Gray"
        Write-RGB $InputObject.InvocationInfo.ScriptLineNumber -FC "White" -Style Bold
        Write-RGB ", Колонка " -FC "Gray"
        Write-RGB $InputObject.InvocationInfo.OffsetInLine -FC "White" -Style Bold -newline
    }

    if ($details.Command) {
        Write-RGB "    🔧 " -FC "Silver"
        Write-RGB "Команда: " -FC "DarkGray"
        Write-RGB $details.Command -FC "Cyan" -Style Bold -newline
    }

    if ($InputObject.Exception.GetType().Name -ne "RuntimeException") {
        Write-RGB "    ⚡ " -FC "Silver"
        Write-RGB "Тип: " -FC "DarkGray"
        Write-RGB $InputObject.Exception.GetType().Name -FC "Magenta" -newline
    }

    # Предложения по исправлению
    if ($global:ErrorViewConfig.ShowSuggestions -and $template.Suggestion) {
        Write-RGB "`n    $($template.Suggestion)" -FC "LimeGreen" -newline

        if ($template.Actions.Count -gt 0) {
            Write-RGB "    📋 Возможные действия:" -FC "DarkCyan" -newline
            foreach ($action in $template.Actions) {
                # Заменяем плейсхолдеры
                $action = $action -replace '\{Command\}', $details.Command
                $action = $action -replace '\{Path\}', $details.Path
                $action = $action -replace '\{FileName\}', $details.FileName

                Write-RGB "       • " -FC "DarkGray"
                Write-RGB $action -FC "Cyan" -newline
            }
        }
    }

    # Внутренние исключения
    if ($global:ErrorViewConfig.ShowInnerExceptions -and $InputObject.Exception.InnerException) {
        Write-RGB "`n    🔍 Внутренняя ошибка: " -FC "DarkYellow"
        $innerMessage = Translate-ErrorMessage -Message $InputObject.Exception.InnerException.Message `
                                             -ExceptionType $InputObject.Exception.InnerException.GetType().Name
        Write-RGB $innerMessage -FC "Yellow" -newline
    }

    # Временная метка
    if ($global:ErrorViewConfig.ShowTimestamp) {
        Write-RGB "`n    🕐 " -FC "DarkGray"
        Write-RGB (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -FC "Gray" -newline
    }

    # Нижняя граница
    Write-GradientLine -Length 60 -Char "━" `
                      -StartColor $colorScheme.End `
                      -EndColor $colorScheme.Start
}

function Show-GradientError {
    param($InputObject, $template, $details, $colorScheme)

    # Полностью градиентное отображение
    $lines = @(
        "╔═══════════════════════════════════════════════════════╗",
        "║  $($colorScheme.Icon)  ОШИБКА                                          ║",
        "╠═══════════════════════════════════════════════════════╣",
        "║  $($details.Message.PadRight(52))  ║",
        "╚═══════════════════════════════════════════════════════╝"
    )

    $lineIndex = 0
    foreach ($line in $lines) {
        $chars = $line.ToCharArray()
        for ($i = 0; $i -lt $chars.Length; $i++) {
            $color = Get-GradientColor -Index $i -TotalItems $chars.Length `
                                     -StartColor $colorScheme.Start `
                                     -EndColor $colorScheme.End `
                                     -GradientType "Sine"
            Write-RGB $chars[$i] -FC $color
        }
        Write-Host ""
    }
}

function Show-MinimalError {
    param($InputObject, $template, $details, $colorScheme)

    Write-RGB "$($colorScheme.Icon) " -FC $colorScheme.Start
    Write-RGB $details.Message -FC "White" -Style Bold

    if ($details.Command) {
        Write-RGB " [$($details.Command)]" -FC "DarkGray"
    }

    Write-Host ""
}

function Show-SingleLineError {
    param($InputObject, $template, $details, $colorScheme)

    $parts = @()

    $parts += "$($colorScheme.Icon) $($details.Message)"

    if ($InputObject.InvocationInfo.ScriptLineNumber) {
        $parts += "[L:$($InputObject.InvocationInfo.ScriptLineNumber)]"
    }

    if ($details.Command) {
        $parts += "[Cmd:$($details.Command)]"
    }

    $parts += "[$(Get-Date -Format 'HH:mm:ss')]"

    Write-RGB ($parts -join " ") -FC $colorScheme.Start -newline
}
#endregion

#region Вспомогательные функции
function Get-ErrorTemplate {
    param([System.Management.Automation.ErrorRecord]$ErrorRecord)

    $exceptionType = $ErrorRecord.Exception.GetType().Name
    $message = $ErrorRecord.Exception.Message

    foreach ($templateKey in $global:ErrorTemplates.Keys) {
        if ($templateKey -eq "Default") { continue }

        $templateInfo = $global:ErrorTemplates[$templateKey]

        if ($exceptionType -match $templateKey -or
                ($templateInfo.Pattern -and $message -match $templateInfo.Pattern)) {
            return $templateInfo
        }
    }

    return $global:ErrorTemplates["Default"]
}

function Extract-ErrorDetails {
    param([System.Management.Automation.ErrorRecord]$ErrorRecord)

    $details = @{
        Command = ""
        Path = ""
        FileName = ""
        ArgumentName = ""
        Message = $ErrorRecord.Exception.Message
    }

    # Извлекаем команду
    if ($ErrorRecord.InvocationInfo) {
        $details.Command = if ($ErrorRecord.InvocationInfo.MyCommand) {
            $ErrorRecord.InvocationInfo.MyCommand.Name
        } else {
            $ErrorRecord.InvocationInfo.InvocationName
        }
    }

    # Извлекаем пути и файлы из сообщения
    if ($ErrorRecord.Exception.Message -match "'([^']+)'") {
        $path = $matches[1]
        if (Test-Path $path -IsValid) {
            $details.Path = $path

            $details.FileName = Split-Path $path -Leaf
        }
    }

    # Специфичные извлечения для разных типов
    if ($ErrorRecord.Exception -is [System.Management.Automation.ParameterBindingException]) {
        if ($ErrorRecord.Exception.Message -match "parameter\s+'([^']+)'") {
            $details.ArgumentName = $matches[1]
        }
    }

    return $details
}

Set-Alias -Name err -Value Show-RecentErrors -Force
Set-Alias -Name errs -Value Get-ErrorStatistics -Force
Set-Alias -Name errb -Value Show-ErrorBrowser -Force
Set-Alias -Name errf -Value Find-ErrorPattern -Force
Set-Alias -Name erre -Value Export-Errors -Force

# Функция быстрой очистки ошибок с подтверждением
function Clear-Errors
{
    param([switch]$Force)

    if ($Error.Count -eq 0)
    {
        Write-Status -Info "Нет ошибок для очистки"
        return
    }

    if (-not $Force)
    {
        Write-RGB "Очистить " -FC "Yellow"
        Write-RGB $Error.Count -FC "Red" -Style Bold
        Write-RGB " ошибок? (Y/N): " -FC "Yellow"

        if ((Read-Host).ToUpper() -ne 'Y')
        {
            Write-Status -Warning "Очистка отменена"
            return
        }
    }

    $count = $Error.Count
    $Error.Clear()
    Write-Status -Success "Очищено $count ошибок"
}
#endregion

function Set-ErrorViewStyle
{
    <#
    .SYNOPSIS
        Устанавливает стиль отображения ошибок
    #>
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Modern', 'Classic', 'Minimal', 'Gradient', 'SingleLine')]
        [string]$Style
    )

    $global:ErrorViewConfig.ErrorStyle = $Style
    $global:ErrorViewConfig | Format-LiЫр *
    Write-Status -Success "Стиль ошибок изменен на: $Style"
}
# Информация о доступных командах


function Show-ErrorViewConfig
{
    <#
    .SYNOPSIS
        Красиво отображает текущую конфигурацию
    #>

    Write-GradientHeader -Title "КОНФИГУРАЦИЯ ERROR HANDLER" `
                        -StartColor "#FF6B6B" -EndColor "#C92A2A"

    Write-RGB "`n📋 Основные настройки:" -FC "Cyan" -Style Bold -newline

    $config = $global:ErrorViewConfig
    $i = 0

    # Исправленный вывод конфигурации
    $config.GetEnumerator() | Where-Object { $_.Key -ne 'ColorSchemes' } | Sort-Object Key | ForEach-Object {
        $gradientColor = Get-GradientColor -Index $i -TotalItems 10 `
                                          -StartColor "#00BFFF" -EndColor "#8B00FF"

        Write-RGB "   " -FC "White"
        Write-RGB $_.Key.PadRight(20) -FC $gradientColor -Style Bold
        Write-RGB " : " -FC "DarkGray"

        $value = switch ($_.Value)
        {
            { $_ -is [bool] } {
                if ($_)
                {
                    "✅ Включено"
                }
                else
                {
                    "❌ Выключено"
                }
            }
            default {
                $_.ToString()
            }
        }

        Write-RGB $value -FC "White" -newline
        $i++
    }

    Write-RGB "`n🎨 Цветовые схемы:" -FC "Cyan" -Style Bold -newline

    foreach ($scheme in $config.ColorSchemes.GetEnumerator())
    {
        Write-RGB "   $( $scheme.Key ): " -FC "White"
        Write-GradientLine -Length 20 -StartColor $scheme.Value.Start `
                          -EndColor $scheme.Value.End -Char "█"
    }
}

function Test-ErrorStyles
{
    <#
    .SYNOPSIS
        Демонстрирует все стили отображения ошибок
    #>

    Write-GradientHeader -Title "ДЕМОНСТРАЦИЯ СТИЛЕЙ ОШИБОК"

    # Создаем тестовую ошибку
    $testError = $null
    try
    {
        Get-Item "C:\НесуществующийФайл123.txt" -ErrorAction Stop
    }
    catch
    {
        $testError = $_
    }

    if ($testError)
    {
        $styles = @('Modern', 'Gradient', 'Minimal', 'SingleLine')

        foreach ($style in $styles)
        {
            Write-RGB "`n=== Стиль: $style ===" -FC "Cyan" -Style Bold -newline
            ConvertTo-Unified ErrorView -InputObject $testError -Style
            Write-RGB "`nНажмите Enter для следующего стиля..." -FC "DarkGray"
            Read-Host
        }
    }
}

# Функция для быстрого просмотра последних ошибок
function Show-RecentErrors
{
    param(
        [int]$Count = 5,
        [string]$Style = $global:ErrorViewConfig.ErrorStyle
    )

    if ($Error.Count -eq 0)
    {
        Write-Status -Success "Нет ошибок для отображения!"
        return
    }

    Write-GradientHeader -Title "ПОСЛЕДНИЕ $Count ОШИБОК"

    $errorsToShow = if ($Error.Count -lt $Count)
    {
        $Error
    }
    else
    {
        $Error[0..($Count - 1)]
    }

    $i = 0
    foreach ($err in $errorsToShow)
    {
        Write-RGB "`n[$( $i + 1 )]" -FC "DarkCyan" -Style Bold
        ConvertTo-UnifiedErrorView -InputObject $err -Style $Style -NoAnimation
        $i++
    }
}


function Write-FormattedError
{
    param($FormattedError, [switch]$NoColor)

    foreach ($line in $FormattedError.Lines)
    {
        if ($line.Parts)
        {
            # Строка с несколькими частями разного цвета
            foreach ($part in $line.Parts)
            {
                if ($NoColor)
                {
                    Write-Host $part.Text -NoNewline
                }
                else
                {
                    $params = @{
                        Text = $part.Text
                    }
                    if ($part.Color)
                    {
                        $params.FC = $part.Color
                    }
                    if ($part.Style)
                    {
                        $params.Style = $part.Style
                    }

                    Write-RGB @params
                }
            }
            Write-Host ""  # Новая строка
        }
        elseif ($line.Text -ne $null)
        {
            # Простая строка
            if ($NoColor)
            {
                Write-Host $line.Text
            }
            else
            {
                $params = @{
                    Text = $line.Text
                    newline = $true
                }
                if ($line.Color)
                {
                    $params.FC = $line.Color
                }
                if ($line.Style)
                {
                    $params.Style = $line.Style
                }

                Write-RGB @params
            }
        }
        else
        {
            # Пустая строка
            Write-Host ""
        }
    }
}

function Get-BorderChars
{
    param([string]$Style)

    $borders = @{
        'Single' = @{
            TL = "┌"; TR = "┐"; BL = "└"; BR = "┘"; H = "─"; V = "│"
        }
        'Double' = @{
            TL = "╔"; TR = "╗"; BL = "╚"; BR = "╝"; H = "═"; V = "║"
        }
        'Rounded' = @{
            TL = "╭"; TR = "╮"; BL = "╰"; BR = "╯"; H = "─"; V = "│"
        }
        'Heavy' = @{
            TL = "┏"; TR = "┓"; BL = "┗"; BR = "┛"; H = "━"; V = "┃"
        }
    }

    return $borders[$Style]
}

function Enable-SmartErrorHandler
{
    $global:ErrorView = {
        param($ErrorRecord)
        ConvertTo-UnifiedErrorView  $ErrorRecord
    }

    Write-Status -Success "Умный обработчик ошибок включен!"
    Write-RGB "Текущий стиль: " -FC "Gray"
    Write-RGB $global:ErrorViewConfig.ErrorStyle -FC "Cyan" -Style Bold -newline
}

function Disable-SmartErrorHandler
{
    $global:ErrorView = "CategoryView"
    Write-Status -Warning "Умный обработчик ошибок отключен"
}


Enable-SmartErrorHandler

Write-RGB "`n✨ " -FC "GoldRGB"
Write-GradientText -Text "Advanced Error Handler v2.0" `
                   -StartColor "#FF6B6B" -EndColor "#4ECDC4" `
                   -NoNewline
Write-RGB " загружен!" -FC "GoldRGB" -newline

Write-RGB "Используйте " -FC "Gray"
Write-RGB "Show-ErrorViewConfig" -FC "Cyan" -Style Bold
Write-RGB " для просмотра настроек" -FC "Gray" -newline

Write-RGB "Или " -FC "Gray"
Write-RGB "Test-ErrorStyles" -FC "Cyan" -Style Bold
Write-RGB " для демонстрации стилей" -FC "Gray" -newline

Write-RGB "`n📚 Новые команды:" -FC "Cyan" -Style Bold -newline
Write-RGB "  • " -FC "DarkGray"
Write-RGB "Get-ErrorStatistics" -FC "Yellow"
Write-RGB " (errs)" -FC "DarkGray"
Write-RGB " - статистика ошибок" -FC "Gray" -newline

Write-RGB "  • " -FC "DarkGray"
Write-RGB "Show-ErrorBrowser" -FC "Yellow"
Write-RGB " (errb)" -FC "DarkGray"
Write-RGB " - интерактивный браузер" -FC "Gray" -newline

Write-RGB "  • " -FC "DarkGray"
Write-RGB "Find-ErrorPattern" -FC "Yellow"
Write-RGB " (errf)" -FC "DarkGray"
Write-RGB " - поиск ошибок" -FC "Gray" -newline

Write-RGB "  • " -FC "DarkGray"
Write-RGB "Export-Errors" -FC "Yellow"
Write-RGB " (erre)" -FC "DarkGray"
Write-RGB " - экспорт ошибок" -FC "Gray" -newline

Write-RGB "  • " -FC "DarkGray"
Write-RGB "Clear-Errors" -FC "Yellow"
Write-RGB " - очистка с подтверждением" -FC "Gray" -newline


#. (Join-Path $PSScriptRoot 'ErrorTest.ps1')
