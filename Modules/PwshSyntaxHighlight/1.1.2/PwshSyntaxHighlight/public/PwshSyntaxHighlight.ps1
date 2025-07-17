$script:Themes = @{
    Github = @{
        Function = @{ R = 255; G = 123; B = 114 }
        Generic = @{ R = 199; G = 159; B = 252 }
        String = @{ R = 143; G = 185; B = 221 }
        Variable = @{ R = 255; G = 255; B = 255 }
        Identifier = @{ R = 110; G = 174; B = 231 }
        Number = @{ R = 255; G = 255; B = 255 }
        Keyword = @{ R = 255; G = 123; B = 114 }
        Default = @{ R = 200; G = 200; B = 200 }
        ForegroundRgb = @{ R = 102; G = 102; B = 102 }
        BackgroundRgb = @{ R = 35; G = 35; B = 35 }
        HighlightRgb = @{ R = 231; G = 72; B = 86 }
    }
    Matrix = @{
        Function = @{ R = 255; G = 255; B = 255 }
        Generic = @{ R = 113; G = 255; B = 96 }
        String = @{ R = 202; G = 255; B = 194 }
        Variable = @{ R = 200; G = 255; B = 200 }
        Identifier = @{ R = 131; G = 193; B = 26 }
        Number = @{ R = 255; G = 255; B = 255 }
        Keyword = @{ R = 40; G = 220; B = 20 }
        Default = @{ R = 0; G = 120; B = 0 }
        ForegroundRgb = @{ R = 102; G = 190; B = 102 }
        BackgroundRgb = @{ R = 15; G = 45; B = 15 }
        HighlightRgb = @{ R = 255; G = 221; B = 0 }
    }
}

# TODO Update this to export correct colors when implementing https://github.com/ShaunLawrie/PwshSyntaxHighlight/issues/2
function Export-ScreenshotAsHtml
{
    param(
        $Path,
        $GutterSize = 0,
        $StartLine = 0,
        $EndLine = $Host.UI.RawUI.WindowSize.Height
    )

    Begin
    {
        if(-not($IsWindows -or $null -eq $IsWindows)) {
            return
        }

        # Required by HttpUtility
        Add-Type -Assembly System.Web
        $raw = $Host.UI.RawUI
        $buffsz = $raw.BufferSize

        function BuildHtml($out, $buff, $gutterSize)
        {
            function OpenElement($out, $fore, $back, $disableSelection)
            {
                & {
                    $out.Append('<span class="')
                    if($fore) {
                        $out.Append(' F').Append($fore)
                    }
                    if($back) {
                        $out.Append(' B').Append($back)
                    }
                    if($disableSelection) {
                        $out.Append(' no-select')
                    }
                    $out.Append('">')
                } | out-null
            }

            function CloseElement($out) {
                $out.Append('</span>') | out-null
            }

            $height = $buff.GetUpperBound(0)
            $width  = $buff.GetUpperBound(1)

            $prev = $null
            $whitespaceCount = 0

            $out.Append("<pre class=`"B$($Host.UI.RawUI.BackgroundColor)`">") | out-null

            for ($y = 0; $y -lt $height; $y++)
            {
                for ($x = 0; $x -lt $width; $x++)
                {
                    $current = $buff[$y, $x]

                    if($x -lt $gutterSize -and $gutterSize -gt 0) {
                        $disableSelection = $false
                        OpenElement $out $current.ForegroundColor $current.BackgroundColor $true
                        $out.Append($current.Character.ToString()) | out-null
                        CloseElement $out
                    } else {
                        if ($current.Character -eq ' ')
                        {
                            $whitespaceCount++
                            write-debug "whitespaceCount: $whitespaceCount"
                        }
                        else
                        {
                            if ($whitespaceCount)
                            {
                                write-debug "appended $whitespaceCount spaces, whitespaceCount: 0"
                                $out.Append((new-object string ' ', $whitespaceCount)) | Out-Null
                                $whitespaceCount = 0
                            }

                            if ((-not $prev) -or
                                ($prev.ForegroundColor -ne $current.ForegroundColor) -or
                                ($prev.BackgroundColor -ne $current.BackgroundColor))
                            {
                                if ($prev) { CloseElement $out }

                                OpenElement $out $current.ForegroundColor $current.BackgroundColor $false
                            }

                            $char = [System.Web.HttpUtility]::HtmlEncode($current.Character)
                            $out.Append($char) | out-null
                            $prev = $current
                        }
                    }
                }

                $out.Append("`n") | out-null
                $whitespaceCount = 0
            }

            if($prev) { CloseElement $out }

            $out.Append('</pre>') | out-null
        }
    }

    Process
    {
        if(-not($IsWindows -or $null -eq $IsWindows)) {
            Write-Warning "Saving HTML is only supported on Windows"
            return
        }

        $topLeft = new-object System.Management.Automation.Host.Coordinates 0, $StartLine
        $bottomRight = new-object System.Management.Automation.Host.Coordinates $buffsz.Width, $EndLine
        $rect = new-object Management.Automation.Host.Rectangle $topLeft, $bottomRight
        $buff = $raw.GetBufferContents($rect)

        $out = new-object Text.StringBuilder
        BuildHtml $out $buff $GutterSize
        
        $cssOut = new-object Text.StringBuilder
        $cssOut.Append('<style>  .no-select { -webkit-user-select: none; -ms-user-select: none; user-select: none; }') | Out-Null
        [Enum]::GetValues([ConsoleColor]) | Foreach {
            $cssOut.Append("  .F$_ { color: $_; }") | Out-Null
            $cssOut.Append("  .B$_ { background-color: $_; }") | Out-Null
        }
        $cssOut.Append('</style>') | Out-Null
        
        $completeOutput = $cssOut.ToString() + $out.ToString()

        $Path = New-SavePath -Path $Path -TemplateFilename "web1" -TemplateExtension ".html"

        while($true) {
            Set-CursorVisible
            $finalDestination = Read-Host -Prompt "Enter a location to save or press enter for the default ($Path)"
            if([string]::IsNullOrEmpty($finalDestination)) {
                $finalDestination = $Path
            }

            if(Test-Path $finalDestination) {
                Write-Warning "There is already a file at '$finalDestination', try another file path to export the image to."
            } else {
                try {
                    Set-Content -Path $finalDestination -Value $completeOutput
                    break
                } catch {
                    Write-Warning "Failed to save as '$finalDestination', try another file path to export the image to."
                }
            }
        }
    }
}

function Export-Screenshot {
    param (
        [string] $Path
    )

    if(-not($IsWindows -or $null -eq $IsWindows)) {
        Write-Warning "Screenshots are only supported on Windows"
        return
    }

    if (-not ([System.Management.Automation.PSTypeName]'User32').Type) {
        Add-Type -TypeDefinition @"
            using System;
            using System.Runtime.InteropServices;

            public class User32 {
                [DllImport("user32.dll")]
                public static extern IntPtr GetForegroundWindow();

                [DllImport("user32.dll")]
                public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);

                public struct RECT {
                    public int Left;
                    public int Top;
                    public int Right;
                    public int Bottom;
                }
            }
"@
    }

    $window = [User32]::GetForegroundWindow()
    $windowRect = New-Object User32+RECT
    [User32]::GetWindowRect($window, [ref]$windowRect) | Out-Null
    
    $bounds = [Drawing.Rectangle]::FromLTRB($windowRect.Left, $windowRect.Top, $windowRect.Right, $windowRect.Bottom)

    try {
        $bmp = New-Object Drawing.Bitmap $bounds.width, $bounds.height
        $graphics = [Drawing.Graphics]::FromImage($bmp)
        $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.Size)

        $Path = New-SavePath -Path $Path

        while($true) {
            Set-CursorVisible
            $finalDestination = Read-Host -Prompt "Enter a location to save or press enter for the default ($Path)"
            if([string]::IsNullOrEmpty($finalDestination)) {
                $finalDestination = $Path
            }

            if(Test-Path $finalDestination) {
                Write-Warning "There is already a file at '$finalDestination', try another file path to export the image to."
            } else {
                try {
                    $bmp.Save($finalDestination)
                    break
                } catch {
                    Write-Warning "Failed to save as '$finalDestination', try another file path to export the image to."
                }
            }
        }
    } finally {
        $graphics.Dispose()
        $bmp.Dispose()
    }
}

function Write-Codeblock {
    <#
        .SYNOPSIS
            Writes a code block to the host.

        .DESCRIPTION
            The Write-Codeblock function outputs a code block to the host console with optional line numbers,
            syntax highlighting, and line or extent highlighting. The function also supports custom foreground
            and background colors.

        .NOTES
            Author: Shaun Lawrie
            This was originally going to be using a screenbuffer but I wanted to support really long functions that may scroll the
            terminal so this streams the lines out from top to bottom which isn't the fastest way to render but it was the most
            reliable way I found to avoid mangling the code as it was being written out.
    #>
    param (
        # The text containing the code to write to the host
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
        [string] $Text,
        # Show a gutter with line numbers
        [switch] $ShowLineNumbers,
        # Syntax highlight the code block
        [switch] $ScreenShot,
        # Capture ScreenShot of output and save to downloads
        [switch] $ClearHost,
        # Clear host before showing the code block
        [switch] $Html,
        # Generate HTML render
        [switch] $SyntaxHighlight,        
        # Extents to highlight in the code block
        [array] $HighlightExtents,
        # Lines to highlight in the code block
        [array] $HighlightLines,
        # The theme to use to render the code
        [ValidateSet("Github", "Matrix")]
        [string] $Theme = "Github"
    )

    $startLine = 0
    if($ClearHost) {
        #Clear-Host
    } else {
        $startLine = $Host.UI.RawUI.CursorPosition.Y
    }

    $ForegroundRgb = $script:Themes[$Theme].ForegroundRgb
    $BackgroundRgb = $script:Themes[$Theme].BackgroundRgb

    # Work out the width of the console minus the line-number gutter
    $gutterSize = 0
    if($ShowLineNumbers) {
        $gutterSize = $Text.Split("`n").Count.ToString().Length + 1
    }
    $codeWidth = $Host.UI.RawUI.WindowSize.Width - $gutterSize

    try {
        Set-CursorVisible $false
        
        $renderedLines = 0
        $functionLineNumber = 1
        $resetEscapeCode = "$([Char]27)[0m"
        $foregroundColorEscapeCode = "$([Char]27)[38;2;{0};{1};{2}m" -f $ForegroundRgb.R, $ForegroundRgb.G, $ForegroundRgb.B
        $backgroundColorEscapeCode = "$([Char]27)[48;2;{0};{1};{2}m" -f $BackgroundRgb.R, $BackgroundRgb.G, $BackgroundRgb.B

        # Get all code tokens
        $tokens = @()
        [System.Management.Automation.Language.Parser]::ParseInput($Text, [ref]$tokens, [ref]$null) | Out-Null
        $lineTokens = Expand-Tokens -Tokens $tokens | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Text) } | Group-Object { $_.Extent.StartLineNumber }
        $lineExtents = $HighlightExtents | Group-Object { $_.StartLineNumber }

        $functionLinesToRender = $Text.Split("`n")
        foreach($line in $functionLinesToRender) {
            $gutterText = ""
            if($ShowLineNumbers) {
                $gutterText = $functionLineNumber.ToString().PadLeft($gutterSize - 1) + " "
            }

            # Disable syntax highlighting for specifically highlighted lines
            $lineSyntax = $SyntaxHighlight
            $lineHighlight = $false
            if($HighlightLines -contains $functionLineNumber) {
                $lineSyntax = $false
                $lineHighlight = $true
            }

            # Work out the lines that will be wrapped in the terminal because they're too long and draw the background
            $lineBackground = $foregroundColorEscapeCode + $gutterText + $backgroundColorEscapeCode + (" " * $codeWidth) + $resetEscapeCode
            if($line.Length -gt $codeWidth) {
                # How many times can this line be wrapped in the code editor width available
                $wrappedLineSegments = ($line | Select-String -Pattern ".{1,$codeWidth}" -AllMatches).Matches.Value
                # Render the background line plus additional background lines without the gutter line number for each wrapped line
                $wrappedLinesBackground = (" " * $gutterSize) + $backgroundColorEscapeCode + (" " * $codeWidth) + $resetEscapeCode
                [Console]::WriteLine($lineBackground + ($wrappedLinesBackground * ($wrappedLineSegments.Count - 1)))
                # Correct terminal line position if the window scrolled
                $terminalLine = $Host.UI.RawUI.CursorPosition.Y - $wrappedLineSegments.Count
                $renderedLines += $wrappedLineSegments.Count
            } else {
                # Render the background
                [Console]::WriteLine($lineBackground)
                $terminalLine = $Host.UI.RawUI.CursorPosition.Y - 1
                $renderedLines++
            }

            # Render the tokens that are on this line
            ($lineTokens | Where-Object { $_.Name -eq $functionLineNumber }).Group | ForEach-Object {
                if($null -ne $_) {
                    Write-Token -Token $_ -TerminalLine $terminalLine -BackgroundRgb $BackgroundRgb -GutterSize $gutterSize -Highlight:$lineHighlight -Theme $Theme -SyntaxHighlight:$lineSyntax
                }
            }

            # Highlight all extents on this line that have been requested to be emphasized
            ($lineExtents | Where-Object { $_.Name -eq $functionLineNumber }).Group | Foreach-Object {
                if($null -ne $_) {
                    Write-Token -Extent $_ -TerminalLine $terminalLine -BackgroundRgb $BackgroundRgb -GutterSize $gutterSize -Highlight -Theme $Theme
                }
            }

            $functionLineNumber++
        }
    } catch {
        throw $_
    } finally {
        if ($ScreenShot) { Export-Screenshot }
        if ($Html) {
            $endLine = $Host.UI.RawUI.CursorPosition.Y
            $startLine = $endLine - $renderedLines
            Export-ScreenshotAsHtml -StartLine $startLine -EndLine $endLine -GutterSize $gutterSize
            if($renderedLines -gt $Host.UI.RawUI.BufferSize.Height - 1) {
                Write-Warning "Html will be truncated because the code block was taller than the terminal"
            }
        }
        Set-CursorVisible
    }
}
