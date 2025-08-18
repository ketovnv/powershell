function Show-ErrorDetails
{
    param(
        [Parameter(ValueFromPipeline)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    if (!$ErrorRecord)
    {
        $ErrorRecord = Get-Error
    }
    if (!$ErrorRecord) {
        wrgb  " 🎡Ошибок не обнаружено 🎡" -FC NeonGreen
        return
    }
    $details = Get-ErrorDetails -ErrorRecord $ErrorRecord

    try
    {
        $smart = ConvertTo-SmartErrorView $ErrorRecord
        write-host $smart
    }
    catch
    {
        Format-Error -Recurse
        # Если что-то пошло не так с обработкой ошибки, возвращаем оригинальное сообщение
        write-host "❌ Внутренняя ошибка"
    }

    foreach ($Key in  $details.keys)
    {
        wrgb "${Key} : "  -FC White
        wrgb  $details[$Key] -FC Red -newline
    }

    wrgbn "`n╔══════════════════════════════════════════════════════════╗" -FC Material_Orange
    wrgbn "║                    Анализ Ошибки                         ║" -FC Material_Orange
    wrgbn "╚══════════════════════════════════════════════════════════╝" -FC Material_Orange

    # Основная информация
    Write-Host "`n📋 BASIC INFO:" -ForegroundColor Yellow
    Write-Host "  Type: " -NoNewline; Write-Host $details.Type -ForegroundColor Cyan
    Write-Host "  Category: " -NoNewline; Write-Host $details.Category -ForegroundColor Cyan

    # Сообщение
    Write-Host "`n💬 MESSAGE:" -ForegroundColor Yellow
    $details.Message -split "`n" | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Gray
    }

    # Пути
    if ($details.Paths)
    {
        Write-Host "`n📁 PATHS FOUND:" -ForegroundColor Yellow
        $details.Paths | ForEach-Object {
            $icon = if ($_.Exists)
            { "✅" }
            else
            { "❌" }
            $color = if ($_.Exists)
            { "Green" }
            else
            { "Red" }
            Write-Host "  $icon $( $_.Path )" -ForegroundColor $color
        }
    }

    # Местоположение ошибки
    if ($details.LineNumbers -or $details.ScriptLineNumber)
    {
        Write-Host "`n📍 LOCATION:" -ForegroundColor Yellow
        if ($details.ScriptName)
        {
            Write-Host "  File: $( $details.ScriptName )" -ForegroundColor Cyan
        }
        if ($details.LineNumbers)
        {
            Write-Host "  Lines: $( $details.LineNumbers -join ', ' )" -ForegroundColor Cyan
        }
        if ($details.ColumnNumbers)
        {
            Write-Host "  Columns: $( $details.ColumnNumbers -join ', ' )" -ForegroundColor Cyan
        }
    }

    # Функции
    if ($details.Functions)
    {
        Write-Host "`n🔧 FUNCTIONS:" -ForegroundColor Yellow
        $details.Functions | ForEach-Object {
            Write-Host "  • $_" -ForegroundColor Magenta
        }
    }

    # Переменные
    if ($details.Variables)
    {
        Write-Host "`n🔤 VARIABLES:" -ForegroundColor Yellow
        $details.Variables | ForEach-Object {
            Write-Host "  • $_" -ForegroundColor Blue
        }
    }

    # URL и сеть
    if ($details.Urls -or $details.IpAddresses -or $details.Ports)
    {
        Write-Host "`n🌐 NETWORK:" -ForegroundColor Yellow
        $details.Urls | ForEach-Object { Write-Host "  URL: $_" -ForegroundColor Cyan }
        $details.IpAddresses | ForEach-Object { Write-Host "  IP: $_" -ForegroundColor Cyan }
        $details.Ports | ForEach-Object { Write-Host "  Port: $_" -ForegroundColor Cyan }
    }

    # Коды ошибок
    if ($details.ErrorCodes)
    {
        Write-Host "`n🔢 ERROR CODES:" -ForegroundColor Yellow
        $details.ErrorCodes | ForEach-Object {
            Write-Host "  • $_" -ForegroundColor Red
        }
    }

    # Предложения
    if ($details.Suggestions)
    {
        Write-Host "`n💡 SUGGESTIONS:" -ForegroundColor Green
        $details.Suggestions | ForEach-Object {
            Write-Host "  → $_" -ForegroundColor Green
        }
    }

    # Stack trace
    if ($details.ScriptStackTrace)
    {
        Write-Host "`n📚 STACK TRACE:" -ForegroundColor Yellow
        $details.ScriptStackTrace -split "`n" | Select-Object -First 5 | ForEach-Object {
            Write-Host "  $_" -ForegroundColor DarkGray
        }
    }

    Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Red
}

# Алиас
Set-Alias sed Show-ErrorDetails