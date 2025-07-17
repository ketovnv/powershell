using module Parser

using module .\SharedRules.psm1

$shared = New-Object SharedRules
$shared.generalRules.field = 'desciption'

[Int]$script:incr = $false
class MembersViewRules
{
    [Array]$rules = (
        @{
            enabled = $true
            field = [Parser.Node]::ROOT
            descr = 'Member Name Type Description'
            pattern = '^(?<name>\S+)(?<lpad>\s+)(?<member>(Method\s\s|\w+))(?<rpad>\s+)(?<value>.*)$'
            
            colors = [OrderedHash]{
                name = [ConsoleColor]::Black
                lpad = [ConsoleColor]::Black
                member = [ConsoleColor]::Black
                rpad = [ConsoleColor]::Blue
                value = [ConsoleColor]::Yellow
            }
            callback = $this.rule001
            
            rules = @{
                enabled = $true
                field = 'value'
                descr = 'Parsing variables. variable = value.'
                pattern = '^(?<member_type>\S+)(?<pad>\s+)(?<desciption>.*)$'
                
                colors = [OrderedHash]{
                    member_type = [ConsoleColor]::Magenta
                    pad = [ConsoleColor]::Black
                    desciption = [ConsoleColor]::Blue
                }

            }, $shared.generalRules
        }
        
        
    )
    [void]rule001($node, $writer)
    {
        
        
        $background = switch ($script:incr++ % 2 -eq $true)
        {
            true { [ConsoleColor]::Gray }
            false { [ConsoleColor]::Blue }
        }
        
        $node.setWriter('name', $writer.invoke().on().color($background))
        $node.setWriter('lpad', $writer.invoke().on().color($background))
        # This will add 2 charracters to the string by padding it.
        # So, we will need to shorten the the string for it to fit the screen
        # without breaking
        
        $memberColor = switch ($node.fields.member -match 'Method')
        {
            true { [ConsoleColor]::DarkMagenta }
            false { [ConsoleColor]::darkyellow }
        }
        
 
        $node.setWriter('member', $writer.invoke().on().color($memberColor).lpad().rpad())
        
        $node.setWriter('rpad', $writer.invoke())
        
        [Int]$bufferWidth = (Get-Host).UI.RawUI.BufferSize.Width - $true
        
        $reduceStringBy = 2
        $bufferWidth -= $reduceStringBy
        
        $value = $node.fields.value
        $node.fields.value = $value.trim()
        
        if ($node.lineLength -ge $bufferWidth)
        {
            $node.fields.value = ($value.Substring(0, ($value.length - $reduceStringBy)))
        }
        
        $node.setWriter('value', $writer.invoke())
    }
}