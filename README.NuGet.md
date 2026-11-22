# LanDX.Templates

[![NuGet](https://img.shields.io/badge/NuGet-LanDX.Templates-blue?logo=nuget)](https://www.nuget.org/packages/LanDX.Templates)
[![NuGet](https://img.shields.io/nuget/v/LanDX.Templates?label=NuGet&logo=nuget&color=darkorange)](https://www.nuget.org/packages/LanDX.Templates/)

[![Repository](https://img.shields.io/badge/GitHub-landx--templates-blue?logo=github)](https://github.com/johnny60904/landx-templates)
[![License](https://img.shields.io/badge/license-MIT-green)](https://opensource.org/license/mit)

LanDX.Templates is a customizable .NET CLI template for generating modern C# Class Library and Console Application projects targeting .NET 8, .NET 9, .NET 10, and .NET 11.

Generate a ready-to-use solution structure with .slnx, .csproj, and common development configuration files. Choose a minimal project structure, use the standard configuration, or enable optional development tooling through template parameters.

---

## Installation

Install the template using the .NET CLI:

`dotnet new install LanDX.Templates`

Verify the installation:

`dotnet new list landx-templates`

---

## Quick Start

Create a Class Library using the default configuration:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100`

Create a minimal project:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --simple`

Create a Console Application:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --project-type console`

Create a project with the full preset:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --preset full`

Create a project with a specific license:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --license Apache-2.0`

Create a project using MTP as the test runner:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --test-runner MTP`

---

## .NET Version Support

> **IMPORTANT**
> 
> **.NET 8 and .NET 9 reached End of Support on November 10, 2026.**
> 
> Microsoft no longer provides servicing updates, security fixes, or technical support for these releases.
> 
> This template currently supports generating projects targeting .NET 8 and .NET 9. However, these versions are no longer supported by Microsoft and are not recommended for new projects.
> 
> **Support for out-of-support target frameworks may be deprecated or removed in future template releases.**
> 
> For new projects, we recommend targeting a currently supported .NET release, such as .NET 10 (LTS) or .NET 11 (STS).
> 
> For details, refer to Microsoft's .NET Support Policy.
> 
> [&rarr; Microsoft Support Policy](https://dotnet.microsoft.com/platform/support/policy)

---

## SDK Version and Target Framework Compatibility

The `--sdk-version` parameter is required and has no default value.

The template automatically normalizes the requested target framework when it exceeds the selected SDK version.

For example, specifying `--sdk-version 8.0.428` together with `--target-framework net11.0` results in a project targeting `net8.0`.

The template ***does not validate*** whether an arbitrary SDK version exists or is available for installation.

Users are responsble for specifying a valid and available .NET SDK version. An unsupported SDK version may allow project generation to  succeed but cause subsequent .NET CLI operations to fail during SDK resolution.

Verify the requested SDK version against the official .NET release information before generateing a project.

[&rarr; .NET SDK Releases](https://dotnet.microsoft.com/download/dotnet)

---

## Requirements

Install a compatible .NET SDK for the generated project's target framework and any SDK version requested by global.json.

Download the .NET SDK:

[.NET Download](https://dotnet.microsoft.com/download)

[.NET Download (All Versions)](https://dotnet.microsoft.com/en-us/download/dotnet)

---

## Features

- Generate Class Library and Console Application projects.

- Support .NET 8, .NET 9, .NET 10, and .NET 11 target frameworks.

- Require an explicit .NET SDK version through `--sdk-version`.

- Automatically normalize the target framework to ensure compatibility with the selected SDK version.

- Generate SDK-compatible solution files (`.sln` for .NET SDK 8 and `.slnx` for .NET SDK 9 and later).

- Provide standard, simple, and full project configurations.

- Include optional test and benchmark projects.

- Support VSTest and Microsoft.Testing.Platform (MTP) test runners.

- Generate runner-specific test project, package, and SDK configurations.

- Include optional architecture documentation and GitHub Actions workflows.

- Support centralized MSBuild and NuGet package configuration.

- Support 10 open-source licenses.

- Generate license-specific SPDX identifiers, copyright notices, and license headers in C# source files.

- Customize license copyright information.

- Automatically normalize supported SDK version, target framework, and license inputs.

---

## Required Options

| Option               | Description                                                                     |
|----------------------|---------------------------------------------------------------------------------|
| `--sdk-version`      | Configures the SDK version in global.json.                                      | 

---

## Common Options

| Option               | Description                                                                       |
|----------------------|---------------------------------------------------------------------------------- |
| `--sdk-version`      | **Required.** Specifies the .NET SDK version used by the generated `global.json`. |
| `--project-type`     | Selects `classlib` (default), `lib`, or `console`.                                |
| `--simple`           | Generates a minimal project without tests or optional components.                 |
| `--preset`           | Selects `standard` (default) or `full`.                                           |
| `--test-runner`      | Selects `VSTest` (default) or `MTP`.                                              |
| `--target-framework` | Selects the target framework: .NET 8, 9, 10 (default), or 11. Automatically normalized when it exceeds the selected SDK version. |
| `--benchmarks`       | Includes the benchmark project.                                                   |
| `--docs`             | Includes architecture documentation.                                              |
| `--github-actions`   | Includes GitHub Actions workflows.                                                |
| `--build-config`     | Includes shared build configuration files.                                        |
| `--license`          | Selects the project license. (default: MIT)                                       |
| `--copyright-year`   | Sets the copyright year in the generated license file(s) and source headers.      |
| `--copyright-owner`  | Sets the copyright owner in the generated license file(s) and source headers.     |
| `--github-owner`     |  Sets the GitHub owner used in generated README links and badges.                 |
| `--github-repo`      |  Sets the repository name used in generated README links and badges.              |

<br>

When `--simple` and `--benchmarks` are specified together, `--simple` takes precedence.

When `--simple` and `--preset full` are specified together, `--preset full` takes precedence.

The default project type is classlib (lib).

The default license is MIT.

The default target framework is net10.0.

The default preset is standard. The full preset enables optional components and automatic stable LTS target framework selection, subject to explicit parameter precedence.

For all supported values, normalization rules, examples, and generated project details, see the full documentation.

---

## Test Runner

Use `--test-runner` to select the test runner for the generated test project.

| Value   | Description                            |
| ------- | -------------------------------------- |
| `VTest` | Uses the VSTest test runner (default). | 
| `MTP`   | Uses Microsoft.Testing.Platform.       |

Example:

`dotnet new landx-templates -n MyProject --sdk-version 10.0.100 --test-runner MTP`

The selected test runner determines the generated test project configuration and its associated NuGet package references.

When MTP is selected, the template also generates SDK-specific configuration:

- .NET SDK 8 and 9: Configures MTP support in the test project.

- .NET SDK 10 and 11: Configures Microsoft.Testing.Platform in `global.json`.

When `--build-config` or `--preset full` is enabled, the corresponding test package versions are centrally managed through `Directory.Packages.props`.

---

## License Selection

Use `--license` to select the license for the generated project.

`dotnet new landx-templates -n MyProject --sdk-version 10 --license ISC`

The following 10 licenses are supported:

| License Identifier | License                                     |
| ------------------ | ------------------------------------------- |
| MIT                | MIT License                                 |
| ISC                | ISC License                                 |
| Apache-2.0         | Apache License 2.0                          |
| BSD-2-Clause       | BSD 2-Clause "Simplified" License           |
| BSD-3-Clause       | BSD 3-Clause "New" or "Revised" License     |
| GPL-2.0-only       | GNU General Public License v2.0 only        |
| GPL-3.0-only       | GNU General Public License v3.0 only        |
| LGPL-2.1-only      | GNU Lesser General Public License v2.1 only |
| AGPL-3.0-only      | GNU Affero General Public License v3.0 only |
| MPL-2.0            | Mozilla Public License 2.0                  |

<br>

The selected license determines the license file or files generated in the project root:

| License       | Generated File(s)       |
| ------------- | ----------------------- |
| MIT           | LICENSE                 |
| ISC           | LICENSE                 |
| Apache-2.0    | LICENSE                 |
| BSD-2-Clause  | LICENSE                 |
| BSD-3-Clause  | LICENSE                 |
| GPL-2.0-only  | COPYING                 |
| GPL-3.0-only  | COPYING                 |
| LGPL-2.1-only | COPYING, COPYING.LESSER |
| AGPL-3.0-only | COPYING                 |
| MPL           | LICENSE                 |

You can also customize the copyright information:

`dotnet new landx-templates -n MyProject --sdk-version 10 --license MIT --copyright-year 2026 --copyright-owner "John Doe"`

The selected license is reflected in the generated README and its corresponding license file or files.

---

## Documentation

For detailed documentation, examples, supported parameter values, project structure, and development instructions, visit:

- GitHub Repository and Full Documentation

- Template Source and Configuration

- Report an Issue

---

## License

LanDX.Templates is licensed under the MIT License.

See the LICENSE file for details.