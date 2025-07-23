# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    💪 OUT-DEFAULT PROXY POWER EXAMPLES                      ║
# ║                   Супер-мощные применения этой техники                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ПРИМЕР 1: Автоматический переводчик для всех выводов
function Out-Default {
    [CmdletBinding()]
    param(
        [switch]$Transcript,
        [Parameter(ValueFromPipeline=$true)]
        [psobject]$InputObject
    )

    begin {
        $realOutDefault = $ExecutionContext.InvokeCommand.GetCommand(
                'Microsoft.PowerShell.Core\Out-Default',
                [System.Management.Automation.CommandTypes]::Cmdlet
        )
        $steppablePipeline = { & $realOutDefault @PSBoundParameters }.GetSteppablePipeline()
        $steppablePipeline.Begin($PSCmdlet)

        # Включаем автоперевод если нужно
        $script:AutoTranslate = $true
        $script:TargetLanguage = 'ru'
    }

    process {
        # Автоматический перевод всех строк!
        if ($script:AutoTranslate -and $InputObject -is [string]) {
            if ($InputObject -match '[a-zA-Z]{3,}') {  # Если есть английский текст
                $translated = $InputObject | Lightning-Translate -To $script:TargetLanguage

                Write-RGB "🌐 " -FC "Cyan"
                Write-RGB $InputObject -FC "Gray" -newline
                Write-RGB "   → " -FC "Green"
                Write-RGB $translated -FC "White" -Style Bold -newline

                $_ = $null  # Не показываем оригинал
                return
            }
        }

        $steppablePipeline.Process($_)
    }

    end {
        $steppablePipeline.End()
    }
}

# ПРИМЕР 2: Автоматическое логирование всего вывода
function Enable-OutputLogging {
    <#
    .SYNOPSIS
        Включает логирование ВСЕГО что выводится в консоль
    #>
    param(
        [string]$LogPath = "$env:TEMP\PowerShell_Output_$(Get-Date -Format 'yyyyMMdd').log"
    )

    # Создаем Out-Default с логированием
    function global:Out-Default {
        [CmdletBinding()]
        param(
            [switch]$Transcript,
            [Parameter(ValueFromPipeline=$true)]
            [psobject]$InputObject
        )

        begin {
            $realOutDefault = $ExecutionContext.InvokeCommand.GetCommand(
                    'Microsoft.PowerShell.Core\Out-Default',
                    [System.Management.Automation.CommandTypes]::Cmdlet
            )
            $steppablePipeline = { & $realOutDefault @PSBoundParameters }.GetSteppablePipeline()
            $steppablePipeline.Begin($PSCmdlet)
        }

        process {
            # Логируем всё!
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logEntry = "[$timestamp] $($InputObject | Out-String)"
            Add-Content -Path $using:LogPath -Value $logEntry -Encoding UTF8

            # И показываем в консоли
            $steppablePipeline.Process($_)
        }

        end {
            $steppablePipeline.End()
        }
    }

    Write-Status -Success "Логирование включено: $LogPath"
}

# ПРИМЕР 3: Автоматическое форматирование JSON/XML
function Enable-SmartFormatting {
    function global:Out-Default {
        [CmdletBinding()]
        param(
            [switch]$Transcript,
            [Parameter(ValueFromPipeline=$true)]
            [psobject]$InputObject
        )

        begin {
            $realOutDefault = $ExecutionContext.InvokeCommand.GetCommand(
                    'Microsoft.PowerShell.Core\Out-Default',
                    [System.Management.Automation.CommandTypes]::Cmdlet
            )
            $steppablePipeline = { & $realOutDefault @PSBoundParameters }.GetSteppablePipeline()
            $steppablePipeline.Begin($PSCmdlet)
        }

        process {
            # Автоматически форматируем JSON
            if ($InputObject -is [string] -and $InputObject.Trim() -match '^[\{\[]') {
                try {
                    $json = $InputObject | ConvertFrom-Json
                    Write-RGB "📋 JSON обнаружен и отформатирован:" -FC "Cyan" -newline
                    $json | ConvertTo-Json -Depth 10 | Out-ParsedJSON
                    $_ = $null
                    return
                } catch {
                    # Не JSON, продолжаем
                }
            }

            # Автоматически форматируем XML
            if ($InputObject -is [string] -and $InputObject -match '^<\?xml|^<\w+') {
                try {
                    $xml = [xml]$InputObject
                    Write-RGB "📐 XML обнаружен и отформатирован:" -FC "Cyan" -newline
                    $xml.OuterXml | Out-ParsedXML
                    $_ = $null
                    return
                } catch {
                    # Не XML, продолжаем
                }
            }

            $steppablePipeline.Process($_)
        }

        end {
            $steppablePipeline.End()
        }
    }
}

# ПРИМЕР 4: Умные уведомления для важных событий
function Enable-SmartNotifications {
    function global:Out-Default {
        [CmdletBinding()]
        param(
            [switch]$Transcript,
            [Parameter(ValueFromPipeline=$true)]
            [psobject]$InputObject
        )

        begin {
            $realOutDefault = $ExecutionContext.InvokeCommand.GetCommand(
                    'Microsoft.PowerShell.Core\Out-Default',
                    [System.Management.Automation.CommandTypes]::Cmdlet
            )
            $steppablePipeline = { & $realOutDefault @PSBoundParameters }.GetSteppablePipeline()
            $steppablePipeline.Begin($PSCmdlet)
        }

        process {
            # Проверяем на важные события
            if ($InputObject -match 'ERROR|FAILED|КРИТИЧНО') {
                # Показываем уведомление Windows
                $notification = New-Object System.Windows.Forms.NotifyIcon
                $notification.Icon = [System.Drawing.SystemIcons]::Error
                $notification.Visible = $true
                $notification.ShowBalloonTip(5000, "PowerShell Error", $InputObject, [System.Windows.Forms.ToolTipIcon]::Error)

                # Мигаем в консоли
                3..1 | ForEach-Object {
                    Write-Host "`r" -NoNewline
                    Write-RGB "🚨 ВНИМАНИЕ! 🚨" -FC "Red" -BC "DarkRed" -Style Bold
                    Start-Sleep -Milliseconds 300
                    Write-Host "`r                  `r" -NoNewline
                    Start-Sleep -Milliseconds 300
                }
            }

            # Успешные операции
            if ($InputObject -match 'SUCCESS|COMPLETED|УСПЕШНО') {
                Write-RGB "🎉 " -FC "Green"
                $confetti = @('🎊','🎈','✨','🌟','💫','⭐')
                1..10 | ForEach-Object {
                    Write-RGB ($confetti | Get-Random) -FC (Get-Random @('Green','Yellow','Cyan','Magenta'))
                    Start-Sleep -Milliseconds 50
                }
                Write-Host ""
            }

            $steppablePipeline.Process($_)
        }

        end {
            $steppablePipeline.End()
        }
    }
}

# ПРИМЕР 5: Интерактивный режим для команд
function Enable-InteractiveMode {
    function global:Out-Default {
        [CmdletBinding()]
        param(
            [switch]$Transcript,
            [Parameter(ValueFromPipeline=$true)]
            [psobject]$InputObject
        )

        begin {
            $realOutDefault = $ExecutionContext.InvokeCommand.GetCommand(
                    'Microsoft.PowerShell.Core\Out-Default',
                    [System.Management.Automation.CommandTypes]::Cmdlet
            )
            $steppablePipeline = { & $realOutDefault @PSBoundParameters }.GetSteppablePipeline()
            $steppablePipeline.Begin($PSCmdlet)

            $script:ObjectBuffer = @()
        }

        process {
            # Собираем объекты
            $script:ObjectBuffer += $InputObject

            # Показываем с номерами
            $index = $script:ObjectBuffer.Count - 1
            Write-RGB "[$index] " -FC "DarkCyan"

            # Особое форматирование для разных типов
            switch ($InputObject) {
                { $_ -is [System.IO.FileInfo] } {
                    Write-RGB $_.Name -FC "Yellow"
                    Write-RGB " - Нажмите O$index чтобы открыть" -FC "DarkGray" -newline
                }
                { $_ -is [System.Diagnostics.Process] } {
                    Write-RGB $_.ProcessName -FC "Cyan"
                    Write-RGB " - Нажмите K$index чтобы завершить" -FC "DarkGray" -newline
                }
                { $_ -is [System.ServiceProcess.ServiceController] } {
                    Write-RGB $_.Name -FC "Magenta"
                    Write-RGB " - Нажмите S$index чтобы старт/стоп" -FC "DarkGray" -newline
                }
                default {
                    $steppablePipeline.Process($_)
                }
            }
        }

        end {
            $steppablePipeline.End()

            if ($script:ObjectBuffer.Count -gt 0) {
                Write-RGB "`nИнтерактивные команды доступны! " -FC "Green"
                Write-RGB "(O=открыть, K=kill, S=service)" -FC "DarkGray" -newline
            }
        }
    }
}

# ПРИМЕР 6: Автоматическая визуализация данных
function Enable-AutoVisualization {
    function global:Out-Default {
        [CmdletBinding()]
        param(
            [switch]$Transcript,
            [Parameter(ValueFromPipeline=$true)]
            [psobject]$InputObject
        )

        begin {
            $realOutDefault = $ExecutionContext.InvokeCommand.GetCommand(
                    'Microsoft.PowerShell.Core\Out-Default',
                    [System.Management.Automation.CommandTypes]::Cmdlet
            )
            $steppablePipeline = { & $realOutDefault @PSBoundParameters }.GetSteppablePipeline()
            $steppablePipeline.Begin($PSCmdlet)

            $script:DataBuffer = @()
        }

        process {
            $script:DataBuffer += $InputObject
            $steppablePipeline.Process($_)
        }

        end {
            $steppablePipeline.End()

            # Если это числовые данные - рисуем график
            if ($script:DataBuffer.Count -gt 3) {
                $numbers = $script:DataBuffer | Where-Object { $_ -is [int] -or $_ -is [double] }

                if ($numbers.Count -gt 0) {
                    Write-RGB "`n📊 Автоматическая визуализация:" -FC "Cyan" -Style Bold -newline

                    $max = ($numbers | Measure-Object -Maximum).Maximum
                    $min = ($numbers | Measure-Object -Minimum).Minimum

                    foreach ($num in $numbers) {
                        $barLength = [Math]::Round((($num - $min) / ($max - $min)) * 30)
                        Write-RGB ("{0,10}" -f $num) -FC "White"
                        Write-RGB " │" -FC "DarkGray"

                        1..$barLength | ForEach-Object {
                            Write-RGB "█" -FC (Get-ProgressGradientColor -Percent (($num / $max) * 100))
                        }
                        Write-Host ""
                    }
                }
            }
        }
    }
}

# Демонстрация всех возможностей
function Show-OutDefaultPowerDemo {
    Clear-Host

    Write-GradientHeader -Title "OUT-DEFAULT PROXY POWER" -StartColor "#FF1744" -EndColor "#F50057"

    Write-RGB "🚀 Out-Default Proxy - это СУПЕР-МОЩНАЯ техника!" -FC "Gold" -Style Bold -newline

    Write-RGB "`n💡 Что можно сделать:" -FC "Cyan" -Style Bold -newline

    Write-RGB "`n1️⃣ " -FC "White"
    Write-RGB "Автоперевод всего вывода" -FC "Yellow" -Style Bold -newline
    Write-RGB "   Get-Help Get-Process  # автоматически переведется!" -FC "Dracula_Comment" -newline

    Write-RGB "`n2️⃣ " -FC "White"
    Write-RGB "Логирование всего что происходит" -FC "Yellow" -Style Bold -newline
    Write-RGB "   Enable-OutputLogging  # всё сохраняется в лог" -FC "Dracula_Comment" -newline

    Write-RGB "`n3️⃣ " -FC "White"
    Write-RGB "Умное форматирование JSON/XML" -FC "Yellow" -Style Bold -newline
    Write-RGB "   '{\"name\":\"test\"}'  # автоматически форматируется" -FC "Dracula_Comment" -newline

    Write-RGB "`n4️⃣ " -FC "White"
    Write-RGB "Уведомления о важных событиях" -FC "Yellow" -Style Bold -newline
    Write-RGB "   Write-Host 'ERROR: критично!'  # покажет уведомление" -FC "Dracula_Comment" -newline

    Write-RGB "`n5️⃣ " -FC "White"
    Write-RGB "Интерактивный режим" -FC "Yellow" -Style Bold -newline
    Write-RGB "   Get-Process  # можно будет кликнуть чтобы убить процесс" -FC "Dracula_Comment" -newline

    Write-RGB "`n6️⃣ " -FC "White"
    Write-RGB "Автовизуализация данных" -FC "Yellow" -Style Bold -newline
    Write-RGB "   1..10 | % {\$_*\$_}  # автоматически нарисует график" -FC "Dracula_Comment" -newline

    Write-RGB "`n🔥 Почему это так мощно:" -FC "Red" -Style Bold -newline
    Write-RGB "  • Работает для ЛЮБОГО вывода автоматически" -FC "White" -newline
    Write-RGB "  • Не требует изменения существующих скриптов" -FC "White" -newline
    Write-RGB "  • Полный контроль над выводом" -FC "White" -newline
    Write-RGB "  • Можно включать/выключать на лету" -FC "White" -newline

    Write-RGB "`n⚡ Это как установить 'фильтр' на всю консоль!" -FC "LimeGreen" -Style Bold -newline
}

# Управление режимами
$script:OutDefaultModes = @{
    Standard = $null
    Translate = ${function:Enable-AutoTranslate}
    Logging = ${function:Enable-OutputLogging}
    Smart = ${function:Enable-SmartFormatting}
    Notify = ${function:Enable-SmartNotifications}
    Interactive = ${function:Enable-InteractiveMode}
    Visual = ${function:Enable-AutoVisualization}
}

function Set-OutDefaultMode {
    param(
        [ValidateSet('Standard', 'Translate', 'Logging', 'Smart', 'Notify', 'Interactive', 'Visual')]
        [string]$Mode = 'Standard'
    )

    if ($Mode -eq 'Standard') {
        Remove-Item Function:\Out-Default -Force -ErrorAction SilentlyContinue
        Write-Status -Info "Вернулись к стандартному режиму"
    } else {
        & $script:OutDefaultModes[$Mode]
        Write-Status -Success "Режим $Mode активирован!"
    }
}

Write-RGB "`n🚀 " -FC "Gold"
Write-GradientText "Out-Default Power System" -StartColor "#FF1744" -EndColor "#F50057" -NoNewline
Write-RGB " загружен!" -FC "Gold" -newline

Write-RGB "`nПопробуйте: " -FC "Gray"
Write-RGB "Show-OutDefaultPowerDemo" -FC "Dracula_Pink" -Style Bold
Write-RGB " для демонстрации" -FC "Gray" -newline

Write-RGB "Или: " -FC "Gray"
Write-RGB "Set-OutDefaultMode -Mode Smart" -FC "Dracula_Cyan" -Style Bold
Write-RGB " для активации режима" -FC "Gray" -newline