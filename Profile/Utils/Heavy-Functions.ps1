Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

# Heavy-Functions.ps1
# Тяжелые функции для отложенной загрузки

# Функция инициализации погоды (была Openwe)
function Initialize-WeatherComponents {
    try {
        if (Get-Command Openwe -ErrorAction SilentlyContinue) {
            $global:openWeatherKey
        }
    } catch {
        Write-Warning "Failed to initialize weather components: $_"
    }
}

# Дополнительные тяжелые функции можно добавить здесь
function Initialize-AdditionalComponents {
    # Место для других тяжелых инициализаций
}

# Автоматически вызываем при загрузке этого файла
Initialize-WeatherComponents
Initialize-AdditionalComponents

Write-Host "🔧 Heavy functions loaded" -ForegroundColor Magenta

Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))