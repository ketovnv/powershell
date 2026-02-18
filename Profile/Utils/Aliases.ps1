#📅 Дата и время
#$VerbosePreference = "Continue"
Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start
function ez
{
    eza  --group-directories-first --hyperlink --icons=always --color=always --color-scale-mode=gradient --git  -x  @args
}


function ghelp
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


function termux {
    ssh -p 8022 192.168.0.178
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

# ---- RIPGREP ----
function rgf
{
    param([string]$pattern)
    if (!$pattern)
    {
        $pattern = Write-Rainbow "Введи патерн для пошуку"
        return
    }
    rg --no-heading --line-number --color always $pattern |
    fzf --ansi --delimiter : `
--preview "bat --color=always --highlight-line {2} {1}" `
--preview-window=up:60%:wrap
    | ForEach-Object {
        $file, $line = ($_ -split ":")[0..1]
        micro "$file" +$line
    }
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

function pg {
    param(
        [Parameter(Position=0)]
        [ValidateSet('start', 'stop', 'restart', 'status', 'backup', 'users', 'logs',
                     'start-service', 'stop-service', 'restart-service',
                     'install-service', 'remove-service', 'help')]
        [string]$Action = 'help',
        [Alias("service", "useService")]

        [switch]$UseService
    )

    # Обработка обратной совместимости с -UseService
    if ($UseService) {
        switch ($Action) {
            'start'   { Start-PostgreSQLService }
            'stop'    { Stop-PostgreSQLService }
            'restart' { Restart-PostgreSQLService }
            default   { PSQL $Action }
        }
    } else {
        PSQL $Action
    }
}

function rd {
    param(
        [Parameter(Position=0)]
        [ValidateSet('start', 'stop', 'restart', 'status', 'info', 'logs', 'clear',
                     'start-service', 'stop-service', 'restart-service',
                     'install-service', 'remove-service', 'help')]
        [string]$Action = 'help',
        [Alias("service", "useService")]
        [switch]$UseService
    )

    # Обработка обратной совместимости с -UseService
    if ($UseService) {
        switch ($Action) {
            'start'   { Start-RedisService }
            'stop'    { Stop-RedisService }
            'restart' { Restart-RedisService }
            default   { RDS $Action }
        }
    } else {
        RDS $Action
    }
}

Set-Alias -Name touch -Value New-Item
Set-Alias -Name which -Value Get-Command

Set-Alias ro Resolve-Object
Set-Alias ioe Invoke-ObjectExplorer
Set-Alias rso Resolve-SingleObject
Set-Alias nue New-UsageExamples

Set-Alias re reloadProfile

Set-Alias v view
Set-Alias t tldr
Set-Alias fz fsearch
Set-Alias f rgf
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
    winget search --verbose @args
}
function wgi
{
    winget install --verbose @args
}
function wgu
{
    winget upgrade --all --verbose @args
}
function wgr
{
    winget restore --verbose @args
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
    winget show --verbose  @args
}
function wgsrc
{
    winget source list @args
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
    $selection = Get-Process | ForEach-Object { "{0,6}  {1}" -f $_.Id, $_.ProcessName } | fzf
    if ($selection) {
        $pid = ($selection -split '\s+', 2)[0].Trim()
        if ($pid -match '^\d+$') { Stop-Process -Id ([int]$pid) -Force }
    }
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
    $dir = Get-ChildItem -Directory | fzf
    if ($dir) { Set-Location $dir }
}

# ---- ПОИСК И ОТКРЫТИЕ ----
function fe
{
    $file = fzf
    if ($file) { Invoke-Item $file }
}
function fhist
{
    $entry = Get-History | ForEach-Object { "{0,5}  {1}" -f $_.Id, $_.CommandLine } | fzf
    if ($entry) {
        $id = ($entry -split '\s+', 2)[0].Trim()
        if ($id -match '^\d+$') { Invoke-Expression (Get-History -Id ([int]$id)).CommandLine }
    }
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


# ---- BAT ----
Set-Alias cat bat
function batf
{
    bat (fzf)  --color=always
}

# ---- BTOP ----
Set-Alias sys btop

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
Set-Alias -Name wrgb -Value Write-RGB -Scope Global -Force
Set-Alias -Name wgt -Value Write-GradientText -Scope Global -Force
Set-Alias -Name wrgbl -Value WriteRGBLine -Force
Set-Alias -Name nthp -Value NumberToHexPair -Force

function wrgbn
{
    wrgb  -newline @args
}

function pr_
{
    param(
        [string]$string,
        [switch]$reload,
        [string]$filePath = "${global:profilePath}Utils\Aliases.ps1",
        [switch]$toStart
    )

    $profileContent = Get-Content -Path $filePath -Raw -ErrorAction SilentlyContinue

    if ($toStart)
    {
        Set-Content -Path $filePath -Value ("`n" + $string + "`n" + $profileContent) -Encoding UTF8 -NoNewline
    }
    else
    {
        Set-Content -Path $filePath -Value ("`n" + $profileContent + "`n" + $string + "`n") -Encoding UTF8 -NoNewline
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

function oklch
{
    $projectRoot = "C:\projects\colors\oklch"  # укажите свой путь
    Set-Location $projectRoot
    chrome "http://localhost:5173/#0.5731,0.1773,254.35,100"
    bun start
}

# ===== АЛИАС ДЛЯ БЫСТРОГО ДОСТУПА К МЕНЮ =====
Set-Alias -Name menu -Value Show-ModernMainMenu
Set-Alias -Name mm -Value Show-ModernMainMenu
Set-Alias -Name br -Value bunRun
Set-Alias -Name es -Value Everything64.exe -Force
function dd { ./devops dev @args }

Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))

Set-Alias -Name p -Value python -Force

# ===== БЫСТРЫЕ АЛИАСЫ ДЛЯ КАТЕГОРИЙ МЕНЮ =====
Set-Alias -Name fm -Value Show-FileManagerMenu
Set-Alias -Name nt -Value Show-NetworkToolsMenu
Set-Alias -Name sm -Value Show-SystemMonitorMenu
Set-Alias -Name dt -Value Show-DevToolsMenu
Set-Alias -Name ql -Value Show-QuickLaunchMenu
Set-Alias -Name prs -Value Show-ProfileSettingsMenu
Set-Alias -Name cs -Value Show-ColorSystemDemo
Set-Alias -Name db -Value Show-DatabaseMenu
Set-Alias -Name hd -Value Show-HelpDiagnosticsMenu

# ===== АЛИАСЫ ДЛЯ ФАЙЛОВЫХ МЕНЕДЖЕРОВ И РЕДАКТОРОВ =====
Set-Alias -Name monster -Value markdownmonster -ErrorAction SilentlyContinue
Set-Alias -Name cursor -Value cursor -ErrorAction SilentlyContinue
Set-Alias -Name deepchat -Value deepchat -ErrorAction SilentlyContinue
Set-Alias -Name lh -Value lobehub -ErrorAction SilentlyContinue
Set-Alias -Name alacritty -Value alacritty -ErrorAction SilentlyContinue

# ===== АЛИАСЫ ДЛЯ НОВЫХ КОМАНД =====
Set-Alias -Name bun-help -Value Show-BunHelp
Set-Alias -Name show-colors -Value Show-AllColors
Set-Alias -Name show-emojis -Value Show-AllEmojis


Set-Alias -Name r -Value rich
Set-Alias -Name l -Value lessh
Set-Alias -Name a -Value claude


function  cath
{
    pygmentize -O style=monokai @args
}

function lessh
{
    pygmentize -O style=monokai @args | less -M -R
}




function gF
{
    param(
        [switch]$all,
        [string]$scriptPathName
    )

    if ($scriptPathName)
    {
        $scriptPathName = [System.IO.Path]::GetFileNameWithoutExtension($scriptPathName)
        $scriptPath = "${global:profilePath}${scriptPathName}.ps1"
        $scriptContent = Get-Content -Path $scriptPath -Raw
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($scriptContent, [ref]$null, [ref]$null)
        $functions = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
        $functions | ForEach-Object { $_.Name }
    }
    else
    {
        Get-ChildItem Function: | Where-Object { $all -or (-not $_.Source) } | Select-Object Name |Format-Wide  -column 4
    }
}

$env:RUST_BACKTRACE='full'
$env:GEMINI_API_KEY='AIzaSyD10YloUN7Et9sOViWgibb48Uy1kHn6iuU'

$env:ANDROID_HOME = "C:\ProgramData\AndroidSDK"
$env:ANDROID_SDK_ROOT = "C:\ProgramData\AndroidSDK"
$env:PATH += ";C:\ProgramData\AndroidSDK\platform-tools;C:\ProgramData\AndroidSDK\emulator"
$env:NGROK_AUTHTOKEN="2h8PYpHkTcgzbjHFjZ3Ui401pS7_4dzkKCU64kyGk9nKnC6iC"
$env:TRON_PRIVATE_KEY="09029b9a68d91eafc12723d7406f5aaf477283d88348b551a4b9a589699b9600"
$env:FIGMA_TOKEN="figd_3cCaphd2DyV72eE2POTdyyHStT9scA7b6zFSBR5F"
