#📅 Дата и время
#$VerbosePreference = "Continue"
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

function now
{
    Get-Date -Format "dd.MM.yyyy HH:mm:ss"
}

function date
{
    Get-Date -Format "dd.MM.yyyy"
}#

function dateRu
{
    (Get-Date).ToString("dd MMMM yyyy HH часов mm минут ss",[System.Globalization.CultureInfo]::GetCultureInfo("ru-RU"))
}

function dt
{
    $months = @{
        1 = "января"; 2 = "февраля"; 3 = "марта"; 4 = "апреля"; 5 = "мая"; 6 = "июня";
        7 = "июля"; 8 = "августа"; 9 = "сентября"; 10 = "октября"; 11 = "ноября"; 12 = "декабря"
    }
    $d = Get-Date
    return "{0:dd} {1} {0:yyyy}" -f $d, $months[$d.Month]
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


function Resolve-Object
{
    param(
        [Parameter(ValueFromPipeline = $true)]
        [object]$InputObject,

        [switch]$Methods,
        [switch]$Properties,
        [switch]$Examples
    )

    process {
        $members = $InputObject | Get-Member

        if ($Methods)
        {
            Write-Host "`n=== МЕТОДЫ ===`n" -ForegroundColor Cyan
            $members | Where-Object { $_.MemberType -eq "Method" } | Format-Table Name, Definition -AutoSize
        }

        if ($Properties)
        {
            Write-Host "`n=== СВОЙСТВА ===`n" -ForegroundColor Green
            $members | Where-Object { $_.MemberType -eq "Property" } | Format-Table Name, Definition -AutoSize
        }

        if ($Examples -and $Methods)
        {
            Write-Host "`n=== ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ ===`n" -ForegroundColor Yellow
            $methodsList = $members | Where-Object { $_.MemberType -eq "Method" }

            foreach ($method in $methodsList)
            {
                $example = switch ($method.Name)
                {
                    "CopyTo" {
                        '$file.CopyTo("C:\new\path.txt")'
                    }
                    "Delete" {
                        '$file.Delete()'
                    }
                    "ToString" {
                        '$date = Get-Date; $date.ToString("yyyy-MM-dd")'
                    }
                    default {
                        "`$obj.$( $method.Name )()"
                    }
                }
                Write-Host ("• " + $example) -ForegroundColor Magenta
            }
        }
    }
}

function Invoke-ObjectExplorer
{
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

        while ($script:objectStack.Count -gt 0 -and $script:currentDepth -lt $Depth)
        {
            $currentObj = $script:objectStack[-1]
            $script:objectStack = $script:objectStack[0..($script:objectStack.Count - 2)]
            $script:currentDepth++

            Explore-SingleObject -Object $currentObj
        }
    }

    end {
        if ($Interactive -and $script:selectedMember)
        {
            Invoke-SelectedMember -Object $InputObject -Member $script:selectedMember
        }
    }
}

function Resolve-SingleObject
{
    param($Object)

    $members = $Object | Get-Member | Where-Object {
        -not $Filter -or $_.Name -like "*$Filter*"
    } | Sort-Object MemberType, Name

    # Интерактивное меню
    if ($Interactive)
    {
        $menu = @()
        $members | ForEach-Object {
            $menu += "[$( $_.MemberType[0] )] $( $_.Name ) - $( $_.Definition )"
        }

        $choice = $menu | Out-GridView -Title "Выберите элемент для исследования (Глубина: $script:currentDepth)" -PassThru
        if ($choice)
        {
            $script:selectedMember = $members[$menu.IndexOf($choice)]
            $script:objectStack += $Object.$( $script:selectedMember.Name )
        }
    }
    else
    {
        # Детальный вывод
        Write-Host "`n=== ОБЪЕКТ [$( $Object.GetType().FullName )] ===" -ForegroundColor Blue
        $members | Group-Object MemberType | ForEach-Object {
            Write-Host "`n=== $($_.Name.ToUpper() ) ===" -ForegroundColor Cyan
            $_.Group | Format-Table Name, Definition -AutoSize -Wrap
        }

        if ($GenerateCode)
        {
            Write-Host "`n=== ГЕНЕРАЦИЯ КОДА ===" -ForegroundColor Yellow
            Generate-UsageExamples -Object $Object -Members $members
        }
    }
}

function New-UsageExamples
{
    param($Object, $Members)

    $Members | Where-Object { $_.MemberType -eq "Method" } | ForEach-Object {
        $example = switch -Regex ($_.Name)
        {
            "^Get" {
                "$( $_.Name )()  # Возвращает данные"
            }
            "^Set" {
                "$( $_.Name )('value')  # Устанавливает значение"
            }
            default {
                "$( $_.Name )()  # Действие"
            }
        }
        Write-Host ("• " + $example) -ForegroundColor Magenta
    }
}

function Invoke-SelectedMember
{
    param($Object, $Member)

    try
    {
        $result = if ($Member.MemberType -eq "Method")
        {
            $Object.$( $Member.Name ).Invoke()
        }
        else
        {
            $Object.$( $Member.Name )
        }

        Write-Host "`n=== РЕЗУЛЬТАТ ===" -ForegroundColor Green
        $result | Format-List *
    }
    catch
    {
        Write-Warning "Ошибка выполнения: $_"
    }
}

function view
{
    param ([string]$file)
    if (-not (Test-Path $file))
    {
        Write-Host "Файл не найден: $file" -ForegroundColor Red
        return
    }
    bat --style=numbers, changes --paging=always --theme=TwoDark $file
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
    goto C:\Users\ketov\Documents\PowerShell\Profile
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
    . $PROFILE; Write-RGB "🔁 Profile was reloaded" -FC "#a0FF99"
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
    winget upgrade @args
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

# ---- CHOCOLATEY ----
function csi
{
    choco install @args
}
function csu
{
    choco upgrade all -y
}
function csl
{
    choco list -lo
}
function csr
{
    choco uninstall @args
}


function reloadProfile
{
    . $PROFILE; Write-RGB "🔁 Profile was reloaded" -FC "#a0FF99"
}

function ShowHostColors {
    $colors = $Host.PrivateData | Get-Member -MemberType Property | Where-Object { $_.Name -match "color" }

    foreach ($color in $colors) {
        $name = $color.Name
        $value = $Host.PrivateData.$name

        # Определяем цвет текста на основе значения
        $fgColor = if ($name -match "Foreground") { $value } else { "White" }
        $bgColor = if ($name -match "Background") { $value } else { "Black" }

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
function myip
{
    Invoke-RestMethod ifconfig.me
}
Set-Alias ipconfig Get-NetIPAddress
# Set-Alias pingtest { Test-Connection -ComputerName 8.8.8.8 -Count 4 }

# ---- ОЧИСТКА ----
function clean-tmp
{
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
}
function clean-ds
{
    Get-ChildItem -Recurse -Force -Filter *.DS_Store | Remove-Item -Force
}

# ---- ОБНОВЛЕНИЕ ----
function update-ps
{
    winget upgrade --id Microsoft.PowerShell
}

# # ---- ЛОКАЛЬНЫЙ WEB СЕРВЕР ----
# function serve {
#     param ([int]$port = 8000)
#     Start-Process "http://localhost:$port"
#     python -m http.server $port
# }

Function Switch-KeyboardLayout {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet("en-US", "ru-RU", "uk-UA")]
        [string]$Culture
    )

    # Сопоставление культур с соответствующими HEX-кодами раскладок Windows
    $layoutMap = @{
        "en-US" = "00000409"
        "ru-RU" = "00000419"
        "uk-UA" = "00000422"
    }

    if (-not $layoutMap.ContainsKey($Culture)) {
        Write-Warning "Неизвестная раскладка: $Culture"
        return
    }

    $klid = $layoutMap[$Culture]

    # Проверяем, не был ли тип уже добавлен
    if (-not ([System.Management.Automation.PSTypeName]'KeyboardLayoutSwitcher').Type) {
        Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        using System.Globalization;

        public class KeyboardLayoutSwitcher {
            [DllImport("user32.dll")]
            public static extern IntPtr LoadKeyboardLayout(string pwszKLID, uint Flags);

            [DllImport("user32.dll")]
            public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

            [DllImport("user32.dll")]
            public static extern IntPtr GetForegroundWindow();

            [DllImport("user32.dll")]
            public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

            [DllImport("user32.dll")]
            public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

            [DllImport("user32.dll")]
            public static extern bool IsWindowVisible(IntPtr hWnd);

            public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

            private const uint WM_INPUTLANGCHANGEREQUEST = 0x0050;
            private const IntPtr INPUTLANGCHANGE_SYSCHARSET = (IntPtr)0x0001;
            private const int KLF_ACTIVATE = 0x00000001;

            public static bool SwitchKeyboardLayout(string layoutId) {
                try {
                    // Загружаем раскладку
                    IntPtr hkl = LoadKeyboardLayout(layoutId, KLF_ACTIVATE);
                    if (hkl == IntPtr.Zero) {
                        return false;
                    }

                    // Отправляем сообщение всем окнам
                    EnumWindows((hWnd, lParam) => {
                        if (IsWindowVisible(hWnd)) {
                            PostMessage(hWnd, WM_INPUTLANGCHANGEREQUEST, INPUTLANGCHANGE_SYSCHARSET, hkl);
                        }
                        return true;
                    }, IntPtr.Zero);

                    // Также отправляем сообщение активному окну
                    IntPtr foregroundWindow = GetForegroundWindow();
                    if (foregroundWindow != IntPtr.Zero) {
                        PostMessage(foregroundWindow, WM_INPUTLANGCHANGEREQUEST, INPUTLANGCHANGE_SYSCHARSET, hkl);
                    }

                    return true;
                } catch {
                    return false;
                }
            }
        }
"@
    }

    try {
        $success = [KeyboardLayoutSwitcher]::SwitchKeyboardLayout($klid)

        if ($success) {
            Write-Host "✅ Раскладка переключена на $Culture" -ForegroundColor Green

            # Небольшая задержка для применения изменений
            Start-Sleep -Milliseconds 100
        } else {
            Write-Error "Не удалось переключить раскладку на $Culture. Убедитесь, что раскладка установлена в системе."
        }

    } catch {
        Write-Error "Ошибка при переключении раскладки: $($_.Exception.Message)"
    }
}

# Альтернативная функция через системные команды
Function Switch-KeyboardLayoutAlt {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet("en-US", "ru-RU", "uk-UA")]
        [string]$Culture
    )

    try {
        # Получаем текущий список языков
        $currentLanguages = Get-WinUserLanguageList

        # Находим нужный язык или добавляем его
        $targetLang = $currentLanguages | Where-Object { $_.LanguageTag -eq $Culture }

        if (-not $targetLang) {
            Write-Host "Добавляю раскладку $Culture..." -ForegroundColor Yellow
            $newLanguages = $currentLanguages + (New-WinUserLanguageList -Language $Culture)
            Set-WinUserLanguageList -LanguageList $newLanguages -Force
            Start-Sleep -Seconds 2
        }

        # Перемещаем выбранный язык на первое место
        $updatedLanguages = Get-WinUserLanguageList
        $reorderedLanguages = @()

        # Сначала добавляем целевой язык
        $reorderedLanguages += $updatedLanguages | Where-Object { $_.LanguageTag -eq $Culture }

        # Затем добавляем остальные языки
        $reorderedLanguages += $updatedLanguages | Where-Object { $_.LanguageTag -ne $Culture }

        Set-WinUserLanguageList -LanguageList $reorderedLanguages -Force

        Write-Host "✅ Раскладка $Culture установлена как основная" -ForegroundColor Green

    } catch {
        Write-Error "Ошибка при переключении раскладки: $($_.Exception.Message)"
    }
}

# Функция для получения списка установленных раскладок
Function Get-InstalledKeyboardLayouts {
    try {
        $layouts = Get-WinUserLanguageList | Select-Object LanguageTag, LocalizedName, @{Name="InputMethods"; Expression={$_.InputMethodTips -join ", "}}
        return $layouts | Format-Table -AutoSize
    } catch {
        Write-Warning "Не удалось получить список установленных раскладок"
    }
}

# Дополнительная функция для получения списка установленных раскладок
Function Get-InstalledKeyboardLayouts {
    try {
        $layouts = Get-WinUserLanguageList | Select-Object LanguageTag, @{Name="InputMethods"; Expression={$_.InputMethodTips -join ", "}}
        return $layouts
    } catch {
        Write-Warning "Не удалось получить список установленных раскладок"
    }
}

# ---- MICRO ----
Set-Alias m micro
function me { micro (fzf) }  # Відкрити обраний файл у micro

# ---- RIPGREP ----
function rgf {
    param([string]$pattern)
    if (!$pattern) { $pattern = Read-Host "Введи патерн для пошуку" }
    rg --no-heading --line-number --color always $pattern | fzf --ansi | ForEach-Object {
        $file, $line = ($_ -split ":")[0..1]
        micro "$file" +$line
    }
}

# ---- BAT ----
Set-Alias cat bat
function batf { bat (fzf)  --color always}

# ---- BTOP ----
Set-Alias sys btop
Set-Alias top btop

# ---- НАВІГАЦІЯ ----
function fcd { Set-Location (Get-ChildItem -Directory | fzf).FullName }
function fe { Invoke-Item (fzf) }

# ---- ПЕРЕГЛЯД ІСТОРІЇ ----
function fhist { Get-History | fzf | ForEach-Object { Invoke-Expression $_.CommandLine } }

# ---- ВИДАЛЕННЯ ФАЙЛУ ----
function frm { Get-ChildItem | fzf | Remove-Item -Force }

# ---- ПЕРЕЙМЕНУВАННЯ ФАЙЛУ ----
function frn {
    $item = Get-ChildItem | fzf
    if ($item) {
        $newName = Read-Host "Нове ім’я для '$($item.Name)'"
        Rename-Item $item.FullName $newName
    }
}

Set-Alias -Name wrgb -Value Write-RGB -Scope Global -Force
Set-Alias -Name wgt -Value Write-GradientText -Scope Global -Force
Set-Alias -Name wrgbn -Value Write-RGBLine -Force
Set-Alias -Name wrgbc -Value Write-RGBNoNewLine -Force
Set-Alias -Name nthp -Value NumberToHexPair -Force

function pr_
{
    param(
        [string]$string,
        [switch]$reload = $false,
        [string]$filePath = "$PSScriptRoot/Aliases.ps1"
    )

    $profileContent = Get-Content -Path $filePath -Raw -ErrorAction SilentlyContinue

    Set-Content -Path $filePath -Value ("`n" + $profileContent + $string + "`n") -Encoding UTF8 -NoNewline
    if ($reload)
    {
        reloadProfile
        Write-Host "`n"
    }
    Write-Warning "`nСтрока ${string} добавлена в ${filePath}`n"
}
#ShowHostColors

# Дерево каталогов, 2 уровня
function lte { eza -T --icons --git --level=2 }

# Дерево всех папок и файлов
function ltte { eza -T -a --icons --git }

# Сортировка по времени
function ltne { eza -la --sort newest --icons }

# Текущая папка с размером и датами
function lsse { eza -lah --icons --git --sort size }

# Только каталоги
function lsde { eza -D --icons }

# Только исполняемые
function lsee { eza --icons | Where-Object { $_ -match '\*' } }

# Без мусора
function lsce { eza --icons --git --group-directories-first --sort name }

# Быстрый fzf + eza
function lzf { eza --icons | fzf }

# Alias на всякий случай
# ----- EZA: цветовая схема -----
$Env:LS_COLORS = @(
    "di=1;36",          # директории — ярко-бирюзовый
    "ln=1;35",          # символические ссылки — фиолетовый
    "so=1;33",          # сокеты — жёлтый
    "pi=1;33",          # пайпы — жёлтый
    "ex=1;32",          # исполняемые — зелёный
    "bd=1;44",          # блочные устройства — синий
    "cd=1;44",          # символьные устройства — синий
    "or=1;31",          # битые ссылки — красный
    "*.ps1=1;36",       # PowerShell скрипты — бирюзовый
    "*.sh=1;32",        # shell — зелёный
    "*.md=1;35",        # markdown — фиолетовый
    "*.json=1;33",      # JSON — жёлтый
    "*.pdf=1;31",       # PDF — красный
    "*.png=1;35",       # изображения — фиолетовый
    "*.jpg=1;35",
    "*.jpeg=1;35",
    "*.zip=1;34",       # архивы — синий
    "*.7z=1;34",
    "*.rar=1;34",
    "*.exe=1;31",       # .exe — красный
    "*.dll=0;36",       # .dll — бирюзовый
    "*.log=0;90"        # логи — тёмно-серый
) -join ":"

# ----- EZA функции (с учётом LS_COLORS) -----
function lse { eza --icons --color=always }
function lle { eza -l --icons --git --color=always }
function lae { eza -la --icons --git --color=always }
function lte { eza -T --level=2 --icons --git --color=always }
function ltte { eza -T -a --icons --git --color=always }
function lzfe { eza --icons --color=always | fzf --ansi }
function lsizee { eza -lah --icons --git --sort size --color=always }

