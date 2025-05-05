# IntegrationTests

[![Doc Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://qedjl-project.github.io/IntegrationTests.jl/stable/)
[![Doc Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://qedjl-project.github.io/IntegrationTests.jl/dev)
[![code style: runic](https://img.shields.io/badge/code_style-%E1%9A%B1%E1%9A%A2%E1%9A%BE%E1%9B%81%E1%9A%B2-black)](https://github.com/fredrikekre/Runic.jl)

# About

`IntegrationTests.jl` provides tools and instructions for automatically creating integration tests for Julia projects in continuous integration pipelines such as [GitLab CI](https://docs.gitlab.com/ee/ci/) and [GitHub Actions](https://docs.github.com/en/actions).

# What are integration tests

Integration tests are required if you want to test whether different packages work together after a code change. For example, if package A is used by package B and the API of package A has been changed, the integration test checks whether package B still works.

## Example Project

Our example package eco system contains the two packages `PkgA` and `PkgB`. `PkgB` uses a function from `PkgA`.

```mermaid
graph TD
   pkgb(PkgB) -->|using| pkga(PkgA)
```

`PkgA` provides the following function:

```julia
module PkgA

    foo(i) = i + 3

end
```

`PkgB` uses the function of `PkgA` in the following way:

```julia
module PkgB
using PkgA

    bar() = PkgA.foo(3)

end
```

`PkgB` implements a test that checks whether `bar()` works:

```julia
using PkgB
using Test

@testset "PkgB.jl" begin
    @test PkgB.bar() == 6
end
```

Suppose we change `foo(i) = i + 3` to `foo(i, j) = i + j + 3`. The `bar()` function in `PkgB` will no longer work because `bar()` calls `foo()` with only one parameter. The integration test will detect the problem and allow the developer to fix the problem before the pull request is merged. For example, a fix can be developed for `PkgB` that calls `foo()` with two arguments.

# Functionality

`IntegrationTests.jl` provides CI configuration files and a tool for the dynamic generation of integration tests for a specific project. The tool determines the dependent packages based on a given `Project.toml` of the entire package ecosystem. This is possible because a `Project.toml` of a package describes the dependencies as a graph. The graph can also contain the dependencies of the dependencies. Therefore, you can create a dependency graph of a package ecosystem. A package ecosystem can look like this:

```mermaid
graph TD
   qed(QED.jl) --> base(QEDbase.jl)
   qed --> processes(QEDprocesses.jl) --> base
   qed --> fields(QEDfields.jl) --> base
   processes --> fields
   qed --> events(QEDevents.jl) --> base
```

[Project.toml](https://github.com/QEDjl-project/QuantumElectrodynamics.jl/blob/08613adadea8a85bb4cbf47065d118eaec6f03d6/Project.toml) of the `QED.jl` package.

For example, if `QEDfields.jl` is changed, `IntegrationTests.jl` returns that `QED.jl` and `QEDprocesses.jl` are dependent on `QEDfields.jl`, and we can generate the integration test jobs. Full CI pipeline examples for GitLab CI and GitHub Actions can be found in the [Pipeline Tutorials](https://qedjl-project.github.io/IntegrationTests.jl/dev/pipeline_tutorials/) section. For more details on the `IntegrationTests.jl` tool, see the [Integration Test Tool](https://qedjl-project.github.io/IntegrationTests.jl/dev/integration_test_tool/) section.

# Credits

This work was partly funded by the [Center for Advanced Systems Understanding (CASUS)](https://www.casus.science) that is financed by Germany’s Federal Ministry of Education and Research (BMBF) and by the Saxon Ministry for Science, Culture and Tourism (SMWK) with tax funds on the basis of the budget approved by the Saxon State Parliament.

Special thanks for concept ideas and discussions:

- Uwe Hernandez Acosta (u.hernandez@hzdr.de)
- Anton Reinhard (a.reinhard@hzdr.de)
