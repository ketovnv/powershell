Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

function Normalize-Path {
    param([string]$path)
    # Убираем эмодзи и любые неASCII символы
    return ($path -replace '[^\x20-\x7E]', '').ToLowerInvariant()
}

wrgb "Ищем внедрения..." -FC "#FFCC33" -newline

# Белый список с эмодзи в отображении, но чистим потом
$knownInjectors = @(
    '☎️C:\Program Files\MacType\mt64agnt.exe',
    '🔤C:\Program Files\MacType\MacTray.exe',
    '🦅C:\Program Files\Windhawk\windhawk.exe',
    '🧱C:\Windows\System32\lsass.exe'
)

# Очищенный список путей
$knownCleaned = $knownInjectors | ForEach-Object { Normalize-Path $_ }

wrgb "Доверенные процессы (игнорируются):" -FC "#1133CC" -newline
$knownInjectors | ForEach-Object { wrgb "- $_" -FC "#3399FF" -newline }

wrgb ("{0,-25} {1,-8} {2,-45} {3,-8} {4,-45}" -f "TimeCreated", "SrcPID", "SourceImage", "TgtPID", "TargetImage") -FC "#444444" -newline
$knownCleaned = $knownInjectors | ForEach-Object { Normalize-Path $_ }
# Данные
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational"  -ErrorAction SilentlyContinue |
Where-Object {
    $_.Id -eq 8 -and
    ($injector = Normalize-Path $_.Properties[4].Value) -and
    ($knownCleaned -notcontains $injector) -and
    -not ($_.Properties[4].Value -like '*\dwm.exe' -and $_.Properties[7].Value -like '*\csrss.exe')
} |
Sort-Object TimeCreated -Descending |
ForEach-Object {
    $time = $_.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
    $srcID = $_.Properties[3].Value
    $src = $_.Properties[4].Value
    $tgtID = $_.Properties[6].Value
    $tgt = $_.Properties[7].Value

    wrgb ("{0,-25}" -f $time) -FC "#AAAAAA"
    wrgb ("{0,-8}" -f $srcID) -FC "#FFAA00"
    wrgb ("{0,-45}" -f $src)   -FC "#FF5555"
    wrgb ("{0,-8}" -f $tgtID) -FC "#00CC66"
    wrgb ("{0,-45}" -f $tgt)   -FC "#00DDFF" -newline
}

wrgb "Поиск завершен" -FC "#3322FF" -newline
wrgb "Если вывод пуст - не найдено ничего подозрительного" -FC "#00FF77" -newline
wrgb "Если в списке есть процессы - это повод для серьезного расследования" -FC "#FF3355" -newline

Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))
