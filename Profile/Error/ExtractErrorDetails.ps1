function Get-ErrorDetails
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
        TargetType = $ErrorRecord.CategoryInfo.TargetType
        StackTrace = $ErrorRecord.Exception.StackTrace
        InnerException = $ErrorRecord.Exception.InnerException
        TargetObject = $ErrorRecord.TargetObject
        Timestamp = Get-Date
        Source = $ErrorRecord.InvocationInfo.MyCommand.Name
        ScriptName = $ErrorRecord.InvocationInfo.ScriptName
        ScriptLineNumber = $ErrorRecord.InvocationInfo.ScriptLineNumber
        OffsetInLine = $ErrorRecord.InvocationInfo.OffsetInLine
        Command = $ErrorRecord.InvocationInfo.MyCommand
        Line = $ErrorRecord.InvocationInfo.Line.trim()
    }

    #    d $ErrorRecord.InvocationInfo

    # Извлекаем пути из сообщения
    if ($ErrorRecord.Exception.Message -match "'([^']+)'")
    {
        $details.Path = $matches[1]
        $details.FileName = Split-Path $matches[1] -Leaf
    }

    # Извлекаем имя параметра для ParameterBindingException


    if ($details.Message -match "'([^']+)'")
    {
        $details.HighlightedText = $matches[1]
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