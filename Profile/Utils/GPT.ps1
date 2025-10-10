#
# GPT.ps1 — Fixed version with improved colorization and gradient handling
#

$script:AI_TOOLS_ROOT = if ($PSScriptRoot) { $PSScriptRoot }
elseif ($PSCommandPath) { Split-Path -Parent $PSCommandPath }
else { (Get-Location).Path }

# Core utility functions
function Write-Section {
    param([string]$Title, [switch]$NoColor)
    $line = ("=" * 80)
    if ($NoColor) {
        Write-Output ""; Write-Output $line; Write-Output ("  " + $Title); Write-Output $line
    }
    else {
        Write-Host ""; Write-Host $line -ForegroundColor Cyan
        Write-Host ("  " + $Title) -ForegroundColor Cyan
        Write-Host $line -ForegroundColor Cyan
    }
}

function To-Hashtable {
    param([object]$Obj)
    if ($null -eq $Obj) { return $null }
    if ($Obj -is [hashtable]) { return $Obj }
    $h = @{}
    foreach ($p in $Obj.PSObject.Properties) {
        $h[$p.Name] = $p.Value
    }
    return $h
}



function Write-RGB {
    param(
        [string]$Text,
        [string]$FC,
        [switch]$NoNewline
    )
    
    if (-not $Text) { return }
    
    $color = Get-RGBColor $FC
    $output = "$color$Text`e[0m"
    
    if ($NoNewline) {
        Write-Host $output -NoNewline
    } else {
        Write-Host $output
    }
}

# Unified gradient system
function Get-GradientSteps {
    param(
        [string]$StartColor,
        [string]$EndColor,
        [int]$Steps,
        [string]$Easing = 'linear'
    )
    
    function ConvertHexToRgb($hex) {
        $hex = $hex.TrimStart('#')
        if ($hex.Length -eq 3) {
            $hex = "$($hex[0])$($hex[0])$($hex[1])$($hex[1])$($hex[2])$($hex[2])"
        }
        return @{
            R = [Convert]::ToInt32($hex.Substring(0,2), 16)
            G = [Convert]::ToInt32($hex.Substring(2,2), 16) 
            B = [Convert]::ToInt32($hex.Substring(4,2), 16)
        }
    }
    
    function EaseValue($t, $type) {
        switch ($type) {
            'smooth' { return $t * $t * (3 - 2 * $t) }
            'ease-in' { return $t * $t }
            'ease-out' { return 1 - (1 - $t) * (1 - $t) }
            default { return $t }
        }
    }
    
    $start = ConvertHexToRgb $StartColor
    $end = ConvertHexToRgb $EndColor
    $result = @()
    
    for ($i = 0; $i -lt $Steps; $i++) {
        $t = if ($Steps -gt 1) { $i / ($Steps - 1) } else { 0 }
        $t = EaseValue $t $Easing
        
        $r = [Math]::Round($start.R + ($end.R - $start.R) * $t)
        $g = [Math]::Round($start.G + ($end.G - $start.G) * $t) 
        $b = [Math]::Round($start.B + ($end.B - $start.B) * $t)
        
        $result += "#{0:X2}{1:X2}{2:X2}" -f $r, $g, $b
    }
    
    return $result
}

function Write-GradientText {
    param(
        [string]$Text,
        [string]$StartColor,
        [string]$EndColor,
        [string]$Easing = 'smooth',
        [switch]$Bold,
        [switch]$ReturnString
    )
    
    if ([string]::IsNullOrEmpty($Text)) {
        if ($ReturnString) { return '' } else { return }
    }
    
    $chars = $Text.ToCharArray()
    $colors = Get-GradientSteps -StartColor $StartColor -EndColor $EndColor -Steps $chars.Length -Easing $Easing
    
    $sb = [System.Text.StringBuilder]::new()
    
    for ($i = 0; $i -lt $chars.Length; $i++) {
        $ansi = Get-RGBColor $colors[$i]
        if ($Bold) { [void]$sb.Append("`e[1m") }
        [void]$sb.Append($ansi)
        [void]$sb.Append($chars[$i])
    }
    
    [void]$sb.Append("`e[0m")
    
    if ($ReturnString) {
        return $sb.ToString()
    } else {
        Write-Host $sb.ToString()
    }
}

# Improved config loader with better error handling
function Get-ColorizeConfig {
    param(
        [string]$ConfigPath,
        [string]$Theme = 'Nord'
    )
    
    if (-not $ConfigPath) {
        $ConfigPath = Join-Path $script:AI_TOOLS_ROOT "resources/colorize.json"
    }
    
    $defaultConfig = @{
        Theme = $Theme
        Rules = @(
            @{ name = 'Error'; hex = '#ff4d4f'; pattern = '(?i)\b(error|failed|exception|fatal)\b'; priority = 60 }
            @{ name = 'Warning'; hex = '#ffc53d'; pattern = '(?i)\b(warn|warning|risk)\b'; priority = 55 }
            @{ name = 'Success'; hex = '#4caf50'; pattern = '(?i)\b(success|passed|ok|done)\b'; priority = 50 }
            @{ name = 'Bullet'; hex = '#e6a700'; pattern = '^\s*[-•–]\s+'; priority = -10 }
        )
        Themes = @{
            Nord = @{ Red = 'Red'; Yellow = 'DarkYellow'; Green = 'Green'; Blue = 'Cyan'; Gray = 'DarkGray' }
            Default = @{ Red = 'Red'; Yellow = 'Yellow'; Green = 'Green'; Blue = 'Blue'; Gray = 'DarkGray' }
        }
        InlineRules = @()
        Md = @{
            inline = @{
                code = @{ hex = '#A1A1AA'; bold = $true }
                bold = @{ gradient = @{ from = '#FFD166'; to = '#FF7A59'; bold = $true } }
                italic = @{ hex = '#40A9FF' }
            }
        }
    }
    
    if (Test-Path $ConfigPath) {
        try {
            $json = Get-Content $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
            
            # Merge with defaults
            $config = $defaultConfig.Clone()
            if ($json.theme) { $config.Theme = $json.theme }
            if ($json.rules) { $config.Rules = @($json.rules) }
            if ($json.themes) { $config.Themes = To-Hashtable $json.themes }
            if ($json.inlineRules) { $config.InlineRules = @($json.inlineRules) }
            if ($json.Md) { $config.Md = To-Hashtable $json.Md }
            
            return $config
        }
        catch {
            Write-Warning "Failed to parse colorize config: $ConfigPath. Using defaults. $_"
        }
    }
    
    return $defaultConfig
}

# Simplified colorization engine
function Invoke-ColorLine {
    param(
        [string]$Line,
        [hashtable]$Rule,
        [Array]$InlineRules = @(),
        [hashtable]$MdConfig,
        [switch]$Debug
    )
    
    if ([string]::IsNullOrEmpty($Line)) {
        Write-Host ""
        return
    }
    
    $output = $Line
    
    # Apply markdown inline formatting first
    if ($MdConfig -and $MdConfig.inline) {
        $output = Apply-MarkdownInline -Text $output -MdConfig $MdConfig.inline
    }
    
    # Apply inline rules
    foreach ($inlineRule in $InlineRules) {
        if ($inlineRule.pattern -and $output -match $inlineRule.pattern) {
            $color = Get-RuleColor $inlineRule
            if ($color) {
                $output = $output -replace $inlineRule.pattern, "$color`$&`e[0m"
            }
        }
    }
    
    # Apply main rule styling
    if ($Rule) {
        $ruleColor = Get-RuleColor $Rule
        if ($ruleColor) {
            Write-Host "$ruleColor$output`e[0m"
            return
        }
    }
    
    Write-Host $output
}

function Get-RuleColor {
    param([hashtable]$Rule)
    
    if (-not $Rule) { return $null }
    
    # Gradient support
    if ($Rule.gradient) {
        $grad = To-Hashtable $Rule.gradient
        if ($grad.from -and $grad.to) {
            # For gradients, we'll apply to the whole text
            return $null # Handle separately
        }
    }
    
    # Hex color
    if ($Rule.hex) {
        $color = Get-RGBColor $Rule.hex
        if ($Rule.bold) { $color = "`e[1m$color" }
        return $color
    }
    
    # RGB name lookup
    if ($Rule.rgbName -and $global:RGB -and $global:RGB[$Rule.rgbName]) {
        return Get-RGBColor $global:RGB[$Rule.rgbName]
    }
    
    return $null
}

function Apply-MarkdownInline {
    param(
        [string]$Text,
        [hashtable]$MdConfig
    )
    
    if (-not $MdConfig -or -not $Text) { return $Text }
    
    $result = $Text
    
    # Code spans: `code`
    if ($MdConfig.code) {
        $color = Get-RuleColor $MdConfig.code
        if ($color) {
            $result = $result -replace '`([^`\r\n]+)`', "$color`$1`e[0m"
        }
    }
    
    # Bold: **text** or __text__
    if ($MdConfig.bold) {
        if ($MdConfig.bold.gradient) {
            # Handle gradient bold separately
            $result = $result -replace '\*\*([^*]+)\*\*', {
                param($match)
                $text = $match.Groups[1].Value
                $grad = To-Hashtable $MdConfig.bold.gradient
                Write-GradientText -Text $text -StartColor $grad.from -EndColor $grad.to -Bold:$grad.bold -ReturnString
            }
        } else {
            $color = Get-RuleColor $MdConfig.bold
            if ($color) {
                $result = $result -replace '\*\*([^*]+)\*\*', "$color`$1`e[0m"
            }
        }
    }
    
    # Italic: *text* or _text_
    if ($MdConfig.italic) {
        $color = Get-RuleColor $MdConfig.italic
        if ($color) {
            $result = $result -replace '(?<!\*)\*([^*]+)\*(?!\*)', "`e[3m$color`$1`e[0m"
            $result = $result -replace '(?<!_)_([^_]+)_(?!_)', "`e[3m$color`$1`e[0m"
        }
    }
    
    return $result
}

# Main colorizer function - simplified and more robust
function Invoke-Colorize {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$InputText,
        [object]$Config,
        [switch]$Debug
    )
    
    begin {
        if (-not $Config) {
            $Config = Get-ColorizeConfig
        }
        
        $state = @{ inCodeFence = $false }
    }
    
    process {
        if ($null -eq $InputText) { return }
        
        $lines = $InputText -split '\r?\n'
        
        foreach ($line in $lines) {
            # Handle code fences
            if ($line -match '^\s*```') {
                $state.inCodeFence = -not $state.inCodeFence
                Write-RGB -Text $line -FC '#888888'
                continue
            }
            
            if ($state.inCodeFence) {
                Write-RGB -Text $line -FC '#888888'
                continue
            }
            
            # Find best matching rule
            $bestRule = $null
            $highestPriority = -999
            
            foreach ($rule in $Config.Rules) {
                if ($rule.pattern -and $line -match $rule.pattern) {
                    $priority = if ($rule.priority) { $rule.priority } else { 0 }
                    if ($priority -gt $highestPriority) {
                        $highestPriority = $priority
                        $bestRule = To-Hashtable $rule
                    }
                }
            }
            
            # Handle gradient rules specially
            if ($bestRule -and $bestRule.gradient) {
                $grad = To-Hashtable $bestRule.gradient
                Write-GradientText -Text $line -StartColor $grad.from -EndColor $grad.to -Bold:$grad.bold
                continue
            }
            
            # Regular rule processing
            Invoke-ColorLine -Line $line -Rule $bestRule -InlineRules $Config.InlineRules -MdConfig $Config.Md -Debug:$Debug
        }
    }
}

# Main GPT function - simplified interface
function Invoke-GPT {
    [CmdletBinding()]
    param(
        [ValidateSet("review", "explain", "tests", "refactor")]
        [string]$Mode = "review",
        [string]$InputPath,
        [string]$Text,
        [string]$GptPath,
        [switch]$NoColor,
        [switch]$PassThru,
        [switch]$Colorize,
        [string]$ColorizeTheme = 'Nord',
        [string]$ColorizeConfig,
        [Parameter(ValueFromPipeline = $true)]
        [string]$PipelineText
    )
    
    begin {
        $inputBuilder = [System.Text.StringBuilder]::new()
    }
    
    process {
        if ($PipelineText) {
            [void]$inputBuilder.AppendLine($PipelineText)
        }
    }
    
    end {
        # Validate dependencies
        if (-not (Get-Command bun -ErrorAction SilentlyContinue)) {
            throw "Bun is not installed or not in PATH. Install from https://bun.sh"
        }
        
        if (-not $env:OPENAI_API_KEY) {
            throw "OPENAI_API_KEY environment variable is not set."
        }
        
        # Find gpt.ts
        $gptScript = if ($GptPath) {
            if (-not (Test-Path $GptPath)) { throw "GptPath not found: $GptPath" }
            (Resolve-Path $GptPath).Path
        } else {
            $candidate = Join-Path $script:AI_TOOLS_ROOT "gpt.ts"
            if (-not (Test-Path $candidate)) {
                throw "gpt.ts not found at: $candidate"
            }
            (Resolve-Path $candidate).Path
        }
        
        # Prepare input
        $input = $null
        $pipeInput = $inputBuilder.ToString().Trim()
        
        if ($InputPath) {
            if (-not (Test-Path $InputPath)) { throw "InputPath not found: $InputPath" }
            $input = (Resolve-Path $InputPath).Path
        }
        elseif ($Text) {
            $input = $Text
        }
        elseif ($pipeInput) {
            $input = $pipeInput
        }
        else {
            throw "No input provided. Use -InputPath, -Text, or pipe content."
        }
        
        # Build arguments
        $args = @("run", $gptScript, $Mode)
        if ($InputPath) {
            $args += $InputPath
        } else {
            $args += $input
        }
        
        Write-Section ("GPT " + $Mode.ToUpper()) -NoColor:$NoColor
        
        if ($PassThru -or $Colorize) {
            $output = & bun @args 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "GPT command failed with exit code $LASTEXITCODE"
            }
            
            if ($Colorize) {
                $config = Get-ColorizeConfig -ConfigPath $ColorizeConfig -Theme $ColorizeTheme
                $output | Invoke-Colorize -Config $config
            } else {
                $output
            }
        } else {
            & bun @args
            if ($LASTEXITCODE -ne 0) {
                throw "GPT command failed with exit code $LASTEXITCODE"
            }
        }
    }
}

# Create alias
$aliasName = "gpt"
try {
    if (Get-Alias $aliasName -ErrorAction SilentlyContinue) {
        $aliasName = "ai-gpt"  
    }
    Set-Alias -Name $aliasName -Value Invoke-GPT -Scope Global -ErrorAction SilentlyContinue
} catch {
    Write-Warning "Could not create alias '$aliasName': $_"
}

# Export-ModuleMember -Function @('Invoke-GPT', 'Get-ColorizeConfig', 'Invoke-Colorize', 'Write-GradientText', 'Write-RGB') -Alias $aliasName