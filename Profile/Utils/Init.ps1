[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Console]::OutputEncoding = [Text.Encoding]::UTF8
Import-Module Microsoft.PowerShell.PSResourceGet -Force

$newModulePath = "C:\Users\ketov\Documents\PowerShell\Modules"
$env:PSModulePath = $newModulePath
[Environment]::SetEnvironmentVariable("PSModulePath", $newModulePath, "User")
$env:POSH_IGNORE_ALLUSER_PROFILES = $true

$global:initStartScripts = @()
$global:initEndScripts = @()

# ===== ИМПОРТ  СКРИПТОВ =====
#importProcess  $MyInvocation.MyCommand.Name.trim('.ps1') -start
function importProcess
{
    param(
        [string]$name,
        [switch]$start,
        [switch]$finalInitialiazation
    )

    if ($finalInitialiazation)
    {
        #    Импорт оставшихся скриптов
        foreach ($script in $scriptsAfter)
        {
            . "${global:profilePath}${script}.ps1"
        }
        # Проверка на успешную инициализацию
        foreach ($scriptInitStart in $global:initStartScripts)
        {
            if ($global:initEndScripts -contains $scriptInitStart)
            {
                Write-Status -Success $scriptInitStart"  "
            }
            else
            {
                Write-Status -Problem $scriptInitStart"  "
            }
        }
        Write-Host ""
        return
    }

    if ($start)
    {
        $global:initStartScripts += $name
    }
    else
    {
        $global:initEndScripts += $name
    }
}

$scriptsBefore = @(
    'Utils\resourses\emoji',
    'Utils\Colors',
    'Utils\NiceColors',
    'Utils\Keyboard'
#'Utils\ProgressBar',
    'Utils\Aliases'
#'ErrorMethods'
#'Menu\Welcome'
#    'ErrorHandler',
)

foreach ($script in $scriptsBefore)
{
    . "${global:profilePath}${script}.ps1"
}


$scriptsAfter = @(
#    'Menu/NetworkSystem',
#    'Menu/MenuItems',
#    'Menu  /AppsBrowsersMenu',
#    'Parser/NiceParser'
#        'Utils/Rainbow'
    'Helper'
)




# ===== МОДУЛИ =====
$modules = @(
    'Logger',
    'PSColor',
    'PSFzf',
    'syntax-highlighting',
    'z'
)

foreach ($module in $modules)
{
    if (Get-Module -ListAvailable -Name $module)
    {
        Import-Module -Name $module -ErrorAction SilentlyContinue
    }
    else
    {
        Write-Host "[!] Модуль $module отсутствует. Установите: Install-Module $module" -ForegroundColor    Red
    }
}

# ===== РАСШИРЕННЫЕ НАСТРОЙКИ PSREADLINE =====
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -ShowToolTips
Set-PSReadLineOption -BellStyle Visual
Set-PSReadLineOption -EditMode Windows

# Горячие клавиши
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Ctrl+z -Function Undo
Set-PSReadLineKeyHandler -Key Ctrl+y -Function Redo
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteChar
Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Key Alt+d -Function DeleteWord

# RGB цветовая схема для PSReadLine
Set-PSReadLineOption -Colors @{
    Command = $PSStyle.Foreground.FromRgb(0, 255, 157)
    Parameter = $PSStyle.Foreground.FromRgb(255, 101, 69)
    Operator = $PSStyle.Foreground.FromRgb(255, 215, 0)
    Variable = $PSStyle.Foreground.FromRgb(139, 43, 255)
    String = $PSStyle.Foreground.FromRgb(15, 188, 249)
    Number = $PSStyle.Foreground.FromRgb(240, 31, 255)
    Member = $PSStyle.Foreground.FromRgb(0, 191, 255)
    Type = $PSStyle.Foreground.FromRgb(255, 255, 255)
    Emphasis = $PSStyle.Foreground.FromRgb(255, 145, 0)
    Error = $PSStyle.Foreground.FromRgb(255, 0, 0)
    Selection = $PSStyle.Background.FromRgb(64, 64, 64)
    InlinePrediction = $PSStyle.Foreground.FromRgb(102, 102, 102)
    ListPrediction = $PSStyle.Foreground.FromRgb(185, 185, 185)
    ContinuationPrompt = $PSStyle.Foreground.FromRgb(100, 255, 0)
}