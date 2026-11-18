# LanDX.Templates

[![NuGet](https://img.shields.io/badge/NuGet-LanDX.Templates-blue?logo=nuget)](https://www.nuget.org/packages/LanDX.Templates)
[![NuGet](https://img.shields.io/nuget/v/LanDX.Templates?label=NuGet&logo=nuget&color=darkorange)](https://www.nuget.org/packages/LanDX.Templates/)

[![Repository](https://img.shields.io/badge/GitHub-landx--templates-blue?logo=github)](https://github.com/johnny60904/landx-templates)
[![License](https://img.shields.io/badge/license-MIT-green)](https://opensource.org/license/mit)

LanDX.Templates is a customizable .NET CLI template for generating modern C# Class Library and Console Application projects targeting .NET 8, .NET 9, .NET 10, and .NET 11.

Generate a read-to-use solution structure with .slnx, .csproj, and common development configuration files. Choose a minimal project structure, use the standard configuration, or enable optional development tooling through template parameters.

---

## Installation

Install the template using the .NET CLI:

`dotnet new install LanDX.Templates`

Verify the installation:

`dotnet new list landx-templates`

---

## Quick Start

Create a Class Library using the default configuration:

`dotnet new landx-templates -n MyProject`

Create a minimal project:

`dotnet new landx-templates -n MyProject --simple`

Create a Console Application:

`dotnet new landx-templates -n MyProject --project-type console`

Generate a project with the full preset:

`dotnet new landx-templates -n MyProject --preset full`

Generate a project with a specific license:

`dotnet new landx-templates -n MyProject --license Apache-2.0`

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

## Features

- Class Library and Console Application project types.

- Standard, simple, and full project configurations.

- Configurable SDK version and target framework.

- Optional test and benchmark projects.

- Optional architecture documentation.

- Optional GitHub Actions workflows.

- Optional centralized MSBuild and NuGet package configuration.

- Multiple license templates: MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC, GPL-2.0-only, GPL-3.0-only, LGPL-2.1-only, AGPL-3.0-only, and MPL-2.0.

- Automatic license file generation with configurable copyright information.

- Automatic normalization of supported version and license inputs.



---

## Common Options

| Option               | Description                                                                     |
|----------------------|---------------------------------------------------------------------------------|
| `--project-type`     | Selects class, classlib, lib, or console.                                       |
| `--simple`           | Generates a minimal project without tests or optional components.               |
| `--preset`           | Selects standard or full.                                                       |
| `--target-framework` | Selects the target framework: .NET 8, 9, 10, or 11.                             |
| `--sdk-version`      | Configures the SDK version in global.json.                                      |
| `--version`          | Applies a shared version input to SDK selection and target framework selection. |
| `--benchmarks`       | Includes the benchmark project.                                                 |
| `--docs`             | Includes architecture documentation.                                            |
| `--github-actions`   | Includes GitHub Actions workflows.                                              |
| `--build-config`     | Includes shared build configuration files.                                      |
| `--license`          | Selects the license for the generated project.                                  |
| `--copyright-year`   | Sets the copyright year in the generated license file.                          |
| `--copyright-owner`  | Sets the copyright owner in the generated license file.                         |
| `--github-owner`     |  Sets the GitHub owner used in generated README links and badges.               |
| `--github-repo`      |  Sets the GitHub repository name used in generated README links and badges.     |

When conflicting version parameters are specified, `--version` takes precedence over `--sdk-version` and `--target-framework`.

When `--simple` and `--benchmarks` are specified together, `--simple` takes precedence.

The default preset is standard. The full preset enables optional components and automatic stable LTS SDK and target framework selection, subject to explicit parameter precedence.

For all supported values, normalization rules, examples, and generated project details, see the full documentation.

---

## License Seletion

Use `--license` to select the license for the generated project.

`dotnet new landx-templates -n MyProject --license ISC`

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

`dotnet new landx-templates -n MyProject --license MIT --copyright-year 2026 --copyright-owner "John Doe"`

The selected license is reflected in the generated README and its corresponding license file or files.

---

## Requirements

Install a compatible .NET SDK for the generated project's target framework and any SDK version requested by global.json.

Download the .NET SDK:

[.NET Download](https://dotnet.microsoft.com/download)

[.NET Download (All Versions)](https://dotnet.microsoft.com/en-us/download/dotnet)

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