# Architecture Decision Records

This document records significant architectural and design decisions for LanDX.Templates.

Architecture Decision Records (ADRs) explain the context behind a decision, the alternatives considered, the chosen approach, and its consequences.

The purpose of these records is to preserve design rationale, improve maintainability, and help future contributors understand why the template behaves as it does.

---

## ADR Index

| ID      | Decision                                                             | Status   |
|---------|----------------------------------------------------------------------|----------|
| ADR-001 | Use the .NET CLI Template Engine                                     | Accepted |
| ADR-002 | Provide Standard, Simple, and Full Project Configurations            | Accepted |
| ADR-003 | Define Explicit Parameter Precedence                                 | Accepted |
| ADR-004 | Normalize SDK and Target Framework Inputs                            | Accepted |
| ADR-005 | Keep Optional Tooling Opt-In                                         | Accepted |
| ADR-006 | Separate Template Documentation from Generated Project Documentation | Accepted |

---

## ADR-001: Use the .NET CLI Template Engine

**Status:** Accepted

### Context

The project aims to provide a reusable mechanism for generating C# Class Library and Console Application projects.

Manually copying project directories is error-prone and makes it difficult to maintain consistent project structures across multiple projects.

A template mechanism should support configurable names, project types, target frameworks, and optional files.

### Decision

Use the .NET CLI Template Engine and its .template.config/template.json configuration to define project generation behavior.

Use template symbols, source modifiers, conditional file inclusion, and post-processing mechanisms where appropriate to implement the supported options.

### Alternatives Considered

 - Maintaining separate repository copies for each project configuration.

 - Providing scripts that manually create project directories and modify files.

 - Using a custom project-generation application.

### Consequences

#### Benefits:

- Integrates with the existing .NET development workflow.

- Allows users to generate projects through dotnet new.

- Centralizes template configuration.

- Supports reusable project files and configurable generation options.

#### Trade-offs:

- Conditional file inclusion and parameter interactions require careful configuration.

- Template behavior must be tested across supported parameter combinations.

- Changes to template symbols or normalization rules may affect backward compatibility.

---

## ADR-002: Provide Standard, Simple, and Full Project Configurations

**Status:** Accepted

### Context

Different projects require different levels of structure.

A small library may not need benchmarking or GitHub Actions, whereas a more fully configured project may benefit from tests, documentation, shared build configuration, and automation.

Requiring every user to configure each component individually would add unnecessary complexity to common use cases.

### Decision

Provide three levels of project configuration:

- **Standard:** the default configuration, containing the common project files, source project, and test project.

- **Simple:** a minimal configuration containing the common project files and source project, without the test project or optional components.

- **Full:** a more complete configuration that enables documentation, GitHub Actions, benchmarks, shared build configuration, and automatic SDK and target framework version selection.

Allow users to enable optional components individually when appropriate.

### Alternatives Considered

- Providing only one fixed project structure.

- Requiring every optional component to be enabled individually.

- Making the full configuration the default for all users.

### Consequences

#### Benefits:

- Keeps the default experience straightforward.

- Supports both lightweight and more extensively configured projects.

- Avoids forcing optional tooling onto every generated project.

#### Trade-offs:

- Multiple configurations increase the number of scenarios that must be tested.

- Documentation must accurately describe which files are included in each configuration.

- The behavior of combined options must be deterministic.

---

## ADR-003: Define Explicit Parameter Precedence

**Status:** Accepted

### Context

Several template parameters can influence the same output files.

For example, `--version` affects both SDK selection and target framework selection, while `--sdk-version` and `--target-framework` control those values independently.

Similarly, `--simple` and `--benchmarks` can request conflicting project structures.

Without explicit precedence rules, users may receive unexpected files or configuration values.

### Decision

Define deterministic precedence rules for conflicting parameters.

For version selection:

1. `--version` takes precedence over `--sdk-version` and `--target-framework`.

2. If `--version` is not specified, `--sdk-version` and `--target-framework` control their respective outputs independently.

3. When automatic version selection is activated and no version parameter is specified, the template selects the latest stable LTS SDK and target framework according to its normalization rules.

For project structure:

1. `--simple` takes precedence over `--benchmarks`.

2. When both options are specified, the simple configuration is generated without the benchmark project.

### Alternatives Considered

- Rejecting all conflicting parameter combinations.

- Allowing conflicting parameters to produce ambiguous results.

- Applying parameter values in command-line order without a documented precedence policy.

### Consequences

#### Benefits:

- Makes generation behavior predictable.

- Allows convenient shared version selection through `--version`.

Simplifies the handling of conflicting project structure options.

#### Trade-offs:

- Users may not realize that a lower-priority parameter is ignored.

- Documentation and automated tests must verify precedence behavior.

- Changes to precedence rules may affect existing automation scripts.

---

## ADR-004: Normalize SDK and Target Framework Inputs

**Status:** Accepted

### Context

Users may refer to SDK versions and target frameworks using different shorthand forms.

For example, a target framework may be entered as 10, 10.0, net10, or net10.0.

SDK selection may also use inputs such as a major version or a channel identifier such as lts.

Requiring users to memorize exact version strings would make the template less convenient to use.

### Decision

Use template normalization logic to convert supported inputs into canonical values.

For target frameworks, supported shorthand inputs are normalized to the corresponding framework moniker:

- `8`, `8.0`, `net8`, and `net8.0` normalize to `net8.0`.

- `9`, `9.0`, `net9`, and `net9.0` normalize to `net9.0`.

- `10`, `10.0`, `net10`, and `net10.0` normalize to `net10.0`.

For SDK selection, supported inputs are normalized to the SDK version format required by the generated global.json.

When an LTS or other supported channel input is accepted, its resolution follows the template's configured normalization rules.

### Alternatives Considered

- Requiring canonical version strings for every input.

- Using separate templates for different target frameworks.

- Leaving all normalization to the user.

### Consequences

#### Benefits:

- Improves usability.

- Reduces invalid or inconsistent version inputs.

- Keeps generated project files in a predictable format.

#### Trade-offs:

- Normalization logic must be maintained as supported versions evolve.

- Channel-based selection depends on the accuracy and maintenance of the resolution rules.

- SDK versions and target framework monikers must remain conceptually distinct even when selected through a shared input.

---

## ADR-005: Keep Optional Tooling Opt-In

**Status:** Accepted

### Context

Not every generated project needs benchmarks, documentation, GitHub Actions, or centralized build configuration.

Including every possible component in every project would increase complexity and create files that some users never use.

At the same time, these components are useful for projects that require more extensive development workflows.

### Decision

Make the following components optional:

- Benchmark project through `--benchmarks`.

- Architecture documentation through `--docs`.

- GitHub Actions configuration through `--github-actions`.

- Shared MSBuild and NuGet configuration through `--build-config`.

Allow the full preset to enable these components together.

When a component is not selected, its corresponding optional files should not be included in the generated project.

### Alternatives Considered

- Including all tooling by default.

- Maintaining separate templates for every combination of optional components.

- Requiring users to remove unwanted files manually after generation.

### Consequences

#### Benefits:

- Keeps generated projects focused on their intended use.

- Reduces unnecessary configuration.

- Allows projects to adopt additional tooling incrementally.

#### Trade-offs:

- The template configuration becomes more complex.

- File inclusion and relocation rules must be tested.

- Documentation must distinguish between guaranteed files and optional files.

---

## ADR-006: Separate Template Documentation from Generated Project Documentation

**Status:** Accepted

### Context

LanDX.Templates serves two different audiences.

The template repository is intended for users who install, configure, develop, and publish the template.

Generated projects are intended for developers who build, test, execute, extend, or distribute the resulting C# projects.

Combining these concerns in one README would make both documents harder to use.

### Decision

Maintain separate documentation for the template repository and generated projects.

The repository-level README.md documents:

- Template installation and invocation.

- Supported parameters and their precedence.

- Preset behavior.

- Version normalization.

- Development and publishing workflows.

The generated content/landx-templates/README.md documents:

- Project overview and structure.

- Prerequisites and setup.

- Building, testing, and usage.

- Development conventions.

- Applicable deployment and licensing information.

The generated README should be adapted to the selected project type and included components wherever practical.

### Alternatives Considered

- Using one README for both the template and generated projects.

- Generating a generic README without considering project type.

- Maintaining entirely separate static README files for every supported configuration.

### Consequences

#### Benefits:

- Keeps instructions relevant to each audience.

- Reduces confusion between template options and generated project capabilities.

- Makes each document easier to maintain independently.

#### Trade-offs:

- Some general documentation may be repeated.

- Changes to template behavior may require updates to both documentation files.

- Conditional documentation must remain consistent with actual file inclusion rules.

---

## Maintaining These Records

When introducing a significant design change:

1. Identify the problem or limitation that motivates the change.
2. Consider reasonable alternatives.
3. Document the chosen approach and its consequences.
4. Assign the next available ADR identifier.
5. Update this index.
6. Update the relevant implementation and user documentation.

Use the following template for future decisions:

`## ADR-NNN`: Decision Title

`**Status**`: Proposed

`### Context`: Describe the problem, constraints, and circumstances that require a decision.

`### Decision`: Explain the chosen approach.

`### Alternatives Considered`: Describe the reasonable alternatives and why they were not selected.

`### Consequences`: Explain the benefits, trade-offs, limitations, and future implications.

Once a decision has been accepted, retain its record even if it is later superseded. Update the status and link to the newer ADR so that the project's decision history remains understandable.