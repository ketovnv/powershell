# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    🔧 FINAL PARSER FIXES & SUPER FEATURES                   ║
# ║                   Исправления и супер-возможности парсера                   ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

#region Исправление
# Format-String для Rainbow
function Format-String {
    <#
    .SYNOPSIS
        Форматирует строку, убирая ANSI последовательности для корректной работы Rainbow
    #>
    param(
        [Parameter(ValueFromPipeline)]
        [string]$InputString
    )

    process {
        # Убираем ANSI escape последовательности
        $InputString -replace '\x1b\[[0-9;]*m', ''
    }
}
#endregion

#region Супер-парсер для логов с AI-подобным анализом
function Out-SmartLog {
    <#
    .SYNOPSIS
        Интеллектуальный парсер логов с анализом паттернов и аномалий

    .DESCRIPTION
        Анализирует логи, выявляет паттерны, аномалии, тренды и предоставляет
        рекомендации по устранению проблем

    .EXAMPLE
        Get-Content error.log | Out-SmartLog -AnalyzePatterns -ShowRecommendations
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string[]]$LogContent,

        [switch]$AnalyzePatterns,
        [switch]$ShowRecommendations,
        [switch]$DetectAnomalies,
        [switch]$GroupByTime,
        [switch]$ShowStatistics,
        [switch]$ExportReport,
        [string]$ReportPath = "$env:TEMP\smart_log_analysis_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    )

    begin {
        $allLogs = @()
        $patterns = @{
            Errors = @()
            Warnings = @()
            Info = @()
            Anomalies = @()
            TimePatterns = @{}
        }

        $recommendations = @{
            HighErrorRate = "Высокая частота ошибок. Проверьте стабильность системы."
            RepeatingError = "Повторяющаяся ошибка. Требуется постоянное решение."
            MemoryIssues = "Обнаружены проблемы с памятью. Увеличьте RAM или оптимизируйте приложение."
            NetworkErrors = "Сетевые ошибки. Проверьте подключение и настройки firewall."
            PermissionDenied = "Ошибки доступа. Проверьте права пользователя и ACL."
            TimeoutErrors = "Таймауты. Оптимизируйте производительность или увеличьте лимиты."
        }
    }

    process {
        $allLogs += $LogContent
    }

    end {
        Write-GradientHeader -Title "SMART LOG ANALYZER" -StartColor "#FF6B6B" -EndColor "#4ECDC4"

        # Парсим все логи
        $parsedLogs = @()
        foreach ($log in $allLogs) {
            $parsed = Parse-LogEntry -Entry $log
            if ($parsed) {
                $parsedLogs += $parsed

                # Категоризируем
                switch ($parsed.Severity) {
                    { $_ -in 'ERROR', 'FATAL', 'CRITICAL' } { $patterns.Errors += $parsed }
                    { $_ -in 'WARN', 'WARNING' } { $patterns.Warnings += $parsed }
                    { $_ -in 'INFO', 'DEBUG', 'TRACE' } { $patterns.Info += $parsed }
                }
            }
        }

        # Показываем базовую статистику
        if ($ShowStatistics -or $AnalyzePatterns) {
            wrgb "`n📊 СТАТИСТИКА ЛОГОВ:" -FC "Cyan" -Style Bold -newline

            $stats = @{
                "Всего записей" = $parsedLogs.Count
                "Ошибок" = $patterns.Errors.Count
                "Предупреждений" = $patterns.Warnings.Count
                "Информационных" = $patterns.Info.Count
            }

            foreach ($stat in $stats.GetEnumerator()) {
                wrgb "  $($stat.Key): " -FC "Gray"
                $color = switch ($stat.Key) {
                    "Ошибок" { if ($stat.Value -gt 10) { "Red" } else { "Yellow" } }
                    "Предупреждений" { "Material_Orange" }
                    default { "White" }
                }
                wrgb $stat.Value -FC $color -Style Bold -newline
            }

            # График распределения
            if ($parsedLogs.Count -gt 0) {
                wrgb "`n📈 Распределение по типам:" -FC "Cyan" -newline

                $maxCount = ($stats.Values | Measure-Object -Maximum).Maximum
                foreach ($type in @("Ошибок", "Предупреждений", "Информационных")) {
                    $count = $stats[$type]
                    $percentage = if ($parsedLogs.Count -gt 0) { [math]::Round(($count / $parsedLogs.Count) * 100) } else { 0 }
                    $barLength = if ($maxCount -gt 0) { [math]::Round(($count / $maxCount) * 30) } else { 0 }

                    wrgb ("  " + $type.PadRight(15)) -FC "Gray"

                    # Прогресс-бар
                    for ($i = 0; $i -lt $barLength; $i++) {
                        $color = Get-ProgressGradientColor -Percent $percentage
                        wrgb "█" -FC $color
                    }

                    wrgb " $percentage%" -FC "White" -newline
                }
            }
        }

        # Анализ паттернов
        if ($AnalyzePatterns) {
            wrgb "`n🔍 АНАЛИЗ ПАТТЕРНОВ:" -FC "Cyan" -Style Bold -newline

            # Находим повторяющиеся ошибки
            $errorGroups = $patterns.Errors | Group-Object Message | Where-Object Count -gt 1 | Sort-Object Count -Descending

            if ($errorGroups) {
                wrgb "`n  Повторяющиеся ошибки:" -FC "Yellow" -newline
                foreach ($group in $errorGroups | Select-Object -First 5) {
                    wrgb "    • " -FC "DarkGray"
                    wrgb "$($group.Count)x" -FC "Red" -Style Bold
                    wrgb " - " -FC "DarkGray"
                    wrgb ($group.Name.Substring(0, [Math]::Min(60, $group.Name.Length)) + "...") -FC "White" -newline
                }
            }

            # Временные паттерны
            if ($GroupByTime) {
                $timeGroups = $parsedLogs | Where-Object Timestamp | Group-Object { $_.Timestamp.Hour } | Sort-Object Name

                wrgb "`n  📅 Распределение по времени (по часам):" -FC "Yellow" -newline
                foreach ($hour in $timeGroups) {
                    wrgb ("    " + $hour.Name.PadLeft(2, '0') + ":00 ") -FC "Gray"

                    # Мини график
                    $barCount = [Math]::Min(20, $hour.Count)
                    for ($i = 0; $i -lt $barCount; $i++) {
                        wrgb "▪" -FC "Material_Cyan"
                    }
                    wrgb " $($hour.Count)" -FC "White" -newline
                }
            }
        }

        # Обнаружение аномалий
        if ($DetectAnomalies) {
            wrgb "`n⚡ ОБНАРУЖЕНИЕ АНОМАЛИЙ:" -FC "Cyan" -Style Bold -newline

            $anomalies = @()

            # Внезапный всплеск ошибок
            if ($patterns.Errors.Count -gt 0) {
                $errorsByMinute = $patterns.Errors | Where-Object Timestamp |
                        Group-Object { $_.Timestamp.ToString("yyyy-MM-dd HH:mm") } |
                        Sort-Object Name

                $avgErrors = ($errorsByMinute | Measure-Object Count -Average).Average
                $threshold = $avgErrors * 3

                $spikes = $errorsByMinute | Where-Object { $_.Count -gt $threshold }
                if ($spikes) {
                    foreach ($spike in $spikes) {
                        $anomalies += "🚨 Всплеск ошибок в $($spike.Name): $($spike.Count) ошибок (норма: $([math]::Round($avgErrors)))"
                    }
                }
            }

            # Необычные сообщения
            $unusualPatterns = @(
                'out of memory', 'stack overflow', 'access violation',
                'critical error', 'system failure', 'corruption'
            )

            foreach ($pattern in $unusualPatterns) {
                $found = $allLogs | Where-Object { $_ -match $pattern }
                if ($found) {
                    $anomalies += "⚠️ Обнаружен критический паттерн: '$pattern' ($($found.Count) раз)"
                }
            }

            if ($anomalies) {
                foreach ($anomaly in $anomalies) {
                    wrgb "  $anomaly" -FC "Material_Red" -newline
                }
            } else {
                wrgb "  ✅ Аномалий не обнаружено" -FC "LimeGreen" -newline
            }
        }

        # Рекомендации
        if ($ShowRecommendations) {
            wrgb "`n💡 РЕКОМЕНДАЦИИ:" -FC "Cyan" -Style Bold -newline

            $suggestedActions = @()

            # Анализируем и даем рекомендации
            if ($patterns.Errors.Count -gt $parsedLogs.Count * 0.3) {
                $suggestedActions += $recommendations.HighErrorRate
            }

            $memoryErrors = $patterns.Errors | Where-Object { $_.Message -match 'memory|ram|heap' }
            if ($memoryErrors) {
                $suggestedActions += $recommendations.MemoryIssues
            }

            $networkErrors = $patterns.Errors | Where-Object { $_.Message -match 'network|connection|timeout' }
            if ($networkErrors) {
                $suggestedActions += $recommendations.NetworkErrors
            }

            $permissionErrors = $patterns.Errors | Where-Object { $_.Message -match 'access denied|permission|unauthorized' }
            if ($permissionErrors) {
                $suggestedActions += $recommendations.PermissionDenied
            }

            if ($suggestedActions) {
                foreach ($action in $suggestedActions | Select-Object -Unique) {
                    wrgb "  • " -FC "DarkGray"
                    wrgb $action -FC "Material_Green" -newline
                }
            } else {
                wrgb "  ✅ Система работает в пределах нормы" -FC "LimeGreen" -newline
            }
        }

        # Экспорт отчета
        if ($ExportReport) {
            Export-LogAnalysisReport -ParsedLogs $parsedLogs -Patterns $patterns -Path $ReportPath
            wrgb "`n📄 Отчет экспортирован: " -FC "Gray"
            wrgb $ReportPath -FC "Cyan" -newline
        }

        # Показываем сами логи с подсветкой
        wrgb "`n📋 ЛОГИ С ПОДСВЕТКОЙ:" -FC "Cyan" -Style Bold -newline
        $allLogs | Out-ParsedText -ShowLineNumbers
    }
}

function Parse-LogEntry {
    param([string]$Entry)

    $result = @{
        Original = $Entry
        Timestamp = $null
        Severity = 'UNKNOWN'
        Message = $Entry
        Component = ''
        Thread = ''
    }

    # Пытаемся извлечь timestamp
    if ($Entry -match '(\d{4}[-/]\d{2}[-/]\d{2}\s+\d{2}:\d{2}:\d{2})') {
        $result.Timestamp = [datetime]::ParseExact($matches[1], 'yyyy-MM-dd HH:mm:ss', $null)
    }

    # Извлекаем уровень severity
    if ($Entry -match '\[(ERROR|WARN|WARNING|INFO|DEBUG|TRACE|FATAL|CRITICAL)\]') {
        $result.Severity = $matches[1]
    } elseif ($Entry -match '\b(ERROR|FAILED|EXCEPTION)\b') {
        $result.Severity = 'ERROR'
    } elseif ($Entry -match '\b(WARNING|WARN)\b') {
        $result.Severity = 'WARN'
    }

    # Извлекаем компонент
    if ($Entry -match '\[([A-Za-z0-9\._]+)\]' -and $matches[1] -notmatch '^(ERROR|WARN|INFO|DEBUG)$') {
        $result.Component = $matches[1]
    }

    # Извлекаем сообщение
    if ($Entry -match '(ERROR|WARN|INFO|DEBUG|TRACE)[\]:\s]+(.+)$') {
        $result.Message = $matches[2]
    }

    return $result
}

function Export-LogAnalysisReport {
    param($ParsedLogs, $Patterns, $Path)

    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Log Analysis Report - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #1e1e1e;
            color: #e0e0e0;
            padding: 20px;
        }
        .header {
            background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: 2em;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .section {
            background: #2d2d2d;
            border-radius: 8px;
            padding: 15px;
            margin: 10px 0;
            border: 1px solid #444;
        }
        .stat {
            display: inline-block;
            margin: 10px;
            padding: 10px 20px;
            background: #3a3a3a;
            border-radius: 5px;
        }
        .error { color: #ff6b6b; }
        .warning { color: #ffd93d; }
        .info { color: #6bcf7f; }
        .chart {
            margin: 20px 0;
            height: 200px;
            position: relative;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            border: 1px solid #444;
            padding: 8px;
            text-align: left;
        }
        th {
            background: #3a3a3a;
            font-weight: bold;
        }
        tr:nth-child(even) {
            background: #2a2a2a;
        }
    </style>
</head>
<body>
    <h1 class="header">Log Analysis Report</h1>

    <div class="section">
        <h2>📊 Summary Statistics</h2>
        <div class="stat">Total Entries: <strong>$($ParsedLogs.Count)</strong></div>
        <div class="stat error">Errors: <strong>$($Patterns.Errors.Count)</strong></div>
        <div class="stat warning">Warnings: <strong>$($Patterns.Warnings.Count)</strong></div>
        <div class="stat info">Info: <strong>$($Patterns.Info.Count)</strong></div>
    </div>

    <div class="section">
        <h2>📈 Error Distribution</h2>
        <canvas id="errorChart" class="chart"></canvas>
    </div>

    <div class="section">
        <h2>🔍 Top Errors</h2>
        <table>
            <tr>
                <th>Count</th>
                <th>Error Message</th>
                <th>First Occurrence</th>
            </tr>
"@

    $topErrors = $Patterns.Errors | Group-Object Message | Sort-Object Count -Descending | Select-Object -First 10
    foreach ($error in $topErrors) {
        $firstOccurrence = ($error.Group | Sort-Object Timestamp | Select-Object -First 1).Timestamp
        $html += @"
            <tr>
                <td class="error">$($error.Count)</td>
                <td>$([System.Web.HttpUtility]::HtmlEncode($error.Name))</td>
                <td>$firstOccurrence</td>
            </tr>
"@
    }

    $html += @"
        </table>
    </div>

    <div class="section">
        <h2>💡 Recommendations</h2>
        <ul>
"@

    # Добавляем рекомендации на основе анализа
    if ($Patterns.Errors.Count -gt $ParsedLogs.Count * 0.3) {
        $html += "<li>High error rate detected. Review system stability.</li>"
    }

    if ($Patterns.Errors | Where-Object { $_.Message -match 'memory' }) {
        $html += "<li>Memory-related errors found. Consider increasing RAM or optimizing applications.</li>"
    }

    $html += @"
        </ul>
    </div>

    <script>
        // Простая визуализация для графика
        const canvas = document.getElementById('errorChart');
        const ctx = canvas.getContext('2d');
        canvas.width = canvas.offsetWidth;
        canvas.height = 200;

        // Данные для графика
        const data = [
            { label: 'Errors', count: $($Patterns.Errors.Count), color: '#ff6b6b' },
            { label: 'Warnings', count: $($Patterns.Warnings.Count), color: '#ffd93d' },
            { label: 'Info', count: $($Patterns.Info.Count), color: '#6bcf7f' }
        ];

        const total = data.reduce((sum, item) => sum + item.count, 0);
        let currentAngle = 0;

        // Рисуем круговую диаграмму
        const centerX = canvas.width / 2;
        const centerY = canvas.height / 2;
        const radius = 80;

        data.forEach(item => {
            const sliceAngle = (item.count / total) * 2 * Math.PI;

            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, currentAngle, currentAngle + sliceAngle);
            ctx.lineTo(centerX, centerY);
            ctx.fillStyle = item.color;
            ctx.fill();

            // Добавляем подпись
            const labelX = centerX + Math.cos(currentAngle + sliceAngle / 2) * (radius + 20);
            const labelY = centerY + Math.sin(currentAngle + sliceAngle / 2) * (radius + 20);
            ctx.fillStyle = '#fff';
            ctx.font = '12px Arial';
            ctx.textAlign = 'center';
            ctx.fillText(item.label + ' (' + Math.round(item.count / total * 100) + '%)', labelX, labelY);

            currentAngle += sliceAngle;
        });
    </script>
</body>
</html>
"@

    $html | Out-File -FilePath $Path -Encoding UTF8
}
#endregion

#region Супер-функция для парсинга кода с подсветкой синтаксиса
function Out-CodeHighlight {
    <#
    .SYNOPSIS
        Продвинутая подсветка синтаксиса для различных языков программирования

    .DESCRIPTION
        Автоматически определяет язык и применяет соответствующую подсветку
        с поддержкой тем и экспорта
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$Code,

        [ValidateSet('Auto', 'PowerShell', 'Python', 'JavaScript', 'CSharp', 'JSON', 'XML', 'SQL', 'Bash')]
        [string]$Language = 'Auto',

        [ValidateSet('Dracula', 'OneDark', 'Monokai', 'VSCode', 'GitHub')]
        [string]$Theme = 'Dracula',

        [switch]$ShowLineNumbers,
        [switch]$ShowLanguage,
        [switch]$HighlightCurrentLine,
        [int]$CurrentLine = 0,

        [switch]$CopyToClipboard
    )

    begin {
        $allCode = @()

        # Темы подсветки
        $themes = @{
            Dracula = @{
                Keyword = "Material_Pink"
                String = "Material_Yellow"
                Comment = "Material_Comment"
                Function = "Material_Green"
                Variable = "Material_Purple"
                Number = "Material_Orange"
                Operator = "Material_Cyan"
                Type = "Material_Purple"
                Default = "Material_Foreground"
            }
            OneDark = @{
                Keyword = "OneDark_Purple"
                String = "OneDark_Green"
                Comment = "DarkGray"
                Function = "OneDark_Blue"
                Variable = "OneDark_Red"
                Number = "OneDark_Yellow"
                Operator = "OneDark_Cyan"
                Type = "OneDark_Yellow"
                Default = "OneDark_White"
            }
            # Другие темы...
        }

        $currentTheme = $themes[$Theme]
    }

    process {
        $allCode += $Code
    }

    end {
        # Определяем язык если Auto
        if ($Language -eq 'Auto') {
            $Language = Detect-CodeLanguage -Code ($allCode -join "`n")
        }

        if ($ShowLanguage) {
            wrgb "Language: " -FC "Gray"
            wrgb $Language -FC "Cyan" -Style Bold -newline
            Write-GradientLine -Length 50
        }

        # Получаем правила для языка
        $rules = Get-LanguageRules -Language $Language -Theme $currentTheme

        # Подсвечиваем код
        $lineNum = 0
        foreach ($line in $allCode) {
            $lineNum++

            if ($ShowLineNumbers) {
                $numColor = if ($lineNum -eq $CurrentLine -and $HighlightCurrentLine) { "Yellow" } else { "DarkGray" }
                wrgb ("{0,4} " -f $lineNum) -FC $numColor
                wrgb "│ " -FC "DarkGray"
            }

            # Подсветка текущей строки
            if ($lineNum -eq $CurrentLine -and $HighlightCurrentLine) {
                wrgb "→ " -FC "Yellow" -Style Bold
            } elseif ($ShowLineNumbers) {
                wrgb "  "
            }

            # Применяем правила подсветки
            $segments = Apply-SyntaxHighlighting -Line $line -Rules $rules

            foreach ($segment in $segments) {
                wrgb $segment.Text -FC $segment.Color -Style $segment.Style
            }

            Write-Host ""
        }

        # Копируем в буфер обмена если нужно
        if ($CopyToClipboard) {
            $allCode -join "`n" | Set-Clipboard
            Write-Status -Success "Код скопирован в буфер обмена"
        }
    }
}

function Detect-CodeLanguage {
    param([string]$Code)

    # Простые эвристики для определения языка
    $signatures = @{
        PowerShell = @('function ', 'param(', '$_', 'Get-', 'Set-', '-eq', '-ne', '[CmdletBinding')
        Python = @('def ', 'import ', 'from ', 'class ', 'if __name__', '    ', 'print(')
        JavaScript = @('function', 'const ', 'let ', 'var ', '=>', 'console.log', 'require(')
        CSharp = @('using ', 'namespace ', 'public class', 'private ', 'static void', 'int ', 'string ')
        JSON = @('^\s*{', '".*":', '^\s*\[')
        SQL = @('SELECT ', 'FROM ', 'WHERE ', 'INSERT INTO', 'UPDATE ', 'CREATE TABLE')
    }

    $scores = @{}

    foreach ($lang in $signatures.Keys) {
        $score = 0
        foreach ($sig in $signatures[$lang]) {
            if ($Code -match $sig) {
                $score += 10
            }
        }
        $scores[$lang] = $score
    }

    $detected = ($scores.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1).Key
    return $detected ?? "PowerShell"
}

function Get-LanguageRules {
    param($Language, $Theme)

    # Здесь определяем правила подсветки для каждого языка
    $rules = switch ($Language) {
        'PowerShell' {
            @{
                Keywords = @{
                    Pattern = '\b(function|param|if|else|foreach|for|while|switch|return|break|continue|try|catch|finally|class|enum)\b'
                    Color = $Theme.Keyword
                    Style = @('Bold')
                }
                Cmdlets = @{
                    Pattern = '\b(Get|Set|New|Remove|Add|Clear|Start|Stop|Out|Write|Read)-\w+'
                    Color = $Theme.Function
                }
                Variables = @{
                    Pattern = '\$\w+'
                    Color = $Theme.Variable
                }
                Strings = @{
                    Pattern = '"[^"]*"|''[^'']*'''
                    Color = $Theme.String
                }
                Comments = @{
                    Pattern = '#.*$'
                    Color = $Theme.Comment
                    Style = @('Italic')
                }
                Numbers = @{
                    Pattern = '\b\d+\.?\d*\b'
                    Color = $Theme.Number
                }
            }
        }
        # Другие языки...
        default {
            @{
                Default = @{
                    Pattern = '.*'
                    Color = $Theme.Default
                }
            }
        }
    }

    return $rules
}

function Apply-SyntaxHighlighting {
    param($Line, $Rules)

    $segments = @()
    $processed = New-Object bool[] $Line.Length

    # Применяем правила в порядке приоритета
    foreach ($ruleName in $Rules.Keys) {
        $rule = $Rules[$ruleName]
        $matches = [regex]::Matches($Line, $rule.Pattern)

        foreach ($match in $matches) {
            $canApply = $true

            # Проверяем, не обработан ли уже этот участок
            for ($i = $match.Index; $i -lt ($match.Index + $match.Length); $i++) {
                if ($processed[$i]) {
                    $canApply = $false
                    break
                }
            }

            if ($canApply) {
                $segments += @{
                    Start = $match.Index
                    Text = $match.Value
                    Color = $rule.Color
                    Style = $rule.Style ?? @()
                }

                # Отмечаем как обработанное
                for ($i = $match.Index; $i -lt ($match.Index + $match.Length); $i++) {
                    $processed[$i] = $true
                }
            }
        }
    }

    # Добавляем необработанные участки
    $finalSegments = @()
    $lastEnd = 0

    foreach ($segment in ($segments | Sort-Object Start)) {
        if ($segment.Start -gt $lastEnd) {
            $finalSegments += @{
                Text = $Line.Substring($lastEnd, $segment.Start - $lastEnd)
                Color = $Rules.Default.Color ?? "White"
                Style = @()
            }
        }

        $finalSegments += $segment
        $lastEnd = $segment.Start + $segment.Text.Length
    }

    if ($lastEnd -lt $Line.Length) {
        $finalSegments += @{
            Text = $Line.Substring($lastEnd)
            Color = $Rules.Default.Color ?? "White"
            Style = @()
        }
    }

    return $finalSegments
}
#endregion

#region Интеграция с Git для парсинга diff
function Out-GitDiff {
    <#
    .SYNOPSIS
        Красивый вывод git diff с подсветкой
    #>
    param(
        [string]$Path = ".",
        [switch]$Staged,
        [switch]$ShowStats
    )

    $gitArgs = @('diff', '--no-pager')
    if ($Staged) {
        $gitArgs += '--staged'
    }

    $diff = & git @gitArgs 2>$null

    if (-not $diff) {
        Write-Status -Info "Нет изменений для отображения"
        return
    }

    Write-GradientHeader -Title "GIT DIFF" -StartColor "#F05033" -EndColor "#F79500"

    if ($ShowStats) {
        $stats = & git diff --stat
        wrgb "`n📊 Статистика изменений:" -FC "Cyan" -Style Bold -newline
        $stats | ForEach-Object {
            if ($_ -match '(\d+) files? changed') {
                wrgb $_ -FC "Yellow" -newline
            } else {
                wrgb $_ -FC "Gray" -newline
            }
        }
        wrgb "" -newline
    }

    foreach ($line in $diff) {
        switch -Regex ($line) {
            '^diff --git' {
                wrgb "`n$line" -FC "Material_Purple" -Style Bold -newline
            }
            '^index' {
                wrgb $line -FC "DarkCyan" -newline
            }
            '^---' {
                wrgb $line -FC "Red" -Style Bold -newline
            }
            '^\+\+\+' {
                wrgb $line -FC "Green" -Style Bold -newline
            }
            '^@@' {
                wrgb $line -FC "Cyan" -newline
            }
            '^\+(?!\+\+)' {
                wrgb $line -FC "LimeGreen" -BC "#0D2818" -newline
            }
            '^-(?!--)' {
                wrgb $line -FC "Red" -BC "#2D0D0D" -newline
            }
            default {
                wrgb $line -FC "Gray" -newline
            }
        }
    }
}
#endregion

#region Финальная демонстрация всех возможностей
function Show-UltimateParserShowcase {
    Clear-Host

    # Супер заголовок
    $title = "🚀 ULTIMATE PARSER SHOWCASE 🚀"
    Write-Rainbow -Text $title -Mode Gradient -Style Neon -Animated -Speed 30

    wrgb "`nДобро пожаловать в финальную демонстрацию всех возможностей парсера!" -FC "GoldRGB" -Style Bold -newline

    # Меню с градиентом
    $showcases = @(
        @{ Name = "🧠 Smart Log Analyzer"; Desc = "AI-подобный анализ логов" }
        @{ Name = "💻 Code Highlighter"; Desc = "Подсветка синтаксиса для всех языков" }
        @{ Name = "📊 Advanced Progress Bars"; Desc = "Все виды прогресс-баров" }
        @{ Name = "🌈 Rainbow Effects Gallery"; Desc = "Галерея радужных эффектов" }
        @{ Name = "📝 File Parsing Magic"; Desc = "Магия парсинга файлов" }
        @{ Name = "🔄 Git Integration"; Desc = "Красивый git diff" }
        @{ Name = "🎯 Live Parsing Demo"; Desc = "Живая демонстрация парсинга" }
        @{ Name = "🎪 MEGA COMBO"; Desc = "Все вместе!" }
    )

    do {
        wrgb "`n📋 Выберите демонстрацию:" -FC "Cyan" -Style Bold -newline

        for ($i = 0; $i -lt $showcases.Count; $i++) {
            $color = Get-MenuGradientColor -Index $i -Total $showcases.Count -Style Ocean
            wrgb ("  [{0}] " -f ($i + 1)) -FC "White"
            wrgb $showcases[$i].Name -FC $color -Style Bold
            wrgb " - " -FC "DarkGray"
            wrgb $showcases[$i].Desc -FC "Gray" -newline
        }

        wrgb "  [Q] Выход" -FC "Red" -newline

        wrgb "`nВаш выбор: " -FC "Yellow"
        $choice = Read-Host

        switch ($choice) {
            "1" {
                # Smart Log Analyzer
                Clear-Host
                $demoLog = @"
2024-01-15 10:00:00 [INFO] Application starting...
2024-01-15 10:00:01 [INFO] Loading configuration from config.json
2024-01-15 10:00:02 [SUCCESS] ✅ Database connection established
2024-01-15 10:00:03 [INFO] Starting web server on port 8080
2024-01-15 10:00:15 [WARNING] ⚠️ Low memory: 412MB available
2024-01-15 10:00:20 [ERROR] ❌ Failed to bind to port 8080: Address already in use
2024-01-15 10:00:21 [ERROR] ❌ Failed to start web server
2024-01-15 10:00:22 [INFO] Trying alternate port 8081...
2024-01-15 10:00:23 [SUCCESS] ✅ Web server started on port 8081
2024-01-15 10:00:30 [ERROR] ❌ Out of memory exception in DataProcessor
2024-01-15 10:00:31 [CRITICAL] 🚨 System failure: Unable to allocate memory
2024-01-15 10:00:32 [INFO] Initiating emergency shutdown...
"@

                $demoLog -split "`n" | Out-SmartLog -AnalyzePatterns -ShowRecommendations -DetectAnomalies -ShowStatistics

                wrgb "`nНажмите Enter..." -FC "DarkGray"
                Read-Host
            }

            "2" {
                # Code Highlighter
                Clear-Host
                Write-GradientHeader -Title "CODE SYNTAX HIGHLIGHTING"

                $demoCode = @'
# Advanced PowerShell Function
function Invoke-AdvancedOperation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [int]$Timeout = 30,

        [switch]$Async
    )

    begin {
        Write-Verbose "Starting operation for: $Name"
        $startTime = Get-Date
    }

    process {
        try {
            # Complex logic here
            $result = @{
                Name = $Name
                Status = "Success"
                Duration = (Get-Date) - $startTime
            }

            if ($Async) {
                Start-Job -ScriptBlock {
                    Start-Sleep -Seconds $using:Timeout
                    return "Async operation completed"
                }
            }

            return $result
        }
        catch {
            Write-Error "Operation failed: $_"
            throw
        }
    }
}

# Usage example
$data = Invoke-AdvancedOperation -Name "Test" -Verbose
$data | ConvertTo-Json
'@

                $demoCode -split "`n" | Out-CodeHighlight -Language PowerShell -ShowLineNumbers -ShowLanguage

                wrgb "`nНажмите Enter..." -FC "DarkGray"
                Read-Host
            }

            "3" {
                # Progress Bars
                Clear-Host
                Show-ProgressDemo
                wrgb "`nНажмите Enter..." -FC "DarkGray"
                Read-Host
            }

            "4" {
                # Rainbow Gallery
                Clear-Host
                Write-GradientHeader -Title "RAINBOW EFFECTS GALLERY"

                $texts = @(
                    "Standard Rainbow Effect",
                    "Fire Rainbow Style",
                    "Ocean Wave Rainbow",
                    "Neon Lights Rainbow",
                    "Pastel Dreams Rainbow"
                )

                $styles = @("Rainbow", "Fire", "Ocean", "Neon", "Pastel")

                for ($i = 0; $i -lt $texts.Count; $i++) {
                    wrgb "`n$($styles[$i]):" -FC "Cyan" -newline
                    $texts[$i] | Write-Rainbow -Style $styles[$i] -Bold
                }

                wrgb "`n`nАнимированные эффекты:" -FC "Cyan" -Style Bold -newline
                "✨ Animated Magic ✨" | Write-Rainbow -Animated -Loop -LoopCount 2 -Speed 50

                wrgb "`nВолновой эффект:" -FC "Cyan" -newline
                "~~~~~~~~~~~~ Wave Effect ~~~~~~~~~~~~" | Write-Rainbow -Mode Wave -Style Ocean

                wrgb "`nНажмите Enter..." -FC "DarkGray"
                Read-Host
            }

            "8" {
                # MEGA COMBO
                Clear-Host

                # Анимированный заголовок
                "🎪 MEGA COMBO DEMONSTRATION 🎪" | Write-Rainbow -Mode Gradient -Animated -Style Rainbow

                # Прогресс инициализации
                wrgb "`n⚡ Инициализация системы..." -FC "Cyan" -newline
                Show-AnimatedProgress -Activity "Загрузка модулей" -TotalSteps 20

                # Парсинг кода с подсветкой
                wrgb "`n💻 Анализ кода:" -FC "Yellow" -Style Bold -newline
                @'
function Start-MegaDemo {
    Write-Host "🚀 Starting MEGA demonstration!" -ForegroundColor Cyan
    $data = @{
        Status = "Active"
        Progress = 100
        Results = @("Success", "Complete", "Ready")
    }
    return $data | ConvertTo-Json
}
'@ -split "`n" | Out-CodeHighlight -ShowLineNumbers

                # Smart log с Rainbow заголовком
                "`n=== SYSTEM LOG ===" | Write-Rainbow -Mode Line -Style Fire

                @"
2024-01-15 12:00:00 [INFO] 🚀 MEGA COMBO started
2024-01-15 12:00:01 [SUCCESS] ✅ All systems operational
2024-01-15 12:00:02 [WARNING] ⚠️ High awesomeness detected
2024-01-15 12:00:03 [INFO] 🎨 Rendering rainbow effects...
2024-01-15 12:00:04 [SUCCESS] ✅ Parser fully operational!
"@ -split "`n" | Out-ParsedText

                # Финальное сообщение
                wrgb "`n" -newline
                "🎉 MEGA COMBO COMPLETE! 🎉" | Write-Rainbow -Mode Gradient -Style Neon -Bold

                wrgb "`nНажмите Enter..." -FC "DarkGray"
                Read-Host
            }
        }

    } while ($choice.ToUpper() -ne 'Q')

    # Прощание
    Clear-Host
    "Thank you for exploring the ULTIMATE PARSER!" | Write-Rainbow -Mode Gradient -Animated -Style Rainbow
    wrgb "`n👋 До новых встреч в мире красивого парсинга!" -FC "GoldRGB" -Style Bold -newline
}
#endregion

# Финальная инициализация и информация
wrgb "`n" -newline
Write-GradientHeader -Title "🎯 PARSER SYSTEM FULLY LOADED 🎯" -StartColor "#00FF00" -EndColor "#00FFFF"

wrgb "`n📚 Новые супер-команды:" -FC "Cyan" -Style Bold -newline

$newCommands = @(
    @{ Cmd = "Out-SmartLog"; Desc = "AI-подобный анализ логов с рекомендациями" }
    @{ Cmd = "Out-CodeHighlight"; Desc = "Продвинутая подсветка кода" }
    @{ Cmd = "Out-GitDiff"; Desc = "Красивый git diff" }
    @{ Cmd = "Show-UltimateParserShowcase"; Desc = "Финальная мега-демонстрация" }
)

foreach ($cmd in $newCommands) {
    wrgb "  • " -FC "DarkGray"
    wrgb $cmd.Cmd -FC "Material_Yellow" -Style Bold
    wrgb " - " -FC "DarkGray"
    wrgb $cmd.Desc -FC "White" -newline
}

wrgb "`n🚀 Система готова к любым задачам парсинга!" -FC "LimeGreen" -Style Bold -newline
wrgb "Попробуйте: " -FC "Gray"
wrgb "Show-UltimateParserShowcase" -FC "Material_Pink" -Style @('Bold', 'Underline')
wrgb " для полного погружения!" -FC "Gray" -newline

# Экспорт всех функций
if ($MyInvocation.MyCommand.Path -match '\.psm1$') {
    Export-ModuleMember -Function * -Alias * -Variable *
}