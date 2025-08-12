Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

$global:richFolder = "${global:profilePath}/Rich/"
Import-PythonModule network_tools -AsGlobal

function pr
{
    param(
        [string] $script
    )
    $script = [System.IO.Path]::GetFileNameWithoutExtension($script)
    python "${global:richFolder}${script}.py" @args
}


function pres
{
    pr  emoji_system @args
}

function preh
{
    pr  emoji_handler @args
}


function prem
{
    param(
        [string]$code1,
        [string]$code2,
        [switch] $grid
    )
    if ($grid)
    {
        pr emoji_handler --qg "${code1}-${code2}"
    }
    elseif ($code2)
    {
        pr emoji_handler --qs "${code1}-${code2}"
    }
    else
    {
        pr emoji_handler --qe "${code1}"
    }
}


function prc
{
    pr  rich_cli @args
}

function prcl
{
    pr  rich_cli log @args
}


$global:data = @{
    System = "Windows 11"
    Version = "24H2"
    CPU = "Intel i7-9700K"
    RAM = "16GB DDR5"
}

Set-Alias -Name pp -Value python -Force
Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))