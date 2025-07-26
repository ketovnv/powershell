importProcess  $MyInvocation.MyCommand.Name.trim('.ps1') -start

 function Get-NetIcon
{
    param([string]$Name)
    switch ( $Name.ToLower())
    {
        "net"       {
            "🌐"
        }
        "ping"      {
            "📶"
        }
        "online"    {
            "🟢"
        }
        "offline"   {
            "🔴"
        }
        "server"    {
            "🖥️"
        }
        "cloud"     {
            "☁️"
        }
        "lock"      {
            "🔒"
        }
        "unlock"    {
            "🔓"
        }
        "shield"    {
            "🛡️"
        }
        "ip"        {
            "🌍"
        }
        "terminal"  {
            ">_"
        }
        "upload"    {
            "⬆️"
        }
        "download"  {
            "⬇️"
        }
        "packet"    {
            "📦"
        }
        "scan"      {
            "📡"
        }
        "bug"       {
            "🐞"
        }
        "key"       {
            "🔑"
        }
        default     {
            "❔"
        }
    }
}


function Get-Number
{
    param([string]$Number)
    switch ( $Number)
    {
       "one"    {
            "1️⃣"
        }
        "two" {
            "2️⃣️⃣"
        }
       default     {
           "❔"
       }
    }
}


function Get-FileIcon
{
    param([string]$Name)
    switch  -Wildcard ( $Name.ToLower())
    {
        ".ps1" {
            "🔮"
        }
        ".exe" {
            "💻️"
        }
        ".com" {
            "🖥️"
        }
        ".dll" {
            "🔧"
        }
        ".txt" {
            "📜"
        }
        ".md" {
            "📝"
        }
        ".json" {
            "💾"
        }
        ".xml" {
            "📋"
        }
        ".zip" {
            "📦"
        }
        ".rar" {
            "📦"
        }
        ".7z" {
            "📦"
        }
        ".pdf" {
            "📕"
        }
        ".jpg" {
            "🖼️"
        }
        ".png" {
            "🖼️"
        }
        ".gif" {
            "🎞️"
        }
        ".mp4" {
            "🎬"
        }
        ".mp3" {
            "🎵"
        }
        ".js" {
            "💖"
        }
        ".jsx" {
            "⚛️"
        }
        ".ts" {
            "💘"
        }
        ".tsx" {
            "⚛️"
        }
        ".rs" {
            "🦀"
        }
        ".py" {
            "🐍"
        }
        ".cpp" {
            "🔵"
        }
        ".cs" {
            "🟣"
        }
        ".html" {
            "🌍"
        }
        ".css" {
            "🎨"
        }
        ".scss" {
            "🎨"
        }
        ".vue" {
            "🤿"
        }
        ".bak" {
            "🦉"
        }
        ".lock" {
            "🔒"
        }
        ".lua" {
            "❤️"
        }
            ".yaml" {
            "💛"
        }
            ".toml" {
            "💙"
        }
        default {
            "📄"
        }

    }



    function Get-TerminalIcon
    {
        param (
            [string]$Name
        )
        switch ( $Name.ToLower())
        {
            "fire"     {
                return "🔥"
            }
            "skull"    {
                return "☠️"
            }
            "shield"   {
                return "🛡️"
            }
            "check"    {
                return "✅"
            }
            "error"    {
                return "❌"
            }
            "warning"  {
                return "⚠️"
            }
            "gear"     {
                return "⚙️"
            }
            "lightning" {
                return "⚡"
            }
            "folder"   {
                return "📁"
            }
            "file"     {
                return "📄"
            }
            default    {
                return "❓"
            }
        }
    }
}



# Git/VCS Icons
function Get-GitIcon {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "branch"     { "🌿" }
        "merge"      { "🔀" }
        "commit"     { "📌" }
        "push"       { "📤" }
        "pull"       { "📥" }
        "fork"       { "🍴" }
        "tag"        { "🏷️" }
        "release"    { "🎉" }
        "conflict"   { "⚔️" }
        "stash"      { "📦" }
        "diff"       { "🔄" }
        "rebase"     { "🔧" }
        "cherry"     { "🍒" }
        "submodule"  { "📚" }
        default      { "📁" }
    }
}

# DevOps/Container Icons
function Get-DevOpsIcon {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "docker"     { "🐳" }
        "kubernetes" { "☸️" }
        "container"  { "📦" }
        "pod"        { "🥛" }
        "helm"       { "⎈" }
        "pipeline"   { "🔗" }
        "deploy"     { "🚀" }
        "build"      { "🏗️" }
        "test"       { "🧪" }
        "monitor"    { "📊" }
        "log"        { "📋" }
        "metric"     { "📈" }
        "alert"      { "🚨" }
        "backup"     { "💾" }
        "restore"    { "♻️" }
        default      { "⚙️" }
    }
}

# Database Icons
function Get-DatabaseIcon {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "database"   { "🗄️" }
        "table"      { "📊" }
        "query"      { "🔍" }
        "index"      { "📇" }
        "key"        { "🔑" }
        "record"     { "📝" }
        "cache"      { "💾" }
        "redis"      { "🔴" }
        "mongo"      { "🍃" }
        "postgres"   { "🐘" }
        "mysql"      { "🐬" }
        "sqlite"     { "🪶" }
        "backup"     { "💿" }
        "sync"       { "🔄" }
        default      { "💽" }
    }
}

# OS/Platform Icons
function Get-OSIcon {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "windows"    { "🪟" }
        "linux"      { "🐧" }
        "ubuntu"     { "🟠" }
        "debian"     { "🌀" }
        "fedora"     { "🎩" }
        "arch"       { "🏛️" }
        "mac"        { "🍎" }
        "android"    { "🤖" }
        "ios"        { "📱" }
        "wsl"        { "🐧" }
        "vm"         { "💻" }
        "terminal"   { "⬛" }
        "shell"      { "🐚" }
        "kernel"     { "🌰" }
        default      { "💻" }
    }
}

# System Status Icons
function Get-StatusIcon {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "running"    { "🟢" }
        "stopped"    { "🔴" }
        "paused"     { "⏸️" }
        "pending"    { "🟡" }
        "starting"   { "🔵" }
        "problem"      { "❌" }
        "warning"    { "⚠️" }
        "success"    { "✅" }
        "info"       { "ℹ️" }
        "debug"      { "🐛" }
        "critical"   { "🚨🚨🚨" }
        "healthy"    { "💚" }
        "unhealthy"  { "💔" }
        "unknown"    { "❓" }
        default      { "⚪" }
    }
}

# Crypto/Web3 Icons
function Get-CryptoIcon {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "bitcoin"    { "₿" }
        "ethereum"   { "Ξ" }
        "crypto"     { "🪙" }
        "wallet"     { "👛" }
        "blockchain" { "⛓️" }
        "nft"        { "🖼️" }
        "defi"       { "🏦" }
        "gas"        { "⛽" }
        "mining"     { "⛏️" }
        "stake"      { "🥩" }
        "swap"       { "🔄" }
        "bridge"     { "🌉" }
        "dao"        { "🏛️" }
        "smart"      { "📜" }
        default      { "💰" }
    }
}

# Time/Calendar Icons
function Get-TimeIcon {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "clock"      { "🕐" }
        "timer"      { "⏱️" }
        "alarm"      { "⏰" }
        "calendar"   { "📅" }
        "date"       { "📆" }
        "deadline"   { "⏳" }
        "schedule"   { "📋" }
        "morning"    { "🌅" }
        "noon"       { "☀️" }
        "evening"    { "🌆" }
        "night"      { "🌙" }
        "weekend"    { "🎉" }
        "holiday"    { "🎄" }
        "birthday"   { "🎂" }
        default      { "🕰️" }
    }
}

# Performance/Monitoring Icons
function Get-PerfIcon {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "cpu"        { "🧠" }
        "ram"        { "💾" }
        "disk"       { "💿" }
        "network"    { "🌐" }
        "temp"       { "🌡️" }
        "hot"        { "🔥" }
        "cold"       { "❄️" }
        "speed"      { "⚡" }
        "slow"       { "🐌" }
        "fast"       { "🚀" }
        "chart"      { "📊" }
        "graph"      { "📈" }
        "battery"    { "🔋" }
        "power"      { "🔌" }
        default      { "📊" }
    }
}

# Security Icons
function Get-SecurityIcon {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "secure"     { "🔐" }
        "insecure"   { "🔓" }
        "auth"       { "🔑" }
        "2fa"        { "🔢" }
        "vpn"        { "🛡️" }
        "firewall"   { "🧱" }
        "antivirus"  { "🦠" }
        "malware"    { "👾" }
        "hack"       { "💀" }
        "pentest"    { "🗡️" }
        "exploit"    { "💣" }
        "patch"      { "🩹" }
        "audit"      { "🔍" }
        "cert"       { "📜" }
        default      { "🔒" }
    }
}

# Communication/Social Icons
function Get-CommsIcon {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "email"      { "📧" }
        "chat"       { "💬" }
        "call"       { "📞" }
        "video"      { "📹" }
        "message"    { "✉️" }
        "notification" { "🔔" }
        "mute"       { "🔕" }
        "broadcast"  { "📢" }
        "stream"     { "📡" }
        "podcast"    { "🎙️" }
        "forum"      { "💭" }
        "social"     { "👥" }
        "share"      { "🔗" }
        "like"       { "❤️" }
        default      { "📱" }
    }
}

# Development Process Icons
function Get-DevProcessIcon {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "plan"       { "📝" }
        "design"     { "🎨" }
        "code"       { "💻" }
        "review"     { "👀" }
        "test"       { "🧪" }
        "bug"        { "🐛" }
        "fix"        { "🔨" }
        "feature"    { "✨" }
        "refactor"   { "♻️" }
        "optimize"   { "⚡" }
        "document"   { "📚" }
        "release"    { "🎉" }
        "hotfix"     { "🚑" }
        "rollback"   { "⏪" }
        default      { "🔧" }
    }
}

# Weather/Environment Icons
function Get-WeatherIcon {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "sunny"      { "☀️" }
        "cloudy"     { "☁️" }
        "rainy"      { "🌧️" }
        "stormy"     { "⛈️" }
        "snowy"      { "❄️" }
        "windy"      { "💨" }
        "foggy"      { "🌫️" }
        "rainbow"    { "🌈" }
        "hot"        { "🔥" }
        "cold"       { "🥶" }
        "temp"       { "🌡️" }
        "humid"      { "💧" }
        "dry"        { "🏜️" }
        "nature"     { "🌳" }
        default      { "🌤️" }
    }
}

# Package Manager Icons
function Get-PackageIcon {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "npm"        { "📦" }
        "yarn"       { "🧶" }
        "pnpm"       { "🚀" }
        "pip"        { "🐍" }
        "cargo"      { "📦" }
        "gem"        { "💎" }
        "apt"        { "📋" }
        "brew"       { "🍺" }
        "choco"      { "🍫" }
        "scoop"      { "🥄" }
        "winget"     { "📥" }
        "nuget"      { "📦" }
        "maven"      { "🏛️" }
        "gradle"     { "🐘" }
        default      { "📦" }
    }
}

# Ukraine Support Icons
function Get-UkraineIcon {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "flag"       { "🇺🇦" }
        "peace"      { "☮️" }
        "heart"      { "💙💛" }
        "strong"     { "💪" }
        "victory"    { "✌️" }
        "support"    { "🤝" }
        "freedom"    { "🕊️" }
        "hope"       { "🌻" }
        "unity"      { "🤲" }
        "courage"    { "🦁" }
        "home"       { "🏠" }
        "love"       { "❤️" }
        "pray"       { "🙏" }
        "light"      { "🕯️" }
        default      { "🇺🇦" }
    }
}

# Fun/Mood Icons
function Get-MoodIcon {
    param([string]$Name)
    switch ($Name.ToLower()) {
        "happy"      { "😊" }
        "sad"        { "😢" }
        "angry"      { "😠" }
        "cool"       { "😎" }
        "love"       { "😍" }
        "think"      { "🤔" }
        "shock"      { "😱" }
        "sleep"      { "😴" }
        "sick"       { "🤒" }
        "party"      { "🥳" }
        "work"       { "💼" }
        "coffee"     { "☕" }
        "beer"       { "🍺" }
        "pizza"      { "🍕" }
        default      { "😐" }
    }
}




# @(
#    "😀","😃","😄","😁","😆","😅","🤣","😂","🙂","🙃","😉","😊","😇","🥰","😍","🤩","😘","😗","😚","😙",
#     "😋","😛","😜","🤪","🤨","🧐","🤓","😎","🥸","🤠","🥳","😏","😒","😞","😔","😟","😕","🙁","☹️","😣",
#     "🚀","💻","⚙️","🧠","🔥","❄️","🌐","📡","📶","🔒","🔓","📂","📁","📄","🖥️","🧮","📊","📈","📉","⏳"
# )


#net	🌐	Интернет / Сеть
#ping	📶	Проверка соединения
#online	🟢	Онлайн / Доступен
#offline	🔴	Оффлайн / Недоступен
#warning	⚠️	Проблема с сетью
#server	🖥️	Сервер
#cloud	☁️	Облако / Хостинг
#lock	🔒	Защищённое соединение
#unlock	🔓	Незащищённое соединение
#shield	🛡️	Фаервол / VPN / Защита
#terminal	>_	Консоль / Терминал
#ip	🌍	IP-адрес
#hacker	🕶️	Стелс / Трюк / Инъекция
#scan	📡	Сканер портов / устройств
#bug	🐞	Уязвимость / баг
#key	🔑	Авторизация / токен
#upload	⬆️	Загрузка на сервер
#download	⬇️	Выгрузка с сервера
#packet	📦	Сетевой пакет / посылка
#dns	🧭

#Название	Иконка	Использование
#arrow_right	➤	Меню / Выбор
#arrow_double	»	Переход
#bullet_star	✦	Список с эффектом
#bullet_dot	•	Классический список
#box_open	⊞	Открытый пункт
#box_closed	⊟	Закрытый пункт
#folder	📁	Каталог / путь
#file	📄	Файл
#lock	🔒	Защищено
#unlock	🔓	Разблокировано
#terminal	🖥️	Командная строка
#signal	📶	Связь / интернет

#shield🛡️	Защита
#sword	🗡️	Нападение / операция

#lightning	⚡	Быстро / энергия
#explosion	💥	Взрыв / сбой
#gear	⚙️	Настройки / процессы
#hourglass	⌛	Загрузка / ожидание
#magic	✨	Завершено магически

 importProcess  $MyInvocation.MyCommand.Name.trim('.ps1')