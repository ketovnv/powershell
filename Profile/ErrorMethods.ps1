Trace-ImportProcess  $MyInvocation.MyCommand.Name.trim(".ps1") -start
# Advanced ErrorView Handler with Templates and Translation
# Расширенная система перехвата и обработки ошибок с шаблонами и переводом

#region Конфигурация и настройки
$ErrorViewConfig = @{
    Language = "ru"  # ru, en
    AutoTranslate = $true
    ShowStackTrace = $false
    ShowInnerExceptions = $true
    UseColors = $true
    LogErrors = $true
    LogPath = "$env:TEMP\PowerShell_Errors.log"
    NotifyOnCritical = $true
}

# Шаблоны перевода ошибок
$ErrorTranslations = @{
# Общие сообщения
    "Access is denied" = "Доступ запрещён"
    "The term .* is not recognized" = "Команда '{}' не распознана"
    "Cannot find path" = "Не удается найти путь 🔍"
    "Cannot find drive" = "Не удается найти диск 💿"
    "The file .* cannot be found" = "Файл '{}' не найден"
    "Cannot convert value" = "Не удается преобразовать значение"
    "Attempted to divide by zero" = "Попытка деления на ноль 😲"
    "Object reference not set" = "Ссылка на объект не установлена"
    "Index was outside the bounds" = "Индекс вышел за пределы массива"
    "The property .* cannot be found" = "Свойство '{}' не найдено"
    "Cannot validate argument" = "Не удается проверить аргумент"
    "Parameter .* cannot be found" = "Параметр '{}' не найден 🔍"
    "Network path was not found" = "Сетевой путь не найден 📡"
    "Access to the path .* is denied" = "Доступ к пути '{}' запрещён"

    # Специфичные ошибки
    "Import-PythonModule" = "Импорт модуля Питона ⚗️"
    "Python module not found" = "Модуль Питона не найден 🙁"
    "CommandNotFoundException" = "Команда не найдена 🙁"
    "ParameterBindingException" = "Ошибка привязки параметра 📎"
    "ArgumentException" = "Неверный аргумент 🙁"
    "UnauthorizedAccessException" = "Нет доступа 🔒"
    "FileNotFoundException" = "Файл не найден ️️🗺"
    "DirectoryNotFoundException" = "Папка не найдена 🙁🗺"
    "PathTooLongException" = "Слишком длинный путь 🙁"
    "InvalidOperationException" = "Недопустимая операция 🙁"
    "NotSupportedException" = "Операция не поддерживается 🙁"
    "TimeoutException" = "Истекло время ожидания 🕰️"
    "NetworkException" = "Ошибка сети 🌏🗺"
}

# Шаблоны для разных типов ошибок
$ErrorTemplates = @{
    "Import-PythonModule" = @{
        Icon = "🐍"
        Pattern = "Python module not found"
        #        Template = "{Icon} Команда не найдена: '{Command}'"
        Suggestion = "💡 Проверьте написание команды или установите соответствующий модуль"
        Color = "Red"
    }
    "CommandNotFoundException" = @{
        Icon = "❌"
        Pattern = "CommandNotFoundError"
        Template = "{Icon} Команда не найдена: '{Command}'"
        Suggestion = "💡 Проверьте написание команды или установите соответствующий модуль"
        Color = "Red"
    }

    "ParameterBindingException" = @{
        Icon = "⚙️"
        Pattern = "ParameterBinding"
        Template = "{Icon} Ошибка параметра: {Message}"
        Suggestion = "💡 Проверьте правильность указания параметров"
        Color = "Yellow"
    }

    "UnauthorizedAccessException" = @{
        Icon = "🔒"
        Pattern = "Access.*denied"
        Template = "{Icon} Нет доступа: {Path}"
        Suggestion = "💡 Запустите PowerShell от имени администратора или проверьте права доступа"
        Color = "Magenta"
    }

    "FileNotFoundException" = @{
        Icon = "📄"
        Pattern = "cannot find.*file"
        Template = "{Icon} Файл не найден: '{FileName}'"
        Suggestion = "💡 Проверьте путь к файлу и его существование"
        Color = "Blue"
    }

    "DirectoryNotFoundException" = @{
        Icon = "📁"
        Pattern = "cannot find.*path"
        Template = "{Icon} Папка не найдена: '{Path}'"
        Suggestion = "💡 Проверьте правильность пути к папке"
        Color = "Blue"
    }

    "InvalidOperationException" = @{
        Icon = "⚠️"
        Pattern = "Invalid.*operation"
        Template = "{Icon} Недопустимая операция: {Message}"
        Suggestion = "💡 Проверьте контекст выполнения операции"
        Color = "DarkYellow"
    }

    "ArgumentException" = @{
        Icon = "📝"
        Pattern = "Argument.*exception"
        Template = "{Icon} Неверный аргумент: {ArgumentName}"
        Suggestion = "💡 Проверьте корректность передаваемых значений"
        Color = "Cyan"
    }

    "NetworkException" = @{
        Icon = "🌐"
        Pattern = "network.*error|connection.*failed"
        Template = "{Icon} Ошибка сети: {Message}"
        Suggestion = "💡 Проверьте сетевое соединение"
        Color = "DarkRed"
    }

    "TimeoutException" = @{
        Icon = "⏰"
        Pattern = "timeout|timed.*out"
        Template = "{Icon} Истекло время ожидания: {Message}"
        Suggestion = "💡 Увеличьте время ожидания или проверьте соединение"
        Color = "DarkMagenta"
    }

    "ParseException" = @{
        Icon = "📋"
        Pattern = "parse.*error|syntax.*error"
        Template = "{Icon} Ошибка синтаксиса: {Message}"
        Suggestion = "💡 Проверьте синтаксис команды или скрипта"
        Color = "Red"
    }

    "Default" = @{
        Icon = "❗"
        Template = "{Icon} {Message}"
        Suggestion = ""
        Color = "White"
    }
}
#endregion

function Show-RecentErrors
{
    param(
        [int]$Count = 5,
        [string]$View = "Colorful"
    )

    wrgb "Последние $Count ошибок (вид: $View):" -FC Yellow -newline
    if ($Error.Count -gt 0)
    {
        $ErrorsToShow = if ($Error.Count -lt $Count)
        {
            $Error
        }
        else
        {
            $Error[0..($Count - 1)]
        }
        $ErrorsToShow | Format-Error $View
    }
    else
    {
        wrgb "Нет ошибок для отображения" -FC Green
    }
}

# Функция для анализа типов ошибок
function Get-ErrorSummary
{
    if ($Error.Count -eq 0)
    {
        wrgb "Нет ошибок в коллекции" -FC Green
        return
    }

    wrgb "`n--- Сводка по ошибкам ---" -FC Yellow -newline

    # Группируем ошибки по типу исключения
    $ErrorsByType = $Error | Group-Object { $_.Exception.GetType().Name } | Sort-Object Count -Descending

    wrgb "По типу исключения:" -FC Material_Orange -newline
    $ErrorsByType | ForEach-Object {
        wrgb   $_.Name" : " -FC Material_Purple
        wrgb   $_.Count" " -FC White  -newline
    }

    # Группируем по категории
    $ErrorsByCategory = $Error | Group-Object { $_.CategoryInfo.Category } | Sort-Object Count -Descending

    wrgb "`nПо категории:" -FC Material_Orange -newline
    $ErrorsByCategory | ForEach-Object {
        wrgb   $_.Name" : " -FC Material_Purple
        wrgb   $_.Count" " -FC White -newline
    }

    wrgb "`nВсего ошибок:  "  -FC "FF0000"
    wrgb $Error.Count -FC "FFFF00" -newline
}


Import-Module ErrorView -Force
$global:ErrorView = "Smart"

function Set-MyErrorView
{
    param(
        [ValidateSet("Simple", "Normal", "Category", "Full", "SingleLine", "Colorful")]
        [string]$View = "Simple"
    )

    $global:ErrorView = $View
    wrgb "ErrorView установлен в: $View" -FC Green
}



function ConvertTo-SingleLineErrorView
{
    param([System.Management.Automation.ErrorRecord]$InputObject)
    -join @(
        $originInfo = &{ Set-StrictMode -Version 1; $InputObject.OriginInfo }
    if (($null -ne $originInfo) -and ($null -ne $originInfo.PSComputerName))
    {
        "[" + $originInfo.PSComputerName + "]: "
    }
        $errorDetails = &{ Set-StrictMode -Version 1; $InputObject.ErrorDetails }
    if (($null -ne $errorDetails) -and ($null -ne $errorDetails.Message) -and ($InputObject.FullyQualifiedErrorId -ne "NativeCommandErrorMessage"))
    {
        $errorDetails.Message
    }
    else
    {
        $InputObject.Exception.Message
    }
        wrgb "Type:  "  -FC "#ff99AA"
        wrgb $InputObject.Exception.GetType().Name -FC "#ff0000"
        wrgb "  |  "  -FC "#ffFFFF"
        wrgb "  ID:  " -FC "#ff99AA"
        wrgb  $InputObject.FullyQualifiedErrorId -FC "#ff0000"
        wrgb "  |  "  -FC "#ffFFFF"

    if ($ErrorViewRecurse)
    {
        $Prefix = " | Exception: "
        $Exception = &{ Set-StrictMode -Version 1; $InputObject.Exception }
        do
        {
            $Prefix + $Exception.GetType().FullName
            $Prefix = wrgb " | "  -FC "#ffFFFF"
            $Prefix = wrgb "InnerException:  "  -FC "#ff99AA"
        } while ($Exception = $Exception.InnerException)
    }
    )
}



#region Функции для работы с переводом и шаблонами
function Translate-ErrorMessage
{
    param(
        [string]$Message,
        [string]$ExceptionType
    )

    if (-not $ErrorViewConfig.AutoTranslate -or $ErrorViewConfig.Language -eq "en")
    {
        return $Message
    }

    $translatedMessage = $Message

    # Сначала ищем точный перевод по типу исключения
    if ( $ErrorTranslations.ContainsKey($ExceptionType))
    {
        return $ErrorTranslations[$ExceptionType]
    }

    # Затем ищем по паттернам
    foreach ($pattern in $ErrorTranslations.Keys)
    {
        if ($Message -match $pattern)
        {
            $translatedMessage = $ErrorTranslations[$pattern]
            # Заменяем плейсхолдеры если есть совпадения в regex
            if ($matches.Count -gt 1)
            {
                for ($i = 1; $i -lt $matches.Count; $i++) {
                    $translatedMessage = $translatedMessage -replace "\{\}", $matches[$i]
                }
            }
            break
        }
    }

    return $translatedMessage
}

function Get-ErrorTemplate
{
    param(
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    $exceptionType = $ErrorRecord.Exception.GetType().Name
    $message = $ErrorRecord.Exception.Message

    # Ищем подходящий шаблон
    $template = $ErrorTemplates["Default"]

    foreach ($templateKey in $ErrorTemplates.Keys)
    {
        if ($templateKey -eq "Default")
        {
            continue
        }

        $templateInfo = $ErrorTemplates[$templateKey]

        #        wrgb $exceptionType -FC Blue -newline
        #        wrgb  $templateKey -FC Green -newline
        # Проверяем по типу исключения
        if ($exceptionType -match $templateKey)
        {
            $template = $templateInfo
            break
        }
        # Проверяем по паттерну в сообщении
        if ($templateInfo.Pattern -and $message -match $templateInfo.Pattern)
        {
            $template = $templateInfo
            break
        }
    }

    return $template
}

function Extract-ErrorDetails
{
    param(
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    $details = @{
        Message = $ErrorRecord.Exception.Message
        ExceptionType = $ErrorRecord.Exception.GetType().Name
        Category = $ErrorRecord.CategoryInfo.Category
        ErrorId = $ErrorRecord.FullyQualifiedErrorId
        Activity = $ErrorRecord.CategoryInfo.Activity
        Reason = $ErrorRecord.CategoryInfo.Reason
        TargetName = $ErrorRecord.CategoryInfo.TargetName
        TargetType = $ErrorRecord.CategoryInfo.TargetTyp
        StackTrace = $ErrorRecord.Exception.StackTrace
        InnerException = $ErrorRecord.Exception.InnerException
        TargetObject = $ErrorRecord.TargetObject
        Timestamp = Get-Date
        Source = $ErrorRecord.InvocationInfo.MyCommand.Name
        ScriptName = $ErrorRecord.InvocationInfo.ScriptName
        ScriptLineNumber = $ErrorRecord.InvocationInfo.ScriptLineNumber
        OffsetInLine = $ErrorRecord.InvocationInfo.OffsetInLine
        Line = $ErrorRecord.InvocationInfo.Line.trim()
    }

    # Извлекаем пути из сообщения
    if ($ErrorRecord.Exception.Message -match "'([^']+)'")
    {
        $details.Path = $matches[1]
        $details.FileName = Split-Path $matches[1] -Leaf
    }

    # Извлекаем имя параметра для ParameterBindingException


    if ($info.Message -match "'([^']+)'")
    {
        $info.HighlightedText = $matches[1]
    }

    $pathFromError = Get-PathFromError $ErrorRecord.Exception.Message

    foreach ($Key in   $pathFromError.keys)
    {
        $details[$key] = $pathFromError[$key]
    }

    # === ИЗВЛЕЧЕНИЕ НОМЕРОВ СТРОК И КОЛОНОК ===
    $linePatterns = @(
        'line\s+(\d+)'
        'Line:\s*(\d+)'
        ':(\d+):(\d+)'
        'at\s+line\s+(\d+)'
        '\((\d+),(\d+)\)'
    )

    foreach ($pattern in $linePatterns)
    {
        if ($details.Message -match $pattern -and $matches[1])
        {
            $details.LineNumbersInMessage += [int]$matches[1]
            if ($matches[2])
            {
                $details.ColumnNumbersInMessage += [int]$matches[2]
            }
        }
    }

    # === ИЗВЛЕЧЕНИЕ ФУНКЦИЙ И МЕТОДОВ ===
    $functionPatterns = @(
        'at\s+([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)\s*\('
        'in\s+function\s+([A-Za-z_]\w*)'
        '([A-Za-z_]\w+)\(\)\s+(?:failed|error|exception)'
        'method\s+([A-Za-z_]\w*)'
        '`([A-Za-z_][\w\.]*)`'
    )

    foreach ($pattern in $functionPatterns)
    {
        [regex]::Matches($details.Message, $pattern) | ForEach-Object {
            if ($_.Groups[1].Value)
            {
                $details.Functions += $_.Groups[1].Value
            }
        }
    }

    # === ИЗВЛЕЧЕНИЕ ПЕРЕМЕННЫХ ===
    $variablePatterns = @(
        '\$([A-Za-z_]\w*)'
        'variable\s+["\"]?([A-Za-z_]\w*)'
        '(?:undefined|null|missing)\s+(?:variable|property)\s+["\"]?([A-Za-z_]\w*)'
    )

    foreach ($pattern in $variablePatterns)
    {
        [regex]::Matches($details.Message, $pattern) | ForEach-Object {
            if ($_.Groups[1].Value)
            {
                $details.Variables += '$' + $_.Groups[1].Value
            }
        }
    }
    # === ИЗВЛЕЧЕНИЕ КОМАНД ===
    $commandPatterns = @(
        'command\s+["\"]?([^"\"]+)["\"]?'
        'cmdlet\s+([A-Za-z]+-[A-Za-z]+)'
        '`([A-Za-z]+-[A-Za-z]+)`'
        'running\s+["\"]?([^"\"]+)["\"]?'
    )

    foreach ($pattern in $commandPatterns)
    {
        if ($details.Message -match $pattern)
        {
            $details.Commands += $matches[1]
        }
    }

    # === ИЗВЛЕЧЕНИЕ URL ===
    $urlPattern = '(https?://[^\s"<>]+)'
    [regex]::Matches($details.Message, $urlPattern) | ForEach-Object {
        $details.Urls += $_.Value
    }

    $urlPattern = '(https?://[^\s"<>]+)'
    [regex]::Matches($details.Message, $urlPattern) | ForEach-Object {
        $details.Urls += $_.Value
    }

    # === ИЗВЛЕЧЕНИЕ IP АДРЕСОВ ===
    $ipPattern = '\b(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b'
    [regex]::Matches($details.Message, $ipPattern) | ForEach-Object {
        $details.IpAddresses += $_.Value
    }

    # === ИЗВЛЕЧЕНИЕ ПОРТОВ ===
    $portPatterns = @(
        ':(\d{2,5})\b'
        'port\s+(\d{1,5})'
        'Port=(\d{1,5})'
    )

    foreach ($pattern in $portPatterns)
    {
        [regex]::Matches($details.Message, $pattern) | ForEach-Object {
            $port = [int]$_.Groups[1].Value
            if ($port -le 65535)
            {
                $details.Ports += $port
            }
        }
    }

    $errorCodePatterns = @(
        '(?:error|code|errno|0x)[:\s]*(\d+|0x[0-9A-Fa-f]+)'
        'HRESULT[:\s]*0x[0-9A-Fa-f]+'
        'Win32[:\s]*(\d+)'
        'exit\s+code[:\s]*(\d+)'
        '\b([A-Z]+_[A-Z_]+)\b'  # CONSTANT_STYLE_ERRORS
    )

    foreach ($pattern in $errorCodePatterns)
    {
        [regex]::Matches($details.Message, $pattern) | ForEach-Object {
            if ($_.Groups[1].Value)
            {
                $details.ErrorCodes += $_.Groups[1].Value
            }
        }
    }

    # === ИЗВЛЕЧЕНИЕ ПРЕДЛОЖЕНИЙ ПО ИСПРАВЛЕНИЮ ===
    $suggestionPatterns = @(
        'Did you mean[:\s]*([^?\n]+)'
        'Try[:\s]*([^.\n]+)'
        'Use[:\s]*([^.\n]+)'
        'Consider[:\s]*([^.\n]+)'
        'Instead[,\s]+([^.\n]+)'
    )

    foreach ($pattern in $suggestionPatterns)
    {
        if ($details.Message -match $pattern)
        {
            $details.Suggestions += $matches[1].Trim()
        }
    }

    # === ОБРАБОТКА INNER EXCEPTIONS ===
    if ($ErrorRecord.Exception.InnerException)
    {
        $inner = $ErrorRecord.Exception.InnerException
        $innerDetails = @{
            Message = $inner.Message
            Type = $inner.GetType().FullName
        }

        # Рекурсивно извлекаем из inner exception
        if ($inner.StackTrace)
        {
            $details.StackTrace = $inner.StackTrace
        }

        Add-Member -InputObject $details -MemberType NoteProperty -Name InnerException -Value $innerDetails
    }

    # === СПЕЦИФИЧНЫЕ ПАРСЕРЫ ===

    # Python errors
    if ($details.Type -match 'Python' -or $details.Message -match 'Traceback|File.*line \d+')
    {
        $details | Add-Member -NoteProperty Language -Value 'Python'

        if ($details.Message -match '([A-Za-z]+Error):\s*(.+)')
        {
            $details | Add-Member -NoteProperty PythonErrorType -Value $matches[1]
            $details | Add-Member -NoteProperty PythonErrorMessage -Value $matches[2]
        }
    }

    # Node.js/npm errors
    if ($details.Message -match 'npm|node|ERR!')
    {
        $details | Add-Member -NoteProperty Language -Value 'Node.js'

        if ($details.Message -match 'npm ERR! code (\w+)')
        {
            $details | Add-Member -NoteProperty NpmErrorCode -Value $matches[1]
        }
    }

    # Git errors
    if ($details.Message -match 'git|fatal:|remote:|branch')
    {
        $details | Add-Member -NoteProperty Tool -Value 'Git'

        if ($details.Message -match 'branch[:\s]+([^\s]+)')
        {
            $details | Add-Member -NoteProperty GitBranch -Value $matches[1]
        }
    }

    # Docker errors
    if ($details.Message -match 'docker|container|image')
    {
        $details | Add-Member -NoteProperty Tool -Value 'Docker'

        if ($details.Message -match 'container[:\s]+([a-f0-9]{12})')
        {
            $details | Add-Member -NoteProperty ContainerId -Value $matches[1]
        }
    }
    return $details
}

function Get-PathFromError
{
    param(
        [string]$ErrorMessage
    )

    # Различные паттерны для извлечения путей
    $patterns = @(
        ':\s*(.+\.py)$', # После двоеточия .py файл
        "['`"]([^'`"]+\.py)['`"]", # В кавычках .py файл
        '([A-Z]:[\\\/][^"<>|]+\.py)', # Windows путь
        '(\/[^"<>|]+\.py)', # Unix путь
        'File\s+"([^"]+)"', # Python traceback format
        'at\s+(.+\.py):\d+'
        '([A-Z]:[\\\/](?:[^\\\/\r\n"<>|:*?]+[\\\/])*[^\\\/\r\n"<>|:*?]+\.\w+)'
        '([A-Z]:[\\\/][^"<>|:*?\r\n]+)'

    # Unix пути
        '(\/(?:usr|home|var|tmp|opt|etc|bin|lib)\/[^"\s]+)'
        '(\.{1,2}\/[^"\s]+\.\w+)'

    # UNC пути
        '(\\\\[^\\\/\s]+[\\\/][^"<>|:*?\r\n]+)'

    # После ключевых слов
        '(?:File|Path|at|in)\s*["\"]?([^"\"]+\.\w+)'
        ':\s*([A-Z]:[\\\/][^"<>|:*?\r\n]+)'
        ':\s*(\/[^"\s]+)'

    # В кавычках
        "['`\`"]([^'`\`"]+\.\w+)['`\`"]"
        '"([^"]+\.\w+)"'

    # Python traceback
        'File\s+"([^"]+)",\s+line\s+(\d+)'

    # Node.js/JavaScript
        'at\s+(?:.*?\s+\()?([^:\(\)]+):(\d+):(\d+)\)?'

    # .NET
        'at\s+[^\s]+\s+in\s+([^:]+):line\s+(\d+)'

    # PowerShell
        'At\s+([^:]+):(\d+)\s+char:(\d+)'
    # At file.py:line format
    )

    foreach ($pattern in $patterns)
    {
        if ($ErrorMessage -match $pattern)
        {
            $path = $matches[1].Trim()

            # Проверяем валидность пути
            if ($path -and (Test-Path $path -IsValid))
            {
                return @{
                    FullPath = $path
                    FileName = Split-Path $path -Leaf
                    Directory = Split-Path $path -Parent
                    Exists = Test-Path $path
                    Extension = [System.IO.Path]::GetExtension($path)
                }
            }
        }
    }

    return $null
}



function Log-Error
{
    param(
        [System.Management.Automation.ErrorRecord]$ErrorRecord,
        [string]$FormattedMessage

    )

    if (-not $ErrorViewConfig.LogErrors)
    {
        return
    }

    $logEntry = @"
[$( Get-Date -Format 'yyyy-MM-dd HH:mm:ss' )] ERROR
Type: $( $ErrorRecord.Exception.GetType().Name )
Message: $( $ErrorRecord.Exception.Message )
Formatted: $FormattedMessage
Command: $( $ErrorRecord.InvocationInfo.MyCommand.Name )
Line: $( $ErrorRecord.InvocationInfo.ScriptLineNumber )
Script: $( $ErrorRecord.InvocationInfo.ScriptName )
---

"@

    Add-Content -Path $ErrorViewConfig.LogPath -Value $logEntry -Encoding UTF8
}
#endregion

#region Создание главной функции для обработки ошибок
function ConvertTo-SmartErrorView
{
    [CmdletBinding()]
    param(
        [System.Management.Automation.ErrorRecord]$InputObject
    )
    try
    {
        # Получаем шаблон для ошибки


        # Если  ObjectNotFound считаем просто опечаткой
        if ($InputObject.CategoryInfo.Category -eq "ObjectNotFound")
        {
            $output = ""
            if ($InputObject.Exception.Message -match "The term ['`"](.+?)['`"] is not recognized")
            {
                $commandName = $matches[1]
                $output += wrgb "😈 "$commandName -FC Material_Orange -newline
            }
            $output += wrgb  "👻 Неправильно набрана команда, "  -FC "Material_Yellow"
            $output += wrgb  "попробуйте ещё раз 😊"  -FC "#1177CC" -newline
            $output
            gh $commandName | d
            RETURN
        }

        $template = Get-ErrorTemplate -ErrorRecord $InputObject
        # Извлекаем детали ошибки
        $details = Extract-ErrorDetails -ErrorRecord $InputObject

        # Переводим сообщение
        $translatedMessage = Translate-ErrorMessage -Message $details.Message -ExceptionType $InputObject.Exception.GetType().Name
        $details.Message = $translatedMessage
        $translatedCommand = Translate-ErrorMessage -Message $details.Command -ExceptionType $InputObject.Exception.GetType().Name
        $details.Command = $translatedCommand


        foreach ($Key in $InputObject.Exeption.Keys)
        {
            wrgb "${Key} : "  -FC White
            wrgb  $InputObject[$Key] -FC Red -newline
        }

        #    Get-Error
        $formattedMessage = ""
        # Формируем сообщение по шаблону
        foreach ($key in $template.KEYS)
        {
            $string = $template[$key]
            $formattedMessage += "${string}/n"
        }

        #        foreach ($key in $details.Keys)
        #        {
        #            $formattedMessage = $formattedMessage -replace "\{$key\}", $details[$key]
        #            wrgb  $key -FC TealRGB -newline
        #            wrgb  $details[$key] -FC OrangeRGB -newline
        #            wrgb  $formattedMessage -FC OrangeRGB -newline
        #        }
        $formattedMessage = $formattedMessage -replace "\{Icon\}", $template.Icon
        $formattedMessage = "🔴" + "$formattedMessage" + "🔴"
        # Добавляем информацию о расположении ошибки
        if ($InputObject.InvocationInfo -and $InputObject.InvocationInfo.ScriptLineNumber)
        {
            $location = "📍 Строка: $( $InputObject.InvocationInfo.ScriptLineNumber )"
            if ($InputObject.InvocationInfo.ScriptName)
            {
                $scriptName = Split-Path $InputObject.InvocationInfo.ScriptName -Leaf
                $location += ", Файл: $scriptName"
            }
            $formattedMessage += "`n$location"
        }

        # Добавляем предложение по исправлению
        if ($template.Suggestion)
        {
            $formattedMessage += "`n📋$( $template.Suggestion )📋"
        }

        # Добавляем информацию о внутренних исключениях
        if ($ErrorViewConfig.ShowInnerExceptions -and $InputObject.Exception.InnerException)
        {
            $innerEx = $InputObject.Exception.InnerException
            $innerMessage = Translate-ErrorMessage -Message $innerEx.Message -ExceptionType $innerEx.GetType().Name
            $formattedMessage += "`n🔍 Внутренняя ошибка: $innerMessage"
        }

        # Добавляем stack trace если нужно
        if ($ErrorViewConfig.ShowStackTrace -and $InputObject.Exception.StackTrace)
        {
            $formattedMessage += "`n📊 Stack Trace:`n$( $InputObject.Exception.StackTrace )"
        }

        # Логируем ошибку
        Log-Error -ErrorRecord $InputObject -FormattedMessage $formattedMessage

        # Проверяем критичность ошибки
        $criticalErrors = @("UnauthorizedAccessException", "OutOfMemoryException", "StackOverflowException")
        if ($ErrorViewConfig.NotifyOnCritical -and $criticalErrors -contains $InputObject.Exception.GetType().Name)
        {
            $formattedMessage += "`n🚨 КРИТИЧЕСКАЯ ОШИБКА! Требует немедленного внимания!"
        }

        #        Console-Warn formattedMessage

        #            Get-ErrorTranslate($InputObject)
        #
        #            # Заголовок ошибки
        #            $output += wrgb  "🔴  Ошибка: "  -FC "#FF0000"
        #            $output += wrgb  $InputObject.Exception.Message  -FC "Material_Orange" -newline
        #
        #            # Категория
        #            $output += wrgb  "📋  Категория: " -FC "#FF3300"
        #            $output += wrgb  $InputObject.CategoryInfo.Category -FC "Material_Yellow" -newline
        #
        #            # Тип исключения
        #            $output += wrgb "⚡  Тип исключения: " -FC "#FF5533"
        #            $output += wrgb   $InputObject.Exception.GetType().Name -FC "Material_Pink" -newline
        #
        #            # ID ошибки
        #            $output += wrgb "🆔  ID Ошибки: " -FC "#FF5555"
        #            $output += wrgb  $InputObject.FullyQualifiedErrorId -FC Material_Purple -newline
        #
        #            # Позиция (если доступна)
        #            if ($InputObject.InvocationInfo -and $InputObject.InvocationInfo.ScriptLineNumber)
        #            {
        #                $output += wrgb "📍  Расположение: "  -FC "#FF5533"
        #                $output += wrgb  " Линия " -FC "#FF3300"
        #                $output += wrgb    $InputObject.InvocationInfo.ScriptLineNumber  -FC "#FFFFFF"
        #                $output += wrgb     "  Колонка "  -FC "#FF3300"
        #                $output += wrgb  $InputObject.InvocationInfo.OffsetInLine   -FC "#FFFFFF" -newline
        #            }
        #
        #            # Команда, вызвавшая ошибку
        #            if ($InputObject.InvocationInfo -and $InputObject.InvocationInfo.MyCommand)
        #            {
        #                $output += wrgb  "🔧  Команда: "  -FC "#FFAAAA"
        #                $output += wrgb $InputObject.InvocationInfo.MyCommand.Name -FC "#FF0000"  -newline
        #                wrgb "" -newline
        #            }
        #            $output
        wrgb  $formattedMessage
        return $formattedMessage

    }
    catch
    {
        # Если что-то пошло не так с обработкой ошибки, возвращаем оригинальное сообщение
        return "❌ $( $InputObject.Exception.Message )"
    }
}

# Создаем также упрощенную версию
function ConvertTo-CompactErrorView
{
    [CmdletBinding()]
    param(
        [System.Management.Automation.ErrorRecord]$InputObject
    )

    $template = Get-ErrorTemplate -ErrorRecord $InputObject
    $translatedMessage = Translate-ErrorMessage -Message $InputObject.Exception.Message -ExceptionType $InputObject.Exception.GetType().Name
    Test-GradientDemo


    return "$( $template.Icon ) $translatedMessage"
}
#endregion

#region Функции управления конфигурацией
function Set-ErrorViewConfig
{
    param(
        [string]$Language,
        [bool]$AutoTranslate,
        [bool]$ShowStackTrace,
        [bool]$ShowInnerExceptions,
        [bool]$UseColors,
        [bool]$LogErrors,
        [string]$LogPath,
        [bool]$NotifyOnCritical
    )

    if ($Language)
    {
        $ErrorViewConfig.Language = $Language
    }
    if ( $PSBoundParameters.ContainsKey('AutoTranslate'))
    {
        $ErrorViewConfig.AutoTranslate = $AutoTranslate
    }
    if ( $PSBoundParameters.ContainsKey('ShowStackTrace'))
    {
        $ErrorViewConfig.ShowStackTrace = $ShowStackTrace
    }
    if ( $PSBoundParameters.ContainsKey('ShowInnerExceptions'))
    {
        $ErrorViewConfig.ShowInnerExceptions = $ShowInnerExceptions
    }
    if ( $PSBoundParameters.ContainsKey('UseColors'))
    {
        $ErrorViewConfig.UseColors = $UseColors
    }
    if ( $PSBoundParameters.ContainsKey('LogErrors'))
    {
        $ErrorViewConfig.LogErrors = $LogErrors
    }
    if ($LogPath)
    {
        $ErrorViewConfig.LogPath = $LogPath
    }
    if ( $PSBoundParameters.ContainsKey('NotifyOnCritical'))
    {
        $ErrorViewConfig.NotifyOnCritical = $NotifyOnCritical
    }

    wrgb "Конфигурация обновлена!" -FC Green
}

function Get-ErrorViewConfig
{
    return $ErrorViewConfig
}

function Add-ErrorTemplate
{
    param(
        [string]$ExceptionType,
        [string]$Icon,
        [string]$Pattern,
        [string]$Template,
        [string]$Suggestion,
        [string]$Color = "Red"
    )

    $ErrorTemplates[$ExceptionType] = @{
        Icon = $Icon
        Pattern = $Pattern
        Template = $Template
        Suggestion = $Suggestion
        Color = $Color
    }

    wrgb "Добавлен шаблон для $ExceptionType" -FC Green
}

function Add-ErrorTranslation
{
    param(
        [string]$Pattern,
        [string]$Translation
    )

    $ErrorTranslations[$Pattern] = $Translation
    wrgb "Добавлен перевод для '$Pattern'" -FC Green
}
#endregion

#region Глобальный обработчик ошибок
function Enable-GlobalErrorHandler
{
    # Устанавливаем умный обработчик ошибок по умолчанию
    $global:ErrorView = "Smart"
    wrgb "✅  Включен глобальный обработчик ошибок: " -FC TealRGB
    wrgb  $global:ErrorView -BC GoldRGB -FC BlackRGB -Style Bold -newline
}

function Disable-GlobalErrorHandler
{

    wrgb "❌ Отключен глобальный обработчик ошибок: " -FC Material_Yellow
    wrgb $global:ErrorView -FC WhiteRGB
    $global:ErrorView = "Simple"
}
#endregion


# Включаем умный обработчик
Enable-GlobalErrorHandler
#Clear-Host



function errorMethodsInfo
{
    wrgb "`n--- Конфигурация системы ---" -FC Yellow
    wrgb "Текущая конфигурация:" -FC Material_Pink -newline
    $config = Get-ErrorViewConfig
    $i = 0
    $config.GetEnumerator() | Sort-Object Key | ForEach-Object {
        wrgb   $_.Key" :  " -FC Gray
        $color = Get-GradientColor -Index (++$i) -TotalItems 4 -StartColor "#0057B7" -EndColor "#FFD700"
        wrgb   $_.Value -FC $color -newline
    }

    wrgb "`n--- Доступные команды ---" -FC Yellow
    @(
        "Enable-GlobalErrorHandler  - включить умный обработчик",
        "Disable-GlobalErrorHandler - отключить умный обработчик",
        "Set-ErrorViewConfig        - изменить настройки",
        "Add-ErrorTemplate          - добавить шаблон ошибки",
        "Add-ErrorTranslation       - добавить перевод",
        "Format-Error Smart         - показать ошибку с умной обработкой",
        "Format-Error Compact       - показать ошибку в компактном виде"
    ) | ForEach-Object {
        wrgb "  $_" -FC White -newline
    }

    #wrgb "`n--- Пример кастомизации ---" -FC Yellow

    # Добавляем кастомный шаблон
    Add-ErrorTemplate -ExceptionType "CustomException" -Icon "🎯" -Pattern "custom.*error" -Template "{Icon} Кастомная ошибка: {Message}" -Suggestion "💡 Обратитесь к документации"

    # Добавляем кастомный перевод
    Add-ErrorTranslation -Pattern "custom error occurred" -Translation "произошла кастомная ошибка"
    #wrgb "`nСистема готова к использованию! 🚀" -FC Green
    #wrgb "Все ошибки теперь будут автоматически обрабатываться с переводом и умными подсказками." -FC White

    # Показываем информацию о логах
    if ($ErrorViewConfig.LogErrors)
    {
        wrgb "`n📝 Ошибки логируются в: " -FC "Material_Comment"
        wrgb  $ErrorViewConfig.LogPath  -BC "#162022" -FC "#000000"
    }
    else
    {
        Write-Host ""
    }
}

#errorMethodsInfo
#endregion
Trace-ImportProcess  $MyInvocation.MyCommand.Name.trim(".ps1")
