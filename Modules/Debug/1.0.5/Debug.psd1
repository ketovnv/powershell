@{
    RootModule = 'Debug.psm1'
    ModuleVersion = '1.0.5'
    GUID = '11d53ac8-b590-4555-838b-71f7278f1e0e'
    Author = 'n8tb1t'
    CompanyName = 'n8tb1t'
    Copyright = '(c) 2019 n8tb1t, licensed under MIT License.'
    Description = 'A collection of debugging tools for helping to develop modern PowerShell applications. For example: objects color highlighting, various code metrics and performance benchmarks.'
    PowerShellVersion = '5.0'
    HelpInfoURI = 'https://github.com/n8tb1t/Debug/blob/master/README.md'

    RequiredModules = @('Parser', 'ColoredText')

    FunctionsToExport = 'Debug-Object'

    AliasesToExport = 'debug'

    PrivateData = @{
        PSData = @{
            Tags = @(
                'table',
                'list',
                'tree',
                'debug',
                'log',
                'color',
                'colored',
                'object',
                'print',
                'highlight',
                'dump',
                'timer',
                'measure'
            )
            LicenseUri = 'https://github.com/n8tb1t/Debug/blob/master/LICENSE'
            ProjectUri = 'https://github.com/n8tb1t/Debug'
            IconUri = 'https://raw.githubusercontent.com/n8tb1t/Debug/master/Docs/Logo/debug.png'
            ReleaseNotes = '
Check out the project site for more information:
https://github.com/n8tb1t/Debug'
        }
        DevTools = @{
            Dependencies = (
                @{
                    deploy = $false
                    name = 'Parser'
                },
                @{
                    deploy = $false
                    name = 'ColoredText'
                }
            )
        }
    }
}
