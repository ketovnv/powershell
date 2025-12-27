Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start


function Prognoz
{

    $apiKey = $global:openWeatherKey
    $city = "Lviv,UA"
    $url = "https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=ua"

    $response = Invoke-RestMethod -Uri $url -Method Get
    $forecastList = $response.list | Where-Object { $_.dt_txt -like "*12:00:00" } | Select-Object -First 5

    function Weather-Emoji($desc)
    {
        switch -Wildcard ($desc)
        {
            "*ясно*"      { "☀️" }
            "*дощ*"       { "🌧️" }
            "*сніг*"      { "❄️" }
            "*гроза*"     { "⛈️" }
            "*хмари*"     { "☁️" }
            "*туман*"     { "🌫️" }
            "*похмуро*"   { "🌥️" }
            default       { "🌈" }
        }
    }


    Write-GradientFull "       ──────────── Прогноз на 5 днів — Львів ────────────          " 0 255 255 0 128 255 0 0 0 20 20 60

    foreach ($day in $forecastList)
    {
        $dt = Get-Date($day.dt_txt) -Format "ddd dd.MM"
        $temp = [math]::Round($day.main.temp)
        $feels = [math]::Round($day.main.feels_like)
        $desc = $day.weather[0].description
        $hum = $day.main.humidity
        $wind = $day.wind.speed
        $emoji = Weather-Emoji $desc

        $line = "│ $dt  $emoji  $desc  $temp°C (відч. $feels°C), 💧 $hum%, 💨 $wind м/с │"
        Write-GradientFull $line 255 255 255 100 255 128 0 0 0 30 30 60
    }

}


#Prognoz


function Search-DDG
{
    param([string]$Query = "PowerShell")

    $encoded = [System.Web.HttpUtility]::UrlEncode($Query)
    $url = "https://api.duckduckgo.com/?q=$encoded&format=json&locale=ru-ru&no_redirect=1&no_html=1"

    $resp = Invoke-RestMethod -Uri $url

    if ($resp.AbstractText)
    {
        Write-GradientFull "┌──────────── Інфо з DuckDuckGo " 0 255 128 0 100 255 0 0 0 30 30 60
        wrgbn "│     🔮 Запит: $Query" -FC Material_Teal -BC Black
        Write-GradientFull "│     🤔 $($resp.AbstractText.PadRight(40) )" 255 255 255 100 255 128 0 0 0 30 30 60
        wgt "│     📚               $( $resp.AbstractURL )" -StartColor "#3377DD" -EndColor "#99CCDD"
        Write-GradientFull "└──────────────────────────────────────────" 0 255 128 0 100 255 0 0 0 30 30 60
    }
    else
    {
        Write-Host "❌ Нічого не знайдено."
    }
}

#Search-DDG "Ukraine"


function Pogoda
{
    $apiKey = $global:openWeatherKey
    $city = "Lviv,UA"
    $url = "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=ua"

    $response = Invoke-RestMethod -Uri $url -Method Get

    $weather = $response.weather[0].description
    $temp = [math]::Round($response.main.temp)
    $feels = [math]::Round($response.main.feels_like)
    $humidity = $response.main.humidity
    $wind = $response.wind.speed
    $emoji = switch -Wildcard ($weather)
    {
        "*дощ*" { "🌧️" }
        "*ясно*" { "☀️" }
        "*хмари*" { "☁️" }
        "*сніг*" { "❄️" }
        default { "🌈" }
    }

    # Вивод з градієнтом
    #    function Write-GradientFull {
    #        param (
    #            [string]$Text,
    #            [int]$R1, [int]$G1, [int]$B1,
    #            [int]$R2, [int]$G2, [int]$B2,
    #            [int]$BR1, [int]$BG1, [int]$BB1,
    #            [int]$BR2, [int]$BG2, [int]$BB2
    #        )
    #        $len = $Text.Length
    #        for ($i = 0; $i -lt $len; $i++) {
    #            $r  = [int]($R1  + ($R2  - $R1)  * $i / ($len - 1))
    #            $g  = [int]($G1  + ($G2  - $G1)  * $i / ($len - 1))
    #            $b  = [int]($B1  + ($B2  - $B1)  * $i / ($len - 1))
    #            $br = [int]($BR1 + ($BR2 - $BR1) * $i / ($len - 1))
    #            $bg = [int]($BG1 + ($BG2 - $BG1) * $i / ($len - 1))
    #            $bb = [int]($BB1 + ($BB2 - $BB1) * $i / ($len - 1))
    #            $ansi = "`e[38;2;${r};${g};${b}m`e[48;2;${br};${bg};${bb}m"
    #            Write-Host "$ansi$($Text[$i])" -NoNewline
    #        }
    #        Write-Host "`e[0m"
    #    }



    #    Clear-Host
    Write-GradientFull "┌────────────────────────────────────────────┐" 0 255 255 0 100 255 0 0 0 30 30 60
    Write-GradientFull "│  ☁️  Прогноз погоди — Львів                 │" 255 255 255 100 255 128 0 0 0 30 30 60
    Write-GradientFull "│  $emoji           $weather                   │" 255 255 255 100 255 128 0 0 0 30 30 60
    Write-GradientFull "│  🌡️  Температура: $temp°C (відчувається $feels°C)  │" 255 255 255 100 255 128 0 0 0 30 30 60
    Write-GradientFull "│  💧  Вологість: $humidity%                        │" 255 255 255 100 255 128 0 0 0 30 30 60
    Write-GradientFull "│  💨  Вітер: $wind м/с                       │" 255 255 255 100 255 128 0 0 0 30 30 60
    Write-GradientFull "└────────────────────────────────────────────┘" 0 255 255 0 100 255 0 0 0 30 30 60
}

function Get-CryptoInfo
{
    $url = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd,eur,uah"
    $data = Invoke-RestMethod -Uri $url

    $btc = $data.bitcoin
    $eth = $data.ethereum
    wrgbn ""
    Write-GradientFull "┌──────────── Курси криптовалют ─────────────┐" 155 155 0 155 100 100 0 0 0 20 20 60
    Write-GradientFull "│ ₿ Bitcoin:   $( $btc.uah )₴ | $( $btc.usd )$  | €$( $btc.eur )  │" 55 155 255 255 150 50 0 0 0 30 30 60
    Write-GradientFull "│ Ξ Ethereum:   $( $eth.uah )₴ | $( $eth.usd )$ |€$( $eth.eur ) │" 255 255 155 255 150 50 0 0 0 30 30 60
    Write-GradientFull "└────────────────────────────────────────────┘" 55 255 0 155 100 0 0 0 0 20 20 60
}

# Get-CryptoInfo
# Pogoda
Trace-ImportProcess  $MyInvocation.MyCommand.Name.trim(".ps1")
