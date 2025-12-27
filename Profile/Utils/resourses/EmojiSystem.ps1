# EmojiSystem.ps1 - Централизованная система управления эмодзи

# Единая структура данных для всех эмодзи
$script:EmojiDatabase = @{
    # Файловые иконки с поддержкой множественных расширений
    FileIcons = @{
        # Скрипты и код
        '.ps1' = '🔮'
        '.psm1' = '🔮'
        '.psd1' = '🔮'
        '.py' = '🐍'
        '.js' = '💖'
        '.jsx' = '⚛️'
        '.ts' = '💘'
        '.tsx' = '⚛️'
        '.rs' = '🦀'
        '.go' = '🐹'
        '.cpp' = '🔵'
        '.c' = '🔷'
        '.cs' = '🟣'
        '.java' = '☕'
        '.rb' = '💎'
        '.php' = '🐘'
        '.swift' = '🦉'
        '.kt' = '🟠'
        '.lua' = '🌙'
        '.dart' = '🎯'
        '.r' = '📊'
        '.jl' = '🟩'
        '.scala' = '🔴'
        '.clj' = '🟢'

        # Исполняемые
        '.exe' = '💻'
        '.msi' = '📦'
        '.app' = '🍎'
        '.deb' = '📦'
        '.rpm' = '📦'
        '.apk' = '🤖'
        '.com' = '🖥️'
        '.bat' = '🦇'
        '.cmd' = '⚡'
        '.sh' = '🐚'
        '.dll' = '🔧'
        '.so' = '🔗'

        # Документы
        '.txt' = '📜'
        '.md' = '📝'
        '.doc' = '📄'
        '.docx' = '📄'
        '.pdf' = '📕'
        '.odt' = '📄'
        '.rtf' = '📄'
        '.tex' = '📐'

        # Данные и конфиги
        '.json' = '💾'
        '.yaml' = '💛'
        '.yml' = '💛'
        '.toml' = '💙'
        '.xml' = '📋'
        '.csv' = '📊'
        '.sql' = '🗄️'
        '.db' = '🗃️'
        '.env' = '🔐'
        '.config' = '⚙️'
        '.ini' = '🔧'

        # Веб
        '.html' = '🌍'
        '.htm' = '🌍'
        '.css' = '🎨'
        '.scss' = '🎨'
        '.sass' = '🎨'
        '.less' = '🎨'
        '.vue' = '🖼️'
        '.svelte' = '🧡'

        # Медиа
        '.jpg' = '🖼️'
        '.jpeg' = '🖼️'
        '.png' = '🖼️'
        '.gif' = '🎞️'
        '.svg' = '🎨'
        '.bmp' = '🖼️'
        '.ico' = '🎭'
        '.webp' = '🖼️'
        '.mp4' = '🎬'
        '.avi' = '🎬'
        '.mov' = '🎬'
        '.mkv' = '🎬'
        '.mp3' = '🎵'
        '.wav' = '🎵'
        '.flac' = '🎵'
        '.ogg' = '🎵'

        # Архивы
        '.zip' = '📦'
        '.rar' = '📦'
        '.7z' = '📦'
        '.tar' = '📦'
        '.gz' = '📦'
        '.bz2' = '📦'
        '.xz' = '📦'

        # Системные
        '.log' = '📋'
        '.lock' = '🔒'
        '.bak' = '💾'
        '.tmp' = '⏳'
        '.cache' = '💾'
        '.swp' = '🔄'

        # Default
        '' = '📄'
    }

    # Категоризированные иконки
    Categories = @{
        Network = @{
            'net' = '🌐'
            'wifi' = '📶'
            'signal' = '📶'
            'online' = '🟢'
            'offline' = '🔴'
            'server' = '🖥️'
            'cloud' = '☁️'
            'vpn' = '🛡️'
            'firewall' = '🧱'
            'proxy' = '🔀'
            'dns' = '🧭'
            'ip' = '🌍'
            'port' = '🚪'
            'socket' = '🔌'
            'packet' = '📦'
            'ping' = '📶'
            'latency' = '⏱️'
            'bandwidth' = '📊'
            'upload' = '⬆️'
            'download' = '⬇️'
            'stream' = '📡'
            'broadcast' = '📢'
            'router' = '📡'
            'switch' = '🔀'
            'hub' = '🎯'
            'gateway' = '🚪'
        }

        Security = @{
            'secure' = '🔐'
            'insecure' = '🔓'
            'lock' = '🔒'
            'unlock' = '🔓'
            'key' = '🔑'
            'password' = '🔑'
            'auth' = '🔐'
            '2fa' = '🔢'
            'shield' = '🛡️'
            'armor' = '🛡️'
            'protect' = '🛡️'
            'hack' = '💀'
            'breach' = '⚠️'
            'exploit' = '💣'
            'vulnerability' = '🐛'
            'patch' = '🩹'
            'audit' = '🔍'
            'cert' = '📜'
            'certificate' = '📜'
            'ssl' = '🔒'
            'tls' = '🔒'
            'encryption' = '🔐'
            'malware' = '👾'
            'virus' = '🦠'
            'antivirus' = '🛡️'
            'pentest' = '🗡️'
            'forensics' = '🔍'
        }

        Git = @{
            'branch' = '🌿'
            'merge' = '🔀'
            'commit' = '📌'
            'push' = '📤'
            'pull' = '📥'
            'fork' = '🍴'
            'clone' = '🐑'
            'tag' = '🏷️'
            'release' = '🎉'
            'issue' = '🐛'
            'pr' = '🔄'
            'conflict' = '⚔️'
            'stash' = '📦'
            'diff' = '🔄'
            'rebase' = '🔧'
            'cherry' = '🍒'
            'cherry-pick' = '🍒'
            'submodule' = '📚'
            'gitignore' = '🚫'
            'workflow' = '🔄'
            'action' = '⚡'
        }

        DevOps = @{
            'docker' = '🐳'
            'kubernetes' = '☸️'
            'k8s' = '☸️'
            'container' = '📦'
            'pod' = '🥛'
            'helm' = '⎈'
            'pipeline' = '🔗'
            'ci' = '🔄'
            'cd' = '🚀'
            'deploy' = '🚀'
            'rollback' = '⏪'
            'build' = '🏗️'
            'test' = '🧪'
            'monitor' = '📊'
            'metric' = '📈'
            'log' = '📋'
            'alert' = '🚨'
            'backup' = '💾'
            'restore' = '♻️'
            'scale' = '📏'
            'terraform' = '🏗️'
            'ansible' = '🔧'
            'jenkins' = '🎩'
        }

        Database = @{
            'database' = '🗄️'
            'db' = '🗄️'
            'table' = '📊'
            'query' = '🔍'
            'index' = '📇'
            'key' = '🔑'
            'primarykey' = '🔑'
            'foreignkey' = '🔗'
            'record' = '📝'
            'row' = '📝'
            'column' = '📏'
            'cache' = '💾'
            'redis' = '🔴'
            'mongo' = '🍃'
            'mongodb' = '🍃'
            'postgres' = '🐘'
            'postgresql' = '🐘'
            'mysql' = '🐬'
            'mariadb' = '🐬'
            'sqlite' = '🪶'
            'oracle' = '🔮'
            'mssql' = '🟦'
            'elasticsearch' = '🔍'
            'backup' = '💿'
            'sync' = '🔄'
            'replication' = '📋'
        }

        OS = @{
            'windows' = '🪟'
            'linux' = '🐧'
            'ubuntu' = '🟠'
            'debian' = '🌀'
            'fedora' = '🎩'
            'centos' = '💠'
            'arch' = '🏛️'
            'manjaro' = '🟢'
            'suse' = '🦎'
            'redhat' = '🎩'
            'mac' = '🍎'
            'macos' = '🍎'
            'android' = '🤖'
            'ios' = '📱'
            'wsl' = '🐧'
            'vm' = '💻'
            'virtualbox' = '📦'
            'vmware' = '🟦'
            'hyperv' = '🟦'
            'terminal' = '⬛'
            'shell' = '🐚'
            'bash' = '🐚'
            'zsh' = '🐚'
            'powershell' = '🔷'
            'cmd' = '⬛'
            'kernel' = '🌰'
        }

        Status = @{
            'running' = '🟢'
            'stopped' = '🔴'
            'paused' = '⏸️'
            'pending' = '🟡'
            'starting' = '🔵'
            'stopping' = '🟠'
            'error' = '❌'
            'warning' = '⚠️'
            'success' = '✅'
            'failed' = '❌'
            'info' = 'ℹ️'
            'debug' = '🐛'
            'problem' = '❌'
            'critical' = '🚨'
            'healthy' = '💚'
            'unhealthy' = '💔'
            'unknown' = '❓'
            'ok' = '👍'
            'bad' = '👎'
            'good' = '👍'
            'excellent' = '🌟'
            'poor' = '💩'
        }

        Performance = @{
            'cpu' = '🧠'
            'ram' = '💾'
            'memory' = '💾'
            'disk' = '💿'
            'storage' = '💿'
            'network' = '🌐'
            'temp' = '🌡️'
            'temperature' = '🌡️'
            'hot' = '🔥'
            'cold' = '❄️'
            'speed' = '⚡'
            'slow' = '🐌'
            'fast' = '🚀'
            'chart' = '📊'
            'graph' = '📈'
            'metric' = '📊'
            'battery' = '🔋'
            'power' = '🔌'
            'energy' = '⚡'
            'usage' = '📊'
            'load' = '⚖️'
        }

        Development = @{
            'code' = '💻'
            'bug' = '🐛'
            'fix' = '🔨'
            'feature' = '✨'
            'refactor' = '♻️'
            'optimize' = '⚡'
            'document' = '📚'
            'test' = '🧪'
            'debug' = '🐛'
            'breakpoint' = '🔴'
            'todo' = '📝'
            'fixme' = '🚨'
            'hack' = '🔨'
            'review' = '👀'
            'approve' = '✅'
            'reject' = '❌'
            'comment' = '💬'
            'question' = '❓'
            'idea' = '💡'
            'plan' = '📋'
            'design' = '🎨'
            'architecture' = '🏛️'
        }

        Package = @{
            'npm' = '📦'
            'yarn' = '🧶'
            'pnpm' = '🚀'
            'pip' = '🐍'
            'pipenv' = '🐍'
            'poetry' = '📜'
            'cargo' = '📦'
            'gem' = '💎'
            'composer' = '🎼'
            'apt' = '📋'
            'yum' = '📋'
            'dnf' = '📋'
            'pacman' = '👾'
            'brew' = '🍺'
            'homebrew' = '🍺'
            'choco' = '🍫'
            'chocolatey' = '🍫'
            'scoop' = '🥄'
            'winget' = '📥'
            'nuget' = '📦'
            'maven' = '🏛️'
            'gradle' = '🐘'
            'bundler' = '💎'
        }

        Ukraine = @{
            'ukraine' =  '🇺🇦'
            'flag' = '🇺🇦'
            'peace' = '☮️'
            'heart' = '💙💛'
            'strong' = '💪'
            'victory' = '✌️'
            'support' = '🤝'
            'freedom' = '🕊️'
            'hope' = '🌻'
            'sunflower' = '🌻'
            'unity' = '🤲'
            'courage' = '🦁'
            'brave' = '🦁'
            'home' = '🏠'
            'love' = '❤️'
            'pray' = '🙏'
            'light' = '🕯️'
            'slava' = '🇺🇦'
            'heroiam' = '🌟'
        }

        Communication = @{
            'email' = '📧'
            'mail' = '✉️'
            'chat' = '💬'
            'message' = '💬'
            'call' = '📞'
            'phone' = '📱'
            'video' = '📹'
            'camera' = '📷'
            'microphone' = '🎤'
            'speaker' = '🔊'
            'notification' = '🔔'
            'bell' = '🔔'
            'mute' = '🔕'
            'broadcast' = '📢'
            'stream' = '📡'
            'podcast' = '🎙️'
            'forum' = '💭'
            'social' = '👥'
            'share' = '🔗'
            'like' = '❤️'
            'follow' = '👣'
            'subscribe' = '🔔'
        }

        Time = @{
            'clock' = '🕐'
            'time' = '⏰'
            'timer' = '⏱️'
            'stopwatch' = '⏱️'
            'alarm' = '⏰'
            'calendar' = '📅'
            'date' = '📆'
            'deadline' = '⏳'
            'schedule' = '📋'
            'morning' = '🌅'
            'noon' = '☀️'
            'afternoon' = '🌤️'
            'evening' = '🌆'
            'night' = '🌙'
            'midnight' = '🌃'
            'weekend' = '🎉'
            'holiday' = '🎄'
            'birthday' = '🎂'
            'anniversary' = '💍'
            'today' = '📍'
            'tomorrow' = '📍'
            'yesterday' = '📍'
        }

        Weather = @{
            'sunny' = '☀️'
            'cloudy' = '☁️'
            'rainy' = '🌧️'
            'stormy' = '⛈️'
            'snowy' = '❄️'
            'windy' = '💨'
            'foggy' = '🌫️'
            'rainbow' = '🌈'
            'hot' = '🔥'
            'cold' = '🥶'
            'warm' = '🌤️'
            'cool' = '🌬️'
            'humid' = '💧'
            'dry' = '🏜️'
            'weather' = '🌤️'
            'forecast' = '📊'
            'temperature' = '🌡️'
            'season' = '🍂'
            'spring' = '🌸'
            'summer' = '☀️'
            'autumn' = '🍂'
            'fall' = '🍂'
            'winter' = '❄️'
        }

        Crypto = @{
            'bitcoin' = '₿'
            'btc' = '₿'
            'ethereum' = 'Ξ'
            'eth' = 'Ξ'
            'crypto' = '🪙'
            'coin' = '🪙'
            'wallet' = '👛'
            'blockchain' = '⛓️'
            'nft' = '🖼️'
            'defi' = '🏦'
            'gas' = '⛽'
            'mining' = '⛏️'
            'miner' = '⛏️'
            'stake' = '🥩'
            'staking' = '🥩'
            'swap' = '🔄'
            'exchange' = '💱'
            'bridge' = '🌉'
            'dao' = '🏛️'
            'smart' = '📜'
            'contract' = '📜'
            'token' = '🪙'
            'yield' = '🌾'
        }

        Fun = @{
            'happy' = '😊'
            'sad' = '😢'
            'angry' = '😠'
            'cool' = '😎'
            'love' = '😍'
            'think' = '🤔'
            'shock' = '😱'
            'sleep' = '😴'
            'sick' = '🤒'
            'party' = '🥳'
            'work' = '💼'
            'coffee' = '☕'
            'beer' = '🍺'
            'wine' = '🍷'
            'pizza' = '🍕'
            'burger' = '🍔'
            'cake' = '🍰'
            'cookie' = '🍪'
            'game' = '🎮'
            'music' = '🎵'
            'movie' = '🎬'
            'book' = '📚'
            'sport' = '⚽'
            'travel' = '✈️'
        }
    }

    # Алиасы для обратной совместимости
    Aliases = @{
        # Сетевые
        'internet' = 'net'
        'www' = 'net'
        'web' = 'net'

        # Безопасность
        'security' = 'shield'
        'protected' = 'lock'

        # Git
        'pullrequest' = 'pr'
        'mergerequest' = 'pr'

        # DevOps
        'k8' = 'k8s'
        'kube' = 'k8s'

        # Базы данных
        'pg' = 'postgres'
        'psql' = 'postgres'

        # ОС
        'win' = 'windows'
        'osx' = 'mac'

        # Статусы
        'fail' = 'failed'
        'err' = 'error'
        'warn' = 'warning'

        # Разное
        'folder' = 'dir'
        'directory' = 'dir'
    }
}

# Универсальная функция получения эмодзи
function Get-Emoji {
    <#
    .SYNOPSIS
    Универсальная функция для получения эмодзи по имени или категории

    .PARAMETER Name
    Имя эмодзи для поиска

    .PARAMETER Category
    Категория для поиска

    .PARAMETER Default
    Эмодзи по умолчанию, если не найдено

    .EXAMPLE
    Get-Emoji "docker"
    Get-Emoji -Category "Network" -Name "server"
    #>
    param(
        [string]$Name,
        [string]$Category,
        [string]$Default = '❓'
    )

    if ($Category -and $Name) {
        # Поиск в конкретной категории
        if ($script:EmojiDatabase.Categories.ContainsKey($Category)) {
            $categoryEmojis = $script:EmojiDatabase.Categories[$Category]

            # Прямое совпадение
            if ($categoryEmojis.ContainsKey($Name.ToLower())) {
                return $categoryEmojis[$Name.ToLower()]
            }

            # Проверка алиасов
            if ($script:EmojiDatabase.Aliases.ContainsKey($Name.ToLower())) {
                $aliasName = $script:EmojiDatabase.Aliases[$Name.ToLower()]
                if ($categoryEmojis.ContainsKey($aliasName)) {
                    return $categoryEmojis[$aliasName]
                }
            }
        }
    }
    elseif ($Name) {
        # Поиск по всем категориям
        $lowerName = $Name.ToLower()

        # Сначала проверяем алиасы
        if ($script:EmojiDatabase.Aliases.ContainsKey($lowerName)) {
            $lowerName = $script:EmojiDatabase.Aliases[$lowerName]
        }

        # Поиск во всех категориях
        foreach ($cat in $script:EmojiDatabase.Categories.GetEnumerator()) {
            if ($cat.Value.ContainsKey($lowerName)) {
                return $cat.Value[$lowerName]
            }
        }
    }

    return $Default
}

# Специализированные функции для обратной совместимости
function Get-FileIcon {
    param(
        [string]$Extension,
        [string]$Default = '📄'
    )

    $ext = $Extension.ToLower()
    if (-not $ext.StartsWith('.')) {
        $ext = ".$ext"
    }

    if ($script:EmojiDatabase.FileIcons.ContainsKey($ext)) {
        return $script:EmojiDatabase.FileIcons[$ext]
    }

    return $Default
}



# Обертки для совместимости
function Get-NetIcon { param($Name) Get-Emoji -Category "Network" -Name $Name }
function Get-GitIcon { param($Name) Get-Emoji -Category "Git" -Name $Name }
function Get-DevOpsIcon { param($Name) Get-Emoji -Category "DevOps" -Name $Name }
function Get-DatabaseIcon { param($Name) Get-Emoji -Category "Database" -Name $Name }
function Get-OSIcon { param($Name) Get-Emoji -Category "OS" -Name $Name }
function Get-StatusIcon { param($Name) Get-Emoji -Category "Status" -Name $Name }
function Get-SecurityIcon { param($Name) Get-Emoji -Category "Security" -Name $Name }
function Get-PerfIcon { param($Name) Get-Emoji -Category "Performance" -Name $Name }
function Get-PackageIcon { param($Name) Get-Emoji -Category "Package" -Name $Name }
function Get-UkraineIcon { param($Name) Get-Emoji -Category "Ukraine" -Name $Name }
function Get-TimeIcon { param($Name) Get-Emoji -Category "Time" -Name $Name }
function Get-WeatherIcon { param($Name) Get-Emoji -Category "Weather" -Name $Name }
function Get-CryptoIcon { param($Name) Get-Emoji -Category "Crypto" -Name $Name }
function Get-MoodIcon { param($Name) Get-Emoji -Category "Fun" -Name $Name }
function Get-CommsIcon { param($Name) Get-Emoji -Category "Communication" -Name $Name }

# Функция поиска эмодзи
function Find-Emoji {
    <#
    .SYNOPSIS
    Поиск эмодзи по ключевому слову
    #>
    param(
        [string]$SearchQuery,
        [switch]$ShowCategories
    )

    $results = @()

    # Поиск в категориях
    foreach ($category in $script:EmojiDatabase.Categories.GetEnumerator()) {
        foreach ($item in $category.Value.GetEnumerator()) {
            if ($item.Key -like "*$SearchQuery*") {
                $results += [PSCustomObject]@{
                    Category = $category.Key
                    Name = $item.Key
                    Emoji = $item.Value
                }
            }
        }
    }

    # Поиск в файлах
    foreach ($ext in $script:EmojiDatabase.FileIcons.GetEnumerator()) {
        if ($ext.Key -like "*$SearchQuery*") {
            $results += [PSCustomObject]@{
                Category = 'Files'
                Name = $ext.Key
                Emoji = $ext.Value
            }
        }
    }

    if ($ShowCategories) {
        $results | Group-Object Category | ForEach-Object {
            Write-Host "`n$($_.Name):" -ForegroundColor Cyan
            $_.Group | ForEach-Object {
                Write-Host "  $($_.Emoji) $($_.Name)"
            }
        }
    }
    else {
        $results | ForEach-Object {
            Write-Host "$($_.Emoji) $($_.Name) [$($_.Category)]"
        }
    }

    Write-Host "`nНайдено: $($results.Count)" -ForegroundColor Yellow
}

# Функция для отображения всех эмодзи по категориям
function Show-AllEmojis {
    param(
        [string]$Category = '*'
    )

    $categories = $script:EmojiDatabase.Categories.Keys | Where-Object { $_ -like $Category }

    foreach ($cat in $categories | Sort-Object) {
        Write-Host "`n=== $cat ===" -ForegroundColor Cyan

        $items = $script:EmojiDatabase.Categories[$cat].GetEnumerator() | Sort-Object Key
        $i = 0

        foreach ($item in $items) {
            Write-Host "$($item.Value) $($item.Key)".PadRight(20) -NoNewline
            $i++
            if ($i % 4 -eq 0) { Write-Host }
        }

        if ($i % 4 -ne 0) { Write-Host }
    }

    if ($Category -eq '*' -or $Category -eq 'Files') {
        Write-Host "`n=== File Extensions ===" -ForegroundColor Cyan

        $exts = $script:EmojiDatabase.FileIcons.GetEnumerator() |
            Sort-Object Key |
            Select-Object -First 20

        foreach ($ext in $exts) {
            Write-Host "$($ext.Value) $($ext.Key)".PadRight(15) -NoNewline
        }
        Write-Host "`n... и еще $($script:EmojiDatabase.FileIcons.Count - 20) расширений"
    }

}




return


$emojiRanges = @(
    [System.Tuple]::Create(0x1F600, 0x1F64F),  # Emoticons
    [System.Tuple]::Create(0x1F300, 0x1F5FF),  # Symbols & Pictographs
    [System.Tuple]::Create(0x1F680, 0x1F6FF)   # Transport & Maps
)




# Метод 1: Конвертация из строки вида "U+1F6FF"
function ConvertFrom-UnicodeString {
    param([string]$UnicodeString)

    # Убираем префикс "U+" и конвертируем из hex в int
    $codePoint = [Convert]::ToInt32($UnicodeString.Replace("U+", ""), 16)
    return [char]::ConvertFromUtf32($codePoint)
}

# Примеры использования:
$emoji1 = ConvertFrom-UnicodeString "U+1F1FF"  # 🛿
$emoji2 = ConvertFrom-UnicodeString "U+1F1FE"  # 🛾
$emoji3 = ConvertFrom-UnicodeString "U+1F1FD"  # 🛽

Write-Host "Эмоджи 1: $emoji1"
Write-Host "Эмоджи 2: $emoji2"
Write-Host "Эмоджи 3: $emoji3"

# Метод 2: Прямая конвертация из hex
$codePoint =Ux1F3c1
$emoji = [char]::ConvertFromUtf32($codePoint)
Write-Host "Прямая конвертация: $emoji"

# Метод 3: Исправление вашего кода
# Вместо передачи строки "U+1F6FF", используйте:
$utf32Value = "U+1F2c1"
$numericValue = [Convert]::ToInt32($utf32Value.Replace("U+", ""), 16)
$convertedEmoji = [char]::ConvertFromUtf32($numericValue)

[PSCustomObject]@{
    Unicode = $utf32Value
    Decimal = $numericValue
    Emoji = $convertedEmoji
    Description = "Converted emoji"
}

# Метод 4: Функция для массовой обработки
function Convert-EmojiArray {
    param([string[]]$UnicodeArray)

    $results = @()
    foreach ($unicode in $UnicodeArray) {
        try {
            $codePoint = [Convert]::ToInt32($unicode.Replace("U+", ""), 16)
            $emoji = [char]::ConvertFromUtf32($codePoint)

            $results += [PSCustomObject]@{
                Unicode = $unicode
                Decimal = $codePoint
                Emoji = $emoji
                Status = "Success"
            }
        }
        catch {
            $results += [PSCustomObject]@{
                Unicode = $unicode
                Decimal = $null
                Emoji = $null
                Status = "Error: $($_.Exception.Message)"
            }
        }
    }
    return $results
}

# Пример использования для массива
$unicodeArray = @("U+1F5FF", "U+1F5FA", "U+1F6a6D", "U+1F6ac")
$results = Convert-EmojiArray $unicodeArray
$results | Format-Table -AutoSize

# Метод 5: Прямое создание эмоджи из кода
# Если вы знаете, что работаете с конкретными кодами:
$emojis = @{
    "U+1F6FF" = [char]::ConvertFromUtf32(0x1F6FF)
    "U+1F6FE" = [char]::ConvertFromUtf32(0x1F6FE)
    "U+1F6FD" = [char]::ConvertFromUtf32(0x1F6FD)
    "U+1F600" = [char]::ConvertFromUtf32(0x1F600)  # 😀
}

Write-Host "`nПрямое создание эмоджи:"
$emojis.GetEnumerator() | ForEach-Object {
    Write-Host "$($_.Key): $($_.Value)"
}



#$allEmojis = foreach ($range in $emojiRanges) {
#    for ($i = $range.Item1; $i -le $range.Item2; $i++) {
#        try {
#            [PSCustomObject]@{
#                Code   = "U+{0:X4}" -f $i
#                Symbol = [char]::ConvertFromUtf32("U+{0:X4}" -f $i)
#                Name   = [System.Char]::GetUnicodeCategory([char]::ConvertFromUtf32("U+{0:X4}" -f $i)).ToString()
#            }
#        } catch {}
#    }
#}
#
#$validEmojis = $allEmojis |
#    Where-Object { $_.Name -match 'OtherSymbol|Surrogate' } |
#    Select-Object Code, Symbol
