#📅 Дата и время
function now { Get-Date -Format "dd.MM.yyyy HH:mm:ss" }

function date { Get-Date -Format "dd.MM.yyyy" }#

function dateRu {
    (Get-Date).ToString("dd MMMM yyyy HH часов mm минут ss", [System.Globalization.CultureInfo]::GetCultureInfo("ru-RU"))
}

function dt {
    $months = @{
        1 = "января"; 2 = "февраля"; 3 = "марта"; 4 = "апреля"; 5 = "мая"; 6 = "июня";
        7 = "июля"; 8 = "августа"; 9 = "сентября"; 10 = "октября"; 11 = "ноября"; 12 = "декабря"
    }
    $d = Get-Date
    return "{0:dd} {1} {0:yyyy}" -f $d, $months[$d.Month]
}

function ExternalScripts {
    Get-Command -CommandType externalscript | Get-Item | 
        Select-Object Directory, Name, Length, CreationTime, LastwriteTime,
        @{name = "Signature"; Expression = { (Get-AuthenticodeSignature $_.fullname).Status } }
}

function freeC {
    (gcim win32_logicaldisk -Filter "deviceid = 'C:'").FreeSpace / 1gb
    #or use the PSDrive
    (Get-PSDrive c).Free / 1gb

}

function commandsExample {
debug (Get-Command).where({ $_.source }) | Sort-Object Source, CommandType, Name | Format-Table -GroupBy Source -Property CommandType, Name, @{Name = "Synopsis"; Expression = {(Get-Help $_.name).Synopsis}}
}


function Resolve-Object {
    param(
        [Parameter(ValueFromPipeline = $true)]
        [object]$InputObject,

        [switch]$Methods,
        [switch]$Properties,
        [switch]$Examples
    )

    process {
        $members = $InputObject | Get-Member

        if ($Methods) {
            Write-Host "`n=== МЕТОДЫ ===`n" -ForegroundColor Cyan
            $members | Where-Object { $_.MemberType -eq "Method" } | Format-Table Name, Definition -AutoSize
        }

        if ($Properties) {
            Write-Host "`n=== СВОЙСТВА ===`n" -ForegroundColor Green
            $members | Where-Object { $_.MemberType -eq "Property" } | Format-Table Name, Definition -AutoSize
        }

        if ($Examples -and $Methods) {
            Write-Host "`n=== ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ ===`n" -ForegroundColor Yellow
            $methodsList = $members | Where-Object { $_.MemberType -eq "Method" }

            foreach ($method in $methodsList) {
                $example = switch ($method.Name) {
                    "CopyTo" { '$file.CopyTo("C:\new\path.txt")' }
                    "Delete" { '$file.Delete()' }
                    "ToString" { '$date = Get-Date; $date.ToString("yyyy-MM-dd")' }
                    default { "`$obj.$($method.Name)()" }
                }
                Write-Host ("• " + $example) -ForegroundColor Magenta
            }
        }
    }
}

function Invoke-ObjectExplorer {
    <#
    .SYNOPSIS
        Интерактивный исследователь объектов PowerShell с генерацией кода.
    .EXAMPLE
        Get-Process | Invoke-ObjectExplorer -Depth 2
        [System.IO.FileInfo]::new("C:\test.txt") | Invoke-ObjectExplorer -Interactive
    #>
    param(
        [Parameter(ValueFromPipeline = $true)]
        [object]$InputObject,

        [ValidateRange(1, 5)]
        [int]$Depth = 1,

        [switch]$Interactive,
        [switch]$GenerateCode,
        [string]$Filter
    )

    begin {
        $script:objectStack = @()
        $script:currentDepth = 0
    }

    process {
        $script:objectStack += $InputObject
        $script:currentDepth = 0

        while ($script:objectStack.Count -gt 0 -and $script:currentDepth -lt $Depth) {
            $currentObj = $script:objectStack[-1]
            $script:objectStack = $script:objectStack[0..($script:objectStack.Count - 2)]
            $script:currentDepth++

            Explore-SingleObject -Object $currentObj
        }
    }

    end {
        if ($Interactive -and $script:selectedMember) {
            Invoke-SelectedMember -Object $InputObject -Member $script:selectedMember
        }
    }
}

function Resolve-SingleObject {
    param($Object)

    $members = $Object | Get-Member | Where-Object {
        -not $Filter -or $_.Name -like "*$Filter*"
    } | Sort-Object MemberType, Name

    # Интерактивное меню
    if ($Interactive) {
        $menu = @()
        $members | ForEach-Object {
            $menu += "[$($_.MemberType[0])] $($_.Name) - $($_.Definition)"
        }

        $choice = $menu | Out-GridView -Title "Выберите элемент для исследования (Глубина: $script:currentDepth)" -PassThru
        if ($choice) {
            $script:selectedMember = $members[$menu.IndexOf($choice)]
            $script:objectStack += $Object.$($script:selectedMember.Name)
        }
    } else {
        # Детальный вывод
        Write-Host "`n=== ОБЪЕКТ [$($Object.GetType().FullName)] ===" -ForegroundColor Blue
        $members | Group-Object MemberType | ForEach-Object {
            Write-Host "`n=== $($_.Name.ToUpper()) ===" -ForegroundColor Cyan
            $_.Group | Format-Table Name, Definition -AutoSize -Wrap
        }

        if ($GenerateCode) {
            Write-Host "`n=== ГЕНЕРАЦИЯ КОДА ===" -ForegroundColor Yellow
            Generate-UsageExamples -Object $Object -Members $members
        }
    }
}

function New-UsageExamples {
    param($Object, $Members)

    $Members | Where-Object { $_.MemberType -eq "Method" } | ForEach-Object {
        $example = switch -Regex ($_.Name) {
            "^Get" { "$($_.Name)()  # Возвращает данные" }
            "^Set" { "$($_.Name)('value')  # Устанавливает значение" }
            default { "$($_.Name)()  # Действие" }
        }
        Write-Host ("• " + $example) -ForegroundColor Magenta
    }
}

function Invoke-SelectedMember {
    param($Object, $Member)

    try {
        $result = if ($Member.MemberType -eq "Method") {
            $Object.$($Member.Name).Invoke()
        } else {
            $Object.$($Member.Name)
        }

        Write-Host "`n=== РЕЗУЛЬТАТ ===" -ForegroundColor Green
        $result | Format-List *
    } catch {
        Write-Warning "Ошибка выполнения: $_"
    }
}

function view {
    param ([string]$file)
    if (-not (Test-Path $file)) {
        Write-Host "Файл не найден: $file" -ForegroundColor Red
        return
    }
    bat --style=numbers, changes --paging=always --theme=TwoDark $file
}

# Быстрый поиск по содержимому всех файлов с интерактивным выбором через fzf + предпросмотром
function fsearch {
    param (
        [string]$pattern
    )

    if (-not $pattern) {
        Write-Host "Пример использования: fsearch 'ошибка'" -ForegroundColor Yellow
        return
    }

    # Ищем по всем текстовым файлам
    $results = Select-String -Path (Get-ChildItem -Recurse -File -Include *.ps1, *.txt, *.log, *.md) -Pattern $pattern -ErrorAction SilentlyContinue

    if (-not $results) {
        Write-Host "Ничего не найдено" -ForegroundColor DarkGray
        return
    }

    $results | fzf --ansi --delimiter : `
        --preview "bat --theme=TwoDark --color=always --highlight-line {2} {1}" `
        --preview-window=up:60%:wrap
}

# Альтернатива grep
function grepz {
    param(
        [string]$pattern,
        [string]$path = "."
    )

    Select-String -Path $path -Pattern $pattern |
        fzf --ansi --delimiter : `
            --preview "bat --color=always --highlight-line {2} {1}" `
            --preview-window=up:60%:wrap
}

function goto {
    param(
        [string]$path
    )
    Set-Location $path;
    Write-Host "🛻"(Get-Location).Path"🚗" -ForegroundColor White
}

function gotoCrypta { goto C:\projects\crypta }
function gotoAppData { goto C:\Users\ketov\AppData }
function gotoPowershellModules { goto C:\Users\ketov\Documents\PowerShell\Modules }
function desktop { goto "$HOME\Desktop" }
function downloads { goto "$HOME\Downloads" }
function docs { goto "$HOME\Documents" }
function ~ { goto $HOME }
function cd.. { goto .. }
function cd... { goto ..\.. }
function cd.... { goto ..\..\.. }

function c { Clear-Host; goto C:\ }
function reloadProfile { . $PROFILE; Write-RGB "🔁 Profile was reloaded" -FC "#a0FF99" }

## 📜 Алиасы
Set-Alias -Name ls -Value PowerColorLS

Set-Alias -Name g -Value git
Set-Alias -Name touch -Value New-Item
Set-Alias -Name which -Value Get-Command

Set-Alias ro Resolve-Object
Set-Alias ioe Invoke-ObjectExplorer
Set-Alias rso Resolve-SingleObject
Set-Alias nue New-UsageExamples

Set-Alias re reloadProfile

Set-Alias v view
Set-Alias fz fsearch
Set-Alias gr grepz

Set-Alias cy gotoCrypta
Set-Alias ad gotoAppData
Set-Alias pm gotoPowershellModules