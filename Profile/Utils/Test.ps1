Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start

function Resolve-Object
{
    param(
        [Parameter(ValueFromPipeline = $true)]
        [object]$InputObject,

        [switch]$Methods,
        [switch]$Properties,
        [switch]$Examples
    )

    process {
        $members = $InputObject | Get-Member

        if ($Methods)
        {
            Write-Host "`n=== МЕТОДЫ ===`n" -ForegroundColor Cyan
            $members | Where-Object { $_.MemberType -eq "Method" } | Format-Table Name, Definition -AutoSize
        }

        if ($Properties)
        {
            Write-Host "`n=== СВОЙСТВА ===`n" -ForegroundColor Green
            $members | Where-Object { $_.MemberType -eq "Property" } | Format-Table Name, Definition -AutoSize
        }

        if ($Examples -and $Methods)
        {
            Write-Host "`n=== ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ ===`n" -ForegroundColor Yellow
            $methodsList = $members | Where-Object { $_.MemberType -eq "Method" }

            foreach ($method in $methodsList)
            {
                $example = switch ($method.Name)
                {
                    "CopyTo" {
                        '$file.CopyTo("C:\new\path.txt")'
                    }
                    "Delete" {
                        '$file.Delete()'
                    }
                    "ToString" {
                        '$date = Get-Date; $date.ToString("yyyy-MM-dd")'
                    }
                    default {
                        "`$obj.$( $method.Name )()"
                    }
                }
                Write-Host ("• " + $example) -ForegroundColor Magenta
            }
        }
    }
}

function Invoke-ObjectExplorer
{
    <#
    .SYNOPSIS
        Интерактивный исследователь объектов PowerShell с генерацией кода.
    .EXAMPLE
        Get-Process | Invoke-ObjectExplorer -Depth 2
        [System.IO.FileInfo]::new("C:\test.txt") | Invoke-ObjectExplorer -Interactive
    #>
    param(
        [Parameter(ValueFromPipeline = $true)]
        [object]$InputObject,

        [ValidateRange(1, 5)]
        [int]$Depth = 1,

        [switch]$Interactive,
        [switch]$GenerateCode,
        [string]$Filter
    )

    begin {
        $script:objectStack = @()
        $script:currentDepth = 0
    }

    process {
        $script:objectStack += $InputObject
        $script:currentDepth = 0

        while ($script:objectStack.Count -gt 0 -and $script:currentDepth -lt $Depth)
        {
            $currentObj = $script:objectStack[-1]
            $script:objectStack = $script:objectStack[0..($script:objectStack.Count - 2)]
            $script:currentDepth++

            Explore-SingleObject -Object $currentObj
        }
    }

    end {
        if ($Interactive -and $script:selectedMember)
        {
            Invoke-SelectedMember -Object $InputObject -Member $script:selectedMember
        }
    }
}

function Resolve-SingleObject
{
    param($Object)

    $members = $Object | Get-Member | Where-Object {
        -not $Filter -or $_.Name -like "*$Filter*"
    } | Sort-Object MemberType, Name

    # Интерактивное меню
    if ($Interactive)
    {
        $menu = @()
        $members | ForEach-Object {
            $menu += "[$( $_.MemberType[0] )] $( $_.Name ) - $( $_.Definition )"
        }

        $choice = $menu | Out-GridView -Title "Выберите элемент для исследования (Глубина: $script:currentDepth)" -PassThru
        if ($choice)
        {
            $script:selectedMember = $members[$menu.IndexOf($choice)]
            $script:objectStack += $Object.$( $script:selectedMember.Name )
        }
    }
    else
    {
        # Детальный вывод
        Write-Host "`n=== ОБЪЕКТ [$( $Object.GetType().FullName )] ===" -ForegroundColor Blue
        $members | Group-Object MemberType | ForEach-Object {
            Write-Host "`n=== $($_.Name.ToUpper() ) ===" -ForegroundColor Cyan
            $_.Group | Format-Table Name, Definition -AutoSize -Wrap
        }

        if ($GenerateCode)
        {
            Write-Host "`n=== ГЕНЕРАЦИЯ КОДА ===" -ForegroundColor Yellow
            Generate-UsageExamples -Object $Object -Members $members
        }
    }
}

function New-UsageExamples
{
    param($Object, $Members)

    $Members | Where-Object { $_.MemberType -eq "Method" } | ForEach-Object {
        $example = switch -Regex ($_.Name)
        {
            "^Get" {
                "$( $_.Name )()  # Возвращает данные"
            }
            "^Set" {
                "$( $_.Name )('value')  # Устанавливает значение"
            }
            default {
                "$( $_.Name )()  # Действие"
            }
        }
        Write-Host ("• " + $example) -ForegroundColor Magenta
    }
}

function Invoke-SelectedMember
{
    param($Object, $Member)

    try
    {
        $result = if ($Member.MemberType -eq "Method")
        {
            $Object.$( $Member.Name ).Invoke()
        }
        else
        {
            $Object.$( $Member.Name )
        }

        Write-Host "`n=== РЕЗУЛЬТАТ ===" -ForegroundColor Green
        $result | Format-List *
    }
    catch
    {
        Write-Warning "Ошибка выполнения: $_"
    }
}

Trace-ImportProcess  ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))