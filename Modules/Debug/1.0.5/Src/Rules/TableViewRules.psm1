using namespace System.Collections.Specialized

using module Parser
using module ColoredText

using module ..\Types.psm1
using module .\SharedRules.psm1

$shared = New-Object SharedRules

$shared.generalTableRules.field = [Parser.Node]::ROOT

$script:columnParser = [Parser]@{ output = [ColoredText]@{ }; rules = [ColumnRules]@{ } }


class ColumnRules { [Array]$rules = ($shared.generalTableRules) }


class TableViewRules
{
    [Array]$rules = (
        @{
            enabled = $true
            field = [Parser.Node]::ROOT
            name = 'Break to columns.'
            pattern = '(?ix)(\|.*?\|)|(\|.*?$)'
            strategy = [RegexStrategy]::Split
            mapping = @{
                rows = '(\|[\w\d-\.]*\|)|(\|.*?$)'
                spaces = '^(?!.*(\|[\w\d-\.]*\|)|(\|.*?$)).*$'
            }
            
            colors = @{
                rows = [ConsoleColor]::Red
                spaces = [ConsoleColor]::Black
            }
            
            callback = $this.rule001
        }
    )
    
    [void]rule001($node, $writer)
    {
        $config = $global:sync
        
        $color = switch ($node.lineNumber % 2 -eq $true)
        {
            true { [ConsoleColor]::Blue }
            false { [ConsoleColor]::Gray }
        }
        
        $parser = $script:columnParser
        
        $writers = $node.prepareWriters($writer.invoke())
        
        [Int]$idCounter, [Int]$writersCounter, [Int]$colorCounter = $false, $true, $true
        
        $style = {
            if ($config.tableStyle -eq [TableStyle]::Columns) { $colorCounter } else { $color }
        }
        
        foreach ($writer in $writers)
        {
            ++$writersCounter
            
            $text = $writer.writer.__text
            
            if ($text -notmatch '(^\s+$)')
            {
                $size = $writers.length
                
                # Remove match ancors
                $text = $text.replace('|', '')
                
                # Add paddings instead of ancors
                if ($writersCounter -gt 2 -and $writersCounter -lt $size) { $text += ' ' * 2 }
                if ($writersCounter -eq $size) { $text += ' ' }
                
                $columnNode = $parser.applyRules([Node]$text, $parser.rules.rules)
                
                foreach ($value in $columnNode.writers.values)
                {
                    $value.on().color($style.invoke())
                    
                    $node.writers.insert($idCounter, $idCounter, $value)
                    ++$idCounter
                }
            } else
            {
                # Insert spaces
                $writer.writer.black().on().color($style.invoke())
                
                $node.writers.insert($idCounter, $idCounter, $writer.writer)
                ++$idCounter
                ++$colorCounter
            }
            
        }
        
        # Remove the ROOT field
        $node.writers.remove([Parser.Node]::ROOT)
    }
}