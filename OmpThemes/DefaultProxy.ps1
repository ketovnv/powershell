# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    🎨 OUT-DEFAULT PROXY EXPLAINED                           ║
# ║              Кастомное форматирование вывода PowerShell                    ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

<#
.SYNOPSIS
    Этот скрипт - это PROXY для Out-Default команды.
    Out-Default автоматически вызывается в конце каждой команды для вывода результата.

.DESCRIPTION
    Зачем это нужно:
    1. Кастомизация вывода для разных типов объектов
    2. Добавление цветов и форматирования
    3. Улучшение читаемости вывода
    4. Добавление дополнительной информации

    Как это работает:
    - Перехватывает ВСЕ выводы в консоль
    - Проверяет тип объекта
    - Применяет кастомное форматирование
    - Передает дальше в оригинальный Out-Default
#>

# Давай создадим УЛУЧШЕННУЮ версию с объяснениями

function Out-Default {
    <#
    .SYNOPSIS
        Улучшенный Out-Default с красивым форматированием

    .DESCRIPTION
        Эта функция автоматически вызывается для ЛЮБОГО вывода в PowerShell.
        Мы перехватываем её, чтобы сделать вывод красивее!
    #>
    [CmdletBinding()]
    param(
        [switch]$Transcript,

        [Parameter(ValueFromPipeline=$true)]
        [psobject]$InputObject
    )

    begin {
        # Получаем НАСТОЯЩИЙ Out-Default (обход нашей обертки)
        $realOutDefault = $ExecutionContext.InvokeCommand.GetCommand(
                'Microsoft.PowerShell.Core\Out-Default',
                [System.Management.Automation.CommandTypes]::Cmdlet
        )

        # Создаем steppable pipeline для передачи данных
        $steppablePipeline = { & $realOutDefault @PSBoundParameters }.GetSteppablePipeline()
        $steppablePipeline.Begin($PSCmdlet)

        # Наши настройки форматирования
        $script:FormatConfig = @{
            ColorizeOutput = $true
            ShowIcons = $true
            ShowExtraInfo = $true
        }
    }

    process {
        # ВОТ ГДЕ ПРОИСХОДИТ МАГИЯ!
        # Проверяем тип объекта и применяем кастомное форматирование

        switch ($InputObject) {
            # Файлы и папки
            { $_ -is [System.IO.FileInfo] -or $_ -is [System.IO.DirectoryInfo] } {
                Format-FileSystemItem $_
                $_ = $null  # Предотвращаем стандартный вывод
            }

            # Службы Windows
            { $_ -is [System.ServiceProcess.ServiceController] } {
                Format-ServiceItem $_
                $_ = $null
            }

            # Результаты поиска (Select-String)
            { $_ -is [Microsoft.PowerShell.Commands.MatchInfo] } {
                Format-MatchInfo $_
                $_ = $null
            }

            # Процессы
            { $_ -is [System.Diagnostics.Process] } {
                Format-ProcessItem $_
                $_ = $null
            }

            # Ошибки
            { $_ -is [System.Management.Automation.ErrorRecord] } {
                Format-ErrorRecord $_
                $_ = $null
            }

            # Hashtable
            { $_ -is [hashtable] } {
                Format-Hashtable $_
                $_ = $null
            }

            # По умолчанию - передаем как есть
            default {
                $steppablePipeline.Process($_)
            }
        }
    }

    end {
        $steppablePipeline.End()
    }
}

# Форматирование для файлов и папок
function Format-FileSystemItem {
    param($Item)

    if ($Item -is [System.IO.DirectoryInfo]) {
        # Папка
        Write-RGB "📁 " -FC "Yellow"
        Write-RGB $Item.Name -FC "Yellow" -Style Bold
        Write-RGB " (" -FC "DarkGray"
        $count = (Get-ChildItem $Item -ErrorAction SilentlyContinue | Measure-Object).Count
        Write-RGB "$count items" -FC "Gray"
        Write-RGB ")" -FC "DarkGray" -newline
    } else {
        # Файл
        $icon = Get-FileIcon $Item.Extension
        $sizeColor = Get-SizeColor $Item.Length

        Write-RGB "$icon " -FC "White"
        Write-RGB $Item.Name -FC "White"
        Write-RGB " (" -FC "DarkGray"
        Write-RGB (Format-FileSize $Item.Length) -FC $sizeColor
        Write-RGB ", " -FC "DarkGray"
        Write-RGB $Item.LastWriteTime.ToString("yyyy-MM-dd HH:mm") -FC "Cyan"
        Write-RGB ")" -FC "DarkGray" -newline
    }
}

# Форматирование для служб
function Format-ServiceItem {
    param($Service)

    $statusIcon = if ($Service.Status -eq 'Running') { "🟢" } else { "🔴" }
    $statusColor = if ($Service.Status -eq 'Running') { "LimeGreen" } else { "Red" }

    Write-RGB "$statusIcon " -FC $statusColor
    Write-RGB $Service.Name -FC "Dracula_Purple" -Style Bold
    Write-RGB " - " -FC "DarkGray"
    Write-RGB $Service.DisplayName -FC "White"
    Write-RGB " [" -FC "DarkGray"
    Write-RGB $Service.Status -FC $statusColor
    Write-RGB "]" -FC "DarkGray" -newline
}

# Форматирование для результатов поиска
function Format-MatchInfo {
    param($Match)

    Write-RGB "🔍 " -FC "Cyan"
    Write-RGB $Match.Filename -FC "Dracula_Blue"
    Write-RGB ":" -FC "White"
    Write-RGB $Match.LineNumber -FC "Yellow"
    Write-RGB ": " -FC "White"

    # Подсвечиваем найденное
    $line = $Match.Line
    $pattern = $Match.Pattern

    if ($line -match $pattern) {
        $before = $line.Substring(0, $line.IndexOf($matches[0]))
        $match = $matches[0]
        $after = $line.Substring($line.IndexOf($matches[0]) + $match.Length)

        Write-RGB $before -FC "Gray"
        Write-RGB $match -FC "Yellow" -BC "DarkRed" -Style Bold
        Write-RGB $after -FC "Gray" -newline
    } else {
        Write-RGB $line -FC "Gray" -newline
    }
}

# Форматирование процессов
function Format-ProcessItem {
    param($Process)

    $cpu = if ($Process.CPU) { [math]::Round($Process.CPU, 2) } else { 0 }
    $memory = [math]::Round($Process.WorkingSet64 / 1MB, 2)

    $cpuColor = if ($cpu -gt 50) { "Red" } elseif ($cpu -gt 20) { "Yellow" } else { "Green" }
    $memColor = if ($memory -gt 1000) { "Red" } elseif ($memory -gt 500) { "Yellow" } else { "Green" }

    Write-RGB "⚙️  " -FC "Cyan"
    Write-RGB $Process.ProcessName -FC "Dracula_Yellow" -Style Bold
    Write-RGB " (PID: " -FC "DarkGray"
    Write-RGB $Process.Id -FC "White"
    Write-RGB ") CPU: " -FC "DarkGray"
    Write-RGB "${cpu}%" -FC $cpuColor
    Write-RGB " MEM: " -FC "DarkGray"
    Write-RGB "${memory}MB" -FC $memColor -newline
}

# Форматирование ошибок
function Format-ErrorRecord {
    param($Error)

    Write-RGB "❌ " -FC "Red"
    Write-RGB "ERROR: " -FC "Red" -Style Bold
    Write-RGB $Error.Exception.Message -FC "Dracula_Red" -newline

    if ($Error.InvocationInfo.ScriptLineNumber) {
        Write-RGB "   📍 " -FC "Yellow"
        Write-RGB "Line " -FC "Gray"
        Write-RGB $Error.InvocationInfo.ScriptLineNumber -FC "Yellow"
        Write-RGB " in " -FC "Gray"
        Write-RGB $Error.InvocationInfo.ScriptName -FC "Cyan" -newline
    }
}

# Форматирование hashtable
function Format-Hashtable {
    param($Table)

    Write-RGB "@{" -FC "Dracula_Purple" -newline

    foreach ($key in $Table.Keys) {
        Write-RGB "    " -FC "White"
        Write-RGB $key -FC "Dracula_Cyan"
        Write-RGB " = " -FC "White"

        $value = $Table[$key]
        switch ($value) {
            { $_ -is [string] } {
                Write-RGB '"' -FC "Dracula_Green"
                Write-RGB $_ -FC "Dracula_Green"
                Write-RGB '"' -FC "Dracula_Green"
            }
            { $_ -is [int] -or $_ -is [double] } {
                Write-RGB $_ -FC "Dracula_Pink"
            }
            { $_ -is [bool] } {
                Write-RGB $_.ToString().ToLower() -FC "Dracula_Orange"
            }
            default {
                Write-RGB $_ -FC "White"
            }
        }
        Write-Host ""
    }

    Write-RGB "}" -FC "Dracula_Purple" -newline
}

# Вспомогательные функции
function Get-FileIcon {
    param([string]$Extension)

    switch ($Extension.ToLower()) {
        '.ps1'   { '⚡' }
        '.txt'   { '📄' }
        '.log'   { '📋' }
        '.json'  { '🔧' }
        '.xml'   { '📐' }
        '.exe'   { '🚀' }
        '.dll'   { '📦' }
        '.zip'   { '🗜️' }
        '.jpg'   { '🖼️' }
        '.png'   { '🖼️' }
        '.mp3'   { '🎵' }
        '.mp4'   { '🎬' }
        '.pdf'   { '📕' }
        '.doc'   { '📘' }
        '.docx'  { '📘' }
        default  { '📄' }
    }
}

function Get-SizeColor {
    param([long]$Size)

    switch ($Size) {
        { $_ -gt 1GB }  { 'Red' }
        { $_ -gt 100MB } { 'Yellow' }
        { $_ -gt 10MB }  { 'Cyan' }
        default         { 'Green' }
    }
}

function Format-FileSize {
    param([long]$Size)

    switch ($Size) {
        { $_ -gt 1GB } { "{0:N2} GB" -f ($_ / 1GB) }
        { $_ -gt 1MB } { "{0:N2} MB" -f ($_ / 1MB) }
        { $_ -gt 1KB } { "{0:N2} KB" -f ($_ / 1KB) }
        default { "$_ bytes" }
    }
}

# Демонстрация возможностей
function Show-OutDefaultDemo {
    Clear-Host
    Write-GradientHeader -Title "OUT-DEFAULT PROXY DEMO"

    Write-RGB "🎨 Этот скрипт перехватывает ВЕСЬ вывод PowerShell!" -FC "Gold" -Style Bold -newline

    Write-RGB "`n📌 Что он делает:" -FC "Cyan" -Style Bold -newline
    Write-RGB "  • Перехватывает Out-Default (вызывается для любого вывода)" -FC "White" -newline
    Write-RGB "  • Проверяет тип объекта" -FC "White" -newline
    Write-RGB "  • Применяет красивое форматирование" -FC "White" -newline
    Write-RGB "  • Добавляет цвета и иконки" -FC "White" -newline

    Write-RGB "`n🔥 Примеры форматирования:" -FC "Yellow" -Style Bold -newline

    # Пример 1: Файлы
    Write-RGB "`n1️⃣ Файлы и папки:" -FC "Cyan" -newline
    Get-ChildItem $env:TEMP | Select-Object -First 3

    # Пример 2: Службы
    Write-RGB "`n2️⃣ Службы:" -FC "Cyan" -newline
    Get-Service | Select-Object -First 3

    # Пример 3: Процессы
    Write-RGB "`n3️⃣ Процессы:" -FC "Cyan" -newline
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 3

    # Пример 4: Hashtable
    Write-RGB "`n4️⃣ Hashtable:" -FC "Cyan" -newline
    @{
        Name = "PowerShell"
        Version = $PSVersionTable.PSVersion
        OS = $PSVersionTable.OS
        IsAwesome = $true
        Rating = 10
    }

    Write-RGB "`n💡 Ключевая техника:" -FC "Red" -Style Bold -newline
    Write-RGB "  Использование " -FC "White"
    Write-RGB "SteppablePipeline" -FC "Yellow" -Style Bold
    Write-RGB " для перехвата pipeline" -FC "White" -newline

    Write-RGB "`n🚀 Это позволяет полностью контролировать вывод!" -FC "LimeGreen" -Style Bold -newline
}

# Включение/выключение кастомного форматирования
function Enable-CustomFormatting {
    Write-Status -Success "Кастомное форматирование включено!"
    Write-RGB "Теперь весь вывод будет красивым! 🎨" -FC "Gold" -newline
}

function Disable-CustomFormatting {
    # Удаляем нашу функцию, чтобы вернуть оригинальную
    Remove-Item Function:\Out-Default -Force
    Write-Status -Info "Вернулись к стандартному форматированию"
}

# Альтернативный подход - Format.ps1xml
function New-CustomFormat {
    <#
    .SYNOPSIS
        Создает кастомный Format.ps1xml для типов

    .DESCRIPTION
        Это альтернативный способ кастомизации вывода через XML
    #>

    $formatXml = @'
<?xml version="1.0" encoding="utf-8"?>
<Configuration>
    <ViewDefinitions>
        <View>
            <Name>CustomFileInfo</Name>
            <ViewSelectedBy>
                <TypeName>System.IO.FileInfo</TypeName>
            </ViewSelectedBy>
            <ListControl>
                <ListEntries>
                    <ListEntry>
                        <ListItems>
                            <ListItem>
                                <Label>📄 Name</Label>
                                <PropertyName>Name</PropertyName>
                            </ListItem>
                            <ListItem>
                                <Label>📏 Size</Label>
                                <ScriptBlock>
                                    "{0:N2} MB" -f ($_.Length / 1MB)
                                </ScriptBlock>
                            </ListItem>
                        </ListItems>
                    </ListEntry>
                </ListEntries>
            </ListControl>
        </View>
    </ViewDefinitions>
</Configuration>
'@

    $formatPath = "$env:TEMP\CustomFormat.ps1xml"
    $formatXml | Out-File $formatPath

    Update-FormatData -PrependPath $formatPath

    Write-Status -Success "Кастомный формат загружен из XML"
}

Write-RGB "`n🎨 " -FC "Gold"
Write-GradientText "Out-Default Proxy System" -StartColor "#FF00FF" -EndColor "#00FFFF" -NoNewline
Write-RGB " загружен!" -FC "Gold" -newline

Write-RGB "`nПопробуйте: " -FC "Gray"
Write-RGB "Show-OutDefaultDemo" -FC "Dracula_Pink" -Style Bold
Write-RGB " для демонстрации" -FC "Gray" -newline