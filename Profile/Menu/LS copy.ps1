
Trace-ImportProcess  $MyInvocation.MyCommand.Name.trim(".ps1") -start
# ===== УЛУЧШЕННЫЙ LS С RGB И ИКОНКАМИ =====
function lss {
    param(
        [string]$Path = ".",
        [string]$StartColor = "#8B00FF",
        [string]$EndColor = "#00BFFF"
    )

    Write-RGB "`n📁 " -FC CyanRGB
    Write-RGB "Directory: " -FC CyanRGB
    Write-RGB (Resolve-Path $Path).Path -FC Yellow -newline

    # Градиентная линия
    $lineLength = 60
    for ($i = 0; $i -lt $lineLength; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems $lineLength -StartColor $StartColor -EndColor  $EndColor
        Write-RGB "─" -FC $color
    }
    Write-RGB "" -newline

    $items = Get-ChildItem $Path | Sort-Object PSIsContainer -Descending

    $col = 0
    foreach ($item in $items) {


        $color = Get-GradientColor -Index $col -TotalItems $items.length -StartColor "#8B00FF" -EndColor "#00BFFF"
        $col++
        if ($item.PSIsContainer) {
            Write-RGB "📂 " -FC Ocean1RGB
            Write-RGB ("{0,-35}" -f $item.Name) -FC Ocean1RGB
            Write-RGB " <DIR>" -FC $color  -newline
        }
        else {
            $icon = Get-FileIcon  $item.Extension
            $color = Get-FileColor $item.Extension



            $sizeColor = "#888888"
            if ($item.Length -gt 1GB) {
                $sizeColor = "#FF0000"
            } elseif ($item.Length -lt 1KB){
                    $sizeColor = "#BBBBAA"
            }
            else {
                $k = 0.2
                $_red = [math]::Round(255 * [math]::Pow( $item.Length / 1GB, $k))               
                $_blue = (255 - $_red) / 1.33
                $_green = $_blue / 1.5                
                if ($item.Length -lt 99999) {
                    $_green = 200 - [math]::Round(255 *  $item.Length / 99999)
                    $_red = [math]::Round(255 *  $item.Length / 220KB)
                }                 
                $red = nthp $_red
                $green = nthp $_green
                $blue = nthp $_blue
                $sizeColor = "#${red}${green}${blue}"
            }


 

            Write-RGB "$icon "      
            Write-GradientText ("{0,-25}" -f $item.Name).Substring(0, 25) -StartColor $color -EndColor $sizeColor  -NoNewline
            if ($item.Length -gt 111111) {
                Write-RGB ("{0,10:N1} MB" -f ($item.Length / 1MB)) -FC $sizeColor
            }
            else {                
                Write-RGB ("{0,10}  B" -f (("{0:N0}" -f $item.Length).Replace(',', ' '))) -FC $sizeColor
            }
            # Write-RGB ("  {0}" -f $item.LastWriteTime.ToString("yyyy-MM-dd HH:mm"),,[System.Globalization.CultureInfo]::GetCultureInfo("ru-RU")) -FC TealRGB -newline
            Write-RGB ("  {0}" -f $item.LastWriteTime.ToString("dd MMM"), , [System.Globalization.CultureInfo]::GetCultureInfo("ru-RU")).trim('.') -FC TealRGB -newline
        }
    }


    # Градиентная линия
    for ($i = 0; $i -lt $lineLength; $i++) {
        $color = Get-GradientColor -Index $i -TotalItems $lineLength -StartColor "#00BFFF" -EndColor "#8B00FF"
        Write-RGB "─" -FC $color
    }
    Write-RGB "" -newline

    $count = $items.Count
    $dirs = ($items | Where-Object PSIsContainer).Count
    $files = $count - $dirs


    # $d = Get-Date
    # return $withYear ? "{0:dd} {1} {0:yyyy}" -f $d, $months[$d.Month] : "{0:dd} {1}" -f $d, $months[$d.Month]
    Write-RGB "📊 Total: " -FC GoldRGB
    Write-RGB "$count items " -FC White
    Write-RGB "(📂 $dirs dirs, 📄 $files files)" -FC CyanRGB -newline
}

Set-Alias -Name ls -Value lss -Force
Trace-ImportProcess  $MyInvocation.MyCommand.Name.trim(".ps1")
