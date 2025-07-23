#region Интеллектуальное определение типа контента
function Get-ContentType {
    <#
    .SYNOPSIS
        Автоматически определяет тип контента с помощью эвристического анализа
    #>
    param(
        [string[]]$Content,
        [switch]$Detailed
    )

    $analysis = @{
        Type = 'Unknown'
        Confidence = 0
        Indicators = @()
        Encoding = 'UTF-8'
        Language = 'Unknown'
        Structure = @{}
    }

    $text = $Content -join "`n"

    # Проверяем различные индикаторы
    $checks = @(
    # PowerShell
        @{
            Type = 'PowerShell'
            Patterns = @(
                '^function\s+\w+-\w+',
                '\$\w+\s*=',
                'param\s*\(',
                '\[CmdletBinding\(',
                'Get-\w+|Set-\w+|New-\w+',
                '-eq|-ne|-gt|-lt'
            )
            Weight = 10
        }

    # JSON
        @{
            Type = 'JSON'
            Patterns = @(
                '^\s*\{[\s\S]*\}\s*$',
                '^\s*\[[\s\S]*\]\s*$',
                '"[^"]+"\s*:\s*["{}\[\]0-9]',
                ':\s*(true|false|null)'
            )
            Weight = 15
        }

    # XML/HTML
        @{
            Type = 'XML/HTML'
            Patterns = @(
                '^<\?xml',
                '<html',
                '<\w+[^>]*>.*</\w+>',
                '<!DOCTYPE'
            )
            Weight = 15
        }

    # Логи
        @{
            Type = 'Log'
            Patterns = @(
                '\d{4}-\d{2}-\d{2}.*\d{2}:\d{2}:\d{2}',
                '\[(ERROR|WARN|INFO|DEBUG)\]',
                '^\[\d+\]',
                'Exception|Error|Failed'
            )
            Weight = 8
        }

    # Markdown
        @{
            Type = 'Markdown'
            Patterns = @(
                '^#{1,6}\s',
                '^\*\s+',
                '^\d+\.\s+',
                '\[.*\]\(.*\)',
                '```\w*'
            )
            Weight = 10
        }

    # CSV
        @{
            Type = 'CSV'
            Patterns = @(
                '^[^,]+,[^,]+',
                '^"[^"]+","[^"]+"',
                '^\w+,\w+,\w+'
            )
            Weight = 12
        }

    # Код (общий)
        @{
            Type = 'Code'
            Patterns = @(
                '^\s*(if|for|while|function|class|def|public|private)',
                '{\s*$',
                ';\s*$',
                '//|/\*|\*/',
                '#include|import|using'
            )
            Weight = 7
        }
    )

    $scores = @{}

    foreach ($check in $checks) {
        $score = 0
        foreach ($pattern in $check.Patterns) {
            if ($text -match $pattern) {
                $score += $check.Weight
                $analysis.Indicators += "Found pattern: $pattern"
            }
        }
        $scores[$check.Type] = $score
    }

    # Определяем тип с наибольшим счетом
    $bestMatch = $scores.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1

    if ($bestMatch.Value -gt 0) {
        $analysis.Type = $bestMatch.Key
        $analysis.Confidence = [Math]::Min(100, $bestMatch.Value * 5)
    }

    # Дополнительный анализ структуры
    $analysis.Structure = @{
        Lines = $Content.Count
        AverageLineLength = ($Content | Measure-Object -Property Length -Average).Average
        EmptyLines = ($Content | Where-Object { $_ -match '^\s*$' }).Count
        IndentationStyle = Get-IndentationStyle -Content $Content
    }

    # Определение языка (простая эвристика)
    if ($text -match '[а-яА-Я]{3,}') {
        $analysis.Language = 'Russian'
    } elseif ($text -match '[a-zA-Z]{3,}') {
        $analysis.Language = 'English'
    }

    if ($Detailed) {
        return $analysis
    } else {
        return $analysis.Type
    }
}

function Get-IndentationStyle {
    param([string[]]$Content)

    $tabs = 0
    $spaces2 = 0
    $spaces4 = 0

    foreach ($line in $Content) {
        if ($line -match '^\t') { $tabs++ }
        elseif ($line -match '^  (?! )') { $spaces2++ }
        elseif ($line -match '^    (?! )') { $spaces4++ }
    }

    if ($tabs -gt $spaces2 -and $tabs -gt $spaces4) {
        return "Tabs"
    } elseif ($spaces4 -gt $spaces2) {
        return "4 Spaces"
    } elseif ($spaces2 -gt 0) {
        return "2 Spaces"
    } else {
        return "None/Mixed"
    }
}
#endregion

#region Универсальный файловый парсер
function Out-ParsedFile {
    <#
    .SYNOPSIS
        Универсальный парсер файлов с автоопределением типа
    
    .DESCRIPTION
        Автоматически определяет тип файла и применяет соответствующую подсветку
    
    .PARAMETER Path
        Путь к файлу
    
    .PARAMETER Type
        Принудительно указать тип файла
    
    .PARAMETER Theme
        Цветовая тема
    
    .EXAMPLE
        Out-ParsedFile -Path ".\script.ps1"
        
    .EXAMPLE
        Out-ParsedFile -Path ".\data.json" -Theme "Dracula"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Path,

        [ValidateSet('Auto', 'PowerShell', 'JSON', 'XML', 'Log', 'Markdown', 'CSV', 'Text')]
        [string]$Type = 'Auto',

        [ValidateSet('Default', 'Dracula', 'Nord', 'OneDark', 'Material')]
        [string]$Theme = 'Default',

        [switch]$ShowLineNumbers,

        [switch]$ShowFileInfo,

        [int]$MaxLines = 0,

        [switch]$Wrap
    )

    # Проверяем существование файла
    if (-not (Test-Path $Path)) {
        Write-Status -Error "Файл не найден: $Path"
        return
    }

    $fileInfo = Get-Item $Path

    # Показываем информацию о файле
    if ($ShowFileInfo) {
        Write-GradientHeader -Title "FILE INFO" -StartColor "#4ECDC4" -EndColor "#44A08D"

        Write-RGB "📄 Имя: " -FC "Cyan"
        Write-RGB $fileInfo.Name -FC "White" -Style Bold -newline

        Write-RGB "📁 Путь: " -FC "Cyan"
        Write-RGB $fileInfo.DirectoryName -FC "Gray" -newline

        Write-RGB "📏 Размер: " -FC "Cyan"
        $size = switch ($fileInfo.Length) {
            { $_ -gt 1GB } { "{0:N2} GB" -f ($_ / 1GB) }
            { $_ -gt 1MB } { "{0:N2} MB" -f ($_ / 1MB) }
            { $_ -gt 1KB } { "{0:N2} KB" -f ($_ / 1KB) }
            default { "$_ bytes" }
        }
        Write-RGB $size -FC "Yellow" -newline

        Write-RGB "📅 Изменен: " -FC "Cyan"
        Write-RGB $fileInfo.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss") -FC "Dracula_Purple" -newline

        Write-GradientLine -Length 50 -StartColor "#4ECDC4" -EndColor "#44A08D"
    }

    # Читаем содержимое
    $content = Get-Content $Path -ErrorAction Stop

    if ($MaxLines -gt 0 -and $content.Count -gt $MaxLines) {
        $content = $content | Select-Object -First $MaxLines
        Write-RGB "`n... Показаны первые $MaxLines строк из $($content.Count) ..." -FC "DarkGray" -newline
    }

    # Определяем тип если не указан
    if ($Type -eq 'Auto') {
        $extension = $fileInfo.Extension.ToLower()
        $Type = switch ($extension) {
            '.ps1' { 'PowerShell' }
            '.psm1' { 'PowerShell' }
            '.psd1' { 'PowerShell' }
            '.json' { 'JSON' }
            '.xml' { 'XML' }
            '.html' { 'XML' }
            '.log' { 'Log' }
            '.md' { 'Markdown' }
            '.csv' { 'CSV' }
            default { Get-ContentType -Content $content }
        }
    }

    # Применяем тему
    Apply-ParserTheme -Theme $Theme

    # Выводим с подсветкой
    Write-RGB "`nТип файла: " -FC "Gray"
    Write-RGB $Type -FC "Cyan" -Style Bold -newline
    Write-RGB ""  -newline

    switch ($Type) {
        'PowerShell' {
            $content | Out-ParsedPowerShell -ShowLineNumbers:$ShowLineNumbers
        }
        'JSON' {
            $content | Out-ParsedJSON -ShowLineNumbers:$ShowLineNumbers
        }
        'XML' {
            $content | Out-ParsedXML -ShowLineNumbers:$ShowLineNumbers
        }
        'Log' {
            $content | Out-ParsedLog -ShowLineNumbers:$ShowLineNumbers
        }
        'Markdown' {
            $content | Out-ParsedMarkdown -ShowLineNumbers:$ShowLineNumbers
        }
        'CSV' {
            $content | Out-ParsedCSV -ShowLineNumbers:$ShowLineNumbers
        }
        default {
            $content | Out-ParsedText -ShowLineNumbers:$ShowLineNumbers
        }
    }
}

function Apply-ParserTheme {
    param([string]$Theme)

    # Здесь можно переопределить цвета в зависимости от темы
    switch ($Theme) {
        'Dracula' {
            # Применяем цвета Dracula
        }
        'Nord' {
            # Применяем цвета Nord
        }
        # и т.д.
    }
}
#endregion

#region Специализированные парсеры для разных форматов
function Out-ParsedPowerShell {
    param(
        [Parameter(ValueFromPipeline)]
        [string[]]$InputText,
        [switch]$ShowLineNumbers
    )

    begin {
        # Расширенные правила для PowerShell
        $psRules = @{
            Keywords = @{
                Patterns = @(
                    @{ Regex = '\b(function|param|begin|process|end|if|else|elseif|switch|for|foreach|while|do|try|catch|finally|return|break|continue|throw|class|enum)\b'; Priority = 100 }
                )
                Style = @{ FC = "Dracula_Pink"; Effects = @('Bold') }
            }

            Cmdlets = @{
                Patterns = @(
                    @{ Regex = '\b(Get|Set|New|Remove|Add|Clear|Copy|Move|Rename|Test|Start|Stop|Restart|Select|Where|ForEach|Sort|Group|Measure|Export|Import|ConvertTo|ConvertFrom|Out|Write|Read)-[A-Z]\w+\b'; Priority = 90 }
                )
                Style = @{ FC = "Dracula_Cyan"; Effects = @('Bold') }
            }

            Variables = @{
                Patterns = @(
                    @{ Regex = '\$[A-Za-z_]\w*'; Priority = 80 }
                    @{ Regex = '\$\{[^}]+\}'; Priority = 85 }
                )
                Style = @{ FC = "Dracula_Green" }
            }

            Comments = @{
                Patterns = @(
                    @{ Regex = '#.*$'; Priority = 70 }
                    @{ Regex = '<#[\s\S]*?#>'; Priority = 75 }
                )
                Style = @{ FC = "Dracula_Comment"; Effects = @('Italic') }
            }

            Strings = @{
                Patterns = @(
                    @{ Regex = '"[^"]*"'; Priority = 60 }
                    @{ Regex = "'[^']*'"; Priority = 60 }
                    @{ Regex = '@"[\s\S]*?"@'; Priority = 65 }
                    @{ Regex = "@'[\s\S]*?'@"; Priority = 65 }
                )
                Style = @{ FC = "Dracula_Yellow" }
            }
        }
    }

    process {
        $InputText | Out-ParsedText -CustomRules $psRules -ShowLineNumbers:$ShowLineNumbers
    }
}

function Out-ParsedJSON {
    param(
        [Parameter(ValueFromPipeline)]
        [string[]]$InputText,
        [switch]$ShowLineNumbers,
        [switch]$Validate
    )

    begin {
        $jsonRules = @{
            Keys = @{
                Patterns = @(
                    @{ Regex = '"[^"]+"\s*:'; Priority = 90 }
                )
                Style = @{ FC = "Dracula_Purple"; Effects = @('Bold') }
            }

            StringValues = @{
                Patterns = @(
                    @{ Regex = ':\s*"[^"]*"'; Priority = 80 }
                )
                Style = @{ FC = "Dracula_Green" }
            }

            Numbers = @{
                Patterns = @(
                    @{ Regex = ':\s*-?\d+\.?\d*([eE][+-]?\d+)?'; Priority = 80 }
                )
                Style = @{ FC = "Dracula_Pink" }
            }

            Booleans = @{
                Patterns = @(
                    @{ Regex = ':\s*(true|false|null)'; Priority = 85 }
                )
                Style = @{ FC = "Dracula_Orange"; Effects = @('Bold') }
            }

            Structure = @{
                Patterns = @(
                    @{ Regex = '[\{\}\[\]]'; Priority = 95 }
                )
                Style = @{ FC = "Dracula_Cyan"; Effects = @('Bold') }
            }
        }

        $allText = @()
    }

    process {
        $allText += $InputText
    }

    end {
        # Валидация JSON если требуется
        if ($Validate) {
            try {
                $null = $allText -join "`n" | ConvertFrom-Json -ErrorAction Stop
                Write-Status -Success "JSON валиден"
            } catch {
                Write-Status -Error "JSON не валиден: $($_.Exception.Message)"
            }
        }

        $allText | Out-ParsedText -CustomRules $jsonRules -ShowLineNumbers:$ShowLineNumbers
    }
}

function Out-ParsedLog {
    param(
        [Parameter(ValueFromPipeline)]
        [string[]]$InputText,
        [switch]$ShowLineNumbers,
        [switch]$GroupBySeverity
    )

    begin {
        $logEntries = @{
            ERROR = @()
            WARN = @()
            INFO = @()
            DEBUG = @()
            OTHER = @()
        }
    }

    process {
        foreach ($line in $InputText) {
            if ($GroupBySeverity) {
                $severity = switch -Regex ($line) {
                    'ERROR|FAIL|FATAL' { 'ERROR' }
                    'WARN|WARNING' { 'WARN' }
                    'INFO|INFORMATION' { 'INFO' }
                    'DEBUG|TRACE' { 'DEBUG' }
                    default { 'OTHER' }
                }
                $logEntries[$severity] += $line
            } else {
                $line | Out-ParsedText -ShowLineNumbers:$ShowLineNumbers
            }
        }
    }

    end {
        if ($GroupBySeverity) {
            foreach ($severity in @('ERROR', 'WARN', 'INFO', 'DEBUG', 'OTHER')) {
                if ($logEntries[$severity].Count -gt 0) {
                    Write-RGB "`n=== $severity (" -FC "Cyan"
                    Write-RGB $logEntries[$severity].Count -FC "Yellow" -Style Bold
                    Write-RGB ") ===" -FC "Cyan" -newline

                    $logEntries[$severity] | Out-ParsedText
                }
            }
        }
    }
}
#endregion

#region Интерактивный парсер
function Start-InteractiveParser {
    <#
    .SYNOPSIS
        Запускает интерактивный режим парсера с живым предпросмотром
    #>
    param(
        [string]$InitialPath
    )

    Clear-Host
    Write-GradientHeader -Title "INTERACTIVE PARSER" -StartColor "#FF00FF" -EndColor "#00FFFF"

    $running = $true
    $currentPath = $InitialPath
    $currentTheme = "Default"
    $showLineNumbers = $true

    while ($running) {
        Write-RGB "`nКоманды: " -FC "Yellow" -Style Bold
        Write-RGB "[O]" -FC "Cyan" -Style Bold
        Write-RGB "pen file, " -FC "Gray"
        Write-RGB "[T]" -FC "Cyan" -Style Bold
        Write-RGB "heme, " -FC "Gray"
        Write-RGB "[L]" -FC "Cyan" -Style Bold
        Write-RGB "ine numbers, " -FC "Gray"
        Write-RGB "[R]" -FC "Cyan" -Style Bold
        Write-RGB "efresh, " -FC "Gray"
        Write-RGB "[C]" -FC "Cyan" -Style Bold
        Write-RGB "lear, " -FC "Gray"
        Write-RGB "[Q]" -FC "Cyan" -Style Bold
        Write-RGB "uit" -FC "Gray" -newline

        if ($currentPath) {
            Write-RGB "Текущий файл: " -FC "Gray"
            Write-RGB $currentPath -FC "Cyan" -newline
        }

        Write-RGB "`nВыбор: " -FC "White"
        $choice = Read-Host

        switch ($choice.ToUpper()) {
            'O' {
                Write-RGB "Путь к файлу: " -FC "Cyan"
                $path = Read-Host
                if (Test-Path $path) {
                    $currentPath = $path
                    Clear-Host
                    Out-ParsedFile -Path $currentPath -Theme $currentTheme -ShowLineNumbers:$showLineNumbers -ShowFileInfo
                } else {
                    Write-Status -Error "Файл не найден"
                }
            }

            'T' {
                Write-RGB "Выберите тему (Default/Dracula/Nord/OneDark/Material): " -FC "Cyan"
                $theme = Read-Host
                if ($theme -in @('Default', 'Dracula', 'Nord', 'OneDark', 'Material')) {
                    $currentTheme = $theme
                    if ($currentPath) {
                        Clear-Host
                        Out-ParsedFile -Path $currentPath -Theme $currentTheme -ShowLineNumbers:$showLineNumbers
                    }
                }
            }

            'L' {
                $showLineNumbers = -not $showLineNumbers
                Write-Status -Info "Номера строк: $(if ($showLineNumbers) { 'Включены' } else { 'Выключены' })"
                if ($currentPath) {
                    Clear-Host
                    Out-ParsedFile -Path $currentPath -Theme $currentTheme -ShowLineNumbers:$showLineNumbers
                }
            }

            'R' {
                if ($currentPath) {
                    Clear-Host
                    Out-ParsedFile -Path $currentPath -Theme $currentTheme -ShowLineNumbers:$showLineNumbers
                }
            }

            'C' {
                Clear-Host
                Write-GradientHeader -Title "INTERACTIVE PARSER" -StartColor "#FF00FF" -EndColor "#00FFFF"
            }

            'Q' {
                $running = $false
            }
        }
    }

    Write-Status -Info "Интерактивный парсер завершен"
}
#endregion

#region Экспорт парсированного контента
function Export-ParsedContent {
    <#
    .SYNOPSIS
        Экспортирует парсированный контент в различные форматы
    #>
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$Content,

        [Parameter(Mandatory)]
        [ValidateSet('HTML', 'RTF', 'Markdown', 'ANSI')]
        [string]$Format,

        [string]$OutputPath = "$env:TEMP\parsed_$(Get-Date -Format 'yyyyMMdd_HHmmss').$($Format.ToLower())",

        [string]$Title = "Parsed Content",

        [switch]$OpenAfterExport
    )

    begin {
        $allContent = @()
    }

    process {
        $allContent += $Content
    }

    end {
        $segments = $allContent | Out-ParsedText -PassThru

        switch ($Format) {
            'HTML' {
                $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>$Title</title>
    <style>
        body { 
            background: #1e1e1e; 
            color: #d4d4d4; 
            font-family: 'Consolas', 'Courier New', monospace;
            padding: 20px;
            line-height: 1.6;
        }
        pre { 
            background: #2d2d2d; 
            padding: 15px; 
            border-radius: 5px;
            overflow-x: auto;
        }
        .error { color: #f48771; font-weight: bold; }
        .success { color: #89d185; font-weight: bold; }
        .warning { color: #e9c062; font-weight: bold; }
        .info { color: #6ab7ff; }
        .code { color: #c586c0; }
        .string { color: #ce9178; }
        .number { color: #b5cea8; }
        .comment { color: #6a9955; font-style: italic; }
    </style>
</head>
<body>
    <h1>$Title</h1>
    <pre>
"@

                foreach ($segment in $segments) {
                    $class = switch ($segment.Category) {
                        'Errors' { 'error' }
                        'Success' { 'success' }
                        'Warnings' { 'warning' }
                        'Info' { 'info' }
                        'Code' { 'code' }
                        'Strings' { 'string' }
                        'Numbers' { 'number' }
                        'Comments' { 'comment' }
                        default { '' }
                    }

                    $text = [System.Web.HttpUtility]::HtmlEncode($segment.Text)
                    if ($class) {
                        $html += "<span class='$class'>$text</span>"
                    } else {
                        $html += $text
                    }
                }

                $html += @"
    </pre>
</body>
</html>
"@

                $html | Out-File -FilePath $OutputPath -Encoding UTF8
            }

            'ANSI' {
                # Сохраняем с ANSI цветами
                $ansiContent = ""
                foreach ($segment in $segments) {
                    $color = Get-RGBColor $segment.Style.FC
                    $ansiContent += $color + $segment.Text + $PSStyle.Reset
                }
                $ansiContent | Out-File -FilePath $OutputPath -Encoding UTF8
            }

            # Другие форматы...
        }

        Write-Status -Success "Экспортировано в: $OutputPath"

        if ($OpenAfterExport) {
            Invoke-Item $OutputPath
        }
    }
}
#endregion

# Финальная демонстрация всех возможностей
function Show-UltimateParserDemo {
    Clear-Host

    Write-GradientHeader -Title "ULTIMATE PARSER DEMO" -StartColor "#FF1744" -EndColor "#F50057"

    Write-RGB "`n🧠 Интеллектуальные возможности парсера:" -FC "Cyan" -Style Bold -newline

    # Демо 1: Автоопределение типа
    Write-RGB "`n1️⃣ Автоматическое определение типа контента:" -FC "Yellow" -newline

    $samples = @{
        "PowerShell" = '$users = Get-ADUser -Filter * | Where-Object {$_.Enabled -eq $true}'
        "JSON" = '{"name": "Parser", "version": "3.0", "features": ["AI", "Colors"]}'
        "Log" = '2024-01-15 ERROR: Connection failed to server'
        "Markdown" = '# Header `code` **bold** [link](url)'
    }

    foreach ($sample in $samples.GetEnumerator()) {
        $detected = Get-ContentType -Content $sample.Value
        Write-RGB "  Sample: " -FC "Gray"
        Write-RGB $sample.Value.Substring(0, [Math]::Min(50, $sample.Value.Length)) + "..." -FC "White" -newline
        Write-RGB "  Detected: " -FC "Gray"
        Write-RGB $detected -FC "LimeGreen" -Style Bold -newline
        Write-RGB "" -newline
    }

    Write-RGB "Нажмите Enter для продолжения..." -FC "DarkGray"
    Read-Host

    # Демо 2: Живой парсинг
    Write-RGB "`n2️⃣ Живой парсинг с подсветкой:" -FC "Yellow" -newline

    $liveDemo = @'
# PowerShell Security Scanner
function Test-SecurityCompliance {
    param(
        [string]$ComputerName = "localhost",
        [int]$Port = 443
    )
    
    Write-Host "🔍 Scanning $ComputerName..." -ForegroundColor Cyan
    
    try {
        $connection = Test-NetConnection -ComputerName $ComputerName -Port $Port
        if ($connection.TcpTestSucceeded) {
            Write-Host "✅ SUCCESS: Port $Port is open" -ForegroundColor Green
            return @{
                Status = "PASSED"
                Host = $ComputerName
                Port = $Port
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        } else {
            Write-Host "❌ ERROR: Connection failed!" -ForegroundColor Red
            throw "Connection to $ComputerName:$Port failed"
        }
    } catch {
        Write-Warning "⚠️ WARNING: $($_.Exception.Message)"
        return $null
    }
}

# TODO: Add more security checks
$results = Test-SecurityCompliance -ComputerName "192.168.1.100"
$results | ConvertTo-Json
'@

    $liveDemo -split "`n" | Out-ParsedPowerShell -ShowLineNumbers

    Write-RGB "`n✨ Все функции парсера готовы к использованию!" -FC "LimeGreen" -Style Bold -newline
}

# Алиасы
Set-Alias -Name pfile -Value Out-ParsedFile -Force
Set-Alias -Name iparse -Value Start-InteractiveParser -Force
Set-Alias -Name pexport -Value Export-ParsedContent -Force

Write-RGB "`n🚀 Ultimate Parser Features загружены!" -FC "GoldRGB" -Style Bold -newline
Write-RGB "Новые команды:" -FC "Cyan" -newline
Write-RGB "  • " -FC "DarkGray"
Write-RGB "Out-ParsedFile (pfile)" -FC "Yellow"
Write-RGB " - парсинг файлов" -FC "Gray" -newline
Write-RGB "  • " -FC "DarkGray"
Write-RGB "Start-InteractiveParser (iparse)" -FC "Yellow"
Write-RGB " - интерактивный режим" -FC "Gray" -newline
Write-RGB "  • " -FC "DarkGray"
Write-RGB "Show-UltimateParserDemo" -FC "Yellow"
Write-RGB " - полная демонстрация" -FC "Gray" -newline