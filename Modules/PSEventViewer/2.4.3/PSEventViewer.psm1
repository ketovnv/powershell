# Get library name, from the PSM1 file name
$LibraryName = 'PSEventViewer'
$Library = "$LibraryName.dll"
$Class = "PSEventViewer.CmdletFindEvent"

$AssemblyFolders = Get-ChildItem -Path $PSScriptRoot\Lib -Directory -ErrorAction SilentlyContinue

# Lets find which libraries we need to load
$Default = $false
$Core = $false
$Standard = $false
foreach ($A in $AssemblyFolders.Name) {
    if ($A -eq 'Default') {
        $Default = $true
    } elseif ($A -eq 'Core') {
        $Core = $true
    } elseif ($A -eq 'Standard') {
        $Standard = $true
    }
}
if ($Standard -and $Core -and $Default) {
    $FrameworkNet = 'Default'
    $Framework = 'Standard'
} elseif ($Standard -and $Core) {
    $Framework = 'Standard'
    $FrameworkNet = 'Standard'
} elseif ($Core -and $Default) {
    $Framework = 'Core'
    $FrameworkNet = 'Default'
} elseif ($Standard -and $Default) {
    $Framework = 'Standard'
    $FrameworkNet = 'Default'
} elseif ($Standard) {
    $Framework = 'Standard'
    $FrameworkNet = 'Standard'
} elseif ($Core) {
    $Framework = 'Core'
    $FrameworkNet = ''
} elseif ($Default) {
    $Framework = ''
    $FrameworkNet = 'Default'
} else {
    Write-Error -Message 'No assemblies found'
}
if ($PSEdition -eq 'Core') {
    $LibFolder = $Framework
} else {
    $LibFolder = $FrameworkNet
}

try {
    $ImportModule = Get-Command -Name Import-Module -Module Microsoft.PowerShell.Core

    if (-not ($Class -as [type])) {
        & $ImportModule ([IO.Path]::Combine($PSScriptRoot, 'Lib', $LibFolder, $Library)) -ErrorAction Stop
    } else {
        $Type = "$Class" -as [Type]
        & $importModule -Force -Assembly ($Type.Assembly)
    }
} catch {
    if ($ErrorActionPreference -eq 'Stop') {
        throw
    } else {
        Write-Warning -Message "Importing module $Library failed. Fix errors before continuing. Error: $($_.Exception.Message)"
        # we will continue, but it's not a good idea to do so
        # return
    }
}
# Dot source all libraries by loading external file
. $PSScriptRoot\PSEventViewer.Libraries.ps1

function Add-ToHashTable {
    param($Hashtable, $Key, $Value)

    <#
    .SYNOPSIS
    Adds a key-value pair to a hashtable.

    .DESCRIPTION
    This function adds a key-value pair to a given hashtable. If the value is not null or empty, it is added to the hashtable.

    .PARAMETER Hashtable
    The hashtable to which the key-value pair will be added.

    .PARAMETER Key
    The key of the key-value pair to be added.

    .PARAMETER Value
    The value of the key-value pair to be added.

    .EXAMPLE
    $myHashtable = @{}
    Add-ToHashTable -Hashtable $myHashtable -Key "Name" -Value "John"
    # Adds the key-value pair "Name"-"John" to $myHashtable.

    .EXAMPLE
    $myHashtable = @{}
    Add-ToHashTable -Hashtable $myHashtable -Key "Age" -Value 25
    # Adds the key-value pair "Age"-25 to $myHashtable.
    #>
    if ($null -ne $Value -and $Value -ne '') {
        $Hashtable.Add($Key, $Value)
    }
}
function Convert-Size { 
    <#
    .SYNOPSIS
    Converts a value from one size unit to another.

    .DESCRIPTION
    This function converts a value from one size unit (Bytes, KB, MB, GB, TB) to another size unit based on the specified conversion. It provides flexibility to handle different size units and precision of the conversion.

    .PARAMETER From
    Specifies the original size unit of the input value.

    .PARAMETER To
    Specifies the target size unit to convert the input value to.

    .PARAMETER Value
    Specifies the numerical value to be converted.

    .PARAMETER Precision
    Specifies the number of decimal places to round the converted value to. Default is 4.

    .PARAMETER Display
    Indicates whether to display the converted value with the target size unit.

    .EXAMPLE
    Convert-Size -From 'KB' -To 'MB' -Value 2048
    # Converts 2048 Kilobytes to Megabytes.

    .EXAMPLE
    Convert-Size -From 'GB' -To 'TB' -Value 2.5 -Precision 2 -Display
    # Converts 2.5 Gigabytes to Terabytes with a precision of 2 decimal places and displays the result.

    #>
    # Original - https://techibee.com/powershell/convert-from-any-to-any-bytes-kb-mb-gb-tb-using-powershell/2376
    #
    # Changelog - Modified 30.03.2018 - przemyslaw.klys at evotec.pl
    # - Added $Display Switch
    [cmdletbinding()]
    param(
        [validateset("Bytes", "KB", "MB", "GB", "TB")]
        [string]$From,
        [validateset("Bytes", "KB", "MB", "GB", "TB")]
        [string]$To,
        [Parameter(Mandatory = $true)]
        [double]$Value,
        [int]$Precision = 4,
        [switch]$Display
    )
    switch ($From) {
        "Bytes" {
            $value = $Value 
        }
        "KB" {
            $value = $Value * 1024 
        }
        "MB" {
            $value = $Value * 1024 * 1024
        }
        "GB" {
            $value = $Value * 1024 * 1024 * 1024
        }
        "TB" {
            $value = $Value * 1024 * 1024 * 1024 * 1024
        }
    }

    switch ($To) {
        "Bytes" {
            return $value
        }
        "KB" {
            $Value = $Value / 1KB
        }
        "MB" {
            $Value = $Value / 1MB
        }
        "GB" {
            $Value = $Value / 1GB
        }
        "TB" {
            $Value = $Value / 1TB
        }
    }
    if ($Display) {
        return "$([Math]::Round($value,$Precision,[MidPointRounding]::AwayFromZero)) $To"
    } else {
        return [Math]::Round($value, $Precision, [MidPointRounding]::AwayFromZero)
    }
}
function Get-WinADForestControllers { 
    <#
    .SYNOPSIS
    Retrieves information about domain controllers in the specified domain(s).

    .DESCRIPTION
    This function retrieves detailed information about domain controllers in the specified domain(s), including hostname, IP addresses, roles, and other relevant details.

    .PARAMETER TestAvailability
    Specifies whether to test the availability of domain controllers.

    .EXAMPLE
    Get-WinADForestControllers -TestAvailability
    Tests the availability of domain controllers in the forest.

    .EXAMPLE
    Get-WinADDomainControllers
    Retrieves information about all domain controllers in the forest.

    .EXAMPLE
    Get-WinADDomainControllers -Credential $Credential
    Retrieves information about all domain controllers in the forest using specified credentials.

    .EXAMPLE
    Get-WinADDomainControllers | Format-Table *
    Displays detailed information about all domain controllers in a tabular format.

    Output:
    Domain        HostName          Forest        IPV4Address     IsGlobalCatalog IsReadOnly SchemaMaster DomainNamingMasterMaster PDCEmulator RIDMaster InfrastructureMaster Comment
    ------        --------          ------        -----------     --------------- ---------- ------------ ------------------------ ----------- --------- -------------------- -------
    ad.evotec.xyz AD1.ad.evotec.xyz ad.evotec.xyz 192.168.240.189            True      False         True                     True        True      True                 True
    ad.evotec.xyz AD2.ad.evotec.xyz ad.evotec.xyz 192.168.240.192            True      False        False                    False       False     False                False
    ad.evotec.pl                    ad.evotec.xyz                                                   False                    False       False     False                False Unable to contact the server. This may be becau...

    .NOTES
    This function provides essential information about domain controllers in the forest.
    #>
    [alias('Get-WinADDomainControllers')]
    [CmdletBinding()]
    param(
        [string[]] $Domain,
        [switch] $TestAvailability,
        [switch] $SkipEmpty,
        [pscredential] $Credential
    )
    try {
        if ($Credential) {
            $Forest = Get-ADForest -Credential $Credential
        } else {
            $Forest = Get-ADForest
        }
        if (-not $Domain) {
            $Domain = $Forest.Domains
        }
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        Write-Warning "Get-WinADForestControllers - Couldn't use Get-ADForest feature. Error: $ErrorMessage"
        return
    }
    $Servers = foreach ($D in $Domain) {
        try {
            $LocalServer = Get-ADDomainController -Discover -DomainName $D -ErrorAction Stop -Writable
            if ($Credential) {
                $DC = Get-ADDomainController -Server $LocalServer.HostName[0] -Credential $Credential -Filter * -ErrorAction Stop
            } else {
                $DC = Get-ADDomainController -Server $LocalServer.HostName[0] -Filter * -ErrorAction Stop 
            }
            foreach ($S in $DC) {
                $Server = [ordered] @{
                    Domain               = $D
                    HostName             = $S.HostName
                    Name                 = $S.Name
                    Forest               = $Forest.RootDomain
                    IPV4Address          = $S.IPV4Address
                    IPV6Address          = $S.IPV6Address
                    IsGlobalCatalog      = $S.IsGlobalCatalog
                    IsReadOnly           = $S.IsReadOnly
                    Site                 = $S.Site
                    SchemaMaster         = ($S.OperationMasterRoles -contains 'SchemaMaster')
                    DomainNamingMaster   = ($S.OperationMasterRoles -contains 'DomainNamingMaster')
                    PDCEmulator          = ($S.OperationMasterRoles -contains 'PDCEmulator')
                    RIDMaster            = ($S.OperationMasterRoles -contains 'RIDMaster')
                    InfrastructureMaster = ($S.OperationMasterRoles -contains 'InfrastructureMaster')
                    LdapPort             = $S.LdapPort
                    SslPort              = $S.SslPort
                    Pingable             = $null
                    Comment              = ''
                }
                if ($TestAvailability) {
                    $Server['Pingable'] = foreach ($_ in $Server.IPV4Address) {
                        Test-Connection -Count 1 -Server $_ -Quiet -ErrorAction SilentlyContinue
                    }
                }
                [PSCustomObject] $Server
            }
        } catch {
            [PSCustomObject]@{
                Domain                   = $D
                HostName                 = ''
                Name                     = ''
                Forest                   = $Forest.RootDomain
                IPV4Address              = ''
                IPV6Address              = ''
                IsGlobalCatalog          = ''
                IsReadOnly               = ''
                Site                     = ''
                SchemaMaster             = $false
                DomainNamingMasterMaster = $false
                PDCEmulator              = $false
                RIDMaster                = $false
                InfrastructureMaster     = $false
                LdapPort                 = ''
                SslPort                  = ''
                Pingable                 = $null
                Comment                  = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            }
        }
    }
    if ($SkipEmpty) {
        return $Servers | Where-Object { $_.HostName -ne '' }
    }
    return $Servers
}
function New-Runspace { 
    <#
    .SYNOPSIS
    Creates a new runspace pool with the specified minimum and maximum runspaces.

    .DESCRIPTION
    This function creates a new runspace pool with the specified minimum and maximum runspaces. It allows for concurrent execution of PowerShell scripts.

    .PARAMETER minRunspaces
    The minimum number of runspaces to be created in the runspace pool. Default is 1.

    .PARAMETER maxRunspaces
    The maximum number of runspaces to be created in the runspace pool. Default is the number of processors plus 1.

    .EXAMPLE
    $pool = New-Runspace -minRunspaces 2 -maxRunspaces 5
    Creates a runspace pool with a minimum of 2 and a maximum of 5 runspaces.

    .EXAMPLE
    $pool = New-Runspace
    Creates a runspace pool with default minimum and maximum runspaces.

    #>
    [cmdletbinding()]
    param (
        [int] $minRunspaces = 1,
        [int] $maxRunspaces = [int]$env:NUMBER_OF_PROCESSORS + 1
    )
    $RunspacePool = [RunspaceFactory]::CreateRunspacePool($minRunspaces, $maxRunspaces)

    $RunspacePool.Open()
    return $RunspacePool
}
function Split-Array { 
    <#
    .SYNOPSIS
    Split an array into multiple arrays of a specified size or by a specified number of elements

    .DESCRIPTION
    Split an array into multiple arrays of a specified size or by a specified number of elements

    .PARAMETER Objects
    Lists of objects you would like to split into multiple arrays based on their size or number of parts to split into.

    .PARAMETER Parts
    Parameter description

    .PARAMETER Size
    Parameter description

    .EXAMPLE
    This splits array into multiple arrays of 3
    Example below wil return 1,2,3  + 4,5,6 + 7,8,9
    Split-array -Objects @(1,2,3,4,5,6,7,8,9,10) -Parts 3

    .EXAMPLE
    This splits array into 3 parts regardless of amount of elements
    Split-array -Objects @(1,2,3,4,5,6,7,8,9,10) -Size 3

    .NOTES

    #>
    [CmdletBinding()]
    param(
        [alias('InArray', 'List')][Array] $Objects,
        [int]$Parts,
        [int]$Size
    )
    if ($Objects.Count -eq 1) {
        return $Objects 
    }
    if ($Parts) {
        $PartSize = [Math]::Ceiling($inArray.count / $Parts)
    }
    if ($Size) {
        $PartSize = $Size
        $Parts = [Math]::Ceiling($Objects.count / $Size)
    }
    $outArray = [System.Collections.Generic.List[Object]]::new()
    for ($i = 1; $i -le $Parts; $i++) {
        $start = (($i - 1) * $PartSize)
        $end = (($i) * $PartSize) - 1
        if ($end -ge $Objects.count) {
            $end = $Objects.count - 1 
        }
        $outArray.Add(@($Objects[$start..$end]))
    }
    , $outArray
}
function Start-Runspace { 
    <#
    .SYNOPSIS
    Starts a new runspace with the provided script block, parameters, and runspace pool.

    .DESCRIPTION
    This function creates a new runspace using the specified script block, parameters, and runspace pool. It then starts the runspace and returns an object containing the runspace and its status.

    .PARAMETER ScriptBlock
    The script block to be executed in the new runspace.

    .PARAMETER Parameters
    The parameters to be passed to the script block.

    .PARAMETER RunspacePool
    The runspace pool in which the new runspace will be created.

    .EXAMPLE
    $scriptBlock = {
        Get-Process
    }
    $parameters = @{
        Name = 'explorer.exe'
    }
    $runspacePool = [RunspaceFactory]::CreateRunspacePool(1, 5)
    $runspacePool.Open()
    $result = Start-Runspace -ScriptBlock $scriptBlock -Parameters $parameters -RunspacePool $runspacePool
    $result.Pipe | Receive-Job -Wait

    This example starts a new runspace that retrieves information about the 'explorer.exe' process.

    #>
    [cmdletbinding()]
    param (
        [ScriptBlock] $ScriptBlock,
        [System.Collections.IDictionary] $Parameters,
        [System.Management.Automation.Runspaces.RunspacePool] $RunspacePool
    )
    if ($ScriptBlock -ne '') {
        $runspace = [PowerShell]::Create()
        $null = $runspace.AddScript($ScriptBlock)
        if ($null -ne $Parameters) {
            $null = $runspace.AddParameters($Parameters)
        }
        $runspace.RunspacePool = $RunspacePool

        [PSCustomObject]@{
            Pipe   = $runspace
            Status = $runspace.BeginInvoke()
        }
    }
}
function Start-TimeLog { 
    <#
    .SYNOPSIS
    Starts a new stopwatch for logging time.

    .DESCRIPTION
    This function starts a new stopwatch that can be used for logging time durations.

    .EXAMPLE
    Start-TimeLog
    Starts a new stopwatch for logging time.

    #>
    [CmdletBinding()]
    param()
    [System.Diagnostics.Stopwatch]::StartNew()
}
function Stop-Runspace { 
    <#
    .SYNOPSIS
    Stops and cleans up the specified runspaces.

    .DESCRIPTION
    This function stops and cleans up the specified runspaces by checking their status and handling any errors, warnings, and verbose messages. It also provides an option for extended output.

    .PARAMETER Runspaces
    Specifies the array of runspaces to stop.

    .PARAMETER FunctionName
    Specifies the name of the function associated with the runspaces.

    .PARAMETER RunspacePool
    Specifies the runspace pool to close and dispose of.

    .PARAMETER ExtendedOutput
    Indicates whether to include extended output in the result.

    .EXAMPLE
    Stop-Runspace -Runspaces $runspaceArray -FunctionName "MyFunction" -RunspacePool $pool -ExtendedOutput
    Stops the specified runspaces in the $runspaceArray associated with the function "MyFunction" using the runspace pool $pool and includes extended output.

    #>
    [cmdletbinding()]
    param(
        [Array] $Runspaces,
        [string] $FunctionName,
        [System.Management.Automation.Runspaces.RunspacePool] $RunspacePool,
        [switch] $ExtendedOutput
    )

    [Array] $List = While (@($Runspaces | Where-Object -FilterScript { $null -ne $_.Status }).count -gt 0) {
        foreach ($Runspace in $Runspaces | Where-Object { $_.Status.IsCompleted -eq $true }) {
            $Errors = foreach ($e in $($Runspace.Pipe.Streams.Error)) {
                Write-Error -ErrorRecord $e
                $e
            }
            foreach ($w in $($Runspace.Pipe.Streams.Warning)) {
                Write-Warning -Message $w
            }
            foreach ($v in $($Runspace.Pipe.Streams.Verbose)) {
                Write-Verbose -Message $v
            }
            if ($ExtendedOutput) {
                @{
                    Output = $Runspace.Pipe.EndInvoke($Runspace.Status)
                    Errors = $Errors
                }
            } else {
                $Runspace.Pipe.EndInvoke($Runspace.Status)
            }
            $Runspace.Status = $null
        }
    }
    $RunspacePool.Close()
    $RunspacePool.Dispose()
    if ($List.Count -eq 1) {
        return , $List
    } else {
        return $List
    }
}
function Stop-TimeLog { 
    <#
    .SYNOPSIS
    Stops the stopwatch and returns the elapsed time in a specified format.

    .DESCRIPTION
    The Stop-TimeLog function stops the provided stopwatch and returns the elapsed time in a specified format. The function can output the elapsed time as a single string or an array of days, hours, minutes, seconds, and milliseconds.

    .PARAMETER Time
    Specifies the stopwatch object to stop and retrieve the elapsed time from.

    .PARAMETER Option
    Specifies the format in which the elapsed time should be returned. Valid values are 'OneLiner' (default) or 'Array'.

    .PARAMETER Continue
    Indicates whether the stopwatch should continue running after retrieving the elapsed time.

    .EXAMPLE
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    # Perform some operations
    Stop-TimeLog -Time $stopwatch
    # Output: "0 days, 0 hours, 0 minutes, 5 seconds, 123 milliseconds"

    .EXAMPLE
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    # Perform some operations
    Stop-TimeLog -Time $stopwatch -Option Array
    # Output: ["0 days", "0 hours", "0 minutes", "5 seconds", "123 milliseconds"]
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)][System.Diagnostics.Stopwatch] $Time,
        [ValidateSet('OneLiner', 'Array')][string] $Option = 'OneLiner',
        [switch] $Continue
    )
    Begin {
    }
    Process {
        if ($Option -eq 'Array') {
            $TimeToExecute = "$($Time.Elapsed.Days) days", "$($Time.Elapsed.Hours) hours", "$($Time.Elapsed.Minutes) minutes", "$($Time.Elapsed.Seconds) seconds", "$($Time.Elapsed.Milliseconds) milliseconds"
        } else {
            $TimeToExecute = "$($Time.Elapsed.Days) days, $($Time.Elapsed.Hours) hours, $($Time.Elapsed.Minutes) minutes, $($Time.Elapsed.Seconds) seconds, $($Time.Elapsed.Milliseconds) milliseconds"
        }
    }
    End {
        if (-not $Continue) {
            $Time.Stop()
        }
        return $TimeToExecute
    }
}
$Script:ScriptBlock = {
    Param (
        [string]$Comp,
        [ValidateNotNull()]
        [alias('Credentials')][System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty,
        [hashtable]$EventFilter,
        [int]$MaxEvents,
        [bool] $Oldest,
        [bool] $Verbose
    )
    if ($Verbose) {
        $VerbosePreference = 'continue'
    }
    function Get-EventsFilter {
        <#
        .SYNOPSIS
        This function generates an xpath filter that can be used with the -FilterXPath
        parameter of Get-WinEvent.  It may also be used inside the <Select></Select tags
        of a Custom View in Event Viewer.
        .DESCRIPTION
        This function generates an xpath filter that can be used with the -FilterXPath
        parameter of Get-WinEvent.  It may also be used inside the <Select></Select tags
        of a Custom View in Event Viewer.

        This function allows for the create of xpath which can select events based on
        many properties of the event including those of named data nodes in the event's
        XML.

        XPath is case sensetive and the data passed to the parameters here must
        match the case of the data in the event's XML.
        .NOTES
        Original Code by https://community.spiceworks.com/scripts/show/3238-powershell-xpath-generator-for-windows-events
        Extended by Justin Grote
        Extended by Przemyslaw Klys
        .LINK

        .PARAMETER ID
        This parameter accepts and array of event ids to include in the xpath filter.
        .PARAMETER StartTime
        This parameter sets the oldest event that may be returned by the xpath.

        Please, note that the xpath time selector created here is based of of the
        time the xpath is generated.  XPath uses a time difference method to select
        events by time; that time difference being the number of milliseconds between
        the time and now.
        .PARAMETER EndTime
        This parameter sets the newest event that may be returned by the xpath.

        Please, note that the xpath time selector created here is based of of the
        time the xpath is generated.  XPath uses a time difference method to select
        events by time; that time difference being the number of milliseconds between
        the time and now.
        .PARAMETER Data
        This parameter will accept an array of values that may be found in the data
        section of the event's XML.
        .PARAMETER ProviderName
        This parameter will accept an array of values that select events from event
        providers.
        .PARAMETER Level
        This parameter will accept an array of values that specify the severity
        rating of the events to be returned.

        It accepts the following values.

        'Critical',
        'Error',
        'Informational',
        'LogAlways',
        'Verbose',
        'Warning'
        .PARAMETER Keywords
        This parameter accepts and array of long integer keywords. You must
        pass this parameter the long integer value of the keywords you want
        to search and not the keyword description.
        .PARAMETER UserID
        This parameter will accept an array of SIDs or domain accounts.
        .PARAMETER NamedDataFilter
        This parameter will accept and array of hashtables that define the key
        value pairs for which you want to filter against the event's named data
        fields.

        Key values, as with XPath filters, are case sensetive.

        You may assign an array as the value of any key. This will search
        for events where any of the values are present in that particular
        data field. If you wanted to define a filter that searches for a SubjectUserName
        of either john.doe or jane.doe, pass the following

        @{'SubjectUserName'=('john.doe','jane.doe')}

        You may specify multiple data files and values. Doing so will create
        an XPath filter that will only return results where both values
        are found. If you only wanted to return events where both the
        SubjectUserName is john.doe and the TargetUserName is jane.doe, then
        pass the following

        @{'SubjectUserName'='john.doe';'TargetUserName'='jane.doe'}

        You may pass an array of hash tables to create an 'or' XPath filter
        that will return objects where either key value set will be returned.
        If you wanted to define a filter that searches for either a
        SubjectUserName of john.doe or a TargetUserName of jane.doe then pass
        the following

        (@{'SubjectUserName'='john.doe'},@{'TargetUserName'='jane.doe'})
        .EXAMPLE
        Get-EventsFilter -ID 4663 -NamedDataFilter @{'SubjectUserName'='john.doe'} -LogName 'ForwardedEvents'

        This will return an XPath filter that will return any events with
        the id of 4663 and has a SubjectUserName of 'john.doe'

        Output:
        <QueryList>
            <Query Id="0" Path="ForwardedEvents">
                <Select Path="ForwardedEvents">
                        (*[System[EventID=4663]]) and (*[EventData[Data[@Name='SubjectUserName'] = 'john.doe']])
                </Select>
            </Query>
        </QueryList>

        .EXAMPLE
        Get-EventsFilter -StartTime '1/1/2015 01:30:00 PM' -EndTime '1/1/2015 02:00:00 PM' -LogName 'ForwardedEvents

        This will return an XPath filter that will return events that occured between 1:30
        2:00 PM on 1/1/2015.  The filter will only be good if used immediately.  XPath time
        filters are based on the number of milliseconds that have occured since the event
        and when the filter is used.  StartTime and EndTime simply calculate the number of
        milliseconds and use that for the filter.

        Output:
        <QueryList>
            <Query Id="0" Path="ForwardedEvents">
                <Select Path="ForwardedEvents">
                        (*[System[TimeCreated[timediff(@SystemTime) &lt;= 125812885399]]]) and (*[System[TimeCreated[timediff(@SystemTime)
    &gt;= 125811085399]]])
                </Select>
            </Query>
        </QueryList>

        .EXAMPLE
        Get-EventsFilter -StartTime (Get-Date).AddDays(-1) -LogName System

        This will return an XPath filter that will get events that occured within the last 24 hours.

        Output:
        <QueryList>
            <Query Id="0" Path="System">
                    <Select Path="System">
                        *[System[TimeCreated[timediff(@SystemTime) &lt;= 86404194]]]
                </Select>
            </Query>
        </QueryList>

        .EXAMPLE
        Get-EventsFilter -ID 1105 -LogName 'ForwardedEvents' -RecordID '3512231','3512232'

        This will return an XPath filter that will get events with EventRecordID 3512231 or 3512232 in Log ForwardedEvents with EventID 1105

        Output:
        <QueryList>
            <Query Id="0" Path="ForwardedEvents">
                    <Select Path="ForwardedEvents">
                        (*[System[EventID=1105]]) and (*[System[(EventRecordID=3512231) or (EventRecordID=3512232)]])
                </Select>
            </Query>
        </QueryList>
        #>

        [CmdletBinding()]
        Param
        (
            [String[]]
            $ID,

            [alias('RecordID')][string[]]
            $EventRecordID,

            [DateTime]
            $StartTime,

            [DateTime]
            $EndTime,

            [String[]]
            $Data,

            [String[]]
            $ProviderName,

            [Long[]]
            $Keywords,

            [ValidateSet(
                'Critical',
                'Error',
                'Informational',
                'LogAlways',
                'Verbose',
                'Warning'
            )]
            [String[]]
            $Level,

            [String[]]
            $UserID,

            [Hashtable[]]
            $NamedDataFilter,

            [Hashtable[]]
            $NamedDataExcludeFilter,

            [String[]]
            $ExcludeID,

            [String]
            $LogName,

            [String]
            $Path,

            [switch] $XPathOnly
        )

        #region Function definitions
        Function Join-XPathFilter {
            Param
            (
                [Parameter(
                    Mandatory = $True,
                    Position = 0
                )]
                [String]
                $NewFilter,

                [Parameter(
                    Position = 1
                )]
                [String]
                $ExistingFilter = '',

                [Parameter(
                    Position = 2
                )]
                # and and or are case sensitive
                # in xpath
                [ValidateSet(
                    "and",
                    "or",
                    IgnoreCase = $False
                )]
                [String]
                $Logic = 'and',

                [switch]$NoParenthesis
            )

            If ($ExistingFilter) {
                # If there is an existing filter add parenthesis unless noparenthesis is specified
                # and the logical operator
                if ($NoParenthesis) {
                    Return "$ExistingFilter $Logic $NewFilter"
                } Else {
                    Return "($ExistingFilter) $Logic ($NewFilter)"
                }
            } Else {
                Return $NewFilter
            }
            <#
        .SYNOPSIS
        This function handles the parenthesis and logical joining
        of XPath statements inside of Get-EventsFilter
        #>
        }

        Function Initialize-XPathFilter {
            Param
            (
                [Object[]]
                $Items,

                [String]
                $ForEachFormatString,

                [String]
                $FinalizeFormatString,

                [ValidateSet("and", "or", IgnoreCase = $False)]
                [String]
                $Logic = 'or',

                [switch]$NoParenthesis
            )

            $filter = ''

            ForEach ($item in $Items) {
                $options = @{'NewFilter' = ($ForEachFormatString -f $item)
                    'ExistingFilter'     = $filter
                    'Logic'              = $logic
                    'NoParenthesis'      = $NoParenthesis
                }
                $filter = Join-XPathFilter @options
            }

            Return $FinalizeFormatString -f $filter
            <#
        .SYNOPSIS
        This function loops thru a set of items and injecting each
        item in the format string given by ForEachFormatString, then
        combines each of those items together with 'or' logic
        using the function Join-XPathFilter, which handles the
        joining and parenthesis.  Before returning the result,
        it injects the resultant xpath into FinalizeFormatString.

        This function is a part of Get-EventsFilter
        #>
        }
        #endregion Function definitions

        [string] $filter = ''

        #region ID filter
        If ($ID) {
            $options = @{
                'Items'                = $ID
                'ForEachFormatString'  = "EventID={0}"
                'FinalizeFormatString' = "*[System[{0}]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        #endregion ID filter

        # region EventRecordID filter
        If ($EventRecordID) {
            $options = @{
                'Items'                = $EventRecordID
                'ForEachFormatString'  = "EventRecordID={0}"
                'FinalizeFormatString' = "*[System[{0}]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        #endregion EventRecordID filter

        #region Exclude ID filter
        If ($ExcludeID) {
            $options = @{
                'Items'                = $ExcludeID
                'ForEachFormatString'  = "EventID!={0}"
                'FinalizeFormatString' = "*[System[{0}]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        #endregion Exclude ID filter

        #region Date filters
        $Now = Get-Date

        # Time in XPath is filtered based on the number of milliseconds
        # between the creation of the event and when the XPath filter is
        # used.
        #
        # The timediff xpath function is used against the SystemTime
        # attribute of the TimeCreated node.

        ## Special chars needs replacement
        # <= is &lt;=
        # <  is &lt;
        # >  is &gt;
        # >= is &gt;=
        #

        If ($StartTime) {
            $Diff = [Math]::Round($Now.Subtract($StartTime).TotalMilliseconds)
            $filter = Join-XPathFilter -NewFilter "*[System[TimeCreated[timediff(@SystemTime) &lt;= $Diff]]]" -ExistingFilter $filter
        }

        If ($EndTime) {
            $Diff = [Math]::Round($Now.Subtract($EndTime).TotalMilliseconds)
            $filter = Join-XPathFilter -NewFilter "*[System[TimeCreated[timediff(@SystemTime) &gt;= $Diff]]]" -ExistingFilter $filter
        }
        #endregion Date filters

        #region Data filter
        If ($Data) {
            $options = @{
                'Items'                = $Data
                'ForEachFormatString'  = "Data='{0}'"
                'FinalizeFormatString' = "*[EventData[{0}]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        #endregion Data filter

        #region ProviderName filter
        If ($ProviderName) {
            $options = @{
                'Items'                = $ProviderName
                'ForEachFormatString'  = "@Name='{0}'"
                'FinalizeFormatString' = "*[System[Provider[{0}]]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        #endregion ProviderName filter

        #region Level filter
        If ($Level) {
            $levels = ForEach ($item in $Level) {
                # Levels in an event's XML are defined
                # with integer values.
                [Int][System.Diagnostics.Tracing.EventLevel]::$item
            }

            $options = @{
                'Items'                = $levels
                'ForEachFormatString'  = "Level={0}"
                'FinalizeFormatString' = "*[System[{0}]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        #endregion Level filter

        #region Keyword filter
        # Keywords are stored as a long integer
        # numeric value.  That integer is the
        # flagged (binary) combination of
        # all the keywords.
        #
        # By combining all given keywords
        # with a binary OR operation, and then
        # taking the resultant number and
        # comparing that against the number
        # stored in the events XML with a
        # binary AND operation will return
        # events that have any of the submitted
        # keywords assigned.
        If ($Keywords) {
            $keyword_filter = ''

            ForEach ($item in $Keywords) {
                If ($keyword_filter) {
                    $keyword_filter = $keyword_filter -bor $item
                } Else {
                    $keyword_filter = $item
                }
            }

            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter "*[System[band(Keywords,$keyword_filter)]]"
        }
        #endregion Keyword filter

        #region UserID filter
        # The UserID attribute of the Security node contains a Sid.
        If ($UserID) {
            $sids = ForEach ($item in $UserID) {
                Try {
                    #If the value submitted isn't a valid sid, it'll error.
                    $sid = [System.Security.Principal.SecurityIdentifier]($item)
                    $sid = $sid.Translate([System.Security.Principal.SecurityIdentifier])
                } Catch [System.Management.Automation.RuntimeException] {
                    # If a RuntimeException occured with an InvalidArgument category
                    # attempt to create an NTAccount object and resolve.
                    If ($Error[0].CategoryInfo.Category -eq 'InvalidArgument') {
                        Try {
                            $user = [System.Security.Principal.NTAccount]($item)
                            $sid = $user.Translate([System.Security.Principal.SecurityIdentifier])
                        } Catch {
                            #There was an error with either creating the NTAccount or
                            #Translating that object to a sid.
                            Throw $Error[0]
                        }
                    } Else {
                        #There was a RuntimeException from either creating the
                        #SecurityIdentifier object or the translation
                        #and the category was not InvalidArgument
                        Throw $Error[0]
                    }
                } Catch {
                    #There was an error from ether the creation of the SecurityIdentifier
                    #object or the Translatation
                    Throw $Error[0]
                }

                $sid.Value
            }

            $options = @{
                'Items'                = $sids
                'ForEachFormatString'  = "@UserID='{0}'"
                'FinalizeFormatString' = "*[System[Security[{0}]]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        #endregion UserID filter

        #region NamedDataFilter
        If ($NamedDataFilter) {
            $options = @{
                'Items'                = $(
                    # This will create set of datafilters for each of
                    # the hash tables submitted in the hash table array
                    ForEach ($item in $NamedDataFilter) {
                        $options = @{
                            'Items'                = $(
                                #This will result in as set of XPath subexpressions
                                #for each key submitted in the hashtable
                                ForEach ($key in $item.Keys) {
                                    If ($item[$key]) {
                                        #If there is a value for the key, create the
                                        #XPath for the Data node with that Name attribute
                                        #and value. Use 'and' logic to join the data values.
                                        #to the Name Attribute.
                                        $options = @{
                                            'Items'                = $item[$key]
                                            'NoParenthesis'        = $true
                                            'ForEachFormatString'  = "Data[@Name='$key'] = '{0}'"
                                            'FinalizeFormatString' = "{0}"
                                        }
                                        Initialize-XPathFilter @options
                                    } Else {
                                        #If there isn't a value for the key, create
                                        #XPath for the existence of the Data node with
                                        #that paritcular Name attribute.
                                        "Data[@Name='$key']"
                                    }
                                }
                            )
                            'ForEachFormatString'  = "{0}"
                            'FinalizeFormatString' = "{0}"
                        }
                        Initialize-XPathFilter @options
                    }
                )
                'ForEachFormatString'  = "{0}"
                'FinalizeFormatString' = "*[EventData[{0}]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        #endregion NamedDataFilter

        #region NamedDataExcludeFilter
        If ($NamedDataExcludeFilter) {
            $options = @{
                'Items'                = $(
                    # This will create set of datafilters for each of
                    # the hash tables submitted in the hash table array
                    ForEach ($item in $NamedDataExcludeFilter) {
                        $options = @{
                            'Items'                = $(
                                #This will result in as set of XPath subexpressions
                                #for each key submitted in the hashtable
                                ForEach ($key in $item.Keys) {
                                    If ($item[$key]) {
                                        #If there is a value for the key, create the
                                        #XPath for the Data node with that Name attribute
                                        #and value. Use 'and' logic to join the data values.
                                        #to the Name Attribute.
                                        $options = @{
                                            'Items'                = $item[$key]
                                            'NoParenthesis'        = $true
                                            'ForEachFormatString'  = "Data[@Name='$key'] != '{0}'"
                                            'FinalizeFormatString' = "{0}"
                                            'Logic'                = 'and'
                                        }
                                        Initialize-XPathFilter @options
                                    } Else {
                                        #If there isn't a value for the key, create
                                        #XPath for the existence of the Data node with
                                        #that paritcular Name attribute.
                                        "Data[@Name='$key']"
                                    }
                                }
                            )
                            'ForEachFormatString'  = "{0}"
                            'FinalizeFormatString' = "{0}"
                        }
                        Initialize-XPathFilter @options
                    }
                )
                'ForEachFormatString'  = "{0}"
                'FinalizeFormatString' = "*[EventData[{0}]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        #endregion NamedDataExcludeFilter

        if ($XPathOnly) {
            return $Filter
        } else {
            if ($Path -ne '') {
                $FilterXML = @"
                    <QueryList>
                        <Query Id="0" Path="file://$Path">
                            <Select>
                                    $filter
                            </Select>
                        </Query>
                    </QueryList>
"@
            } else {
                $FilterXML = @"
                    <QueryList>
                        <Query Id="0" Path="$LogName">
                            <Select Path="$LogName">
                                    $filter
                            </Select>
                        </Query>
                    </QueryList>
"@
            }
            return $FilterXML
        }
    } # Function Get-EventsFilter
    function Get-EventsInternal () {
        [CmdLetBinding()]
        param (
            [string]$Comp,
            [ValidateNotNull()]
            [alias('Credentials')][System.Management.Automation.PSCredential]
            [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty,
            [hashtable]$EventFilter,
            [int]$MaxEvents,
            [switch] $Oldest
        )
        $Measure = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start

        Write-Verbose "Get-Events - Inside $Comp for Events ID: $($EventFilter.ID)"
        Write-Verbose "Get-Events - Inside $Comp for Events LogName: $($EventFilter.LogName)"
        Write-Verbose "Get-Events - Inside $Comp for Events RecordID: $($EventFilter.RecordID)"
        Write-Verbose "Get-Events - Inside $Comp for Events Oldest: $Oldest"
        try {
            [Array] $Events = @(
                if ($null -ne $EventFilter.RecordID -or `
                        $null -ne $EventFilter.NamedDataFilter -or `
                        $null -ne $EventFilter.ExcludeID -or `
                        $null -ne $EventFilter.NamedDataExcludeFilter -or `
                        $null -ne $EventFilter.UserID
                ) {
                    $FilterXML = Get-EventsFilter @EventFilter
                    $SplatEvents = @{
                        ErrorAction  = 'Stop'
                        ComputerName = $Comp
                        Oldest       = $Oldest
                        FilterXml    = $FilterXML
                    }
                    Write-Verbose "Get-Events - Inside $Comp - Custom FilterXML: `n$FilterXML"
                } else {
                    $SplatEvents = @{
                        ErrorAction     = 'Stop'
                        ComputerName    = $Comp
                        Oldest          = $Oldest
                        FilterHashtable = $EventFilter
                    }
                    foreach ($k in $EventFilter.Keys) {
                        Write-Verbose "Get-Events - Inside $Comp Data in FilterHashTable $k $($EventFilter[$k])"
                    }
                }
                if ($MaxEvents -ne 0) {
                    $SplatEvents.MaxEvents = $MaxEvents
                    Write-Verbose "Get-Events - Inside $Comp for Events Max Events: $MaxEvents"
                }
                if ($Credential -ne [System.Management.Automation.PSCredential]::Empty) {
                    $SplatEvents.Credential = $Credential
                    Write-Verbose "Get-Events - Inside $Comp for Events Credential: $Credential"
                }
                Get-WinEvent @SplatEvents
            )
            #$EventsCount = ($Events | Measure-Object).Count
            Write-Verbose -Message "Get-Events - Inside $Comp Events found $($Events.Count)"
        } catch {
            if ($_.Exception -match "No events were found that match the specified selection criteria") {
                Write-Verbose -Message "Get-Events - Inside $Comp No events found."
            } elseif ($_.Exception -match "There are no more endpoints available from the endpoint") {
                Write-Verbose -Message "Get-Events - Inside $Comp Error $($_.Exception.Message)"
                Write-Error -Message "$Comp`: $_"
            } else {
                Write-Verbose -Message "Get-Events - Inside $Comp Error $($_.Exception.Message)"
                Write-Error -Message "$Comp`: $_"
            }
            Write-Verbose "Get-Events - Inside $Comp Time to generate $($Measure.Elapsed.Hours) hours, $($Measure.Elapsed.Minutes) minutes, $($Measure.Elapsed.Seconds) seconds, $($Measure.Elapsed.Milliseconds) milliseconds"
            $Measure.Stop()
            return
        }
        Write-Verbose "Get-Events - Inside $Comp Processing events..."

        # Parse out the event message data
        ForEach ($Event in $Events) {
            # Convert the event to XML
            $eventXML = [xml]$Event.ToXml()
            # Iterate through each one of the XML message properties
            #Add-Member -InputObject $Event -MemberType NoteProperty -Name "Computer" -Value $event.MachineName.ToString() -Force
            #Add-Member -InputObject $Event -MemberType NoteProperty -Name "Date" -Value $Event.TimeCreated -Force
            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('Computer', $event.MachineName.ToString()))
            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('Date', $Event.TimeCreated))

            #$EventTopNodes = Get-Member -InputObject $eventXML.Event -MemberType Properties | Where-Object { $_.Name -ne 'System' -and $_.Name -ne 'xmlns' }
            $EventTopNodes = $eventXML.Event.PSAdapted.PSObject.Properties.Name #| Where-Object { $_ -ne 'System' -and $_ -ne 'xmlns' }

            [Array] $EventTopNodes = foreach ($Entry in $EventTopNodes) {
                if ($Entry -ne 'System' -and $Entry -ne 'xmlns' ) {
                    $Entry
                }
            }
            foreach ($TopNode in $EventTopNodes) {
                #$TopNode = $EventTopNode.Name

                #$EventSubsSubs = Get-Member -InputObject $eventXML.Event.$TopNode -MemberType Properties
                $EventSubsSubs = $eventXML.Event.$TopNode.PSAdapted.PSObject.Properties
                $h = 0
                foreach ($EventSubSub in $EventSubsSubs) {
                    $SubNode = $EventSubSub.Name
                    #$EventSubSub | ft -a
                    if ($EventSubSub.TypeNameOfValue -like "System.Object*") {
                        #if (Get-Member -InputObject $eventXML.Event.$TopNode -Name "$SubNode" -MemberType Properties) {
                        if ($eventXML.Event.$TopNode.$SubNode) {
                            # Case 1
                            #$SubSubNode = Get-Member -InputObject $eventXML.Event.$TopNode.$SubNode -MemberType Properties | Where-Object { $_.Name -ne 'xmlns' -and $_.Definition -like "string*" }
                            $SubSubNode = $eventXML.Event.$TopNode.$SubNode.PSAdapted.PSObject.Properties #| Where-Object { $_.Name -ne 'xmlns' -and $_.TypeNameOfValue -like "string*" }
                            [Array] $SubSubNode = foreach ($Entry in $SubSubNode) {
                                if ($Entry.Name -ne 'xmls' -and $_.TypeNameOfValue -like "string*") {
                                    $Entry
                                }
                            }
                            foreach ($Name in $SubSubNode.Name) {
                                $fieldName = $Name
                                $fieldValue = $eventXML.Event.$TopNode.$SubNode.$Name
                                #Add-Member -InputObject $Event -MemberType NoteProperty -Name $fieldName -Value $fieldValue -Force
                                $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new($fieldName, $fieldValue))
                            }
                            # Case 1

                            For ($i = 0; $i -lt $eventXML.Event.$TopNode.$SubNode.Count; $i++) {
                                #if (Get-Member -InputObject $eventXML.Event.$TopNode.$SubNode[$i] -Name "Name" -MemberType Properties) {
                                if ($eventXML.Event.$TopNode.$SubNode[$i].Name) {
                                    # Case 2
                                    $fieldName = $eventXML.Event.$TopNode.$SubNode[$i].Name
                                    #if (Get-Member -InputObject $eventXML.Event.$TopNode.$SubNode[$i] -Name "#text" -MemberType Properties) {
                                    if ($eventXML.Event.$TopNode.$SubNode[$i]."#text") {
                                        $fieldValue = $eventXML.Event.$TopNode.$SubNode[$i]."#text"
                                        if ($fieldValue -eq "-".Trim()) {
                                            $fieldValue = $fieldValue -replace "-" 
                                        }
                                    } else {
                                        $fieldValue = ""
                                    }
                                    if ($fieldName -ne "") {
                                        #Add-Member -InputObject $Event -MemberType NoteProperty -Name $fieldName -Value $fieldValue -Force
                                        $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new($fieldName, $fieldValue))
                                    }
                                    # Case 2
                                } else {
                                    # Case 3
                                    $Value = $eventXML.Event.$TopNode.$SubNode[$i]
                                    if ($Value.Name -ne 'Name' -and $Value.Name -ne '#text') {
                                        $fieldName = "NoNameA$i"
                                        $fieldValue = $Value
                                        # Add-Member -InputObject $Event -MemberType NoteProperty -Name $fieldName -Value $fieldValue -Force
                                        $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new($fieldName, $fieldValue))
                                    }
                                    # Case 3
                                }
                            }
                        }
                    } elseif ($EventSubSub.TypeNameOfValue -like "System.Xml.XmlElement*") {
                        # Case 1
                        #$SubSubNode = Get-Member -InputObject $eventXML.Event.$TopNode.$SubNode -MemberType Properties | Where-Object { $_.Name -ne 'xmlns' -and $_.Definition -like "string*" }
                        $SubSubNode = $eventXML.Event.$TopNode.$SubNode.PSAdapted.PSObject.Properties #| Where-Object { $_.Name -ne 'xmlns' -and $_.TypeNameOfValue -like "string*" }
                        [Array] $SubSubNode = foreach ($Entry in $SubSubNode) {
                            if ($Entry.Name -ne 'xmls' -and $_.TypeNameOfValue -like "string*") {
                                $Entry
                            }
                        }
                        foreach ($Name in $SubSubNode.Name) {
                            $fieldName = $Name
                            $fieldValue = $eventXML.Event.$TopNode.$SubNode.$Name
                            # Add-Member -InputObject $Event -MemberType NoteProperty -Name $fieldName -Value $fieldValue -Force
                            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new($fieldName, $fieldValue))
                        }
                        # Case 1
                    } else {
                        # Case 4 - Where Data has no Names
                        $fieldValue = $eventXML.Event.$TopNode.$SubNode
                        if ($fieldValue -match "\n") {
                            # this is case with ADConnect - event id 6946 where 1 Value has multiple values line per line
                            $SplittedValues = $fieldValue -split '\n'
                            foreach ($Split in $SplittedValues) {
                                $h++
                                $fieldName = "NoNameB$h"
                                #Add-Member -InputObject $Event -MemberType NoteProperty -Name $fieldName -Value $Split -Force
                                $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new($fieldName, $Split))
                            }
                        } else {
                            $h++
                            $fieldName = "NoNameB$h"
                            #Add-Member -InputObject $Event -MemberType NoteProperty -Name $fieldName -Value $fieldValue -Force
                            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new($fieldName, $fieldValue))
                        }
                        # Case 4
                    }
                }
            }
            # This adds some fields specific to PSWinReporting
            [string] $MessageSubject = ($Event.Message -split '\n')[0] -replace "`n", '' -replace "`r", '' -replace "`t", ''
            #Add-Member -InputObject $Event -MemberType NoteProperty -Name 'MessageSubject' -Value $MessageSubject -Force
            #Add-Member -InputObject $Event -MemberType NoteProperty -Name 'Action' -Value $MessageSubject -Force
            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('MessageSubject', $MessageSubject))
            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('Action', $MessageSubject))

            # Level value is not needed because there is actually LevelDisplayName
            #Add-Member -InputObject $Event -MemberType NoteProperty -Name 'LevelTranslated' -Value ([EventViewerX.Level] $Event.Level)

            # Overwrite value - the old value is collection
            # Add-Member -InputObject $Event -MemberType NoteProperty -Name 'KeywordDisplayName' -Value ($Event.KeywordsDisplayNames -join ',') -Force
            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('KeywordDisplayName', ($Event.KeywordsDisplayNames -join ',')))

            if ($Event.SubjectDomainName -and $Event.SubjectUserName) {
                #Add-Member -InputObject $Event -MemberType NoteProperty -Name 'Who' -Value "$($Event.SubjectDomainName)\$($Event.SubjectUserName)" -Force
                $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('Who', "$($Event.SubjectDomainName)\$($Event.SubjectUserName)" ))
            } elseif ($Event.SubjectUserName) {
                $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('Who', "$($Event.SubjectUserName)"))
            }
            if ($Event.TargetDomainName -and $Event.TargetUserName) {
                #Add-Member -InputObject $Event -MemberType NoteProperty -Name 'ObjectAffected' -Value "$($Event.TargetDomainName)\$($Event.TargetUserName)" -Force
                $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('ObjectAffected', "$($Event.TargetDomainName)\$($Event.TargetUserName)"))
            } elseif ($Event.TargetUserName) {
                # Add-Member -InputObject $Event -MemberType NoteProperty -Name 'ObjectAffected' -Value "$($Event.TargetUserName)" -Force
                $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('ObjectAffected', "$($Event.TargetUserName)"))
            }
            if ($Event.MemberName) {
                [string] $MemberNameWithoutCN = $Event.MemberName -replace 'CN=|\\|,(OU|DC|CN).*$'
                #Add-Member -InputObject $Event -MemberType NoteProperty -Name 'MemberNameWithoutCN' -Value $MemberNameWithoutCN -Force
                $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('MemberNameWithoutCN', $MemberNameWithoutCN))
            }
            if ($EventFilter.Path) {
                #Add-Member -InputObject $Event -MemberType NoteProperty -Name "GatheredFrom" -Value $EventFilter.Path -Force
                $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('GatheredFrom', $EventFilter.Path))
            } else {
                #Add-Member -InputObject $Event -MemberType NoteProperty -Name "GatheredFrom" -Value $Comp -Force
                $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('GatheredFrom', $Comp))
            }
            #Add-Member -InputObject $Event -MemberType NoteProperty -Name "GatheredLogName" -Value $EventFilter.LogName -Force
            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('GatheredLogName', $EventFilter.LogName))
        }
        Write-Verbose "Get-Events - Inside $Comp Time to generate $($Measure.Elapsed.Hours) hours, $($Measure.Elapsed.Minutes) minutes, $($Measure.Elapsed.Seconds) seconds, $($Measure.Elapsed.Milliseconds) milliseconds"
        $Measure.Stop()
        return $Events
    }
    Write-Verbose "Get-Events -------------START---------------------"
    [Array] $Data = Get-EventsInternal -Comp $Comp -EventFilter $EventFilter -MaxEvents $MaxEvents -Oldest:$Oldest -Verbose:$Verbose -Credential $Credential
    Write-Verbose "Get-Events --------------END----------------------"
    return $Data
}
$Script:ScriptBlockEventsInformation = {
    Param (
        [string]$Computer,
        [string]$Path,
        [string]$LogName,
        [bool] $Verbose
    )
    if ($Verbose) {
        $VerbosePreference = 'continue'
    }
    function Convert-Size {
        # Original - https://techibee.com/powershell/convert-from-any-to-any-bytes-kb-mb-gb-tb-using-powershell/2376
        #
        # Changelog - Modified 30.03.2018 - przemyslaw.klys at evotec.pl
        # - Added $Display Switch
        [cmdletbinding()]
        param(
            [validateset("Bytes", "KB", "MB", "GB", "TB")]
            [string]$From,
            [validateset("Bytes", "KB", "MB", "GB", "TB")]
            [string]$To,
            [Parameter(Mandatory = $true)]
            [double]$Value,
            [int]$Precision = 4,
            [switch]$Display
        )
        switch ($From) {
            "Bytes" {
                $value = $Value 
            }
            "KB" {
                $value = $Value * 1024 
            }
            "MB" {
                $value = $Value * 1024 * 1024 
            }
            "GB" {
                $value = $Value * 1024 * 1024 * 1024 
            }
            "TB" {
                $value = $Value * 1024 * 1024 * 1024 * 1024 
            }
        }

        switch ($To) {
            "Bytes" {
                return $value 
            }
            "KB" {
                $Value = $Value / 1KB 
            }
            "MB" {
                $Value = $Value / 1MB 
            }
            "GB" {
                $Value = $Value / 1GB 
            }
            "TB" {
                $Value = $Value / 1TB 
            }
        }
        if ($Display) {
            return "$([Math]::Round($value,$Precision,[MidPointRounding]::AwayFromZero)) $To"
        } else {
            return [Math]::Round($value, $Precision, [MidPointRounding]::AwayFromZero)
        }
    }

    try {
        if ($Computer -eq '') {

            $FileInformation = Get-ChildItem -File $Path
            $EventsOldest = Get-WinEvent -MaxEvents 1 -Oldest -Path $Path -Verbose:$false
            $EventsNewest = Get-WinEvent -MaxEvents 1 -Path $Path -Verbose:$false

            $RecordCount = $EventsNewest.RecordID - $EventsOldest.RecordID

            $EventsInfo = [PSCustomObject]@{
                EventNewest                        = $EventsNewest.TimeCreated
                EventOldest                        = $EventsOldest.TimeCreated
                FileSize                           = $FileInformation.Length
                FileSizeMaximum                    = $null
                FileSizeCurrentMB                  = Convert-Size -Value $FileInformation.Length -From Bytes -To MB -Precision 2 #-Display
                FileSizeMaximumMB                  = Convert-Size -Value $FileInformation.Length -From Bytes -To MB -Precision 2 #-Display
                IsClassicLog                       = $false
                IsEnabled                          = $false
                IsLogFull                          = $false
                LastAccessTime                     = $FileInformation.LastAccessTime
                LastWriteTime                      = $FileInformation.LastWriteTime
                LogFilePath                        = $Path
                LogIsolation                       = $false
                LogMode                            = 'N/A'
                LogName                            = 'N/A'
                LogType                            = 'N/A'
                MaximumSizeInBytes                 = $FileInformation.Length
                MachineName                        = (@($EventsOldest.MachineName) + @($EventsNewest.MachineName) | Sort-Object -Unique) -join ', '
                OldestRecordNumber                 = $EventsOldest.RecordID
                OwningProviderName                 = ''
                ProviderBufferSize                 = 0
                ProviderControlGuid                = ''
                ProviderKeywords                   = ''
                ProviderLatency                    = 1000
                ProviderLevel                      = ''
                ProviderMaximumNumberOfBuffers     = 16
                ProviderMinimumNumberOfBuffers     = 0
                ProviderNames                      = ''
                ProviderNamesExpanded              = ''
                RecordCount                        = $RecordCount
                SecurityDescriptor                 = $null
                SecurityDescriptorOwner            = $null
                SecurityDescriptorGroup            = $null
                SecurityDescriptorDiscretionaryAcl = $null
                SecurityDescriptorSystemAcl        = $null
                Source                             = 'File'
            }
        } else {
            $EventsInfo = Get-WinEvent -ListLog $LogName -ComputerName $Computer

            $FileSizeCurrentMB = Convert-Size -Value $EventsInfo.FileSize -From Bytes -To MB -Precision 2 #-Display
            $FileSizeMaximumMB = Convert-Size -Value $EventsInfo.MaximumSizeInBytes -From Bytes -To MB -Precision 2 #-Display
            $EventOldest = (Get-WinEvent -MaxEvents 1 -LogName $LogName -Oldest -ComputerName $Computer).TimeCreated
            $EventNewest = (Get-WinEvent -MaxEvents 1 -LogName $LogName -ComputerName $Computer).TimeCreated
            $ProviderNamesExpanded = $EventsInfo.ProviderNames -join ', '

            $SecurityDescriptorTranslated = ConvertFrom-SddlString -Sddl $EventsInfo.SecurityDescriptor

            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name "FileSizeCurrentMB" -Value $FileSizeCurrentMB -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name "FileSizeMaximumMB" -Value $FileSizeMaximumMB -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name "EventOldest" -Value $EventOldest -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name "EventNewest" -Value $EventNewest -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name "ProviderNamesExpanded" -Value $ProviderNamesExpanded -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name "MachineName" -Value $Computer -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name "Source" -Value $Computer -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name 'SecurityDescriptorOwner' -Value $SecurityDescriptorTranslated.Owner -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name 'SecurityDescriptorGroup' -Value $SecurityDescriptorTranslated.Group -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name 'SecurityDescriptorDiscretionaryAcl' -Value $SecurityDescriptorTranslated.DiscretionaryAcl -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name 'SecurityDescriptorSystemAcl' -Value $SecurityDescriptorTranslated.SystemACL -Force
        }
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        switch ($ErrorMessage) {
            { $_ -match 'No events were found' } {
                Write-Verbose -Message "$Computer Reading Event Log ($LogName) size failed. No events found."
            }
            { $_ -match 'Attempted to perform an unauthorized operation' } {
                Write-Verbose -Message "$Computer Reading Event Log ($LogName) size failed. Unauthorized operation."
                Write-Error -Message "$Computer`: $_"
            }
            default {
                Write-Verbose -Message "$Computer Reading Event Log ($LogName) size failed. Error occured: $ErrorMessage"
                Write-Error -Message "$Computer`: $_"
            }
        }
    }
    $Properties = $EventsInfo.PSObject.Properties.Name | Sort-Object
    $EventsInfo | Select-Object $Properties
}
function Get-Events {
    <#
    .SYNOPSIS
    Get-Events is a wrapper function around Get-WinEvent providing additional features and options.

    .DESCRIPTION
    Get-Events is a wrapper function around Get-WinEvent providing additional features and options exposing most of the Get-WinEvent functionality in easy to use manner.

    .PARAMETER Machine
    Specifies the name of the computer that this cmdlet gets events from the event logs. Type the NetBIOS name, an IP address, or the fully qualified domain name (FQDN) of the computer. The default value is the local computer, localhost. This parameter accepts only one computer name at a time.

    To get event logs from remote computers, configure the firewall port for the event log service to allow remote access.

    This cmdlet does not rely on PowerShell remoting. You can use the ComputerName parameter even if your computer is not configured to run remote commands.

    .PARAMETER DateFrom
    Specifies the date and time of the earliest event in the event log you want to search for.

    .PARAMETER DateTo
    Specifies the date and time of the latest event in the event log you want to search for.

    .PARAMETER ID
    Specifies the event ID (or events) of the event you want to search for. If provided more than 23 the cmdlet will split the events into multiple queries automatically.

    .PARAMETER ExcludeID
    Specifies the event ID (or events) of the event you want to exclude from the search. If provided more than 23 the cmdlet will split the events into multiple queries automatically.

    .PARAMETER LogName
    Specifies the event logs that this cmdlet get events from. Enter the event log names in a comma-separated list. Wildcards are permitted.

    .PARAMETER ProviderName
    Specifies, as a string array, the event log providers from which this cmdlet gets events. Enter the provider names in a comma-separated list, or use wildcard characters to create provider name patterns.

    An event log provider is a program or service that writes events to the event log. It is not a PowerShell provider.

    .PARAMETER NamedDataFilter
    Provide NamedDataFilter in specific form to optimize search performance looking for specific events.

    .PARAMETER NamedDataExcludeFilter
    Provide NamedDataExcludeFilter in specific form to optimize search performance looking for specific events.

    .PARAMETER UserID
    The UserID key can take a valid security identifier (SID) or a domain account name that can be used to construct a valid System.Security.Principal.NTAccount object.

    .PARAMETER Level
    Define the event level that this cmdlet gets events from. Options are Verbose, Informational, Warning, Error, Critical, LogAlways

    .PARAMETER UserSID
    Search events by UserSID

    .PARAMETER Data
    The Data value takes event data in an unnamed field. For example, events in classic event logs.

    .PARAMETER MaxEvents
    Specifies the maximum number of events that are returned. Enter an integer such as 100. The default is to return all the events in the logs or files.

    .PARAMETER Credential
    Specifies the name of the computer that this cmdlet gets events from the event logs. Type the NetBIOS name, an IP address, or the fully qualified domain name (FQDN) of the computer. The default value is the local computer, localhost. This parameter accepts only one computer name at a time.

    To get event logs from remote computers, configure the firewall port for the event log service to allow remote access.

    This cmdlet does not rely on PowerShell remoting. You can use the ComputerName parameter even if your computer is not configured to run remote commands.

    .PARAMETER Path
    Specifies the path to the event log files that this cmdlet get events from. Enter the paths to the log files in a comma-separated list, or use wildcard characters to create file path patterns.

    .PARAMETER Keywords
    Define keywords to search for by their name. Available keywords are: AuditFailure, AuditSuccess, CorrelationHint2, EventLogClassic, Sqm, WdiDiagnostic, WdiContext, ResponseTime, None

    .PARAMETER RecordID
    Find a single event in the event log using it's RecordId

    .PARAMETER MaxRunspaces
    Limit the number of concurrent runspaces that can be used to process the events. By default it uses $env:NUMBER_OF_PROCESSORS + 1

    .PARAMETER Oldest
    Indicate that this cmdlet gets the events in oldest-first order. By default, events are returned in newest-first order.

    .PARAMETER DisableParallel
    Disables parallel processing of the events. By default, events are processed in parallel.

    .PARAMETER ExtendedOutput
    Indicates that this cmdlet returns an extended set of output parameters. By default, this cmdlet does not generate any extended output.

    .PARAMETER ExtendedInput
    Indicates that this cmdlet takes an extended set of input parameters. Extended input is used by PSWinReportingV2 to provide special input parameters.

    .EXAMPLE
    Get-Events -LogName 'Application' -ID 1001 -MaxEvents 1 -Verbose -DisableParallel

    .EXAMPLE
    Get-Events -LogName 'Setup' -ID 2 -ComputerName 'AD1' -MaxEvents 1 -Verbose | Format-List *

    .EXAMPLE
    Get-Events -LogName 'Setup' -ID 2 -ComputerName 'AD1','AD2','AD3' -MaxEvents 1 -Verbose | Format-List *

    .EXAMPLE
    Get-Events -LogName 'Security' -ID 5379 -RecordID 19626 -Verbose

    .EXAMPLE
    Get-Events -LogName 'System' -ID 1001,1018 -ProviderName 'Microsoft-Windows-WER-SystemErrorReporting' -Verbose
    Get-Events -LogName 'System' -ID 42,41,109 -ProviderName 'Microsoft-Windows-Kernel-Power' -Verbose
    Get-Events -LogName 'System' -ID 1,12,13 -ProviderName 'Microsoft-Windows-Kernel-General' -Verbose
    Get-Events -LogName 'System' -ID 6005,6006,6008,6013 -ProviderName 'EventLog' -Verbose

    .EXAMPLE
    $List = @(
        @{ Server = 'AD1'; LogName = 'Security'; EventID = '5136', '5137'; Type = 'Computer' }
        @{ Server = 'AD2'; LogName = 'Security'; EventID = '5136', '5137'; Type = 'Computer' }
        @{ Server = 'C:\MyEvents\Archive-Security-2018-08-21-23-49-19-424.evtx'; LogName = 'Security'; EventID = '5136', '5137'; Type = 'File' }
        @{ Server = 'C:\MyEvents\Archive-Security-2018-09-15-09-27-52-679.evtx'; LogName = 'Security'; EventID = '5136', '5137'; Type = 'File' }
        @{ Server = 'Evo1'; LogName = 'Setup'; EventID = 2; Type = 'Computer'; }
        @{ Server = 'AD1.ad.evotec.xyz'; LogName = 'Security'; EventID = 4720, 4738, 5136, 5137, 5141, 4722, 4725, 4767, 4723, 4724, 4726, 4728, 4729, 4732, 4733, 4746, 4747, 4751, 4752, 4756, 4757, 4761, 4762, 4785, 4786, 4787, 4788, 5136, 5137, 5141, 5136, 5137, 5141, 5136, 5137, 5141; Type = 'Computer' }
        @{ Server = 'Evo1'; LogName = 'Security'; Type = 'Computer'; MaxEvents = 15; Keywords = 'AuditSuccess' }
        @{ Server = 'Evo1'; LogName = 'Security'; Type = 'Computer'; MaxEvents = 15; Level = 'Informational'; Keywords = 'AuditFailure' }
    )
    $Output = Get-Events -ExtendedInput $List -Verbose
    $Output | Format-Table Computer, Date, LevelDisplayName

    .EXAMPLE
    Get-Events -MaxEvents 2 -LogName 'Security' -ComputerName 'AD1.AD.EVOTEC.XYZ','AD2' -ID 4720, 4738, 5136, 5137, 5141, 4722, 4725, 4767, 4723, 4724, 4726, 4728, 4729, 4732, 4733, 4746, 4747, 4751, 4752, 4756, 4757, 4761, 4762, 4785, 4786, 4787, 4788, 5136, 5137, 5141, 5136, 5137, 5141, 5136, 5137, 5141 -Verbose

    .NOTES
    General notes
    #>
    [CmdLetBinding()]
    param (
        [alias ("ADDomainControllers", "DomainController", "Server", "Servers", "Computer", "Computers", "ComputerName")] [string[]] $Machine = $Env:COMPUTERNAME,
        [alias ("StartTime", "From")][nullable[DateTime]] $DateFrom = $null,
        [alias ("EndTime", "To")][nullable[DateTime]] $DateTo = $null,
        [alias ("Ids", "EventID", "EventIds")] [int[]] $ID = $null,
        [alias ("ExludeEventID")][int[]] $ExcludeID = $null,
        [alias ("LogType", "Log")][string] $LogName = $null,
        [alias ("Provider", "Source")] [string[]] $ProviderName,
        [hashtable] $NamedDataFilter,
        [hashtable] $NamedDataExcludeFilter,
        [string[]] $UserID,
        [EventViewerX.Level[]] $Level = $null,
        [string] $UserSID = $null,
        [string[]]$Data = $null,
        [int] $MaxEvents = $null,

        [ValidateNotNull()]
        [alias('Credentials')][System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty,

        [string] $Path = $null,
        [EventViewerX.Keywords[]] $Keywords = $null,
        [alias("EventRecordID")][int64] $RecordID,
        [int] $MaxRunspaces = [int]$env:NUMBER_OF_PROCESSORS + 1,
        [switch] $Oldest,
        [switch] $DisableParallel,
        [switch] $ExtendedOutput,
        [Array] $ExtendedInput
    )
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
        $Verbose = $true 
    } else {
        $Verbose = $false 
    }

    $MeasureTotal = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start
    $ParametersList = [System.Collections.Generic.List[Object]]::new()

    if ($ExtendedInput.Count -gt 0) {
        # Special input - PSWinReporting requires it
        [Array] $Param = foreach ($EventEntry in $ExtendedInput) {
            $EventFilter = @{ }
            if ($EventEntry.Type -eq 'File') {
                Write-Verbose "Get-Events - Preparing data to scan file $($EventEntry.Server)"
                Add-ToHashTable -Hashtable $EventFilter -Key "Path" -Value $EventEntry.Server
                $Comp = $Env:COMPUTERNAME
            } else {
                Write-Verbose "Get-Events - Preparing data to scan computer $($EventEntry.Server)"
                $Comp = $EventEntry.Server
            }
            $ConvertedLevels = foreach ($DataLevel in $EventEntry.Level) {
                ([EventViewerX.Level]::$DataLevel).value__
            }
            $ConvertedKeywords = foreach ($DataKeyword in $EventEntry.Keywords) {
                ([EventViewerX.Keywords]::$DataKeyword).value__
            }
            Add-ToHashTable -Hashtable $EventFilter -Key "LogName" -Value $EventEntry.LogName
            Add-ToHashTable -Hashtable $EventFilter -Key "StartTime" -Value $EventEntry.DateFrom
            Add-ToHashTable -Hashtable $EventFilter -Key "EndTime" -Value $EventEntry.DateTo
            Add-ToHashTable -Hashtable $EventFilter -Key "Keywords" -Value $ConvertedKeywords
            Add-ToHashTable -Hashtable $EventFilter -Key "Level" -Value $ConvertedLevels
            Add-ToHashTable -Hashtable $EventFilter -Key "UserID" -Value $EventEntry.UserSID
            Add-ToHashTable -Hashtable $EventFilter -Key "Data" -Value $EventEntry.Data
            Add-ToHashTable -Hashtable $EventFilter -Key "RecordID" -Value $EventEntry.RecordID
            Add-ToHashTable -Hashtable $EventFilter -Key "NamedDataFilter" -Value $EventEntry.NamedDataFilter
            Add-ToHashTable -Hashtable $EventFilter -Key "NamedDataExcludeFilter" -Value $EventEntry.NamedDataExcludeFilter
            Add-ToHashTable -Hashtable $EventFilter -Key "UserID" -Value $EventEntry.UserID
            Add-ToHashTable -Hashtable $EventFilter -Key "ExcludeID" -Value $EventEntry.ExcludeID

            if ($Verbose) {
                foreach ($Key in $EventFilter.Keys) {
                    if ($Key -eq 'NamedDataFilter' -or $Key -eq 'NamedDataExcludeFilter') {
                        foreach ($SubKey in $($EventFilter.$Key).Keys) {
                            Write-Verbose "Get-Events - Filter parameters provided $Key with SubKey $SubKey = $(($EventFilter.$Key.$SubKey) -join ', ')"
                        }
                    } else {
                        Write-Verbose "Get-Events - Filter parameters provided $Key = $(($EventFilter.$Key) -join ', ')"
                    }
                }
            }
            if ($null -ne $EventEntry.EventID) {
                $ID = $EventEntry.EventID | Sort-Object -Unique
                Write-Verbose "Get-Events - Events to process in Total (unique): $($Id.Count)"
                Write-Verbose "Get-Events - Events to process in Total ID: $($ID -join ', ')"
                if ($Id.Count -gt 22) {
                    Write-Verbose "Get-Events - There are more events to process then 22, split will be required."
                }
                $SplitArrayID = Split-Array -inArray $ID -Size 22  # Support for more ID's then 22 (limitation of Get-WinEvent)
                foreach ($EventIdGroup in $SplitArrayID) {
                    $EventFilter.Id = @($EventIdGroup)
                    @{
                        Comp        = $Comp
                        Credential  = $Credential
                        EventFilter = $EventFilter.Clone()
                        MaxEvents   = $EventEntry.MaxEvents
                        Oldest      = $Oldest
                        Verbose     = $Verbose
                    }
                }
            } else {
                @{
                    Comp        = $Comp
                    Credential  = $Credential
                    EventFilter = $EventFilter
                    MaxEvents   = $EventEntry.MaxEvents
                    Oldest      = $Oldest
                    Verbose     = $Verbose
                }
            }
        }
        if ($null -ne $Param) {
            $null = $ParametersList.AddRange($Param)
        }
    } else {
        # Standard input
        $EventFilter = @{ }
        Add-ToHashTable -Hashtable $EventFilter -Key "LogName" -Value $LogName # Accepts Wildcard
        Add-ToHashTable -Hashtable $EventFilter -Key "ProviderName" -Value $ProviderName # Accepts Wildcard
        Add-ToHashTable -Hashtable $EventFilter -Key "Path" -Value $Path # https://blogs.technet.microsoft.com/heyscriptingguy/2011/01/25/use-powershell-to-parse-saved-event-logs-for-errors/
        Add-ToHashTable -Hashtable $EventFilter -Key "Keywords" -Value $Keywords.value__
        Add-ToHashTable -Hashtable $EventFilter -Key "Level" -Value $Level.value__
        Add-ToHashTable -Hashtable $EventFilter -Key "StartTime" -Value $DateFrom
        Add-ToHashTable -Hashtable $EventFilter -Key "EndTime" -Value $DateTo
        Add-ToHashTable -Hashtable $EventFilter -Key "UserID" -Value $UserSID
        Add-ToHashTable -Hashtable $EventFilter -Key "Data" -Value $Data
        Add-ToHashTable -Hashtable $EventFilter -Key "RecordID" -Value $RecordID
        Add-ToHashTable -Hashtable $EventFilter -Key "NamedDataFilter" -Value $NamedDataFilter
        Add-ToHashTable -Hashtable $EventFilter -Key "NamedDataExcludeFilter" -Value $NamedDataExcludeFilter
        Add-ToHashTable -Hashtable $EventFilter -Key "UserID" -Value $UserID
        Add-ToHashTable -Hashtable $EventFilter -Key "ExcludeID" -Value $ExcludeID

        [Array] $Param = foreach ($Comp in $Machine) {
            if ($Verbose) {
                Write-Verbose "Get-Events - Preparing data to scan computer $Comp"
                foreach ($Key in $EventFilter.Keys) {
                    if ($Key -eq 'NamedDataFilter' -or $Key -eq 'NamedDataExcludeFilter') {
                        foreach ($SubKey in $($EventFilter.$Key).Keys) {
                            Write-Verbose "Get-Events - Filter parameters provided $Key with SubKey $SubKey = $(($EventFilter.$Key.$SubKey) -join ', ')"
                        }
                    } else {
                        Write-Verbose "Get-Events - Filter parameters provided $Key = $(($EventFilter.$Key) -join ', ')"
                    }
                }
            }
            if ($null -ne $ID) {
                # EventID needed
                $ID = $ID | Sort-Object -Unique
                Write-Verbose "Get-Events - Events to process in Total (unique): $($Id.Count)"
                Write-Verbose "Get-Events - Events to process in Total ID: $($ID -join ', ')"
                if ($Id.Count -gt 22) {
                    Write-Verbose "Get-Events - There are more events to process then 22, split will be required."
                }
                $SplitArrayID = Split-Array -inArray $ID -Size 22  # Support for more ID's then 22 (limitation of Get-WinEvent)
                foreach ($EventIdGroup in $SplitArrayID) {
                    $EventFilter.Id = @($EventIdGroup)
                    @{
                        Comp        = $Comp
                        Credential  = $Credential
                        EventFilter = $EventFilter.Clone()
                        MaxEvents   = $MaxEvents
                        Oldest      = $Oldest
                        Verbose     = $Verbose
                    }
                }
            } else {
                # No EventID given
                @{
                    Comp        = $Comp
                    Credential  = $Credential
                    EventFilter = $EventFilter
                    MaxEvents   = $MaxEvents
                    Oldest      = $Oldest
                    Verbose     = $Verbose
                }
            }
        }
        if ($null -ne $Param) {
            $null = $ParametersList.AddRange($Param)
        }
    }
    $AllErrors = @()
    if ($DisableParallel) {
        Write-Verbose 'Get-Events - Running query with parallel disabled...'
        [Array] $AllEvents = foreach ($Parameter in $ParametersList) {
            Invoke-Command -ScriptBlock $Script:ScriptBlock -ArgumentList $Parameter.Comp, $Parameter.Credential, $Parameter.EventFilter, $Parameter.MaxEvents, $Parameter.Oldest, $Parameter.Verbose
        }
    } else {
        Write-Verbose 'Get-Events - Running query with parallel enabled...'
        $RunspacePool = New-Runspace -maxRunspaces $maxRunspaces -Verbose:$Verbose
        $Runspaces = foreach ($Parameter in $ParametersList) {
            Start-Runspace -ScriptBlock $Script:ScriptBlock -Parameters $Parameter -RunspacePool $RunspacePool -Verbose:$Verbose
        }
        [Array] $AllEvents = Stop-Runspace -Runspaces $Runspaces -FunctionName "Get-Events" -RunspacePool $RunspacePool -Verbose:$Verbose -ErrorAction SilentlyContinue -ErrorVariable +AllErrors -ExtendedOutput:$ExtendedOutput
    }
    Write-Verbose "Get-Events - Overall errors: $($AllErrors.Count)"
    Write-Verbose "Get-Events - Overall events processed in total for the report: $($AllEvents.Count)"
    Write-Verbose "Get-Events - Overall time to generate $($MeasureTotal.Elapsed.Hours) hours, $($MeasureTotal.Elapsed.Minutes) minutes, $($MeasureTotal.Elapsed.Seconds) seconds, $($MeasureTotal.Elapsed.Milliseconds) milliseconds"
    $MeasureTotal.Stop()
    Write-Verbose "Get-Events - Overall events processing end"
    if ($AllEvents.Count -eq 1) {
        return , $AllEvents
    } else {
        return $AllEvents
    }
}
function Get-EventsFilter {
    <#
    .SYNOPSIS
    This function generates an xpath filter that can be used with the -FilterXPath
    parameter of Get-WinEvent.  It may also be used inside the <Select></Select tags
    of a Custom View in Event Viewer.

    .DESCRIPTION
    This function generates an xpath filter that can be used with the -FilterXPath
    parameter of Get-WinEvent.  It may also be used inside the <Select></Select tags
    of a Custom View in Event Viewer.

    This function allows for the create of xpath which can select events based on
    many properties of the event including those of named data nodes in the event's
    XML.

    XPath is case sensetive and the data passed to the parameters here must
    match the case of the data in the event's XML.

    .NOTES
    Original Code by https://community.spiceworks.com/scripts/show/3238-powershell-xpath-generator-for-windows-events
    Extended by Justin Grote
    Extended by Przemyslaw Klys

    .LINK

    .PARAMETER ID
    This parameter accepts and array of event ids to include in the xpath filter.

    .PARAMETER StartTime
    This parameter sets the oldest event that may be returned by the xpath.

    Please, note that the xpath time selector created here is based of of the
    time the xpath is generated.  XPath uses a time difference method to select
    events by time; that time difference being the number of milliseconds between
    the time and now.

    .PARAMETER EndTime
    This parameter sets the newest event that may be returned by the xpath.

    Please, note that the xpath time selector created here is based of of the
    time the xpath is generated.  XPath uses a time difference method to select
    events by time; that time difference being the number of milliseconds between
    the time and now.

    .PARAMETER Data
    This parameter will accept an array of values that may be found in the data
    section of the event's XML.

    .PARAMETER ProviderName
    This parameter will accept an array of values that select events from event
    providers.

    .PARAMETER Level
    This parameter will accept an array of values that specify the severity
    rating of the events to be returned.

    It accepts the following values.

    'Critical',
    'Error',
    'Informational',
    'LogAlways',
    'Verbose',
    'Warning'

    .PARAMETER Keywords
    This parameter accepts and array of long integer keywords. You must
    pass this parameter the long integer value of the keywords you want
    to search and not the keyword description.

    .PARAMETER UserID
    This parameter will accept an array of SIDs or domain accounts.

    .PARAMETER NamedDataFilter
    This parameter will accept and array of hashtables that define the key
    value pairs for which you want to filter against the event's named data
    fields.

    Key values, as with XPath filters, are case sensetive.

    You may assign an array as the value of any key. This will search
    for events where any of the values are present in that particular
    data field. If you wanted to define a filter that searches for a SubjectUserName
    of either john.doe or jane.doe, pass the following

    @{'SubjectUserName'=('john.doe','jane.doe')}

    You may specify multiple data files and values. Doing so will create
    an XPath filter that will only return results where both values
    are found. If you only wanted to return events where both the
    SubjectUserName is john.doe and the TargetUserName is jane.doe, then
    pass the following

    @{'SubjectUserName'='john.doe';'TargetUserName'='jane.doe'}

    You may pass an array of hash tables to create an 'or' XPath filter
    that will return objects where either key value set will be returned.
    If you wanted to define a filter that searches for either a
    SubjectUserName of john.doe or a TargetUserName of jane.doe then pass
    the following

    (@{'SubjectUserName'='john.doe'},@{'TargetUserName'='jane.doe'})

    .EXAMPLE
    Get-EventsFilter -ID 4663 -NamedDataFilter @{'SubjectUserName'='john.doe'} -LogName 'ForwardedEvents'

    This will return an XPath filter that will return any events with
    the id of 4663 and has a SubjectUserName of 'john.doe'

    Output:
    <QueryList>
        <Query Id="0" Path="ForwardedEvents">
            <Select Path="ForwardedEvents">
                    (*[System[EventID=4663]]) and (*[EventData[Data[@Name='SubjectUserName'] = 'john.doe']])
            </Select>
        </Query>
    </QueryList>

    .EXAMPLE
    Get-EventsFilter -StartTime '1/1/2015 01:30:00 PM' -EndTime '1/1/2015 02:00:00 PM' -LogName 'ForwardedEvents

    This will return an XPath filter that will return events that occured between 1:30
    2:00 PM on 1/1/2015.  The filter will only be good if used immediately.  XPath time
    filters are based on the number of milliseconds that have occured since the event
    and when the filter is used.  StartTime and EndTime simply calculate the number of
    milliseconds and use that for the filter.

    Output:
    <QueryList>
        <Query Id="0" Path="ForwardedEvents">
            <Select Path="ForwardedEvents">
                    (*[System[TimeCreated[timediff(@SystemTime) &lt;= 125812885399]]]) and (*[System[TimeCreated[timediff(@SystemTime)
&gt;= 125811085399]]])
            </Select>
        </Query>
    </QueryList>

    .EXAMPLE
    Get-EventsFilter -StartTime (Get-Date).AddDays(-1) -LogName System

    This will return an XPath filter that will get events that occured within the last 24 hours.

    Output:
    <QueryList>
        <Query Id="0" Path="System">
                <Select Path="System">
                    *[System[TimeCreated[timediff(@SystemTime) &lt;= 86404194]]]
            </Select>
        </Query>
    </QueryList>

    .EXAMPLE
    Get-EventsFilter -ID 1105 -LogName 'ForwardedEvents' -RecordID '3512231','3512232'

    This will return an XPath filter that will get events with EventRecordID 3512231 or 3512232 in Log ForwardedEvents with EventID 1105

    Output:
    <QueryList>
        <Query Id="0" Path="ForwardedEvents">
                <Select Path="ForwardedEvents">
                    (*[System[EventID=1105]]) and (*[System[(EventRecordID=3512231) or (EventRecordID=3512232)]])
            </Select>
        </Query>
    </QueryList>

    .EXAMPLE
    Get-EventsFilter -LogName 'System' -id 7040 -NamedDataFilter @{ param4 = ('TrustedInstaller','BITS') }

    Will return a XPath filter that will check the systemlog for events generated by these events

    <QueryList>
        <Query Id="0" Path="System">
            <Select Path="System">
                    (*[System[EventID=7040]]) and (*[EventData[Data[@Name='param4'] = 'TrustedInstaller' or Data[@Name='param4'] = 'BITS']])
            </Select>
        </Query>
    </QueryList>

    .EXAMPLE
    Get-EventsFilter -LogName 'System' -id 7040 -NamedDataExcludeFilter  @{ param4 = ('TrustedInstaller','BITS') }

    Will return a XPath filter that will check the systemlog for all events with ID 7040 (change starttype) except those two

    <QueryList>
        <Query Id="0" Path="System">
            <Select Path="System">
                    (*[System[EventID=7040]]) and (*[EventData[Data[@Name='param4'] != 'TrustedInstaller' and Data[@Name='param4'] != 'BITS']])
            </Select>
        </Query>
    </QueryList>
    #>

    [CmdletBinding()]
    Param
    (
        [String[]]
        $ID,

        [alias('RecordID')][string[]]
        $EventRecordID,

        [DateTime]
        $StartTime,

        [DateTime]
        $EndTime,

        [String[]]
        $Data,

        [String[]]
        $ProviderName,

        [Long[]]
        $Keywords,

        [ValidateSet(
            'Critical',
            'Error',
            'Informational',
            'LogAlways',
            'Verbose',
            'Warning'
        )]
        [String[]]
        $Level,

        [String[]]
        $UserID,

        [Hashtable[]]
        $NamedDataFilter,

        [Hashtable[]]
        $NamedDataExcludeFilter,

        [String[]]
        $ExcludeID,

        [String]
        $LogName,

        [String]
        $Path,

        [switch] $XPathOnly
    )

    #region Function definitions
    Function Join-XPathFilter {
        Param
        (
            [Parameter(
                Mandatory = $True,
                Position = 0
            )]
            [String]
            $NewFilter,

            [Parameter(
                Position = 1
            )]
            [String]
            $ExistingFilter = '',

            [Parameter(
                Position = 2
            )]
            # and and or are case sensitive
            # in xpath
            [ValidateSet(
                "and",
                "or",
                IgnoreCase = $False
            )]
            [String]
            $Logic = 'and',

            [switch]$NoParenthesis
        )

        If ($ExistingFilter) {
            # If there is an existing filter add parenthesis unless noparenthesis is specified
            # and the logical operator
            if ($NoParenthesis) {
                Return "$ExistingFilter $Logic $NewFilter"
            } Else {
                Return "($ExistingFilter) $Logic ($NewFilter)"
            }
        } Else {
            Return $NewFilter
        }
        <#
    .SYNOPSIS
    This function handles the parenthesis and logical joining
    of XPath statements inside of Get-EventsFilter
    #>
    }

    Function Initialize-XPathFilter {
        Param
        (
            [Object[]]
            $Items,

            [String]
            $ForEachFormatString,

            [String]
            $FinalizeFormatString,

            [ValidateSet("and", "or", IgnoreCase = $False)]
            [String]
            $Logic = 'or',

            [switch]$NoParenthesis
        )

        $filter = ''

        ForEach ($item in $Items) {
            $options = @{'NewFilter' = ($ForEachFormatString -f $item)
                'ExistingFilter'     = $filter
                'Logic'              = $logic
                'NoParenthesis'      = $NoParenthesis
            }
            $filter = Join-XPathFilter @options
        }

        Return $FinalizeFormatString -f $filter
        <#
    .SYNOPSIS
    This function loops thru a set of items and injecting each
    item in the format string given by ForEachFormatString, then
    combines each of those items together with 'or' logic
    using the function Join-XPathFilter, which handles the
    joining and parenthesis.  Before returning the result,
    it injects the resultant xpath into FinalizeFormatString.

    This function is a part of Get-EventsFilter
    #>
    }
    #endregion Function definitions

    [string] $filter = ''

    #region ID filter
    If ($ID) {
        $options = @{
            'Items'                = $ID
            'ForEachFormatString'  = "EventID={0}"
            'FinalizeFormatString' = "*[System[{0}]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    #endregion ID filter

    # region EventRecordID filter
    If ($EventRecordID) {
        $options = @{
            'Items'                = $EventRecordID
            'ForEachFormatString'  = "EventRecordID={0}"
            'FinalizeFormatString' = "*[System[{0}]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    #endregion EventRecordID filter

    #region Exclude ID filter
    If ($ExcludeID) {
        $options = @{
            'Items'                = $ExcludeID
            'ForEachFormatString'  = "EventID!={0}"
            'FinalizeFormatString' = "*[System[{0}]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    #endregion Exclude ID filter

    #region Date filters
    $Now = Get-Date

    # Time in XPath is filtered based on the number of milliseconds
    # between the creation of the event and when the XPath filter is
    # used.
    #
    # The timediff xpath function is used against the SystemTime
    # attribute of the TimeCreated node.

    ## Special chars needs replacement
    # <= is &lt;=
    # <  is &lt;
    # >  is &gt;
    # >= is &gt;=
    #

    If ($StartTime) {
        $Diff = [Math]::Round($Now.Subtract($StartTime).TotalMilliseconds)
        $filter = Join-XPathFilter -NewFilter "*[System[TimeCreated[timediff(@SystemTime) &lt;= $Diff]]]" -ExistingFilter $filter
    }

    If ($EndTime) {
        $Diff = [Math]::Round($Now.Subtract($EndTime).TotalMilliseconds)
        $filter = Join-XPathFilter -NewFilter "*[System[TimeCreated[timediff(@SystemTime) &gt;= $Diff]]]" -ExistingFilter $filter
    }
    #endregion Date filters

    #region Data filter
    If ($Data) {
        $options = @{
            'Items'                = $Data
            'ForEachFormatString'  = "Data='{0}'"
            'FinalizeFormatString' = "*[EventData[{0}]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    #endregion Data filter

    #region ProviderName filter
    If ($ProviderName) {
        $options = @{
            'Items'                = $ProviderName
            'ForEachFormatString'  = "@Name='{0}'"
            'FinalizeFormatString' = "*[System[Provider[{0}]]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    #endregion ProviderName filter

    #region Level filter
    If ($Level) {
        $levels = ForEach ($item in $Level) {
            # Levels in an event's XML are defined
            # with integer values.
            [Int][System.Diagnostics.Tracing.EventLevel]::$item
        }

        $options = @{
            'Items'                = $levels
            'ForEachFormatString'  = "Level={0}"
            'FinalizeFormatString' = "*[System[{0}]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    #endregion Level filter

    #region Keyword filter
    # Keywords are stored as a long integer
    # numeric value.  That integer is the
    # flagged (binary) combination of
    # all the keywords.
    #
    # By combining all given keywords
    # with a binary OR operation, and then
    # taking the resultant number and
    # comparing that against the number
    # stored in the events XML with a
    # binary AND operation will return
    # events that have any of the submitted
    # keywords assigned.
    If ($Keywords) {
        $keyword_filter = ''

        ForEach ($item in $Keywords) {
            If ($keyword_filter) {
                $keyword_filter = $keyword_filter -bor $item
            } Else {
                $keyword_filter = $item
            }
        }

        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter "*[System[band(Keywords,$keyword_filter)]]"
    }
    #endregion Keyword filter

    #region UserID filter
    # The UserID attribute of the Security node contains a Sid.
    If ($UserID) {
        $sids = ForEach ($item in $UserID) {
            Try {
                #If the value submitted isn't a valid sid, it'll error.
                $sid = [System.Security.Principal.SecurityIdentifier]($item)
                $sid = $sid.Translate([System.Security.Principal.SecurityIdentifier])
            } Catch [System.Management.Automation.RuntimeException] {
                # If a RuntimeException occured with an InvalidArgument category
                # attempt to create an NTAccount object and resolve.
                If ($Error[0].CategoryInfo.Category -eq 'InvalidArgument') {
                    Try {
                        $user = [System.Security.Principal.NTAccount]($item)
                        $sid = $user.Translate([System.Security.Principal.SecurityIdentifier])
                    } Catch {
                        #There was an error with either creating the NTAccount or
                        #Translating that object to a sid.
                        Throw $Error[0]
                    }
                } Else {
                    #There was a RuntimeException from either creating the
                    #SecurityIdentifier object or the translation
                    #and the category was not InvalidArgument
                    Throw $Error[0]
                }
            } Catch {
                #There was an error from ether the creation of the SecurityIdentifier
                #object or the Translatation
                Throw $Error[0]
            }

            $sid.Value
        }

        $options = @{
            'Items'                = $sids
            'ForEachFormatString'  = "@UserID='{0}'"
            'FinalizeFormatString' = "*[System[Security[{0}]]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    #endregion UserID filter

    #region NamedDataFilter
    If ($NamedDataFilter) {
        $options = @{
            'Items'                = $(
                # This will create set of datafilters for each of
                # the hash tables submitted in the hash table array
                ForEach ($item in $NamedDataFilter) {
                    $options = @{
                        'Items'                = $(
                            #This will result in as set of XPath subexpressions
                            #for each key submitted in the hashtable
                            ForEach ($key in $item.Keys) {
                                If ($item[$key]) {
                                    #If there is a value for the key, create the
                                    #XPath for the Data node with that Name attribute
                                    #and value. Use 'and' logic to join the data values.
                                    #to the Name Attribute.
                                    $options = @{
                                        'Items'                = $item[$key]
                                        'NoParenthesis'        = $true
                                        'ForEachFormatString'  = "Data[@Name='$key'] = '{0}'"
                                        'FinalizeFormatString' = "{0}"
                                    }
                                    Initialize-XPathFilter @options
                                } Else {
                                    #If there isn't a value for the key, create
                                    #XPath for the existence of the Data node with
                                    #that paritcular Name attribute.
                                    "Data[@Name='$key']"
                                }
                            }
                        )
                        'ForEachFormatString'  = "{0}"
                        'FinalizeFormatString' = "{0}"
                    }
                    Initialize-XPathFilter @options
                }
            )
            'ForEachFormatString'  = "{0}"
            'FinalizeFormatString' = "*[EventData[{0}]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    #endregion NamedDataFilter

    #region NamedDataExcludeFilter
    If ($NamedDataExcludeFilter) {
        $options = @{
            'Items'                = $(
                # This will create set of datafilters for each of
                # the hash tables submitted in the hash table array
                ForEach ($item in $NamedDataExcludeFilter) {
                    $options = @{
                        'Items'                = $(
                            #This will result in as set of XPath subexpressions
                            #for each key submitted in the hashtable
                            ForEach ($key in $item.Keys) {
                                If ($item[$key]) {
                                    #If there is a value for the key, create the
                                    #XPath for the Data node with that Name attribute
                                    #and value. Use 'and' logic to join the data values.
                                    #to the Name Attribute.
                                    $options = @{
                                        'Items'                = $item[$key]
                                        'NoParenthesis'        = $true
                                        'ForEachFormatString'  = "Data[@Name='$key'] != '{0}'"
                                        'FinalizeFormatString' = "{0}"
                                        'Logic'                = 'and'
                                    }
                                    Initialize-XPathFilter @options
                                } Else {
                                    #If there isn't a value for the key, create
                                    #XPath for the existence of the Data node with
                                    #that paritcular Name attribute.
                                    "Data[@Name='$key']"
                                }
                            }
                        )
                        'ForEachFormatString'  = "{0}"
                        'FinalizeFormatString' = "{0}"
                    }
                    Initialize-XPathFilter @options
                }
            )
            'ForEachFormatString'  = "{0}"
            'FinalizeFormatString' = "*[EventData[{0}]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    #endregion NamedDataExcludeFilter

    if ($XPathOnly) {
        return $Filter
    } else {
        if ($Path -ne '') {
            $FilterXML = @"
                <QueryList>
                    <Query Id="0" Path="file://$Path">
                        <Select>
                                $filter
                        </Select>
                    </Query>
                </QueryList>
"@
        } else {
            $FilterXML = @"
                <QueryList>
                    <Query Id="0" Path="$LogName">
                        <Select Path="$LogName">
                                $filter
                        </Select>
                    </Query>
                </QueryList>
"@
        }
        return $FilterXML
    }
} # Function Get-EventsFilter
function Get-EventsInformation {
    <#
    .SYNOPSIS
    Small wrapper against Get-WinEvent providing easy way to gather statistics for Event Logs.

    .DESCRIPTION
    Small wrapper against Get-WinEvent providing easy way to gather statistics for Event Logs.
    It provides option to ask for multiple machines, multiple files at the same time.
    It runs on steroids (runspaces) which allows youto process everything at same time.
    This basically allows you to query 50 servers at same time and do it in finite way.

    .PARAMETER Machine
    ComputerName or Server you want to query. Takes an array of servers as well.

    .PARAMETER FilePath
    FilePath to Event Log file (with .EVTX). Takes an array of Event Log files.

    .PARAMETER LogName
    LogName such as Security or System. Works in conjuction with Machine (s). Default is Security.

    .PARAMETER MaxRunspaces
    Maximum number of runspaces running at same time. For optimum performance decide on your own. Default is 50.

    .EXAMPLE
    $Computer = 'EVO1','AD1','AD2'
    $LogName = 'Security'

    $Size = Get-EventsInformation -Computer $Computer -LogName $LogName
    $Size | ft -A

    Output:

    EventNewest         EventOldest          FileSize FileSizeCurrentGB FileSizeMaximumGB IsClassicLog IsEnabled IsLogFull LastAccessTime      LastWriteTime
    -----------         -----------          -------- ----------------- ----------------- ------------ --------- --------- --------------      -------------
    28.12.2018 12:47:14 20.12.2018 19:29:57 110170112 0.1 GB            0.11 GB                   True      True     False 27.05.2018 14:18:36 28.12.2018 12:33:24
    28.12.2018 12:46:51 26.12.2018 12:54:16  20975616 0.02 GB           0.02 GB                   True      True     False 28.12.2018 12:46:57 28.12.2018 12:46:57

    .EXAMPLE

    Due to AD2 being down time to run is 22 seconds. This is actual timeout before letting it go.

    $Computers = 'EVO1', 'AD1', 'AD2'
    $LogName = 'Security'

    $EventLogsDirectory = Get-ChildItem -Path 'C:\MyEvents'

    $Size = Get-EventsInformation -FilePath $EventLogsDirectory.FullName -Computer $Computers -LogName 'Security'
    $Size | ft -a

    Output:

    VERBOSE: Get-EventsInformation - processing start
    VERBOSE: Get-EventsInformation - Setting up runspace for EVO1
    VERBOSE: Get-EventsInformation - Setting up runspace for AD1
    VERBOSE: Get-EventsInformation - Setting up runspace for AD2
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-08-21-23-49-19-424.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-08-02-53-53-711.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-15-09-27-52-679.evtx
    VERBOSE: AD2 Reading Event Log (Security) size failed. Error occured: The RPC server is unavailable
    VERBOSE: Get-EventsInformation - processing end - 0 days, 0 hours, 0 minutes, 22 seconds, 648 milliseconds

    EventNewest         EventOldest          FileSize FileSizeCurrentGB FileSizeMaximumGB IsClassicLog IsEnabled IsLogFull LastAccessTime      LastWriteTime
    -----------         -----------          -------- ----------------- ----------------- ------------ --------- --------- --------------      -------------
    28.12.2018 15:56:54 20.12.2018 19:29:57 111218688 0.1 GB            0.11 GB                   True      True     False 27.05.2018 14:18:36 28.12.2018 14:18:24
    22.08.2018 01:48:57 11.08.2018 09:28:06 115740672 0.11 GB           0.11 GB                  False     False     False 16.09.2018 09:27:04 22.08.2018 01:49:20
    08.09.2018 04:53:52 03.09.2018 23:50:15 115740672 0.11 GB           0.11 GB                  False     False     False 12.09.2018 13:18:25 08.09.2018 04:53:53
    15.09.2018 00:13:06 08.09.2018 04:53:53 115740672 0.11 GB           0.11 GB                  False     False     False 15.09.2018 00:13:26 15.09.2018 00:13:08
    15.09.2018 11:27:51 22.08.2018 01:49:20 115740672 0.11 GB           0.11 GB                  False     False     False 15.09.2018 11:28:13 15.09.2018 11:27:55
    28.12.2018 15:56:56 26.12.2018 15:56:31  20975616 0.02 GB           0.02 GB                   True      True     False 28.12.2018 15:56:47 28.12.2018 15:56:47

    .EXAMPLE

    $Computers = 'EVO1', 'AD1','AD1'
    $LogName = 'Security'

    $EventLogsDirectory = Get-ChildItem -Path 'C:\MyEvents'

    $Size = Get-EventsInformation -FilePath $EventLogsDirectory.FullName -Computer $Computers -LogName 'Security' -Verbose
    $Size | ft -a Source, EventNewest, EventOldest,FileSize, FileSizeCurrentGB, FileSizeMaximumGB, IsEnabled, IsLogFull, LastAccessTime, LastWriteTime

    Output:

    VERBOSE: Get-EventsInformation - processing start
    VERBOSE: Get-EventsInformation - Setting up runspace for EVO1
    VERBOSE: Get-EventsInformation - Setting up runspace for AD1
    VERBOSE: Get-EventsInformation - Setting up runspace for AD1
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-08-21-23-49-19-424.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-08-02-53-53-711.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-15-09-27-52-679.evtx
    VERBOSE: Get-EventsInformation - processing end - 0 days, 0 hours, 0 minutes, 1 seconds, 739 milliseconds

    Source EventNewest         EventOldest          FileSize FileSizeCurrentGB FileSizeMaximumGB IsEnabled IsLogFull LastAccessTime      LastWriteTime
    ------ -----------         -----------          -------- ----------------- ----------------- --------- --------- --------------      -------------
    AD1    28.12.2018 15:59:22 20.12.2018 19:29:57 111218688 0.1 GB            0.11 GB                True     False 27.05.2018 14:18:36 28.12.2018 14:18:24
    AD1    28.12.2018 15:59:22 20.12.2018 19:29:57 111218688 0.1 GB            0.11 GB                True     False 27.05.2018 14:18:36 28.12.2018 14:18:24
    File   22.08.2018 01:48:57 11.08.2018 09:28:06 115740672 0.11 GB           0.11 GB               False     False 16.09.2018 09:27:04 22.08.2018 01:49:20
    File   08.09.2018 04:53:52 03.09.2018 23:50:15 115740672 0.11 GB           0.11 GB               False     False 12.09.2018 13:18:25 08.09.2018 04:53:53
    File   15.09.2018 00:13:06 08.09.2018 04:53:53 115740672 0.11 GB           0.11 GB               False     False 15.09.2018 00:13:26 15.09.2018 00:13:08
    File   15.09.2018 11:27:51 22.08.2018 01:49:20 115740672 0.11 GB           0.11 GB               False     False 15.09.2018 11:28:13 15.09.2018 11:27:55
    EVO1   28.12.2018 15:59:22 26.12.2018 15:56:31  20975616 0.02 GB           0.02 GB                True     False 28.12.2018 15:58:47 28.12.2018 15:58:47

    .EXAMPLE

    $Computers = 'EVO1', 'AD1'
    $EventLogsDirectory = Get-ChildItem -Path 'C:\MyEvents'

    $Size = Get-EventsInformation -FilePath $EventLogsDirectory.FullName -Computer $Computers -LogName 'Security','System' -Verbose
    $Size | ft -a Source, EventNewest, EventOldest,FileSize, FileSizeCurrentGB, FileSizeMaximumGB, IsEnabled, IsLogFull, LastAccessTime, LastWriteTime, LogFilePath, LOgName

    VERBOSE: Get-EventsInformation - processing start
    VERBOSE: Get-EventsInformation - Setting up runspace for EVO1
    VERBOSE: Get-EventsInformation - Setting up runspace for AD1
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-08-21-23-49-19-424.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-08-02-53-53-711.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-15-09-27-52-679.evtx
    VERBOSE: Get-EventsInformation - processing end - 0 days, 0 hours, 0 minutes, 0 seconds, 137 milliseconds

    Source EventNewest         EventOldest          FileSize FileSizeCurrentGB FileSizeMaximumGB IsEnabled IsLogFull LastAccessTime      LastWriteTime       LogFilePath                                               LogName
    ------ -----------         -----------          -------- ----------------- ----------------- --------- --------- --------------      -------------       -----------                                               -------
    File   22.08.2018 01:48:57 11.08.2018 09:28:06 115740672 0.11 GB           0.11 GB               False     False 16.09.2018 09:27:04 22.08.2018 01:49:20 C:\MyEvents\Archive-Security-2018-08-21-23-49-19-424.evtx N/A
    File   08.09.2018 04:53:52 03.09.2018 23:50:15 115740672 0.11 GB           0.11 GB               False     False 12.09.2018 13:18:25 08.09.2018 04:53:53 C:\MyEvents\Archive-Security-2018-09-08-02-53-53-711.evtx N/A
    EVO1   28.12.2018 18:19:48 26.12.2018 17:27:30  20975616 0.02 GB           0.02 GB                True     False 28.12.2018 18:19:47 28.12.2018 18:19:47 %SystemRoot%\System32\Winevt\Logs\Security.evtx           Security
    AD1    28.12.2018 18:20:01 20.12.2018 19:29:57 113315840 0.11 GB           0.11 GB                True     False 27.05.2018 14:18:36 28.12.2018 17:48:24 %SystemRoot%\System32\Winevt\Logs\Security.evtx           Security
    File   15.09.2018 00:13:06 08.09.2018 04:53:53 115740672 0.11 GB           0.11 GB               False     False 15.09.2018 00:13:26 15.09.2018 00:13:08 C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx N/A
    EVO1   28.12.2018 18:20:01 05.10.2018 01:33:48  12652544 0.01 GB           0.02 GB                True     False 28.12.2018 18:18:01 28.12.2018 18:18:01 %SystemRoot%\System32\Winevt\Logs\System.evtx             System
    AD1    28.12.2018 18:12:47 03.12.2018 17:20:48   2166784 0 GB              0.01 GB                True     False 19.05.2018 20:05:07 27.12.2018 12:00:32 %SystemRoot%\System32\Winevt\Logs\System.evtx             System
    File   15.09.2018 11:27:51 22.08.2018 01:49:20 115740672 0.11 GB           0.11 GB               False     False 15.09.2018 11:28:13 15.09.2018 11:27:55 C:\MyEvents\Archive-Security-2018-09-15-09-27-52-679.evtx N/A

    .NOTES
    General notes
    #>


    [CmdLetBinding()]
    param(
        [alias ("ADDomainControllers", "DomainController", "Server", "Servers", "Computer", "Computers", "ComputerName")]
        [string[]] $Machine = $Env:COMPUTERNAME,
        [string[]] $FilePath,
        [alias ("LogType", "Log")][string[]] $LogName = 'Security',
        [int] $MaxRunspaces = 50,
        [alias('AskDC', 'QueryDomainControllers', 'AskForest')][switch] $RunAgainstDC
    )
    Write-Verbose "Get-EventsInformation - processing start"
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
        $Verbose = $true 
    } else {
        $Verbose = $false 
    }

    $Time = Start-TimeLog
    $Pool = New-Runspace -maxRunspaces $maxRunspaces -Verbose:$Verbose

    if ($RunAgainstDC) {
        # we only allow that if AD module is available
        if (Get-Module -ListAvailable ActiveDirectory) {
            Write-Verbose 'Get-EventsInformation - scanning for domain controllers'
            $ForestInformation = Get-WinADForestControllers
            $MachineWithErrors = $ForestInformation | Where-Object { $_.HostName -eq '' }
            foreach ($Computer in $MachineWithErrors) {
                Write-Warning "Get-EventsInformation - Error scanning forest $($Computer.Forest) (domain: $($Computer.Domain)) error: $($Computer.Comment)"
            }
            $Machine = ($ForestInformation | Where-Object { $_.HostName -ne '' }).HostName
        } else {
            Write-Warning 'Get-EventsInformation - ActiveDirectory module is not available. Cannot scan for domain controllers'
            return
        }
    }

    $RunSpaces = @(
        foreach ($Computer in $Machine) {
            foreach ($Log in $LogName) {
                Write-Verbose "Get-EventsInformation - Setting up runspace for $Computer on $Log log"
                $Parameters = [ordered] @{
                    Computer = $Computer
                    LogName  = $Log
                    Verbose  = $Verbose
                }
                # returns values
                Start-Runspace -ScriptBlock $Script:ScriptBlockEventsInformation -Parameters $Parameters -RunspacePool $Pool -Verbose:$Verbose
            }
        }
        foreach ($Path in $FilePath) {
            Write-Verbose "Get-EventsInformation - Setting up runspace for $Path"
            $Parameters = [ordered] @{
                Path    = $Path
                Verbose = $Verbose
            }
            # returns values
            Start-Runspace -ScriptBlock $Script:ScriptBlockEventsInformation -Parameters $Parameters -RunspacePool $Pool -Verbose:$Verbose
        }
    )
    ### End Runspaces START
    $AllEvents = Stop-Runspace -Runspaces $RunSpaces `
        -FunctionName "Get-EventsInformation" `
        -RunspacePool $pool -Verbose:$Verbose `
        -ErrorAction SilentlyContinue `
        -ErrorVariable +AllErrors

    foreach ($Error in $AllErrors) {
        Write-Warning "Get-EventsInformation - Error: $Error"
    }

    $Elapsed = Stop-TimeLog -Time $Time -Option OneLiner
    Write-Verbose -Message "Get-EventsInformation - processing end - $Elapsed"
    ### End Runspaces END
    return $AllEvents
}
function Get-EventsSettings {
    <#
    .SYNOPSIS
    Get-EventsSettings retrieves information about a specified event log.

    .DESCRIPTION
    Get-EventsSettings retrieves detailed information about a specified event log, including log properties and settings.

    .EXAMPLE
    Get-EventsSettings -LogName 'Application'
    Retrieves information about the 'Application' event log.

    .EXAMPLE
    Get-EventsSettings -LogName 'Security' -ComputerName 'Server01'
    Retrieves information about the 'Security' event log on the remote computer 'Server01'.

    #>
    [cmdletBinding()]
    param(
        [parameter(Mandatory)][string] $LogName,
        [string] $ComputerName
    )
    try {
        if ($ComputerName) {
            $Log = Get-WinEvent -ListLog $LogName -ErrorAction Stop
        } else {
            $Log = Get-WinEvent -ListLog $LogName -ComputerName $ComputerName -ErrorAction Stop
        }
    } catch {
        if ($ErrorActionPreference -eq 'Stop') {
            throw
        } else {
            Write-Warning -Message "Get-EventsSettings - Error occured during reading of event log $LogName - $($_.Exception.Message)"
            return
        }
    }
    if ($Log.LogMode -eq 'AutoBackup') {
        $EventAction = 'ArchiveTheLogWhenFullDoNotOverwrite'
    } elseif ($Log.LogMode -eq 'Circular') {
        $EventAction = 'OverwriteEventsAsNeededOldestFirst'
    } elseif ($Log.LogMode -eq 'Retain') {
        $EventAction = 'DoNotOverwriteEventsClearLogManually'
    } else {
        $EventAction = 'Unknown'
    }
    [PSCustomObject] @{
        EventAction                    = $EventAction
        LogName                        = $Log.LogName                         # #: Application
        LogType                        = $Log.LogType                         # #: Administrative
        LogMode                        = $Log.LogMode                         # #: Circular
        FileSize                       = $Log.FileSize                        # #: 69632
        FileSizeMB                     = Convert-Size -Value $Log.FileSize -From Bytes -To MB -Precision 2
        MaximumSizeInBytes             = $Log.MaximumSizeInBytes              # #: 2105344
        MaximumSizeinMB                = Convert-Size -Value $Log.MaximumSizeInBytes -From Bytes -To MB -Precision 2
        IsLogFull                      = $Log.IsLogFull                       # #: False
        LogFilePath                    = $Log.LogFilePath                     # #: % SystemRoot % \System32\Winevt\Logs\Application.evtx
        LastAccessTime                 = $Log.LastAccessTime                  # #: 25.05.2022 12:32:29
        LastWriteTime                  = $Log.LastWriteTime                   # #: 25.05.2022 12:22:33
        OldestRecordNumber             = $Log.OldestRecordNumber              # #: 1
        RecordCount                    = $Log.RecordCount                     # #: 11
        LogIsolation                   = $Log.LogIsolation                    # #: Application
        IsEnabled                      = $Log.IsEnabled                       # #: True
        IsClassicLog                   = $Log.IsClassicLog                    # #: True
        SecurityDescriptor             = $Log.SecurityDescriptor              # #: O:BAG:SYD:(A; ; 0x2; ; ; S - 1 - 15 - 2 - 1)(A; ; 0x2; ; ; S - 1 - 15 - 3 - 1024 - 3153509613 - 960666767 - 3724611135 - 2725662640 - 12138253 - 543910227 - 1950414635 - 4190290187)(A; ; 0xf0007; ; ; SY)(A; ; 0x7; ; ; BA)(A; ; 0x7; ; ; SO)(A; ; 0x3; ; ; IU)(A; ; 0x3; ; ; SU)(A; ; 0x3; ; ; S - 1 - 5 - 3)(A; ; 0x3; ; ; S - 1 - 5 - 33)(A; ; 0x1; ; ; S - 1 - 5 - 32$Log. - 57
        OwningProviderName             = $Log.OwningProviderName              # #:
        ProviderNames                  = $Log.ProviderNames                   # #: { .NET Runtime, .NET Runtime Optimization Service, Application, Application Error… }
        ProviderLevel                  = $Log.ProviderLevel                   # #:
        ProviderKeywords               = $Log.ProviderKeywords                # #:
        ProviderBufferSize             = $Log.ProviderBufferSize              # #: 64
        ProviderMinimumNumberOfBuffers = $Log.ProviderMinimumNumberOfBuffers  # #: 0
        ProviderMaximumNumberOfBuffers = $Log.ProviderMaximumNumberOfBuffers  # #: 64
        ProviderLatency                = $Log.ProviderLatency                 # #: 1000
        ProviderControlGuid            = $Log.ProviderControlGuid             # #:
    }
}
function Set-EventsSettings {
    <#
    .SYNOPSIS
    Set-EventsSettings updates the settings of a specified event log.

    .DESCRIPTION
    Set-EventsSettings allows you to modify various settings of a specified event log, such as log mode, maximum size, and event action.

    .EXAMPLE
    Set-EventsSettings -LogName 'Application' -EventAction 'ArchiveTheLogWhenFullDoNotOverwrite'
    Updates the 'Application' event log to archive the log when full without overwriting.

    .EXAMPLE
    Set-EventsSettings -LogName 'Security' -MaximumSizeMB 100 -Mode Circular
    Sets the 'Security' event log to have a maximum size of 100 MB and log mode as Circular.
    #>
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string] $LogName,
        [string] $ComputerName,
        [int] $MaximumSizeMB,
        [int] $MaximumSizeInBytes,
        [ValidateSet('OverwriteEventsAsNeededOldestFirst', 'ArchiveTheLogWhenFullDoNotOverwrite', 'DoNotOverwriteEventsClearLogManually')][string] $EventAction,
        [alias('LogMode')][System.Diagnostics.Eventing.Reader.EventLogMode] $Mode
    )

    $TranslateEventAction = @{
        'OverwriteEventsAsNeededOldestFirst'   = [System.Diagnostics.Eventing.Reader.EventLogMode]::Circular
        'ArchiveTheLogWhenFullDoNotOverwrite'  = [System.Diagnostics.Eventing.Reader.EventLogMode]::AutoBackup
        'DoNotOverwriteEventsClearLogManually' = [System.Diagnostics.Eventing.Reader.EventLogMode]::Retain
    }

    try {
        if ($ComputerName) {
            $Log = Get-WinEvent -ListLog $LogName -ErrorAction Stop
        } else {
            $Log = Get-WinEvent -ListLog $LogName -ComputerName $ComputerName -ErrorAction Stop
        }
    } catch {
        if ($ErrorActionPreference -eq 'Stop') {
            throw
        } else {
            Write-Warning -Message "Set-EventsSettings - Error occured during reading $LogName log - $($_.Exception.Message)"
            return
        }
    }
    if ($PSBoundParameters.ContainsKey('EventAction')) {
        $Log.LogMode = $TranslateEventAction[$EventAction]
    }
    if ($PSBoundParameters.ContainsKey('Mode')) {
        $Log.LogMode = $Mode
    }
    if ($PSBoundParameters.ContainsKey('MaximumSizeMB')) {
        $MaxSize = $MaximumSizeMB * 1MB
        $Log.MaximumSizeInBytes = $MaxSize
    }
    if ($PSBoundParameters.ContainsKey('MaximumSizeInBytes')) {
        $Log.MaximumSizeInBytes = $MaximumSizeInBytes
    }
    if ($PSCmdlet.ShouldProcess($LogName, "Saving event log settings")) {
        try {
            $Log.SaveChanges()
        } catch {
            if ($ErrorActionPreference -eq 'Stop') {
                throw
            } else {
                Write-Warning -Message "Set-EventsSettings - Error occured during saving of changes for $LogName log - $($_.Exception.Message)"
                return
            }
        }
    }
}



# Export functions and aliases as required
Export-ModuleMember -Function @('Get-Events', 'Get-EventsFilter', 'Get-EventsInformation', 'Get-EventsSettings', 'Set-EventsSettings') -Alias @('Write-Event') -Cmdlet 'Find-WinEvent', 'Start-EventWatching', 'Write-WinEvent'
# SIG # Begin signature block
# MIItqwYJKoZIhvcNAQcCoIItnDCCLZgCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCaPa7eUx+mq6GU
# 4V1DiymQw8+/NZVNFgT13p5puNlcE6CCJq4wggWNMIIEdaADAgECAhAOmxiO+dAt
# 5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBa
# Fw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3E
# MB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKy
# unWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsF
# xl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU1
# 5zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJB
# MtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObUR
# WBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6
# nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxB
# YKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5S
# UUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+x
# q4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIB
# NjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwP
# TzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMC
# AYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0Nc
# Vec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnov
# Lbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65Zy
# oUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFW
# juyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPF
# mCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9z
# twGpn1eqXijiuZQwggWQMIIDeKADAgECAhAFmxtXno4hMuI5B72nd3VcMA0GCSqG
# SIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
# dXN0ZWQgUm9vdCBHNDAeFw0xMzA4MDExMjAwMDBaFw0zODAxMTUxMjAwMDBaMGIx
# CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3
# dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBH
# NDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL/mkHNo3rvkXUo8MCIw
# aTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3EMB/zG6Q4FutWxpdtHauyefLK
# EdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKyunWZanMylNEQRBAu34LzB4Tm
# dDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsFxl7sWxq868nPzaw0QF+xembu
# d8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU15zHL2pNe3I6PgNq2kZhAkHnD
# eMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJBMtfbBHMqbpEBfCFM1LyuGwN1
# XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObURWBf3JFxGj2T3wWmIdph2PVld
# QnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6nj3cAORFJYm2mkQZK37AlLTS
# YW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxBYKqxYxhElRp2Yn72gLD76GSm
# M9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5SUUd0viastkF13nqsX40/ybzT
# QRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+xq4aLT8LWRV+dIPyhHsXAj6Kx
# fgommfXkaS+YHS312amyHeUbAgMBAAGjQjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYD
# VR0PAQH/BAQDAgGGMB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwPTzANBgkq
# hkiG9w0BAQwFAAOCAgEAu2HZfalsvhfEkRvDoaIAjeNkaA9Wz3eucPn9mkqZucl4
# XAwMX+TmFClWCzZJXURj4K2clhhmGyMNPXnpbWvWVPjSPMFDQK4dUPVS/JA7u5iZ
# aWvHwaeoaKQn3J35J64whbn2Z006Po9ZOSJTROvIXQPK7VB6fWIhCoDIc2bRoAVg
# X+iltKevqPdtNZx8WorWojiZ83iL9E3SIAveBO6Mm0eBcg3AFDLvMFkuruBx8lbk
# apdvklBtlo1oepqyNhR6BvIkuQkRUNcIsbiJeoQjYUIp5aPNoiBB19GcZNnqJqGL
# FNdMGbJQQXE9P01wI4YMStyB0swylIQNCAmXHE/A7msgdDDS4Dk0EIUhFQEI6FUy
# 3nFJ2SgXUE3mvk3RdazQyvtBuEOlqtPDBURPLDab4vriRbgjU2wGb2dVf0a1TD9u
# KFp5JtKkqGKX0h7i7UqLvBv9R0oN32dmfrJbQdA75PQ79ARj6e/CVABRoIoqyc54
# zNXqhwQYs86vSYiv85KZtrPmYQ/ShQDnUBrkG5WdGaG5nLGbsQAe79APT0JsyQq8
# 7kP6OnGlyE0mpTX9iV28hWIdMtKgK1TtmlfB2/oQzxm3i0objwG2J5VT6LaJbVu8
# aNQj6ItRolb58KaAoNYes7wPD1N1KarqE3fk3oyBIa0HEEcRrYc9B9F1vM/zZn4w
# ggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqGSIb3DQEBCwUAMGIx
# CzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3
# dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBH
# NDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMxCzAJBgNVBAYTAlVT
# MRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1
# c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwggIiMA0GCSqG
# SIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXHJQPE8pE3qZdRodbS
# g9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMfUBMLJnOWbfhXqAJ9
# /UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w1lbU5ygt69OxtXXn
# HwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRktFLydkf3YYMZ3V+0
# VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYbqMFkdECnwHLFuk4f
# sbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yemj052FVUmcJgmf6AaRyBD40Nj
# gHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP65x9abJTyUpURK1h0
# QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzKQtwYSH8UNM/STKvv
# mz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo80VgvCONWPfcYd6T
# /jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjBJgj5FBASA31fI7tk
# 42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXcheMBK9Rp6103a50g5r
# mQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4E
# FgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5n
# P+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMIMHcG
# CCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQu
# Y29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGln
# aUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8v
# Y3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAgBgNV
# HSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcNAQELBQADggIB
# AH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd4ksp+3CKDaopafxp
# wc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiCqBa9qVbPFXONASIl
# zpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl/Yy8ZCaHbJK9nXzQ
# cAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeCRK6ZJxurJB4mwbfe
# Kuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYTgAnEtp/Nh4cku0+j
# Sbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/a6fxZsNBzU+2QJsh
# IUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37xJV77QpfMzmHQXh6
# OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmLNriT1ObyF5lZynDw
# N7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0YgkPCr2B2RP+v6TR
# 81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJRyvmfxqkhQ/8mJb2
# VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIGsDCCBJigAwIBAgIQ
# CK1AsmDSnEyfXs2pvZOu2TANBgkqhkiG9w0BAQwFADBiMQswCQYDVQQGEwJVUzEV
# MBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29t
# MSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjEwNDI5MDAw
# MDAwWhcNMzYwNDI4MjM1OTU5WjBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGln
# aUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgQ29kZSBT
# aWduaW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEgQ0ExMIICIjANBgkqhkiG9w0BAQEF
# AAOCAg8AMIICCgKCAgEA1bQvQtAorXi3XdU5WRuxiEL1M4zrPYGXcMW7xIUmMJ+k
# jmjYXPXrNCQH4UtP03hD9BfXHtr50tVnGlJPDqFX/IiZwZHMgQM+TXAkZLON4gh9
# NH1MgFcSa0OamfLFOx/y78tHWhOmTLMBICXzENOLsvsI8IrgnQnAZaf6mIBJNYc9
# URnokCF4RS6hnyzhGMIazMXuk0lwQjKP+8bqHPNlaJGiTUyCEUhSaN4QvRRXXegY
# E2XFf7JPhSxIpFaENdb5LpyqABXRN/4aBpTCfMjqGzLmysL0p6MDDnSlrzm2q2AS
# 4+jWufcx4dyt5Big2MEjR0ezoQ9uo6ttmAaDG7dqZy3SvUQakhCBj7A7CdfHmzJa
# wv9qYFSLScGT7eG0XOBv6yb5jNWy+TgQ5urOkfW+0/tvk2E0XLyTRSiDNipmKF+w
# c86LJiUGsoPUXPYVGUztYuBeM/Lo6OwKp7ADK5GyNnm+960IHnWmZcy740hQ83eR
# Gv7bUKJGyGFYmPV8AhY8gyitOYbs1LcNU9D4R+Z1MI3sMJN2FKZbS110YU0/EpF2
# 3r9Yy3IQKUHw1cVtJnZoEUETWJrcJisB9IlNWdt4z4FKPkBHX8mBUHOFECMhWWCK
# ZFTBzCEa6DgZfGYczXg4RTCZT/9jT0y7qg0IU0F8WD1Hs/q27IwyCQLMbDwMVhEC
# AwEAAaOCAVkwggFVMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFGg34Ou2
# O/hfEYb7/mF7CIhl9E5CMB8GA1UdIwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9P
# MA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDAzB3BggrBgEFBQcB
# AQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggr
# BgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcmwwHAYDVR0gBBUwEzAH
# BgVngQwBAzAIBgZngQwBBAEwDQYJKoZIhvcNAQEMBQADggIBADojRD2NCHbuj7w6
# mdNW4AIapfhINPMstuZ0ZveUcrEAyq9sMCcTEp6QRJ9L/Z6jfCbVN7w6XUhtldU/
# SfQnuxaBRVD9nL22heB2fjdxyyL3WqqQz/WTauPrINHVUHmImoqKwba9oUgYftzY
# gBoRGRjNYZmBVvbJ43bnxOQbX0P4PpT/djk9ntSZz0rdKOtfJqGVWEjVGv7XJz/9
# kNF2ht0csGBc8w2o7uCJob054ThO2m67Np375SFTWsPK6Wrxoj7bQ7gzyE84FJKZ
# 9d3OVG3ZXQIUH0AzfAPilbLCIXVzUstG2MQ0HKKlS43Nb3Y3LIU/Gs4m6Ri+kAew
# Q3+ViCCCcPDMyu/9KTVcH4k4Vfc3iosJocsL6TEa/y4ZXDlx4b6cpwoG1iZnt5Lm
# Tl/eeqxJzy6kdJKt2zyknIYf48FWGysj/4+16oh7cGvmoLr9Oj9FpsToFpFSi0HA
# SIRLlk2rREDjjfAVKM7t8RhWByovEMQMCGQ8M4+uKIw8y4+ICw2/O/TOHnuO77Xr
# y7fwdxPm5yg/rBKupS8ibEH5glwVZsxsDsrFhsP2JjMMB0ug0wcCampAMEhLNKhR
# ILutG4UI4lkNbcoFUCvqShyepf2gpx8GdOfy1lKQ/a+FSCH5Vzu0nAPthkX0tGFu
# v2jiJmCG6sivqf6UHedjGzqGVnhOMIIGvDCCBKSgAwIBAgIQC65mvFq6f5WHxvnp
# BOMzBDANBgkqhkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGln
# aUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5
# NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4XDTI0MDkyNjAwMDAwMFoXDTM1MTEy
# NTIzNTk1OVowQjELMAkGA1UEBhMCVVMxETAPBgNVBAoTCERpZ2lDZXJ0MSAwHgYD
# VQQDExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyNDCCAiIwDQYJKoZIhvcNAQEBBQAD
# ggIPADCCAgoCggIBAL5qc5/2lSGrljC6W23mWaO16P2RHxjEiDtqmeOlwf0KMCBD
# Er4IxHRGd7+L660x5XltSVhhK64zi9CeC9B6lUdXM0s71EOcRe8+CEJp+3R2O8oo
# 76EO7o5tLuslxdr9Qq82aKcpA9O//X6QE+AcaU/byaCagLD/GLoUb35SfWHh43rO
# H3bpLEx7pZ7avVnpUVmPvkxT8c2a2yC0WMp8hMu60tZR0ChaV76Nhnj37DEYTX9R
# eNZ8hIOYe4jl7/r419CvEYVIrH6sN00yx49boUuumF9i2T8UuKGn9966fR5X6kgX
# j3o5WHhHVO+NBikDO0mlUh902wS/Eeh8F/UFaRp1z5SnROHwSJ+QQRZ1fisD8UTV
# DSupWJNstVkiqLq+ISTdEjJKGjVfIcsgA4l9cbk8Smlzddh4EfvFrpVNnes4c16J
# idj5XiPVdsn5n10jxmGpxoMc6iPkoaDhi6JjHd5ibfdp5uzIXp4P0wXkgNs+CO/C
# acBqU0R4k+8h6gYldp4FCMgrXdKWfM4N0u25OEAuEa3JyidxW48jwBqIJqImd93N
# Rxvd1aepSeNeREXAu2xUDEW8aqzFQDYmr9ZONuc2MhTMizchNULpUEoA6Vva7b1X
# CB+1rxvbKmLqfY/M/SdV6mwWTyeVy5Z/JkvMFpnQy5wR14GJcv6dQ4aEKOX5AgMB
# AAGjggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUB
# Af8EDDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1s
# BwEwHwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFJ9X
# LAN3DigVkGalY17uT5IfdqBbMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1l
# U3RhbXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhho
# dHRwOi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNl
# cnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZU
# aW1lU3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAD2tHh92mVvjOIQS
# R9lDkfYR25tOCB3RKE/P09x7gUsmXqt40ouRl3lj+8QioVYq3igpwrPvBmZdrlWB
# b0HvqT00nFSXgmUrDKNSQqGTdpjHsPy+LaalTW0qVjvUBhcHzBMutB6HzeledbDC
# zFzUy34VarPnvIWrqVogK0qM8gJhh/+qDEAIdO/KkYesLyTVOoJ4eTq7gj9UFAL1
# UruJKlTnCVaM2UeUUW/8z3fvjxhN6hdT98Vr2FYlCS7Mbb4Hv5swO+aAXxWUm3Wp
# ByXtgVQxiBlTVYzqfLDbe9PpBKDBfk+rabTFDZXoUke7zPgtd7/fvWTlCs30VAGE
# sshJmLbJ6ZbQ/xll/HjO9JbNVekBv2Tgem+mLptR7yIrpaidRJXrI+UzB6vAlk/8
# a1u7cIqV0yef4uaZFORNekUgQHTqddmsPCEIYQP7xGxZBIhdmm4bhYsVA6G2WgNF
# YagLDBzpmk9104WQzYuVNsxyoVLObhx3RugaEGru+SojW4dHPoWrUhftNpFC5H7Q
# EY7MhKRyrBe7ucykW7eaCuWBsBb4HOKRFVDcrZgdwaSIqMDiCLg4D+TPVgKx2EgE
# deoHNHT9l3ZDBD+XgbF+23/zBjeCtxz+dL/9NWR6P2eZRi7zcEO1xwcdcqJsyz/J
# ceENc2Sg8h3KeFUCS7tpFk7CrDqkMIIHXzCCBUegAwIBAgIQB8JSdCgUotar/iTq
# F+XdLjANBgkqhkiG9w0BAQsFADBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGln
# aUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgQ29kZSBT
# aWduaW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEgQ0ExMB4XDTIzMDQxNjAwMDAwMFoX
# DTI2MDcwNjIzNTk1OVowZzELMAkGA1UEBhMCUEwxEjAQBgNVBAcMCU1pa2/FgsOz
# dzEhMB8GA1UECgwYUHJ6ZW15c8WCYXcgS8WCeXMgRVZPVEVDMSEwHwYDVQQDDBhQ
# cnplbXlzxYJhdyBLxYJ5cyBFVk9URUMwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQCUmgeXMQtIaKaSkKvbAt8GFZJ1ywOH8SwxlTus4McyrWmVOrRBVRQA
# 8ApF9FaeobwmkZxvkxQTFLHKm+8knwomEUslca8CqSOI0YwELv5EwTVEh0C/Daeh
# vxo6tkmNPF9/SP1KC3c0l1vO+M7vdNVGKQIQrhxq7EG0iezBZOAiukNdGVXRYOLn
# 47V3qL5PwG/ou2alJ/vifIDad81qFb+QkUh02Jo24SMjWdKDytdrMXi0235CN4Rr
# W+8gjfRJ+fKKjgMImbuceCsi9Iv1a66bUc9anAemObT4mF5U/yQBgAuAo3+jVB8w
# iUd87kUQO0zJCF8vq2YrVOz8OJmMX8ggIsEEUZ3CZKD0hVc3dm7cWSAw8/FNzGNP
# lAaIxzXX9qeD0EgaCLRkItA3t3eQW+IAXyS/9ZnnpFUoDvQGbK+Q4/bP0ib98XLf
# QpxVGRu0cCV0Ng77DIkRF+IyR1PcwVAq+OzVU3vKeo25v/rntiXCmCxiW4oHYO28
# eSQ/eIAcnii+3uKDNZrI15P7VxDrkUIc6FtiSvOhwc3AzY+vEfivUkFKRqwvSSr4
# fCrrkk7z2Qe72Zwlw2EDRVHyy0fUVGO9QMuh6E3RwnJL96ip0alcmhKABGoIqSW0
# 5nXdCUbkXmhPCTT5naQDuZ1UkAXbZPShKjbPwzdXP2b8I9nQ89VSgQIDAQABo4IC
# AzCCAf8wHwYDVR0jBBgwFoAUaDfg67Y7+F8Rhvv+YXsIiGX0TkIwHQYDVR0OBBYE
# FHrxaiVZuDJxxEk15bLoMuFI5233MA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAK
# BggrBgEFBQcDAzCBtQYDVR0fBIGtMIGqMFOgUaBPhk1odHRwOi8vY3JsMy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JTQTQwOTZTSEEz
# ODQyMDIxQ0ExLmNybDBToFGgT4ZNaHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0VHJ1c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5j
# cmwwPgYDVR0gBDcwNTAzBgZngQwBBAEwKTAnBggrBgEFBQcCARYbaHR0cDovL3d3
# dy5kaWdpY2VydC5jb20vQ1BTMIGUBggrBgEFBQcBAQSBhzCBhDAkBggrBgEFBQcw
# AYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMFwGCCsGAQUFBzAChlBodHRwOi8v
# Y2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmlu
# Z1JTQTQwOTZTSEEzODQyMDIxQ0ExLmNydDAJBgNVHRMEAjAAMA0GCSqGSIb3DQEB
# CwUAA4ICAQC3EeHXUPhpe31K2DL43Hfh6qkvBHyR1RlD9lVIklcRCR50ZHzoWs6E
# BlTFyohvkpclVCuRdQW33tS6vtKPOucpDDv4wsA+6zkJYI8fHouW6Tqa1W47YSrc
# 5AOShIcJ9+NpNbKNGih3doSlcio2mUKCX5I/ZrzJBkQpJ0kYha/pUST2CbE3JroJ
# f2vQWGUiI+J3LdiPNHmhO1l+zaQkSxv0cVDETMfQGZKKRVESZ6Fg61b0djvQSx51
# 0MdbxtKMjvS3ZtAytqnQHk1ipP+Rg+M5lFHrSkUlnpGa+f3nuQhxDb7N9E8hUVev
# xALTrFifg8zhslVRH5/Df/CxlMKXC7op30/AyQsOQxHW1uNx3tG1DMgizpwBasrx
# h6wa7iaA+Lp07q1I92eLhrYbtw3xC2vNIGdMdN7nd76yMIjdYnAn7r38wwtaJ3KY
# D0QTl77EB8u/5cCs3ShZdDdyg4K7NoJl8iEHrbqtooAHOMLiJpiL2i9Yn8kQMB6/
# Q6RMO3IUPLuycB9o6DNiwQHf6Jt5oW7P09k5NxxBEmksxwNbmZvNQ65Zn3exUAKq
# G+x31Egz5IZ4U/jPzRalElEIpS0rgrVg8R8pEOhd95mEzp5WERKFyXhe6nB6bSYH
# v8clLAV0iMku308rpfjMiQkqS3LLzfUJ5OHqtKKQNMLxz9z185UCszGCBlMwggZP
# AgEBMH0waTELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMUEw
# PwYDVQQDEzhEaWdpQ2VydCBUcnVzdGVkIEc0IENvZGUgU2lnbmluZyBSU0E0MDk2
# IFNIQTM4NCAyMDIxIENBMQIQB8JSdCgUotar/iTqF+XdLjANBglghkgBZQMEAgEF
# AKCBhDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3
# DQEJBDEiBCCDECcr1AqeUVAYJ+yaxoRuNthpQYywvDui7JotEnNvkjANBgkqhkiG
# 9w0BAQEFAASCAgB0ovekcouIKRu1XEanf1Hm8VRB219G/O7VVl/ueN2ZnBtJiV5I
# ARaWfeSSAw2hGE5KSRiydlyIEhNkeRbAe9V4DuBombYxP8VfK3LFCVnoFU1/NFwm
# Z4wkRyVKcDMj2IkkHGOfZK6M7XJPqHItkKonemFQWmxvDg15OZqGAJ9d73UEjDZx
# LOpsiapxBk2cQARgm9lBiTd+38bN0z/TM18axwGjow8Mx4FqTGj2/fc6OeMat9lW
# LiJAddbtSTjS5Nqh2wNgwYOROvtduUA6Va4rXx4AuAg3I21ctVE0U0Z44uHcxwdZ
# pKZK8AlxNVrFtsFfLHLE5v0qhpv/MdgXXsjgVU5f1PB4CObzobqrjzHbE/CtIwsK
# LAvvglkLEV+woNSy9qP1OaYhyBhGF5bU6qCf7mZ/c4GkI47VawTbSiW0xdZDXxtL
# oqAHNTw91Lg+CvIUHHHtPade4YVbxEdj7O6XXS8ycvZhvL/+LmD59WOFMZofy+kT
# y5ZqqPCNRaJnoQuaCoxNWShsfZNJpYO/7Azh0mPmqP9iPpHk8keOZtWBq+xxCLE9
# 6SS4Sn2sXaIUGgtCjPL91xVvk3vrKGCNnIfmsVUpKza1a0W6tO/ecnv/P4JiQa2G
# 2BrsmyqvymIX7o0SyruHurKyT0IbKZQTrChhP0OJgdDz2g1Jr/auiRf2fqGCAyAw
# ggMcBgkqhkiG9w0BCQYxggMNMIIDCQIBATB3MGMxCzAJBgNVBAYTAlVTMRcwFQYD
# VQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBH
# NCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAuuZrxaun+Vh8b56QTj
# MwQwDQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwG
# CSqGSIb3DQEJBTEPFw0yNDExMjYxMDA0MTBaMC8GCSqGSIb3DQEJBDEiBCBIvenG
# mTH/0w2IaMPg7UTyUR6aty7a5rVPdbssaYSSTjANBgkqhkiG9w0BAQEFAASCAgBR
# JfGK15FvzuZTrGeNS4vtDIvhQZqPl8A4bpHBl+0xg9cnGIGRm+GkqeRUjZH+9Hlp
# VY0lV9ARAbDd0YhU1y7luYRRKH2poRD/QwqP4j3IVIhFpNHpRTyhFYlYejeTVvIm
# mImltTERGfnlaFoSG0aXkfhHUAO9cqi3mq4CcvjwSZWTEM+Ea+nVSvZXaKHxT7Su
# WlYX5WKJ7vUI+JZwFQzab5Dy6RFl6nf/XeVRRc7f1rTKuOhdtvEPo4oZIEA2aoME
# 8wwGWWl1MvIMPuwO1yeUxG+euPSu9si9Ramn+Nf2x8Fi/Fn6Rmr0pb6eMJ+TzAFU
# Z/heK9k2MMbnoEs8l9SNnqm6lnhmDlGWRYUY2VDwvcGSdeVJg31hr3AsZOopoGm5
# RH+Q4z4ia4N5WaNCCmSdL7thhCtna55EtIgsocO/+2x1dos7LbvZXEYRYTFh4eJl
# HYxCvtHg1IpH/jVlucjtlGxMIAk0140ddUR34hjoT5mBBdIOVFcCdlGbhpBI33u5
# ZMZKPwj8pcET65kukfnyhB8ATRjyCGeUuDdA2JuxFY/bvtFWNiYYIXyfVbqERYdn
# ur/JrDNMSIOuGzpY9iun0NMhx6ndzqThio7uXumyejAEHhTrnikOOKPdXneNzl0A
# kx7nGXHQILcuvCfiMsrXRL9UT2JR1cdTyTtL5piSUQ==
# SIG # End signature block
