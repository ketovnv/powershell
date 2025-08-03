importProcess  $MyInvocation.MyCommand.Name.trim('.ps1') -start

# Heavy-Functions.ps1
# Тяжелые функции для отложенной загрузки

# Функция инициализации погоды (была Openwe)
function Initialize-WeatherComponents {
    try {
        if (Get-Command Openwe -ErrorAction SilentlyContinue) {
            Openwe
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

importProcess  $MyInvocation.MyCommand.Name.trim('.ps1')