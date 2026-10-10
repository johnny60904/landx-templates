# LanDX.Templates

[![NuGet](https://img.shields.io/badge/NuGet-LanDX.Templates-blue?logo=nuget)](https://www.nuget.org/packages/LanDX.Templates)
[![NuGet](https://img.shields.io/badge/Package-Template-green?logo=nuget)](https://www.nuget.org/packages/LanDX.Templates)
[![NuGet](https://img.shields.io/nuget/v/LanDX.Templates?label=NuGet&logo=nuget&color=darkorange)](https://www.nuget.org/packages/LanDX.Templates/)

[![Badge](https://img.shields.io/badge/Support-.NET_8-darkcyan?logo=dotnet)](https://dotnet.microsoft.com/zh-tw/download/dotnet/8.0)
[![Badge](https://img.shields.io/badge/Support-.NET_9-darkcyan?logo=dotnet)](https://dotnet.microsoft.com/zh-tw/download/dotnet/9.0)
[![Badge](https://img.shields.io/badge/Support-.NET_10-darkcyan?logo=dotnet)](https://dotnet.microsoft.com/zh-tw/download/dotnet/10.0)

[![Repository](https://img.shields.io/badge/GitHub-landx--templates-blue?logo=github)](https://github.com/johnny60904/landx-templates)
[![License](https://img.shields.io/badge/license-MIT-green)](https://choosealicense.com/licenses/mit/)

**LanDX.Templates**  is a customizable .NET CLI project template for creating modern C# Class Library and Console Application projects.

It provides a consistent project structure, configurable target frameworks, and optional development tooling. Choose a minimal project setup, use the standard configuration, or enable the full set of optional components.

---

## Features

- **Modern .NET:** Supports .NET 8, .NET 9, and .NET 10 target frameworks.

- **Multiple project types:** Generate Class Library or Console Application projects.

- **Configurable project structure:** Choose the standard or full preset, or use --simple for a minimal setup.

- **Flexible version selection:** Configure the SDK version and target framework independently or use --version as a shared input.

- **Optional tests:** Include a test project in the standard configuration.

- **Optional benchmarks:** Include a benchmark project with --benchmarks.

- **Optional documentation:** Include architecture decision records with --docs.

- **Optional GitHub Actions:** Include workflow configuration with --github-actions.

- **Optional shared build configuration:** Include centralized MSBuild and NuGet configuration with --build-config.

- **Automated package publishing:** Publish versioned template packages through GitHub Actions and NuGet Trusted Publishing.

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

`dotnet new landx-templates -n <your-project-name>`

<br>

To generate a project in a specific directory, use `--output` / `-o` (short name):

`dotnet new landx-templates -n <your-project-name> -o <path>`

<br>

Create a minimal project:

`dotnet new landx-templates -n <your-project-name> --simple`

<br>

Create a Console Application:

`dotnet new landx-templates -n <your-project-name> --project-type console`

<br>

Create a project with the full preset:

`dotnet new landx-templates -n <your-project-name> --preset full`

<br>

The available parameters and their defaults are described below.

---

## Template Options

### Project Type

Use `--project-type` / `-pt` (short name) to select the project type.

<br>

| Value      | Description                        |
|------------|------------------------------------|
| `classlib` | Class Library project.             |
| `class`    | Class Library project alias.       |
| `lib`      | Class Library project alias.       |
| `console`  | Console Application project.       |

The default project type is **classlib**.

<br>

Example:

`dotnet new landx-templates -n <your-project-name> --project-type console`

If `--project-type` is omitted, the template uses its configured default. The current default is intended to be a Class Library.

---

### Presets

Use `--preset` / `-ps` (short name) to select a predefined project configuration.

<br>

| Preset     | Description |
|------------|-------------|
| `standard` | Includes the common project files, source project, and test project. |
| `full`     | Enables the optional documentation, GitHub Actions, benchmarks, and build configuration, together with automatic LTS SDK and target framework selection. |

<br>

The default preset is **standard**.

<br>

Create a standard project:

`dotnet new landx-templates -n <your-project-name> --preset standard`

<br>

Create a full project:

`dotnet new landx-templates -n <your-project-name> --preset full`

<br>

The full preset enables the equivalent of the following options:

- `--docs`
- `--github-actions`
- `--benchmarks`
- `--build-config`
- Latest stable long-term support (LTS) SDK selection
- Latest stable LTS target framework selection

The exact SDK and target framework versions depend on the template's normalization rules and the available version metadata.

---

### Simple Mode

Use `--simple` / `-smp` (short name) to generate a minimal project structure.

`dotnet new landx-templates -n <your-project-name> --simple`

The simple configuration includes the common project files and source project, without the test project or optional components.

When `--simple` and `--benchmarks` are specified together, `--simple` takes precedence and the benchmark project is not included.

---

### Optional Components

The following switches enable additional files or directories.

<br>

| Option             | Description                                                                                                    |
|--------------------|----------------------------------------------------------------------------------------------------------------|
| `--docs`           | Includes the **docs**/ directory and architecture decision records.                                            |
| `--github-actions` | Includes the **.github**/ directory and workflow configuration.                                                |
| `--benchmarks`     | Includes the **benchmarks**/ directory and benchmark project.                                                  |
| `--build-config`   | Includes shared **MSBuild** and **NuGet** configuration files and relocate them to the generated project root. |

<br>
<br>

| Option             | Short Name |
|--------------------|------------|
| `--docs`           | `-dc`      |
| `--github-actions` | `-ga`      |
| `--benchmarks`     | `-bm`      |
| `--build-config`   | `-bc`      |

<br>

For example:

`dotnet new landx-templates -n <your-project-name> --docs --github-actions --benchmarks --build-config`

Optional components are excluded unless enabled by the selected preset or explicit options, subject to the precedence rules described in this document.

---

### SDK Version and Target Framework

The template provides three parameters for selecting the SDK version and target framework.

<br>

| Option               | Purpose                                                                                           |
|----------------------|---------------------------------------------------------------------------------------------------|
| `--sdk-version`      | Selects the SDK version written to the generated **global.json.**                                 |
| `--target-framework` | Selects the target framework written to the generated project **.csproj** files.                  |
| `--version`          | Applies the normalized shared version input to both SDK selection and target framework selection. |

<br>

| Option               | Short Name |
|----------------------|------------|
| `--sdk-version`      | `-sdkv`    |
| `--target-framework` | `-tfm`     |
| `--version`          | `-ver`     |

<br>

---

### SDK version

Use `--sdk-version` / `-sdkv` (short name) to configure the generated global.json.

`dotnet new landx-templates -n <your-project-name> --sdk-version 10.0.107`

<br>

The template normalizes supported inputs according to its configured rules. The selected SDK version must be available in the development or build environment.

<br>

Examples:

`dotnet new landx-templates -n <your-project-name> --sdk-version 8`

`dotnet new landx-templates -n <your-project-name> --sdk-version 9.0`

`dotnet new landx-templates -n <your-project-name> --sdk-version 9.0.318`

`dotnet new landx-templates -n <your-project-name> --sdk-version lts`

`dotnet new landx-templates -n <your-project-name> --sdk-version latest`

---

### Target framework

Use `--target-framework` / `-tfm` (short name) to select the target framework for the generated project .csproj files.

<br>

Supported inputs include:

| Inputs                           | Target framework |
|----------------------------------|------------------|
| `net8.0`, `net8`, `8`, `8.0`     | `net8.0`         |
| `net9.0`, `net9`, `9`, `9.0`     | `net9.0`         |
| `net10.0`, `net10`, `10`, `10.0` | `net10.0`        |

<br>

Example:

`dotnet new landx-templates -n <your-project-name> --target-framework net8.0`

<br>

The normalized target framework is applied to the generated project .csproj files.

---

### Shared version selection

Use `--version` / `-ver` (short name) when you want to select the SDK and target framework together.

`dotnet new landx-templates -n <your-project-name> --version 10`

<br>

The result will be:

**Target Framework:** net10.0

**SDK Version**: 10.0.401

<br>

The input is normalized according to the template configuration and applied to both global.json and the generated project .csproj files.

<br>

**Important:** The SDK version and target framework are different concepts. The SDK version determines the .NET tooling used to build the project; the target framework determines the framework against which the project is compiled. A shared input does not mean that these two version values are identical.

---

### Version precedence

If multiple version parameters are supplied, the template applies the following precedence:

1. `--version`
2. `--sdk-version` and `--target-framework`, independently

<br>

For example:

`dotnet new landx-templates -n <your-project-name> --preset full --version 9 --sdk-version lts --target-framework 8.0`

<br>

In this example, `--version` takes precedence over the other version parameters and the automatic version selection provided by the full preset. The generated SDK and target framework are determined by the normalized value of `--version`.

<br>

When automatic version selection is activated and no explicit version parameter is supplied (`--version`, `--sdk-version`, and `--target-framework`), the template selects the latest stable LTS SDK and target framework according to its normalization rules.

<br>

The plain default invocation and the standard preset do not, by themselves, imply that every optional file is generated. Refer to the preset and parameter behavior documented above.

---

### GitHub Metadata

Use `--github-user` / `-usr` (short name) to configure the GitHub user or organization used by the generated README badge URL.

Use `--github-repo` / `-repo` (short name) to configure the repository name used by the badge and repository hyperlink.

<br>

Example:

`dotnet new landx-templates -n <your-project-name> --github-user LanDX --github-repo MyProject`

<br>

The template normalizes the repository name used in the badge URL by replacing hyphens with double hyphens where required by the badge format. The repository hyperlink retains the original repository name.

<br>

Ensure that the supplied user and repository values correspond to the intended GitHub repository.

---

### License

Use `--license` / `-lcn` (short name) to configure the license identifier displayed in the generated README.

<br>

Example:

`dotnet new landx-templates -n <your-project-name> --license MIT`

<br>

The generated project includes the template's MIT license text with replaceable copyright information.

<br>

**Note:** Changing the README license label does not, by itself, automatically replace the license text. Eensure that the identifier and the actual LICENSE file remain consistent.

---

## Generated Project Structure

The default project structure includes the following files and directories:

```txt
MyNamespace.MyProject/
├── src/
│   └── MyNamespace.MyProject/
│       ├── MyNamespace.MyProject.csproj
│       ├── MyClass.cs
│       └── Program.cs
├── tests/                          # Standard preset
│   └── MyNamespace.MyProject.Tests/
│       ├── MyNamespace.MyProject.Tests.csproj
│       └── UnitTest1.cs
├── .editorconfig
├── .gitattributes
├── .gitignore
├── LICENSE
├── MyNamespace.MyProject.slnx
└── README.md
```

<br>

Depending on the selected options, the generated project may also include:

| Include                    | Option             |
|----------------------------|--------------------|
| `.github/`                 | `--github-actions` |
| `benchmarks/`              | `--benchmarks`     |
| `docs/`                    | `--docs`           |
| `global.json`              | Version selection  |
| `Directory.Build.props`    | `build-config`     |
| `Directory.Build.targets`  | `build-config`     |
| `Directory.Packages.props` | `build-config`     |

<br>

When `--build-config` is enabled, the shared configuration files are relocated to the generated project root. The exact generated structure depends on the selected options and parameter precedence.

The solution file is also configured to include the appropriate project folders for the selected project structure.

---

## Examples

### Minimal Class Library

`dotnet new landx-templates -n <your-project-name> --simple --project-type classlib`

<br>

### Standard Console Application

`dotnet new landx-templates -n <your-project-name> --project-type console`

<br>

### Full Class Library Targeting .NET 10

`dotnet new landx-templates -n <your-project-name> --preset full --project-type classlib --target-framework net10.0`

<br>

### Custom SDK and Target Framework

`dotnet new landx-templates -n <your-project-name> --sdk-version 10 --target-framework net9.0`

<br>

### Explicit Shared Version

`dotnet new landx-templates -n <your-project-name> --version 10`

---

## Development

This section describes how to develop, test, and package the template itself, rather than a project generated from it.

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
├── LanDX.Templates.csproj
└── README.md
```

The **content/landx-templates/** directory contains the source files for the generated template. Its **.template.config/template.json** defines the template identity, parameters, normalization rules, and file inclusion behavior.

The root **LanDX.Templates.csproj** packages the template content into a NuGet package.

Build output and intermediate files are generated under bin/ and obj/ when applicable.

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

Before packaging or publishing a template release, install or otherwise make the template available to the local .NET CLI and test representative project configurations.

The local test workflow uses a separate directory for generated artifacts:

```txt
TemplateTest/
└── artifacts/
    ├── T01.DefaultClassLibrary/
    ├── T02.DefaultSimple/
    ├── T03.DefaultConsole/
    ├── T04.DefaultBenchmarks/
    ├── T05.DefaultDocs/
    ├── T06.DefaultGitHubActions/
    ├── T07.DefaultBuildConfig/
    ├── T08.DefaultSdkVersion/
    ├── T09.DefaultTargetFramework/
    ├── T10.FullPreset/
    ├── T11.UnifiedVersionPriorSpecifiedVersionAndFullPreset/
    ├── B01.SimplePriorBenchmarks/
    ├── B02.SimpleDocs/
    ├── B03.SimpleGitHubActions/
    ├── B04.SimpleBuildConfig/
    ├── B05.ClassLibraryDocsGitHubActions/
    ├── B06.StandardPreset/
    ├── B07.FullPresetPriorSimple/
    ├── B08.FullPresetSdkVersion/
    ├── B09.FullPresetTargetFramework/
    ├── B10.FullPresetConsole/
    ├── B11.DefaultClassLibraryTargetFramework/
    ├── B12.DefaultConsoleTargetFramework/
    ├── B13.ClassLibraryTargetFramework/
    └── BB14.ConsoleTargetFramework/
```

<br>
<br>

| Test Project                                         | Command                                                                |
|------------------------------------------------------|------------------------------------------------------------------------|
| T01.DefaultClassLibrary                              | `dotnet new landx-templates -n T01.DefaultClassLibrary -o T01.DefaultClassLibrary` |
| T02.DefaultSimple                                    | `dotnet new landx-templates -n T02.DefaultSimple -o T02.DefaultSimple --simple` |
| T03.DefaultConsole                                   | `dotnet new landx-templates -n T03.DefaultConsole -o T03.DefaultConsole --project-type console` |
| T04.DefaultBenchmarks                                | `dotnet new landx-templates -n T04.DefaultBenchmarks -o T04.DefaultBenchmarks --benchmarks` |
| T05.DefaultDocs                                      | `dotnet new landx-templates -n T05.DefaultDocs -o T05.DefaultDocs --docs` |
| T06.DefaultGitHubActions                             | `dotnet new landx-templates -n T06.DefaultGitHubActions -o T06.DefaultGitHubActions --github-actions` |
| T07.DefaultBuildConfig                               | `dotnet new landx-templates -n T07.DefaultBuildConfig -o T07.DefaultBuildConfig --build-config` |
| T08.DefaultSdkVersion                                | `dotnet new landx-templates -n T08.DefaultSdkVersion -o T08.DefaultSdkVersion --sdk-version 10.0.100` |
| T09.DefaultTargetFramework                           | `dotnet new landx-templates -n T09.DefaultTargetFramework -o T09.DefaultTargetFramework --target-framework 8` |
| T10.FullPreset                                       | `dotnet new landx-templates -n T10.FullPreset -o T10.FullPreset --preset full` |
| T11.UnifiedVersionPriorSpecifiedVersionAndFullPreset | `dotnet new landx-templates -n T11.UnifiedVersionPriorSpecifiedVersionAndFullPreset -o T11.UnifiedVersionPriorSpecifiedVersionAndFullPreset --preset full --sdk-version 8 --target-framework 8 --version 9` |
| B01.SimplePriorBenchmarks                            | `dotnet new landx-templates -n B01.SimplePriorBenchmarks -o B01.SimplePriorBenchmarks --simple --benchmarks` |
| B02.SimpleDocs                                       | `dotnet new landx-templates -n B02.SimpleDocs -o B02.SimpleDocs --simple --docs` |
| B03.SimpleGitHubActions                              | `dotnet new landx-templates -n B03.SimpleGitHubActions -o B03.SimpleGitHubActions --simple --github-actions` |
| B04.SimpleBuildConfig                                | `dotnet new landx-templates -n B04.SimpleBuildConfig -o B04.SimpleBuildConfig --simple --build-config` |
| B05.ClassLibraryDocsGitHubActions                    | `dotnet new landx-templates -n B05.ClassLibraryDocsGitHubActions -o B05.ClassLibraryDocsGitHubActions --benchmarks --docs --github-actions` |
| B06.StandardPreset                                   | `dotnet new landx-templates -n B06.StandardPreset -o B06.StandardPreset --preset standard` |
| B07.FullPresetPriorSimple                            | `dotnet new landx-templates -n B07.FullPresetPriorSimple -o B07.FullPresetPriorSimple --preset full --simple` |
| B08.FullPresetSdkVersion                             | `dotnet new landx-templates -n B08.FullPresetSdkVersion -o B08.FullPresetSdkVersion --preset full --sdk-version 10.0.107` |
| B09.FullPresetTargetFramework                        | `dotnet new landx-templates -n B09.FullPresetTargetFramework -o B09.FullPresetTargetFramework --preset full --target-framework 9` |
| B10.FullPresetConsole                                | `dotnet new landx-templates -n B10.FullPresetConsole -o B10.FullPresetConsole --preset full --project-type console` |
| B11.DefaultClassLibraryTargetFramework               | `dotnet new landx-templates -n B11.DefaultClassLibraryTargetFramework -o B11.DefaultClassLibraryTargetFramework --project-type classlib --target-framework 9` |
| B12.DefaultConsoleTargetFramework                    | `dotnet new landx-templates -n B12.DefaultConsoleTargetFramework -o B12.DefaultConsoleTargetFramework --project-type console --target-framework 8` |
| B13.ClassLibraryTargetFramework                      | `dotnet new landx-templates -n B13.ClassLibraryTargetFramework -o B13.ClassLibraryTargetFramework --project-type classlib --target-framework 9 --benchmarks` |
| BB14.ConsoleTargetFramework                          | `dotnet new landx-templates -n B14.ConsoleTargetFramework -o B14.ConsoleTargetFramework --project-type classlib --target-framework 8 --benchmarks` |

<br>
<br>

The local verification suite covers the following areas:

| Area                 | Verification                                                                                         |
|----------------------|------------------------------------------------------------------------------------------------------|
| Default generation   | Required files and default project structure.                                                        |
| Simple mode          | Exclusion of tests and optional components.                                                          |
| Project type         | Class Library and Console Application selection.                                                     |
| Optional components  | Benchmarks, documentation, GitHub Actions, and shared build configuration.                           |
| Presets              | Standard and full configurations.                                                                    |
| Version selection    | SDK version, target framework, normalization, and precedence.                                        |
| File relocation      | Root-level build configuration files and global.json.                                                |
| Solution structure   | Correct project folder references in the generated .slnx.                                            |
| README and license   | Correct source-name substitutions, repository URLs, badges, and license text.                        |
| Parameter validation | Unsupported choices fail as expected.                                                                |
| Template discovery   | The template appears in dotnet new list and its options appear in dotnet new landx-templates --help. |

The test suite also includes conflicting parameter combinations, including --simple with --benchmarks and --version with other version options.

---

### Validate Generated Projects

For each generated test project, run the following commands:

```txt
dotnet clean
dotnet restore
dotnet build --no-restore
dotnet test --no-build
```

<br>

For generated Console Applications, also run the application:

`dotnet run --project <ProjectName>/<ProjectName>.csproj`

Replace `<ProjectName>` with the actual generated project directory and project name.

<br>

The local verification suite checks that generated projects can be restored, built, tested, and executed where applicable.

<br>

Negative tests verify that unsupported choices are rejected:

```txt
dotnet new landx-templates -n E01 --project-type invalid
dotnet new landx-templates -n E02 --target-framework net7.0
dotnet new landx-templates -n E03 --preset invalid
```

These commands are expected to fail because the supplied choice values are unsupported.

<br>

Inspect the generated files as well as command exit codes. A successful template invocation alone does not guarantee that the generated solution, configuration files, and documentation are correct.

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

---

## License

This repository is licensed under the MIT License.

See LICENSE for the complete license text.