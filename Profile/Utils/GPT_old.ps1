<#
GPT.ps1 — GPT helpers with TrueColor + gradients + $global:RGB support
#>

$script:AI_TOOLS_ROOT = if ($PSScriptRoot)
{ $PSScriptRoot }
elseif ($PSCommandPath)
{ Split-Path -Parent $PSCommandPath }
else
{ (Get-Location).Path }

function Write-Section
{
    param([string]$Title, [switch]$NoColor)
    $line = ("=" * 80)
    if ($NoColor)
    { Write-Output ""; Write-Output $line; Write-Output ("  " + $Title); Write-Output $line }
    else
    { Write-Host ""; Write-Host $line -ForegroundColor Cyan; Write-Host ("  " + $Title) -ForegroundColor Cyan; Write-Host $line -ForegroundColor Cyan }
}

function To-Hashtable
{
    param([object]$Obj)
    if ($null -eq $Obj)
    { return $null }
    if ($Obj -is [hashtable])
    { return $Obj }
    $h = @{ }
    foreach ($p in $Obj.PSObject.Properties)
    { $h[$p.Name] = $p.Value }
    $h
}


function Add-KeywordRule
{
    param(
        [Parameter(Mandatory)] [string]$ConfigPath,
        [Parameter(Mandatory)] [string]$Name,
        [Parameter(Mandatory)] [string[]]$Words,
        [string]$Hex, [string]$RgbName
    )
    $cfg = Get-Content $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $escaped = $Words | ForEach-Object { [Regex]::Escape($_) }
    $pat = '(?i)\b(' + ($escaped -join '|') + ')\b'
    $rule = if ($RgbName)
    {
        [pscustomobject]@{ name = $Name; rgbName = $RgbName; pattern = $pat }
    }
    else
    {
        [pscustomobject]@{ name = $Name; hex = $Hex; pattern = $pat }
    }
    $cfg.rules = @($rule) + @($cfg.rules)   # добавим в начало
    ($cfg | ConvertTo-Json -Depth 6) | Set-Content -Path $ConfigPath -Encoding UTF8
}

# пример:
#Add-KeywordRule -ConfigPath .\colorize.json -Name 'Web3' -Words @('ethers','wagmi','viem','metamask') -Hex '#F59E0B'


function Invoke-ColorLine
{
    param(
        [string]$Line,
        [string]$Hex,
        [hashtable]$Gradient,
        [Array]$InlineRules,
        [hashtable]$Md,
        [switch]$Debug
    )
    $out = $Line
    { Write-Output $Line; return }

    # ---- Градиент: inline цвета с градиентом не смешиваем (дорого и «рябит»),
    # но маркдаун-маркеры снимем, чтобы не видеть ** ** и т.п.
    if ($Gradient -and $Gradient.from -and $Gradient.to)
    {
        $text = $Line
        if ($Md -and $Md.inline)
        {
            $text = Apply-MarkdownInline -Line $text -Md $Md -ReenterAnsi $null -Debug:$DebugColorize
        }

        # Style[] для Write-GradientText
        $styles = @()
        if ($Gradient.PSObject.Properties.Name -contains 'style' -and $Gradient.style)
        {
            if ($Gradient.style -is [array])
            { $styles += $Gradient.style }
            else
            { $styles += [string]$Gradient.style }
        }
        if ([bool]$Gradient.bold)
        { $styles += 'Bold' }
        if ($styles.Count -eq 0)
        { $styles = @('Normal') }
        Write-RGB $Gradient.from -FC "#112299"
        Write-RGB $Gradient.to -FC "#11AA11"
        $gradStr = Write-GradientText -Text $text -StartColor $Gradient.from -EndColor $Gradient.to -Style $styles
        return $gradStr
    }

    # ---- Однотонная строка: сначала inline-подсветка и markdown, затем зальём базовым цветом
    if ($Hex)
    {
        Write-RGB  $text -FC $Hex

    }

    # fallback — без цвета
    Write-Host $Line
}

function Fix-JsonRegex {
    param([string]$Pattern)
    if (-not $Pattern) { return $Pattern }
    # заменяем реальный backspace ( `b ) на текст \b для Regex
    $Pattern = $Pattern -replace "`b", '\b'
    # по желанию: форс-UTF-8 и т.п.
    return $Pattern
}


# --- Config loader ------------------------------------------------------------
function Get-ColorizeConfig
{
    [CmdletBinding()]
    param([string]$ConfigPath, [string]$Theme = 'Nord')
    if (-not $ConfigPath)
    {
        $ConfigPath = Join-Path $script:AI_TOOLS_ROOT "resourses/colorize.json"
    }
    if (Test-Path $ConfigPath)
    {
        try
        {
            $json = Get-Content $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable -ErrorAction Stop
            foreach ($r in @($cfg.Rules)) {
                if ($r.ContainsKey('pattern')) { $r.pattern = Fix-JsonRegex $r.pattern }
            }
            foreach ($ir in @($cfg.InlineRules)) {
                if ($ir.ContainsKey('pattern')) { $ir.pattern = Fix-JsonRegex $ir.pattern }
            }
            foreach ($r in @($cfg.Rules)) {
                if ($r.ContainsKey('pattern')) { $r.pattern = Fix-JsonRegex $r.pattern }
            }
            foreach ($md in @($cfg.Md)) {
                if ($md.ContainsKey('pattern')) { $md.pattern = Fix-JsonRegex $md.pattern }
            }
            if ($json.theme)
            {
                $Theme = $json.theme
            }
            return @{
                Theme = $Theme
                Rules = @($json.rules)
                Themes = $json.themes
                Md = $json.Md
            }
        }
        catch
        {
            Write-Warning "Failed to parse colorize config: $ConfigPath. Using built-in defaults. $_"
        }
    }
    $defaults = @{
    InlineRules = @()
    theme = $Theme
    themes = @{
    Default = @{
    Red = 'Red'; Yellow = 'Yellow'; Green = 'Green'; Blue = 'Blue'; Gray = 'DarkGray'; Bullet = 'DarkYellow'; Cyan = 'Cyan'; Magenta = 'Magenta'
    }
    Nord = @{
    Red = 'Red'; Yellow = 'DarkYellow'; Green = 'Green'; Blue = 'Cyan'; Gray = 'DarkGray'; Bullet = 'Yellow'; Cyan = 'Cyan'; Magenta = 'Magenta'
    }
    Dracula = @{
    Red = 'Magenta'; Yellow = 'Yellow'; Green = 'Green'; Blue = 'Cyan'; Gray = 'Gray'; Bullet = 'DarkYellow'; Cyan = 'Cyan'; Magenta = 'Magenta'
    }
    }
    rules = @(
    @{
    name = 'Error'; hex = '#ff4d4f'; pattern = '(?i)\b(error|ошибка|failed|exception|fatal)\b'
    },
    @{
    name = 'Warning'; hex = '#ffc53d'; pattern = '(?i)\b(warn|warning|предупреждение|замечание|risk|риск)\b'
    },
    @{
    name = 'Security'; hex = '#ff4dff'; pattern = '(?i)\b(security|безопасн|xss|csrf|ssrf|sqli|rce|injection)\b'
    },
    @{
    name = 'Performance'; hex = '#36cfc9'; pattern = '(?i)\b(perf|performance|оптимизац|latency|throughput|memory|alloc)\b'
    },
    @{
    name = 'Deprecated'; hex = '#fa8c16'; pattern = '(?i)\b(deprecated|устаревш|legacy)\b'
    },
    @{
    name = 'TodoFixme'; gradient = @{
    from = '#ffd166'; to = '#ef476f'; bold = $true
    }; pattern = '(?i)\b(todo|fixme)\b'
    },
    @{
    name = 'Success'; hex = '#4caf50'; pattern = '(?i)\b(success|успех|passed|ok|done)\b'
    },
    @{
    name = 'Info'; hex = '#40a9ff'; pattern = '^(?i)\s*(info|инфо|note|заметка)\s*:'
    },
    @{
    name = 'FilePos'; gradient = @{
    from = '#56ccf2'; to = '#2f80ed'
    }; pattern = '^(?i)\s*(файл|file|строка|line|колонка|column)\s*:'
    },
    @{
    name = 'Bullet'; hex = '#e6a700'; pattern = '^\s*([-•—])\s+'
    },
    @{
    name = 'CodeFence'; hex = '#888888'; pattern = '^\s*```'
    }
    )
    }
    return @{
    Theme = $defaults.theme
    Rules = $defaults.rules
    Themes = $defaults.themes
    InlineRules = @($json.inlineRules)
    Md = $cfg.Md
    }
}



function Get-GradientColor {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$Index,
        [Parameter(Mandatory)][int]$TotalItems,
        [string]$StartColor = '#FF0000',
        [string]$EndColor   = '#0000FF',
        [ValidateSet('Linear','Exponential','Sine','Cosine','Quadratic','Smooth')]
        [string]$GradientType = 'Linear',
        [switch]$LinearSpace,   # интерполировать в линейном sRGB (лучше визуально)
        [switch]$UseCache
    )

    # кеш-слой
    if ($UseCache) {
        if (-not $script:ColorSystemConfig) { $script:ColorSystemConfig = @{ Cache = @{ GradientColors = @{} } } }
        elseif (-not $script:ColorSystemConfig.Cache) { $script:ColorSystemConfig.Cache = @{ GradientColors = @{} } }
        elseif (-not $script:ColorSystemConfig.Cache.GradientColors) { $script:ColorSystemConfig.Cache.GradientColors = @{} }
        $cacheKey = "$Index|$TotalItems|$StartColor|$EndColor|$GradientType|lin:$($LinearSpace.IsPresent)"
        if ($script:ColorSystemConfig.Cache.GradientColors.ContainsKey($cacheKey)) {
            return $script:ColorSystemConfig.Cache.GradientColors[$cacheKey]
        }
    }

    if ($TotalItems -le 1)        { return $StartColor }
    if ($Index -le 0)             { return $StartColor }
    if ($Index -ge $TotalItems-1) { return $EndColor   }

    # позиция
    $t = $Index / [double]($TotalItems - 1)
    switch ($GradientType) {
        'Linear'      { }                                   # t как есть
        'Exponential' { $t = [Math]::Pow($t, 2) }
        'Sine'        { $t = [Math]::Sin($t * [Math]::PI/2) }
        'Cosine'      { $t = 1 - [Math]::Cos($t * [Math]::PI/2) }
        'Quadratic'   { if ($t -lt 0.5){ $t = 2*$t*$t } else { $t = 1 - [Math]::Pow(-2*$t+2,2)/2 } }
        'Smooth'      { $t = $t*$t*(3-2*$t) }               # smoothstep
    }

    $a = ConvertTo-RGBComponents $StartColor
    $b = ConvertTo-RGBComponents $EndColor

    function SrgbToLin([double]$c){ $n=$c/255.0; if($n -le 0.04045){ $n/12.92 } else { [math]::Pow(($n+0.055)/1.055,2.4) } }
    function LinToSrgb([double]$x){ if($x -le 0.0031308){ 12.92*$x } else { 1.055*[math]::Pow($x,1/2.4)-0.055 } }
    function Lerp([double]$u,[double]$x,[double]$y){ (1-$u)*$x + $u*$y }
    function ClampByte([double]$v){ $i=[int][math]::Round($v); if($i -lt 0){0}elseif($i -gt 255){255}else{$i} }

    if ($LinearSpace) {
        $ar = SrgbToLin $a.R; $ag = SrgbToLin $a.G; $ab = SrgbToLin $a.B
        $br = SrgbToLin $b.R; $bg = SrgbToLin $b.G; $bb = SrgbToLin $b.B
        $r = ClampByte (255 * (LinToSrgb (Lerp $t $ar $br)))
        $g = ClampByte (255 * (LinToSrgb (Lerp $t $ag $bg)))
        $bl= ClampByte (255 * (LinToSrgb (Lerp $t $ab $bb)))
    } else {
        $r = ClampByte (Lerp $t $a.R $b.R)
        $g = ClampByte (Lerp $t $a.G $b.G)
        $bl= ClampByte (Lerp $t $a.B $b.B)
    }

    $result = ConvertFrom-RGBToHex -R $r -G $g -B $bl
    if ($UseCache) { $script:ColorSystemConfig.Cache.GradientColors[$cacheKey] = $result }
    $result
}

function Render-GradientText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$StartColor,
        [Parameter(Mandatory)][string]$EndColor,
        [ValidateSet('Linear','Exponential','Sine','Cosine','Quadratic','Smooth')]
        [string]$Easing = 'Smooth',
        [switch]$LinearSpace,
        [switch]$Bold,
        [switch]$ReturnString   # если нужен именно строковый результат
    )

    if ([string]::IsNullOrEmpty($Text)) { if($ReturnString){return ''} else {return} }

    $chars = $Text.ToCharArray()
    $sb = [System.Text.StringBuilder]::new()

    for ($i=0; $i -lt $chars.Length; $i++) {
        $hex = Get-GradientColor -Index $i -TotalItems $chars.Length `
                             -StartColor $StartColor -EndColor $EndColor `
                             -GradientType $Easing -LinearSpace -UseCache
        $ansi = Get-RGBColor $hex
        if ($Bold) { [void]$sb.Append($PSStyle.Bold) }
        [void]$sb.Append($ansi)
        [void]$sb.Append($chars[$i])
    }
    [void]$sb.Append($PSStyle.Reset)

    if ($ReturnString) { return $sb.ToString() }
    else { Write-Host $sb.ToString() }
}


function Get-FlatAnsi {
    param([Parameter(Mandatory)][object]$StyleObj)
    # To-Hashtable у тебя уже есть — используем
    $S = To-Hashtable $StyleObj
    $on = ''
    if ($S.ContainsKey('bold') -and [bool]$S.bold) { $on += $PSStyle.Bold }

    if     ($S.hex)     { $on += Get-RGBColor $S.hex }
    elseif ($S.Hex)     { $on += Get-RGBColor $S.Hex }
    elseif ($S.rgbName) { $on += ($global:RGB.ContainsKey($S.rgbName) ? (Get-RGBColor $global:RGB[$S.rgbName]) : (Get-RGBColor $S.rgbName)) }
    elseif ($S.RgbName) { $on += ($global:RGB.ContainsKey($S.RgbName) ? (Get-RGBColor $global:RGB[$S.RgbName]) : (Get-RGBColor $S.RgbName)) }
    elseif ($S.rgb)     { $on += Get-RGBColor @{ R=$S.rgb.R; G=$S.rgb.G; B=$S.rgb.B } }
    elseif ($S.Rgb)     { $on += Get-RGBColor @{ R=$S.Rgb.R; G=$S.Rgb.G; B=$S.Rgb.B } }
    elseif ($StyleObj -is [string]) {
        if ($global:RGB.ContainsKey($StyleObj)) { $on += Get-RGBColor $global:RGB[$StyleObj] }
        else { $on += Get-RGBColor $StyleObj }
    }

    @{ on = $on; off = $PSStyle.Reset }
}

function Get-SrgbGradientSteps {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$StartHex,
        [Parameter(Mandatory)][string]$EndHex,
        [Parameter(Mandatory)][int]$Count,
        [ValidateSet('linear','smooth')][string]$Easing = 'smooth'
    )

    function _HexToRGB([string]$h) {
        $x = $h.TrimStart('#')
        if ($x.Length -eq 3) { $x = "$($x[0])$($x[0])$($x[1])$($x[1])$($x[2])$($x[2])" }
        [pscustomobject]@{
            R = [Convert]::ToInt32($x.Substring(0,2),16)
            G = [Convert]::ToInt32($x.Substring(2,2),16)
            B = [Convert]::ToInt32($x.Substring(4,2),16)
        }
    }
    function _SrgbToLin([double]$c){ $n=$c/255.0; if($n -le 0.04045){ $n/12.92 } else { [math]::Pow(($n+0.055)/1.055,2.4) } }
    function _LinToSrgb([double]$x){ if($x -le 0.0031308){ 12.92*$x } else { 1.055*[math]::Pow($x,1/2.4)-0.055 } }
    function _Ease([double]$t,[string]$m){ if($m -eq 'smooth'){ return $t*$t*(3-2*$t) } $t }
    function _ClampByte([double]$v){ $i=[int][math]::Round($v); if($i -lt 0){0}elseif($i -gt 255){255}else{$i} }

    $a=_HexToRGB $StartHex; $b=_HexToRGB $EndHex
    $aL=@{ R=_SrgbToLin $a.R; G=_SrgbToLin $a.G; B=_SrgbToLin $a.B }
    $bL=@{ R=_SrgbToLin $b.R; G=_SrgbToLin $b.G; B=_SrgbToLin $b.B }

    $res = New-Object System.Collections.Generic.List[string]
    $n = [math]::Max(1,$Count)
    for($i=0;$i -lt $n;$i++){
        $t = if($n -gt 1){ $i/([double]($n-1)) } else { 0.0 }
        $u = _Ease $t $Easing
        $r = _LinToSrgb( (1-$u)*$aL.R + $u*$bL.R )
        $g = _LinToSrgb( (1-$u)*$aL.G + $u*$bL.G )
        $b2= _LinToSrgb( (1-$u)*$aL.B + $u*$bL.B )
        $R8=_ClampByte(255*$r); $G8=_ClampByte(255*$g); $B8=_ClampByte(255*$b2)
        $res.Add( ('#{0:X2}{1:X2}{2:X2}' -f $R8,$G8,$B8) )
    }
    $res
}

function Render-GradientText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$StartColor,
        [Parameter(Mandatory)][string]$EndColor,
        [ValidateSet('linear','smooth')][string]$Easing='smooth',
        [switch]$Bold,
        [switch]$ReturnString
    )
    if ([string]::IsNullOrEmpty($Text)) { if($ReturnString){return ''} else {return} }

    $chars = $Text.ToCharArray()
    $steps = Get-SrgbGradientSteps -StartHex $StartColor -EndHex $EndColor -Count $chars.Length -Easing $Easing

    $sb = [System.Text.StringBuilder]::new()
    for($i=0;$i -lt $chars.Length;$i++){
        $ansi = Get-RGBColor $steps[$i]
        if($Bold){ $null=$sb.Append($PSStyle.Bold) }
        $null=$sb.Append($ansi)
        $null=$sb.Append($chars[$i])
    }
    $null=$sb.Append($PSStyle.Reset)
    if($ReturnString){ return $sb.ToString() } else { Write-Host $sb.ToString() }
}
# --- Colorizer ----------------------------------------------------------------

function Colorize-Span
{
    param(
        [string]$Text,
        [Parameter(Mandatory)][object]$Style,
        [string]$ReenterAnsi,
        [switch]$TraceColorize  # ← добавили
    )

    # нормализуем
    $S = To-Hashtable $Style


    # градиент
    if ( $S.ContainsKey('gradient'))
    {
        $g = To-Hashtable $S.gradient

        $chars = $Text.ToCharArray()    # на всякий

        $sb = [System.Text.StringBuilder]::new()
        for ($i=0; $i -lt $chars.Length; $i++) {
            $color = Get-GradientColor -Index $i -TotalItems $chars.Length `
                                     -StartColor $g.from`
                                     -EndColor  $g.to `
                                     -GradientType "Sine" `
                                     -Style  Bold:([bool]$g.bold)
            [void]$sb.Append(  $color)
            [void]$sb.Append($chars[$i])
        }
        $off = "`e[39m`e[22m"
        if ($ReenterAnsi) { $off += $ReenterAnsi }
        [void]$sb.Append($off)
        return $sb.ToString()
    }


    $flat = Get-FlatAnsi -StyleObj $Style
    if ($flat -and $flat.on) {
        $on  = $flat.on
        $off = $flat.off + ($ReenterAnsi ?? '')
        return $on + $Text + $off
    }

    # только bold
    if ($S.bold)
    {
        $on = "`e[1m"; $off = "`e[22m"; if ($ReenterAnsi)
        { $off += $ReenterAnsi }
        return $on + $Text + $off
    }
    $Text
}

function Apply-MarkdownInline
{
    param(
        [string]$Line,
        [hashtable]$Md, # $cfg.Md
        [string]$ReenterAnsi,
        [switch]$Debug
    )
    if (-not $Md -or -not $Md.inline)
    { return $Line }
    $Md = To-Hashtable $Md
    $S = if ($Md.inline)
    { To-Hashtable $Md.inline }
    else
    { $null }

    $out = $Line

    # ссылки: [text](url)
    $out = [regex]::Replace($out, '\[([^\]]+)\]\(([^)]+)\)', {
        param($m)
        $txt = Colorize-Span -Text $m.Groups[1].Value -Style (To-Hashtable $S.linkText) -ReenterAnsi $ReenterAnsi   -TraceColorize:$Debug
        $url = Colorize-Span -Text $m.Groups[2].Value -Style (To-Hashtable $S.linkUrl)  -ReenterAnsi $ReenterAnsi  -TraceColorize:$Debug
        $txt + " " + $url
    })

    # code: `...`
    $out = [regex]::Replace($out, '`([^`\r\n]+)`', {
        param($m) (Colorize-Span -Text $m.Groups[1].Value -Style (To-Hashtable $S.code) -ReenterAnsi $ReenterAnsi  -TraceColorize:$Debug)
    })

    # bold: **...** или __...__
    $out = [regex]::Replace($out, '\*\*([^*]+)\*\*', { param($m) (Colorize-Span -Text $m.Groups[1].Value -Style (To-Hashtable $S.bold) -ReenterAnsi $ReenterAnsi  -TraceColorize:$Debug) })
    $out = [regex]::Replace($out, '__([^_]+)__', { param($m) (Colorize-Span -Text $m.Groups[1].Value -Style (To-Hashtable $S.bold) -ReenterAnsi $ReenterAnsi  -TraceColorize:$Debug) })

    # italic: *...* или _..._
    $out = [regex]::Replace($out, '(?<!\*)\*([^*]+)\*(?!\*)', { param($m) (Colorize-Span -Text $m.Groups[1].Value -Style (To-Hashtable $S.italic) -ReenterAnsi $ReenterAnsi -TraceColorize:$Debug) })
    $out = [regex]::Replace($out, '(?<!_)_([^_]+)_(?!_)', { param($m) (Colorize-Span -Text $m.Groups[1].Value -Style (To-Hashtable $S.italic) -ReenterAnsi $ReenterAnsi  -TraceColorize:$Debug) })

    # strike: ~~...~~
    $out = [regex]::Replace($out, '~~([^~]+)~~', { param($m) (Colorize-Span -Text $m.Groups[1].Value -Style (To-Hashtable $S.strike) -ReenterAnsi $ReenterAnsi  -TraceColorize:$Debug) })

    # списки: убираем маркеры, если попросили
    if ($Md.stripMarkers)
    {
        $out = [regex]::Replace($out, '^\s*[-*+]\s+', '')
        $out = [regex]::Replace($out, '^\s*\d+\.\s+', '')
    }

    $out
}


function Apply-MarkdownBlock
{
    param(
        [string]$Line,
        [hashtable]$Md,
        [ref]$State,
        [switch]$Debug
    )
    if (-not $Md)
    { return $null }  # нет изменений
    # тройные бэктики
    if ($Line -match '^\s*```')
    {
        $State.Value.inFence = -not $State.Value.inFence
        return ""  # строку-фенс скрываем
    }

    if ($State.Value.inFence)
    {
        # внутри кода — однотонный стиль
        $Md = To-Hashtable $Md
        $style = if ($Md.inline.code)
        { To-Hashtable $Md.inline.code }
        else
        { $null }
        return (Colorize-Span -Text $Line -Style $style -ReenterAnsi $null  -TraceColorize:$Debug)
    }

    # блок-цитата
    $m = [regex]::Match($Line, '^\s*>\s?(.*)$')
    if ($m.Success)
    {
        $content = $m.Groups[1].Value
        $Md = To-Hashtable $Md
        $style = if ($Md.blockquote)
        { To-Hashtable $Md.blockquote }
        else
        { $null }
        return (Colorize-Span -Text $content -Style $style -ReenterAnsi $null  -TraceColorize:$Debug)
    }

    # заголовки
    $hm = [regex]::Match($Line, '^(#{1,6})\s+(.*)$')
    if ($hm.Success)
    {
        $lvl = $hm.Groups[1].Value.Length
        $text = $hm.Groups[2].Value
        $hCfg = $Md.heading
        $style =
        if ($lvl -eq 1)
        { $hCfg.h1 }
        elseif ($lvl -eq 2)
        { $hCfg.h2 }
        elseif ($lvl -eq 3)
        { $hCfg.h3 }
        else
        { @{ hex = "#A78BFA" } }

        $heading = if ($Md.heading)
        { To-Hashtable $Md.heading }
        else
        { @{ } }
        $style = switch ($lvl)
        { 1 { To-Hashtable $heading.h1 } 2 { To-Hashtable $heading.h2 } default { To-Hashtable $heading.h3 } }
        return (Colorize-Span -Text $text -Style $style -ReenterAnsi $null  -TraceColorize:$Debug)
    }

    # нет блочных md-правок
    $null
}

function Apply-InlineRules {
    param(
        [Parameter(Mandatory)][string]$Line,
        [Parameter(Mandatory)][Array]$InlineRules,
        [string]$ReenterAnsi  # ← ANSI, которым мы продолжаем строку после inline-фрагмента
    )
    Write-RGB $Line -FC "#FFFFFF"
    if (-not $InlineRules -or $InlineRules.Count -eq 0) { return $Line }

    $out = $Line
    foreach ($r in $InlineRules) {
        $pat = [string]$r.pattern
        if (-not $pat) { continue }

        # получить hex для inline
        $hex = $null
        if ($r.PSObject.Properties.Name -contains 'hex')      { $hex = Resolve-ColorSpec -Spec $r.hex }
        elseif ($r.PSObject.Properties.Name -contains 'rgbName') { $hex = Resolve-ColorSpec -Spec @{ rgbName = $r.rgbName } }
        elseif ($r.PSObject.Properties.Name -contains 'rgb')  { $hex = ('#{0:X2}{1:X2}{2:X2}' -f [int]$r.rgb.R,[int]$r.rgb.G,[int]$r.rgb.B) }
        if (-not $hex) { continue }

        $bold = [bool]$r.bold
        $on  = New-AnsiFg -Hex $hex -Bold:$bold
        # вместо полного reset — только сброс текста + возврат в основной цвет строки (если задан)
        $off = if ($ReenterAnsi) { "`e[39m`e[22m" + $ReenterAnsi } else { "`e[0m" }

        $out = [regex]::Replace($out, $pat, { param($m) $on + $m.Value + $off })
    }
    return $out
}

function Colorize-GPT
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [AllowEmptyString()]
        [string]$Text,
        [object]$Theme,
        [Array]$Rules,
        [hashtable]$Themes,
        [object]$InlineRules,
        [object]$Md,
        [switch]$DebugColorize
    )
    begin {
        # нормализуем InlineRules в массив
        if ($null -eq $InlineRules)
        { $Inline = @() }
        elseif ($InlineRules -is [Array])
        { $Inline = $InlineRules }
        else
        { $Inline = @($InlineRules) }

        # нормализуем Md в hashtable
        if ($null -eq $Md)
        { $mdCfg = $null }
        elseif ($Md -is [hashtable])
        { $mdCfg = $Md }
        else
        { $mdCfg = @{ }; foreach ($p in $Md.PSObject.Properties)
        { $mdCfg[$p.Name] = $p.Value } }

        $mdState = @{ inFence = $false }
        $state = @{ inCode = $false }
        $palette = if ($Themes -and $Themes.ContainsKey($Theme))
        { $Themes[$Theme] }
        else
        {
            @{ Red = 'Red'; Yellow = 'Yellow'; Green = 'Green'; Blue = 'Blue'; Gray = 'DarkGray'; Bullet = 'DarkYellow'; Cyan = 'Cyan'; Magenta = 'Magenta' }
        }
    }
    process {
        $blk = Apply-MarkdownBlock -Line $line -Md $mdCfg -State ([ref]$mdState) -Debug:$DebugColorize
        if ($blk -ne $null)
        {
            if ($NoColor)
            { $blk }
            else
            { Write-Host $blk }; return
        }
        if ($line -eq '')
        {
            if ($NoColor)
            { '' }
            else
            { Write-Host '' }; return
        }
        # code fences
        if ($line -match '^\s*```')
        { $state.inCode = -not $state.inCode; Invoke-ColorLine -Line $line -Hex '#888888' -NoColor:$NoColor; return }
        if ($state.inCode)
        { Invoke-ColorLine -Line $line -Hex '#888888' -NoColor:$NoColor -Debug:$DebugColorize; return }

        # --- выбрать лучшее совпадение по priority (чем больше — тем важнее) ---
        $best = $null

        foreach ($r in $Rules) {
            $pat = [string]$r.pattern
            if (-not $pat) { continue }
            if ($line -match $pat) {
                $prio = 0
                if ($r.PSObject.Properties.Name -contains 'priority') { $prio = [int]$r.priority }
                if ($null -eq $best -or $prio -gt $best.priority) {
                    $best = @{ rule = $r; priority = $prio }
                }
            }
        }

        if ($best -ne $null)
        {
            $r = $best.rule
            if ($DebugColorize)
            { Write-Host ("[rule:{0}] " -f $r.name) -ForegroundColor DarkGray -NoNewline }

            if ($r.PSObject.Properties.Name -contains 'hex')
            {
                Invoke-ColorLine -Line $line -Hex $hex -NoColor:$NoColor -InlineRules $Inline -Md $mdCfg -Debug:$DebugColorize; return
            }
            if ($r.PSObject.Properties.Name -contains 'gradient' -and $r.gradient)
            {
                $mdCfg = To-Hashtable $mdCfg
                Invoke-ColorLine -Line $line -Gradient $g  -Md $mdCfg -Debug:$DebugColorize; return
            }
            if ($r.PSObject.Properties.Name -contains 'rgbName')
            {
                $hex = Resolve-ColorSpec -Spec @{ rgbName = $r.rgbName }
                $mdCfg = To-Hashtable $mdCfg
                Invoke-ColorLine -Line $line -Hex $hex -NoColor:$NoColor -InlineRules $Inline -Md $mdCfg -Debug:$DebugColorize; return
            }
            if ($r.PSObject.Properties.Name -contains 'rgb')
            {
                $hex = ('#{0:X2}{1:X2}{2:X2}' -f [int]$r.rgb.R, [int]$r.rgb.G, [int]$r.rgb.B)
                $mdCfg = To-Hashtable $mdCfg
                Invoke-ColorLine -Line $line -Hex $hex -NoColor:$NoColor -InlineRules $Inline -Md $mdCfg -Debug:$DebugColorize; return
            }
            if ($r.PSObject.Properties.Name -contains 'color')
            {
                $c = if ($r.color -eq 'Bullet')
                { $palette.Bullet }
                else
                { $r.color }
                $res = $palette[$c]
                if ($res)
                {
                    if ($NoColor)
                    { $line }
                    else
                    { Write-Host $line -ForegroundColor $res }; return
                }
            }
            if ($NoColor)
            { $line }
            else
            { Write-Host $line }; return
        }

        if ($InlineRules -or ($mdCfg -and $mdCfg.inline))
        {
            $content = if ($mdCfg -and $mdCfg.inline)
            {
                Apply-MarkdownInline -Line $line -Md $mdCfg -ReenterAnsi $lineAnsi -Debug:$DebugColorize
            }
            else
            { $line }

            if ($InlineRules)
            {
                $content = Apply-InlineRules -Line $content -InlineRules $InlineRules -ReenterAnsi $lineAnsi -Debug:$DebugColorize
            }

            Write-RGB  $content -FC  $lineAnsi
        }

        if (-not $best -and ($mdCfg -and $mdCfg.inline))
        {
            $mk = Apply-MarkdownInline -Line $line -Md $mdCfg -ReenterAnsi $null -Debug:$DebugColorize
            if ($NoColor)
            { $line }
            else
            { Write-Host ($mk) }
            return
        }

        # inline-правила (когда линейные не сработали)
        if ($InlineRules -and $InlineRules.Count -gt 0)
        {
            $colored = Apply-InlineRules -Line $content -InlineRules $InlineRules -Debug:$DebugColorize
            if ($DebugColorize)
            { Write-Host "[inline] " -ForegroundColor DarkGray -NoNewline }
            if ($NoColor)
            { $line }
            else
            { Write-Host $colored }
            return
        }

        if ($NoColor)
        { $line }
        else
        { Write-Host $line }
    }
}

# --- GPT invoker (unchanged from previous improved version, shortened here) ---
function Invoke-GPT
{
    [CmdletBinding()]
    param(
        [ValidateSet("review", "explain", "tests", "refactor")][string]$Mode = "review",
        [string]$InputPath, [string]$Text, [string]$GptPath, [switch]$NoColor, [switch]$PassThru, [switch]$DebugColorize,
        [Parameter(ValueFromPipeline = $true)][string]$PipelineText, [switch]$Colorize, [string]$ColorizeTheme = 'Nord', [string]$ColorizeConfig
    )
    begin {
        $acc = New-Object System.Text.StringBuilder
    }
    process {
        if ($PSBoundParameters.ContainsKey('PipelineText') -and $PipelineText)
        {
            [void]$acc.AppendLine($PipelineText)
        }
    }
    end {
        if (-not (Get-Command bun -ErrorAction SilentlyContinue))
        {
            throw "Bun is not installed or not in PATH. https://bun.sh"
        }
        if (-not $env:OPENAI_API_KEY)
        {
            throw "OPENAI_API_KEY is not set. Prefer a secrets manager; for testing set `$env:OPENAI_API_KEY in the current session."
        }

        $gptTs = if ($GptPath)
        {
            if (-not (Test-Path $GptPath))
            {
                throw "Provided -GptPath not found: $GptPath"
            }
            (Resolve-Path $GptPath).Path
        }
        else
        {
            $cand = Join-Path $script:AI_TOOLS_ROOT "gpt.ts"
            if (-not (Test-Path $cand))
            {
                throw "gpt.ts not found next to this script. Looked at: $cand`n→ Put gpt.ts next to AI-Tools.ps1 OR pass -GptPath 'C:\path\to\gpt.ts'"
            }
            (Resolve-Path $cand).Path
        }

        $argsList = @("run", $gptTs, $Mode)
        $fromPipe = $acc.ToString().TrimEnd()
        if ($InputPath)
        {
            if (-not (Test-Path $InputPath))
            {
                throw "InputPath not found: $InputPath"
            }
            $argsList += ,(Resolve-Path $InputPath).Path
        }
        elseif ($Text)
        {
            if ($Text.Length -gt 3500 -and $IsWindows)
            {
                $tmp = New-TemporaryFile; Set-Content -Path $tmp -Value $Text -Encoding UTF8; $argsList += ,$tmp
            }
            else
            {
                $argsList += ,$Text
            }
        }
        elseif ($fromPipe)
        {
            if ($fromPipe.Length -gt 3500 -and $IsWindows)
            {
                $tmp = New-TemporaryFile; Set-Content -Path $tmp -Value $fromPipe -Encoding UTF8; $argsList += ,$tmp
            }
            else
            {
                $argsList += ,$fromPipe
            }
        }
        else
        {
            throw "Provide -InputPath or -Text, or pipe content: Get-Content file | gpt -Mode review"
        }

        Write-Section ("GPT " + $Mode) -NoColor:$NoColor

        if ($PassThru -or $Colorize)
        {
            $out = & bun @argsList 2>&1
            $code = $LASTEXITCODE
            if ($Colorize)
            {
                $cfg = Get-ColorizeConfig -ConfigPath $ColorizeConfig -Theme $ColorizeTheme

                $out -split '\r?\n' |
                        Colorize-GPT `
    -Theme  $cfg.Theme `
    -Rules  $cfg.Rules `
    -Themes $cfg.Themes `
    -InlineRules $cfg.InlineRules `
    -Md $cfg.Md `
    -NoColor:$NoColor `
    -DebugColorize:$DebugColorize
            }
            else
            {
                $out | Write-Output
            }
            if ($code -ne 0)
            {
                throw "bun failed with exit code $code"
            }
        }
        else
        {
            & bun @argsList
            $code = $LASTEXITCODE
            if ($code -ne 0)
            {
                throw "bun failed with exit code $code"
            }
        }
    }
}

function Test-Colorize
{
    param(
        [Parameter(Mandatory)][string]$Text,
        [string]$ConfigPath
    )
    $cfg = Get-ColorizeConfig -ConfigPath $ConfigPath
    $rules = $cfg.Rules
    $counts = @{ }; foreach ($r in $rules)
    { $counts[$r.name] = 0 }

    $lines = [regex]::Split($Text, '\r?\n')
    foreach ($line in $lines)
    {
        if ($line -match '^\s*$')
        { continue }
        $matched = $false
        foreach ($r in $rules)
        {
            if ($line -match $r.pattern)
            {
                $counts[$r.name]++
                $matched = $true
                break   # first-match wins
            }
        }
        if (-not $matched)
        { $counts['__no_match__'] = 1 + ($counts['__no_match__'] ?? 0) }
    }

    $counts.GetEnumerator() |
            Sort-Object -Property Value -Descending |
            Format-Table Name,Value
}

# Alias (safe)
$aliasName = "gpt"; try
{
    if (Get-Alias $aliasName -ErrorAction SilentlyContinue)
    {
        $aliasName = "ai-gpt"
    }
}
catch
{ }
Set-Alias -Name $aliasName -Value Invoke-GPT -ErrorAction SilentlyContinue
$script:AI_TOOLS_ALIAS = $aliasName
