importProcess  $MyInvocation.MyCommand.Name.trim('.ps1') -start

param(
    [string]$InputFolder = "ast_exports",
    [string]$OutputFile = "AST_Report.md"
)

# Проверка пути
if (-not (Test-Path $InputFolder)) {
    Write-Host "❌ Папка '$InputFolder' не найдена." -ForegroundColor Red
    exit
}

# Получаем все JSON-файлы
$jsonFiles = Get-ChildItem -Path $InputFolder -Filter "*.json" -File

if (-not $jsonFiles) {
    Write-Host "❗ Нет JSON-файлов для обработки." -ForegroundColor Yellow
    exit
}

# Хранилище Markdown
$markdown = @()
$markdown += "# 📘 AST Report"
$markdown += ""
$markdown += "_Сгенерировано $(Get-Date -Format 'yyyy-MM-dd HH:mm')_"
$markdown += ""

foreach ($file in $jsonFiles) {
    try {
        $ast = Get-Content $file -Raw | ConvertFrom-Json -Depth 20

        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
        $split = $baseName -split '__', 2
        $moduleName = $split[0]
        $funcName = $split[1]

        $markdown += "## ⚙️ Функция: `$funcName`"
        $markdown += "**Модуль:** `$moduleName`"
        $markdown += "**Файл:** `$($file.Name)`"
        $markdown += ""

        # Вывод AST как Markdown-дерево
        function Format-Ast {
            param($node, $indent = 0)
            $pad = ' ' * ($indent * 2)
            $type = $node.Type
            $extent = $node.Extent?.Text -replace "`r?`n", ' '
            if ($extent.Length -gt 60) { $extent = $extent.Substring(0, 57) + "..." }
            $line = "$pad- **$type**: `$extent`"
            return $line
        }

        function Walk-Ast {
            param($node, $indent = 0)
            $lines = @()
            $lines += Format-Ast -node $node -indent $indent
            if ($node.PipelineElements) {
                foreach ($child in $node.PipelineElements) {
                    $lines += Walk-Ast -node $child -indent ($indent + 1)
                }
            }
            if ($node.Commands) {
                foreach ($child in $node.Commands) {
                    $lines += Walk-Ast -node $child -indent ($indent + 1)
                }
            }
            if ($node.Body) {
                $lines += Walk-Ast -node $node.Body -indent ($indent + 1)
            }
            if ($node.Statements) {
                foreach ($child in $node.Statements) {
                    $lines += Walk-Ast -node $child -indent ($indent + 1)
                }
            }
            if ($node.Expression) {
                $lines += Walk-Ast -node $node.Expression -indent ($indent + 1)
            }
            return $lines
        }

        $tree = Walk-Ast -node $ast
        $markdown += "```markdown"
        $markdown += $tree
        $markdown += "```"
        $markdown += ""

    } catch {
        $markdown += "⚠️ Ошибка при обработке файла `$($file.Name)`"
        $markdown += ""
    }
}

# Сохраняем в файл
$markdown -join "`n" | Out-File -FilePath $OutputFile -Encoding utf8

Write-Host "✅ Markdown-отчёт сохранён: $OutputFile" -ForegroundColor Green

importProcess  $MyInvocation.MyCommand.Name.trim('.ps1')
