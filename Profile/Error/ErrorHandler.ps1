Trace-ImportProcess  $MyInvocation.MyCommand.Name.trim(".ps1") -start
# Advanced ErrorView Handler with Templates and Translation
# Расширенная система перехвата и обработки ошибок с шаблонами и переводом

#errorImports
. "${global:profilePath}/Error/ExtractErrorDetails.ps1"
. "${global:profilePath}/Error/SmartError.ps1"
. "${global:profilePath}/Error/ShowError.ps1"

#endregion
#region Конфигурация и настройки
$ErrorViewConfig = @{
    Language = "ru"  # ru, en
    AutoTranslate = $true
    ShowStackTrace = $false
    ShowInnerExceptions = $true
    UseColors = $true
    LogErrors = $true
    LogPath = "$env:TEMP\PowerShell_Errors.log"
    NotifyOnCritical = $true
}



function Show-RecentErrors
{
    param(
        [int]$Count = 5,
        [string]$View = "Colorful"
    )

    wrgb "Последние $Count ошибок (вид: $View):" -FC Yellow -newline
    if ($Error.Count -gt 0)
    {
        $ErrorsToShow = if ($Error.Count -lt $Count)
        {
            $Error
        }
        else
        {
            $Error[0..($Count - 1)]
        }
        $ErrorsToShow | Format-Error $View
    }
    else
    {
        wrgb "Нет ошибок для отображения" -FC Green
    }
}

# Функция для анализа типов ошибок
function Get-ErrorSummary
{
    if ($Error.Count -eq 0)
    {
        wrgb "Нет ошибок в коллекции" -FC Green
        return
    }

    wrgb "`n--- Сводка по ошибкам ---" -FC Yellow -newline

    # Группируем ошибки по типу исключения
    $ErrorsByType = $Error | Group-Object { $_.Exception.GetType().Name } | Sort-Object Count -Descending

    wrgb "По типу исключения:" -FC Material_Orange -newline
    $ErrorsByType | ForEach-Object {
        wrgb   $_.Name" : " -FC Material_Purple
        wrgb   $_.Count" " -FC White  -newline
    }

    # Группируем по категории
    $ErrorsByCategory = $Error | Group-Object { $_.CategoryInfo.Category } | Sort-Object Count -Descending

    wrgb "`nПо категории:" -FC Material_Orange -newline
    $ErrorsByCategory | ForEach-Object {
        wrgb   $_.Name" : " -FC Material_Purple
        wrgb   $_.Count" " -FC White -newline
    }

    wrgb "`nВсего ошибок:  "  -FC "FF0000"
    wrgb $Error.Count -FC "FFFF00" -newline
}


Import-Module ErrorView -Force

$global:ErrorView = "Smart"

function Set-MyErrorView
{
    param(
        [ValidateSet("Simple", "Normal", "Category", "Full", "SingleLine", "Colorful")]
        [string]$View = "Simple"
    )

    $global:ErrorView = $View
    wrgb "ErrorView установлен в: $View" -FC Green
}



function ConvertTo-SingleLineErrorView
{
    param([System.Management.Automation.ErrorRecord]$InputObject)
    -join @(
        $originInfo = &{ Set-StrictMode -Version 1; $InputObject.OriginInfo }
    if (($null -ne $originInfo) -and ($null -ne $originInfo.PSComputerName))
    {
        "[" + $originInfo.PSComputerName + "]: "
    }
        $errorDetails = &{ Set-StrictMode -Version 1; $InputObject.ErrorDetails }
    if (($null -ne $errorDetails) -and ($null -ne $errorDetails.Message) -and ($InputObject.FullyQualifiedErrorId -ne "NativeCommandErrorMessage"))
    {
        $errorDetails.Message
    }
    else
    {
        $InputObject.Exception.Message
    }
        wrgb "Type:  "  -FC "#ff99AA"
        wrgb $InputObject.Exception.GetType().Name -FC "#ff0000"
        wrgb "  |  "  -FC "#ffFFFF"
        wrgb "  ID:  " -FC "#ff99AA"
        wrgb  $InputObject.FullyQualifiedErrorId -FC "#ff0000"
        wrgb "  |  "  -FC "#ffFFFF"

    if ($ErrorViewRecurse)
    {
        $Prefix = " | Exception: "
        $Exception = &{ Set-StrictMode -Version 1; $InputObject.Exception }
        do
        {
            $Prefix + $Exception.GetType().FullName
            $Prefix = wrgb " | "  -FC "#ffFFFF"
            $Prefix = wrgb "InnerException:  "  -FC "#ff99AA"
        } while ($Exception = $Exception.InnerException)
    }
    )
}



#region Функции для работы с переводом и шаблонами




function Log-Error
{
    param(
        [System.Management.Automation.ErrorRecord]$ErrorRecord,
        [string]$FormattedMessage

    )

    if (-not $ErrorViewConfig.LogErrors)
    {
        return
    }

    $logEntry = @"
[$( Get-Date -Format 'yyyy-MM-dd HH:mm:ss' )] ERROR
Type: $( $ErrorRecord.Exception.GetType().Name )
Message: $( $ErrorRecord.Exception.Message )
Formatted: $FormattedMessage
Command: $( $ErrorRecord.InvocationInfo.MyCommand.Name )
Line: $( $ErrorRecord.InvocationInfo.ScriptLineNumber )
Script: $( $ErrorRecord.InvocationInfo.ScriptName )
---

"@

    Add-Content -Path $ErrorViewConfig.LogPath -Value $logEntry -Encoding UTF8
}
#endregion


function ConvertTo-CompactErrorView
{
    [CmdletBinding()]
    param(
        [System.Management.Automation.ErrorRecord]$InputObject
    )

    $template = Get-ErrorTemplate -ErrorRecord $InputObject
    $translatedMessage = Translate-ErrorMessage -Message $InputObject.Exception.Message -ExceptionType $InputObject.Exception.GetType().Name

    return "$( $template.Icon ) $translatedMessage"
}
#endregion

#region Функции управления конфигурацией
function Set-ErrorViewConfig
{
    param(
        [string]$Language,
        [bool]$AutoTranslate,
        [bool]$ShowStackTrace,
        [bool]$ShowInnerExceptions,
        [bool]$UseColors,
        [bool]$LogErrors,
        [string]$LogPath,
        [bool]$NotifyOnCritical
    )

    if ($Language)
    {
        $ErrorViewConfig.Language = $Language
    }
    if ( $PSBoundParameters.ContainsKey('AutoTranslate'))
    {
        $ErrorViewConfig.AutoTranslate = $AutoTranslate
    }
    if ( $PSBoundParameters.ContainsKey('ShowStackTrace'))
    {
        $ErrorViewConfig.ShowStackTrace = $ShowStackTrace
    }
    if ( $PSBoundParameters.ContainsKey('ShowInnerExceptions'))
    {
        $ErrorViewConfig.ShowInnerExceptions = $ShowInnerExceptions
    }
    if ( $PSBoundParameters.ContainsKey('UseColors'))
    {
        $ErrorViewConfig.UseColors = $UseColors
    }
    if ( $PSBoundParameters.ContainsKey('LogErrors'))
    {
        $ErrorViewConfig.LogErrors = $LogErrors
    }
    if ($LogPath)
    {
        $ErrorViewConfig.LogPath = $LogPath
    }
    if ( $PSBoundParameters.ContainsKey('NotifyOnCritical'))
    {
        $ErrorViewConfig.NotifyOnCritical = $NotifyOnCritical
    }

    wrgb "Конфигурация обновлена!" -FC Green
}

function Get-ErrorViewConfig
{
    return $ErrorViewConfig
}

function Add-ErrorTemplate
{
    param(
        [string]$ExceptionType,
        [string]$Icon,
        [string]$Pattern,
        [string]$Template,
        [string]$Suggestion,
        [string]$Color = "Red"
    )

    $ErrorTemplates[$ExceptionType] = @{
        Icon = $Icon
        Pattern = $Pattern
        Template = $Template
        Suggestion = $Suggestion
        Color = $Color
    }

    wrgb "Добавлен шаблон для $ExceptionType" -FC Green
}

function Add-ErrorTranslation
{
    param(
        [string]$Pattern,
        [string]$Translation
    )

    $ErrorTranslations[$Pattern] = $Translation
    wrgb "Добавлен перевод для '$Pattern'" -FC Green
}
#endregion

#region Глобальный обработчик ошибок
function Enable-GlobalErrorHandler
{
    # Устанавливаем умный обработчик ошибок по умолчанию
    $global:ErrorView = "Smart"
    #    wrgb "✅  Включен глобальный обработчик ошибок: " -FC TealRGB
    #    wrgb  $global:ErrorView -BC GoldRGB -FC BlackRGB -Style Bold -newline
}

function Disable-GlobalErrorHandler
{

    wrgb "❌ Отключен глобальный обработчик ошибок: " -FC Material_Yellow
    wrgb $global:ErrorView -FC WhiteRGB
    $global:ErrorView = "Simple"
}
#endregion


# Включаем умный обработчик
Enable-GlobalErrorHandler
#Clear-Host



function errorMethodsInfo
{
    wrgb "`n--- Конфигурация системы ---" -FC Yellow
    wrgb "Текущая конфигурация:" -FC Material_Pink -newline
    $config = Get-ErrorViewConfig
    $i = 0
    $config.GetEnumerator() | Sort-Object Key | ForEach-Object {
        wrgb   $_.Key" :  " -FC Gray
        $color = Get-GradientColor -Index (++$i) -TotalItems 4 -StartColor "#0057B7" -EndColor "#FFD700"
        wrgb   $_.Value -FC $color -newline
    }

    wrgb "`n--- Доступные команды ---" -FC Yellow
    @(
        "Enable-GlobalErrorHandler  - включить умный обработчик",
        "Disable-GlobalErrorHandler - отключить умный обработчик",
        "Set-ErrorViewConfig        - изменить настройки",
        "Add-ErrorTemplate          - добавить шаблон ошибки",
        "Add-ErrorTranslation       - добавить перевод",
        "Format-Error Smart         - показать ошибку с умной обработкой",
        "Format-Error Compact       - показать ошибку в компактном виде"
    ) | ForEach-Object {
        wrgb "  $_" -FC White -newline
    }

    #wrgb "`n--- Пример кастомизации ---" -FC Yellow

    # Добавляем кастомный шаблон
    Add-ErrorTemplate -ExceptionType "CustomException" -Icon "🎯" -Pattern "custom.*error" -Template "{Icon} Кастомная ошибка: {Message}" -Suggestion "💡 Обратитесь к документации"

    # Добавляем кастомный перевод
    Add-ErrorTranslation -Pattern "custom error occurred" -Translation "произошла кастомная ошибка"
    #wrgb "`nСистема готова к использованию! 🚀" -FC Green
    #wrgb "Все ошибки теперь будут автоматически обрабатываться с переводом и умными подсказками." -FC White

    # Показываем информацию о логах
    if ($ErrorViewConfig.LogErrors)
    {
        wrgb "`n📝 Ошибки логируются в: " -FC "Material_Comment"
        wrgb  $ErrorViewConfig.LogPath  -BC "#162022" -FC "#000000"
    }
    else
    {
        Write-Host ""
    }
}


Trace-ImportProcess  $MyInvocation.MyCommand.Name.trim(".ps1")
