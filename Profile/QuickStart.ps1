# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    🚀 QUICK START - BROWSER TRANSLATOR                      ║
# ║                        Быстрый старт для переводчика                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Установка необходимых компонентов
function Install-TranslatorDependencies {
    Write-RGB "📦 Установка зависимостей..." -FC "Cyan" -Style Bold -newline

    # Selenium PowerShell Module
    if (-not (Get-Module -ListAvailable -Name Selenium)) {
        Write-RGB "  • Устанавливаем Selenium..." -FC "Yellow"
        Install-Module -Name Selenium -Force -Scope CurrentUser
        Write-RGB " ✅" -FC "Green" -newline
    }

    # WebDriver для Edge
    if (-not (Test-Path "$env:USERPROFILE\.webdrivers\msedgedriver.exe")) {
        Write-RGB "  • Загружаем Edge WebDriver..." -FC "Yellow"

        # Создаем папку для драйверов
        New-Item -Path "$env:USERPROFILE\.webdrivers" -ItemType Directory -Force | Out-Null

        # Определяем версию Edge
        $edgeVersion = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe').'(Default)' |
                ForEach-Object { (Get-Item $_).VersionInfo.ProductVersion }

        # Загружаем соответствующий драйвер
        $driverUrl = "https://msedgedriver.azureedge.net/$edgeVersion/edgedriver_win64.zip"
        $zipPath = "$env:TEMP\edgedriver.zip"

        Invoke-WebRequest -Uri $driverUrl -OutFile $zipPath
        Expand-Archive -Path $zipPath -DestinationPath "$env:USERPROFILE\.webdrivers" -Force
        Remove-Item $zipPath

        Write-RGB " ✅" -FC "Green" -newline
    }

    # Добавляем в PATH
    if ($env:PATH -notlike "*$env:USERPROFILE\.webdrivers*") {
        $env:PATH += ";$env:USERPROFILE\.webdrivers"
    }

    Write-Status -Success "Все зависимости установлены!"
}

# Простейший пример использования
function Quick-Translate {
    <#
    .SYNOPSIS
        Самый простой способ перевести текст
        
    .EXAMPLE
        Quick-Translate "Hello, World!"
        
    .EXAMPLE
        "Welcome to PowerShell" | Quick-Translate -To es
    #>
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipeline)]
        [string]$Text,

        [string]$To = 'ru'
    )

    Write-RGB "🌐 Перевод на $To..." -FC "Cyan" -newline

    # Простой метод через Google Translate URL
    $encoded = [System.Web.HttpUtility]::UrlEncode($Text)
    $url = "https://translate.google.com/?sl=auto&tl=$To&text=$encoded&op=translate"

    # Открываем в браузере
    Start-Process $url

    Write-RGB "✅ Открыто в браузере!" -FC "Green" -newline
}

# Супер-простая версия с Selenium
function Simple-BrowserTranslate {
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Text,

        [string]$To = 'ru'
    )

    begin {
        Write-RGB "🤖 Запускаем браузер..." -FC "Cyan"

        Import-Module Selenium

        # Запускаем Edge в фоне
        $driver = Start-SeEdge -Headless
        Write-RGB " ✅" -FC "Green" -newline
    }

    process {
        try {
            # Переходим на Google Translate
            $driver.Navigate().GoToUrl("https://translate.google.com")
            Start-Sleep -Seconds 1

            # Вводим текст
            $inputBox = $driver.FindElementByClassName("er8xn")
            $inputBox.Clear()
            $inputBox.SendKeys($Text)

            # Ждем перевод
            Start-Sleep -Seconds 2

            # Получаем результат
            $result = $driver.FindElementByClassName("J0lOec").Text

            Write-RGB "📝 Оригинал: " -FC "Gray"
            Write-RGB $Text -FC "White" -newline
            Write-RGB "🔄 Перевод: " -FC "Gray"
            Write-RGB $result -FC "Green" -Style Bold -newline

            return $result

        } catch {
            Write-Status -Error "Ошибка перевода: $_"
        }
    }

    end {
        $driver.Quit()
        Write-RGB "👋 Браузер закрыт" -FC "DarkGray" -newline
    }
}

# Перевод файлов - простая версия
function Translate-FileSimple {
    param(
        [string]$Path,
        [string]$To = 'ru'
    )

    if (-not (Test-Path $Path)) {
        Write-Status -Error "Файл не найден: $Path"
        return
    }

    $content = Get-Content $Path -Raw
    $lines = $content -split "`n"

    Write-RGB "📄 Переводим файл: " -FC "Cyan"
    Write-RGB (Split-Path $Path -Leaf) -FC "Yellow" -Style Bold -newline
    Write-RGB "📏 Строк: " -FC "Gray"
    Write-RGB $lines.Count -FC "White" -newline

    # Создаем выходной файл
    $outPath = [System.IO.Path]::GetFileNameWithoutExtension($Path) + "_$To.txt"

    # Переводим построчно для простоты
    $translated = @()

    Import-Module Selenium
    $driver = Start-SeEdge -Headless

    try {
        $driver.Navigate().GoToUrl("https://translate.google.com")
        Start-Sleep -Seconds 1

        $i = 0
        foreach ($line in $lines) {
            $i++
            if ($line.Trim()) {
                Write-Progress -Activity "Перевод" -Status "Строка $i из $($lines.Count)" -PercentComplete (($i / $lines.Count) * 100)

                # Очищаем и вводим текст
                $inputBox = $driver.FindElementByClassName("er8xn")
                $inputBox.Clear()
                $inputBox.SendKeys($line)

                Start-Sleep -Milliseconds 1500

                # Получаем перевод
                $result = $driver.FindElementByClassName("J0lOec").Text
                $translated += $result
            } else {
                $translated += ""
            }
        }

        # Сохраняем результат
        $translated | Out-File -FilePath $outPath -Encoding UTF8

        Write-Progress -Activity "Перевод" -Completed
        Write-Status -Success "Перевод сохранен: $outPath"

    } finally {
        $driver.Quit()
    }
}

# Мини-версия интерактивного переводчика
function Mini-Translator {
    Write-GradientHeader -Title "MINI TRANSLATOR" -StartColor "#4285F4" -EndColor "#34A853"

    Write-RGB "💡 Команды: [Enter] - перевести, 'exit' - выход" -FC "DarkGray" -newline

    Import-Module Selenium
    $driver = Start-SeEdge -Headless

    try {
        $driver.Navigate().GoToUrl("https://translate.google.com")
        Start-Sleep -Seconds 1

        while ($true) {
            Write-RGB "`n📝 Текст: " -FC "Cyan"
            $text = Read-Host

            if ($text -eq 'exit') { break }
            if (-not $text) { continue }

            # Переводим
            $inputBox = $driver.FindElementByClassName("er8xn")
            $inputBox.Clear()
            $inputBox.SendKeys($text)

            Start-Sleep -Seconds 2

            $result = $driver.FindElementByClassName("J0lOec").Text

            Write-RGB "🔄 " -FC "Green"
            Write-RGB $result -FC "White" -Style Bold -newline
        }
    } finally {
        $driver.Quit()
    }
}

# Супер-быстрый способ через API (ограниченный)
function Lightning-Translate {
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Text,

        [string]$To = 'ru'
    )

    # Используем неофициальный API Google Translate (может перестать работать)
    $url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$To&dt=t&q=$([uri]::EscapeDataString($Text))"

    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
        $translation = $response[0][0][0]

        Write-RGB "⚡ " -FC "Yellow"
        Write-RGB $translation -FC "Green" -Style Bold -newline

        return $translation
    } catch {
        Write-Status -Error "API недоступен, используйте браузерный метод"
    }
}

# Примеры использования
function Show-TranslatorExamples {
    Clear-Host

    Write-GradientHeader -Title "TRANSLATOR EXAMPLES" -StartColor "#4285F4" -EndColor "#34A853"

    Write-RGB "🌐 Простые примеры использования:" -FC "Gold" -Style Bold -newline

    # Пример 1
    Write-RGB "`n1️⃣ Быстрый перевод текста:" -FC "Cyan" -newline
    Write-RGB "   " -FC "White"
    Write-RGB '"Hello, World!" | Lightning-Translate' -FC "Dracula_Comment" -newline
    "Hello, World!" | Lightning-Translate

    # Пример 2
    Write-RGB "`n2️⃣ Перевод в браузере:" -FC "Cyan" -newline
    Write-RGB "   " -FC "White"
    Write-RGB 'Quick-Translate "Welcome to PowerShell"' -FC "Dracula_Comment" -newline

    # Пример 3
    Write-RGB "`n3️⃣ Перевод из буфера обмена:" -FC "Cyan" -newline
    Write-RGB "   " -FC "White"
    Write-RGB 'Get-Clipboard | Lightning-Translate | Set-Clipboard' -FC "Dracula_Comment" -newline

    # Пример 4
    Write-RGB "`n4️⃣ Интерактивный мини-переводчик:" -FC "Cyan" -newline
    Write-RGB "   " -FC "White"
    Write-RGB 'Mini-Translator' -FC "Dracula_Comment" -newline

    # Пример 5
    Write-RGB "`n5️⃣ Перевод файла:" -FC "Cyan" -newline
    Write-RGB "   " -FC "White"
    Write-RGB 'Translate-FileSimple -Path "document.txt"' -FC "Dracula_Comment" -newline

    Write-RGB "`n💡 Полезные однострочники:" -FC "Yellow" -Style Bold -newline

    Write-RGB "`n# Перевести и озвучить:" -FC "Green" -newline
    Write-RGB '"Good morning" | Lightning-Translate | ForEach-Object { (New-Object -ComObject SAPI.SpVoice).Speak($_) }' -FC "White" -newline

    Write-RGB "`n# Перевести help команды:" -FC "Green" -newline
    Write-RGB 'Get-Help Get-Process | Out-String | Lightning-Translate' -FC "White" -newline

    Write-RGB "`n# Создать словарь:" -FC "Green" -newline
    Write-RGB '@("Hello", "Goodbye", "Thank you") | ForEach-Object { "$_ = $(Lightning-Translate $_)" }' -FC "White" -newline
}

# Автоустановка при первом запуске
$script:TranslatorInitialized = $false

function Initialize-TranslatorIfNeeded {
    if (-not $script:TranslatorInitialized) {
        if (-not (Get-Module -ListAvailable -Name Selenium)) {
            Write-RGB "⚡ Первый запуск - устанавливаем компоненты..." -FC "Yellow" -newline
            Install-TranslatorDependencies
        }
        $script:TranslatorInitialized = $true
    }
}

# Короткие алиасы
Set-Alias -Name tr -Value Lightning-Translate -Force
Set-Alias -Name translate -Value Translate-Text -Force
Set-Alias -Name mt -Value Mini-Translator -Force

Write-RGB "`n🌐 " -FC "Gold"
Write-GradientText "Quick Translator" -StartColor "#4285F4" -EndColor "#34A853" -NoNewline
Write-RGB " готов!" -FC "Gold" -newline

Write-RGB "`n⚡ Быстрые команды:" -FC "Cyan" -Style Bold -newline
Write-RGB "  • " -FC "DarkGray"
Write-RGB "tr" -FC "Yellow"
Write-RGB ' "Hello"' -FC "White"
Write-RGB " - молниеносный перевод" -FC "Gray" -newline

Write-RGB "  • " -FC "DarkGray"
Write-RGB "mt" -FC "Yellow"
Write-RGB " - мини-переводчик" -FC "Gray" -newline

Write-RGB "  • " -FC "DarkGray"
Write-RGB "Show-TranslatorExamples" -FC "Yellow"
Write-RGB " - примеры" -FC "Gray" -newline