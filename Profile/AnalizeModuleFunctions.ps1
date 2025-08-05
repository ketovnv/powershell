Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

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
        wrgb "❌ Модуль '$Module' не найден.`n" -FC "#FF4444"
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
    wrgb "❗ Функции не найдены для анализа.`n" -FC "#FF8800"
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

        wrgb "`n📦 Модуль: " -FC "#00CED1"; wrgb "$module`n" -FC "#AAAAAA"
        wrgb "⚙️  Функция: " -FC "#00FF00"; wrgb "$name`n" -FC "#FFFFFF"

        # Парсинг
        $parsed = Parse-Code -ScriptText $definition

        wrgb "🔍 Токены:`n" -FC "#FFAA00"
        foreach ($token in $parsed.Tokens) {
            $tokColor = switch ($token.Kind) {
                "Keyword"      { "#00FFFF" }
                "Identifier"   { $color }
                "StringLiteral"{ "#FF55FF" }
                "NumberLiteral"{ "#FFFF00" }
                "Comment"      { "#888888" }
                default        { "#DDDDDD" }
            }
            wrgb "  $($token.Kind): " -FC "#8888FF"
            wrgb "$($token.Text)`n" -FC $tokColor
        }

        # Экспорт AST
        $safeModule = $module -replace '[\\\/:*?"<>|]', '_'
        $safeName = $name -replace '[\\\/:*?"<>|]', '_'
        $astFile = Join-Path $exportPath "$safeModule`__$safeName.json"
        $parsed.Ast | ConvertTo-Json -Depth 10 | Out-File $astFile -Encoding utf8

        wrgb "💾 AST сохранён: $astFile`n" -FC "#44FF44"
        wrgb "────────────────────────────────────────────────────`n" -FC "#555555"

        Start-Sleep -Milliseconds 400

    } catch {
        wrgb "⚠️ Ошибка при анализе '$($func.Name)': $_`n" -FC "#FF0000"
    }
}

Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))
