#requires -Version 7.6.8
#requires -PSEdition Core

using namespace System
using namespace System.Diagnostics
using namespace System.Globalization
using namespace System.IO
using namespace System.Text
using namespace System.Management.Automation

$script:Root = [Path]::Join($PSScriptRoot, 'artifacts')
$script:LogRoot = [Path]::Join($PSScriptRoot, 'logs')

$script:SectionDivider = "======================================================"
$script:SubSectionDivider = "------------------------------------------------------"

$script:BoilerplateFiles = @(
    '.editorconfig',
    '.gitattributes',
    '.gitignore',
    'README.md'
)

$script:GnuLesserFiles = @(
    'COPYING'
    'COPYING.LESSER'
)

$script:BuildConfigFiles = @(
    'Directory.Build.props',
    'Directory.Build.targets',
    'Directory.Packages.props'
)

$script:Artifacts = @(
    'T01.DefaultClassLibrary',
    'T02.DefaultSimple',
    'T03.DefaultConsole',
    'T04.WithBenchmarks',
    'T05.WithDocs',
    'T06.WithGitHubActions',
    'T07.WithBuildConfigs',
    'T08.SpecifiedSdkVersion',
    'T09.SpecifiedTargetFramework',
    'T10.FullPreset',
    'T11.DefaultISCLicense',
    'T12.DefaultGPLLicense',
    'T13.DefaultLGPLLicense',
    'T14.DefaultVSTestTestRunner',
    'T15.DefaultMTPTestRunner',
    'B01.SimplePrecedeBenchmarks',
    'B02.SimpleWithDocs',
    'B03.SimpleWithGitHubActions',
    'B04.SimpleWithBuildConfigs',
    'B05.WithBenchmarksDocsGitHubActions',
    'B06.DefaultStandard',
    'B07.FullPrecedeSimple',
    'B08.FullWithSpecifiedSdkVersion',
    'B09.FullWithSpecifiedTargetFramework',
    'B10.ConsoleFull',
    'B11.ClassLibWithSpecifiedTargetFramework',
    'B12.ConsoleWithSpecifiedTargetFramework',
    'B13.ClassLibWithSpecifiedTargetFrameworkBenchmarks',
    'B14.ConsoleWithSpecifiedTargetFrameworkBenchmarks',
    'B15.DefaultClassLibWithSln',
    'B16.NormalizedCorrespondingTfm'
)

$script:AssertionResult = [StringBuilder]::new()

[Directory]::CreateDirectory($script:Root)
[Directory]::CreateDirectory($script:LogRoot)

function Invoke-ExpectedNativeExitCode {
    [CmdletBinding()]
    param(
        [Alias('i', 'n')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Name,
        
        [Alias('exp-ex-cd')]
        [Parameter(Mandatory, Position = 1)]
        [ValidateRange(0, 255)]
        [int] $ExpectedExitCode,
        
        [Alias('cmd')]
        [Parameter(Mandatory, Position = 2)]
        [ValidateNotNull()]
        [scriptblock] $Command
    )
    process {
        $previousNativePreference      = $PSNativeCommandUseErrorActionPreference
        $previousErrorActionPreference = $ErrorActionPreference
        
        $actualExitCode = 0
        
        try {
            $PSNativeCommandUseErrorActionPreference = $false
            $ErrorActionPreference = [ActionPreference]::Continue
            
            & $Command
            
            $actualExitCode = $global:LASTEXITCODE
        } finally {
            $PSNativeCommandUseErrorActionPreference = $previousNativePreference
            $ErrorActionPreference                   = $previousErrorActionPreference
            
            $target = [Path]::Join($script:Root, $Name)
            if ([Directory]::Exists($target)) {
                [Directory]::Delete($target, $true)
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
        [Alias('i', 'n')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Name,
        
        [Alias('tgt')]
        [Parameter(Mandatory, Position = 1)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Target,
        
        [Alias('fail', 'f')]
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

function Assert-File {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath,
        
        [Alias('tgt-segs')]
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string[]] $TargetPathSegments,
        
        [Alias('disp', 'dsp')]
        [Parameter(Mandatory, Position = 2)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $DisplayName
    )
    process {
        $resolvedArtifact = [Path]::GetFullPath($ArtifactPath, $PWD.ProviderPath)
        $artifactName     = [Path]::GetFileName($resolvedArtifact)
        
        $joinedTarget     = [string]::Join([Path]::DirectorySeparatorChar, $TargetPathSegments)
        $targetPath       = [Path]::Join('.', $joinedTarget)
        $resolvedTarget   = [Path]::GetFullPath($targetPath, $resolvedArtifact)
        $targetName       = [Path]::GetFileName($resolvedTarget)
        
        $existed = Test-Path -Path $resolvedTarget -PathType Leaf
        
        if (-not $existed) {
            $resultText = New-ResultText -Name $artifactName -Target $targetName -Failure
            
            Write-Host $resultText -ForegroundColor DarkYellow
            Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
            
            $null = $script:AssertionResult.AppendLine($resultText)
            $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
            
            $splitWords = $DisplayName.Split(' ')
            $sb = [StringBuilder]::new()
            
            $splitWords.PSForEach({
                $firstElement   = [StringInfo]::GetNextTextElement($_, 0)
                $rest           = $_.Substring($firstElement.Length)
                $pascalCaseText = $firstElement.ToUpperInvariant() + $rest
                
                $sb.Append($pascalCaseText)
            })
            
            $record = [ErrorRecord]::new(
                [InvalidOperationException]::new(
                    "Missing required $($DisplayName): ""$($targetName)""; Path: ""$($resolvedTarget)""."
                ),
                "MissingRequired$($sb.ToString())",
                [ErrorCategory]::InvalidOperation,
                $resolvedTarget
            )
            $PSCmdlet.ThrowTerminatingError($record)
        }
        
        $resultText = New-ResultText -Name $artifactName -Target $targetName
        
        Write-Host $resultText -ForegroundColor DarkYellow
        
        $null = $script:AssertionResult.AppendLine($resultText)
    }
}

Set-Alias -Name 'asrt-f' -Value Assert-File -Scope Script

function Assert-BoilerplateFiles {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath
    )
    process {
        
        $script:BoilerplateFiles.PSForEach({
            $segments = @($_)
            Assert-File `
                -ArtifactPath $ArtifactPath `
                -TargetPathSegments $segments `
                -DisplayName 'boilerplate file'
        })
    }
}

Set-Alias -Name 'asrt-bp-f' -Value Assert-BoilerplateFiles -Scope Script
Set-Alias -Name 'asrt-bpf' -Value Assert-BoilerplateFiles -Scope Script

function Assert-License {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath,
        
        [Alias('t')]
        [Parameter(Position = 1)]
        [ValidateSet('Generic', 'Gnu', 'GnuLesser', IgnoreCase = $false)]
        [string] $Type = 'Generic'
    )
    process {
        switch ($Type) {
            'Generic' {
                $segments = @('LICENSE')
                
                Assert-File `
                    -ArtifactPath $ArtifactPath `
                    -TargetPathSegments $segments `
                    -DisplayName 'license file'
            }
            'Gnu' {
                $segments = @('COPYING')
                
                Assert-File `
                    -ArtifactPath $ArtifactPath `
                    -TargetPathSegments $segments `
                    -DisplayName 'license file'
            }
            'GnuLesser' {
                $script:GnuLesserFiles.PSForEach({
                    $segments = @($_)
                    Assert-File `
                        -ArtifactPath $ArtifactPath `
                        -TargetPathSegments $segments `
                        -DisplayName 'license file'
                })
            }
            default {
                $record = [ErrorRecord]::new(
                    [UnreachableException]::new(
                        'Unreachable code path in Assert-License.'
                    ),
                    'UnreachableCodePath',
                    [ErrorCategory]::InvalidOperation,
                    $null
                )
                $PSCmdlet.ThrowTerminatingError($record)
            }
        } # switch block
        
    } # process block
}

Set-Alias -Name 'asrt-lic' -Value Assert-License -Scope Script

function Assert-Solution {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath,
        
        [Alias('outd')]
        [Parameter()]
        [switch] $Outdated
    )
    process {
        $resolvedArtifact = [Path]::GetFullPath($ArtifactPath, $PWD.ProviderPath)
        $artifactName     = [Path]::GetFileName($resolvedArtifact)
        
        $segments         = ($Outdated.IsPresent) ?
            @("$($artifactName).sln") :
            @("$($artifactName).slnx")
        
        Assert-File `
            -ArtifactPath $ArtifactPath `
            -TargetPathSegments $segments `
            -DisplayName 'solution file'
    }
}

Set-Alias -Name 'asrt-soln' -Value Assert-Solution -Scope Script

function Assert-GlobalJson {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath
    )
    process {
        $segments = @('global.json')
        
        Assert-File `
            -ArtifactPath $ArtifactPath `
            -TargetPathSegments $segments `
            -DisplayName 'global JSON file'
    }
}

Set-Alias -Name 'asrt-glb-json' -Value Assert-GlobalJson -Scope Script

function Assert-BuildConfigs {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath
    )
    process {
        $script:BuildConfigFiles.PSForEach({
            $segments = @($_)
            
            Assert-File `
                -ArtifactPath $ArtifactPath `
                -TargetPathSegments $segments `
                -DisplayName 'build config file'
        })
    }
}

Set-Alias -Name 'asrt-bld-conf' -Value Assert-BuildConfigs -Scope Script
Set-Alias -Name 'asrt-bld-cfg' -Value Assert-BuildConfigs -Scope Script

function Assert-Docs {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath
    )
    process {
        $segments = @('docs', 'architecture-decision-records.md')
        
        Assert-File `
            -ArtifactPath $ArtifactPath `
            -TargetPathSegments $segments `
            -DisplayName 'architecture docs file'
    }
}

Set-Alias -Name 'asrt-docs' -Value Assert-Docs -Scope Script

function Assert-GitHubActions {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath
    )
    process {
        $segments = @('.github', 'workflows', 'workflow.yaml')
        
        Assert-File `
            -ArtifactPath $ArtifactPath `
            -TargetPathSegments $segments `
            -DisplayName 'GitHub Actions workflow file'
    }
}

Set-Alias -Name 'asrt-actions' -Value Assert-GitHubActions -Scope Script
Set-Alias -Name 'asrt-acts' -Value Assert-GitHubActions -Scope Script
Set-Alias -Name 'asrt-gha' -Value Assert-GitHubActions -Scope Script

function Assert-ClassLib {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath
    )
    process {
        $resolvedArtifact = [Path]::GetFullPath($ArtifactPath, $PWD.ProviderPath)
        $artifactName     = [Path]::GetFileName($resolvedArtifact)
        
        $files            = @(
            'MyClass.cs',
            "$($artifactName).csproj"
        )
        
        $files.PSForEach({
            $segments = @('src', $artifactName, $_)
            
            Assert-File `
                -ArtifactPath $ArtifactPath `
                -TargetPathSegments $segments `
                -DisplayName 'source file'
        })
    }
}

Set-Alias -Name 'asrt-cls-lib' -Value Assert-ClassLib -Scope Script
Set-Alias -Name 'asrt-lib' -Value Assert-ClassLib -Scope Script

function Assert-Console {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath
    )
    process {
        $resolvedArtifact = [Path]::GetFullPath($ArtifactPath, $PWD.ProviderPath)
        $artifactName     = [Path]::GetFileName($resolvedArtifact)
        
        $files            = @(
            'MyClass.cs',
            'Program.cs',
            "$($artifactName).csproj"
        )
        
        $files.PSForEach({
            $segments = @('src', $artifactName, $_)
            
            Assert-File `
                -ArtifactPath $ArtifactPath `
                -TargetPathSegments $segments `
                -DisplayName 'source file'
        })
    }
}

Set-Alias -Name 'asrt-con' -Value Assert-Console -Scope Script

function Assert-Tests {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath
    )
    process {
        $resolvedArtifact = [Path]::GetFullPath($ArtifactPath, $PWD.ProviderPath)
        $artifactName     = [Path]::GetFileName($resolvedArtifact)
        
        $files            = @(
            'UnitTest1.cs',
            "$($artifactName).Tests.csproj"
        )
        
        $files.PSForEach({
            $segments = @('tests', "$($artifactName).Tests", $_)
            
            Assert-File `
                -ArtifactPath $ArtifactPath `
                -TargetPathSegments $segments `
                -DisplayName 'test file'
        })
    }
}

Set-Alias -Name 'asrt-tsts' -Value Assert-Tests -Scope Script

function Assert-Benchmarks {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath
    )
    process {
        $resolvedArtifact = [Path]::GetFullPath($ArtifactPath, $PWD.ProviderPath)
        $artifactName     = [Path]::GetFileName($resolvedArtifact)
        
        $files            = @(
            'Benchmarks.cs',
            "$($artifactName).Benchmarks.csproj"
        )
        
        $files.PSForEach({
            $segments = @('benchmarks', "$($artifactName).Benchmarks", $_)
            
            Assert-File `
                -ArtifactPath $ArtifactPath `
                -TargetPathSegments $segments `
                -DisplayName 'benchmark file'
        })
    }
}

Set-Alias -Name 'asrt-benchs' -Value Assert-Benchmarks -Scope Script

function Write-Section {
    [CmdletBinding()]
    param(
        [Alias('i')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactName
    )
    process {
        $date              = Get-Date
        $localDateTime     = $date.ToString("yyyy-MM-ddTHH:mm:ssK", [CultureInfo]::InvariantCulture)
        $universalDateTime = $date.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ", [CultureInfo]::InvariantCulture)
        
        Write-Host "`n$script:SectionDivider" -ForegroundColor Green
        Write-Host $ArtifactName -ForegroundColor Green
        Write-Host "$script:SectionDivider`n" -ForegroundColor Green
        
        $section = "`nLocal Date Time: $($localDateTime)`n" +
            "`nUniversal Date Time: $($universalDateTime)`n" +
            "`n$($script:SectionDivider)" +
            "`n$($ArtifactName)" +
            "`n$($script:SectionDivider)`n"
        
        $null = $script:AssertionResult.AppendLine($section)
    }
}

Set-Alias -Name 'wrt-sec' -Value Write-Section -Scope Script

function Write-Subsection {
    [CmdletBinding(DefaultParameterSetName = 'Normal')]
    param(
        [Parameter(ParameterSetName = 'Normal')]
        [Parameter(ParameterSetName = 'Path')]
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ResolvedArtifactPath,
        
        [Parameter(ParameterSetName = 'Normal')]
        [Parameter(ParameterSetName = 'Path')]
        [Alias('cmd')]
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Command,
        
        [Parameter(ParameterSetName = 'Path')]
        [Alias('cmd-path')]
        [string] $CommandPath
    )
    process {
        $artifactName   = [Path]::GetFileName($ResolvedArtifactPath)
        $artifactPrefix = $artifactName.Substring(0, $artifactName.IndexOf('.'))
        Write-Host $script:SubSectionDivider -ForegroundColor DarkCyan
        
        switch ($PSCmdlet.ParameterSetName) {
            'Normal' {
                Write-Host "    $($artifactPrefix): $($Command)" -ForegroundColor DarkCyan
            }
            'Path' {
                Write-Host "    $($artifactPrefix): $($Command) \" -ForegroundColor DarkCyan
                Write-Host "        $($CommandPath)" -ForegroundColor DarkCyan
            }
        }
        
        Write-Host $script:SubSectionDivider -ForegroundColor DarkCyan
    }
}

Set-Alias -Name 'wrt-subsec' -Value Write-Subsection -Scope Script

function Invoke-DotnetCliTest {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath,
        
        [Alias('proj-type', 'proj')]
        [Parameter(Position = 1)]
        [ValidateSet('ClassLib', 'Console', IgnoreCase = $false)]
        [string] $ProjectType = 'ClassLib',
        
        [Alias('smp')]
        [Parameter()]
        [switch] $Simple,
        
        [Alias('f-prst', 'fprst')]
        [Parameter()]
        [switch] $FullPreset
    )
    process {
        $resolvedArtifact = [Path]::GetFullPath($ArtifactPath, $PWD.ProviderPath)
        
        cd $resolvedArtifact
        
        try {
            Write-Subsection `
                -ResolvedArtifactPath $resolvedArtifact `
                -Command 'dotnet clean'
            
            dotnet clean
            
            Write-Subsection `
                -ResolvedArtifactPath $resolvedArtifact `
                -Command 'dotnet restore'
            
            dotnet restore
            
            Write-Subsection `
                -ResolvedArtifactPath $resolvedArtifact `
                -Command 'dotnet build --no-restore'
            
            dotnet build --no-restore
            
            if (-not $Simple.IsPresent -or $FullPreset.IsPresent) {
                Write-Subsection `
                    -ResolvedArtifactPath $resolvedArtifact `
                    -Command 'dotnet test --no-build'
                
                dotnet test --no-build
            }
            
            if ($ProjectType -eq 'Console') {
                $artifactName   = [Path]::GetFileName($resolvedArtifact)
                $csProjectPath  = "src/$($artifactName)/$($artifactName).csproj"
                
                Write-Subsection `
                    -ResolvedArtifactPath $resolvedArtifact `
                    -Command "dotnet run --project" `
                    -CommandPath """$($csProjectPath)"""
                
                dotnet run --project $csProjectPath
            }
        } finally {
            cd $script:Root
        }
    }
}

Set-Alias -Name 'inv-net-cli-tst' -Value Invoke-DotnetCliTest -Scope Script
Set-Alias -Name 'inv-net-tst' -Value Invoke-DotnetCliTest -Scope Script

function Assert-Artifacts {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath,
        
        [Alias('lic-type', 'lic')]
        [Parameter(Position = 1)]
        [ValidateSet('Generic', 'Gnu', 'GnuLesser', IgnoreCase = $false)]
        [string] $LicenseType = 'Generic',
        
        [Alias('proj-type', 'proj')]
        [Parameter(Position = 2)]
        [ValidateSet('ClassLib', 'Console', IgnoreCase = $false)]
        [string] $ProjectType = 'ClassLib',
        
        [Alias('smp')]
        [Parameter()]
        [switch] $Simple,
        
        [Alias('bench')]
        [Parameter()]
        [switch] $Benchmarks,
        
        [Parameter()]
        [switch] $Docs,
        
        [Alias('actions', 'ga')]
        [Parameter()]
        [switch] $GitHubActions,
        
        [Alias('outd')]
        [Parameter()]
        [switch] $Outdated,
        
        [Alias('bld-conf', 'bld-cfg')]
        [Parameter()]
        [switch] $BuildConfig,
        
        [Alias('f-prst', 'fprst')]
        [Parameter()]
        [switch] $FullPreset
    )
    process {
        $resolvedArtifact = [Path]::GetFullPath($ArtifactPath, $PWD.ProviderPath)
        $artifactName     = [Path]::GetFileName($resolvedArtifact)
        
        Write-Section -ArtifactName $artifactName
        
        Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
        $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
        
        Assert-BoilerplateFiles -ArtifactPath $ArtifactPath
        Assert-License -ArtifactPath $ArtifactPath -Type $LicenseType
        Assert-Solution -ArtifactPath $ArtifactPath -Outdated:$Outdated
        Assert-GlobalJson -ArtifactPath $ArtifactPath
        
        switch ($ProjectType) {
            'ClassLib' {
                Assert-ClassLib -ArtifactPath $ArtifactPath
            }
            'Console' {
                Assert-Console -ArtifactPath $ArtifactPath
            }
        }
        
        if (-not $Simple.IsPresent -or $FullPreset.IsPresent) {
            Assert-Tests -ArtifactPath $ArtifactPath
        }
        
        if ($Benchmarks.IsPresent -or $FullPreset.IsPresent) {
            Assert-Benchmarks -ArtifactPath $ArtifactPath
        }
        
        if ($Docs.IsPresent -or $FullPreset.IsPresent) {
            Assert-Docs -ArtifactPath $ArtifactPath
        }
        
        if ($GitHubActions.IsPresent -or $FullPreset.IsPresent) {
            Assert-GitHubActions -ArtifactPath $ArtifactPath
        }
        
        if ($BuildConfig.IsPresent -or $FullPreset.IsPresent) {
            Assert-BuildConfigs -ArtifactPath $ArtifactPath
        }
        
        Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
        $null = $script:AssertionResult.AppendLine($script:SubSectionDivider)
    }
}

Set-Alias -Name 'asrt-artfs' -Value Assert-Artifacts -Scope Script
Set-Alias -Name 'asrt-arts' -Value Assert-Artifacts -Scope Script

function Invoke-TestCase {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath,
        
        [Alias('lic-type', 'lic')]
        [Parameter()]
        [ValidateSet('Generic', 'Gnu', 'GnuLesser', IgnoreCase = $false)]
        [string] $LicenseType = 'Generic',
        
        [Alias('proj-type', 'proj')]
        [Parameter()]
        [ValidateSet('ClassLib', 'Console', IgnoreCase = $false)]
        [string] $ProjectType = 'ClassLib',
        
        [Alias('smp')]
        [Parameter()]
        [switch] $Simple,
        
        [Alias('bench')]
        [Parameter()]
        [switch] $Benchmarks,
        
        [Parameter()]
        [switch] $Docs,
        
        [Alias('actions', 'ga')]
        [Parameter()]
        [switch] $GitHubActions,
        
        [Alias('outd')]
        [Parameter()]
        [switch] $Outdated,
        
        [Alias('bld-conf', 'bld-cfg')]
        [Parameter()]
        [switch] $BuildConfig,
        
        [Alias('f-prst', 'fprst')]
        [Parameter()]
        [switch] $FullPreset
    )
    process {
        $null             = $script:AssertionResult.Clear()
        
        $resolvedArtifact = [Path]::GetFullPath($ArtifactPath, $PWD.ProviderPath)
        $artifact         = "$([Path]::GetFileName($resolvedArtifact)).log"
        $logFile          = [Path]::Join($script:LogRoot, $artifact)
        
        try {
            Assert-Artifacts `
                -ArtifactPath $ArtifactPath `
                -LicenseType $LicenseType `
                -ProjectType $ProjectType `
                -Simple:$Simple `
                -Benchmarks:$Benchmarks `
                -Docs:$Docs `
                -GitHubActions:$GitHubActions `
                -Outdated:$Outdated `
                -BuildConfig:$BuildConfig `
                -FullPreset:$FullPreset
        } finally {
            [File]::WriteAllText($logFile, $script:AssertionResult.ToString(), [Encoding]::UTF8)
        }
        
        Invoke-DotnetCliTest `
            -ArtifactPath $ArtifactPath `
            -ProjectType $ProjectType `
            -Simple:$Simple `
            -FullPreset:$FullPreset
    }
}

Set-Alias -Name 'inv-tst-case' -Value Invoke-TestCase -Scope Script

function Write-CommandSection {
    [CmdletBinding()]
    param(
        [Alias('i', 'n')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Name,
        
        [Alias('cmd')]
        [Parameter(Mandatory, Position = 1)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Command,
        
        [Alias('desc')]
        [Parameter(Mandatory, Position = 2)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Description,
        
        [Alias('addm', 'add')]
        [Parameter(Position = 3)]
        [string] $Addendum,
        
        [Alias('exp-fail')]
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

Set-Alias -Name 'wrt-cmd-sec' -Value Write-CommandSection -Scope Script

function Invoke-CommandTestCase {
    [CmdletBinding()]
    param(
        [Alias('i', 'n')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Name,
        
        [Alias('cmd')]
        [Parameter(Mandatory, Position = 1)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Command,
        
        [Alias('desc')]
        [Parameter(Mandatory, Position = 2)]
        [ValidateLength(1, 255)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Description,
        
        [Alias('scrp')]
        [Parameter(Mandatory, Position = 3)]
        [ValidateNotNull()]
        [scriptblock] $Script,
        
        [Alias('addm', 'add')]
        [Parameter(Position = 4)]
        [string] $Addendum,
        
        [Alias('exp-ex-cd')]
        [Parameter(Position = 5)]
        [ValidateRange(0, 255)]
        [int] $ExpectedExitCode
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
            Invoke-ExpectedNativeExitCode `
                -Name $namePrefix `
                -ExpectedExitCode $ExpectedExitCode `
                -Command $Script
        } else {
            & $Script
        }
        
        Write-Host $script:SubSectionDivider -ForegroundColor DarkYellow
    }
}

Set-Alias -Name 'inv-cmd-tst' -Value Invoke-CommandTestCase -Scope Script

function Remove-Artifact {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf', 'art')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactPath
    )
    process {
        $resolvedArtifact = [Path]::GetFullPath($ArtifactPath, $script:Root)
        
        if ([Directory]::Exists($resolvedArtifact)) {
            [Directory]::Delete($resolvedArtifact, $true)
        }
    }
}

Set-Alias -Name 'rm-artf' -Value Remove-Artifact -Scope Script
Set-Alias -Name 'rm-art' -Value Remove-Artifact -Scope Script

function Remove-Artifacts {
    [CmdletBinding()]
    param()
    process {
        $script:Artifacts.PSForEach({
            Remove-Artifact -ArtifactPath "./$($_)"
        })
    }
}

Set-Alias -Name 'rm-artfs' -Value Remove-Artifacts -Scope Script
Set-Alias -Name 'rm-arts' -Value Remove-Artifacts -Scope Script

function Remove-Log {
    [CmdletBinding()]
    param(
        [Alias('i', 'artf-log', 'art-log')]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $ArtifactLogRoot
    )
    process {
        $resolvedArtifactLog = [Path]::GetFullPath($ArtifactLogRoot, $script:LogRoot)
        
        if ([File]::Exists($resolvedArtifactLog)) {
            [File]::Delete($resolvedArtifactLog)
        }
    }
}

Set-Alias -Name 'rm-log' -Value Remove-Log -Scope Script

function Remove-Logs {
    [CmdletBinding()]
    param()
    process {
        $script:Artifacts.PSForEach({
            Remove-Log -ArtifactLogRoot "./$($_).log"
        })
    }
}

Set-Alias -Name 'rm-logs' -Value Remove-Logs -Scope Script

$previousNativePreference = $global:PSNativeCommandUseErrorActionPreference
$previousActionPreference = $global:ErrorActionPreference

$global:PSNativeCommandUseErrorActionPreference = $true
$global:ErrorActionPreference = [ActionPreference]::Stop

cd $script:Root

try {
    Remove-Artifacts
    Remove-Logs

    dotnet new landx-templates -n T01.DefaultClassLibrary -o T01.DefaultClassLibrary --sdk-version 10
    Invoke-TestCase -ArtifactPath ./T01.DefaultClassLibrary -ProjectType ClassLib -LicenseType Generic

    dotnet new landx-templates -n T02.DefaultSimple -o T02.DefaultSimple --sdk-version 10 --simple
    Invoke-TestCase -ArtifactPath ./T02.DefaultSimple -ProjectType ClassLib -LicenseType Generic -Simple

    dotnet new landx-templates -n T03.DefaultConsole -o T03.DefaultConsole --sdk-version 10 --project-type console
    Invoke-TestCase -ArtifactPath ./T03.DefaultConsole -ProjectType Console -LicenseType Generic

    dotnet new landx-templates -n T04.WithBenchmarks -o T04.WithBenchmarks --sdk-version 10 --benchmarks
    Invoke-TestCase -ArtifactPath ./T04.WithBenchmarks -ProjectType ClassLib -LicenseType Generic -Benchmarks

    dotnet new landx-templates -n T05.WithDocs -o T05.WithDocs --sdk-version 10 --docs
    Invoke-TestCase -ArtifactPath ./T05.WithDocs -ProjectType ClassLib -LicenseType Generic -Docs

    dotnet new landx-templates -n T06.WithGitHubActions -o T06.WithGitHubActions --sdk-version 10 --github-actions
    Invoke-TestCase -ArtifactPath ./T06.WithGitHubActions -ProjectType ClassLib -LicenseType Generic -GitHubActions

    dotnet new landx-templates -n T07.WithBuildConfigs -o T07.WithBuildConfigs --sdk-version 10 --build-config
    Invoke-TestCase -ArtifactPath ./T07.WithBuildConfigs -ProjectType ClassLib -LicenseType Generic -BuildConfig

    dotnet new landx-templates -n T08.SpecifiedSdkVersion -o T08.SpecifiedSdkVersion --sdk-version 9
    Invoke-TestCase -ArtifactPath ./T08.SpecifiedSdkVersion -ProjectType ClassLib -LicenseType Generic

    dotnet new landx-templates -n T09.SpecifiedTargetFramework -o T09.SpecifiedTargetFramework --sdk-version 10 --target-framework 9
    Invoke-TestCase -ArtifactPath ./T09.SpecifiedTargetFramework -ProjectType ClassLib -LicenseType Generic

    dotnet new landx-templates -n T10.FullPreset -o T10.FullPreset --sdk-version 10 --preset full
    Invoke-TestCase -ArtifactPath ./T10.FullPreset -ProjectType ClassLib -LicenseType Generic -FullPreset

    dotnet new landx-templates -n T11.DefaultIscLicense -o T11.DefaultIscLicense --sdk-version 10 --license ISC --copyright-year 2026 --copyright-owner "John Doe"
    Invoke-TestCase -ArtifactPath ./T11.DefaultIscLicense -ProjectType ClassLib -LicenseType Generic

    dotnet new landx-templates -n T12.DefaultGplLicense -o T12.DefaultGplLicense --sdk-version 10 --license GPL-2.0-only --copyright-year 2026 --copyright-owner "John Doe"
    Invoke-TestCase -ArtifactPath ./T12.DefaultGplLicense -ProjectType ClassLib -LicenseType Gnu

    dotnet new landx-templates -n T13.DefaultLgplLicense -o T13.DefaultLgplLicense --sdk-version 10 --license LGPL-2.1-only --copyright-year 2026 --copyright-owner "John Doe"
    Invoke-TestCase -ArtifactPath ./T13.DefaultLgplLicense -ProjectType ClassLib -LicenseType GnuLesser

    dotnet new landx-templates -n T14.DefaultVsTestTestRunner -o T14.DefaultVsTestTestRunner --sdk-version 10 --test-runner VSTest
    Invoke-TestCase -ArtifactPath ./T14.DefaultVsTestTestRunner -ProjectType ClassLib -LicenseType Generic

    dotnet new landx-templates -n T15.DefaultMtpTestRunner -o T15.DefaultMtpTestRunner --sdk-version 10 --test-runner MTP
    Invoke-TestCase -ArtifactPath ./T15.DefaultMtpTestRunner -ProjectType ClassLib -LicenseType Generic

    dotnet new landx-templates -n B01.SimplePrecedeBenchmarks -o B01.SimplePrecedeBenchmarks --sdk-version 10 --simple --benchmarks
    Invoke-TestCase -ArtifactPath ./B01.SimplePrecedeBenchmarks -ProjectType ClassLib -LicenseType Generic -simple

    dotnet new landx-templates -n B02.SimpleWithDocs -o B02.SimpleWithDocs --sdk-version 10 --simple --docs
    Invoke-TestCase -ArtifactPath ./B02.SimpleWithDocs -ProjectType ClassLib -LicenseType Generic -Simple -Docs

    dotnet new landx-templates -n B03.SimpleWithGitHubActions -o B03.SimpleWithGitHubActions --sdk-version 10 --simple --github-actions
    Invoke-TestCase -ArtifactPath ./B03.SimpleWithGitHubActions -ProjectType ClassLib -LicenseType Generic -Simple -GitHubActions

    dotnet new landx-templates -n B04.SimpleWithBuildConfigs -o B04.SimpleWithBuildConfigs --sdk-version 10 --simple --build-config
    Invoke-TestCase -ArtifactPath ./B04.SimpleWithBuildConfigs -ProjectType ClassLib -LicenseType Generic -Simple -BuildConfig

    dotnet new landx-templates -n B05.WithBenchmarksDocsGitHubActions -o B05.WithBenchmarksDocsGitHubActions --sdk-version 10 --benchmarks --docs --github-actions
    Invoke-TestCase -ArtifactPath ./B05.WithBenchmarksDocsGitHubActions -ProjectType ClassLib -LicenseType Generic -Benchmarks -Docs -GitHubActions

    dotnet new landx-templates -n B06.DefaultStandard -o B06.DefaultStandard --sdk-version 10 --preset standard
    Invoke-TestCase -ArtifactPath ./B06.DefaultStandard -ProjectType ClassLib -LicenseType Generic

    dotnet new landx-templates -n B07.FullPrecedeSimple -o B07.FullPrecedeSimple --sdk-version 10 --preset full --simple
    Invoke-TestCase -ArtifactPath ./B07.FullPrecedeSimple -ProjectType ClassLib -LicenseType Generic -FullPreset

    dotnet new landx-templates -n B08.FullWithSpecifiedSdkVersion -o B08.FullWithSpecifiedSdkVersion --sdk-version 11 --preset full
    Invoke-TestCase -ArtifactPath ./B08.FullWithSpecifiedSdkVersion -ProjectType ClassLib -LicenseType Generic -FullPreset

    dotnet new landx-templates -n B09.FullWithSpecifiedTargetFramework -o B09.FullWithSpecifiedTargetFramework --preset full --target-framework 8 --sdk-version 10
    Invoke-TestCase -ArtifactPath ./B09.FullWithSpecifiedTargetFramework -ProjectType ClassLib -LicenseType Generic -FullPreset

    dotnet new landx-templates -n B10.ConsoleFull -o B10.ConsoleFull --sdk-version 10 --preset full --project-type console
    Invoke-TestCase -ArtifactPath ./B10.ConsoleFull -ProjectType Console -LicenseType Generic -FullPreset

    dotnet new landx-templates -n B11.ClassLibWithSpecifiedTargetFramework -o B11.ClassLibWithSpecifiedTargetFramework --project-type classlib --target-framework 9 --sdk-version 10
    Invoke-TestCase -ArtifactPath ./B11.ClassLibWithSpecifiedTargetFramework -ProjectType ClassLib -LicenseType Generic

    dotnet new landx-templates -n B12.ConsoleWithSpecifiedTargetFramework -o B12.ConsoleWithSpecifiedTargetFramework --project-type console --target-framework 10 --sdk-version 10
    Invoke-TestCase -ArtifactPath ./B12.ConsoleWithSpecifiedTargetFramework -ProjectType Console -LicenseType Generic

    dotnet new landx-templates -n B13.ClassLibWithSpecifiedTargetFrameworkBenchmarks -o B13.ClassLibWithSpecifiedTargetFrameworkBenchmarks --project-type classlib --target-framework 8 --benchmarks --sdk-version 10
    Invoke-TestCase -ArtifactPath ./B13.ClassLibWithSpecifiedTargetFrameworkBenchmarks -ProjectType ClassLib -LicenseType Generic -Benchmarks

    dotnet new landx-templates -n B14.ConsoleWithSpecifiedTargetFrameworkBenchmarks -o B14.ConsoleWithSpecifiedTargetFrameworkBenchmarks --project-type console --target-framework 11 --benchmarks --sdk-version 11
    Invoke-TestCase -ArtifactPath ./B14.ConsoleWithSpecifiedTargetFrameworkBenchmarks -ProjectType Console -LicenseType Generic -Benchmarks

    dotnet new landx-templates -n B15.DefaultClassLibWithSln -o B15.DefaultClassLibWithSln --sdk-version 8 --target-framework 8
    Invoke-TestCase -ArtifactPath ./B15.DefaultClassLibWithSln -ProjectType ClassLib -LicenseType Generic -Outdated

    dotnet new landx-templates -n B16.NormalizedCorrespondingTfm -o B16.NormalizedCorrespondingTfm --sdk-version 9 --target-framework 10
    Invoke-TestCase -ArtifactPath ./B16.NormalizedCorrespondingTfm -ProjectType ClassLib -LicenseType Generic

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
} finally {
    $path = [Path]::GetFullPath('..', $script:Root)
    cd $path
}

$global:PSNativeCommandUseErrorActionPreference = $previousNativePreference
$global:ErrorActionPreference = $previousActionPreference