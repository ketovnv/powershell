
importProcess  $MyInvocation.MyCommand.Name.trim('.ps1') -start
function Get-Help
{
    [CmdletBinding(DefaultParameterSetName = 'AllUsersView')]
    param(
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(ParameterSetName = 'DetailedView', Mandatory = $true)]
        [switch]$Detailed,

        [Parameter(ParameterSetName = 'AllUsersView')]
        [switch]$Full,

        [Parameter(ParameterSetName = 'Examples', Mandatory = $true)]
        [switch]$Examples,

        [Parameter(ParameterSetName = 'Parameters', Mandatory = $true)]
        [string[]]$Parameter,

        [Parameter(ParameterSetName = 'Online', Mandatory = $true)]
        [switch]$Online,

    # Наши дополнительные параметры
        [switch]$Colorized,
        [switch]$Interactive,
        [switch]$ShowRelated,
        [switch]$ExportHTML
    )

    # Сохраняем наши параметры и убираем их из передачи в оригинальную команду
    $ourParams = @{ }
    foreach ($param in @('Colorized', 'Interactive', 'ShowRelated', 'ExportHTML'))
    {
        if ( $PSBoundParameters.ContainsKey($param))
        {
            $ourParams[$param] = $PSBoundParameters[$param]
            $PSBoundParameters.Remove($param)
        }
    }

    # Вызываем ОРИГИНАЛЬНЫЙ Get-Help
    $helpResult = Microsoft.PowerShell.Core\Get-Help @PSBoundParameters


    # Теперь можем делать с результатом что угодно!
    if ($ourParams.Colorized -or $true)
    {
        # По умолчанию включаем цвета
        $helpResult | Format-ColorizedHelp -ShowRelated:$ourParams.ShowRelated
    }
    elseif ($ourParams.Interactive)
    {
        Show-InteractiveHelp -HelpObject $helpResult
    }
    elseif ($ourParams.ExportHTML)
    {
        Export-HelpToHTML -HelpObject $helpResult
    }
    else
    {
        # Возвращаем как есть
        $helpResult
    }
}

function Format-ColorizedHelp
{
    param(
        [Parameter(ValueFromPipeline)]
        $HelpObject,
        [switch]$ShowRelated
    )

    process {
        # Преобразуем в строку для обработки
        $helpText = $HelpObject | Out-String

        # Продвинутые паттерны для подсветки

        $patterns = @{
            # Секции (с поддержкой разных языков)
            Sections = @{
                Pattern = '(?m)^(NAME|PowerShell|ИМЯ|SYNOPSIS|КРАТКОЕ ОПИСАНИЕ|SYNTAX|СИНТАКСИС|DESCRIPTION|ОПИСАНИЕ|PARAMETERS|ПАРАМЕТРЫ|EXAMPLES?|ПРИМЕРЫ?|INPUTS|ВХОДНЫЕ ДАННЫЕ|OUTPUTS|ВЫХОДНЫЕ ДАННЫЕ|NOTES|ПРИМЕЧАНИЯ|RELATED LINKS|СВЯЗАННЫЕ ССЫЛКИ)(.*)$'
                Style = @{
                    FC = "Material_Pink"
                    Effects = @('Bold', 'Underline')
                }
            }
            # Имя команды
            CommandName = @{
                Pattern = "(?<![a-zA-Z-])($([regex]::Escape($HelpObject.Name) ))(?![a-zA-Z-])"
                Style = @{
                    FC = "Material_Yellow"
                    Effects = @('Bold')
                }
            }
            # Параметры
            Parameters = @{
                Pattern = '\B-[a-zA-Z]\w*\b'
                Style = @{ FC = "Material_Cyan" }
            }
            # Типы данных
            Types = @{
                Pattern = '\[([\w\[\]\.]+)\]'
                Style = @{ FC = "Material_Purple"; Effects = @('Italic') }
            }
            # Required, Position и т.д.
            Attributes = @{
                Pattern = '\b(Required|Mandatory|Position|ValueFromPipeline|ValueFromPipelineByPropertyName)\b'
                Style = @{ FC = "Material_Orange" }
            }
            # Значения по умолчанию
            DefaultValues = @{
                Pattern = 'Default value:?\s*(.+)$'
                Style = @{ FC = "Material_Green" }
            }
            # URL и пути
            Links = @{
                Pattern = 'https?://[^\s]+'
                Style = @{ FC = "SkyBlue"; Effects = @('Underline') }
            }
            # Примеры кода
            CodeExamples = @{
                Pattern = '^\s{4,}.+$'  # Строки с отступом (обычно примеры)
                Style = @{ FC = "Material_Comment"; BC = "#1E1E1E" }
            }
        }

        # Разбиваем на строки для построчной обработки
        $lines = $helpText -split "`n"

        foreach ($line in $lines)
        {
            $processed = $false
            $segments = @()

            # Проверяем каждый паттерн
            foreach ($patternName in $patterns.Keys)
            {
                $pattern = $patterns[$patternName]

                if ($line -match $pattern.Pattern)
                {
                    $processed = $true

                    # Особая обработка для секций
                    if ($patternName -eq 'Sections')
                    {
                        Write-Host ""  # Пустая строка перед секцией
                        wrgb $matches[1] -FC $pattern.Style.FC -Style $pattern.Style.Effects
                        if ($matches[2])
                        {
                            wrgb $matches[2] -FC "White" -newline
                        }
                        else
                        {
                            Write-Host ""
                        }
                        break
                    }
                }
            }

            # Если строка не обработана специальным образом
            if (-not $processed)
            {
                # Применяем все паттерны к строке
                $finalLine = $line

                foreach ($patternName in @('Types', 'Parameters', 'CommandName', 'Attributes', 'Links'))
                {
                    $pattern = $patterns[$patternName]
                    $finalLine = [regex]::Replace($finalLine, $pattern.Pattern, {
                        param($match)
                        $fcValue = $pattern.Style.FC
                        $colorValue = if ($fcValue -and $global:RGB -and $global:RGB.ContainsKey($fcValue)) { 
                            $global:RGB[$fcValue] 
                        } else { 
                            if ($fcValue) { $fcValue } else { "White" }
                        }
                        $color = Get-RGBColor $colorValue
                        $reset = $PSStyle.Reset

                        # Добавляем эффекты
                        $effects = ""
                        if ($pattern.Style.Effects -contains 'Bold')
                        {
                            $effects += $PSStyle.Bold
                        }
                        if ($pattern.Style.Effects -contains 'Italic')
                        {
                            $effects += $PSStyle.Italic
                        }
                        if ($pattern.Style.Effects -contains 'Underline')
                        {
                            $effects += $PSStyle.Underline
                        }

                        return $effects + $color + $match.Value + $reset
                    })
                }

                # Проверяем, не является ли это примером кода
                if ($line -match '^\s{4,}.+$')
                {
                    wrgb $line -FC "Material_Comment" -BC "#1E1E1E" -newline
                }
                else
                {
                    Write-Host $finalLine
                }
            }
        }

        # Показываем связанные команды если нужно
        if ($ShowRelated)
        {
            Show-RelatedCommands -CommandName $HelpObject.Name
        }
    }
}

function Show-RelatedCommands
{
    param([string]$CommandName)

    Write-Host ""
    wrgb "СВЯЗАННЫЕ КОМАНДЫ" -FC "Material_Pink" -Style @('Bold', 'Underline') -newline

    # Ищем команды с похожим именем или из того же модуля
    $command = Get-Command $CommandName -ErrorAction SilentlyContinue
    if ($command -and $command.ModuleName)
    {
        $relatedCommands = Get-Command -Module $command.ModuleName |
                Where-Object {
                    $_.Name -ne $CommandName
                } |
                Select-Object -First 5

        foreach ($related in $relatedCommands)
        {
            wrgb "  • " -FC "DarkGray"
            wrgb $related.Name -FC "Material_Cyan"
            wrgb " - " -FC "DarkGray"

            # Получаем краткое описание
            $synopsis = (Microsoft.PowerShell.Core\Get-Help $related.Name).Synopsis
            if ($synopsis)
            {
                wrgb ($synopsis -split "`n")[0] -FC "Gray" -newline
            }
            else
            {
                wrgb "Нет описания" -FC "DarkGray" -newline
            }
        }
    }
}

#endregion

#region Другие мощные применения техники

# Пример 2: Перехват Get-Process с дополнительной информацией
function Get-Process
{
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        [Parameter(ParameterSetName = 'Name', Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('ProcessName')]
        [string[]]$Name,

        [Parameter(ParameterSetName = 'Id', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [int[]]$Id,

        [Parameter(ParameterSetName = 'InputObject', Mandatory = $true, ValueFromPipeline = $true)]
        [System.Diagnostics.Process[]]$InputObject,

    # Наши дополнительные параметры
        [switch]$ShowPerformance,
        [switch]$ColorByUsage,
        [switch]$Tree
    )

    # Сохраняем наши параметры
    $ourParams = @{
    }
    foreach ($param in @('ShowPerformance', 'ColorByUsage', 'Tree'))
    {
        if ( $PSBoundParameters.ContainsKey($param))
        {
            $ourParams[$param] = $PSBoundParameters[$param]
            $PSBoundParameters.Remove($param)
        }
    }

    # Вызываем оригинальный Get-Process
    $processes = Microsoft.PowerShell.Management\Get-Process @PSBoundParameters

    # Улучшаем вывод
    if ($ourParams.ShowPerformance)
    {
        $processes | Format-ProcessPerformance
    }
    elseif ($ourParams.ColorByUsage)
    {
        $processes | Format-ProcessColored
    }
    elseif ($ourParams.Tree)
    {
        $processes | Format-ProcessTree
    }
    else
    {
        $processes
    }
}

function Format-ProcessColored
{
    param(
        [Parameter(ValueFromPipeline)]
        [System.Diagnostics.Process]$Process
    )

    begin {
        $totalMemory = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
        wrgb "PID".PadRight(8) -FC "Cyan"
        wrgb "Name".PadRight(25) -FC "Cyan"
        wrgb "CPU(s)".PadRight(10) -FC "Cyan"
        wrgb "Memory(MB)".PadRight(12) -FC "Cyan"
        wrgb "Status" -FC "Cyan" -newline
        wrgb ("-" * 65) -FC "DarkGray" -newline
    }

    process {
        # Определяем цвет по использованию ресурсов
        $memoryMB = [math]::Round($Process.WorkingSet64 / 1MB, 2)
        $memoryPercent = ($Process.WorkingSet64 / $totalMemory) * 100

        $cpuColor = "White"
        $memColor = if ($memoryPercent -gt 10)
        {
            "Red"
        }
        elseif ($memoryPercent -gt 5)
        {
            "Yellow"
        }
        else
        {
            "Green"
        }

        wrgb $Process.Id.ToString().PadRight(8) -FC "White"
        wrgb $Process.ProcessName.PadRight(25) -FC "Material_Purple"
        wrgb $Process.CPU.ToString("F2").PadRight(10) -FC $cpuColor
        wrgb $memoryMB.ToString().PadRight(12) -FC $memColor
        wrgb $( if ($Process.Responding)
        {
            "✓ Running"
        }
        else
        {
            "✗ Not Responding"
        } ) `
                 -FC $( if ($Process.Responding)
        {
            "LimeGreen"
        }
        else
        {
            "Red"
        } ) -newline
    }
}

# Пример 3: Умный Get-ChildItem с preview файлов
function Get-ChildItem
{
    [CmdletBinding(DefaultParameterSetName = 'Items')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$Path,

        [Parameter(Position = 1)]
        [string]$Filter,

        [string[]]$Include,
        [string[]]$Exclude,
        [switch]$Recurse,
        [switch]$Force,
        [switch]$Name,

    # Наши параметры
        [switch]$Preview,
        [switch]$ColorByType,
        [switch]$ShowSize,
        [switch]$Git  # Учитывать .gitignore
    )

    # Сохраняем наши параметры
    $ourParams = @{
    }
    foreach ($param in @('Preview', 'ColorByType', 'ShowSize', 'Git'))
    {
        if ( $PSBoundParameters.ContainsKey($param))
        {
            $ourParams[$param] = $PSBoundParameters[$param]
            $PSBoundParameters.Remove($param)
        }
    }

    # Вызываем оригинальный Get-ChildItem
    $items = Microsoft.PowerShell.Management\Get-ChildItem @PSBoundParameters

    # Обрабатываем результат
    if ($ourParams.Preview)
    {
        $items | Show-FilePreview
    }
    elseif ($ourParams.ColorByType)
    {
        $items | Format-ItemsColored
    }
    elseif ($ourParams.Git)
    {
        # Фильтруем согласно .gitignore
        $items | Where-Object {
            -not (Test-GitIgnored $_.FullName)
        }
    }
    else
    {
        $items
    }
}

function Format-ItemsColored
{
    param(
        [Parameter(ValueFromPipeline)]
        $Item
    )

    process {
        $icon = ""
        $color = "White"

        if ($Item.PSIsContainer)
        {
            $icon = "📁"
            $color = "Material_Yellow"
        }
        else
        {
            switch -Wildcard ( $Item.Extension.ToLower())
            {
                ".ps1" {
                    $icon = "⚡"; $color = "Material_Blue"
                }
                ".txt" {
                    $icon = "📄"; $color = "White"
                }
                ".log" {
                    $icon = "📋"; $color =
    "Gray"
                }
                ".json" {
                    $icon = "🔧"; $color = "Material_Green"
                }
                ".xml" {
                    $icon = "📐"; $color = "Material_Orange"
                }
                ".exe" {
                    $icon = "🚀"; $color = "Material_Red"
                }
                ".dll" {
                    $icon = "📦"; $color = "Material_Purple"
                }
                ".zip" {
                    $icon = "🗜️"; $color = "Material_Cyan"
                }
                ".jpg" {
                    $icon = "🖼️"; $color = "Material_Pink"
                }
                ".mp3" {
                    $icon = "🎵"; $color = "Material_Purple"
                }
                ".mp4" {
                    $icon = "🎬"; $color = "Material_Red"
                }
                default {
                    $icon = "📄"; $color = "White"
                }
            }
        }

        wrgb "$icon " -FC $color
        wrgb $Item.Name -FC $color

        if (-not $Item.PSIsContainer)
        {
            $size = switch ($Item.Length)
            {
                {
                    $_ -gt 1GB
                } {
                    " ({0:N2} GB)" -f ($_ / 1GB)
                }
                {
                    $_ -gt 1MB
                } {
                    " ({0:N2} MB)" -f ($_ / 1MB)
                }
                {
                    $_ -gt 1KB
                } {
                    " ({0:N2} KB)" -f ($_ / 1KB)
                }
                default {
                    " ($_ bytes)"
                }
            }
            wrgb $size -FC "DarkGray"
        }

        Write-Host ""
    }
}

#endregion

#region Создание универсального Proxy генератора

function New-CommandProxy
{
    <#
    .SYNOPSIS
        Создает proxy-функцию для любой команды с возможностью модификации

    .DESCRIPTION
        Генерирует функцию-обертку, которая перехватывает вызовы команды,
        позволяет модифицировать параметры, результат и добавлять функционал

    .EXAMPLE
        New-CommandProxy -Command Get-Service -AddParameters @{
            ColorStatus = @{ Type = 'switch'; Help = 'Цветной вывод статусов' }
        } -OutputScript MyGetService.ps1
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Command,

        [hashtable]$AddParameters = @{
    },

        [scriptblock]$PreProcess,
        [scriptblock]$PostProcess,

        [string]$OutputScript,
        [switch]$PassThru
    )

    # Получаем метаданные команды
    $cmd = Get-Command $Command -ErrorAction Stop
    $metadata = [System.Management.Automation.CommandMetadata]::new($cmd)

    # Генерируем прокси
    $proxyScript = [System.Management.Automation.ProxyCommand]::Create($metadata)

    # Модифицируем скрипт
    if ($AddParameters.Count -gt 0)
    {
        # Добавляем наши параметры
        $paramBlock = ""
        foreach ($paramName in $AddParameters.Keys)
        {
            $param = $AddParameters[$paramName]
            $paramBlock += "`n        [$( $param.Type )]`$$paramName,"
        }

        # Вставляем параметры в нужное место
        $proxyScript = $proxyScript -replace '(\[CmdletBinding[^\]]*\]\s*param\s*\([^)]*)', "`$1,$paramBlock"
    }

    # Добавляем нашу логику
    $enhancedScript = @"
function $Command {
$proxyScript
}
"@

    if ($OutputScript)
    {
        $enhancedScript | Out-File -FilePath $OutputScript -Encoding UTF8
        Write-Status -Success "Proxy функция сохранена в: $OutputScript"
    }

    if ($PassThru)
    {
        return $enhancedScript
    }
}

#endregion

#region Интерактивный исследователь команд

function Explore-Command
{
    <#
    .SYNOPSIS
        Интерактивный исследователь внутренностей PowerShell команд

    .DESCRIPTION
        Позволяет изучить любую команду изнутри, посмотреть все доступные
        перегрузки, параметры, методы и создать улучшенную версию
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    Clear-Host
    Write-GradientHeader -Title "COMMAND EXPLORER: $Name"

    # Получаем полную информацию
    $command = Get-Command $Name -ErrorAction Stop
    $help = Microsoft.PowerShell.Core\Get-Help $Name -Full

    wrgb "`n📋 Основная информация:" -FC "Cyan" -Style Bold -newline
    wrgb "  Тип: " -FC "Gray"
    wrgb $command.CommandType -FC "Yellow" -newline
    wrgb "  Модуль: " -FC "Gray"
    wrgb $command.ModuleName -FC "Material_Purple" -newline
    wrgb "  Версия: " -FC "Gray"
    wrgb $command.Version -FC "Material_Green" -newline

    # Полный путь к команде
    wrgb "  Полное имя: " -FC "Gray"
    wrgb "$( $command.ModuleName )\$( $command.Name )" -FC "Material_Orange" -newline

    # Параметры
    wrgb "`n📊 Параметры:" -FC "Cyan" -Style Bold -newline
    $command.Parameters.Values | ForEach-Object {
        wrgb "  • " -FC "DarkGray"
        wrgb "-$( $_.Name )" -FC "Material_Cyan"
        wrgb " [$( $_.ParameterType.Name )]" -FC "Material_Purple"

        if ($_.IsMandatory)
        {
            wrgb " (Обязательный)" -FC "Red"
        }

        Write-Host ""
    }

    # Наборы параметров
    if ($command.ParameterSets.Count -gt 1)
    {
        wrgb "`n🔀 Наборы параметров:" -FC "Cyan" -Style Bold -newline
        $command.ParameterSets | ForEach-Object {
            wrgb "  • " -FC "DarkGray"
            wrgb $_.Name -FC "Material_Yellow"
            if ($_.IsDefault)
            {
                wrgb " (По умолчанию)" -FC "Green"
            }
            Write-Host ""
        }
    }

    # Примеры вызовов
    wrgb "`n💡 Способы вызова:" -FC "Cyan" -Style Bold -newline

    # Прямой вызов
    wrgb "  1. Обычный: " -FC "Gray"
    wrgb $Name -FC "White" -newline

    # Через модуль
    if ($command.ModuleName)
    {
        wrgb "  2. Через модуль: " -FC "Gray"
        wrgb "$( $command.ModuleName )\$Name" -FC "White" -newline
    }

    # Полный путь
    wrgb "  3. Полный путь: " -FC "Gray"
    wrgb "Microsoft.PowerShell.$( $command.ModuleName )\$Name" -FC "White" -newline

    # Создание proxy
    wrgb "`n🔧 Действия:" -FC "Cyan" -Style Bold -newline
    wrgb "  [P] Создать Proxy-функцию" -FC "Yellow" -newline
    wrgb "  [T] Протестировать вызовы" -FC "Yellow" -newline
    wrgb "  [E] Экспортировать информацию" -FC "Yellow" -newline
    wrgb "  [Q] Выход" -FC "Red" -newline

    wrgb "`nВыбор: " -FC "White"
    $choice = Read-Host

    switch ( $choice.ToUpper())
    {
        'P' {
            wrgb "`nИмя для proxy-функции: " -FC "Cyan"
            $proxyName = Read-Host

            if ($proxyName)
            {
                New-CommandProxy -Command $Name -OutputScript "$proxyName.ps1" -AddParameters @{
                    Enhanced = @{
                        Type = 'switch'; Help = 'Включить улучшения'
                    }
                    ColorOutput = @{
                        Type = 'switch'; Help = 'Цветной вывод'
                    }
                }
            }
        }
        'T' {
            Test-CommandCalls -CommandName $Name
        }
        'E' {
            $exportData = @{
                Command = $command
                Help = $help
                Parameters = $command.Parameters
                ParameterSets = $command.ParameterSets
            }

            $exportPath = "$env:TEMP\$Name`_info.json"
            $exportData | ConvertTo-Json -Depth 10 | Out-File $exportPath
            Write-Status -Success "Экспортировано в: $exportPath"
        }
    }
}

function Test-CommandCalls
{
    param([string]$CommandName)

    wrgb "`n🧪 Тестирование различных способов вызова:" -FC "Cyan" -Style Bold -newline

    # Тест 1: Обычный вызов
    wrgb "`n1. Обычный вызов:" -FC "Yellow" -newline
    try
    {
        $result1 = & $CommandName -ErrorAction Stop
        Write-Status -Success "Успешно"
    }
    catch
    {
        Write-Status -Error $_.Exception.Message
    }

    # Тест 2: Через модуль
    $cmd = Get-Command $CommandName
    if ($cmd.ModuleName)
    {
        wrgb "`n2. Через модуль:" -FC "Yellow" -newline
        try
        {
            $result2 = & "$( $cmd.ModuleName )\$CommandName" -ErrorAction Stop
            Write-Status -Success "Успешно"
        }
        catch
        {
            Write-Status -Error $_.Exception.Message
        }
    }

    # Тест 3: Полный путь
    wrgb "`n3. Полный путь:" -FC "Yellow" -newline
    try
    {
        $fullPath = "Microsoft.PowerShell.$( $cmd.ModuleName )\$CommandName"
        $result3 = & $fullPath -ErrorAction Stop
        Write-Status -Success "Успешно"
    }
    catch
    {
        Write-Status -Error $_.Exception.Message
    }
}

#endregion

#region Демонстрация возможностей

function Show-ProxyTechniquesDemo
{
    Clear-Host
    Write-GradientHeader -Title "PROXY TECHNIQUES DEMONSTRATION"

    wrgb "🔮 Демонстрация мощи техники Microsoft.PowerShell.Core\Command" -FC "GoldRGB" -Style Bold -newline

    # Демо 1: Улучшенный Get-Help
    wrgb "`n1️⃣ Улучшенный Get-Help с цветами:" -FC "Cyan" -newline
    wrgb "Попробуйте: " -FC "Gray"
    wrgb "Get-Help Get-Process" -FC "Yellow" -Style Bold -newline

    # Демо 2: Цветной Get-Process
    wrgb "`n2️⃣ Get-Process с цветовой индикацией:" -FC "Cyan" -newline
    wrgb "Попробуйте: " -FC "Gray"
    wrgb "Get-Process -ColorByUsage" -FC "Yellow" -Style Bold -newline

    # Демо 3: Get-ChildItem с иконками
    wrgb "`n3️⃣ Get-ChildItem с иконками файлов:" -FC "Cyan" -newline
    wrgb "Попробуйте: " -FC "Gray"
    wrgb "Get-ChildItem -ColorByType" -FC "Yellow" -Style Bold -newline

    # Демо 4: Исследование команд
    wrgb "`n4️⃣ Исследователь команд:" -FC "Cyan" -newline
    wrgb "Попробуйте: " -FC "Gray"
    wrgb "Explore-Command Get-Service" -FC "Yellow" -Style Bold -newline

    wrgb "`n💡 Эта техника позволяет:" -FC "Material_Orange" -Style Bold -newline
    wrgb "  • Перехватывать любые команды" -FC "White" -newline
    wrgb "  • Добавлять новый функционал" -FC "White" -newline
    wrgb "  • Сохранять полную совместимость" -FC "White" -newline
    wrgb "  • Создавать умные обертки" -FC "White" -newline

    wrgb "`n🎯 Ключевая строка:" -FC "Red" -Style Bold -newline
    wrgb "  Microsoft.PowerShell.Core\Get-Help @PSBoundParameters" -FC "Material_Yellow" -BC "#1E1E1E" -newline

    wrgb "`nЭто как 'системный вызов' - прямой доступ к оригинальной команде!" -FC "Gray" -newline
}

#endregion

# Экспорт функций
if ($MyInvocation.MyCommand.Path -match '\.psm1$')
{
    Export-ModuleMember -Function * -Alias *
}

# Информация при загрузке
wrgb "`n🔮 " -FC "GoldRGB"
Write-GradientText "Advanced Proxy Techniques" -StartColor "#FF00FF" -EndColor "#00FFFF" -NoNewline
wrgb " загружены!" -FC "GoldRGB" -newline

wrgb "Попробуйте: " -FC "Gray"
wrgb "Show-ProxyTechniquesDemo" -FC "Material_Pink" -Style Bold
wrgb " для демонстрации" -FC "Gray" -newline


# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    🧙‍♂️ SUPER ADVANCED PROXY MAGIC                           ║
# ║                   Глубокая магия PowerShell прокси-команд                   ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

#region Универсальный перехватчик ВСЕХ команд

function Enable-UniversalCommandInterceptor
{
    <#
    .SYNOPSIS
        Включает универсальный перехватчик для ВСЕХ команд PowerShell

    .DESCRIPTION
        Создает прокси для каждой команды в системе, позволяя логировать,
        модифицировать и улучшать любые вызовы

    .EXAMPLE
        Enable-UniversalCommandInterceptor -LogCalls -ColorOutput
    #>
    [CmdletBinding()]
    param(
        [switch]$LogCalls,
        [switch]$ColorOutput,
        [switch]$MeasurePerformance,
        [switch]$SafeMode, # Блокирует опасные команды
        [string[]]$IncludeCommand = @(),
        [string[]]$ExcludeCommand = @()
    )

    $script:InterceptorConfig = @{
        LogCalls = $LogCalls
        ColorOutput = $ColorOutput
        MeasurePerformance = $MeasurePerformance
        SafeMode = $SafeMode
        CallLog = @()
    }

    # Получаем все команды
    $commands = Get-Command -CommandType Cmdlet, Function

    if ($IncludeCommand) {
        $commands = $commands | Where-Object {
            $_.Name -in $IncludeCommand
        }
    }

    if ($ExcludeCommand)
    {
        $commands = $commands | Where-Object {
            $_.Name -notin $ExcludeCommand
        }
    }

    $intercepted = 0
    foreach ($cmd in $commands)
    {
        try
        {
            # Создаем уникальное имя для оригинальной команды
            $originalName = "__Original_$( $cmd.Name )"

            # Сохраняем ссылку на оригинальную команду
            if (-not (Get-Command $originalName -ErrorAction SilentlyContinue))
            {
                Set-Alias -Name $originalName -Value "$( $cmd.ModuleName )\$( $cmd.Name )" -Scope Global
            }

            # Создаем прокси
            $proxyDefinition = @"
function global:$( $cmd.Name ) {
    [CmdletBinding()]
    param()

    dynamicparam {
        # Получаем оригинальные параметры
        `$wrappedCmd = Get-Command $originalName
        `$metadata = [System.Management.Automation.CommandMetadata]::new(`$wrappedCmd)
        `$dynamicParams = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

        foreach (`$param in `$metadata.Parameters.Values) {
            `$dynParam = [System.Management.Automation.RuntimeDefinedParameter]::new(
                `$param.Name,
                `$param.ParameterType,
                `$param.Attributes
            )
            `$dynamicParams.Add(`$param.Name, `$dynParam)
        }

        return `$dynamicParams
    }

    begin {
        `$startTime = Get-Date

        if (`$script:InterceptorConfig.LogCalls) {
            `$script:InterceptorConfig.CallLog += @{
                Command = '$( $cmd.Name )'
                Time = `$startTime
                Parameters = `$PSBoundParameters
            }
        }

        if (`$script:InterceptorConfig.SafeMode) {
            # Проверяем опасные команды
            `$dangerous = @('Remove-Item', 'Clear-Content', 'Stop-Process', 'Stop-Computer', 'Restart-Computer')
            if ('$( $cmd.Name )' -in `$dangerous) {
                Write-Warning "Команда '$( $cmd.Name )' заблокирована в безопасном режиме!"
                return
            }
        }
    }

    process {
        # Вызываем оригинальную команду
        & $originalName @PSBoundParameters
    }

    end {
        if (`$script:InterceptorConfig.MeasurePerformance) {
            `$duration = (Get-Date) - `$startTime
            Write-Host "⏱️ $( $cmd.Name ): `$(`$duration.TotalMilliseconds)ms" -ForegroundColor DarkGray
        }
    }
}
"@

            # Выполняем определение прокси
            Invoke-Expression $proxyDefinition
            $intercepted++

        }
        catch
        {
            # Пропускаем команды, которые не можем перехватить
            continue
        }
    }

    Write-Status -Success "Перехвачено команд: $intercepted"
}

function Disable-UniversalCommandInterceptor
{
    <#
    .SYNOPSIS
        Отключает универсальный перехватчик команд
    #>

    # Здесь нужна логика для восстановления оригинальных команд
    Write-Status -Warning "Для полного отключения требуется перезапуск сессии PowerShell"
}

function Show-InterceptedCalls
{
    <#
    .SYNOPSIS
        Показывает журнал перехваченных вызовов
    #>

    if (-not $script:InterceptorConfig -or $script:InterceptorConfig.CallLog.Count -eq 0) {
    Write-Status -Info "Нет записей о вызовах"
    return
    }

    Write-GradientHeader -Title "INTERCEPTED CALLS LOG"

    $script:InterceptorConfig.CallLog | ForEach-Object {
    wrgb "[$($_.Time.ToString('HH:mm:ss'))] " -FC "DarkGray"
    wrgb $_.Command -FC "Material_Yellow" -Style Bold

    if ($_.Parameters.Count -gt 0) {
    wrgb " -" -FC "Material_Cyan"
    $_.Parameters.GetEnumerator() | ForEach-Object {
    wrgb "$($_.Key):" -FC "Material_Purple"
    wrgb "$($_.Value) " -FC "White"
    }
    }
    Write-Host ""
    }
}

#endregion

#region Умный Help System с AI-подобными подсказками

function Get-SmartHelp
{
    <#
    .SYNOPSIS
        Супер-умный Help с примерами, похожими командами и подсказками
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Name,

        [switch]$ShowSimilar,
        [switch]$ShowUsageStats,
        [switch]$Interactive,
        [switch]$GenerateExamples
    )

    # Если имя не указано, показываем интерактивное меню
    if (-not $Name)
    {
        Show-InteractiveHelpMenu
        return
    }

    # Получаем help через оригинальную команду
    $help = Microsoft.PowerShell.Core\Get-Help $Name -ErrorAction SilentlyContinue

    if (-not $help)
    {
        # Пытаемся найти похожие команды
        Write-Status -Warning "Команда '$Name' не найдена"

        $similar = Get-Command -Name "*$Name*" -ErrorAction SilentlyContinue | Select-Object -First 5
        if ($similar)
        {
            wrgb "`nВозможно, вы искали:" -FC "Cyan" -newline
            $similar | ForEach-Object {
                wrgb "  • " -FC "DarkGray"
                wrgb $_.Name -FC "Material_Yellow"
                wrgb " - " -FC "DarkGray"
                $synopsis = (Microsoft.PowerShell.Core\Get-Help $_.Name).Synopsis
                wrgb ($synopsis -split "`n")[0] -FC "Gray" -newline
            }
        }
        return
    }

    # Красивый вывод help
    Clear-Host
    Write-GradientHeader -Title "SMART HELP: $( $help.Name )" -StartColor "#4ECDC4" -EndColor "#44A08D"

    # Синопсис с эмодзи
    if ($help.Synopsis)
    {
        wrgb "📋 " -FC "Cyan"
        wrgb "КРАТКОЕ ОПИСАНИЕ" -FC "Material_Pink" -Style Bold -newline
        wrgb "   $( $help.Synopsis )" -FC "White" -newline
    }

    # Синтаксис с подсветкой
    if ($help.Syntax)
    {
        wrgb "`n⚡ " -FC "Yellow"
        wrgb "СИНТАКСИС" -FC "Material_Pink" -Style Bold -newline

        $help.Syntax.syntaxItem | ForEach-Object {
            wrgb "   " -FC "White"
            wrgb $_.name -FC "Material_Yellow" -Style Bold

            $_.parameter | ForEach-Object {
                if ($_.required -eq "true")
                {
                    wrgb " -$( $_.name )" -FC "Material_Red" -Style Bold
                }
                else
                {
                    wrgb " [-$( $_.name )]" -FC "Material_Cyan"
                }

                if ($_.parameterValue)
                {
                    wrgb " <$( $_.parameterValue )>" -FC "Material_Purple"
                }
            }
            Write-Host ""
        }
    }

    # Умные примеры
    if ($GenerateExamples -or $help.examples)
    {
        wrgb "`n💡 " -FC "Green"
        wrgb "ПРИМЕРЫ" -FC "Material_Pink" -Style Bold -newline

        if ($help.examples)
        {
            $exampleCount = 1
            $help.examples.example | ForEach-Object {
                wrgb "`n   Пример $exampleCount`: " -FC "Material_Orange" -Style Bold
                wrgb $_.title -FC "Gray" -newline

                # Код примера с подсветкой
                wrgb "   PS> " -FC "DarkCyan"
                $_.code | Out-ParsedPowerShell

                if ($_.remarks)
                {
                    wrgb "   " -FC "White"
                    wrgb ($_.remarks | Out-String).Trim() -FC "Gray" -newline
                }

                $exampleCount++
            }
        }

        # Генерируем дополнительные умные примеры
        if ($GenerateExamples)
        {
            wrgb "`n   🤖 Сгенерированные примеры:" -FC "Material_Green" -newline
            Generate-SmartExamples -CommandName $help.Name
        }
    }

    # Похожие команды
    if ($ShowSimilar)
    {
        wrgb "`n🔗 " -FC "Blue"
        wrgb "ПОХОЖИЕ КОМАНДЫ" -FC "Material_Pink" -Style Bold -newline

        Find-SimilarCommands -CommandName $help.Name | ForEach-Object {
            wrgb "   • " -FC "DarkGray"
            wrgb $_.Name -FC "Material_Cyan"
            wrgb " - " -FC "DarkGray"
            wrgb $_.Synopsis -FC "Gray" -newline
        }
    }

    # Статистика использования
    if ($ShowUsageStats)
    {
        Show-CommandUsageStats -CommandName $help.Name
    }

    # Интерактивный режим
    if ($Interactive)
    {
        Show-InteractiveHelp -HelpObject $help
    }
}

function Generate-SmartExamples
{
    param([string]$CommandName)

    # Здесь можно реализовать логику генерации примеров на основе параметров команды
    $command = Get-Command $CommandName -ErrorAction SilentlyContinue
    if (-not $command)
    {
        return
    }

    # Пример: генерируем базовые варианты использования
    $examples = @()

    # Пример с обязательными параметрами
    $mandatoryParams = $command.Parameters.Values | Where-Object {
        $_.IsMandatory
    }
    if ($mandatoryParams)
    {
        $example = "$CommandName"
        foreach ($param in $mandatoryParams)
        {
            $example += " -$( $param.Name ) "
            $example += switch ($param.ParameterType.Name)
            {
                'String' {
                    '"example"'
                }
                'Int32' {
                    '42'
                }
                'Boolean' {
                    '$true'
                }
                'DateTime' {
                    '(Get-Date)'
                }
                default {
                    '<value>'
                }
            }
        }
        wrgb "   $example" -FC "Yellow" -newline
    }

    # Пример с pipeline
    if ($command.Parameters.Values | Where-Object {
        $_.ValueFromPipeline
    })
    {
        wrgb "   Get-Something | $CommandName" -FC "Yellow" -newline
    }
}

function Find-SimilarCommands
{
    param([string]$CommandName)

    $command = Get-Command $CommandName -ErrorAction SilentlyContinue
    if (-not $command)
    {
        return
    }

    # Ищем команды в том же модуле
    if ($command.ModuleName)
    {
        Get-Command -Module $command.ModuleName |
                Where-Object {
                    $_.Name -ne $CommandName
                } |
                Select-Object -First 5 Name, @{
                    Name = 'Synopsis'
                    Expression = {
                        (Microsoft.PowerShell.Core\Get-Help $_.Name).Synopsis
                    }
                }
    }

    # Ищем команды с похожими именами
    $verb = $command.Name -split '-' | Select-Object -First 1
    Get-Command -Verb $verb |
            Where-Object {
                $_.Name -ne $CommandName
            } |
            Select-Object -First 3 Name, @{
                Name = 'Synopsis'
                Expression = {
                    (Microsoft.PowerShell.Core\Get-Help $_.Name).Synopsis
                }
            }
}

function Show-InteractiveHelp
{
    param($HelpObject)

    $running = $true
    while ($running)
    {
        wrgb "`n📚 Интерактивная справка" -FC "Cyan" -Style Bold -newline
        wrgb "[P] Параметры подробно" -FC "Yellow" -newline
        wrgb "[E] Больше примеров" -FC "Yellow" -newline
        wrgb "[S] Похожие команды" -FC "Yellow" -newline
        wrgb "[T] Попробовать команду" -FC "Yellow" -newline
        wrgb "[Q] Выход" -FC "Red" -newline

        wrgb "`nВыбор: " -FC "White"
        $choice = Read-Host

        switch ( $choice.ToUpper())
        {
            'P' {
                Show-DetailedParameters -Command $HelpObject.Name
            }
            'E' {
                Search-OnlineExamples -Command $HelpObject.Name
            }
            'S' {
                Find-SimilarCommands -CommandName $HelpObject.Name | Format-Table
            }
            'T' {
                Test-CommandInteractive -CommandName $HelpObject.Name
            }
            'Q' {
                $running = $false
            }
        }
    }
}

#endregion

#region Продвинутая работа с модулями

function Get-ModuleInternals
{
    <#
    .SYNOPSIS
        Исследует внутренности PowerShell модуля

    .DESCRIPTION
        Показывает скрытые команды, внутренние функции и недокументированные возможности
    #>
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName,

        [switch]$ShowHidden,
        [switch]$ShowPrivate,
        [switch]$ExportDiagram
    )

    # Загружаем модуль если не загружен
    if (-not (Get-Module $ModuleName))
    {
        Import-Module $ModuleName -ErrorAction Stop
    }

    $module = Get-Module $ModuleName

    Write-GradientHeader -Title "MODULE INTERNALS: $ModuleName"

    # Основная информация
    wrgb "📦 Модуль: " -FC "Cyan"
    wrgb $module.Name -FC "White" -Style Bold
    wrgb " v$( $module.Version )" -FC "Gray" -newline

    # Все экспортированные команды
    wrgb "`n📤 Экспортированные команды:" -FC "Cyan" -Style Bold -newline
    $module.ExportedCommands.Values | Group-Object CommandType | ForEach-Object {
        wrgb "  $( $_.Name ): " -FC "Material_Purple"
        wrgb $_.Count -FC "Yellow" -Style Bold -newline
    }

    # Скрытые/приватные функции
    if ($ShowHidden -or $ShowPrivate)
    {
        wrgb "`n🔒 Скрытые элементы:" -FC "Cyan" -Style Bold -newline

        # Получаем все функции из пространства имен модуля
        $moduleScope = & $module {
            $ExecutionContext.SessionState.Module
        }
        $allFunctions = & $moduleScope {
            Get-Command -CommandType Function
        }

        $privateFunctions = $allFunctions | Where-Object {
            $_.Name -notin $module.ExportedCommands.Keys
        }

        if ($privateFunctions)
        {
            wrgb "  Найдено приватных функций: " -FC "Gray"
            wrgb $privateFunctions.Count -FC "Red" -Style Bold -newline

            $privateFunctions | Select-Object -First 10 | ForEach-Object {
                wrgb "  • " -FC "DarkGray"
                wrgb $_.Name -FC "Material_Red"

                # Пытаемся получить описание
                $ast = $_.ScriptBlock.Ast
                if ($ast.Body.ParamBlock -and $ast.Body.ParamBlock.Attributes)
                {
                    $comment = $ast.GetHelpContent()
                    if ($comment.Synopsis)
                    {
                        wrgb " - " -FC "DarkGray"
                        wrgb $comment.Synopsis -FC "Gray"
                    }
                }
                Write-Host ""
            }
        }
    }

    # Переменные модуля
    wrgb "`n📊 Переменные модуля:" -FC "Cyan" -Style Bold -newline
    $moduleVariables = & $module {
        Get-Variable -Scope Script
    }

    $moduleVariables | Select-Object -First 10 | ForEach-Object {
        wrgb "  • " -FC "DarkGray"
        wrgb "`$$( $_.Name )" -FC "Material_Green"
        wrgb " = " -FC "Gray"

        $value = if ($_.Value -is [string] -and $_.Value.Length -gt 50)
        {
            $_.Value.Substring(0, 50) + "..."
        }
        else
        {
            $_.Value
        }

        wrgb $value -FC "White" -newline
    }

    # Создаем диаграмму зависимостей
    if ($ExportDiagram)
    {
        Export-ModuleDiagram -Module $module
    }
}

function Invoke-HiddenCommand
{
    <#
    .SYNOPSIS
        Вызывает скрытую/приватную команду из модуля

    .DESCRIPTION
        Позволяет выполнить недокументированные или приватные функции модуля
    #>
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName,

        [Parameter(Mandatory)]
        [string]$CommandName,

        [Parameter(ValueFromRemainingArguments)]
        $Arguments
    )

    $module = Get-Module $ModuleName -ErrorAction Stop

    # Выполняем команду в контексте модуля
    & $module $CommandName @Arguments
}

#endregion

#region Система мониторинга команд

$script:CommandMonitor = @{
    Enabled = $false
    History = @()
    Statistics = @{
    }
}

function Start-CommandMonitor
{
    <#
    .SYNOPSIS
        Запускает мониторинг всех выполняемых команд
    #>
    param(
        [switch]$TrackParameters,
        [switch]$TrackPerformance,
        [switch]$TrackErrors,
        [switch]$ShowLiveStats
    )

    $script:CommandMonitor.Enabled = $true

    # Устанавливаем обработчик PreCommandLookupAction
    $ExecutionContext.InvokeCommand.PreCommandLookupAction = {
        param($CommandName, $CommandLookupEventArgs)

        if ($script:CommandMonitor.Enabled)
        {
            $entry = @{
                Command = $CommandName
                Time = Get-Date
                SessionId = [Guid]::NewGuid()
            }

            $script:CommandMonitor.History += $entry

            # Обновляем статистику
            if (-not $script:CommandMonitor.Statistics.ContainsKey($CommandName)) {
            $script:CommandMonitor.Statistics[$CommandName] = @{
            Count = 0
            TotalTime = [TimeSpan]::Zero
            Errors = 0
            }
            }

            $script:CommandMonitor.Statistics[$CommandName].Count++

            if ($ShowLiveStats) {
            Write-Host "→ $CommandName" -ForegroundColor DarkGray
            }
        }
    }

    Write-Status -Success "Мониторинг команд запущен"
}

function Stop-CommandMonitor
{
    $script:CommandMonitor.Enabled = $false
    $ExecutionContext.InvokeCommand.PreCommandLookupAction = $null
    Write-Status -Info "Мониторинг команд остановлен"
}

function Show-CommandStatistics
{
    <#
    .SYNOPSIS
        Показывает статистику использования команд
    #>
    param(
        [switch]$Top10,
        [switch]$GroupByVerb,
        [switch]$ShowGraph
    )

    if ($script:CommandMonitor.Statistics.Count -eq 0)
    {
        Write-Status -Warning "Нет данных статистики"
        return
    }

    Write-GradientHeader -Title "COMMAND USAGE STATISTICS"

    $stats = $script:CommandMonitor.Statistics.GetEnumerator() |
    Sort-Object {
    $_.Value.Count
    } -Descending

    if ($Top10) {
    $stats = $stats | Select-Object -First 10
    }

    wrgb "📊 Топ используемых команд:" -FC "Cyan" -Style Bold -newline

    $maxCount = ($stats | Measure-Object {
    $_.Value.Count
    } -Maximum).Maximum

    foreach ($stat in $stats) {
    $percentage = ($stat.Value.Count / $maxCount) * 100
    $barLength = [Math]::Round($percentage / 5)

    wrgb ("  " + $stat.Key.PadRight(30)) -FC "Material_Yellow"

    # График
    for ($i = 0; $i -lt $barLength; $i++) {
    wrgb "█" -FC (Get-ProgressGradientColor -Percent $percentage)
    }

    wrgb " $($stat.Value.Count)" -FC "White" -Style Bold -newline
    }

    if ($GroupByVerb) {
    wrgb "`n📈 По глаголам:" -FC "Cyan" -Style Bold -newline

    $verbStats = $stats | ForEach-Object {
    $verb = ($_.Key -split '-')[0]
    @{
    Verb = $verb; Count = $_.Value.Count
    }
    } | Group-Object Verb | ForEach-Object {
    @{
    Verb = $_.Name
    Total = ($_.Group | Measure-Object Count -Sum).Sum
    }
    } | Sort-Object Total -Descending

    $verbStats | ForEach-Object {
    wrgb "  $($_.Verb): " -FC "Material_Purple"
    wrgb $_.Total -FC "Yellow" -Style Bold -newline
    }
    }
}

#endregion

#region Финальная демонстрация

function Show-UltimateProxyDemo
{
    Clear-Host

    "🧙‍♂️ ULTIMATE PROXY MAGIC DEMO 🧙‍♂️" | Write-Rainbow -Mode Gradient -Style Neon -Animated

    wrgb "`nДобро пожаловать в мир глубокой магии PowerShell!" -FC "GoldRGB" -Style Bold -newline

    $demos = @(
        @{
            Name = "🎯 Smart Help System"
            Desc = "Умная справка с AI-подсказками"
            Command = "Get-SmartHelp Get-Process -ShowSimilar -GenerateExamples"
        },
        @{
            Name = "🔍 Module Internals Explorer"
            Desc = "Исследование внутренностей модулей"
            Command = "Get-ModuleInternals Microsoft.PowerShell.Management -ShowHidden"
        },
        @{
            Name = "📊 Command Monitor"
            Desc = "Мониторинг использования команд"
            Command = "Start-CommandMonitor -ShowLiveStats; Get-Process; Stop-CommandMonitor; Show-CommandStatistics"
        },
        @{
            Name = "🚀 Universal Interceptor"
            Desc = "Перехват ВСЕХ команд"
            Command = "Enable-UniversalCommandInterceptor -LogCalls -MeasurePerformance"
        }
    )

    wrgb "`n🎪 Выберите демонстрацию:" -FC "Cyan" -Style Bold -newline

    for ($i = 0; $i -lt $demos.Count; $i++) {
        $color = Get-MenuGradientColor -Index $i -Total $demos.Count -Style Ocean
        wrgb "  [$( $i + 1 )] " -FC "White"
        wrgb $demos[$i].Name -FC $color -Style Bold
        wrgb " - " -FC "DarkGray"ку
        wrgb $demos[$i].Desc -FC "Gray" -newline
        wrgb "      Команда: " -FC "DarkGray"
        wrgb $demos[$i].Command -FC "Material_Comment" -newline
    }

    wrgb "`n🔑 Ключевая техника:" -FC "Red" -Style Bold -newline
    wrgb "  Microsoft.PowerShell.Core\Command" -FC "Material_Yellow" -BC "#1E1E1E" -Style Bold -newline
    wrgb "  Позволяет вызывать оригинальные команды напрямую!" -FC "Gray" -newline

    wrgb "`n💡 Это открывает возможности:" -FC "Material_Orange" -Style Bold -newline
    wrgb "  • Перехват и модификация ЛЮБЫХ команд" -FC "White" -newline
    wrgb "  • Доступ к скрытым функциям модулей" -FC "White" -newline
    wrgb "  • Создание умных оберток с сохранением совместимости" -FC "White" -newline
    wrgb "  • Мониторинг и анализ использования" -FC "White" -newline
    wrgb "  • Добавление AI-подобных возможностей" -FC "White" -newline

    wrgb "`nПопробуйте любую команду из списка!" -FC "LimeGreen" -Style Bold -newline
}

#endregion

# Инициализация
wrgb "`n🧙‍♂️ " -FC "GoldRGB"
Write-GradientText "Ultimate Proxy Magic" -StartColor "#9400D3" -EndColor "#FF1493" -NoNewline
wrgb " загружена!" -FC "Material_LightGreen" -newline

wrgb "Запустите: " -FC "Gray"
wrgb "Show-UltimateProxyDemo" -FC "Material_Pink" -Style Bold
wrgb " для полной демонстрации магии!" -FC "Gray" -newline

# Экспорт
if ($MyInvocation.MyCommand.Path -match '\.psm1$')
{
    Export-ModuleMember -Function * -Alias * -Variable *
}







# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    💼 PRACTICAL PROXY EXAMPLES                              ║
# ║                   Реальные применения proxy техники                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

#region Безопасный Remove-Item с корзиной

function Remove-Item
{
    <#
    .SYNOPSIS
        Безопасная версия Remove-Item с корзиной и подтверждением

    .DESCRIPTION
        Перехватывает Remove-Item и добавляет:
        - Перемещение в корзину вместо удаления
        - Визуальное подтверждение
        - Логирование удалений
        - Возможность восстановления
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param()

    dynamicparam {
        # Получаем параметры оригинальной команды
        $wrappedCmd = Get-Command Remove-Item -Module Microsoft.PowerShell.Management
        $metadata = [System.Management.Automation.CommandMetadata]::new($wrappedCmd)

        # Создаем динамические параметры
        $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

        foreach ($param in $metadata.Parameters.Values)
        {
            $dynParam = [System.Management.Automation.RuntimeDefinedParameter]::new(
                    $param.Name,
                    $param.ParameterType,
                    $param.Attributes
            )
            $paramDictionary.Add($param.Name, $dynParam)
        }

        # Добавляем наши параметры
        $trashParam = [System.Management.Automation.RuntimeDefinedParameter]::new(
                'UseTrash',
                [switch],
                [System.Management.Automation.ParameterAttribute]@{
                    HelpMessage = 'Переместить в корзину вместо удаления'
                }
        )
        $paramDictionary.Add('UseTrash', $trashParam)

        $skipConfirmParam = [System.Management.Automation.RuntimeDefinedParameter]::new(
                'SkipSafetyCheck',
                [switch],
                [System.Management.Automation.ParameterAttribute]@{
                    HelpMessage = 'Пропустить проверку безопасности'
                }
        )
        $paramDictionary.Add('SkipSafetyCheck', $skipConfirmParam)

        return $paramDictionary
    }

    begin {
        # Путь к корзине
        $trashPath = "$env:USERPROFILE\.PowerShellTrash"
        if (-not (Test-Path $trashPath))
        {
            New-Item -Path $trashPath -ItemType Directory -Force | Out-Null
        }

        # Получаем значения наших параметров
        $useTrash = $PSBoundParameters['UseTrash']
        $skipSafety = $PSBoundParameters['SkipSafetyCheck']

        # Убираем наши параметры перед передачей в оригинальную команду
        $PSBoundParameters.Remove('UseTrash') | Out-Null
        $PSBoundParameters.Remove('SkipSafetyCheck') | Out-Null
    }

    process {
        # Получаем элементы для удаления
        $items = @()
        if ( $PSBoundParameters.ContainsKey('Path'))
        {
            $items = Get-Item -Path $PSBoundParameters['Path'] -ErrorAction SilentlyContinue
        }
        elseif ($PSBoundParameters.ContainsKey('LiteralPath'))
        {
            $items = Get-Item -LiteralPath $PSBoundParameters['LiteralPath'] -ErrorAction SilentlyContinue
        }

        if (-not $skipSafety -and $items)
        {
            # Показываем что будет удалено
            wrgb "`n⚠️  ВНИМАНИЕ: Будут удалены следующие элементы:" -FC "Yellow" -Style Bold -newline

            foreach ($item in $items)
            {
                $icon = if ($item.PSIsContainer)
                {
                    "📁"
                }
                else
                {
                    "📄"
                }
                $size = if (-not $item.PSIsContainer)
                {
                    " ({0:N2} MB)" -f ($item.Length / 1MB)
                }
                else
                {
                    $count = (Get-ChildItem $item -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
                    " ($count элементов)"
                }

                wrgb "  $icon " -FC "Red"
                wrgb $item.Name -FC "White" -Style Bold
                wrgb $size -FC "DarkGray"
                wrgb " - " -FC "DarkGray"
                wrgb $item.FullName -FC "Gray" -newline
            }

            wrgb "`n" -newline
            $useTrashText = if ($useTrash)
            {
                "(в корзину)"
            }
            else
            {
                "(БЕЗВОЗВРАТНО)"
            }
            wrgb "Удалить " -FC "White"
            wrgb $items.Count -FC "Red" -Style Bold
            wrgb " элемент(ов) " -FC "White"
            wrgb $useTrashText -FC $( if ($useTrash)
            {
                "Yellow"
            }
            else
            {
                "Red"
            } ) -Style Bold
            wrgb "? [Y/N]: " -FC "White"

            $confirmation = Read-Host
            if ($confirmation -ne 'Y')
            {
                Write-Status -Warning "Операция отменена"
                return
            }
        }

        # Выполняем удаление
        foreach ($item in $items)
        {
            try
            {
                if ($useTrash)
                {
                    # Перемещаем в корзину
                    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                    $trashName = "$timestamp`_$( $item.Name )"
                    $trashItemPath = Join-Path $trashPath $trashName

                    # Сохраняем метаданные
                    $metadata = @{
                        OriginalPath = $item.FullName
                        DeletedDate = Get-Date
                        Size = if (-not $item.PSIsContainer)
                        {
                            $item.Length
                        }
                        else
                        {
                            0
                        }
                    }

                    $metadataPath = "$trashItemPath.metadata"
                    $metadata | ConvertTo-Json | Out-File $metadataPath

                    # Перемещаем
                    Move-Item -Path $item.FullName -Destination $trashItemPath -Force

                    wrgb "  ♻️ " -FC "Green"
                    wrgb "Перемещено в корзину: " -FC "Green"
                    wrgb $item.Name -FC "White" -newline
                }
                else
                {
                    # Обычное удаление через оригинальную команду
                    Microsoft.PowerShell.Management\Remove-Item -Path $item.FullName @PSBoundParameters

                    wrgb "  ❌ " -FC "Red"
                    wrgb "Удалено: " -FC "Red"
                    wrgb $item.Name -FC "White" -newline
                }

                # Логируем
                $logEntry = @{
                    Action = if ($useTrash)
                    {
                        "Moved to Trash"
                    }
                    else
                    {
                        "Deleted"
                    }
                    Item = $item.FullName
                    Date = Get-Date
                    User = $env:USERNAME
                }

                $logPath = "$env:TEMP\PowerShell_RemoveItem.log"
                $logEntry | ConvertTo-Json -Compress | Add-Content $logPath

            }
            catch
            {
                Write-Status -Error "Ошибка при удалении $( $item.Name ): $_"
            }
        }
    }
}

function Restore-Item
{
    <#
    .SYNOPSIS
        Восстанавливает элементы из PowerShell корзины
    #>
    param(
        [string]$Name,
        [switch]$Latest,
        [switch]$ShowTrash
    )

    $trashPath = "$env:USERPROFILE\.PowerShellTrash"

    if ($ShowTrash)
    {
        Write-GradientHeader -Title "POWERSHELL TRASH"

        $trashItems = Get-ChildItem $trashPath -Filter "*.metadata" | ForEach-Object {
            $metadata = Get-Content $_.FullName | ConvertFrom-Json
            $itemPath = $_.FullName -replace '\.metadata$', ''

            [PSCustomObject]@{
                Name = Split-Path $metadata.OriginalPath -Leaf
                OriginalPath = $metadata.OriginalPath
                DeletedDate = [datetime]$metadata.DeletedDate
                Size = $metadata.Size
                TrashPath = $itemPath
                Exists = Test-Path $itemPath
            }
        } | Sort-Object DeletedDate -Descending

        if ($trashItems)
        {
            $trashItems | ForEach-Object {
                wrgb "📄 " -FC $( if ($_.Exists)
                {
                    "Green"
                }
                else
                {
                    "Red"
                } )
                wrgb $_.Name -FC "White" -Style Bold
                wrgb " (удалено: " -FC "DarkGray"
                wrgb $_.DeletedDate.ToString("yyyy-MM-dd HH:mm") -FC "Yellow"
                wrgb ")" -FC "DarkGray" -newline
                wrgb "   Оригинальный путь: " -FC "Gray"
                wrgb $_.OriginalPath -FC "Cyan" -newline
            }
        }
        else
        {
            Write-Status -Info "Корзина пуста"
        }

        return
    }

    # Логика восстановления...
    Write-Status -Info "Функция восстановления в разработке"
}

#endregion

#region Умный Invoke-WebRequest с прогрессом и retry

function Invoke-WebRequest
{
    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=217035')]
    param()

    dynamicparam {
        # Копируем параметры оригинальной команды
        $wrappedCmd = Get-Command Invoke-WebRequest -Module Microsoft.PowerShell.Utility
        $metadata = [System.Management.Automation.CommandMetadata]::new($wrappedCmd)
        $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

        foreach ($param in $metadata.Parameters.Values)
        {
            $dynParam = [System.Management.Automation.RuntimeDefinedParameter]::new(
                    $param.Name,
                    $param.ParameterType,
                    $param.Attributes
            )
            $paramDictionary.Add($param.Name, $dynParam)
        }

        # Добавляем улучшения
        $retryParam = [System.Management.Automation.RuntimeDefinedParameter]::new(
                'RetryCount',
                [int],
                [System.Management.Automation.ParameterAttribute]@{
                    HelpMessage = 'Количество повторных попыток'
                }
        )
        $paramDictionary.Add('RetryCount', $retryParam)

        $progressParam = [System.Management.Automation.RuntimeDefinedParameter]::new(
                'ShowProgress',
                [switch],
                [System.Management.Automation.ParameterAttribute]@{
                    HelpMessage = 'Показывать красивый прогресс'
                }
        )
        $paramDictionary.Add('ShowProgress', $progressParam)

        return $paramDictionary
    }

    process {
        $retryCount = $PSBoundParameters['RetryCount'] ?? 0
        $showProgress = $PSBoundParameters['ShowProgress'] ?? $false

        # Убираем наши параметры
        $PSBoundParameters.Remove('RetryCount') | Out-Null
        $PSBoundParameters.Remove('ShowProgress') | Out-Null

        $uri = $PSBoundParameters['Uri']
        $attempt = 0
        $success = $false

        while ($attempt -le $retryCount -and -not $success)
        {
            try
            {
                if ($attempt -gt 0)
                {
                    wrgb "🔄 Попытка " -FC "Yellow"
                    wrgb "$attempt/$retryCount" -FC "White" -Style Bold
                    wrgb " для " -FC "Yellow"
                    wrgb $uri -FC "Cyan" -newline
                }

                if ($showProgress -and $PSBoundParameters.ContainsKey('OutFile'))
                {
                    # Добавляем обработчик прогресса
                    $progressPreference = $global:ProgressPreference
                    $global:ProgressPreference = 'SilentlyContinue'

                    $response = Microsoft.PowerShell.Utility\Invoke-WebRequest @PSBoundParameters -PassThru

                    # Показываем наш красивый прогресс
                    if ($response.Headers['Content-Length'])
                    {
                        $totalSize = [int64]$response.Headers['Content-Length'][0]
                        wrgb "📥 Загрузка: " -FC "Cyan"
                        wrgb ($totalSize / 1MB).ToString("F2") + " MB" -FC "Yellow" -newline
                    }

                    $global:ProgressPreference = $progressPreference
                    return $response
                }
                else
                {
                    # Обычный вызов
                    return Microsoft.PowerShell.Utility\Invoke-WebRequest @PSBoundParameters
                }

                $success = $true

            }
            catch
            {
                $attempt++

                if ($attempt -gt $retryCount)
                {
                    Write-Status -Error "Не удалось после $retryCount попыток: $_"
                    throw
                }
                else
                {
                    Write-Status -Warning "Ошибка: $_. Повтор через 2 секунды..."
                    Start-Sleep -Seconds 2
                }
            }
        }
    }
}

#endregion

#region Git команды с визуализацией

function git
{
    <#
    .SYNOPSIS
        Улучшенный git с цветным выводом и визуализацией
    #>
    param(
        [Parameter(Position = 0)]
        [string]$Command,

        [Parameter(Position = 1, ValueFromRemainingArguments)]
        [string[]]$Arguments
    )

    # Специальная обработка для некоторых команд
    switch ($Command)
    {
        'status' {
            Write-GradientHeader -Title "GIT STATUS" -StartColor "#F05033" -EndColor "#F79500"

            $output = & git.exe status --porcelain = v1 2> $null

            if (-not $output)
            {
                Write-Status -Success "Рабочая директория чиста"
            }
            else
            {
                $stats = @{
                    Modified = 0
                    Added = 0
                    Deleted = 0
                    Untracked = 0
                }

                foreach ($line in $output)
                {
                    $status = $line.Substring(0, 2)
                    $file = $line.Substring(3)

                    switch -Wildcard ($status)
                    {
                        '*M*' {
                            wrgb "  📝 " -FC "Yellow"
                            wrgb "изменен:   " -FC "Yellow"
                            wrgb $file -FC "White" -newline
                            $stats.Modified++
                        }
                        '*A*' {
                            wrgb "  ✅ " -FC "Green"
                            wrgb "добавлен:  " -FC "Green"
                            wrgb $file -FC "White" -newline
                            $stats.Added++
                        }
                        '*D*' {
                            wrgb "  ❌ " -FC "Red"
                            wrgb "удален:    " -FC "Red"
                            wrgb $file -FC "White" -newline
                            $stats.Deleted++
                        }
                        '??' {
                            wrgb "  ❓ " -FC "Magenta"
                            wrgb "не отслеж: " -FC "Magenta"
                            wrgb $file -FC "White" -newline
                            $stats.Untracked++
                        }
                    }
                }

                # Сводка
                wrgb "`n📊 Сводка: " -FC "Cyan"
                if ($stats.Modified -gt 0)
                {
                    wrgb "изменено: $( $stats.Modified ) " -FC "Yellow"
                }
                if ($stats.Added -gt 0)
                {
                    wrgb "добавлено: $( $stats.Added ) " -FC "Green"
                }
                if ($stats.Deleted -gt 0)
                {
                    wrgb "удалено: $( $stats.Deleted ) " -FC "Red"
                }
                if ($stats.Untracked -gt 0)
                {
                    wrgb "не отслеживается: $( $stats.Untracked ) " -FC "Magenta"
                }
                Write-Host ""
            }
        }

        'log' {
            # Красивый лог с графом
            & git.exe log --graph --pretty = format: '%C(auto)%h%d %s %C(black)%C(bold)%cr' --abbrev-commit @Arguments
        }

        'branch' {
            Write-GradientHeader -Title "GIT BRANCHES" -StartColor "#F05033" -EndColor "#F79500"

            $branches = & git.exe branch -a 2> $null

            foreach ($branch in $branches)
            {
                if ($branch -match '^\*')
                {
                    wrgb "  ➜ " -FC "Green" -Style Bold
                    wrgb $branch.Substring(2) -FC "Green" -Style Bold -newline
                }
                elseif ($branch -match 'remotes/')
                {
                    wrgb "  ☁️  " -FC "Blue"
                    wrgb $branch.Trim() -FC "Blue" -newline
                }
                else
                {
                    wrgb "  📌 " -FC "White"
                    wrgb $branch.Trim() -FC "White" -newline
                }
            }
        }

        default {
            # Для остальных команд - обычный вызов
            & git.exe $Command @Arguments
        }
    }
}

#endregion

#region Система алиасов с подсказками

function Set-Alias
{
    <#
    .SYNOPSIS
        Улучшенный Set-Alias с автодополнением и подсказками
    #>
    [CmdletBinding()]
    param()

    dynamicparam {
        $wrappedCmd = Get-Command Set-Alias -Module Microsoft.PowerShell.Utility
        $metadata = [System.Management.Automation.CommandMetadata]::new($wrappedCmd)
        $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

        foreach ($param in $metadata.Parameters.Values)
        {
            $dynParam = [System.Management.Automation.RuntimeDefinedParameter]::new(
                    $param.Name,
                    $param.ParameterType,
                    $param.Attributes
            )
            $paramDictionary.Add($param.Name, $dynParam)
        }

        # Добавляем функцию автодополнения
        $autoCompleteParam = [System.Management.Automation.RuntimeDefinedParameter]::new(
                'EnableAutoComplete',
                [switch],
                [System.Management.Automation.ParameterAttribute]@{
                    HelpMessage = 'Включить автодополнение для алиаса'
                }
        )
        $paramDictionary.Add('EnableAutoComplete', $autoCompleteParam)

        return $paramDictionary
    }

    process {
        $enableAutoComplete = $PSBoundParameters['EnableAutoComplete']
        $PSBoundParameters.Remove('EnableAutoComplete') | Out-Null

        # Вызываем оригинальную команду
        Microsoft.PowerShell.Utility\Set-Alias @PSBoundParameters

        # Если включено автодополнение
        if ($enableAutoComplete)
        {
            $aliasName = $PSBoundParameters['Name']
            $targetCommand = $PSBoundParameters['Value']

            # Регистрируем автодополнение
            Register-ArgumentCompleter -CommandName $aliasName -ScriptBlock {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

                # Получаем параметры целевой команды
                $targetCmd = Get-Command $using:targetCommand -ErrorAction SilentlyContinue
                if ($targetCmd)
                {
                    $targetCmd.Parameters.Keys | Where-Object {
                        $_ -like "$wordToComplete*"
                    } | ForEach-Object {
                        [System.Management.Automation.CompletionResult]::new(
                                "-$_",
                                "-$_",
                                'ParameterName',
                                "Parameter: $_"
                        )
                    }
                }
            }

            Write-Status -Success "Алиас '$aliasName' создан с автодополнением"
        }
    }
}

#endregion

#region Финальная демонстрация практических примеров

function Show-PracticalProxyExamples
{
#    Clear-Host

    Write-GradientHeader -Title "PRACTICAL PROXY EXAMPLES" -StartColor "#00C851" -EndColor "#00FF00"

    wrgb "💼 Практические применения proxy техники" -FC "GoldRGB" -Style Bold -newline

    wrgb "`n1️⃣ " -FC "Cyan"
    wrgb "Безопасный Remove-Item" -FC "Yellow" -Style Bold
    wrgb " с корзиной:" -FC "White" -newline
    wrgb "   Remove-Item test.txt -UseTrash" -FC "Material_Comment" -newline
    wrgb "   • Перемещает в корзину вместо удаления" -FC "Gray" -newline
    wrgb "   • Визуальное подтверждение" -FC "Gray" -newline
    wrgb "   • Возможность восстановления" -FC "Gray" -newline

    wrgb "`n2️⃣ " -FC "Cyan"
    wrgb "Умный Invoke-WebRequest" -FC "Yellow" -Style Bold
    wrgb " с retry:" -FC "White" -newline
    wrgb "   Invoke-WebRequest https://example.com -RetryCount 3 -ShowProgress" -FC "Material_Comment" -newline
    wrgb "   • Автоматические повторные попытки" -FC "Gray" -newline
    wrgb "   • Красивый прогресс загрузки" -FC "Gray" -newline

    wrgb "`n3️⃣ " -FC "Cyan"
    wrgb "Git с визуализацией" -FC "Yellow" -Style Bold
    wrgb ":" -FC "White" -newline
    wrgb "   git status" -FC "Material_Comment" -newline
    wrgb "   • Цветной вывод с иконками" -FC "Gray" -newline
    wrgb "   • Статистика изменений" -FC "Gray" -newline

    wrgb "`n4️⃣ " -FC "Cyan"
    wrgb "Set-Alias с автодополнением" -FC "Yellow" -Style Bold
    wrgb ":" -FC "White" -newline
    wrgb "   Set-Alias gs Get-Service -EnableAutoComplete" -FC "Material_Comment" -newline
    wrgb "   • Автодополнение параметров для алиасов" -FC "Gray" -newline

    wrgb "`n🔑 Ключевые преимущества:" -FC "Material_Orange" -Style Bold -newline
    wrgb "   ✓ Полная обратная совместимость" -FC "LimeGreen" -newline
    wrgb "   ✓ Расширение функциональности" -FC "LimeGreen" -newline
    wrgb "   ✓ Сохранение оригинального поведения" -FC "LimeGreen" -newline
    wrgb "   ✓ Добавление безопасности" -FC "LimeGreen" -newline

    wrgb "`n💡 Попробуйте сами эти команды!" -FC "GoldRGB" -Style Bold -newline
}

#endregion

# Инициализация
wrgb "`n💼 " -FC "GoldRGB"
Write-GradientText "Practical Proxy Examples" -StartColor "#00C851" -EndColor "#00FF00" -NoNewline
wrgb " загружены!" -FC "Material_LightGreen" -newline

wrgb "Запустите: " -FC "Gray"
wrgb "Show-PracticalProxyExamples" -FC "Material_Pink" -Style Bold
wrgb " для демонстрации" -FC "Gray" -newline

# Экспорт
if ($MyInvocation.MyCommand.Path -match '\.psm1$')
{
    Export-ModuleMember -Function * -Alias * -Variable *
}

Show-PracticalProxyExamples
importProcess  $MyInvocation.MyCommand.Name.trim('.ps1')
