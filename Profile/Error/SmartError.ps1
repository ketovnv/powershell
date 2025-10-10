# Шаблоны перевода ошибок
$ErrorTranslations = @{
# Общие сообщения
    "Access is denied" = "Доступ запрещён"
    "NotSpecified" = "Не указана"
    "The term .* is not recognized" = "Команда '{}' не распознана"
    "Cannot find path" = "Не удается найти путь 🔍"
    "Cannot find drive" = "Не удается найти диск 💿"
    "The file .* cannot be found" = "Файл '{}' не найден"
    "Cannot convert value" = "Не удается преобразовать значение"
    "Attempted to divide by zero" = "Попытка деления на ноль 😲"
    "Object reference not set" = "Ссылка на объект не установлена 📎"
    "Index was outside the bounds" = "Индекс вышел за пределы массива 📎"
    "The property .* cannot be found" = "Свойство '{}' не найдено 📎"
    "Cannot validate argument" = "Не удается проверить аргумент"
    "Parameter .* cannot be found" = "Параметр '{}' не найден 🔍"
    "Network path was not found" = "Сетевой путь не найден 📡"
    "Access to the path .* is denied" = "Доступ к пути '{}' запрещён 🔒"

    # Комманды
    "Import-PythonModule" = "Import-PythonModule (Импорт модуля Питона) ⚗️"

    # Специфичные ошибки
    "Python module not found" = "Модуль Питона не найден 🙁"
    "CommandNotFoundException" = "Команда не найдена 🙁"
    "ParameterBindingException" = "Ошибка привязки параметра 🧶"
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
        Template = "{Icon} '{message}': `n  {FullPath}"
        Suggestion = "Проверить путь к  модулю 💡"
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

function Get-ErrorMessageTranslate
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

#region Создание главной функции для обработки ошибок
function ConvertTo-SmartErrorView
{
    [CmdletBinding()]
    param(
        [System.Management.Automation.ErrorRecord]$InputObject
    )
    try
    {
        # Если  ObjectNotFound считаем просто опечаткой
        if ($InputObject.CategoryInfo.Category -eq "ObjectNotFound")
        {
            $output = ""
            if ($InputObject.Exception.Message -match "The term ['`"](.+?)['`"] is not recognized")
            {
                $commandName = $matches[1]
                $output += wrgb "😈 "$commandName -FC Material_Orange
            }
            $output += wrgb  "   👻 Неправильно набрана команда, "  -FC "Material_Yellow"
            $output += wrgb  "попробуйте ещё раз 😊"  -FC "#1177CC" -newline
            $output
            #            gh $commandName | d
            RETURN
        }

        # Получаем шаблон для ошибки
        $template = Get-ErrorTemplate -ErrorRecord $InputObject
        # Извлекаем детали ошибки
        $details = Get-ErrorDetails -ErrorRecord $InputObject

        # Переводим сообщение
        $translatedMessage = Get-ErrorMessageTranslate -Message $details.Message -ExceptionType $InputObject.Exception.GetType().Name
        $details.Message = $translatedMessage
        $translatedCommand = Get-ErrorMessageTranslate -Message $details.Command -ExceptionType $InputObject.Exception.GetType().Name
        $details.Command = $translatedCommand

        $translatedCategory = Get-ErrorMessageTranslate -Message $details.Category -ExceptionType $InputObject.Exception.GetType().Name
        $details.Category = $translatedCategory


        $detailsKeyColor = "OneDark_Green"
        $detailsValueColor = "Nord_FrostBlue"

        #                        foreach ($Key in  $details.keys)
        #                        {
        #                            wrgb "${Key} : "  -FC $detailsKeyColor
        #                            wrgb  $details[$Key] -FC $detailsValueColor -newline
        #                        }
        #                       debug $details

        $formattedMessage = $template.template
        foreach ($key in $details.Keys)
        {
            $formattedMessage = $formattedMessage -replace "\{$key\}", $details[$key]
        }

        $formattedMessage = $formattedMessage -replace "\{Icon\}", $template.Icon
        $formattedMessage += wrgb  "`n  🔴 ОШИБКА: 🔴`n  "  -FC Material_Orange
        $formattedMessage += wrgbn $formattedMessage  -FC $template.Color
        #        $formattedMessage += wrgbn  "  🔴 🔴 🔴 🔴 🔴 🔴 🔴 🔴 🔴🔴 🔴 🔴 "

        # Категория

        $formattedMessage += wrgb  "  📋 Категория:" -FC Dracula_Purple
        $formattedMessage += wrgbn  $details.Category -FC $detailsValueColor

        # Команда, вызвавшая ошибку
        if ($details.Command)
        {
            $formattedMessage += wrgb  "  🎙️  Команда:"  -FC Nord_AuroraOrange
            $formattedMessage += wrgbn $details.Command -FC $detailsValueColor

        }

        if ($details.Directory)
        {
            $formattedMessage += wrgb  "  📁 Директория:"  -FC  $detailsKeyColor
            $formattedMessage += wrgbn $details.Directory -FC $detailsValueColor
        }

        if ($details.ScriptName)
        {
            $scriptName = Split-Path $details.ScriptName -Leaf
            $formattedMessage += wrgb  "  📑 Файл:"  -FC  $detailsKeyColor
            $formattedMessage += wrgbn $scriptName -FC $detailsValueColor
        }

        if ($details.Line)
        {
            $formattedMessage += wrgb  "  📝️ Строка:"  -FC  $detailsKeyColor
            $formattedMessage += wrgb $details.Line -FC White  -newline
        }

        #    Добавляем информацию о расположении ошибки

        if ($details.OffsetInLine -and $details.ScriptLineNumber)
        {
            $formattedMessage += wrgb "  📍 Расположение: "  -FC  $detailsKeyColor
            $formattedMessage += wrgb  "Линия " -FC  $detailsValueColor
            $formattedMessage += wrgb    $InputObject.InvocationInfo.ScriptLineNumber  -FC White
            $formattedMessage += wrgb     "  Колонка "  -FC  $detailsValueColor
            $formattedMessage += wrgbn  $InputObject.InvocationInfo.OffsetInLine   -FC White
        }

        if ($template.Suggestion)
        {
            $formattedMessage += wrgb  "  🧙‍♂️ Совет:"  -FC  $detailsKeyColor
            $formattedMessage += wrgb $template.Suggestion -FC $detailsValueColor  -newline
        }
        $criticalErrors = @("UnauthorizedAccessException", "OutOfMemoryException", "StackOverflowException")
        if ($ErrorViewConfig.NotifyOnCritical -and $criticalErrors -contains $InputObject.Exception.GetType().Name)
        {
            $formattedMessage += "`n🚨 КРИТИЧЕСКАЯ ОШИБКА! Требует немедленного внимания!"
        }



        wrgb "`n   "
        $path = $details.FullPath ?? $details.ScriptName
        return $path ? "🔴 ${path} 🔴" : "  🔴 🔴 🔴 🔴 🔴 🔴 🔴 🔴 🔴 🔴 `n`n"
        #      Проверяем критичность ошибки

        # Добавляем предложение по исправлению

        # Добавляем информацию о внутренних исключениях
        #        if ($ErrorViewConfig.ShowInnerExceptions -and $InputObject.Exception.InnerException)
        #        {
        #            $innerEx = $InputObject.Exception.InnerException
        #            $innerMessage = Translate-ErrorMessage -Message $innerEx.Message -ExceptionType $innerEx.GetType().Name
        #            $formattedMessage += "`n🔍 Внутренняя ошибка: $innerMessage"
        #        }
        #
        #        # Добавляем stack trace если нужно
        #        if ($ErrorViewConfig.ShowStackTrace -and $InputObject.Exception.StackTrace)
        #        {
        #            $formattedMessage += "`n📊 Stack Trace:`n$( $InputObject.Exception.StackTrace )"
        #        }

        # Логируем ошибку
        #        Log-Error -ErrorRecord $InputObject -FormattedMessage $formattedMessage


        #        Console-Warn formattedMessage

        #            Get-ErrorTranslate($InputObject)
        #
        #            # Заголовок ошибки

        #

        #

        #
        #            # ID ошибки
        #            $output += wrgb "🆔  ID Ошибки: " -FC "#FF5555"
        #            $output += wrgb  $InputObject.FullyQualifiedErrorId -FC Material_Purple -newline
        #


    }
    catch
    {
        # Если что-то пошло не так с обработкой ошибки, возвращаем оригинальное сообщение
        return "❌ $( $InputObject.Exception.Message )"
    }
}

# Создаем также упрощенную версию