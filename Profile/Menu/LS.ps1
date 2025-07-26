# ===== УЛУЧШЕННЫЙ LS С RGB И ИКОНКАМИ =====
function lss
{
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
    foreach ($item in $items)
    {


        $color = Get-GradientColor -Index $col -TotalItems $items.length -StartColor "#8B00FF" -EndColor "#00BFFF"
        $col++
        if ($item.PSIsContainer)
        {
            Write-RGB "📂 " -FC Ocean1RGB
            Write-RGB ("{0,-35}" -f $item.Name) -FC Ocean1RGB
            Write-RGB " <DIR>" -FC $color  -newline
        }
        else
        {
            $icon = Get-FileIcon  $item.Extension
            $color = Get-FileColor $item.Extension

            $sizeColor = if ($item.Length -gt 1GB)
            {
                "#FF0000"
            }
            elseif ($item.Length -gt 100MB)
            {
                "Sunset1RGB"
            }
            elseif ($item.Length -gt 10MB)
            {
                "NeonRedRGB"
            }
            elseif ($item.Length -gt 1MB)
            {
                "OrangeRGB"
            }
            elseif ($item.Length -gt 100KB)
            {
                "LimeRGB"
            }
            else
            {
                "TealRGB"
            }

            Write-RGB "$icon " -FC White
            Write-RGB ("{0,-35}" -f $item.Name) -FC $color
            Write-RGB (" {0,10:N2} KB" -f ($item.Length / 1KB)) -FC $sizeColor
            Write-RGB ("  {0}" -f $item.LastWriteTime.ToString("yyyy-MM-dd HH:mm"),,[System.Globalization.CultureInfo]::GetCultureInfo("ru-RU")) -FC TealRGB -newline
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

    Write-RGB "📊 Total: " -FC GoldRGB
    Write-RGB "$count items " -FC White
    Write-RGB "(📂 $dirs dirs, 📄 $files files)" -FC CyanRGB -newline
}