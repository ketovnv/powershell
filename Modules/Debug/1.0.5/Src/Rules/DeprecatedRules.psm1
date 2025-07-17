class DeprecatedRules {
    $squareBraces = @{
        enabled = $true
        field = 'line'
        descr = 'Parsing square braces [{Conent}].'
        pattern = '(?x)
                           (
                             (?<lbr>^[ ]*\[)|(?<rbr>^[ ]*\])|
                             (?<lbr>^[ ]*\[)(?<text>.*?)(?<rbr>\])
                           )$'
        colors = @{
            lbr = [ConsoleColor]::DarkGreen
            text = [ConsoleColor]::DarkBlue
            rbr = [ConsoleColor]::DarkGreen
        }
    }
}