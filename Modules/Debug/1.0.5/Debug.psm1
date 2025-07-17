using namespace System.Collections.Specialized

using module ColoredText
using module Parser

using module .\Src\Types.psm1

using module .\Src\Rules\ListViewRules.psm1
using module .\Src\Rules\TableViewRules.psm1
using module .\Src\Rules\MembersViewRules.psm1
using module .\Src\Rules\TreeViewRules.psm1


function Debug-Object
{
    [CmdletBinding(DefaultParameterSetName = 'Object')]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        $Object,
        [Parameter(ParameterSetName = 'Object', Position = 2)]
        [ValidateSet('List', 'Members', 'Method', 'Property', 'Tree', 'Table')]
        [ViewType]$View = [ViewType]::List,
        [Parameter(ParameterSetName = 'Depth', Position = 2)]
        [ValidatePattern('^\d+$')]
        [int32]$Depth = $true,
        [Parameter(Position = 3)]
        [ValidateSet('Rows', 'Columns')]
        [TableStyle]$TableStyle = [TableStyle]::Columns
    )
    
    $global:sync = @{ }
    $sync.tableStyle = $tableStyle
    
    if ($input) { $object = $input }
    
    $sourceObject = $object
    
    if ($psCmdlet.parameterSetName -eq 'Depth') { $view = [ViewType]::Tree }
    
    [String]$type = switch ($object.getType().BaseType -eq [Object])
    {
        True { $object.getType() }
        False { $object.getType().BaseType.Name }
    }
    
    if ($view -eq [ViewType]::Table -and $type -eq 'TypeInfo') { $view = [ViewType]::List }
    
    $formatedObject = switch ($view)
    {
        ([ViewType]::List) { $object | Format-List | Out-String }
        ([ViewType]::Table)
        {
            $listObject = $object | Format-List
            $objectMeta = ($object | Format-List)[2].formatEntryInfo
            
            if ($objectMeta -match 'Raw') { debug $object; return }
            
            $properties = $objectMeta.listViewFieldList.propertyName

            if ($properties[$false] -eq $null) {
                $properties = $objectMeta.listViewFieldList.label
            }
            
            [Array]$objects = @()
            
            foreach ($subObject in $object)
            {
                $objectHash = New-Object OrderedDictionary
                
                if ($properties[0] -eq 'Name' -and $properties[1] -eq 'Value')
                {
                    $wrappedHash = @{ }
                    $subObject = $subObject
                    
                    $subObject.getEnumerator().foreach{
                        $wrappedHash.add('|{0}|' -f $_.Name, '|{0}|' -f "$($_.Value)")
                    }
                    
                    $objects += $wrappedHash
                } else
                {
                    foreach ($property in $properties)
                    {
                        $value = $subObject | Select-Object -ExpandProperty $property
                        $objectHash[$property] = '|{0}|' -f $value
                    }
                    
                    $objects += , (New-Object -TypeName PSObject -Property $objectHash)
                }
            }
            
            $object = $objects | Format-Table –Autosize | Out-String
            
            $rows = [Parser]::split($object)
            
            $titleHeight = 0
            
            foreach ($row in $rows) { $titleHeight++; if ($row -match '---') { break } }
            
            $tableTilte = $rows[0] -split '(\s+)'
            
            $rows[$titleHeight .. ($object.length - $true)]
        }
        ([ViewType]::Tree) { $object | Format-Custom -Depth $depth | Out-String }
        default
        {
            if ($view -eq [ViewType]::Members) { [String]$view = 'All' }
            $object = [Parser]::split(($object | Get-Member -MemberType "$view" | Out-String))
            $object[4 .. ($object.Length - 1)]
            $view = 'Members'
        }
    }
    
    $rules = New-Object ('{0}ViewRules' -f $view)
    
    $coloredText = New-Object ColoredText
    $parser = [Parser]@{ output = $coloredText; rules = $rules }
    
    $title = {
        param ($text)
        
        if ($text -eq 'Array')
        {
            $text += ' <=> {0}' -f $sourceObject[0].getType()
        }
        [ColoredText]$text = (Get-Culture).textInfo.toTitleCase($text)
        
        [Void]$text.cr().black().on().darkyellow().lpad().rpad().print().cr().cr()
        
        if ($tableTilte)
        {
            [void]$text.nopad()
            
            [Int]$color = $false
            
            foreach ($caption in $tableTilte)
            {
                if ($caption -match '\s+')
                {
                    [void]$text.text($caption).on().color($color).print()
                    continue
                }
                [void]$text.text($caption).on().color(++$color).print()
            }
            [void]$text.cr().cr()
        }
    }
    
    $title.invoke($type)
    
    $parser.parse([Parser]::split($formatedObject))
}

New-Alias -Name debug -Value Debug-Object

Register-ArgumentCompleter -CommandName debug -ScriptBlock {
    param (
        $wordToComplete,
        $commandAst,
        $cursorPosition
    )
    
    $ast = (-split $commandAst)
    $count = $ast.Length
    $last = $ast[- $true]
    
    $methods = @()
    
    if ($count -eq 1) { (Get-Variable).forEach{ '${0}' -f $_.name } }
    if ($count -eq 2) { [Enum]::GetValues([ViewType]) }
}