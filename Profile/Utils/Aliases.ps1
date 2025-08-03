


#📅 Дата и время
#$VerbosePreference = "Continue"
importProcess  $MyInvocation.MyCommand.Name.trim('.ps1') -start
function ez
{
    eza  --group-directories-first --hyperlink --icons=always --color=always --color-scale-mode=gradient --git  -x  @args
}


function gh
{
    [CmdletBinding(DefaultParameterSetName = 'AllUsersView', HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=2096483')]
    param(
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] ${Name},

        [string] ${Path},

        [ValidateSet('Alias', 'Cmdlet', 'Provider', 'General', 'FAQ', 'Glossary', 'HelpFile', 'ScriptCommand', 'Function', 'Filter', 'ExternalScript', 'All', 'DefaultHelp', 'DscResource', 'Class', 'Configuration')]
        [string[]] ${Category},

        [Parameter(ParameterSetName = 'DetailedView', Mandatory = $true)]
        [switch] ${Detailed},

        [Parameter(ParameterSetName = 'AllUsersView')]
        [switch] ${Full},

        [Parameter(ParameterSetName = 'Examples', Mandatory = $true)]
        [switch] ${Examples},

        [Parameter(ParameterSetName = 'Parameters', Mandatory = $true)]
        [string[]] ${Parameter},

        [string[]] ${Component},

        [string[]] ${Functionality},

        [string[]] ${Role},

        [Parameter(ParameterSetName = 'Online', Mandatory = $true)]
        [switch] ${Online},

        [Parameter(ParameterSetName = 'ShowWindow', Mandatory = $true)]
        [switch] ${ShowWindow}
    )

    process {
        # Call the original Get-Help command by its fully qualified path.
        $help = Microsoft.PowerShell.Core\Get-Help @PSBoundParameters

        # Define the styles for colorization.
        $style = @{
            SECTION = $PSStyle.Formatting.FormatAccent
            COMMAND = $PSStyle.Foreground.BrightYellow
            PARAM = $PSStyle.Foreground.FromRgb(64, 200, 230)
        }

        # Escape the command name for use in RegEx
        $commandNameEscaped = [regex]::Escape($help.Name)

        # Define a RegEx for doing the formatting. The names of the RegEx groups have to match the keys of the $style hashtable.
        $regEx = @(
            "(?m)(?<=^[ \t]*)(?<SECTION>[A-Z][A-Z \t\d\W]+$)"
            "(?<COMMAND>\b$commandNameEscaped\b)"
            "(?<PARAM>\B-\w+)"
        ) -join '|'

        # Format the help object
        $help | Out-String | ForEach-Object {
            [regex]::Replace($_, $regEx, {
                # Get the RegEx group that has matched.
                $matchGroup = $args.Groups.Where{ $_.Success }[1]
                # Use the RegEx group name to select associated style for colorizing the match.
                $style[$matchGroup.Name] + $matchGroup.Value + $PSStyle.Reset
            })
        }
    }
}


function ruDate
{
    param(        
        [switch] $withTime,
        [switch] $onlyTime
    )

    $format = $onlyTime ? "HH часов mm минут ss" :
    ($withTime ? "dd MMMM yyyy HH часов mm минут ss": "dd MMMM yyyy")

    (Get-Date).ToString($format,[System.Globalization.CultureInfo]::GetCultureInfo("ru-RU"))
}

function ruDay
{
    param(
        [switch] $withYear
    )
    $months = @{
        1 = "января"; 2 = "февраля"; 3 = "марта"; 4 = "апреля"; 5 = "мая"; 6 = "июня";
        7 = "июля"; 8 = "августа"; 9 = "сентября"; 10 = "октября"; 11 = "ноября"; 12 = "декабря"
    }
    $d = Get-Date
    return $withYear ? "{0:dd} {1} {0:yyyy}" -f $d, $months[$d.Month] : "{0:dd} {1}" -f $d, $months[$d.Month]
}

function ExternalScripts
{
    Get-Command -CommandType externalscript | Get-Item |
            Select-Object Directory, Name, Length, CreationTime, LastwriteTime,
            @{ name = "Signature"; Expression = { (Get-AuthenticodeSignature $_.fullname).Status } }
}

function freeC
{
    #    (gcim win32_logicaldisk -Filter "deviceid = 'C:'").FreeSpace / 1gb
    #or use the PSDrive
    (Get-PSDrive c).Free / 1gb
}

function commandsExample
{
    debug (Get-Command).where({ $_.source }) | Sort-Object Source, CommandType, Name | Format-Table -GroupBy Source -Property CommandType, Name, @{ Name = "Synopsis"; Expression = { (Get-Help $_.name).Synopsis } }
}


function view
{
    param ([string]$file)
    if (-not (Test-Path $file))
    {
        Write-Host "Файл не найден: $file" -ForegroundColor Red
        return
    }
    bat --color=always --paging=always --theme=TwoDark $file
}

# Быстрый поиск по содержимому всех файлов с интерактивным выбором через fzf + предпросмотром
function fsearch
{
    param (
        [string]$pattern
    )

    if (-not $pattern)
    {
        Write-Host "Пример использования: fsearch 'ошибка'" -ForegroundColor Yellow
        return
    }

    # Ищем по всем текстовым файлам
    $results = Select-String -Path (Get-ChildItem -Recurse -File -Include *.ps1, *.txt, *.log, *.md) -Pattern $pattern -ErrorAction SilentlyContinue

    if (-not $results)
    {
        Write-Host "Ничего не найдено" -ForegroundColor DarkGray
        return
    }

    $results | fzf --ansi --delimiter : `
        --preview "bat --theme=TwoDark --color=always --highlight-line {2} {1}" `
        --preview-window=up:60%:wrap
}

# Альтернатива grep
function grepz
{
    param(
        [string]$pattern,
        [string]$path = "."
    )

    Select-String -Path $path -Pattern $pattern |
            fzf --ansi --delimiter : `
            --preview "bat --color=always --highlight-line {2} {1}" `
            --preview-window=up:60%:wrap
}

function goto
{
    param(
        [string]$path
    )
    Set-Location $path;
    Write-Host "🛻"(Get-Location).Path"🚗" -ForegroundColor White
}


function gotoCrypta
{
    goto C:\projects\crypta
}
function gotoAppData
{
    goto C:\Users\ketov\AppData
}
function gotoPowershellModules
{
    goto C:\Users\ketov\Documents\PowerShell\Modules
}
function gotoPowershellProfile
{
    goto C:\projects\PowerShell\Profile
}

function desktop
{
    goto "$HOME\Desktop"
}
function downloads
{
    goto "$HOME\Downloads"
}
function docs
{
    goto "$HOME\Documents"
}
function ~
{
    goto $HOME
}
function cd..
{
    goto ..
}
function cd...
{
    goto ..\..
}
function cd....
{
    goto ..\..\..
}

function c
{
    Clear-Host; goto C:\
}
function cm
{
    goto C:\Users\ketov\.config\micro\
}
function reloadProfile
{
    . $PROFILE; wrgb "🔁 Profile was reloaded" -FC "#a0FF99"
}
function gotoKaliRoot
{
    goto \\wsl.localhost\kali-linux\
}





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


Set-Alias kr gotoKaliRoot
Set-Alias cy gotoCrypta
Set-Alias ad gotoAppData
Set-Alias pm gotoPowershellModules
Set-Alias pp gotoPowershellProfile
Set-Alias d  debug

# ---- WINGET ----
function wgs
{
    winget search @args
}
function wgi
{
    winget install @args
}
function wgu
{
    winget upgrade --all --verbose @args
}
function wgr
{
    winget restore @args
}
function wgl
{
    winget list @args
}
function wgrm
{
    winget uninstall @args
}
function wgsh
{
    winget show @args
}
function wgsrc
{
    winget source list @args
}


function reloadProfile
{
    . $PROFILE; wrgb "🔁 Profile was reloaded" -FC "#a0FF99"
}

function ShowHostColors
{
    $colors = $Host.PrivateData | Get-Member -MemberType Property | Where-Object { $_.Name -match "color" }

    foreach ($color in $colors)
    {
        $name = $color.Name
        $value = $Host.PrivateData.$name

        # Определяем цвет текста на основе значения
        $fgColor = if ($name -match "Foreground")
        {
            $value
        }
        else
        {
            "White"
        }
        $bgColor = if ($name -match "Background")
        {
            $value
        }
        else
        {
            "Black"
        }

        Write-Host "$name : $value" -ForegroundColor $fgColor -BackgroundColor $bgColor
    }
}

# ---- SYSTEM ----
Set-Alias cls Clear-Host
Set-Alias np notepad
Set-Alias exp explorer

# ---- ПРОЦЕССЫ ----
function top
{
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 15 | Format-Table -AutoSize
}
function pkill
{
    Get-Process -Name $args[0] | Stop-Process -Force
}
function psx
{
    Get-Process | fzf | ForEach-Object { Stop-Process -Id $_.Id -Force }
}

# ---- НАВИГАЦИЯ ----
function up
{
    Set-Location ..
}
function home
{
    Set-Location $HOME
}
Set-Alias h home
function fcd
{
    Set-Location (Get-ChildItem -Directory | fzf).FullName
}

# ---- ПОИСК И ОТКРЫТИЕ ----
function fe
{
    Invoke-Item (fzf)
}
function fhist
{
    Get-History | fzf | ForEach-Object { Invoke-Expression $_.CommandLine }
}

# ---- СЕТЬ ----
function myIP
{
    curl 2ip.ua
}
Set-Alias ipconfig Get-NetIPAddress


# ---- ОЧИСТКА ----
function Remove-tmp
{
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
}
function Remove-ds
{
    Get-ChildItem -Recurse -Force -Filter *.DS_Store | Remove-Item -Force
}

# ---- ЛОКАЛЬНЫЙ WEB СЕРВЕР ----
function serverPython
{
    param ([int]$port = 8000)
    Start-Process "http://localhost:$port"
    python -m http.server $port
}

# ---- MICRO ----
Set-Alias m micro


# ---- RIPGREP ----
function rgf
{
    param([string]$pattern)
    if (!$pattern)
    {
        $pattern = Read-Host "Введи патерн для пошуку"
    }
    rg --no-heading --line-number --color always $pattern | fzf --ansi | ForEach-Object {
        $file, $line = ($_ -split ":")[0..1]
        micro "$file" +$line
    }
}

# ---- BAT ----
Set-Alias cat bat
function batf
{
    bat (fzf)  --color=always
}

# ---- BTOP ----
Set-Alias sys btop

# ---- НАВИГАЦИЯ ----
function fcd
{
    Set-Location (Get-ChildItem -Directory | fzf).FullName
}
function fe
{
    Invoke-Item (fzf)
}

# ---- ПЕРЕГЛЯД ИСТОРИИ ----
function fhist
{
    Get-History | fzf | ForEach-Object { Invoke-Expression $_.CommandLine }
}

# ---- ВИДАЛЕННЯ ФАЙЛУ ----
function frm
{
    Get-ChildItem | fzf | Remove-Item -Force
}

# ---- ПЕРЕЙМЕНУВАННЯ ФАЙЛУ ----
function frn
{
    $item = Get-ChildItem | fzf
    if ($item)
    {
        $newName = Read-Host "Нове ім’я для '$( $item.Name )'"
        Rename-Item $item.FullName $newName
    }
}

Set-Alias -Name wrgb -Value Write-RGB -Scope Global -Force
Set-Alias -Name wgt -Value Write-GradientText -Scope Global -Force
Set-Alias -Name wrgbl -Value WriteRGBLine -Force
Set-Alias -Name nthp -Value NumberToHexPair -Force

function pr_
{
    param(
        [string]$string,
        [switch]$reload,
        [string]$filePath =  "${global:profilePath}Utils\Aliases.ps1",
        [switch]$toStart
    )

    $profileContent = Get-Content -Path $filePath -Raw -ErrorAction SilentlyContinue

    if ($toStart)
    {
        Set-Content -Path $filePath -Value ("`n" + $string + "`n"+ $profileContent ) -Encoding UTF8 -NoNewline
    }
    else
    {
        Set-Content -Path $filePath -Value ("`n" + $profileContent + "`n" +$string + "`n") -Encoding UTF8 -NoNewline
    }
    if ($reload)
    {
        reloadProfile
        Write-Host "`n"
    }
    Write-Warning "`nСтрока ${string} добавлена в ${filePath}`n"
}

function bunRun
{
    bun run dev
}

function oklch {
    $projectRoot = "C:\projects\colors\oklch"  # укажите свой путь
    Set-Location $projectRoot
    chrome "http://localhost:5173/#0.5731,0.1773,254.35,100"
    bun start
}

# ===== АЛИАС ДЛЯ БЫСТРОГО ДОСТУПА К МЕНЮ =====
Set-Alias -Name menu -Value Show-MainMenu
Set-Alias -Name mm -Value Show-MainMenu
Set-Alias -Name br -Value bunRun
Set-Alias -Name es -Value Everything64.exe -Force
importProcess  $MyInvocation.MyCommand.Name.trim(".ps1")

