# LanDX.Templates

[![NuGet](https://img.shields.io/badge/NuGet-LanDX.Templates-blue?logo=nuget)](https://www.nuget.org/packages/LanDX.Templates)
[![NuGet](https://img.shields.io/nuget/v/LanDX.Templates?label=NuGet&logo=nuget&color=darkorange)](https://www.nuget.org/packages/LanDX.Templates/)

[![Repository](https://img.shields.io/badge/GitHub-landx--templates-blue?logo=github)](https://github.com/johnny60904/landx-templates)
[![License](https://img.shields.io/badge/license-MIT-green)](https://opensource.org/license/mit)

LanDX.Templates is a customizable .NET CLI template for generating modern C# Class Library and Console Application projects targeting .NET 8, .NET 9, and .NET 10.

Choose a minimal project structure, use the standard configuration, or enable optional development tooling through template parameters.

---

## Installation

Install the template using the .NET CLI:

`dotnet new install LanDX.Templates`

Verify the installation:

`dotnet new list landx-templates`

---

## Quick Start

Create a Class Library using the default configuration:

`dotnet new landx-templates -n <your-project-name>`

Create a minimal project:

`dotnet new landx-templates -n <your-project-name> --simple`

Create a Console Application:

`dotnet new landx-templates -n <your-project-name> --project-type console`

Generate a project with the full preset:

`dotnet new landx-templates -n <your-project-name> --preset full`

---

## Features

- Class Library and Console Application project types.

- Standard, simple, and full project configurations.

- Configurable SDK version and target framework.

- Optional test and benchmark projects.

- Optional architecture documentation.

- Optional GitHub Actions workflows.

- Optional centralized MSBuild and NuGet package configuration.

- Automatic normalization of supported version inputs.

---

## Common Options

| Option               | Description                                                                     |
|----------------------|---------------------------------------------------------------------------------|
| `--project-type`     | Selects class, classlib, lib, or console.                                       |
| `--simple`           | Generates a minimal project without tests or optional components.               |
| `--preset`           | Selects standard or full.                                                       |
| `--target-framework` | Selects the target framework: .NET 8, 9, or 10.                                 |
| `--sdk-version`      | Configures the SDK version in global.json.                                      |
| `--version`          | Applies a shared version input to SDK selection and target framework selection. |
| `--benchmarks`       | Includes the benchmark project.                                                 |
| `--docs`             | Includes architecture documentation.                                            |
| `--github-actions`   | Includes GitHub Actions workflows.                                              |
| `--build-config`     | Includes shared build configuration files.                                      |

When conflicting version parameters are specified, `--version` takes precedence over `--sdk-version` and `--target-framework`.

When `--simple` and `--benchmarks` are specified together, `--simple` takes precedence.

The default preset is standard. The full preset enables optional components and automatic stable LTS SDK and target framework selection, subject to explicit parameter precedence.

For all supported values, normalization rules, examples, and generated project details, see the full documentation.

---

## Requirements

Install a compatible .NET SDK for the generated project's target framework and any SDK version requested by global.json.

Download the .NET SDK:

[.NET Download](https://dotnet.microsoft.com/download)

[.NET Download (All Versions)](https://dotnet.microsoft.com/en-us/download/dotnet)

---

## Documentation

- GitHub Repository and Full Documentation

- Template Source and Configuration

- Report an Issue

---

## License

This project is licensed under the MIT License. See the LICENSE file for details.