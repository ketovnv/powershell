using module Parser

using module .\SharedRules.psm1

$shared = New-Object SharedRules

$shared.generalRules.field = 'value'

class TreeViewRules
{
    $variableExtendedRules = (
        @{
            enabled = $true
            field = 'value'
            descr = "Parsing ints in variable value."
            pattern = '(?<int>^[ ]*\d+(\.\d+)*$)'
            colors = @{
                int = [ConsoleColor]::DarkGreen
            }
        },
        $shared.generalRules,
        @{
            enabled = $true
            field = 'variable'
            descr = 'Parsing specified variable name.'
            pattern = '(?<padding>^[ ]*)(?<name>.*?Name.*?$)'
            colors = @{
                padding = [ConsoleColor]::Black
                name = [ConsoleColor]::Black
            }
            callback = $this.rule001
        }
    )
    
    [void]rule001($node, $writer)
    {
        $node.setWriter('padding', $writer.invoke())
        $node.setWriter('name', $writer.invoke().on().white())
    }
    
    [Array]$rules = (
        @{
            enabled = $true
            field = [Parser.Node]::ROOT
            descr = 'Parsing variables. variable = value.'
            pattern = '(?<variable>^[ ]*[A-z1-9]*)(?<equals> =)(?<value>.*?)$'
            
            colors = [OrderedHash]{
                variable = [ConsoleColor]::Magenta
                equals = [ConsoleColor]::Darkgray
                value = [ConsoleColor]::Yellow
            }
            
            rules = $this.variableExtendedRules
        },
        @{
            enabled = $true
            field = [Parser.Node]::ROOT
            descr = 'Parsing class names. class SomeClass.'
            pattern = '(?<ctag>^[ ]*(class)[ ]*)(?<cname>(.*?)$)'
            colors = [OrderedHash]{
                ctag = [ConsoleColor]::Blue
                cname = [ConsoleColor]::Black
            }
        },
        @{
            enabled = $true
            field = [Parser.Node]::ROOT
            descr = 'Parsing curly braces {}.'
            pattern = '(?<curlybraces>^[ ]*{|^[ ]*})$'
            colors = @{
                curlybraces = [ConsoleColor]::Darkmagenta
            }
        },
        @{
            enabled = $true
            field = [Parser.Node]::ROOT
            descr = 'Parsing Missed lines.'
            pattern = '(?<value>^.*?$)'
            colors = @{
                value = [ConsoleColor]::White
            }
            rules = $shared.generalRules
        }
    )
}