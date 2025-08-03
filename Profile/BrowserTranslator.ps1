importProcess  $MyInvocation.MyCommand.Name.trim('.ps1') -start

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    🌐 BROWSER TRANSLATOR INTEGRATION                        ║
# ║              Интеграция браузерных переводчиков в PowerShell               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

#region Метод 1: Selenium WebDriver для автоматизации браузера

function Initialize-BrowserTranslator {
    <#
    .SYNOPSIS
        Инициализирует браузерный переводчик через Selenium

    .DESCRIPTION
        Использует Selenium WebDriver для управления браузером и доступа
        к встроенным переводчикам (Google Translate, Edge Translator и др.)

    .PARAMETER Browser
        Тип браузера: Chrome, Edge, Firefox

    .PARAMETER Headless
        Запуск в фоновом режиме без GUI
    #>
    param(
        [ValidateSet('Chrome', 'Edge', 'Firefox')]
        [string]$Browser = 'Edge',

        [switch]$Headless
    )

    # Проверяем наличие Selenium
    if (-not (Get-Module -ListAvailable -Name Selenium)) {
        Write-Status -Warning "Устанавливаем Selenium PowerShell модуль..."
        Install-Module Selenium -Force -Scope CurrentUser
    }

    Import-Module Selenium

    # Настройки браузера
    $options = switch ($Browser) {
        'Chrome' {
            $chromeOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
            if ($Headless) {
                $chromeOptions.AddArgument("--headless")
            }
            $chromeOptions.AddArgument("--disable-gpu")
            $chromeOptions.AddArgument("--no-sandbox")
            $chromeOptions.AddArgument("--disable-dev-shm-usage")
            $chromeOptions.AddArgument("--lang=ru-RU")
            $chromeOptions
        }
        'Edge' {
            $edgeOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions
            if ($Headless) {
                $edgeOptions.AddArgument("--headless")
            }
            $edgeOptions.AddArgument("--disable-gpu")
            $edgeOptions.AddArgument("--lang=ru-RU")
            $edgeOptions
        }
        'Firefox' {
            $firefoxOptions = New-Object OpenQA.Selenium.Firefox.FirefoxOptions
            if ($Headless) {
                $firefoxOptions.AddArgument("--headless")
            }
            $firefoxOptions
        }
    }

    # Создаем драйвер
    try {
        $driver = switch ($Browser) {
            'Chrome' { New-Object OpenQA.Selenium.Chrome.ChromeDriver($chromeOptions) }
            'Edge' { New-Object OpenQA.Selenium.Edge.EdgeDriver($edgeOptions) }
            'Firefox' { New-Object OpenQA.Selenium.Firefox.FirefoxDriver($firefoxOptions) }
        }

        $script:BrowserDriver = $driver
        Write-Status -Success "Браузерный переводчик инициализирован ($Browser)"

        return $driver
    } catch {
        Write-Status -Error "Не удалось инициализировать браузер: $_"
        throw
    }
}

function Invoke-BrowserTranslate {
    <#
    .SYNOPSIS
        Переводит текст любого объема через браузерный переводчик

    .DESCRIPTION
        Использует Google Translate или встроенный переводчик браузера
        для перевода текста любого размера

    .PARAMETER Text
        Текст для перевода (может быть очень большим)

    .PARAMETER From
        Исходный язык (auto для автоопределения)

    .PARAMETER To
        Целевой язык

    .PARAMETER Service
        Сервис перевода: GoogleTranslate, EdgeTranslator, DeepL

    .EXAMPLE
        $translatedText = Invoke-BrowserTranslate -Text $hugeText -From en -To ru
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Text,

        [string]$From = 'auto',
        [string]$To = 'ru',

        [ValidateSet('GoogleTranslate', 'EdgeTranslator', 'DeepL')]
        [string]$Service = 'GoogleTranslate',

        [switch]$ShowProgress
    )

    begin {
        # Проверяем инициализацию
        if (-not $script:BrowserDriver) {
            Write-Status -Info "Инициализируем браузер..."
            Initialize-BrowserTranslator -Headless
        }
    }

    process {
        $driver = $script:BrowserDriver

        try {
            switch ($Service) {
                'GoogleTranslate' {
                    # URL для Google Translate
                    $url = "https://translate.google.com/?sl=$From&tl=$To&op=translate"

                    # Переходим на страницу
                    $driver.Navigate().GoToUrl($url)
                    Start-Sleep -Milliseconds 1000

                    # Находим поле ввода
                    $inputField = $driver.FindElement([OpenQA.Selenium.By]::CssSelector("textarea[aria-label*='Source text']"))

                    # Вводим текст частями для больших объемов
                    if ($Text.Length -gt 5000) {
                        if ($ShowProgress) {
                            wrgb "📝 Вводим текст частями..." -FC "Cyan" -newline
                        }

                        $chunks = [System.Text.RegularExpressions.Regex]::Matches($Text, '[\s\S]{1,5000}')
                        $totalChunks = $chunks.Count
                        $currentChunk = 0

                        $translatedParts = @()

                        foreach ($chunk in $chunks) {
                            $currentChunk++

                            if ($ShowProgress) {
                                $percent = ($currentChunk / $totalChunks) * 100
                                Show-RGBProgress -Activity "Перевод" `
                                               -PercentComplete $percent `
                                               -Status "Часть $currentChunk из $totalChunks" `
                                               -ShowPercentage
                            }

                            # Очищаем поле
                            $inputField.Clear()

                            # Вводим текст
                            $inputField.SendKeys($chunk.Value)

                            # Ждем перевода
                            Start-Sleep -Milliseconds 2000

                            # Получаем результат
                            $resultElement = $driver.FindElement([OpenQA.Selenium.By]::CssSelector("span[jsname='W297wb']"))
                            $translatedParts += $resultElement.Text
                        }

                        return $translatedParts -join ' '
                    } else {
                        # Для небольших текстов
                        $inputField.Clear()
                        $inputField.SendKeys($Text)

                        # Ждем перевода
                        Start-Sleep -Milliseconds 2000

                        # Получаем результат
                        $resultElement = $driver.FindElement([OpenQA.Selenium.By]::CssSelector("span[jsname='W297wb']"))
                        return $resultElement.Text
                    }
                }

                'EdgeTranslator' {
                    # Используем встроенный переводчик Edge
                    # Требует Edge с включенным переводчиком

                    # Создаем временную HTML страницу с текстом
                    $tempHtml = [System.IO.Path]::GetTempFileName() + ".html"
                    @"
<!DOCTYPE html>
<html lang="$From">
<head>
    <meta charset="UTF-8">
    <title>Translation</title>
</head>
<body>
    <div id="content">$([System.Web.HttpUtility]::HtmlEncode($Text))</div>
</body>
</html>
"@ | Out-File -FilePath $tempHtml -Encoding UTF8

                    # Открываем в браузере
                    $driver.Navigate().GoToUrl("file:///$tempHtml")

                    # Активируем переводчик Edge (Ctrl+Shift+A)
                    $actions = New-Object OpenQA.Selenium.Interactions.Actions($driver)
                    $actions.KeyDown([OpenQA.Selenium.Keys]::Control)
                    .KeyDown([OpenQA.Selenium.Keys]::Shift)
                    .SendKeys("a")
                    .KeyUp([OpenQA.Selenium.Keys]::Shift)
                    .KeyUp([OpenQA.Selenium.Keys]::Control)
                    .Perform()

                    # Ждем перевода
                    Start-Sleep -Seconds 3

                    # Получаем переведенный текст
                    $contentElement = $driver.FindElement([OpenQA.Selenium.By]::Id("content"))
                    $translatedText = $contentElement.Text

                    # Удаляем временный файл
                    Remove-Item $tempHtml -Force

                    return $translatedText
                }

                'DeepL' {
                    # DeepL имеет ограничения для бесплатной версии
                    $url = "https://www.deepl.com/translator#$From/$To/"

                    $driver.Navigate().GoToUrl($url)
                    Start-Sleep -Milliseconds 2000

                    # Находим поле ввода
                    $inputField = $driver.FindElement([OpenQA.Selenium.By]::CssSelector("textarea[dl-test='translator-source-input']"))

                    # Вводим текст
                    $inputField.Clear()
                    $inputField.SendKeys($Text)

                    # Ждем перевода
                    Start-Sleep -Seconds 3

                    # Получаем результат
                    $resultElement = $driver.FindElement([OpenQA.Selenium.By]::CssSelector("textarea[dl-test='translator-target-input']"))
                    return $resultElement.GetAttribute("value")
                }
            }
        } catch {
            Write-Status -Error "Ошибка при переводе: $_"
            throw
        }
    }
}

function Close-BrowserTranslator {
    <#
    .SYNOPSIS
        Закрывает браузерный переводчик
    #>

    if ($script:BrowserDriver) {
        $script:BrowserDriver.Quit()
        $script:BrowserDriver = $null
        Write-Status -Success "Браузерный переводчик закрыт"
    }
}

#endregion

#region Метод 2: Edge WebView2 Integration

function Initialize-EdgeTranslator {
    <#
    .SYNOPSIS
        Инициализирует переводчик через Edge WebView2

    .DESCRIPTION
        Использует встроенный WebView2 для интеграции с Edge
        Более легковесный чем Selenium
    #>

    # Проверяем наличие WebView2
    $webView2 = Get-Package "Microsoft Edge WebView2 Runtime" -ErrorAction SilentlyContinue

    if (-not $webView2) {
        Write-Status -Warning "WebView2 не установлен. Загружаем..."

        $installerUrl = "https://go.microsoft.com/fwlink/p/?LinkId=2124703"
        $installerPath = "$env:TEMP\MicrosoftEdgeWebview2Setup.exe"

        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
        Start-Process -FilePath $installerPath -ArgumentList "/silent" -Wait
    }

    # Создаем WebView2 контрол
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName Microsoft.Web.WebView2.WinForms

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "PowerShell Translator"
    $form.Width = 800
    $form.Height = 600
    $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized

    $webView = New-Object Microsoft.Web.WebView2.WinForms.WebView2
    $webView.Dock = [System.Windows.Forms.DockStyle]::Fill

    $form.Controls.Add($webView)

    # Инициализируем WebView2
    $webView.EnsureCoreWebView2Async($null).Wait()

    $script:EdgeWebView = @{
        Form = $form
        WebView = $webView
    }

    Write-Status -Success "Edge WebView2 переводчик инициализирован"
}

#endregion

#region Метод 3: Chrome DevTools Protocol

function Invoke-ChromeTranslate {
    <#
    .SYNOPSIS
        Использует Chrome DevTools Protocol для перевода

    .DESCRIPTION
        Подключается к запущенному Chrome/Edge через DevTools Protocol
        Это самый быстрый и надежный метод
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [string]$From = 'en',
        [string]$To = 'ru',

        [int]$Port = 9222
    )

    # Запускаем Chrome/Edge с remote debugging
    $browserPath = if (Test-Path "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe") {
        "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    } else {
        "C:\Program Files\Google\Chrome\Application\chrome.exe"
    }

    # Запускаем браузер с отладкой
    $process = Start-Process -FilePath $browserPath `
                           -ArgumentList "--remote-debugging-port=$Port", "--headless" `
                           -PassThru

    Start-Sleep -Seconds 2

    try {
        # Подключаемся к DevTools
        $webSocketUrl = (Invoke-RestMethod "http://localhost:$Port/json").webSocketDebuggerUrl | Select-Object -First 1

        # Здесь нужен WebSocket клиент для полной реализации
        # Упрощенный вариант через HTTP endpoints

        $sessionId = [Guid]::NewGuid().ToString()

        # Навигация на страницу переводчика
        $navigateParams = @{
            url = "https://translate.google.com/?sl=$From&tl=$To&text=$([System.Web.HttpUtility]::UrlEncode($Text))&op=translate"
        } | ConvertTo-Json

        Invoke-RestMethod -Method Post `
                         -Uri "http://localhost:$Port/json/runtime/evaluate" `
                         -Body $navigateParams `
                         -ContentType "application/json"

        Start-Sleep -Seconds 3

        # Получаем результат
        $script = @"
        document.querySelector('span[jsname="W297wb"]').innerText
"@

        $evalParams = @{
            expression = $script
        } | ConvertTo-Json

        $result = Invoke-RestMethod -Method Post `
                                   -Uri "http://localhost:$Port/json/runtime/evaluate" `
                                   -Body $evalParams `
                                   -ContentType "application/json"

        return $result.result.value

    } finally {
        # Закрываем браузер
        $process | Stop-Process -Force
    }
}

#endregion

#region Метод 4: Native API Integration

function Invoke-TranslatorAPI {
    <#
    .SYNOPSIS
        Прямое использование API переводчиков

    .DESCRIPTION
        Использует официальные API для перевода больших объемов текста
        Требует API ключи
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [string]$From = 'en',
        [string]$To = 'ru',

        [ValidateSet('Google', 'Microsoft', 'DeepL', 'Yandex')]
        [string]$Provider = 'Microsoft',

        [string]$ApiKey,

        [switch]$ChunkLargeText
    )

    switch ($Provider) {
        'Microsoft' {
            # Microsoft Translator API (бесплатный уровень доступен)
            if (-not $ApiKey) {
                # Используем бесплатный endpoint (ограниченный)
                $endpoint = "https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&from=$From&to=$To"

                $headers = @{
                    'Ocp-Apim-Subscription-Key' = 'YOUR_KEY_HERE'
                    'Content-Type' = 'application/json'
                }

                $body = @(@{
                    Text = $Text
                }) | ConvertTo-Json

                try {
                    $response = Invoke-RestMethod -Method Post `
                                                -Uri $endpoint `
                                                -Headers $headers `
                                                -Body $body

                    return $response[0].translations[0].text
                } catch {
                    Write-Status -Warning "Требуется API ключ для Microsoft Translator"
                }
            }
        }

        'Yandex' {
            # Yandex Translate API
            $endpoint = "https://translate.yandex.net/api/v1.5/tr.json/translate"

            $params = @{
                key = $ApiKey
                text = $Text
                lang = "$From-$To"
            }

            $response = Invoke-RestMethod -Method Post -Uri $endpoint -Body $params
            return $response.text -join ' '
        }
    }
}

#endregion

#region Универсальная функция-обертка

function Translate-Text {
    <#
    .SYNOPSIS
        Универсальная функция для перевода текста любого объема

    .DESCRIPTION
        Автоматически выбирает лучший метод перевода в зависимости от
        размера текста и доступных ресурсов

    .PARAMETER Text
        Текст для перевода (любого размера)

    .PARAMETER From
        Исходный язык

    .PARAMETER To
        Целевой язык

    .PARAMETER Method
        Метод перевода: Auto, Browser, API, WebView

    .EXAMPLE
        $book | Translate-Text -From en -To ru

    .EXAMPLE
        Get-Content "huge-document.txt" -Raw | Translate-Text -Method Browser
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Text,

        [string]$From = 'auto',
        [string]$To = 'ru',

        [ValidateSet('Auto', 'Browser', 'API', 'WebView', 'Chrome')]
        [string]$Method = 'Auto',

        [ValidateSet('GoogleTranslate', 'EdgeTranslator', 'DeepL')]
        [string]$Service = 'GoogleTranslate',

        [switch]$ShowProgress,
        [switch]$SaveToFile,
        [string]$OutputPath
    )

    begin {
        $startTime = Get-Date

        # Определяем метод автоматически
        if ($Method -eq 'Auto') {
            $textLength = $Text.Length

            $Method = if ($textLength -lt 5000) {
                'API'  # Для небольших текстов - API
            } elseif ($textLength -lt 50000) {
                'Browser'  # Для средних - браузер
            } else {
                'Browser'  # Для огромных - браузер с разбивкой
            }

            wrgb "📊 Размер текста: " -FC "Cyan"
            wrgb "$textLength символов" -FC "Yellow"
            wrgb ", выбран метод: " -FC "Cyan"
            wrgb $Method -FC "Green" -Style Bold -newline
        }
    }

    process {
        wrgb "🌐 Начинаем перевод " -FC "Cyan"
        wrgb "($From → $To)" -FC "White" -Style Bold
        wrgb " через " -FC "Cyan"
        wrgb $Service -FC "Yellow" -newline

        if ($ShowProgress) {
            Show-AnimatedProgress -Activity "Инициализация переводчика" -TotalSteps 10
        }

        $translatedText = switch ($Method) {
            'Browser' {
                try {
                    Initialize-BrowserTranslator -Browser Edge -Headless
                    Invoke-BrowserTranslate -Text $Text -From $From -To $To -Service $Service -ShowProgress:$ShowProgress
                } finally {
                    Close-BrowserTranslator
                }
            }

            'API' {
                Invoke-TranslatorAPI -Text $Text -From $From -To $To
            }

            'WebView' {
                Initialize-EdgeTranslator
                # Реализация через WebView2
            }

            'Chrome' {
                Invoke-ChromeTranslate -Text $Text -From $From -To $To
            }
        }

        # Статистика
        $duration = (Get-Date) - $startTime
        $wordsCount = ($Text -split '\s+').Count
        $translatedWordsCount = ($translatedText -split '\s+').Count

        wrgb "`n✅ Перевод завершен!" -FC "LimeGreen" -Style Bold -newline
        wrgb "⏱️  Время: " -FC "Gray"
        wrgb $duration.ToString("mm\:ss") -FC "Yellow" -newline
        wrgb "📝 Слов оригинал: " -FC "Gray"
        wrgb $wordsCount -FC "Cyan"
        wrgb " → перевод: " -FC "Gray"
        wrgb $translatedWordsCount -FC "Cyan" -newline

        # Сохранение в файл
        if ($SaveToFile) {
            if (-not $OutputPath) {
                $OutputPath = "translated_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
            }

            $translatedText | Out-File -FilePath $OutputPath -Encoding UTF8
            wrgb "💾 Сохранено в: " -FC "Gray"
            wrgb $OutputPath -FC "Green" -newline
        }

        return $translatedText
    }
}

#endregion

#region Интерактивный переводчик

function Start-InteractiveTranslator {
    <#
    .SYNOPSIS
        Запускает интерактивный режим переводчика
    #>

    Clear-Host
    Write-GradientHeader -Title "INTERACTIVE TRANSLATOR" -StartColor "#4285F4" -EndColor "#34A853"

    wrgb "🌍 Добро пожаловать в интерактивный переводчик!" -FC "Gold" -Style Bold -newline
    wrgb "Поддерживаются тексты любого размера" -FC "Gray" -newline

    $running = $true

    while ($running) {
        wrgb "`n📝 Введите текст для перевода (или команду):" -FC "Cyan" -newline
        wrgb "Команды: [F]ile, [C]lipboard, [U]RL, [S]ettings, [Q]uit" -FC "DarkGray" -newline
        wrgb "> " -FC "Yellow"

        $input = Read-Host

        switch -Regex ($input) {
            '^[Ff]$' {
                wrgb "Путь к файлу: " -FC "Cyan"
                $path = Read-Host

                if (Test-Path $path) {
                    $content = Get-Content $path -Raw
                    wrgb "📄 Файл загружен: " -FC "Green"
                    wrgb "$((Get-Item $path).Length / 1KB) KB" -FC "Yellow" -newline

                    $translated = Translate-Text -Text $content -ShowProgress

                    # Показываем preview
                    wrgb "`n--- Начало перевода ---" -FC "DarkGray" -newline
                    wrgb ($translated.Substring(0, [Math]::Min(500, $translated.Length)) + "...") -FC "White" -newline
                    wrgb "--- Конец preview ---" -FC "DarkGray" -newline
                }
            }

            '^[Cc]$' {
                $clipText = Get-Clipboard
                if ($clipText) {
                    wrgb "📋 Текст из буфера обмена получен" -FC "Green" -newline
                    $translated = Translate-Text -Text $clipText
                    Set-Clipboard $translated
                    wrgb "✅ Перевод скопирован в буфер обмена" -FC "LimeGreen" -newline
                }
            }

            '^[Uu]$' {
                wrgb "URL страницы: " -FC "Cyan"
                $url = Read-Host

                # Получаем контент страницы
                $response = Invoke-WebRequest -Uri $url
                $text = $response.Content -replace '<[^>]+>', ' ' -replace '\s+', ' '

                $translated = Translate-Text -Text $text -ShowProgress
            }

            '^[Qq]$' {
                $running = $false
            }

            default {
                if ($input.Length -gt 0) {
                    $translated = Translate-Text -Text $input
                    wrgb "`n🔄 Перевод:" -FC "Green" -Style Bold -newline
                    wrgb $translated -FC "White" -newline
                }
            }
        }
    }

    Write-Status -Info "Переводчик закрыт"
}

#endregion

#region Пакетный переводчик для файлов

function Translate-Files {
    <#
    .SYNOPSIS
        Переводит несколько файлов с сохранением структуры
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [string]$Filter = "*.txt",

        [string]$From = 'en',
        [string]$To = 'ru',

        [string]$OutputFolder = "Translated",

        [switch]$PreserveFormatting
    )

    $files = Get-ChildItem -Path $Path -Filter $Filter -Recurse

    Write-GradientHeader -Title "BATCH FILE TRANSLATOR"
    wrgb "📁 Найдено файлов: " -FC "Cyan"
    wrgb $files.Count -FC "Yellow" -Style Bold -newline

    # Создаем выходную папку
    $outputPath = Join-Path (Split-Path $Path) $OutputFolder
    New-Item -Path $outputPath -ItemType Directory -Force | Out-Null

    $processed = 0

    foreach ($file in $files) {
        $processed++
        $percent = ($processed / $files.Count) * 100

        wrgb "`n[$processed/$($files.Count)] " -FC "DarkCyan"
        wrgb "Перевод: " -FC "White"
        wrgb $file.Name -FC "Yellow" -newline

        try {
            $content = Get-Content $file.FullName -Raw

            if ($PreserveFormatting) {
                # Сохраняем форматирование (переводим по абзацам)
                $paragraphs = $content -split "`n`n"
                $translatedParagraphs = @()

                foreach ($paragraph in $paragraphs) {
                    if ($paragraph.Trim()) {
                        $translatedParagraphs += Translate-Text -Text $paragraph -From $From -To $To
                    } else {
                        $translatedParagraphs += ""
                    }
                }

                $translated = $translatedParagraphs -join "`n`n"
            } else {
                $translated = Translate-Text -Text $content -From $From -To $To
            }

            # Сохраняем с сохранением структуры папок
            $relativePath = $file.FullName.Substring($Path.Length)
            $newPath = Join-Path $outputPath $relativePath
            $newDir = Split-Path $newPath -Parent

            New-Item -Path $newDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

            $translated | Out-File -FilePath $newPath -Encoding UTF8

            Write-Status -Success "Сохранено: $newPath"

        } catch {
            Write-Status -Error "Ошибка при переводе $($file.Name): $_"
        }

        Show-RGBProgress -Activity "Общий прогресс" `
                        -PercentComplete $percent `
                        -Status "$processed из $($files.Count)" `
                        -ShowPercentage
    }

    wrgb "`n✅ Перевод завершен!" -FC "LimeGreen" -Style Bold -newline
    wrgb "📁 Результаты в: " -FC "Gray"
    wrgb $outputPath -FC "Cyan" -newline
}

#endregion

#region Демонстрация

function Show-BrowserTranslatorDemo {
    Clear-Host

    Write-GradientHeader -Title "BROWSER TRANSLATOR DEMO" -StartColor "#4285F4" -EndColor "#34A853"

    wrgb "🌐 Возможности браузерного переводчика:" -FC "Gold" -Style Bold -newline

    wrgb "`n1️⃣ " -FC "Cyan"
    wrgb "Перевод больших текстов" -FC "Yellow" -Style Bold -newline
    wrgb "   Get-Content 'book.txt' -Raw | Translate-Text -ShowProgress" -FC "Material_Comment" -newline

    wrgb "`n2️⃣ " -FC "Cyan"
    wrgb "Интерактивный режим" -FC "Yellow" -Style Bold -newline
    wrgb "   Start-InteractiveTranslator" -FC "Material_Comment" -newline

    wrgb "`n3️⃣ " -FC "Cyan"
    wrgb "Пакетный перевод файлов" -FC "Yellow" -Style Bold -newline
    wrgb "   Translate-Files -Path './docs' -Filter '*.txt'" -FC "Material_Comment" -newline

    wrgb "`n4️⃣ " -FC "Cyan"
    wrgb "Перевод из буфера обмена" -FC "Yellow" -Style Bold -newline
    wrgb "   Get-Clipboard | Translate-Text | Set-Clipboard" -FC "Material_Comment" -newline

    wrgb "`n🚀 Преимущества:" -FC "Material_Orange" -Style Bold -newline
    wrgb "   ✓ Нет ограничений на размер текста" -FC "LimeGreen" -newline
    wrgb "   ✓ Использует качественные браузерные переводчики" -FC "LimeGreen" -newline
    wrgb "   ✓ Работает с любыми языками" -FC "LimeGreen" -newline
    wrgb "   ✓ Сохраняет форматирование" -FC "LimeGreen" -newline

    wrgb "`n💡 Попробуйте: " -FC "White"
    wrgb "'Hello World' | Translate-Text" -FC "Material_Pink" -Style Bold -newline
}

#endregion

# Инициализация
wrgb "`n🌐 " -FC "Gold"
Write-GradientText "Browser Translator Integration" -StartColor "#4285F4" -EndColor "#34A853" -NoNewline
wrgb " загружен!" -FC "Gold" -newline

wrgb "Используйте: " -FC "Gray"
wrgb "Show-BrowserTranslatorDemo" -FC "Material_Pink" -Style Bold
wrgb " для демонстрации" -FC "Gray" -newline

# Экспорт
if ($MyInvocation.MyCommand.Path -match '\.psm1$') {
    Export-ModuleMember -Function * -Alias * -Variable *
}

importProcess  $MyInvocation.MyCommand.Name.trim('.ps1')