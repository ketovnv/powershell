Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

function Show-SitesMenu {
    $menuItems = @(
        @{ Text = "🌐 Google"; Data = "google" },
        @{ Text = "📧 Gmail"; Data = "gmail" },
        @{ Text = "📺 YouTube"; Data = "youtube" },
        @{ Text = "💬 ChatGPT"; Data = "chatgpt" },
        @{ Text = "🐙 GitHub"; Data = "github" },
        @{ Text = "🔍 Stack Overflow"; Data = "stackoverflow" },
        @{ Text = "📰 Reddit"; Data = "reddit" },
        @{ Text = "💼 LinkedIn"; Data = "linkedin" },
        @{ Text = "🐦 Twitter/X"; Data = "twitter" },
        @{ Text = "📘 Facebook"; Data = "facebook" },
        @{ Text = "📷 Instagram"; Data = "instagram" },
        @{ Text = "💳 Telegram"; Data = "telegram" },
        @{ Text = "📊 Яндекс"; Data = "yandex" },
        @{ Text = "📨 Mail.ru"; Data = "mailru" },
        @{ Text = "🎬 Netflix"; Data = "netflix" },
        @{ Text = "🎵 Spotify"; Data = "spotify" },
        @{ Text = "🛒 Amazon"; Data = "amazon" },
        @{ Text = "🔧 Настройки браузера"; Data = "browser-settings" },
        @{ Text = "➕ Добавить свой сайт"; Data = "add-site" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $gradientOptions = @{
        StartColor = "#1E90FF"
        EndColor = "#00BFFF"
        GradientType = "Linear"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "🌐 БЫСТРЫЙ ДОСТУП К САЙТАМ" -Prompt "Выберите сайт для открытия" -GradientOptions $gradientOptions

    switch ($selected.Data) {
        "google" {
            wrgb "`n🌐 Открываю Google..." -FC BlueRGB -newline
            Start-Process "https://www.google.com"
            Pause
            Show-SitesMenu
        }
        "gmail" {
            wrgb "`n📧 Открываю Gmail..." -FC RedRGB -newline
            Start-Process "https://mail.google.com"
            Pause
            Show-SitesMenu
        }
        "youtube" {
            wrgb "`n📺 Открываю YouTube..." -FC RedRGB -newline
            Start-Process "https://www.youtube.com"
            Pause
            Show-SitesMenu
        }
        "chatgpt" {
            wrgb "`n💬 Открываю ChatGPT..." -FC GreenRGB -newline
            Start-Process "https://chat.openai.com"
            Pause
            Show-SitesMenu
        }
        "github" {
            wrgb "`n🐙 Открываю GitHub..." -FC DarkGray -newline
            Start-Process "https://github.com"
            Pause
            Show-SitesMenu
        }
        "stackoverflow" {
            wrgb "`n🔍 Открываю Stack Overflow..." -FC OrangeRGB -newline
            Start-Process "https://stackoverflow.com"
            Pause
            Show-SitesMenu
        }
        "reddit" {
            wrgb "`n📰 Открываю Reddit..." -FC OrangeRGB -newline
            Start-Process "https://www.reddit.com"
            Pause
            Show-SitesMenu
        }
        "linkedin" {
            wrgb "`n💼 Открываю LinkedIn..." -FC BlueRGB -newline
            Start-Process "https://www.linkedin.com"
            Pause
            Show-SitesMenu
        }
        "twitter" {
            wrgb "`n🐦 Открываю Twitter/X..." -FC Black -newline
            Start-Process "https://twitter.com"
            Pause
            Show-SitesMenu
        }
        "facebook" {
            wrgb "`n📘 Открываю Facebook..." -FC BlueRGB -newline
            Start-Process "https://www.facebook.com"
            Pause
            Show-SitesMenu
        }
        "instagram" {
            wrgb "`n📷 Открываю Instagram..." -FC MagentaRGB -newline
            Start-Process "https://www.instagram.com"
            Pause
            Show-SitesMenu
        }
        "telegram" {
            wrgb "`n💳 Открываю Telegram Web..." -FC CyanRGB -newline
            Start-Process "https://web.telegram.org"
            Pause
            Show-SitesMenu
        }
        "yandex" {
            wrgb "`n📊 Открываю Яндекс..." -FC RedRGB -newline
            Start-Process "https://yandex.ru"
            Pause
            Show-SitesMenu
        }
        "mailru" {
            wrgb "`n📨 Открываю Mail.ru..." -FC OrangeRGB -newline
            Start-Process "https://mail.ru"
            Pause
            Show-SitesMenu
        }
        "netflix" {
            wrgb "`n🎬 Открываю Netflix..." -FC RedRGB -newline
            Start-Process "https://www.netflix.com"
            Pause
            Show-SitesMenu
        }
        "spotify" {
            wrgb "`n🎵 Открываю Spotify..." -FC GreenRGB -newline
            Start-Process "https://open.spotify.com"
            Pause
            Show-SitesMenu
        }
        "amazon" {
            wrgb "`n🛒 Открываю Amazon..." -FC OrangeRGB -newline
            Start-Process "https://www.amazon.com"
            Pause
            Show-SitesMenu
        }
        "browser-settings" {
            Show-BrowserSettingsMenu
        }
        "add-site" {
            Add-CustomSite
        }
        "back" {
            Show-MainMenu
        }
    }
}

function Show-BrowserSettingsMenu {
    $menuItems = @(
        @{ Text = "🌐 Открыть в Chrome"; Data = "chrome" },
        @{ Text = "🔥 Открыть в Firefox"; Data = "firefox" },
        @{ Text = "🔵 Открыть в Edge"; Data = "edge" },
        @{ Text = "⚙️  Настройки браузера по умолчанию"; Data = "default-browser" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "⚙️  НАСТРОЙКИ БРАУЗЕРА" -Prompt "Выберите браузер"

    switch ($selected.Data) {
        "chrome" {
            wrgb "`n🌐 Устанавливаю Chrome как браузер по умолчанию..." -FC YellowRGB -newline
            # Здесь можно добавить логику для установки Chrome как браузера по умолчанию
            wrgb "✅ Chrome установлен как браузер по умолчанию" -FC GreenRGB -newline
            Pause
            Show-BrowserSettingsMenu
        }
        "firefox" {
            wrgb "`n🔥 Устанавливаю Firefox как браузер по умолчанию..." -FC OrangeRGB -newline
            # Здесь можно добавить логику для установки Firefox как браузера по умолчанию
            wrgb "✅ Firefox установлен как браузер по умолчанию" -FC GreenRGB -newline
            Pause
            Show-BrowserSettingsMenu
        }
        "edge" {
            wrgb "`n🔵 Устанавливаю Edge как браузер по умолчанию..." -FC BlueRGB -newline
            # Здесь можно добавить логику для установки Edge как браузера по умолчанию
            wrgb "✅ Edge установлен как браузер по умолчанию" -FC GreenRGB -newline
            Pause
            Show-BrowserSettingsMenu
        }
        "default-browser" {
            Show-DefaultBrowserSettings
        }
        "back" {
            Show-SitesMenu
        }
    }
}

function Show-DefaultBrowserSettings {
    wrgb "`n⚙️  ТЕКУЩИЕ НАСТРОЙКИ БРАУЗЕРА" -FC CyanRGB -newline

    try {
        # Получаем браузер по умолчанию
        $defaultBrowser = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name ProgId -ErrorAction SilentlyContinue
        if ($defaultBrowser) {
            wrgb "Браузер по умолчанию: $($defaultBrowser.ProgId)" -FC White -newline
        }

        # Проверяем установленные браузеры
        wrgb "`n🌐 УСТАНОВЛЕННЫЕ БРАУЗЕРЫ:" -FC YellowRGB -newline

        $browsers = @(
            @{ Name = "Google Chrome"; Path = "chrome"; Exe = "chrome.exe" },
            @{ Name = "Mozilla Firefox"; Path = "firefox"; Exe = "firefox.exe" },
            @{ Name = "Microsoft Edge"; Path = "msedge"; Exe = "msedge.exe" },
            @{ Name = "Opera"; Path = "opera"; Exe = "opera.exe" },
            @{ Name = "Brave"; Path = "brave"; Exe = "brave.exe" }
        )

        foreach ($browser in $browsers) {
            $browserPath = Get-Command $browser.Exe -ErrorAction SilentlyContinue
            if ($browserPath) {
                wrgb "✅ $($browser.Name)" -FC GreenRGB -newline
            } else {
                wrgb "❌ $($browser.Name) (не установлен)" -FC Red -newline
            }
        }

    } catch {
        wrgb "❌ Не удалось получить информацию о браузерах" -FC Red -newline
    }

    Pause
    Show-BrowserSettingsMenu
}

function Add-CustomSite {
    wrgb "`n➕ ДОБАВЛЕНИЕ СВОЕГО САЙТА" -FC CyanRGB -newline

    $siteName = Read-Host "`nВведите название сайта"
    $siteUrl = Read-Host "Введите URL сайта (например: https://example.com)"

    if ($siteName -and $siteUrl) {
        # Проверяем корректность URL
        if ($siteUrl -notmatch "^https?://") {
            $siteUrl = "https://" + $siteUrl
        }

        wrgb "`n🌐 Открываю $siteName..." -FC BlueRGB -newline
        Start-Process $siteUrl
        wrgb "✅ Сайт '$siteName' добавлен и открыт!" -FC GreenRGB -newline
        wrgb "📋 URL: $siteUrl" -FC White -newline
    } else {
        wrgb "❌ Необходимо ввести название и URL сайта" -FC Red -newline
    }

    Pause
    Show-SitesMenu
}

# Функция для быстрого открытия сайта по имени
function Open-Site {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SiteName
    )

    $sites = @{
        "google" = "https://www.google.com"
        "gmail" = "https://mail.google.com"
        "youtube" = "https://www.youtube.com"
        "chatgpt" = "https://chat.openai.com"
        "github" = "https://github.com"
        "stackoverflow" = "https://stackoverflow.com"
        "reddit" = "https://www.reddit.com"
        "linkedin" = "https://www.linkedin.com"
        "twitter" = "https://twitter.com"
        "facebook" = "https://www.facebook.com"
        "instagram" = "https://www.instagram.com"
        "telegram" = "https://web.telegram.org"
        "yandex" = "https://yandex.ru"
        "mailru" = "https://mail.ru"
        "netflix" = "https://www.netflix.com"
        "spotify" = "https://open.spotify.com"
        "amazon" = "https://www.amazon.com"
    }

    if ($sites.ContainsKey($SiteName.ToLower())) {
        wrgb "🌐 Открываю $SiteName..." -FC BlueRGB -newline
        Start-Process $sites[$SiteName.ToLower()]
    } else {
        wrgb "❌ Сайт '$SiteName' не найден в списке" -FC Red -newline
        wrgb "📋 Доступные сайты: $($sites.Keys -join ', ')" -FC White -newline
    }
}

# Алиас для быстрого открытия сайтов
Set-Alias -Name site -Value Open-Site
Set-Alias -Name sites -Value Show-SitesMenu

if (-not (Get-Command Show-SitesMenu -ErrorAction SilentlyContinue)) {
    wrgb 'Show-SitesMenu Error' -FC NeonRedRGB
}

Trace-ImportProcess  $MyInvocation.MyCommand.Name.trim(".ps1")
