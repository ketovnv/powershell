function Run-Application {
    $menuItems = @(
        @{ Text = "💻 WebStorm 2025.1.ws3"; Data = @{ Path = "pwsh ws" } },
        @{ Text = "📝 Zed"; Data = @{ Path = "zed" } },
        @{ Text = "🖥️  Wezterm"; Data = @{ Path = "wezterm-gui" } },
        @{ Text = "🪟 Windows Terminal Preview"; Data = @{ Path = "wt" } },
        @{ Text = "💬 Telegram"; Data = @{ Path = "pwsh ttg black" } },
        @{ Text = "📘 VS Code"; Data = @{ Path = "code" } },
        @{ Text = "📗 VS Code Insiders"; Data = @{ Path = "code-insiders" } },
        @{ Text = "🦀 RustRover"; Data = @{ Path = "rustrover" } },
        @{ Text = "🌐 Запустить браузер"; Data = @{ Action = "browser" } },
        @{ Text = "🔙 Назад"; Data = @{ Action = "back" } }
    )

    $gradientOptions = @{
        StartColor = "#00FF00"
        EndColor = "#FF00FF"
        GradientType = "Sine"
    }

    $selected = Show-Menu -MenuItems $menuItems -MenuTitle "🚀 ЗАПУСК ПРИЛОЖЕНИЙ" -Prompt "Выберите приложение" -GradientOptions $gradientOptions

    if ($selected.Data.Action -eq "browser") {
        Run-Browser
    } elseif ($selected.Data.Action -eq "back") {
        Show-MainMenu
    } else {
        try {
            wrgb "`n🚀 Запускаю " -FC White
            wrgb $selected.Text -FC NeonMaterial_LightGreen -newline
            Start-Process $selected.Data.Path -ErrorAction Stop
            Show-Notification -Title "Приложение запущено" -Message $selected.Text -Type "Success"
        } catch {
            Show-Notification -Title "Ошибка" -Message "Не удалось запустить приложение" -Type "Error"
        }
    }
}

# ===== МЕНЮ БРАУЗЕРОВ С RGB =====
function Run-Browser {
    $browsers = @(
        @{ Text = "🦊 Firefox Nightly"; Data = "firefox"; Args = "-P nightly" },
        @{ Text = "🦊 Firefox Developer"; Data = "firefox"; Args = "-P dev-edition-default" },
        @{ Text = "🦊 Firefox"; Data = "firefox" },
        @{ Text = "🔶 Chrome Canary"; Data = "chrome"; Args = "--chrome-canary" },
        @{ Text = "🔷 Chrome Dev"; Data = "chrome"; Args = "--chrome-dev" },
        @{ Text = "🔵 Chrome"; Data = "chrome" },
        @{ Text = "🟦 Edge Canary"; Data = "msedge-canary" },
        @{ Text = "🟦 Edge Dev"; Data = "msedge-dev" },
        @{ Text = "🟦 Edge"; Data = "msedge" },
        @{ Text = "🎭 Opera"; Data = "opera" },
        @{ Text = "🎨 Vivaldi"; Data = "vivaldi" },
        @{ Text = "🧅 Tor"; Data = "tor" },
        @{ Text = "🔷 Chromium"; Data = "chromium" },
        @{ Text = "🦁 Brave"; Data = "brave" },
        @{ Text = "🌊 Floorp"; Data = "floorp" },
        @{ Text = "💧 Waterfox"; Data = "waterfox" },
        @{ Text = "⚡ Thorium"; Data = "thorium" },
        @{ Text = "🐺 LibreWolf"; Data = "librewolf" },
        @{ Text = "🟡 Yandex"; Data = "yandex" },
        @{ Text = "🔙 Назад"; Data = "back" }
    )

    $gradientOptions = @{
        StartColor = "#FF6B6B"
        EndColor = "#4ECDC4"
        GradientType = "Exponential"
    }

    $selected = Show-Menu -MenuItems $browsers -MenuTitle "🌐 ВЫБОР БРАУЗЕРА" -Prompt "Выберите браузер" -GradientOptions $gradientOptions

    if ($selected.Data -eq "back") {
        Run-Application
    } else {
        try {
            wrgb "`n🌐 Запускаю " -FC White
            wrgb $selected.Text -FC Ocean1RGB -newline

            if ($selected.Args) {
                Start-Process $selected.Data -ArgumentList $selected.Args -ErrorAction Stop
            } else {
                Start-Process $selected.Data -ErrorAction Stop
            }

            Show-Notification -Title "Браузер запущен" -Message $selected.Text -Type "Success"
        } catch {
            Show-Notification -Title "Ошибка" -Message "Браузер не найден" -Type "Error"
        }
    }
}