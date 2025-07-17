function Write-RGB {
    param(
        [string]$Text,
        [string]$FC = "#FFFFFF",
        [switch]$newline
    )
    $esc = "`e"
    $rgb = $FC -replace "#", ""
    $r = [convert]::ToInt32($rgb.Substring(0,2),16)
    $g = [convert]::ToInt32($rgb.Substring(2,2),16)
    $b = [convert]::ToInt32($rgb.Substring(4,2),16)
    $seq = "$esc[38;2;${r};${g};${b}m$Text$esc[0m"
    if ($newline) { Write-Host $seq } else { Write-Host -NoNewline $seq }
}

param(
    [string]$Module
)

# Подключаем модуль Parser
if (-not (Get-Module -ListAvailable -Name Parser)) {
    Install-Module -Name Parser -Scope CurrentUser -Force
}
Import-Module Parser

# Папка для экспорта
$exportPath = "ast_exports"
if (-not (Test-Path $exportPath)) {
    New-Item -ItemType Directory -Path $exportPath | Out-Null
}

# Определяем модуль(и) для анализа
if ($Module) {
    $modules = Get-Module -ListAvailable -Name $Module
    if (-not $modules) {
        Write-RGB "❌ Модуль '$Module' не найден.`n" -FC "#FF4444"
        exit
    }
} else {
    $modules = Get-Module -ListAvailable
}

# Цветовая палитра
$colors = @("#FFB347", "#7FFFD4", "#ADD8E6", "#FF69B4", "#FFD700", "#98FB98", "#DA70D6", "#FF6347")
$colorIndex = 0

# Получаем все функции из выбранных модулей
$functions = $modules | ForEach-Object {
    try {
        Get-Command -Module $_.Name -CommandType Function
    } catch {}
} | Sort-Object Name -Unique

if (-not $functions) {
    Write-RGB "❗ Функции не найдены для анализа.`n" -FC "#FF8800"
    exit
}

# Анализ каждой функции
foreach ($func in $functions) {
    try {
        $name = $func.Name
        $module = $func.ModuleName
        $definition = $func.Definition

        if (-not $definition) { continue }

        $color = $colors[$colorIndex % $colors.Count]
        $colorIndex++

        Write-RGB "`n📦 Модуль: " -FC "#00CED1"; Write-RGB "$module`n" -FC "#AAAAAA"
        Write-RGB "⚙️  Функция: " -FC "#00FF00"; Write-RGB "$name`n" -FC "#FFFFFF"

        # Парсинг
        $parsed = Parse-Code -ScriptText $definition

        Write-RGB "🔍 Токены:`n" -FC "#FFAA00"
        foreach ($token in $parsed.Tokens) {
            $tokColor = switch ($token.Kind) {
                "Keyword"      { "#00FFFF" }
                "Identifier"   { $color }
                "StringLiteral"{ "#FF55FF" }
                "NumberLiteral"{ "#FFFF00" }
                "Comment"      { "#888888" }
                default        { "#DDDDDD" }
            }
            Write-RGB "  $($token.Kind): " -FC "#8888FF"
            Write-RGB "$($token.Text)`n" -FC $tokColor
        }

        # Экспорт AST
        $safeModule = $module -replace '[\\\/:*?"<>|]', '_'
        $safeName = $name -replace '[\\\/:*?"<>|]', '_'
        $astFile = Join-Path $exportPath "$safeModule`__$safeName.json"
        $parsed.Ast | ConvertTo-Json -Depth 10 | Out-File $astFile -Encoding utf8

        Write-RGB "💾 AST сохранён: $astFile`n" -FC "#44FF44"
        Write-RGB "────────────────────────────────────────────────────`n" -FC "#555555"

        Start-Sleep -Milliseconds 400

    } catch {
        Write-RGB "⚠️ Ошибка при анализе '$($func.Name)': $_`n" -FC "#FF0000"
    }
}
