
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Console]::OutputEncoding = [Text.Encoding]::UTF8
Import-Module Microsoft.PowerShell.PSResourceGet -Force
$env:PYTHONPATH += ";C:\Users\ketov\pipx\venvs\rich-cli\Scripts"

$global:successScripts = @()
$global:problemScripts = @()

function Test-InitScripts {
    $global:successScripts = @()
    $global:problemScripts = @()

    # Проверка на успешную инициализацию
    foreach ($scriptInitStart in $global:initStartScripts) {
        if ($global:initEndScripts -contains $scriptInitStart) {
            $global:successScripts += Write-Status -Success $scriptInitStart -returnRow
        }
        else {
            $global:problemScripts += Write-Status -Problem  $scriptInitStart  -returnRow
        }
    }

    $global:successScripts | Format-Wide
    $global:problemScripts | Format-Wide
}

$global:initStartScripts = @()
$global:initEndScripts = @()

Set-Alias -Name chs -Value Test-InitScripts
# ===== ИМПОРТ  СКРИПТОВ =====
#Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start
function Trace-ImportProcess {
    param(
        [string]$name,
        [switch]$start,
        [switch]$finalInitialiazation
    )

    if ($finalInitialiazation) {
        Test-InitScripts
    }

    if ($start) {
        $global:initStartScripts += $name
    }
    else {
        $global:initEndScripts += $name
    }
}

$scriptsBefore = @(
#  'Utils\resourses\emoji',
    'Utils\resourses\EmojiSystem',
    'Utils\resourses\EmojiTest',
    'Utils\Colors',
    'Utils\NiceColors',
    'Utils\Aliases',
    'Utils\ColorSystem',
    'Error\ErrorHandler',
    #    'ErrorTest',
    'Utils\Keyboard',
    'Utils\ProgressBar',

    'Rich\RichInit',
    #    'Rich\GlobalPython',
    'Rich\RichColors',
    'Rich\RichTheme',
    'Rich\Rich'
#    'Rich\files\PythonDiagnostics'

#    'ErrorHandler',
)

foreach ($script in $scriptsBefore) {
    . "${global:profilePath}${script}.ps1"
}

$global:scriptsAfter = @(
    'Menu\LS',
    'Menu\NetworkSystem',
    'Menu\MenuItem',
    'Menu\AppsBrowsersMenu',
    'Menu\Welcome',
    'Menu\ShowMenu',
    'Menu\Weather',
    #  'Utils\Rainbow'
    'Parser\NiceParser',
    'Parser\UltimateParser',
    'Parser\Integrate',
    'Parser\ParserIntegration',
    #     'AnalizeModuleFunctions'
    'Helper'
#    'BrowserTranslator',
#    'QuickStart',pipx install poetrypipx install poetry
)

# Show-TestGradientFull
# ===== МОДУЛИ =====

$modules = @(
# 'Logger',
# 'PSColor',
    'PSFzf',
    'syntax-highlighting',
    'z'
)

foreach ($module in $modules) {
    if (Get-Module -ListAvailable -Name $module) {
        Import-Module -Name $module -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "[!] Модуль $module отсутствует. Установите: Install-Module $module" -ForegroundColor    Red
    }
}

# ===== РАСШИРЕННЫЕ НАСТРОЙКИ PSREADLINE =====
# Проверяем, не пропускаем ли мы интерактивные настройки
if (-not $global:SkipInteractiveSetup) {
    try {
        # Проверяем поддержку виртуального терминала перед настройкой PSReadLine
        if ([Environment]::UserInteractive -and $Host.Name -eq 'ConsoleHost' -and ![Console]::IsOutputRedirected) {
            Set-PSReadLineOption -PredictionSource HistoryAndPlugin -ErrorAction Stop
            Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction Stop
            Set-PSReadLineOption -HistorySearchCursorMovesToEnd -ErrorAction SilentlyContinue
            Set-PSReadLineOption -ShowToolTips -ErrorAction SilentlyContinue
            Set-PSReadLineOption -BellStyle Visual -ErrorAction SilentlyContinue
            Set-PSReadLineOption -EditMode Windows -ErrorAction SilentlyContinue

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
                Command            = $PSStyle.Foreground.FromRgb(0, 255, 157)
                Parameter          = $PSStyle.Foreground.FromRgb(255, 101, 69)
                Operator           = $PSStyle.Foreground.FromRgb(255, 215, 0)
                Variable           = $PSStyle.Foreground.FromRgb(139, 43, 255)
                String             = $PSStyle.Foreground.FromRgb(15, 188, 249)
                Number             = $PSStyle.Foreground.FromRgb(240, 31, 255)
                Member             = $PSStyle.Foreground.FromRgb(0, 191, 255)
                Type               = $PSStyle.Foreground.FromRgb(255, 255, 255)
                Emphasis           = $PSStyle.Foreground.FromRgb(255, 145, 0)
                Error              = $PSStyle.Foreground.FromRgb(255, 0, 0)
                Selection          = $PSStyle.Background.FromRgb(64, 64, 64)
                InlinePrediction   = $PSStyle.Foreground.FromRgb(102, 102, 102)
                ListPrediction     = $PSStyle.Foreground.FromRgb(185, 185, 185)
                ContinuationPrompt = $PSStyle.Foreground.FromRgb(100, 255, 0)
            }
        }
    } catch [System.ArgumentException] {
        # Предиктивные функции не поддерживаются - это нормально для неинтерактивного режима
        Write-Verbose "Predictive features not supported: $($_.Exception.Message)"
    } catch [System.IO.IOException] {
        # Проблемы с дескриптором - пропускаем PSReadLine
        Write-Verbose "Terminal descriptor issue, skipping PSReadLine: $($_.Exception.Message)"
    } catch {
        # Другие ошибки PSReadLine
        Write-Verbose "PSReadLine configuration failed: $($_.Exception.Message)"
    }
} else {
    Write-Verbose "Interactive setup skipped - running in non-interactive mode"
}

if (-not (Get-Command Test-InitScripts -ErrorAction SilentlyContinue)) { Write-Host 'Test-InitScripts Error' }
if (-not (Get-Command Trace-ImportProcess -ErrorAction SilentlyContinue)) { Write-Host ' Trace-ImportProcess Error' }