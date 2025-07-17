# This file should be in utf8 encoding
# because there are some rules here that fix the PowerShell utf8 characters.

using module Parser


class SharedRules {
    
    $generalTableRules = @{
        enabled = $true
        field = $false
        name = 'splitText'
        descr = 'Parsing elemental lexemes.:)'
        pattern = '(?ix)
                   (-)|(\/)|(;)|(=)|({|})|(\d)|(\.)|(\,)|(\[|\])|(\(|\))'
        
        strategy = [RegexStrategy]::Split
        
        mapping = @{
            misc = '(-)|(\/)|;|='
            braces = '{|}'
            digit = '\d'
            dots = '\.'
            commas = '\,'
            squareBraces = '\[|\]'
            roundParentheses = '\(|\)'
            text = '(?ix)
                    ^(?!.*
                        (-)|(\/)|;|{|}|\d|\.|\,|\[|\]|\(|\)|=
                    ).*$'
        }
        
        colors = @{
            misc = [ConsoleColor]::White
            braces = [ConsoleColor]::White
            digit = [ConsoleColor]::Black
            dots = [ConsoleColor]::White
            commas = [ConsoleColor]::White
            squareBraces = [ConsoleColor]::White
            roundParentheses = [ConsoleColor]::White
            text = [ConsoleColor]::Black
        }
        callback = $this.generalTableRulesCalback
    }
    
    $generalRules = @{
        enabled = $true
        field = $false
        name = 'splitText'
        descr = 'Parsing elemental lexemes.:)'
        pattern = '(?ix)
                (void\b)|(int\b)|(\bstring\b)|(\bsystem\b)|(boolean\b)|
                (False\b)|(True\b)|
                (\bset\b)|(\bget\b)|
                (;)|({|})|(\d)|(։)|(⧹)|(\.)|(\,)|(\[|\])|(\(|\))|(=)'
        
        strategy = [RegexStrategy]::Split
        
        mapping = @{
            basic_types = '(void\b)|(int\b)|(\bstring\b)|(\bsystem\b)|(boolean\b)'
            true = '(True\b)'
            false = '(False\b)'
            misc = ';|='
            magic = '(\bset\b)|(\bget\b)'
            braces = '{|}'
            digit = '\d'
            path_fix_backslash = '⧹'
            path_fix_colon = '։'
            dots = '\.'
            commas = '\,'
            squareBraces = '\[|\]'
            roundParentheses = '\(|\)'
            text = '(?ix)
                    ^(?!.*
                        (void\b)|(int\b)|(string\b)|(system\b)|(boolean\b)|
                        False\b|True\b|
                        set\b|get\b|
                        ;|{|}|\d|։|⧹|\.|\,|\[|\]|\(|\)|=
                    ).*$'
        }
        
        colors = @{
            basic_types = [ConsoleColor]::Blue
            true = [ConsoleColor]::Green
            false = [ConsoleColor]::DarkMagenta
            misc = [ConsoleColor]::White
            magic = [ConsoleColor]::Blue
            braces = [ConsoleColor]::DarkYellow
            digit = [ConsoleColor]::DarkGreen
            text = [ConsoleColor]::Yellow
            dots = [ConsoleColor]::Gray
            commas = [ConsoleColor]::Gray
            squareBraces = [ConsoleColor]::DarkYellow
            roundParentheses = [ConsoleColor]::DarkYellow
            path_fix_backslash = [ConsoleColor]::Gray
            path_fix_colon = [ConsoleColor]::Gray
        }
        
        callback = $this.generalRulesCalback
    }
    
    [void]generalRulesCalback($node, $writer)
    {
        $writers = $node.prepareWriters($writer.invoke())
        
        foreach ($writer in $writers)
        {
            if ($writer.type -eq $node.rule.mapping.roundParentheses)
            {
                $writer.writer.on().black()
            }
            
            # Skipped
            if ($false -and $writer.type -eq $node.rule.mapping.squareBraces)
            {
                if ($writer.writer.__text -eq '[') { $writer.writer.rpad() } else { $writer.writer.lpad() }
            }
            
            if ($writer.type -eq $node.rule.mapping.path_fix_backslash)
            {
                $writer.writer.text('\')
            }
            
            if ($writer.type -eq $node.rule.mapping.path_fix_colon)
            {
                $writer.writer.text(':')
            }
        }
        $node.enqueueWriters($writers)
    }
    
    [void]generalTableRulesCalback($node, $writer)
    {
        $node.enqueueWriters($node.prepareWriters($writer.invoke()))
    }
}