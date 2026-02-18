function Get-WeatherSegment {
    param(
        [string]$City = "Kyiv",
        [string]$ApiKey = $global:openWeatherKey
    )
    
    try {
        if (-not $ApiKey) {
            return "🌤️"
        }
        
        $uri = "http://api.openweathermap.org/data/2.5/weather?q=$City&appid=$ApiKey&units=metric"
        $response = Invoke-RestMethod -Uri $uri -TimeoutSec 3
        
        $temp = [math]::Round($response.main.temp)
        $condition = $response.weather[0].main
        
        $icon = switch ($condition) {
            "Clear" { "☀️" }
            "Clouds" { "☁️" }
            "Rain" { "🌧️" }
            "Snow" { "❄️" }
            "Thunderstorm" { "⛈️" }
            "Drizzle" { "🌦️" }
            "Mist" { "🌫️" }
            "Fog" { "🌫️" }
            default { "🌤️" }
        }
        
        return "$icon $temp°C"
    }
    catch {
        return "🌤️"
    }
}

