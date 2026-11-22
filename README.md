# LanDX.Templates

[![NuGet](https://img.shields.io/badge/NuGet-LanDX.Templates-blue?logo=nuget)](https://www.nuget.org/packages/LanDX.Templates)
[![NuGet](https://img.shields.io/badge/Package-Template-green?logo=nuget)](https://www.nuget.org/packages/LanDX.Templates)
[![NuGet](https://img.shields.io/nuget/v/LanDX.Templates?label=NuGet&logo=nuget&color=darkorange)](https://www.nuget.org/packages/LanDX.Templates/)

[![Target Framework](https://img.shields.io/badge/Target_Framework-.NET_8-darkcyan?logo=dotnet)](https://dotnet.microsoft.com/download/dotnet/8.0)
[![Target Framework](https://img.shields.io/badge/Target_Framework-.NET_9-darkcyan?logo=dotnet)](https://dotnet.microsoft.com/download/dotnet/9.0)
[![Target Framework](https://img.shields.io/badge/Target_Framework-.NET_10-darkcyan?logo=dotnet)](https://dotnet.microsoft.com/download/dotnet/10.0)
[![Target Framework](https://img.shields.io/badge/Target_Framework-.NET_11-darkcyan?logo=dotnet)](https://dotnet.microsoft.com/download/dotnet/11.0)

[![Repository](https://img.shields.io/badge/GitHub-landx--templates-blue?logo=github)](https://github.com/johnny60904/landx-templates)
[![License](https://img.shields.io/badge/license-MIT-green)](https://choosealicense.com/licenses/mit/)

**LanDX.Templates**  is a customizable .NET CLI project template for creating modern C# Class Library and Console Application projects.

It provides a consistent project structure, configurable target frameworks, and optional development tooling. Choose a minimal project setup, use the standard configuration, or enable the full set of optional components.

---

## Features

- **Modern .NET:** Supports .NET 8, .NET 9, .NET 10, and .NET 11 target frameworks.

- **Multiple project types:** Generate Class Library or Console Application projects.

- **Configurable project structure:** Choose the standard or full preset, or use `--simple` for a minimal setup.

- **Explicit SDK selection:** Specify the required .NET SDK version through `--sdk-version`.

- **Target framework normalization:** Automatically adjusts the target framework when it exceeds the selected SDK version.

- **SDK-compatible solution format:** Generates `.sln` for .NET SDK 8 and `.slnx` for .NET SDK 9 and later.

- **Optional tests:** Include a test project in the standard configuration.

- **Configurable test runner:** Choose between VSTest or Microsoft.Testing.Platform (MTP).

- **Runner-specific configuration:** Generates compatible test project settings, package references, and SDK configuration based on the selected test runner.

- **Optional benchmarks:** Include a benchmark project with `--benchmarks`.

- **Optional documentation:** Include architecture decision records with `--docs`.

- **Optional GitHub Actions:** Include workflow configuration with `--github-actions`.

- **Optional shared build configuration:** Include centralized MSBuild and NuGet configuration with `--build-config`.

- **Configurable licensing:** Select from 10 supported open-source licenses.

- **License-aware source headers:** Automatically generates SPDX identifiers, copyright notices, and license-specific headers in generated C# source files.

- **Configurable license copyright information:** Specify the copyright year and owner/holder.

- **Configurable README metadata:** Customize GitHub repository links and license badges in generated README file.

- **Automated package publishing:** Publish versioned template packages through GitHub Actions and NuGet Trusted Publishing.

---

## .NET Version Support

LanDX.Templates supports generating projects targeting .NET 8, .NET 9, .NET 10, and .NET 11. Template compatibility does not necessarily indicate that the corresponding .NET release is still supported by Microsoft.

### Microsoft Support Lifecycle

| .NET Version | Release Type | Microsoft Support Status |
| ------------ | ------------ | ------------------------ |
| .NET 8       | LTS          | End of Support           |
| .NET 9       | STS          | End of Support           |
| .NET 10      | LTS          | Supported                |
| .NET 11      | STS          | Supported                |

<br>

> [!IMPORTANT]
> **.NET 8 and .NET 9 reached End of Support on November 10, 2026.**
> 
> Microsoft no longer provides servicing updates, security fixes, or technical support for these releases.
> 
> LanDX.Templates currently retains the ability to generate .NET 8 and .NET 9 projects for compatibility purposes. However, these target frameworks are no longer recommended for new projects.

### Target Framework Deprecation Policy

Out-of-support target frameworks may remain available in the template for compatibility with existing development environments and projects.

However, their availability is not guaranteed across future template releases. Deprecated target frameworks may eventually be removed as part of a major release, based on maintenance requirements, compatibility considerations, and project direction.

For new projects, we recommend targeting a currently supported .NET release. .NET 10 (LTS) is the recommended when a longer support lifecycle is preferred.

For the latest release information and support dates, refer to Microsoft's official documentation:

- [.NET and .NET Core Support Policy](https://dotnet.microsoft.com/en-us/platform/support/policy/dotnet-core)

- [.NET Releases and Support](https://learn.microsoft.com/dotnet/core/releases-and-support)

- [.NET Downloads](https://dotnet.microsoft.com/download/dotnet)

---

## Prerequisites

- A compatible .NET SDK.
- A terminal with access to the dotnet CLI.
- Git, if you intend to clone the repository or work with version tags.

<br>

Check the installed SDKs:

`dotnet --list-sdks`

<br>

Check the installed Runtimes:

`dotnet --list-runtimes`

<br>

Download the .NET SDK and Runtime from the official website:

[.NET Download](https://dotnet.microsoft.com/download)

[.NET Download (All Versions)](https://dotnet.microsoft.com/en-us/download/dotnet)

[.NET Release and Support](https://learn.microsoft.com/en-us/dotnet/core/releases-and-support)

[.NET Structured Release JSON Data](https://github.com/dotnet/core/blob/main/release-notes/releases-index.json)

---

## Get Started

### Installation

Install the template package from NuGet:

`dotnet new install LanDX.Templates`

<br>

Verify that the template is available:

`dotnet new list landx-templates`

The template short name is **landx-templates**.

---

### Quick Start

Create a Class Library using the default configuration (`-n` is short name for `--name`):

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100`

<br>

Create a project in a specific directory, use `--output` / `-o` (short name):

`dotnet new landx-templates -n MyProject -o path/to/your/project --sdk-version 10.0.100`

<br>

Create a minimal project:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --simple`

<br>

Create a Console Application:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --project-type console`

<br>

Create a project with the full preset:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --preset full`

<br>

Create a project targeting .NET 11:

`dotnet new landx-templates -n MyProject --sdk-version 11.0.100 --target-framework net11.0`

<br>

Create a project using MTP as the test runner:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --test-runner MTP`

<br>

Create a project with a specific license:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --license Apache-2.0`

<br>

The available parameters default values, and normalization rules are described below.

---

## Required Options

### SDK Version

Use `--sdk-version` / `-sdkv` (short name) to specify the .NET SDK version and used by the generated project.

The parameter is ***required*** and has no default value.

The specified SDK version is written to the generated `global.json` file.

Example:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100`

<br>

Supported input formats include:

| Input format            | Example                                      |
| ----------------------- | -------------------------------------------- |
| Major version           | `8`, `9`, `10`, `11`                         |
| Major and minor version | `8.0`, `9.0`, `10.0`, `11.0`                 |
| Full SDK version        | `8.0.428`, `9.0.321`, `10.0.404`, `11.0.100` |
| Version aliases         | `lts`, `sts`, `latest`                       |

<br>

The template normalizes supported inputs according to its configured rules.

> [!IMPORTANT]
> The specified SDK version must be available in the development or build environment. The template ***does not verify*** whether an arbitrary SDK version exists or is available for installation.
> 
> For additional information, see [SDK Version Validation](#sdk-version-validation).

<br>

The generated `global.json` configures the SDK version with the following settings:

- `rollForward`: `latestFeature`

- `allowPrerelease`: `false`

<br>

The selected SDK version also determines the default target framework compatibility and solution file format.

---

### SDK Version Validation

The `--sdk-version` parameter accepts a text value and is ***not restricted*** to a predefined list of SDK versions.

The template normalizes the supplied value but ***does not validate*** whether the specified SDK version has been officially released or is available for installation.

Users are responsible for specifying a valid and available .NET SDK version.

An unsupported or unavailable SDK version may still allow the template to generate project files successfully. However, subsequent .NET CLI operations, such as `dotnet restore`, `dotnet build`, and `dotnet test`, may fail during SDK resolution.

For example, specifying an SDK version that does not exist in the corresponding .NET release history may result in a generated `global.json` that cannot be resolved by the installed .NET SDK.

Always verify the requested SDK version against Microsoft's official .NET release information before generating a project.

References:

- [.NET SDK Releases](https://dotnet.microsoft.com/download/dotnet)

- [.NET Releases and Support](https://learn.microsoft.com/dotnet/core/releases-and-support)

---

## Template Options

### Project Type

Use `--project-type` / `-pt` (short name) to select the project type.

<br>

| Value      | Description                        |
| ---------- | ---------------------------------- |
| `classlib` | Class Library project.             |
| `class`    | Class Library project alias.       |
| `lib`      | Class Library project alias.       |
| `console`  | Console Application project.       |

The default project type is **classlib**.

<br>

Example:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --project-type console`

If `--project-type` is omitted, the template uses its configured default. The current default is intended to be a Class Library.

---

### Test Runner

Use `--test-runner` / `-test` (short name) to select the test runner configuration for the generated test project.

<br>

| Value   | Description                      |
| ------- | -------------------------------- |
| `VTest` | Uses the VSTest test runner.     |
| `MTP`   | Uses Microsoft.Testing.Platform. |

<br>

The default test runner is **VSTest**.

<br>

Example:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --test-runner MTP`

<br>

The selected test runner determines the generated test project configuration and its associated NuGet package references.

#### VSTest

When VSTest is selected, the generated test project uses:

- `Microsoft.NET.Test.SDK`

- `xunit.runner.visualstudio`

- `xunit.v3.mtp-off`

- `coverlet.collector`

#### Microsoft.Testing.Platform (MTP)

When MTP is selected, the generated test project uses:

- `xunit.v3`

- `Microsoft.Testing.Extensions.CodeCoverage`

The generated project also includes the required Microsoft.Testing.Platform configuration.

<br>

**SDK-specific configuration**

The template generates additional configuration depending on the selected SDK version:

| SDK Version       | MTP Configuration                                                            |
| ----------------- | ---------------------------------------------------------------------------- |
| .NET 8 / .NET 9   | Sets `TestingPlatformDotnetTestSupport` in the test project.                 |
| .NET 10 / .NET 11 | Configures `Microsoft.Testing.Platform` as the test runner in `global.json`. |

<br>

.NET 8, .NET 9, .NET 10, .NET 11 all set `UseMicrosoftTestingPlatformRunner` in the test project.

<br>

When `--build-config` or `--preset full` is enabled, the corresponding package versions are centrally managed through `Directory.Packages.props`.

Otherwise, package versions are specified directly in the generated test project file.

The selected test runner does not change the target framework of the generated test project.

---

### Presets

Use `--preset` / `-ps` (short name) to select a predefined project configuration.

<br>

| Preset     | Description |
| ---------- | ----------- |
| `standard` | Includes the common project files, source project, and test project. |
| `full`     | Enables the optional documentation, GitHub Actions, benchmarks, and build configuration, together with automatic LTS SDK and target framework selection. |

<br>

The default preset is **standard**.

<br>

When `--simple` and `--preset full` are specified together, `--preset full` takes precedence. 

<br>

Create a standard project:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --preset standard`

<br>

Create a full project:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --preset full`

<br>

The full preset enables the equivalent of the following options:

- `--docs`

- `--github-actions`

- `--benchmarks`

- `--build-config`

- Latest stable LTS target framework selection

The exact SDK and target framework versions depend on the template's normalization rules and the available version metadata.

---

### Simple Mode

Use `--simple` / `-smp` (short name) to generate a minimal project structure.

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --simple`

The simple configuration includes the common project files and source project, without the test project or optional components.

When `--simple` and `--benchmarks` are specified together, `--simple` takes precedence and the benchmark project is not included.

---

### Optional Components

The following switches enable additional files or directories.

<br>

| Option             | Description                                                                                                    |
| ------------------ | -------------------------------------------------------------------------------------------------------------- |
| `--docs`           | Includes the **docs**/ directory and architecture decision records.                                            |
| `--github-actions` | Includes the **.github**/ directory and workflow configuration.                                                |
| `--benchmarks`     | Includes the **benchmarks**/ directory and benchmark project.                                                  |
| `--build-config`   | Includes shared **MSBuild** and **NuGet** configuration files and relocate them to the generated project root. |

<br>
<br>

| Option             | Short Name |
| ------------------ | ---------- |
| `--docs`           | `-dc`      |
| `--github-actions` | `-ga`      |
| `--benchmarks`     | `-bm`      |
| `--build-config`   | `-bc`      |

<br>

For example:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --docs --github-actions --benchmarks --build-config`

Optional components are excluded unless enabled by the selected preset or explicit options, subject to the precedence rules described in this document.

---

### Target Framework

Use `--target-framework` / `-tfm` (short name) to select the target framework for the generated project files.

<br>

Supported inputs include:

| Inputs                                            | Target framework |
|---------------------------------------------------|------------------|
| `net8.0`, `net8`, `8`, `8.0`                      | `net8.0`         |
| `net9.0`, `net9`, `9`, `9.0`                      | `net9.0`         |
| `net10.0`, `net10`, `10`, `10.0`, `lts`           | `net10.0`        |
| `net11.0`, `net11`, `11`, `11.0`, `sts`, `latest` | `net11.0`        |

<br>

The default target framework is **net10.0**.

#### SDK Compatibility and Target Framework Normalization

The requested target framework is automatically normalized to ensure compatibility with the selected SDK version.

If the requested target framework is higher than the selected SDK version, the template adjusts the target framework to match the SDK's major version.

If the requested target framework is equal to or lower than the selected SDK version, the requested target framework is preserved.

For example:

| SDK Version | Requested Target Framework | Generated Target Framework |
| ----------- | -------------------------- | -------------------------- |
| `8.0.428`   | `net11.0`                  | `net8.0`                   |
| `9.0.321`   | `net11.0`                  | `net9.0`                   |
| `10.0.404`  | `net11.0`                  | `net10.0`                  |
| `11.0.100`  | `net10.0`                  | `net10.0`                  |
| `11.0.100`  | `net11.0`                  | `net11.0`                  |

<br>

This behavior prevents the generated project from targeting a framework version higher than the selected SDK version.

Example:

`dotnet new landx-templates -n MyProject --sdk-version 8.0.428 --target-framework net11.0`

The resulting project targets `net8.0`.

<br>

The normalized target framework is applied consistently to the generated project files, including the source project, test project, and benchmark project when applicable.

---

### GitHub Metadata

Use `--github-owner` / `-owner` (short name) to configure the GitHub user or organization used by the generated README badge URL.

Use `--github-repo` / `-repo` (short name) to configure the repository name used by the badge and repository hyperlink.

<br>

Example:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --github-owner LanDX --github-repo MyProject`

<br>

The template normalizes the repository name used in the badge URL by replacing hyphens with double hyphens where required by the badge format. The repository hyperlink retains the original repository name.

<br>

Ensure that the supplied owner and repository values correspond to the intended GitHub repository.

---

### License

Use `--license` / `-lcn` (short name) to select the license for the generated project.

<br>

The default license is **MIT**.

<br>

### Supported Licenses

LanDX.Templates currently supports generating projects with the following 10 open-source licenses:

| SPDX License Identifier | License Name                                 | Generated File(s)               |
| ----------------------- | -------------------------------------------- | ------------------------------- |
| MIT                     | MIT License                                  | **LICENSE**                     |
| ISC                     | ISC License                                  | **LICENSE**                     |
| BSD-2-Clause            | BSD 2-Clause License                         | **LICENSE**                     |
| BSD-3-Clause            | BSD 3-Clause License                         | **LICENSE**                     |
| GPL-2.0-only            | GNU General Public License v2.0 only         | **COPYING**                     |
| GPL-3.0-only            | GNU General Public License v3.0 only         | **COPYING**                     |
| LGPL-2.1-only           | GNU Lesser General Public License v2.1 only  | **COPYING**, **COPYING.LESSER** |
| AGPL-3.0-only           | GNU Affero General Public License v3.0 only  | **COPYING**                     |
| MPL-2.0                 | Mozilla Public License 2.0                   | **LICENSE**                     |
| Apache-2.0              | Apache License 2.0                           | **LICENSE**                     |

<br>

### Usage

Specify a license identifier when generating a project:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --license Apache-2.0`

Additional examples:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --license MIT`

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --license BSD-3-Clause`

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --license GPL-3.0-only`

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --license LGPL-2.1-only`

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --license AGPL-3.0-only`

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --license MPL-2.0`

<br>

### License File Generation

The template automatically generates the license file(s) corresponding to the selected license.

Depending on the selected license, the generated project includes:

- **LICENSE**

- **COPYING**

- **COPYING**, **COPYING.LESSER**

Only the files required by the selected license are generated.

The generated **README** also updates its `## License section` and `license badge` to reflect the selected license identifier.

<br>

---

### Copyright Information

Use the following parameters to customize copyright information in the generated license file(s):

| Option              | Short Name | Description              |
| ------------------- | ---------- | ------------------------ |
| `--copyright-year`  | `-cyear`   | Sets the copyright year  |
| `--copyright-owner` | `-cowner`  | Sets the copyright owner |

<br>

Example:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --license MIT --copyright-year 2026 --copyright-owner "John Doe"`

The default values are placeholders. Specify the appropriate copyright year and copyright owner/holder when generating your project, and review the generated license file(s) before distribution.

**Important Notes**

- The default license is **MIT** when --license is omitted.

- Use one of the supported license identifier listed above.

- The generated license file(s), README license section, and license badge are configured according to the selected license.

- Selecting a license does not constitute legal advice. Review the applicable license terms before distributing your project.

For official license identifiers and their definitions, see the SPDX License List.

[&rarr; SPDX License List](https://spdx.org/licenses/)

---

### C# Source File Headers

The selected license also determines the license-related headers generated in C# source files.

The template automatically generates the following information:

- SPDX license identifier.

- Copyright notice.

- License-specific header and license statement.

<br>

These headers are generated consistently across the applicable C# source files in the generated project, including:

- `src/**/*.cs`

- `tests/**/*.cs`

- `benchmarks/**/*.cs`

<br>

The generated headers reflect the selected `--license`, `--copyright-year`, and `--copyright-owner` parameters.

For example, when MIT is selected, the generated source file begins with:

```csharp
// SPDX-License-Identifier: MIT
// 
// Copyright (C) 2026 John Doe
```

For license that require addtional notices, the template generates the corresponding license-specific header.

The generated source file headers are intended to identify the applicable license and copyright information. They do not replace the complete license file(s) generated in the project root.

---

## Generated Project Structure

### Default Structure

```txt
MyNamespace.MyProject/
├── src/
│   └── MyNamespace.MyProject/
│       ├── MyNamespace.MyProject.csproj
│       ├── MyClass.cs
│       └── Program.cs              # Console only
├── tests/                          # Excluded by --simple
│   └── MyNamespace.MyProject.Tests/
│       ├── MyNamespace.MyProject.Tests.csproj
│       └── UnitTest1.cs
├── .editorconfig
├── .gitattributes
├── .gitignore
├── global.json                     # Generated using required --sdk-version
├── LICENSE                         # Default MIT
├── MyNamespace.MyProject.sln[x]    # .sln for .NET SDK 8; .slnx for .NET SDK 9 and later
└── README.md
```

### Optional Structure

```txt
MyNamespace.MyProject/
├── .github/                              # --github-actions
│   └── workflows/
│       └── workflow.yaml
├── benchmarks/                           # --benchmarks
│   └── MyNamespace.MyProject.Benchmarks/
├── docs/                                 # --docs
│   └── architecture-decision-records.md
├── Directory.Build.props                 # --build-config
├── Directory.Build.targets               # --build-config
└── Directory.Packages.props              # --build-config
```

<br>

When `--build-config` is enabled, the shared configuration files are relocated to the generated project root. The exact generated structure depends on the selected options and parameter precedence.

The solution file is also configured to include the appropriate project folders for the selected project structure.

---

## Examples

### Minimal Class Library

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --simple --project-type classlib`

<br>

### Standard Console Application

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --project-type console`

<br>

### Full Class Library Targeting .NET 10

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --preset full --project-type classlib --target-framework net10.0`

<br>

### Custom SDK and Target Framework

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --target-framework net9.0`

---

### SDK-Dependent Generated Files

Some generated files are configured according to the selected SDK version and test runner.

| Generated File   | Condition                     | Configuration                                                 |
| ---------------- | ----------------------------- | ------------------------------------------------------------- |
| `global.json`    | MTP with .NET SDK 10 or later | Includes `test.runner` set to `Microsoft.Testing.Platform`.   |
| `*.Tests.csproj` | MTP selected                  | Includes MTP-specific test properties and package references. |
| `*.sln`          | .NET SDK 8                    | Uses the legacy solution format.                              |
| `*.slnx`         | .NET SDK 9 or later           | Uses the XML-based solution format.                           |

When `--build-config` or `--preset full` is enabled, test package versions are centrally managed through `Directory.Packages.props`.

---

## Development

This section describes how to develop, test, and package the template itself, rather than a project generated from it.

---

### Repository Structure

```txt
LanDX.Templates/
├── .github/
│   └── workflows/
│       └── publish-nuget.yml
├── content/
│   └── landx-templates/
│       ├── .template.config/
│       │   ├── dotnetcli.host.json
│       │   └── template.json
│       ├── src/
│       ├── tests/
│       ├── README.md
│       └── ...
├── tests/
│   ├── artifacts/                       # Generated test projects
│   ├── logs/                            # Structural assertion reports
│   └── create-and-test-templates.ps1    # Local test automation
├── docs/
│   └── architecture-decision-record.md
├── LanDX.Templates.csproj
├── LICENSE
├── README.md
└── README.NuGet.md
```

The `content/landx-templates/` directory contains the source files for the generated template. Its `.template.config/template.json` defines the template identity, parameters, normalization rules, and file inclusion behavior.

The root `LanDX.Templates.csproj` packages the template content into a NuGet package.

The `tests/` directory contains the local template verification script, generated test artifacts, and structural assertion reports.

- `tests/artifacts/` stores projects generated during test execution.

- `tests/logs/` stores per-test-case structureal assertion reports.

Build output and intermediate files are generated under **bin/** and **obj/** when applicable.

---

### Create the Template Pack Project

The template pack project was created using Microsoft's Template Authoring Templates:

```txt
dotnet new install Microsoft.TemplateEngine.Authoring.Templates
dotnet new templatepack -n LanDX.Templates
```

These commands install the authoring templates and create a template pack project. They are setup steps for developing the template, not commands required by users who install the published package.

---

### Test Locally

The repository includes a PowerShell-based test suite for verifying the behavior of the template during development.

The test suite generates projects using different template configurations, checks the generated project structure, and executes applicable .NET CLI operations to verify that the generated projects can be built, tested, and run.

#### Prerequisites

- PowerShell 7.6.8 or later (PowerShell Core)

- .NET SDKs for .NET 8, .NET 9, .NET 10, and .NET 11.

- The `landx-templates` template must be installed and available through the local .NET CLI.

The test script requires PowerShell 7.6.8 or later and explicitly selects SDK versions 8, 9, 10, and 11 across its test cases.

#### Install the Local Template

Before running the test suite, ensure that the template from the current repository source is installed.

From the repository root, run:

`dotnet new install ./content/landx-templates`

Verify that the template is available:

`dotnet new list landx-templates`

Make sure the installed template corresponds to the current source being tested rather than an older published package version.

#### Run the Test Suite

Execute the test script from the repository root:

`pwsh -NoProfile -File ./tests/create-and-test-templates.ps1`

Alternatively, run it directly from PowerShell:

`./tests/create-and-test-templates.ps1`

The script automatically generates test projects under `tests/artifacts/`, performs structural validation, and executes the applicable .NET CLI operations.

#### Test Artifacts and Logs

The test script automatically creates the `artifacts/` and `logs/` directories under `tests/`.

The generated directory structure is as follows:

```txt
tests/
├── artifacts/
│   ├── T01.DefaultClassLibrary/
│   ├── ...
│   └── B16.NormalizedCorrespondingTfm/
├── logs/
│   ├── T01.DefaultClassLibrary.log
│   ├── ...
│   ├── B15.DefaultClassLibWithSln.log
│   └── B16.NormalizedCorrespondingTfm.log
└── create-and-test-templates.ps1
```

The `artifacts/` directory stores the generated projects used by the test suite.

The `logs/` directory stores structural assertion reports for project-generation test cases (T01-T15 and B01-B16).

The logs are generated by `Invoke-TestCase` and contain:

- Local and UTC timestamps for the test section.

- The corresponding test case name.

- Assertion results indicating whether expected generated files exist.

- Section separators used to organize the results.

For example:

```txt

Local Date Time: 2026-11-22T16:47:36+08:00

Universal Date Time: 2026-11-22T08:47:36Z

------------------------------------------------------
T01.DefaultClassLibrary
------------------------------------------------------

------------------------------------------------------
    - [T01] Passed: Assertion existence - ".editorconfig"
    - [T01] Passed: Assertion existence - ".gitattributes"
    - [T01] Passed: Assertion existence - ".gitignore"
    - [T01] Passed: Assertion existence - "README.md"
    - [T01] Passed: Assertion existence - "LICENSE"
    - [T01] Passed: Assertion existence - "T01.DefaultClassLibrary.slnx"
    - [T01] Passed: Assertion existence - "global.json"
    - [T01] Passed: Assertion existence - "MyClass.cs"
    - [T01] Passed: Assertion existence - "T01.DefaultClassLibrary.csproj"
    - [T01] Passed: Assertion existence - "UnitTest1.cs"
    - [T01] Passed: Assertion existence - "T01.DefaultClassLibrary.Tests.csproj"
------------------------------------------------------

```

#### Logging Behavior

- **Separate assertion reports:** Each project-generation test case handled by `Invoke-TestCase` writes its assertion results to a separate .log file.

- **Automatic generation:** The `logs/` directory is created automatically when the test script runs.

- **Overwrite existing reports:** Existing test logs are removed at the beginning of a test run, and the corresponding files are written again as their test cases execute.

- **Assertion-only content:** Log files contain explicitly recorded structural assertion results. They are not complete console transcripts or test execution logs.

- **Terminal output:** PowerShell write-Host messages and .NET CLI output are displayed directly in the terminal. Their console output is not captured in these log files.

- **Plain-text format:** Log files contain plain-text assertion messages without console foreground/background color information.

The log files are intended to provide a convenient way to inspect whether the expected generated files exist for each project configuration.

#### Command test cases (**C00-C01** and **E00-E04**) do not currently generate individual log files.

Their command output is displayed in the terminal only.

The `tests/logs/` directory is intended for local diagnostic output and should be excluded from source control.

#### Test Coverage

The test suite is organized into the following test groups:

| Test Group | Coverage |
| ---------- | -------- |
| T01-T15 | Default configurations, Class Library and Console Application generation, simple mode, optional components, SDK and target framework selection, license, and VSTest/MTP configurations. |
| B01-B16 | Combined parameter configurations, feature precedence, preset interactions, SDK and target framework compatibility, project type variations, benchmark integration, and solution format selection. |
| C00-C01 | .NET CLI help output and template discovery commands. |
| E00-E04 | Negative test cases covering missing required parameters and unsupported parameter values. |

The test suite covers both individual template options and combinations of parameters to exercise configuration precedence and conditional file generation.

#### Automated Validation

For each generated project, the test script performs the applicable checks.

**1. Structural validation**

The script checks the existence of expected generated files and directories, including:

- Common repository/project files such as .editorconfig, .gitattributes, .gitignore, and README.md.

- License files corresponding to the selected license type.

- The generated solution file and global.json.

- Required source project files.

- Test project files when applicable.

- Benchmark, documentation, GitHub Actions, and shared build configuration files when enabled.

These checks verify the existence of the expected paths. They do not inspect the contents of the generated files.

**2. Build and execution validation**

The script executes the following .NET CLI commands for generated projects:

```text
dotnet clean
dotnet restore
dotnet build --no-restore
```

For configurations that include a test project, it also executes:

`dotnet test --no-build`

For console Applications, the script additionally runs the generated application using:

`dotnet run`

These operations provide basic verification that the generated projects can be cleaned, restored, built, tested, and executed as applicable.

Their standard output and standard error are displayed in the terminal and are not included in the structural assertion reports.

**3. Command validation**

The test suite executes additional .NET CLI scenarios:

- C00: Displays template help information.

- C01: Lists the installed LanDX.Templates.

- E00: Checks the expected exit code when the required `--sdk-version` parameter is missing.

- E01-E04: Checks the expected exit codes for invalid project type, target framework, preset, and license values.

The negative test cases validate their expected native process exit codes. The help and template discovery cases currently display their command output for inspection but do not perform automated content matching against that output.

**4. Current Validation Scope**

The current test suite combines structural existence checks with basic .NET CLI execution checks.

> [!IMPORTANT]
> **The automated structural checks do not yet perform comprehensive content-level validation of generated files.**

In particular, the current automated checks do not verify the following:

- **C# source file content:** SPDX license identifiers, copyright notices, and license-specific source headers.

- **License file contents:** Correct license text, copyright information, and license-specific notices.

- **Project configuration:** Exact PackageReference, ProjectReference, target framework, and other MSBuild property values in generated .csproj files.

- **SDK configuration:** Expected property values and configuration in the generated global.json.

- **Generated documentation:** Correct source-name replacements, repository URLs, badges, and license information in the generated README.md.

- **Solution configuration:** Exact project entries, project paths, and solution folder organization.

Although the script executes restore, build, test, and run operations, successful execution does not guarantee that every generated configuration value, file reference, or textual substitution matches its intended value.

The current assertion reports only record the existence checks performed by the script. Additional content-level validation may be introduced in future updates to improve automated verification and reduce the need for manual inspection.

---

### Package Locally

Build the NuGet package from the repository root:

`dotnet pack -c Release`

The package is generated under the configured output directory. With the current default project configuration, the initial package was produced at:

`bin/Release/LanDX.Templates.1.0.0.nupkg`

The output path and package version may change with project configuration and release updates.

Before publishing, verify the package contents, package metadata, version, template configuration, and generated project behavior.

---

## Publishing

LanDX.Templates uses GitHub Actions and NuGet Trusted Publishing to publish versioned template packages.

The publishing workflow is defined in:

`.github/workflows/publish-nuget.yml`

---

### Release Process

The workflow is triggered by Git tags matching:

`v*.*.*`

For example:

```txt
git add .
git commit -m "Prepare release"
git push
```

After updating the package version in the project configuration as required, create and push a release tag:

```txt
git tag v1.0.0
git push origin v1.0.0
```

Use the version that matches the intended release. Ensure that the package version configured in the project and the Git tag agree.

---

### GitHub Actions Workflow

The publishing workflow performs the following steps:

1. Checks out the repository.

2. Sets up the .NET SDK.

3. Packs the NuGet package into an artifacts/ directory.

4. Authenticates with NuGet using Trusted Publishing.

5. Publishes the generated .nupkg package to NuGet.org.

The workflow uses the following permissions:

- contents: read to access the repository.

- id-token: write to support OIDC-based authentication.

The NuGet/login@v1 action exchanges the GitHub Actions identity for temporary publishing credentials. The workflow then passes the resulting API key to dotnet nuget push.

---

### Trusted Publishing Configuration

The publishing workflow expects a GitHub Actions repository secret named:

`NUGET_USER`

Its value is the NuGet username configured for the Trusted Publishing integration, not an email address or a NuGet API key.

The corresponding Trusted Publishing configuration must authorize the intended GitHub repository and workflow identity.

Do not commit publishing credentials, tokens, or secrets to source control.

For details, see the official documentation:

- NuGet Trusted Publishing

- GitHub Actions documentation

---

## Troubleshooting

### The template is not listed

Run:

`dotnet new list landx-templates`

If the template is missing, install the package again:

`dotnet new install LanDX.Templates`

<br>

### A parameter value is rejected

Check the supported choices with:

`dotnet new landx-templates --help`

The template validates project type, preset, and target framework choices. Unsupported values should cause generation to fail.

<br>

### An unexpected SDK or target framework is generated

Check the supplied version parameters and their precedence.

`--version` takes precedence over `--sdk-version` and `--target-framework`. When automatic version selection is activated, the template may select the latest stable LTS SDK and target framework.

Inspect global.json and the generated .csproj files to confirm the resulting values.

<br>

### A generated project fails to build

Verify that the required SDK is installed:

`dotnet --list-sdks`

Check global.json, the target framework, the solution file, and any relocated build configuration files.

Restore and build the generated project to identify the actual error:

```txt
dotnet restore
dotnet build
```

<br>

### A NuGet release fails

Verify that:

- The pushed tag matches the workflow's tag pattern.

- The package version is correct.

- NUGET_USER is configured as a GitHub Actions repository secret.

- The NuGet Trusted Publishing configuration authorizes the intended GitHub repository and workflow.

- The workflow has the required OIDC permissions.

- The package has not already been published under the same package ID and version.

Review the failed GitHub Actions run for the specific error.

<br>

### The README badge does not display correctly

Check the generated badge URL, GitHub user or organization, repository name, and license identifier. Confirm that the normalized repository name is used only in the badge URL and that the repository hyperlink retains the original name.

<br>

### SDK version cannot be resolved

Verify that the SDK version specified through `--sdk-version` exists and is available in your environment.

The template ***does not validate*** SDK availability during project generation.

Check the installed SDK versions:

`dotnet --list-sdks`

Compare the requested version with the official .NET SDK release history.

If the specified SDK version is unavailable, update the generated `global.json` or regenerate the project using a valid SDK version.

<br>

### Target framework differs from the requested value

The template automatically normalizes the requested target framework when it exceeds the selected SDK version.

Check the generated `.csproj` files to verify the normalized target framework.

Specify an SDK version compatible with the desired target framework if you need to target a newer .NET release.

<br>

### The local test script cannot run

Verify that PowerShell Core 7.6.8 or later installed:

`$PSVersionTable`

The local test suite uses .NET 8, 9, 10, and 11. Missing SDK versions may cause the corresponding test cases to fail.

Also verify that the local template source had been installed:

`dotnet new list landx-templates`

If the template is missing or an outdated version is being used, install the template from the current repository source.

---

## License

This repository is licensed under the MIT License.

See LICENSE for the complete license text.