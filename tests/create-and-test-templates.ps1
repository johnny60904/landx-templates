#requires -Version 7.6.8
#requires -PSEdition Core

using namespace System
using namespace System.IO
using namespace System.Text
using namespace System.Management.Automation

$script:Root = [Path]::Join($PSScriptRoot, 'artifacts')
$script:LogRoot = [Path]::Join($PSScriptRoot, 'logs')

[Directory]::CreateDirectory($script:Root)
[Directory]::CreateDirectory($script:LogRoot)

cd $script:Root

$script:SectionDivider = "------------------------------------------------------"
$script:SubSectionDivider = "------------------------------------------------------"
$script:AssertionResult = [StringBuilder]::new()

function Invoke-ExpectedNativeExitCode {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Name,
        
        [Parameter(Mandatory, Position = 1)]
        [ValidateRange(0, 255)]
        [int] $ExpectedExitCode,
        
        [Parameter(Mandatory, Position = 2)]
        [ValidateNotNull()]
        [scriptblock] $Command
    )
    process {
        $previousNativePreference = $PSNativeCommandUseErrorActionPreference
        $previousErrorActionPreference = $ErrorActionPreference
        
        $actualExitCode = 0
        
        try {
            $PSNativeCommandUseErrorActionPreference = $false
            $ErrorActionPreference = [ActionPreference]::Continue
            
            & $Command
            
            $actualExitCode = $LASTEXITCODE
        } finally {
            $PSNativeCommandUseErrorActionPreference = $previousNativePreference
            $ErrorActionPreference = $previousErrorActionPreference
            
            $target = [Path]::Join($script:Root, $Name)
            if ([Directory]::Exists($target)) {
                [Directory]::Delete($target)
            }
        }
        
        if ($actualExitCode -ne $ExpectedExitCode) {
            throw [InvalidOperationException]::new(
                "Expected native exit code $ExpectedExitCode, but received $actualExitCode."
            )
        }
    }
}

function New-ResultText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Name,
        
        [Parameter(Mandatory, Position = 1)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Target,
        
        [Parameter()]
        [switch] $Failure
    )
    process {
        $prefix = $Name.Substring(
            0,
            $Name.IndexOf('.')
        )
        
        return $Failure.IsPresent ?
            "    - [$prefix] Failed: Assertion existence - ""$Target""" :
            "    - [$prefix] Passed: Assertion existence - ""$Target"""
    }
}

function Assert-BoilerplateFiles {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    begin {
        $boilerplateFiles = @(
            '.editorconfig',
            '.gitattributes',
            '.gitignore',
            'README.md'
        )
    }
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        
        foreach ($file in $boilerplateFiles) {
            $targetBoilerplateFile = [Path]::Join($resolvedPath, $file)
            $targetBoilerplateFileName = [Path]::GetFileName($targetBoilerplateFile)
            $existed = Test-Path -Path $targetBoilerplateFile
            if (-not $existed) {
                $resultText = New-ResultText -Name $name -Target $targetBoilerplateFileName -Failure
                Write-Host $resultText -ForegroundColor DarkYellow
                Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
                $null = $script:AssertionResult.AppendLine($resultText)
                $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
                $record = [ErrorRecord]::new(
                    [InvalidOperationException]::new(
                        "Missing required boilerplate file: ""$targetBoilerplateFileName""; Path: ""$targetBoilerplateFile""."
                    ),
                    'MissingBoilerplateFile',
                    [ErrorCategory]::InvalidOperation,
                    $resolvedPath
                )
                $PSCmdlet.ThrowTerminatingError($record)
            }
            $resultText = New-ResultText -Name $name -Target $targetBoilerplateFileName
            Write-Host $resultText -ForegroundColor DarkYellow
            $null = $script:AssertionResult.AppendLine($resultText)
        }
    }
}

function Assert-License {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path,
        
        [Parameter()]
        [ValidateSet('Generic', 'Gnu', 'GnuLesser', IgnoreCase = $false)]
        [string] $Type = 'Generic'
    )
    begin {
        $gnuLesserFiles = @(
            'COPYING'
            'COPYING.LESSER'
        )
    }
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        
        $existed = $false
                
        if ($Type -ceq 'Generic') {
            $licenseName = 'LICENSE'
            $targetLicenseFile = [Path]::Join($resolvedPath, $licenseName)
            $targetLicenseFileName = [Path]::GetFileName($targetLicenseFile)
            
            $existed = Test-Path -Path $targetLicenseFile
            
            if (-not $existed) {
                $resultText = New-ResultText -Name $name -Target $targetLicenseFileName -Failure
                Write-Host $resultText -ForegroundColor DarkYellow
                Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
                $null = $script:AssertionResult.AppendLine($resultText)
                $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
                $record = [ErrorRecord]::new(
                    [InvalidOperationException]::new(
                        "Missing required license file: ""$targetLicenseFileName""; Path: ""$targetLicenseFile""."
                    ),
                    'MissingLicenseFile',
                    [ErrorCategory]::InvalidOperation,
                    $resolvedPath
                )
                $PSCmdlet.ThrowTerminatingError($record)
            }
            $resultText = New-ResultText -Name $name -Target $targetLicenseFileName
            Write-Host $resultText -ForegroundColor DarkYellow
            $null = $script:AssertionResult.AppendLine($resultText)
        } elseif ($Type -ceq 'Gnu') {
            $licenseName = 'COPYING'
            $targetLicenseFile = [Path]::Join($resolvedPath, $licenseName)
            $targetLicenseFileName = [Path]::GetFileName($targetLicenseFile)
            
            $existed = Test-Path -Path $targetLicenseFile
            
            if (-not $existed) {
                $resultText = New-ResultText -Name $name -Target $targetLicenseFileName -Failure
                Write-Host $resultText -ForegroundColor DarkYellow
                Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
                $null = $script:AssertionResult.AppendLine($resultText)
                $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
                $record = [ErrorRecord]::new(
                    [InvalidOperationException]::new(
                        "Missing required license file: ""$targetLicenseFileName""; Path: ""$targetLicenseFile""."
                    ),
                    'MissingLicenseFile',
                    [ErrorCategory]::InvalidOperation,
                    $resolvedPath
                )
                $PSCmdlet.ThrowTerminatingError($record)
            }
            $resultText = New-ResultText -Name $name -Target $targetLicenseFileName
            Write-Host $resultText -ForegroundColor DarkYellow
            $null = $script:AssertionResult.AppendLine($resultText)
        } else { # 'GnuLesser'
            $licenses = @(
                'COPYING',
                'COPYING.LESSER'
            )
            
            foreach ($file in $licenses) {
                $targetLicenseFile = [Path]::Join($resolvedPath, $file)
                $targetLicenseFileName = [Path]::GetFileName($targetLicenseFile)
                
                $existed = Test-Path -Path $targetLicenseFile
                
                if (-not $existed) {
                    $resultText = New-ResultText -Name $name -Target $targetLicenseFileName -Failure
                    Write-Host $resultText -ForegroundColor DarkYellow
                    Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
                    $null = $script:AssertionResult.AppendLine($resultText)
                    $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
                    $record = [ErrorRecord]::new(
                        [InvalidOperationException]::new(
                            "Missing required license file: ""$targetLicenseFileName""; Path: ""$targetLicenseFile""."
                        ),
                        'MissingLicenseFile',
                        [ErrorCategory]::InvalidOperation,
                        $resolvedPath
                    )
                    $PSCmdlet.ThrowTerminatingError($record)
                }
                $resultText = New-ResultText -Name $name -Target $targetLicenseFileName
                Write-Host $resultText -ForegroundColor DarkYellow
                $null = $script:AssertionResult.AppendLine($resultText)
            }
        }
    }
}

function Assert-Solution {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path,
        
        [Parameter()]
        [switch] $Outdated
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        
        $existed = $true
        
        $targetSolutionFile = ($Outdated.IsPresent) ?
            [Path]::Join($resolvedPath, "$name.sln") :
            [Path]::Join($resolvedPath, "$name.slnx")
        
        $targetSolutionFileName = [Path]::GetFileName($targetSolutionFile)
        
        $existed = Test-Path -Path $targetSolutionFile
        
        if (-not $existed) {
            $resultText = New-ResultText -Name $name -Target $targetSolutionFileName -Failure
            Write-Host $resultText -ForegroundColor DarkYellow
            Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
            $null = $script:AssertionResult.AppendLine($resultText)
            $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
            $record = [ErrorRecord]::new(
                [InvalidOperationException]::new(
                    "Missing required solution file: ""$targetSolutionFileName""; Path: ""$targetSolutionFile""."
                ),
                'MissingSolutionFile',
                [ErrorCategory]::InvalidOperation,
                $resolvedPath
            )
            $PSCmdlet.ThrowTerminatingError($record)
        }
        $resultText = New-ResultText -Name $name -Target $targetSolutionFileName
        Write-Host $resultText -ForegroundColor DarkYellow
        $null = $script:AssertionResult.AppendLine($resultText)
    }
}

function Assert-BuildConfigs {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    begin {
        $buildConfigFiles = @(
            'Directory.Build.props',
            'Directory.Build.targets',
            'Directory.Packages.props'
        )
    }
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        
        foreach ($configFile in $buildConfigFiles) {
            $targetConfigFile = [Path]::Join($resolvedPath, $configFile)
            $targetConfigFileName = [Path]::GetFileName($targetConfigFile)
            $existed = Test-Path -Path $targetConfigFile
            if (-not $existed) {
                $resultText = New-ResultText -Name $name -Target $targetConfigFileName -Failure
                Write-Host $resultText -ForegroundColor DarkYellow
                Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
                $null = $script:AssertionResult.AppendLine($resultText)
                $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
                $record = [ErrorRecord]::new(
                    [InvalidOperationException]::new(
                        "Missing required MS build configuration file: ""$targetConfigFileName""; Path: ""$targetConfigFile""."
                    ),
                    'MissingBuildConfigFile',
                    [ErrorCategory]::InvalidOperation,
                    $resolvedPath
                )
                $PSCmdlet.ThrowTerminatingError($record)
            }
            $resultText = New-ResultText -Name $name -Target $targetConfigFileName
            Write-Host $resultText -ForegroundColor DarkYellow
            $null = $script:AssertionResult.AppendLine($resultText)
        }
    }
}

function Assert-GlobalJson {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        
        $targetJsonFile = [Path]::Join($resolvedPath, 'global.json')
        $targetJsonFileName = [Path]::GetFileName($targetJsonFile)
        
        $existed = Test-Path -Path $targetJsonFile
        
        if (-not $existed) {
            $resultText = New-ResultText -Name $name -Target $targetJsonFileName -Failure
            Write-Host $resultText -ForegroundColor DarkYellow
            Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
            $null = $script:AssertionResult.AppendLine($resultText)
            $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
            $record = [ErrorRecord]::new(
                [InvalidOperationException]::new(
                    "Missing required global json file: ""$targetJsonFileName""; Path: ""$targetJsonFile""."
                ),
                'MissingGlobalJsonFile',
                [ErrorCategory]::InvalidOperation,
                $resolvedPath
            )
            $PSCmdlet.ThrowTerminatingError($record)
        }
        $resultText = New-ResultText -Name $name -Target $targetJsonFileName
        Write-Host $resultText -ForegroundColor DarkYellow
        $null = $script:AssertionResult.AppendLine($resultText)
    }
}

function Assert-Docs {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        
        $targetDocFile = [Path]::Join($resolvedPath, 'docs', 'architecture-decision-records.md')
        $targetDocFileName = [Path]::GetFileName($targetDocFile)
        
        $existed = Test-Path -Path $targetDocFile
        
        if (-not $existed) {
            $resultText = New-ResultText -Name $name -Target $targetDocFileName -Failure
            Write-Host $resultText -ForegroundColor DarkYellow
            Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
            $null = $script:AssertionResult.AppendLine($resultText)
            $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
            $record = [ErrorRecord]::new(
                [InvalidOperationException]::new(
                    "Missing required docs file: ""$targetDocFileName""; Path: ""$targetDocFile""."
                ),
                'MissingDocsFile',
                [ErrorCategory]::InvalidOperation,
                $resolvedPath
            )
            $PSCmdlet.ThrowTerminatingError($record)
        }
        $resultText = New-ResultText -Name $name -Target $targetDocFileName
        Write-Host $resultText -ForegroundColor DarkYellow
        $null = $script:AssertionResult.AppendLine($resultText)
    }
}

function Assert-GitHubActions {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        
        $targetWorkflowFile = [Path]::Join($resolvedPath, '.github', 'workflows', 'workflow.yaml')
        $targetWorkflowFileName = [Path]::GetFileName($targetWorkflowFile)
        
        $existed = Test-Path -Path $targetWorkflowFile
        
        if (-not $existed) {
            $resultText = New-ResultText -Name $name -Target $targetWorkflowFileName -Failure
            Write-Host $resultText -ForegroundColor DarkYellow
            Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
            $null = $script:AssertionResult.AppendLine($resultText)
            $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
            $record = [ErrorRecord]::new(
                [InvalidOperationException]::new(
                    "Missing required GitHub actions workflow file: ""$targetWorkflowFileName""; Path: ""$targetWorkflowFile""."
                ),
                'MissingGitHubActionsWorkflowFile',
                [ErrorCategory]::InvalidOperation,
                $resolvedPath
            )
            $PSCmdlet.ThrowTerminatingError($record)
        }
        $resultText = New-ResultText -Name $name -Target $targetWorkflowFileName
        Write-Host $resultText -ForegroundColor DarkYellow
        $null = $script:AssertionResult.AppendLine($resultText)
    }
}

function Assert-ClassLib {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        
        $classLibFiles = @(
            [Path]::Join($resolvedPath, 'src', $name, 'MyClass.cs'),
            [Path]::Join($resolvedPath, 'src', $name, "$name.csproj")
        )
        
        foreach ($file in $classLibFiles) {
            $targetClassLibFileName = [Path]::GetFileName($file)
            $existed = Test-Path -Path $file
            if (-not $existed) {
                $resultText = New-ResultText -Name $name -Target $targetClassLibFileName -Failure
                Write-Host $resultText -ForegroundColor DarkYellow
                Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
                $null = $script:AssertionResult.AppendLine($resultText)
                $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
                $record = [ErrorRecord]::new(
                    [InvalidOperationException]::new(
                        "Missing required class library source file: ""$targetClassLibFileName""; Path: ""$file""."
                    ),
                    'MissingClassLibrarySourceFile',
                    [ErrorCategory]::InvalidOperation,
                    $resolvedPath
                )
                $PSCmdlet.ThrowTerminatingError($record)
            }
            $resultText = New-ResultText -Name $name -Target $targetClassLibFileName
            Write-Host $resultText -ForegroundColor DarkYellow
            $null = $script:AssertionResult.AppendLine($resultText)
        }
    }
}

function Assert-Console {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        
        $consoleFiles = @(
            [Path]::Join($resolvedPath, 'src', $name, 'MyClass.cs'),
            [Path]::Join($resolvedPath, 'src', $name, 'Program.cs'),
            [Path]::Join($resolvedPath, 'src', $name, "$name.csproj")
        )
        
        foreach ($file in $consoleFiles) {
            $targetConsoleFileName = [Path]::GetFileName($file)
            $existed = Test-Path -Path $file
            if (-not $existed) {
                $resultText = New-ResultText -Name $name -Target $targetConsoleFileName -Failure
                Write-Host $resultText -ForegroundColor DarkYellow
                Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
                $null = $script:AssertionResult.AppendLine($resultText)
                $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
                $record = [ErrorRecord]::new(
                    [InvalidOperationException]::new(
                        "Missing required console source file: ""$targetConsoleFileName""; Path: ""$file""."
                    ),
                    'MissingConsoleSourceFile',
                    [ErrorCategory]::InvalidOperation,
                    $resolvedPath
                )
                $PSCmdlet.ThrowTerminatingError($record)
            }
            $resultText = New-ResultText -Name $name -Target $targetConsoleFileName
            Write-Host $resultText -ForegroundColor DarkYellow
            $null = $script:AssertionResult.AppendLine($resultText)
        }
    }
}

function Assert-Tests {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        
        $testFiles = @(
            [Path]::Join($resolvedPath, 'tests', "$name.Tests", 'UnitTest1.cs'),
            [Path]::Join($resolvedPath, 'tests', "$name.Tests", "$name.Tests.csproj")
        )
        
        foreach ($file in $testFiles) {
            $targetTestFileName = [Path]::GetFileName($file)
            $existed = Test-Path -Path $file
            if (-not $existed) {
                $resultText = New-ResultText -Name $name -Target $targetTestFileName -Failure
                Write-Host $resultText -ForegroundColor DarkYellow
                Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
                $null = $script:AssertionResult.AppendLine($resultText)
                $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
                $record = [ErrorRecord]::new(
                    [InvalidOperationException]::new(
                        "Missing required test file: ""$targetTestFileName""; Path: ""$file""."
                    ),
                    'MissingTestFile',
                    [ErrorCategory]::InvalidOperation,
                    $resolvedPath
                )
                $PSCmdlet.ThrowTerminatingError($record)
            }
            $resultText = New-ResultText -Name $name -Target $targetTestFileName
            Write-Host $resultText -ForegroundColor DarkYellow
            $null = $script:AssertionResult.AppendLine($resultText)
        }
    }
}

function Assert-Benchmarks {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        
        $benchmarkFiles = @(
            [Path]::Join($resolvedPath, 'benchmarks', "$name.Benchmarks", 'Benchmarks.cs'),
            [Path]::Join($resolvedPath, 'benchmarks', "$name.Benchmarks", "$name.Benchmarks.csproj")
        )
        
        foreach ($file in $benchmarkFiles) {
            $targetBenchmarkFileName = [Path]::GetFileName($file)
            $existed = Test-Path -Path $file
            if (-not $existed) {
                $resultText = New-ResultText -Name $name -Target $targetBenchmarkFileName -Failure
                Write-Host $resultText -ForegroundColor DarkYellow
                Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
                $null = $script:AssertionResult.AppendLine($resultText)
                $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
                $record = [ErrorRecord]::new(
                    [InvalidOperationException]::new(
                        "Missing required benchmark file: ""$targetBenchmarkFileName""; Path: ""$file""."
                    ),
                    'MissingBenchmarkFile',
                    [ErrorCategory]::InvalidOperation,
                    $resolvedPath
                )
                $PSCmdlet.ThrowTerminatingError($record)
            }
            $resultText = New-ResultText -Name $name -Target $targetBenchmarkFileName
            Write-Host $resultText -ForegroundColor DarkYellow
            $null = $script:AssertionResult.AppendLine($resultText)
        }
    }
}

function Invoke-DotnetCliTest {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path,
        
        [Parameter()]
        [ValidateSet('ClassLib', 'Console', IgnoreCase = $false)]
        [string] $ProjectType = 'ClassLib',
        
        [Parameter()]
        [switch] $Simple,
        
        [Parameter()]
        [switch] $FullPreset
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        cd $resolvedPath
        
        $name = [Path]::GetFileName($resolvedPath)
        
        $prefix = $name.Substring(
            0,
            $name.IndexOf('.')
        )
        
        Write-Host "------------------------------------------------------" -ForegroundColor DarkCyan
        Write-Host "    $($prefix): dotnet clean" -ForegroundColor DarkCyan
        Write-Host "------------------------------------------------------" -ForegroundColor DarkCyan
        dotnet clean
        
        Write-Host "------------------------------------------------------" -ForegroundColor DarkCyan
        Write-Host "    $($prefix): dotnet restore" -ForegroundColor DarkCyan
        Write-Host "------------------------------------------------------" -ForegroundColor DarkCyan
        dotnet restore
        
        Write-Host "------------------------------------------------------" -ForegroundColor DarkCyan
        Write-Host "    $($prefix): dotnet build --no-restore" -ForegroundColor DarkCyan
        Write-Host "------------------------------------------------------" -ForegroundColor DarkCyan
        dotnet build --no-restore
        
        if (-not $Simple.IsPresent -or $FullPreset.IsPresent) {
            Write-Host "------------------------------------------------------" -ForegroundColor DarkCyan
            Write-Host "    $($prefix): dotnet test --no-build" -ForegroundColor DarkCyan
            Write-Host "------------------------------------------------------" -ForegroundColor DarkCyan
            dotnet test --no-build
        }
        
        if ($ProjectType -eq 'Console') {
            Write-Host "------------------------------------------------------" -ForegroundColor DarkCyan
            Write-Host "    $($prefix): dotnet run --project \" -ForegroundColor DarkCyan
            Write-Host "        src/$($name)/$($name).csproj" -ForegroundColor DarkCyan
            Write-Host "------------------------------------------------------" -ForegroundColor DarkCyan
            dotnet run --project "src/$($name)/$($name).csproj"
        }
        
        cd $script:Root
    }
}

function Write-Section {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Target
    )
    process {
        $date = Get-Date
        $localDateTime = $date.ToString("yyyy-MM-ddTHH:mm:ssK")
        $universalDateTime = $date.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        
        Write-Host "`n$script:SectionDivider" -ForegroundColor Green
        Write-Host $Target -ForegroundColor Green
        Write-Host "$script:SectionDivider`n" -ForegroundColor Green
        
        $sectionStart = "`nLocal Date Time: $localDateTime`n" +
        "`nUniversal Date Time: $universalDateTime`n" +
        "`n$script:SectionDivider" +
        "`n$Target" +
        "`n$script:SectionDivider`n"
        
        $null = $script:AssertionResult.AppendLine($sectionStart)
    }
}

function Assert-Artifacts {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path,
        
        [Parameter()]
        [ValidateSet('Generic', 'Gnu', 'GnuLesser', IgnoreCase = $false)]
        [string] $LicenseType = 'Generic',
        
        [Parameter()]
        [ValidateSet('ClassLib', 'Console', IgnoreCase = $false)]
        [string] $ProjectType = 'ClassLib',
        
        [Parameter()]
        [switch] $Simple,
        
        [Parameter()]
        [switch] $Benchmarks,
        
        [Parameter()]
        [switch] $Docs,
        
        [Parameter()]
        [switch] $GitHubActions,
        
        [Parameter()]
        [switch] $Outdated,
        
        [Parameter()]
        [switch] $BuildConfig,
        
        [Parameter()]
        [switch] $GlobalJson,
        
        [Parameter()]
        [switch] $FullPreset
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        $projectName = [Path]::GetFileName($resolvedPath)
        Write-Section -Target $projectName
        
        Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
        $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
        
        Assert-BoilerplateFiles -Path $Path
        Assert-License -Path $Path -Type $LicenseType
        Assert-Solution -Path $Path -Outdated:$Outdated
        Assert-GlobalJson -Path $Path
        
        switch ($ProjectType) {
            'ClassLib' {
                Assert-ClassLib -Path $Path
            }
            'Console' {
                Assert-Console -Path $Path
            }
        }
        
        if (-not $Simple.IsPresent -or $FullPreset.IsPresent) {
            Assert-Tests -Path $Path
        }
        
        if ($Benchmarks.IsPresent -or $FullPreset.IsPresent) {
            Assert-Benchmarks -Path $Path
        }
        
        if ($Docs.IsPresent -or $FullPreset.IsPresent) {
            Assert-Docs -Path $Path
        }
        
        if ($GitHubActions.IsPresent -or $FullPreset.IsPresent) {
            Assert-GitHubActions -Path $Path
        }
        
        if ($BuildConfig.IsPresent -or $FullPreset.IsPresent) {
            Assert-BuildConfigs -Path $Path
        }
        
        Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
        $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
    }
}

function Invoke-TestCase {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path,
        
        [Parameter()]
        [ValidateSet('Generic', 'Gnu', 'GnuLesser', IgnoreCase = $false)]
        [string] $LicenseType = 'Generic',
        
        [Parameter()]
        [ValidateSet('ClassLib', 'Console', IgnoreCase = $false)]
        [string] $ProjectType = 'ClassLib',
        
        [Parameter()]
        [switch] $Simple,
        
        [Parameter()]
        [switch] $Benchmarks,
        
        [Parameter()]
        [switch] $Docs,
        
        [Parameter()]
        [switch] $GitHubActions,
        
        [Parameter()]
        [switch] $Outdated,
        
        [Parameter()]
        [switch] $BuildConfig,
        
        [Parameter()]
        [switch] $GlobalJson,
        
        [Parameter()]
        [switch] $FullPreset
    )
    process {
        $null = $script:AssertionResult.Clear()
        
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        $artifact = "$([Path]::GetFileName($resolvedPath)).log"
        $logFile = [Path]::Join($script:LogRoot, $artifact)
        
        try {
            Assert-Artifacts `
                -Path $Path `
                -LicenseType $LicenseType `
                -ProjectType $ProjectType `
                -Simple:$Simple `
                -Benchmarks:$Benchmarks `
                -Docs:$Docs `
                -GitHubActions:$GitHubActions `
                -Outdated:$Outdated `
                -BuildConfig:$BuildConfig `
                -GlobalJson:$GlobalJson `
                -FullPreset:$FullPreset
        } finally {
            [File]::WriteAllText($logFile, $script:AssertionResult.ToString(), [Encoding]::UTF8)
        }
        
        Invoke-DotnetCliTest `
            -Path $Path `
            -ProjectType $ProjectType `
            -Simple:$Simple `
            -FullPreset:$FullPreset
    }
}

function Write-CommandSection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Name,
        
        [Parameter(Mandatory, Position = 1)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Command,
        
        [Parameter(Mandatory, Position = 2)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Description,
        
        [Parameter(Position = 3)]
        [string] $Addendum,
        
        [Parameter()]
        [switch] $ExpectedFailure
    )
    process {
        $title = $ExpectedFailure.IsPresent ?
            "Command Error Test - $($Name):" :
            "Command Test - $($Name):"
        
        Write-Host "`n$script:SectionDivider" -ForegroundColor Green
        
        Write-Host $title -ForegroundColor Green
        
        Write-Host $Command -ForegroundColor Green -BackgroundColor DarkGray -NoNewline
        
        if ($PSBoundParameters.ContainsKey('Addendum')) {
            Write-Host "`n$Addendum" -ForegroundColor Green
            
            Write-Host $Description -ForegroundColor Green
        } else {
            Write-Host "`n$Description" -ForegroundColor Green
        }
        
        Write-Host "$script:SectionDivider`n" -ForegroundColor Green
    }
}

function Invoke-CommandTestCase {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Name,
        
        [Parameter(Mandatory, Position = 1)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Command,
        
        [Parameter(Mandatory, Position = 2)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Description,
        
        [Parameter(Mandatory, Position = 3)]
        [ValidateNotNull()]
        [scriptblock] $Script,
        
        [Parameter(Position = 4)]
        [string] $Addendum,
        
        [Parameter(Position = 5)]
        [string] $ExpectedExitCode
    )
    process {
        $namePrefix = $Name.Substring(0, $Name.IndexOf('.'))
        
        $expectedFailure = if ($PSBoundParameters.ContainsKey('ExpectedExitCode')) { $true } else { $false }
        
        Write-CommandSection `
            -Name $namePrefix `
            -Command $Command `
            -Description $Description `
            -Addendum $Addendum `
            -ExpectedFailure:$expectedFailure
        
        Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
        
        Write-Host "Result:`n" -ForegroundColor DarkYellow
        
        if ($expectedFailure) {
            Invoke-ExpectedNativeExitCode -Name $namePrefix -ExpectedExitCode $ExpectedExitCode -Command $Script
        } else {
            & $Script
        }
        
        Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
    }
}

function Remove-Artifact {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        if ([Directory]::Exists($resolvedPath)) {
            [Directory]::Delete($resolvedPath, $true)
        }
    }
}

function Remove-Artifacts {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        $targets = @(
            [Path]::Join($resolvedPath, 'T01.DefaultClassLibrary'),
            [Path]::Join($resolvedPath, 'T02.DefaultSimple'),
            [Path]::Join($resolvedPath, 'T03.DefaultConsole'),
            [Path]::Join($resolvedPath, 'T04.WithBenchmarks'),
            [Path]::Join($resolvedPath, 'T05.WithDocs'),
            [Path]::Join($resolvedPath, 'T06.WithGitHubActions'),
            [Path]::Join($resolvedPath, 'T07.WithBuildConfigs'),
            [Path]::Join($resolvedPath, 'T08.SpecifiedSdkVersion'),
            [Path]::Join($resolvedPath, 'T09.SpecifiedTargetFramework'),
            [Path]::Join($resolvedPath, 'T10.FullPreset'),
            [Path]::Join($resolvedPath, 'T11.DefaultIscLicense'),
            [Path]::Join($resolvedPath, 'T12.DefaultGplLicense'),
            [Path]::Join($resolvedPath, 'T13.DefaultLgplLicense'),
            [Path]::Join($resolvedPath, 'T14.DefaultVsTestTestRunner'),
            [Path]::Join($resolvedPath, 'T15.DefaultMtpTestRunner'),
            [Path]::Join($resolvedPath, 'B01.SimplePrecedeBenchmarks'),
            [Path]::Join($resolvedPath, 'B02.SimpleWithDocs'),
            [Path]::Join($resolvedPath, 'B03.SimpleWithGitHubActions'),
            [Path]::Join($resolvedPath, 'B04.SimpleWithBuildConfigs'),
            [Path]::Join($resolvedPath, 'B05.WithBenchmarksDocsGitHubActions'),
            [Path]::Join($resolvedPath, 'B06.DefaultStandard'),
            [Path]::Join($resolvedPath, 'B07.FullPrecedeSimple'),
            [Path]::Join($resolvedPath, 'B08.FullWithSpecifiedSdkVersion'),
            [Path]::Join($resolvedPath, 'B09.FullWithSpecifiedTargetFramework'),
            [Path]::Join($resolvedPath, 'B10.ConsoleFull'),
            [Path]::Join($resolvedPath, 'B11.ClassLibWithSpecifiedTargetFramework'),
            [Path]::Join($resolvedPath, 'B12.ConsoleWithSpecifiedTargetFramework'),
            [Path]::Join($resolvedPath, 'B13.ClassLibWithSpecifiedTargetFrameworkBenchmarks'),
            [Path]::Join($resolvedPath, 'B14.ConsoleWithSpecifiedTargetFrameworkBenchmarks'),
            [Path]::Join($resolvedPath, 'B15.DefaultClassLibWithSln'),
            [Path]::Join($resolvedPath, 'B16.NormalizedCorrespondingTfm')
        )
        foreach ($target in $targets) {
            Remove-Artifact -Path $target
        }
    }
}

function Remove-Log {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        if ([File]::Exists($resolvedPath)) {
            [File]::Delete($resolvedPath)
        }
    }
}

function Remove-Logs {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        $targets = @(
            [Path]::Join($resolvedPath, 'T01.DefaultClassLibrary.log'),
            [Path]::Join($resolvedPath, 'T02.DefaultSimple.log'),
            [Path]::Join($resolvedPath, 'T03.DefaultConsole.log'),
            [Path]::Join($resolvedPath, 'T04.WithBenchmarks.log'),
            [Path]::Join($resolvedPath, 'T05.WithDocs.log'),
            [Path]::Join($resolvedPath, 'T06.WithGitHubActions.log'),
            [Path]::Join($resolvedPath, 'T07.WithBuildConfigs.log'),
            [Path]::Join($resolvedPath, 'T08.SpecifiedSdkVersion.log'),
            [Path]::Join($resolvedPath, 'T09.SpecifiedTargetFramework.log'),
            [Path]::Join($resolvedPath, 'T10.FullPreset.log'),
            [Path]::Join($resolvedPath, 'T11.DefaultIscLicense.log'),
            [Path]::Join($resolvedPath, 'T12.DefaultGplLicense.log'),
            [Path]::Join($resolvedPath, 'T13.DefaultLgplLicense.log'),
            [Path]::Join($resolvedPath, 'T14.DefaultVsTestTestRunner.log'),
            [Path]::Join($resolvedPath, 'T15.DefaultMtpTestRunner.log'),
            [Path]::Join($resolvedPath, 'B01.SimplePrecedeBenchmarks.log'),
            [Path]::Join($resolvedPath, 'B02.SimpleWithDocs.log'),
            [Path]::Join($resolvedPath, 'B03.SimpleWithGitHubActions.log'),
            [Path]::Join($resolvedPath, 'B04.SimpleWithBuildConfigs.log'),
            [Path]::Join($resolvedPath, 'B05.WithBenchmarksDocsGitHubActions.log'),
            [Path]::Join($resolvedPath, 'B06.DefaultStandard.log'),
            [Path]::Join($resolvedPath, 'B07.FullPrecedeSimple.log'),
            [Path]::Join($resolvedPath, 'B08.FullWithSpecifiedSdkVersion.log'),
            [Path]::Join($resolvedPath, 'B09.FullWithSpecifiedTargetFramework.log'),
            [Path]::Join($resolvedPath, 'B10.ConsoleFull.log'),
            [Path]::Join($resolvedPath, 'B11.ClassLibWithSpecifiedTargetFramework.log'),
            [Path]::Join($resolvedPath, 'B12.ConsoleWithSpecifiedTargetFramework.log'),
            [Path]::Join($resolvedPath, 'B13.ClassLibWithSpecifiedTargetFrameworkBenchmarks.log'),
            [Path]::Join($resolvedPath, 'B14.ConsoleWithSpecifiedTargetFrameworkBenchmarks.log'),
            [Path]::Join($resolvedPath, 'B15.DefaultClassLibWithSln.log'),
            [Path]::Join($resolvedPath, 'B16.NormalizedCorrespondingTfm.log')
        )
        foreach ($target in $targets) {
            Remove-Log -Path $target
        }
    }
}

$previousNativePreference = $global:PSNativeCommandUseErrorActionPreference
$previousActionPreference = $global:ErrorActionPreference

$global:PSNativeCommandUseErrorActionPreference = $true
$global:ErrorActionPreference = [ActionPreference]::Stop

Remove-Artifacts -Path $script:Root
Remove-Logs -Path $script:LogRoot

dotnet new landx-templates -n T01.DefaultClassLibrary -o T01.DefaultClassLibrary --sdk-version 10
Invoke-TestCase -Path ./T01.DefaultClassLibrary -ProjectType ClassLib -LicenseType Generic

dotnet new landx-templates -n T02.DefaultSimple -o T02.DefaultSimple --sdk-version 10 --simple
Invoke-TestCase -Path ./T02.DefaultSimple -ProjectType ClassLib -LicenseType Generic -Simple

dotnet new landx-templates -n T03.DefaultConsole -o T03.DefaultConsole --sdk-version 10 --project-type console
Invoke-TestCase -Path ./T03.DefaultConsole -ProjectType Console -LicenseType Generic

dotnet new landx-templates -n T04.WithBenchmarks -o T04.WithBenchmarks --sdk-version 10 --benchmarks
Invoke-TestCase -Path ./T04.WithBenchmarks -ProjectType ClassLib -LicenseType Generic -Benchmarks

dotnet new landx-templates -n T05.WithDocs -o T05.WithDocs --sdk-version 10 --docs
Invoke-TestCase -Path ./T05.WithDocs -ProjectType ClassLib -LicenseType Generic -Docs

dotnet new landx-templates -n T06.WithGitHubActions -o T06.WithGitHubActions --sdk-version 10 --github-actions
Invoke-TestCase -Path ./T06.WithGitHubActions -ProjectType ClassLib -LicenseType Generic -GitHubActions

dotnet new landx-templates -n T07.WithBuildConfigs -o T07.WithBuildConfigs --sdk-version 10 --build-config
Invoke-TestCase -Path ./T07.WithBuildConfigs -ProjectType ClassLib -LicenseType Generic -BuildConfig

dotnet new landx-templates -n T08.SpecifiedSdkVersion -o T08.SpecifiedSdkVersion --sdk-version 9
Invoke-TestCase -Path ./T08.SpecifiedSdkVersion -ProjectType ClassLib -LicenseType Generic

dotnet new landx-templates -n T09.SpecifiedTargetFramework -o T09.SpecifiedTargetFramework --sdk-version 10 --target-framework 9
Invoke-TestCase -Path ./T09.SpecifiedTargetFramework -ProjectType ClassLib -LicenseType Generic

dotnet new landx-templates -n T10.FullPreset -o T10.FullPreset --sdk-version 10 --preset full
Invoke-TestCase -Path ./T10.FullPreset -ProjectType ClassLib -LicenseType Generic -FullPreset

dotnet new landx-templates -n T11.DefaultIscLicense -o T11.DefaultIscLicense --sdk-version 10 --license ISC --copyright-year 2026 --copyright-owner "John Doe"
Invoke-TestCase -Path ./T11.DefaultIscLicense -ProjectType ClassLib -LicenseType Generic

dotnet new landx-templates -n T12.DefaultGplLicense -o T12.DefaultGplLicense --sdk-version 10 --license GPL-2.0-only --copyright-year 2026 --copyright-owner "John Doe"
Invoke-TestCase -Path ./T12.DefaultGplLicense -ProjectType ClassLib -LicenseType Gnu

dotnet new landx-templates -n T13.DefaultLgplLicense -o T13.DefaultLgplLicense --sdk-version 10 --license LGPL-2.1-only --copyright-year 2026 --copyright-owner "John Doe"
Invoke-TestCase -Path ./T13.DefaultLgplLicense -ProjectType ClassLib -LicenseType GnuLesser

dotnet new landx-templates -n T14.DefaultVsTestTestRunner -o T14.DefaultVsTestTestRunner --sdk-version 10 --test-runner VSTest
Invoke-TestCase -Path ./T14.DefaultVsTestTestRunner -ProjectType ClassLib -LicenseType Generic

dotnet new landx-templates -n T15.DefaultMtpTestRunner -o T15.DefaultMtpTestRunner --sdk-version 10 --test-runner MTP
Invoke-TestCase -Path ./T15.DefaultMtpTestRunner -ProjectType ClassLib -LicenseType Generic

dotnet new landx-templates -n B01.SimplePrecedeBenchmarks -o B01.SimplePrecedeBenchmarks --sdk-version 10 --simple --benchmarks
Invoke-TestCase -Path ./B01.SimplePrecedeBenchmarks -ProjectType ClassLib -LicenseType Generic -simple

dotnet new landx-templates -n B02.SimpleWithDocs -o B02.SimpleWithDocs --sdk-version 10 --simple --docs
Invoke-TestCase -Path ./B02.SimpleWithDocs -ProjectType ClassLib -LicenseType Generic -Simple -Docs

dotnet new landx-templates -n B03.SimpleWithGitHubActions -o B03.SimpleWithGitHubActions --sdk-version 10 --simple --github-actions
Invoke-TestCase -Path ./B03.SimpleWithGitHubActions -ProjectType ClassLib -LicenseType Generic -Simple -GitHubActions

dotnet new landx-templates -n B04.SimpleWithBuildConfigs -o B04.SimpleWithBuildConfigs --sdk-version 10 --simple --build-config
Invoke-TestCase -Path ./B04.SimpleWithBuildConfigs -ProjectType ClassLib -LicenseType Generic -Simple -BuildConfig

dotnet new landx-templates -n B05.WithBenchmarksDocsGitHubActions -o B05.WithBenchmarksDocsGitHubActions --sdk-version 10 --benchmarks --docs --github-actions
Invoke-TestCase -Path ./B05.WithBenchmarksDocsGitHubActions -ProjectType ClassLib -LicenseType Generic -Benchmarks -Docs -GitHubActions

dotnet new landx-templates -n B06.DefaultStandard -o B06.DefaultStandard --sdk-version 10 --preset standard
Invoke-TestCase -Path ./B06.DefaultStandard -ProjectType ClassLib -LicenseType Generic

dotnet new landx-templates -n B07.FullPrecedeSimple -o B07.FullPrecedeSimple --sdk-version 10 --preset full --simple
Invoke-TestCase -Path ./B07.FullPrecedeSimple -ProjectType ClassLib -LicenseType Generic -FullPreset

dotnet new landx-templates -n B08.FullWithSpecifiedSdkVersion -o B08.FullWithSpecifiedSdkVersion --sdk-version 11 --preset full
Invoke-TestCase -Path ./B08.FullWithSpecifiedSdkVersion -ProjectType ClassLib -LicenseType Generic -FullPreset

dotnet new landx-templates -n B09.FullWithSpecifiedTargetFramework -o B09.FullWithSpecifiedTargetFramework --preset full --target-framework 8 --sdk-version 10
Invoke-TestCase -Path ./B09.FullWithSpecifiedTargetFramework -ProjectType ClassLib -LicenseType Generic -FullPreset

dotnet new landx-templates -n B10.ConsoleFull -o B10.ConsoleFull --sdk-version 10 --preset full --project-type console
Invoke-TestCase -Path ./B10.ConsoleFull -ProjectType Console -LicenseType Generic -FullPreset

dotnet new landx-templates -n B11.ClassLibWithSpecifiedTargetFramework -o B11.ClassLibWithSpecifiedTargetFramework --project-type classlib --target-framework 9 --sdk-version 10
Invoke-TestCase -Path ./B11.ClassLibWithSpecifiedTargetFramework -ProjectType ClassLib -LicenseType Generic

dotnet new landx-templates -n B12.ConsoleWithSpecifiedTargetFramework -o B12.ConsoleWithSpecifiedTargetFramework --project-type console --target-framework 10 --sdk-version 10
Invoke-TestCase -Path ./B12.ConsoleWithSpecifiedTargetFramework -ProjectType Console -LicenseType Generic

dotnet new landx-templates -n B13.ClassLibWithSpecifiedTargetFrameworkBenchmarks -o B13.ClassLibWithSpecifiedTargetFrameworkBenchmarks --project-type classlib --target-framework 8 --benchmarks --sdk-version 10
Invoke-TestCase -Path ./B13.ClassLibWithSpecifiedTargetFrameworkBenchmarks -ProjectType ClassLib -LicenseType Generic -Benchmarks

dotnet new landx-templates -n B14.ConsoleWithSpecifiedTargetFrameworkBenchmarks -o B14.ConsoleWithSpecifiedTargetFrameworkBenchmarks --project-type console --target-framework 11 --benchmarks --sdk-version 11
Invoke-TestCase -Path ./B14.ConsoleWithSpecifiedTargetFrameworkBenchmarks -ProjectType Console -LicenseType Generic -Benchmarks

dotnet new landx-templates -n B15.DefaultClassLibWithSln -o B15.DefaultClassLibWithSln --sdk-version 8 --target-framework 8
Invoke-TestCase -Path ./B15.DefaultClassLibWithSln -ProjectType ClassLib -LicenseType Generic -Outdated

dotnet new landx-templates -n B16.NormalizedCorrespondingTfm -o B16.NormalizedCorrespondingTfm --sdk-version 9 --target-framework 10
Invoke-TestCase -Path ./B16.NormalizedCorrespondingTfm -ProjectType ClassLib -LicenseType Generic

Invoke-CommandTestCase `
    -Name C00.ShowHelpInfo `
    -Command 'dotnet new landx-templates --help' `
    -Description "`nIt should show help information." `
    -Script { dotnet new landx-templates --help }

Invoke-CommandTestCase `
    -Name C01.ListLanDXTemplates `
    -Command 'dotnet new list landx-templates' `
    -Description "`nIt should match and show LanDX.Templates as the result." `
    -Script { dotnet new list landx-templates }

Invoke-CommandTestCase `
    -Name E00.MissingRequiredSdkVersionParam `
    -Command 'dotnet new landx-templates -n E00' `
    -Description "It should fail and show related information." `
    -Script { dotnet new landx-templates -n E00 } `
    -Addendum "`n(missing required --sdk-version)" `
    -ExpectedExitCode 102

Invoke-CommandTestCase `
    -Name E01.InvalidProjectType `
    -Command 'dotnet new landx-templates -n E01 --project-type invalid' `
    -Description "`nIt should fail and show the correct choices." `
    -Script { dotnet new landx-templates -n E01 --project-type invalid } `
    -ExpectedExitCode 127

Invoke-CommandTestCase `
    -Name E02.InvalidTargetFramework `
    -Command 'dotnet new landx-templates -n E02 --target-framework 99' `
    -Description "`nIt should fail and show the correct choices." `
    -Script { dotnet new landx-templates -n E02 --target-framework 99 } `
    -ExpectedExitCode 127

Invoke-CommandTestCase `
    -Name E03.InvalidPreset `
    -Command 'dotnet new landx-templates -n E03 --preset invalid' `
    -Description "`nIt should fail and show the correct choices." `
    -Script { dotnet new landx-templates -n E03 --preset invalid } `
    -ExpectedExitCode 127

Invoke-CommandTestCase `
    -Name E04.InvalidLicense `
    -Command 'dotnet new landx-templates -n E04 --license invalid' `
    -Description "`nIt should fail and show the correct choices." `
    -Script { dotnet new landx-templates -n E04 --license invalid } `
    -ExpectedExitCode 127

$global:PSNativeCommandUseErrorActionPreference = $previousNativePreference
$global:ErrorActionPreference = $previousActionPreference