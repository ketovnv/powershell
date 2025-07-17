using module Parser

using module .\SharedRules.psm1

$shared = New-Object SharedRules

$shared.generalRules.field = 'right'

class ListViewRules
{
    [Array]$rules = (
        @{
            enabled = $true
            field = [Parser.Node]::ROOT
            descr = 'Parsing Format-List the whole line.'
            pattern = '(?<line>^.*?$)'
            colors = @{
                line = [ConsoleColor]::Yellow
            }
            
            rules = @{
                enabled = $true
                field = 'line'
                descr = 'Parsing Format-List Variable : Value.'
                pattern = '((?<left>^[\S\W]+)(?<delimiter>:)(?<right>.*)$)|(?<right>^.*$)'
                colors = [OrderedHash]{
                    left = [ConsoleColor]::Magenta
                    delimiter = [ConsoleColor]::Darkgray
                    right = [ConsoleColor]::Yellow
                }
            }, $shared.generalRules
        }
    )
}