importProcess  $MyInvocation.MyCommand.Name.trim('.ps1') -start

#region Инициализация
$global:RGB = @{ }

# Проверяем поддержку ANSI/PSStyle сразу
$global:ColorSupport = $null -ne $PSStyle

if (-not $global:ColorSupport)
{
    Write-Warning "Ваша версия PowerShell не поддерживает PSStyle. Некоторые функции будут недоступны."
}
#endregion

#region Цветовые палитры
# Палитры в формате HEX (упорядочены и дополнены)
$newHexColors = @{
# Палитра Nord (спокойные и элегантные тона)
    "Nord_PolarNight" = "#2E3440" # Очень темный сине-серый
    "Nord_DarkBlue" = "#3B4252" # Темно-синий
    "Nord_SteelBlue" = "#4C566A" # Стальной синий
    "Nord_LightGray" = "#D8DEE9" # Светло-серый
    "Nord_Snow" = "#D8DEE9" # Снежный (дубликат убран)
    "Nord_White" = "#ECEFF4" # Почти белый
    "Nord_FrostBlue" = "#88C0D0" # Морозный голубой
    "Nord_FrostGreen" = "#8FBCBB" # Морозный зеленый
    "Nord_AuroraRed" = "#BF616A" # Аврора (красный)
    "Nord_AuroraOrange" = "#D08770" # Аврора (оранжевый)
    "Nord_AuroraYellow" = "#EBCB8B" # Аврора (желтый)
    "Nord_AuroraGreen" = "#A3BE8C" # Аврора (зеленый)
    "Nord_AuroraPurple" = "#B48EAD" # Аврора (фиолетовый)

    # Палитра Dracula (яркая и контрастная)
    "Dracula_Background" = "#282A36" # Фон
    "Dracula_CurrentLine" = "#44475A" # Выделение строки
    "Dracula_Foreground" = "#F8F8F2" # Текст
    "Dracula_Comment" = "#6272A4" # Комментарий
    "Dracula_Cyan" = "#8BE9FD" # Циан
    "Dracula_Green" = "#50FA7B" # Зеленый
    "Dracula_Orange" = "#FFB86C" # Оранжевый
    "Dracula_Pink" = "#FF79C6" # Розовый
    "Dracula_Purple" = "#BD93F9" # Фиолетовый
    "Dracula_Red" = "#FF5555" # Красный
    "Dracula_Yellow" = "#F1FA8C" # Желтый

    # Палитра Material Design
    "Material_Red" = "#F44336"
    "Material_Pink" = "#E91E63"
    "Material_Purple" = "#9C27B0"
    "Material_DeepPurple" = "#673AB7"
    "Material_Indigo" = "#3F51B5"
    "Material_Blue" = "#2196F3"
    "Material_LightBlue" = "#03A9F4"
    "Material_Cyan" = "#00BCD4"
    "Material_Teal" = "#009688"
    "Material_Green" = "#4CAF50"
    "Material_LightGreen" = "#8BC34A"
    "Material_Lime" = "#CDDC39"
    "Material_Yellow" = "#FFEB3B"
    "Material_Amber" = "#FFC107"
    "Material_Orange" = "#FF9800"
    "Material_DeepOrange" = "#FF5722"
    "Material_Brown" = "#795548"
    "Material_Grey" = "#9E9E9E"
    "Material_BlueGrey" = "#607D8B"

    # Новая палитра - Cyber/Synthwave
    "Cyber_Neon" = "#00FFFF"
    "Cyber_Pink" = "#FF006E"
    "Cyber_Purple" = "#8338EC"
    "Cyber_Blue" = "#006FFF"
    "Cyber_Green" = "#00F5FF"
    "Cyber_Orange" = "#FF9500"
    "Cyber_Background" = "#0D1117"
    "Cyber_Dark" = "#161B22"

    # Палитра One Dark (популярна в VS Code)
    "OneDark_Background" = "#282C34"
    "OneDark_Red" = "#E06C75"
    "OneDark_Green" = "#98C379"
    "OneDark_Yellow" = "#E5C07B"
    "OneDark_Blue" = "#61AFEF"
    "OneDark_Purple" = "#C678DD"
    "OneDark_Cyan" = "#56B6C2"
    "OneDark_White" = "#ABB2BF"
}

$additionalColors = @{
# Пастельные тона
    "PastelPink" = "#FFD1DC"
    "PastelBlue" = "#AEC6CF"
    "PastelGreen" = "#77DD77"
    "PastelYellow" = "#FDFD96"
    "PastelPurple" = "#B19CD9"
    "PastelLavender" = "#E6E6FA"
    "PastelMint" = "#F5FFFA"
    "PastelPeach" = "#FFCBA4"

    # Металлические оттенки
    "Silver" = "#C0C0C0"
    "Bronze" = "#CD7F32"
    "Copper" = "#B87333"
    "Platinum" = "#E5E4E2"
    "RoseGold" = "#E8B4B8"
    "Champagne" = "#F7E7CE"

    # Природные цвета
    "SkyBlue" = "#87CEEB"
    "SeaGreen" = "#2E8B57"
    "SandyBrown" = "#F4A460"
    "Turquoise" = "#40E0D0"
    "Olive" = "#808000"
    "Maroon" = "#800000"
    "Navy" = "#000080"

    # Энергетические/неоновые цвета
    "ElectricLime" = "#CCFF00"
    "LaserRed" = "#FF0F0F"
    "NeonOrange" = "#FF6600"
    "PlasmaViolet" = "#8B00FF"
    "ElectricBlue" = "#7DF9FF"
    "NeonGreen" = "#39FF14"
    "HotPink" = "#FF69B4"

    # Дополнительные популярные цвета
    "Lavender" = "#E6E6FA"
    "Coral" = "#FF7F50"
    "Mint" = "#98FB98"
    "Salmon" = "#FA8072"
    "DeepPurple" = "#6A0DAD"
    "OceanBlue" = "#006994"
    "ForestGreen" = "#228B22"
    "SunsetOrange" = "#FF8C00"
    "RoyalPurple" = "#7851A9"
    "LimeGreen" = "#32CD32"
    "GoldYellow" = "#FFD700"
    "CrimsonRed" = "#DC143C"
    "TealBlue" = "#008080"
    "Violet" = "#8A2BE2"
    "Indigo" = "#4B0082"

    # Украинские цвета 🇺🇦
    "UkraineBlue" = "#0057B7"
    "UkraineYellow" = "#FFD500"
}

# RGB версии цветов (оптимизированы)
$colorsRGB = @{
# Основные цвета (исправлены для лучшего отображения)
    "BlackRGB" = @{
        R = 0; G = 0; B = 0
    }
    "WhiteRGB" = @{
        R = 255; G = 255; B = 255
    }
    "CyanRGB" = @{
        R = 0; G = 255; B = 255
    }
    "MagentaRGB" = @{
        R = 255; G = 0; B = 255
    }
    "YellowRGB" = @{
        R = 255; G = 255; B = 0
    }
    "OrangeRGB" = @{
        R = 255; G = 165; B = 0
    }
    "PinkRGB" = @{
        R = 255; G = 192; B = 203
    }
    "PurpleRGB" = @{
        R = 128; G = 0; B = 128
    }
    "LimeRGB" = @{
        R = 0; G = 255; B = 0
    }
    "TealRGB" = @{
        R = 0; G = 128; B = 128
    }
    "GoldRGB" = @{
        R = 255; G = 215; B = 0
    }
    "CocoaBeanRGB" = @{
        R = 79; G = 56; B = 53
    }

    # Неоновые цвета
    "NeonBlueRGB" = @{
        R = 77; G = 200; B = 255
    }
    "NeonMaterial_LightGreen" = @{
        R = 57; G = 255; B = 20
    }
    "NeonPinkRGB" = @{
        R = 255; G = 70; B = 200
    }
    "NeonRedRGB" = @{
        R = 255; G = 55; B = 100
    }

    # Градиентные цвета
    "Sunset1RGB" = @{
        R = 255; G = 94; B = 77
    }
    "Sunset2RGB" = @{
        R = 255; G = 154; B = 0
    }
    "Ocean1RGB" = @{
        R = 0; G = 119; B = 190
    }
    "Ocean2RGB" = @{
        R = 0; G = 180; B = 216
    }
    "Ocean3RGB" = @{
        R = 0; G = 150; B = 160
    }
    "Ocean4RGB" = @{
        R = 0; G = 205; B = 230
    }
    "UkraineBlueRGB" = @{
        R = 0; G = 87; B = 183
    }
    "UkraineYellowRGB" = @{
        R = 255; G = 213; B = 0
    }
}


$RAINBOWGRADIENT = @(
"#FF0000",
"#FF4000",
"#FF8000",
"#FFBF00",
"#FFFF00",
"#CCFF00",
"#80FF00",
"#40FF00",
"#00FF00",
"#00FF40",
"#00FF80",
"#00FFBF",
"#00FFFF",
"#8000FF",
"#BF00FF",
"#FF00FF")

$RAINBOWGRADIENT2 = @(
'#FF0000',
'#FF5500',
'#FFAA00',
'#FFFF00',
'#AAFF00',
'#55FF00',
'#00FF00',
'#00FF55',
'#00FFAA',
'#00FFFF',
'#00AAFF',
'#0055FF',
'#0000FF',
'#5500FF',
'#AA00FF',
'#FF00FF'
)


# Подгрузка PSD1 файла
$fileColors = Import-PowerShellDataFile "$global:profilePath/Utils/resourses/filecolors.psd1"
# Функция для получения цвета файла
function Get-FileColor($fileName) {
    $extension = [System.IO.Path]::GetExtension($fileName).ToLower()
    
    # Прямое обращение к хеш-таблице (быстрее)
    $color = $fileColors.Types.Files[$extension]
    if ($color) { return $color }
    
    # Если не найден точный match, проверяем WellKnown файлы
    $wellKnownColor = $fileColors.Types.Files.WellKnown[$fileName]
    if ($wellKnownColor) { return $wellKnownColor }
    
    # Возвращаем цвет по умолчанию
    return $fileColors.Types.Files['']
}
# Использование
# $color = Get-FileColor "script.ps1"  # '#00BFFF'
# $color = Get-FileColor "README.md"   # '#00FFFF'     # '#e4eee4'

# Функция для получения цвета директории
function Get-DirectoryColor($dirName) {
    $dirNameLower = $dirName.ToLower()
    
    # Проверяем WellKnown папки
    $wellKnownColor = $fileColors.Types.Directories.WellKnown[$dirNameLower]
    if ($wellKnownColor) { 
        return $wellKnownColor 
    }
    
    # Проверяем специальные типы
    if (Test-Path $dirName -PathType Container) {
        $item = Get-Item $dirName
        if ($item.LinkType -eq 'SymbolicLink') {
            return $fileColors.Types.Directories.symlink
        }
        if ($item.LinkType -eq 'Junction') {
            return $fileColors.Types.Directories.junction
        }
    }
    
    # Цвет по умолчанию для обычных папок
    return $fileColors.Types.Directories['']
}
# Примеры использования
# $color1 = Get-DirectoryColor "Documents"    # '#00BFFF'
# $color2 = Get-DirectoryColor ".git"         # '#FF4500'
# $color3 = Get-DirectoryColor "MyFolder"     # '#e4eee4' (default)

#цвета для eza
$Env:LS_COLORS = @(
    "di=1;36", # директории — ярко-бирюзовый
    "ln=1;35", # символические ссылки — фиолетовый
    "so=1;33", # сокеты — жёлтый
    "pi=1;33", # пайпы — жёлтый
    "ex=1;32", # исполняемые — зелёный
    "bd=1;44", # блочные устройства — синий
    "cd=1;44", # символьные устройства — синий
    "or=1;31", # битые ссылки — красный
    "*.ps1=1;36", # PowerShell скрипты — бирюзовый
    "*.sh=1;32", # shell — зелёный
    "*.md=1;35", # markdown — фиолетовый
    "*.json=1;33", # JSON — жёлтый
    "*.pdf=1;31", # PDF — красный
    "*.png=1;35", # изображения — фиолетовый
    "*.jpg=1;35",
    "*.jpeg=1;35",
    "*.zip=1;34", # архивы — синий
    "*.7z=1;34",
    "*.rar=1;34",
    "*.exe=1;31", # .exe — красный
    "*.dll=0;36", # .dll — бирюзовый
    "*.log=0;90"        # логи — тёмно-серый
) -join ":"


importProcess  $MyInvocation.MyCommand.Name.trim('.ps1')