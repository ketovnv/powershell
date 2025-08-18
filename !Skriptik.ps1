HelpUri='https://go.microsoft.com/fwlink/?LinkID=2096486', RemotingCapability='None')]
param(
[switch]
${Transcript


































},
[Parameter(ValueFromPipeline = $true)]
[psobject]
${InputObject}
)
begin
{
try {
## Access the REAL Foreach-Object command, so that command
## wrappers do not interfere with this script
$foreachObject = $executionContext.InvokeCommand.GetCmdlet(
"Microsoft.PowerShell.Core\Foreach-Object")
$wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(
'Out-Default',
[System.Management.Automation.CommandTypes]::Cmdlet)
## TargetParameters represents the hashtable of parameters that
## we will pass along to the wrapped command
$targetParameters = @{ }
$PSBoundParameters.GetEnumerator() |
& $foreachObject {
if ($command.Parameters.ContainsKey($.Key))
{
$targetParameters.Add($.Key, $_.Value)
}
}
## finalPipeline represents the pipeline we wil ultimately run
$newPipeline = {
& $wrappedCmd @targetParameters
}
$finalPipeline = $newPipeline.ToString()
$steppablePipeline = [ScriptBlock]::Create(
$finalPipeline).GetSteppablePipeline()
$steppablePipeline.Begin($PSCmdlet)
} catch {
throw
}
}
process
{
try {
if (($ -is [System.IO.DirectoryInfo]) -or ($ -is [System.IO.FileInfo]))
{
FileInfo $
$ = $null
}
elseif($ -is [System.ServiceProcess.ServiceController])
{
ServiceController $
$ = $null
}
elseif($ -is [Microsoft.Powershell.Commands.MatchInfo])
{
MatchInfo $
$ = $null
}
$steppablePipeline.Process($_)
} catch {
throw
}
}
end
{
try {
write-host ""
$script: showHeader =$true
$steppablePipeline.End()
} catch {
throw
}
}
dynamicparam
{
## Access the REAL Get-Command, Foreach-Object, and Where-Object
## commands, so that command wrappers do not interfere with this script
$getCommand = $executionContext.InvokeCommand.GetCmdlet(
"Microsoft.PowerShell.Core\Get-Command")
$foreachObject = $executionContext.InvokeCommand.GetCmdlet(
"Microsoft.PowerShell.Core\Foreach-Object")
$whereObject = $executionContext.InvokeCommand.GetCmdlet(
"Microsoft.PowerShell.Core\Where-Object")
## Find the parameters of the original command, and remove everything
## else from the bound parameter list so we hide parameters the wrapped
## command does not recognize.
$command = & $getCommand Out-Default -Type Cmdlet
$targetParameters = @{ }
$PSBoundParameters.GetEnumerator() |
& $foreachObject {
if ($command.Parameters.ContainsKey($.Key))
{
$targetParameters.Add($.Key, $.Value)
}
}
## Get the argumment list as it would be passed to the target command
$argList = @($targetParameters.GetEnumerator() |
Foreach-Object {
"-$($.Key)"; $.Value
})
## Get the dynamic parameters of the wrapped command, based on the
## arguments to this command
$command = $null
try
{
$command = & $getCommand Out-Default -Type Cmdlet `
-ArgumentList $argList
}
catch
{
}
$dynamicParams = @($command.Parameters.GetEnumerator() |
& $whereObject {
$.Value.IsDynamic
})
## For each of the dynamic parameters, add them to the dynamic
## parameters that we return.
if ($dynamicParams.Length -gt 0)
{
$paramDictionary =
New-Object Management.Automation.RuntimeDefinedParameterDictionary
foreach ($param in $dynamicParams)
{
$param = $param.Value
$arguments = $param.Name, $param.ParameterType, $param.Attributes
$newParameter =
New-Object Management.Automation.RuntimeDefinedParameter `
$arguments
$paramDictionary.Add($param.Name, $newParameter)
}
return $paramDictionary
}
}
<#
.ForwardHelpTargetName Out-Default
.ForwardHelpCategory Cmdlet