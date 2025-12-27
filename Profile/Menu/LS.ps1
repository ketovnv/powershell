Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

function Get-FormattedFileSize
{
    <#
    .SYNOPSIS
    Форматирует размер файла с градиентным цветом
    #>
    param(
        [long]$Size,
        [switch]$ColorOnly
    )

    # Определение цвета на основе размера
    $color = if ($Size -eq 0)
    {
        '#222222'
    }
    elseif ($Size -lt 100)
    {
        "#7799AA"
    }
    elseif ($Size -lt 1KB)
    {
        # Градиент от зеленого к желтому
        $percent = [Math]::Min($Size / 1KB, 1)
        $r = [int](255 * $percent)
        $g = [int](255 * (1 - $percent * 0.55))
        $b = [int](255 * $percent * 0.55)
        ConvertFrom-RGBToHex -R $r -G $g -B $b
    }
    elseif ($Size -lt 100MB)
    {
        # Градиент от желтого к оранжевому
        $k = 0.2
        $_red = [math]::Round(255 * [math]::Pow($item.Length / 1GB, $k))
        $_blue = (255 - $_red) / 1.33
        $_green = $_blue / 1.5
        if ($item.Length -lt 99999)
        {
            $_green = 200 - [math]::Round(255 *  $item.Length / 99999)
            $_red = [math]::Round(255 *  $item.Length / 220KB)
        }
        $red = nthp $_red
        $green = nthp $_green
        $blue = nthp $_blue
        "#${red}${green}${blue}"
    }
    elseif ($Size -lt 1GB)
    {
        # Градиент от оранжевого к красному
        $percent = [Math]::Min(($Size - 100MB) / 900MB, 1)
        $r = 255
        $g = [int](155 - 155 * $percent)
        $b = 0
        ConvertFrom-RGBToHex -R $r -G $g -B $b
    }
    else
    {
        '#FF0000'
    }

    if ($ColorOnly)
    {
        return $color
    }

    # Форматирование размера
    $formatted = if ($Size -eq 0)
    {
        "     0 B  "
    }
    elseif ($Size -lt 1KB)
    {
        "{0,6} B  " -f $Size
    }
    elseif ($Size -lt 1MB)
    {
        "{0,6:N1} KB" -f ($Size / 1KB)
    }
    elseif ($Size -lt 1GB)
    {
        "{0,6:N1} MB" -f ($Size / 1MB)
    }
    elseif ($Size -lt 1TB)
    {
        "{0,6:N1} GB" -f ($Size / 1GB)
    }
    else
    {
        "{0,6:N1} TB" -f ($Size / 1TB)
    }

    return @{
        Text = $formatted
        Color = $color
    }
}

function Get-FormattedDate
{
    <#
    .SYNOPSIS
    Форматирует дату с учетом давности
    #>
    param(
        [DateTime]$Date,
        [switch]$Detailed
    )

    $age = (Get-Date) - $Date

    # Цвет в зависимости от возраста
    $color = if ($age.TotalDays -lt 1)
    {
        '#00FF00'  # Ярко-зеленый для новых
    }
    elseif ($age.TotalDays -lt 7)
    {
        '#88FF88'  # Зеленый для недельных
    }
    elseif ($age.TotalDays -lt 30)
    {
        '#FFFF88'  # Желтый для месячных
    }
        elseif ($age.TotalDays -lt 90)
    {
        '#998800'  # Тёмно Желтый для 3 мес
    }
    elseif ($age.TotalDays -lt 365)
    {
        '#998888'  # Оранжевый для годовых
    }
    else
    {
        '#888888'  # Серый для старых
    }

    # Форматирование
    $formatted = if ($age.TotalDays -lt 1)
    {
        if ($age.TotalHours -lt 1)
        {
            "{0,3}m ago" -f [int]$age.TotalMinutes
        }
        else
        {
            "{0,3}h ago" -f [int]$age.TotalHours
        }
    }
    elseif ($age.TotalDays -lt 7)
    {
        "{0,3}d ago" -f [int]$age.TotalDays
    }
    elseif ($age.TotalDays -lt 30)
    {
        $Date.ToString("dd MMM")
    }
    elseif ($age.TotalDays -lt 365)
    {
        $Date.ToString("dd MMM")
    }
    else
    {
        $Date.ToString("MMM yyyy")
    }

    return @{
        Text = $formatted.trim("  .0")
        Color = $color
    }
}

function Show-DirectoryListing
{
    <#
    .SYNOPSIS
    Отображает содержимое директории с расширенным форматированием

    .PARAMETER Path
    Путь к директории

    .PARAMETER ShowHidden
    Показывать скрытые файлы

    .PARAMETER SortBy
    Критерий сортировки: Name, Size, Date, Type

    .PARAMETER GroupBy
    Группировка: None, Type, Extension, Date

    .PARAMETER Filter
    Фильтр файлов

    .PARAMETER Recurse
    Рекурсивный просмотр

    .PARAMETER MaxDepth
    Максимальная глубина рекурсии

    .PARAMETER GradientStyle
    Стиль градиента для заголовка
    #>
    [CmdletBinding()]
    param(
        [string]$Path = ".",

        [switch]$ShowHidden,

        [ValidateSet('Name', 'Size', 'Date', 'Type', 'Extension')]
        [string]$SortBy = 'Type',

        [ValidateSet('None', 'Type', 'Extension', 'Date', 'Size')]
        [string]$GroupBy = 'None',

        [string]$Filter = '*',

        [switch]$Recurse,

        [int]$MaxDepth = 3,

        [ValidateSet('Ocean', 'Fire', 'Nature', 'Neon', 'Ukraine', 'Custom')]
        [string]$GradientStyle = 'Ocean',

        [hashtable]$CustomGradient = @{
        Start = '#8B00FF'
        End = '#00BFFF'
    }
    )

    # Получение полного пути
    $fullPath = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
    if (-not $fullPath)
    {
        wrgb "Путь не найден: $Path" -FC Red
        return
    }

    # Заголовок с градиентом
    $headerGradient = switch ($GradientStyle)
    {
        'Ocean' {
            @{ Start = '#0080FF'; End = '#00FFD4' }
        }
        'Fire' {
            @{ Start = '#FF0000'; End = '#FFD700' }
        }
        'Nature' {
            @{ Start = '#00FF00'; End = '#90EE90' }
        }
        'Neon' {
            @{ Start = '#FF00FF'; End = '#00FFFF' }
        }
        'Ukraine' {
            @{ Start = '#0057B7'; End = '#FFD500' }
        }
        'Custom' {
            $CustomGradient
        }
    }

    # Отображение заголовка
    wrgb "`n"
    wrgb "📁 "
    Write-GradientText "Directory: $fullPath" `
        -StartColor $headerGradient.Start `
        -EndColor $headerGradient.End

    Write-GradientLine -Length 80 -Char "─" `
        -StartColor $headerGradient.Start `
        -EndColor $headerGradient.End

    # Получение элементов
    $items = Get-ChildItem -Path $fullPath -Filter $Filter -Force:$ShowHidden -ErrorAction SilentlyContinue

    if (-not $items)
    {
        wrgb "  Директория пуста" -FC DarkGray
        Write-GradientLine -Length 80 -Char "─" `
            -StartColor $headerGradient.End`
            -StartColor $headerGradient.Start
        return
    }

    # Сортировка
    $sorted = switch ($SortBy)
    {
        'Name' {
            $items | Sort-Object Name
        }
        'Size' {
            $items | Sort-Object Length -Descending
        }
        'Date' {
            $items | Sort-Object LastWriteTime -Descending
        }
        'Type' {
            $items | Sort-Object `
            @{ Expression = 'PSIsContainer'; Descending = $true }, `
                 Extension, `
                 Name
        }
        'Extension' {
            $items | Sort-Object @{
                Expression = { if ( [string]::IsNullOrEmpty($_.Extension))
                {
                    "XXX"
                }
                else
                {
                    $_.Extension
                } }
            }, Name
        }

        default {
            $items | Sort-Object Name
        }

    }

    # Группировка
    if ($GroupBy -ne 'None')
    {
        $groups = switch ($GroupBy)
        {
            'Type' {
                $sorted | Group-Object { if ($_.PSIsContainer)
                {
                    "Directories"
                }
                else
                {
                    "Files"
                } }
            }
            'Extension' {
                $sorted | Group-Object {
                    if ($_.PSIsContainer)
                    {
                        "📁 Folders"
                    }
                    else
                    {
                        $ext = $_.Extension
                        if ( [string]::IsNullOrEmpty($ext))
                        {
                            "📄 No Extension"
                        }
                        else
                        {
                            "$ext Files"
                        }
                    }
                }
            }
            'Date' {
                $sorted | Group-Object { $_.LastWriteTime.Date.ToString("yyyy-MM-dd") }
            }
            'Size' {
                $sorted | Group-Object {
                    if ($_.PSIsContainer)
                    {
                        "📁 Directories"
                    }
                    elseif ($_.Length -eq 0)
                    {
                        "📄 Empty"
                    }
                    elseif ($_.Length -lt 1KB)
                    {
                        "📄 < 1 KB"
                    }
                    elseif ($_.Length -lt 1MB)
                    {
                        "📄 < 1 MB"
                    }
                    elseif ($_.Length -lt 100MB)
                    {
                        "📄 < 100 MB"
                    }
                    elseif ($_.Length -lt 1GB)
                    {
                        "📄 < 1 GB"
                    }
                    else
                    {
                        "📄 > 1 GB"
                    }
                }
            }
        }

        foreach ($group in $groups)
        {
            wrgb "`n  "
            wrgb $group.Name -FC Yellow
            wrgb "  "
            wrgb  ("─" * ($group.Name.Length + 2)) -FC DarkGray -newline

            foreach ($item in $group.Group)
            {
                Format-FileItem -Item $item -Indent "    "
                wrgb "`n  "
            }
        }
    }
    else
    {
        # Обычный вывод
        $index = 0
        foreach ($item in $sorted)
        {
            $color = Get-GradientColor -Index $index -TotalItems $sorted.Count `
                -StartColor $headerGradient.Start -EndColor $headerGradient.End
            Format-FileItem -Item $item -GradientColor $color
            $index++
            wrgb "`n  "
        }
    }

    # Итоговая статистика
    wrgb "`n  "
    Write-GradientLine -Length 80 -Char "─" `
        -StartColor $headerGradient.End `
        -EndColor $headerGradient.Start

    $stats = Get-DirectoryStats -Items $items
    wrgb "  📊 " -FC Yellow
    wrgb "Total: " -FC White
    wrgb "$( $stats.TotalCount ) items " -FC Cyan
    wrgb "(" -FC DarkGray
    wrgb "📁 $( $stats.DirectoryCount )" -FC Blue
    wrgb ", " -FC DarkGray
    wrgb "📄 $( $stats.FileCount )" -FC Green
    wrgb ", 🥷" -FC DarkGray
    wrgb (Get-FormattedFileSize  $stats.TotalSize).Text -FC Magenta
#    wrgb (Get-FormattedFileSize  $stats.TotalSize).Text -FC Magenta
    wrgb ")" -FC DarkGray -newline

    if ($ShowHidden -and $stats.HiddenCount -gt 0)
    {
        wrgb "  👻 Hidden: $( $stats.HiddenCount ) items" -FC DarkGray
    }
}

function Format-FileItem
{
    <#
    .SYNOPSIS
    Форматирует отдельный элемент файловой системы
    #>
    param(
        [Parameter(Mandatory)]
        $Item,

        [string]$Indent = "  ",

        [string]$GradientColor
    )

    wrgb $Indent

    if ($Item.PSIsContainer)
    {
        # Директория
        $icon = "📂"
        $color = Get-DirectoryColor $Item.Name

        # Специальные иконки для известных папок
        $specialIcons = @{
            '.git' = '🔀'
            'node_modules' = '📦'
            '.vscode' = '💻'
            'src' = '💾'
            'dist' = '📤'
            'build' = '🏗️'
            'test' = '🧪'
            'tests' = '🧪'
            'docs' = '📚'
            'images' = '🖼️'
            'videos' = '🎬'
            'music' = '🎵'
            'src-tauri' = '🦀'
        }

        if ( $specialIcons.ContainsKey($Item.Name.ToLower()))
        {
            $icon = $specialIcons[$Item.Name.ToLower()]
        }

        wrgb "$icon "
        wrgb ("{0,-35}" -f $Item.Name) -FC $color
        wrgb " <DIR>" -FC DarkCyan

        # Подсчет элементов в папке (если не слишком большая)
        try
        {
            $subItems = @(Get-ChildItem -Path $Item.FullName -Force -ErrorAction SilentlyContinue)
            if ($subItems.Count -gt 0)
            {
                wrgb "$Indent     "
                wrgb "└─ $( $subItems.Count ) items" -FC DarkGray
            }
        }
        catch
        {
        }
    }
    else
    {
        # Файл
        $icon = Get-FileIcon $Item.Extension
        $nameColor = Get-FileColor $Item.Extension
        $sizeInfo = Get-FormattedFileSize -Size $Item.Length
        $dateInfo = Get-FormattedDate -Date $Item.LastWriteTime

        wrgb "$icon "

        # Имя файла с градиентом
            wrgb ("{0,-42}" -f $Item.Name.PadRight(42).Substring(0, 42))   -FC $nameColor


        # Размер
        wrgb " "
        wrgb ("{0,-10}" -f $sizeInfo.Text) -FC $sizeInfo.Color

        # Дата
        wrgb "  "
        wrgb $dateInfo.Text -FC $dateInfo.Color

        # Дополнительная информация для особых файлов
        if ($Item.Extension -in @('.ps1', '.psm1', '.psd1'))
        {
            try
            {
                $content = Get-Content $Item.FullName -First 10 -ErrorAction SilentlyContinue
                $synopsis = $content | Select-String -Pattern 'SYNOPSIS' -Context 0, 1
                if ($synopsis)
                {
                    $desc = $synopsis.Context.PostContext[0].Trim()
                    if ($desc)
                    {
                        wrgb "$Indent  "
                        wrgb "$desc" -FC Material_Grey
                    }
                }
            }
            catch
            {
            }
        }
    }
}

function Get-DirectoryStats
{
    <#
    .SYNOPSIS
    Получает статистику по директории
    #>
    param($Items)

    $stats = @{
        TotalCount = $Items.Count
        FileCount = ($Items | Where-Object { -not $_.PSIsContainer }).Count
        DirectoryCount = ($Items | Where-Object { $_.PSIsContainer }).Count
        TotalSize = ($Items | Where-Object { -not $_.PSIsContainer } |
                Measure-Object -Property Length -Sum).Sum
        HiddenCount = ($Items | Where-Object { $_.Attributes -band [System.IO.FileAttributes]::Hidden }).Count
    }

    return $stats
}

# Создание алиасов
Set-Alias -Name ls -Value Show-DirectoryListing -Force
Set-Alias -Name ll -Value Show-DirectoryListing -Force
Set-Alias -Name ldd -Value Show-DirectoryListing -Force

# Функция быстрого просмотра
function lss
{
    Show-DirectoryListing @args
}

# Функция для рекурсивного просмотра
function lst
{
    Show-DirectoryListing -Recurse -MaxDepth 2 @args
}

# Функция для просмотра только директорий
function lsd
{
    Get-ChildItem -Directory @args | ForEach-Object {
        $icon = "   📁"
        wrgb  "$icon"
        wrgb $_.Name -FC Cyan
    }
}

# Функция для просмотра с фильтрацией по расширению
function lsf
{
    param(
        [string]$Extension = '*',
        [string]$Path = '.'
    )

    if (-not $Extension.StartsWith('*'))
    {
        $Extension = "*.$Extension"
    }

    Show-DirectoryListing -Path $Path -Filter $Extension
}

Trace-ImportProcess  $MyInvocation.MyCommand.Name.trim(".ps1")
