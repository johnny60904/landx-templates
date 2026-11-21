using namespace System
using namespace System.IO
using namespace System.Management.Automation

$root = [Path]::Join($PSScriptRoot, 'artifacts')

cd $root

function Assert-BoilerplateFiles {
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
        $prefix = $name.Substring(
            0,
            $name.IndexOf('.')
        )
        
        foreach ($file in $boilerplateFiles) {
            $targetBoilerplateFile = [Path]::Join($resolvedPath, $file)
            $targetBoilerplateFileName = [Path]::GetFileName($targetBoilerplateFile)
            $existed = Test-Path -Path $targetBoilerplateFile
            if (-not $existed) {
                Write-Host "    - [$prefix] Failed: Assertion ""$targetBoilerplateFileName"" existence" -ForegroundColor DarkYellow
                Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
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
            Write-Host "    - [$prefix] Passed: Assertion ""$targetBoilerplateFileName"" existence" -ForegroundColor DarkYellow
        }
    }
}

function Assert-License {
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path,
        
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
        $prefix = $name.Substring(
            0,
            $name.IndexOf('.')
        )
        
        $existed = $false
                
        if ($Type -ceq 'Generic') {
            $licenseName = 'LICENSE'
            $targetLicenseFile = [Path]::Join($resolvedPath, $licenseName)
            $targetLicenseFileName = [Path]::GetFileName($targetLicenseFile)
            
            $existed = Test-Path -Path $targetLicenseFile
            
            if (-not $existed) {
                Write-Host "    - [$prefix] Failed: Assertion ""$targetLicenseFileName"" existence" -ForegroundColor DarkYellow
                Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
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
            Write-Host "    - [$prefix] Passed: Assertion ""$targetLicenseFileName"" existence" -ForegroundColor DarkYellow
        } elseif ($Type -ceq 'Gnu') {
            $licenseName = 'COPYING'
            $targetLicenseFile = [Path]::Join($resolvedPath, $licenseName)
            $targetLicenseFileName = [Path]::GetFileName($targetLicenseFile)
            
            $existed = Test-Path -Path $targetLicenseFile
            
            if (-not $existed) {
                Write-Host "    - [$prefix] Failed: Assertion ""$targetLicenseFileName"" existence" -ForegroundColor DarkYellow
                Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
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
            Write-Host "    - [$prefix] Passed: Assertion ""$targetLicenseFileName"" existence" -ForegroundColor DarkYellow
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
                    Write-Host "    - [$prefix] Failed: Assertion ""$targetLicenseFileName"" existence" -ForegroundColor DarkYellow
                    Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
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
                Write-Host "    - [$prefix] Passed: Assertion ""$targetLicenseFileName"" existence" -ForegroundColor DarkYellow
            }
        }
    }
}

function Assert-Solution {
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path,
        
        [switch] $Outdated
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        $prefix = $name.Substring(
            0,
            $name.IndexOf('.')
        )
        
        $existed = $true
        
        $targetSolutionFile = ($Outdated.IsPresent) ?
            [Path]::Join($resolvedPath, "$name.sln") :
            [Path]::Join($resolvedPath, "$name.slnx")
        
        $targetSolutionFileName = [Path]::GetFileName($targetSolutionFile)
        
        $existed = Test-Path -Path $targetSolutionFile
        
        if (-not $existed) {
            Write-Host "    - [$prefix] Failed: Assertion ""$targetSolutionFileName"" existence" -ForegroundColor DarkYellow
            Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
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
        Write-Host "    - [$prefix] Passed: Assertion ""$targetSolutionFileName"" existence" -ForegroundColor DarkYellow
    }
}

function Assert-BuildConfigs {
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
        $prefix = $name.Substring(
            0,
            $name.IndexOf('.')
        )
        
        foreach ($configFile in $buildConfigFiles) {
            $targetConfigFile = [Path]::Join($resolvedPath, $configFile)
            $targetConfigFileName = [Path]::GetFileName($targetConfigFile)
            $existed = Test-Path -Path $targetConfigFile
            if (-not $existed) {
                Write-Host "    - [$prefix] Failed: Assertion ""$targetConfigFileName"" existence" -ForegroundColor DarkYellow
                Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
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
            Write-Host "    - [$prefix] Passed: Assertion ""$targetConfigFileName"" existence" -ForegroundColor DarkYellow
        }
    }
}

function Assert-GlobalJson {
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        $prefix = $name.Substring(
            0,
            $name.IndexOf('.')
        )
        
        $targetJsonFile = [Path]::Join($resolvedPath, 'global.json')
        $targetJsonFileName = [Path]::GetFileName($targetJsonFile)
        
        $existed = Test-Path -Path $targetJsonFile
        
        if (-not $existed) {
            Write-Host "    - [$prefix] Failed: Assertion ""$targetJsonFileName"" existence" -ForegroundColor DarkYellow
            Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
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
        Write-Host "    - [$prefix] Passed: Assertion ""$targetJsonFileName"" existence" -ForegroundColor DarkYellow
    }
}

function Assert-Docs {
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        $prefix = $name.Substring(
            0,
            $name.IndexOf('.')
        )
        
        $targetDocFile = [Path]::Join($resolvedPath, 'docs', 'architecture-decision-records.md')
        $targetDocFileName = [Path]::GetFileName($targetDocFile)
        
        $existed = Test-Path -Path $targetDocFile
        
        if (-not $existed) {
            Write-Host "    - [$prefix] Failed: Assertion ""$targetDocFileName"" existence" -ForegroundColor DarkYellow
            Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
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
        Write-Host "    - [$prefix] Passed: Assertion ""$targetDocFileName"" existence" -ForegroundColor DarkYellow
    }
}

function Assert-GitHubActions {
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        $prefix = $name.Substring(
            0,
            $name.IndexOf('.')
        )
        
        $targetWorkflowFile = [Path]::Join($resolvedPath, '.github', 'workflows', 'workflow.yaml')
        $targetWorkflowFileName = [Path]::GetFileName($targetWorkflowFile)
        
        $existed = Test-Path -Path $targetWorkflowFile
        
        if (-not $existed) {
            Write-Host "    - [$prefix] Failed: Assertion ""$targetWorkflowFileName"" existence" -ForegroundColor DarkYellow
            Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
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
        Write-Host "    - [$prefix] Passed: Assertion ""$targetWorkflowFileName"" existence" -ForegroundColor DarkYellow
    }
}

function Assert-ClassLib {
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        $prefix = $name.Substring(
            0,
            $name.IndexOf('.')
        )
        
        $classLibFiles = @(
            [Path]::Join($resolvedPath, 'src', $name, 'MyClass.cs'),
            [Path]::Join($resolvedPath, 'src', $name, "$name.csproj")
        )
        
        foreach ($file in $classLibFiles) {
            $targetClassLibFileName = [Path]::GetFileName($file)
            $existed = Test-Path -Path $file
            if (-not $existed) {
                Write-Host "    - [$prefix] Failed: Assertion ""$targetClassLibFileName"" existence" -ForegroundColor DarkYellow
                Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
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
            Write-Host "    - [$prefix] Passed: Assertion ""$targetClassLibFileName"" existence" -ForegroundColor DarkYellow
        }
    }
}

function Assert-Console {
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        $prefix = $name.Substring(
            0,
            $name.IndexOf('.')
        )
        
        $consoleFiles = @(
            [Path]::Join($resolvedPath, 'src', $name, 'MyClass.cs'),
            [Path]::Join($resolvedPath, 'src', $name, 'Program.cs'),
            [Path]::Join($resolvedPath, 'src', $name, "$name.csproj")
        )
        
        foreach ($file in $consoleFiles) {
            $targetConsoleFileName = [Path]::GetFileName($file)
            $existed = Test-Path -Path $file
            if (-not $existed) {
                Write-Host "    - [$prefix] Failed: Assertion ""$targetConsoleFileName"" exsistence" -ForegroundColor DarkYellow
                Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
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
            Write-Host "    - [$prefix] Passed: Assertion ""$targetConsoleFileName"" exsistence" -ForegroundColor DarkYellow
        }
    }
}

function Assert-Tests {
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        $prefix = $name.Substring(
            0,
            $name.IndexOf('.')
        )
        
        $testFiles = @(
            [Path]::Join($resolvedPath, 'tests', "$name.Tests", 'UnitTest1.cs'),
            [Path]::Join($resolvedPath, 'tests', "$name.Tests", "$name.Tests.csproj")
        )
        
        foreach ($file in $testFiles) {
            $targetTestFileName = [Path]::GetFileName($file)
            $existed = Test-Path -Path $file
            if (-not $existed) {
                Write-Host "    - [$prefix] Failed: Assertion ""$targetTestFileName"" exsistence" -ForegroundColor DarkYellow
                Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
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
            Write-Host "    - [$prefix] Passed: Assertion ""$targetTestFileName"" exsistence" -ForegroundColor DarkYellow
        }
    }
}

function Assert-Benchmarks {
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path
    )
    process {
        $resolvedPath = [Path]::GetFullPath($Path, $PWD.ProviderPath)
        
        $name = [Path]::GetFileName($resolvedPath)
        $prefix = $name.Substring(
            0,
            $name.IndexOf('.')
        )
        
        $benchmarkFiles = @(
            [Path]::Join($resolvedPath, 'benchmarks', "$name.Benchmarks", 'Benchmarks.cs'),
            [Path]::Join($resolvedPath, 'benchmarks', "$name.Benchmarks", "$name.Benchmarks.csproj")
        )
        
        foreach ($file in $benchmarkFiles) {
            $targetBenchmarkFileName = [Path]::GetFileName($file)
            $existed = Test-Path -Path $file
            if (-not $existed) {
                Write-Host "    - [$prefix] Failed: Assertion ""$targetBenchmarkFileName"" exsistence" -ForegroundColor DarkYellow
                Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
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
            Write-Host "    - [$prefix] Passed: Assertion ""$targetBenchmarkFileName"" exsistence" -ForegroundColor DarkYellow
        }
    }
}

function Assert-Artifacts {
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Path,
        
        [ValidateSet('Generic', 'Gnu', 'GnuLesser', IgnoreCase = $false)]
        [string] $LicenseType = 'Generic',
        
        [ValidateSet('ClassLib', 'Console', IgnoreCase = $false)]
        [string] $ProjectType = 'ClassLib',
        
        [switch] $Simple,
        
        [switch] $Benchmarks,
        
        [switch] $Docs,
        
        [switch] $GitHubActions,
        
        [switch] $Outdated,
        
        [switch] $BuildConfig,
        
        [switch] $GlobalJson,
        
        [switch] $FullPreset
    )
    process {
        Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
        
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
        
        Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
        
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
        
        cd $root
    }
}

function Remove-Artifact {
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
            [Path]::Join($resolvedPath, 'B15.DefaultClassLibWithSln')
        )
        foreach ($target in $targets) {
            Remove-Artifact -Path $target
        }
    }
}

function Write-Section {
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Target
    )
    process {
        Write-Host "`n======================================================" -ForegroundColor Green
        Write-Host "$Target" -ForegroundColor Green
        Write-Host "======================================================`n" -ForegroundColor Green
    }
}

$defaultPSNativeCmdAction = $PSNativeCommandUseErrorActionPreference
$PSNativeCommandUseErrorActionPreference = $true
$ErrorActionPreference = [ActionPreference]::Stop

Remove-Artifacts -Path $root

Write-Section -Target T01.DefaultClassLibrary
dotnet new landx-templates -n T01.DefaultClassLibrary -o T01.DefaultClassLibrary --sdk-version 10
Assert-Artifacts -Path ./T01.DefaultClassLibrary -ProjectType ClassLib -LicenseType Generic

Write-Section -Target T02.DefaultSimple
dotnet new landx-templates -n T02.DefaultSimple -o T02.DefaultSimple --simple --sdk-version 10
Assert-Artifacts -Path ./T02.DefaultSimple -ProjectType ClassLib -LicenseType Generic -Simple

Write-Section -Target T03.DefaultConsole
dotnet new landx-templates -n T03.DefaultConsole -o T03.DefaultConsole --project-type console --sdk-version 10
Assert-Artifacts -Path ./T03.DefaultConsole -ProjectType Console -LicenseType Generic

Write-Section -Target T04.WithBenchmarks
dotnet new landx-templates -n T04.WithBenchmarks -o T04.WithBenchmarks --benchmarks --sdk-version 10
Assert-Artifacts -Path ./T04.WithBenchmarks -ProjectType ClassLib -LicenseType Generic -Benchmarks

Write-Section -Target T05.WithDocs
dotnet new landx-templates -n T05.WithDocs -o T05.WithDocs --docs --sdk-version 10
Assert-Artifacts -Path ./T05.WithDocs -ProjectType ClassLib -LicenseType Generic -Docs

Write-Section -Target T06.WithGitHubActions
dotnet new landx-templates -n T06.WithGitHubActions -o T06.WithGitHubActions --github-actions --sdk-version 10
Assert-Artifacts -Path ./T06.WithGitHubActions -ProjectType ClassLib -LicenseType Generic -GitHubActions

Write-Section -Target T07.WithBuildConfigs
dotnet new landx-templates -n T07.WithBuildConfigs -o T07.WithBuildConfigs --build-config --sdk-version 10
Assert-Artifacts -Path ./T07.WithBuildConfigs -ProjectType ClassLib -LicenseType Generic -BuildConfig

Write-Section -Target T08.SpecifiedSdkVersion
dotnet new landx-templates -n T08.SpecifiedSdkVersion -o T08.SpecifiedSdkVersion --sdk-version 10
Assert-Artifacts -Path ./T08.SpecifiedSdkVersion -ProjectType ClassLib -LicenseType Generic

Write-Section -Target T09.SpecifiedTargetFramework
dotnet new landx-templates -n T09.SpecifiedTargetFramework -o T09.SpecifiedTargetFramework --target-framework 9 --sdk-version 10
Assert-Artifacts -Path ./T09.SpecifiedTargetFramework -ProjectType ClassLib -LicenseType Generic

Write-Section -Target T10.FullPreset
dotnet new landx-templates -n T10.FullPreset -o T10.FullPreset --preset full --sdk-version 10
Assert-Artifacts -Path ./T10.FullPreset -ProjectType ClassLib -LicenseType Generic -FullPreset

Write-Section -Target T11.DefaultIscLicense
dotnet new landx-templates -n T11.DefaultIscLicense -o T11.DefaultIscLicense --license ISC --copyright-year 2026 --copyright-owner "John Doe" --sdk-version 10
Assert-Artifacts -Path ./T11.DefaultIscLicense -ProjectType ClassLib -LicenseType Generic

Write-Section -Target T12.DefaultGplLicense
dotnet new landx-templates -n T12.DefaultGplLicense -o T12.DefaultGplLicense --license GPL-2.0-only --copyright-year 2026 --copyright-owner "John Doe" --sdk-version 10
Assert-Artifacts -Path ./T12.DefaultGplLicense -ProjectType ClassLib -LicenseType Gnu

Write-Section -Target T13.DefaultLgplLicense
dotnet new landx-templates -n T13.DefaultLgplLicense -o T13.DefaultLgplLicense --license LGPL-2.1-only --copyright-year 2026 --copyright-owner "John Doe" --sdk-version 10
Assert-Artifacts -Path ./T13.DefaultLgplLicense -ProjectType ClassLib -LicenseType GnuLesser

Write-Section -Target B01.SimplePrecedeBenchmarks
dotnet new landx-templates -n B01.SimplePrecedeBenchmarks -o B01.SimplePrecedeBenchmarks --simple --benchmarks --sdk-version 10
Assert-Artifacts -Path ./B01.SimplePrecedeBenchmarks -ProjectType ClassLib -LicenseType Generic -simple

Write-Section -Target B02.SimpleWithDocs
dotnet new landx-templates -n B02.SimpleWithDocs -o B02.SimpleWithDocs --simple --docs --sdk-version 10
Assert-Artifacts -Path ./B02.SimpleWithDocs -ProjectType ClassLib -LicenseType Generic -Simple -Docs

Write-Section -Target B03.SimpleWithGitHubActions
dotnet new landx-templates -n B03.SimpleWithGitHubActions -o B03.SimpleWithGitHubActions --simple --github-actions --sdk-version 10
Assert-Artifacts -Path ./B03.SimpleWithGitHubActions -ProjectType ClassLib -LicenseType Generic -Simple -GitHubActions

Write-Section -Target B04.SimpleWithBuildConfigs
dotnet new landx-templates -n B04.SimpleWithBuildConfigs -o B04.SimpleWithBuildConfigs --simple --build-config --sdk-version 10
Assert-Artifacts -Path ./B04.SimpleWithBuildConfigs -ProjectType ClassLib -LicenseType Generic -Simple -BuildConfig

Write-Section -Target B05.WithBenchmarksDocsGitHubActions
dotnet new landx-templates -n B05.WithBenchmarksDocsGitHubActions -o B05.WithBenchmarksDocsGitHubActions --benchmarks --docs --github-actions --sdk-version 10
Assert-Artifacts -Path ./B05.WithBenchmarksDocsGitHubActions -ProjectType ClassLib -LicenseType Generic -Benchmarks -Docs -GitHubActions

Write-Section -Target B06.DefaultStandard
dotnet new landx-templates -n B06.DefaultStandard -o B06.DefaultStandard --preset standard --sdk-version 10
Assert-Artifacts -Path ./B06.DefaultStandard -ProjectType ClassLib -LicenseType Generic

Write-Section -Target B07.FullPrecedeSimple
dotnet new landx-templates -n B07.FullPrecedeSimple -o B07.FullPrecedeSimple --preset full --simple --sdk-version 10
Assert-Artifacts -Path ./B07.FullPrecedeSimple -ProjectType ClassLib -LicenseType Generic -FullPreset

Write-Section -Target B08.FullWithSpecifiedSdkVersion
dotnet new landx-templates -n B08.FullWithSpecifiedSdkVersion -o B08.FullWithSpecifiedSdkVersion --preset full --sdk-version 11
Assert-Artifacts -Path ./B08.FullWithSpecifiedSdkVersion -ProjectType ClassLib -LicenseType Generic -FullPreset

Write-Section -Target B09.FullWithSpecifiedTargetFramework
dotnet new landx-templates -n B09.FullWithSpecifiedTargetFramework -o B09.FullWithSpecifiedTargetFramework --preset full --target-framework 8 --sdk-version 10
Assert-Artifacts -Path ./B09.FullWithSpecifiedTargetFramework -ProjectType ClassLib -LicenseType Generic -FullPreset

Write-Section -Target B10.ConsoleFull
dotnet new landx-templates -n B10.ConsoleFull -o B10.ConsoleFull --preset full --project-type console --sdk-version 10
Assert-Artifacts -Path ./B10.ConsoleFull -ProjectType Console -LicenseType Generic -FullPreset

Write-Section -Target B11.ClassLibWithSpecifiedTargetFramework
dotnet new landx-templates -n B11.ClassLibWithSpecifiedTargetFramework -o B11.ClassLibWithSpecifiedTargetFramework --project-type classlib --target-framework 9 --sdk-version 10
Assert-Artifacts -Path ./B11.ClassLibWithSpecifiedTargetFramework -ProjectType ClassLib -LicenseType Generic

Write-Section -Target B12.ConsoleWithSpecifiedTargetFramework
dotnet new landx-templates -n B12.ConsoleWithSpecifiedTargetFramework -o B12.ConsoleWithSpecifiedTargetFramework --project-type console --target-framework 10 --sdk-version 10
Assert-Artifacts -Path ./B12.ConsoleWithSpecifiedTargetFramework -ProjectType Console -LicenseType Generic

Write-Section -Target B13.ClassLibWithSpecifiedTargetFrameworkBenchmarks
dotnet new landx-templates -n B13.ClassLibWithSpecifiedTargetFrameworkBenchmarks -o B13.ClassLibWithSpecifiedTargetFrameworkBenchmarks --project-type classlib --target-framework 8 --benchmarks --sdk-version 10
Assert-Artifacts -Path ./B13.ClassLibWithSpecifiedTargetFrameworkBenchmarks -ProjectType ClassLib -LicenseType Generic -Benchmarks

Write-Section -Target B14.ConsoleWithSpecifiedTargetFrameworkBenchmarks
dotnet new landx-templates -n B14.ConsoleWithSpecifiedTargetFrameworkBenchmarks -o B14.ConsoleWithSpecifiedTargetFrameworkBenchmarks --project-type console --target-framework 11 --benchmarks --sdk-version 11
Assert-Artifacts -Path ./B14.ConsoleWithSpecifiedTargetFrameworkBenchmarks -ProjectType Console -LicenseType Generic -Benchmarks

Write-Section -Target B15.DefaultClassLibWithSln
dotnet new landx-templates -n B15.DefaultClassLibWithSln -o B15.DefaultClassLibWithSln --sdk-version 8 --target-framework 8
Assert-Artifacts -Path ./B15.DefaultClassLibWithSln -ProjectType ClassLib -LicenseType Generic -Outdated

Write-Host "`n======================================================" -ForegroundColor Green
Write-Host "C0 --help" -ForegroundColor Green
Write-Host "======================================================`n" -ForegroundColor Green
Write-Host "------------------------------------------------------`n" -ForegroundColor DarkYellow
dotnet new landx-templates --help
Write-Host "`n------------------------------------------------------" -ForegroundColor DarkYellow

Write-Host "`n======================================================" -ForegroundColor Green
Write-Host "C01 dotnet new list landx-templates" -ForegroundColor Green
Write-Host "======================================================`n" -ForegroundColor Green
Write-Host "------------------------------------------------------`n" -ForegroundColor DarkYellow
dotnet new list landx-templates
Write-Host "`n------------------------------------------------------" -ForegroundColor DarkYellow

try {
    Write-Host "`n======================================================" -ForegroundColor Green
    Write-Host "E01 --project-type invalid" -ForegroundColor Green
    Write-Host "======================================================`n" -ForegroundColor Green
    Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
    dotnet new landx-templates -n E01 --project-type invalid
    Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
} catch {
    if ($LASTEXITCODE -ne 127) {
        Write-Error "Unexpected last exit code: ""$LASTEXITCODE""."
        return
    }
}

try {
    Write-Host "`n======================================================" -ForegroundColor Green
    Write-Host "E02 --target-framework 99" -ForegroundColor Green
    Write-Host "======================================================`n" -ForegroundColor Green
    Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
    dotnet new landx-templates -n E02 --target-framework 7
    Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
} catch {
    if ($LASTEXITCODE -ne 127) {
        Write-Error "Unexpected last exit code: ""$LASTEXITCODE""."
        return
    }
}

try {
    Write-Host "`n======================================================" -ForegroundColor Green
    Write-Host "E03 --preset invalid" -ForegroundColor Green
    Write-Host "======================================================`n" -ForegroundColor Green
    Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
    dotnet new landx-templates -n E03 --preset invalid
    Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
} catch {
    if ($LASTEXITCODE -ne 127) {
        Write-Error "Unexpected last exit code: ""$LASTEXITCODE""."
        return
    }
}

try {
    Write-Host "`n======================================================" -ForegroundColor Green
    Write-Host "E04 --license invalid" -ForegroundColor Green
    Write-Host "======================================================`n" -ForegroundColor Green
    Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
    dotnet new landx-templates -n E04 --license invalid
    Write-Host "------------------------------------------------------" -ForegroundColor DarkYellow
} catch {
    if ($LASTEXITCODE -ne 127) {
        Write-Error "Unexpected last exit code: ""$LASTEXITCODE""."
        return
    }
}

$PSNativeCommandUseErrorActionPreference = $defaultPSNativeCmdAction
$ErrorActionPreference = [ActionPreference]::Continue