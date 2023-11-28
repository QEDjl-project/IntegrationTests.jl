module getDeps

using IntegrationTests
using Pkg
using PkgDependency

# This script tests the IntegrationTests package with a real package ecosystem.
# The package ecosystem is located in the `example_project` folder. All package names start with
# `MyPkg`. The packages also have dependencies on third-party packages. The `MetaTestPkg` is a
# specially created package. It has only one dependency, the `MyPkgMain` package. The `MyPkgMain`
# itself has all other packages as direct dependencies. We use the environment of the `MetaTestPkg`
# package to construct the dependency tree for the `depending_projects()` function. We cannot use
# `MyPkgMain` directly because a package is not a member of its own dependency graph. This means
# that `depending_projects()` would not check if `MyPkgMain` is a dependency of a package we are
# looking for, because it is not part of the dependency graph.

if !isinteractive()
    main_project_path = Base.Filesystem.joinpath(
        Base.Filesystem.dirname(Base.source_path()), "example_project/MetaTestPkg/"
    )

    # extra Project.toml to generate dependency graph for the whole project
    Pkg.activate(main_project_path)
    depending_packages = IntegrationTests.depending_projects("MyPkgFields", r"^MyPkg*")

    # compare with expected result
    # needs to be negated, because true would result in error code 1
    exit(!(sort(depending_packages) == sort(["MyPkgMain", "MyPkgProcesses"])))
end

end
