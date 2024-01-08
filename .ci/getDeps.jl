module getDeps

using IntegrationTests
using Pkg
using PkgDependency

include(joinpath(dirname(@__FILE__), "prepareIntegrationTest.jl"))

# TODO: Update discription

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
    tmp_path = mktempdir()
    prepareIntegrationTest.create_package_eco_system(tmp_path)

    # extra Project.toml to generate dependency graph for the whole project
    Pkg.activate(joinpath(tmp_path, "MyPkgMeta"))
    depending_packages = IntegrationTests.depending_projects("MyPkgC", r"^MyPkg*")

    # compare with expected result
    # needs to be negated, because true would result in error code 1
    exit(!(sort(depending_packages) == sort(["MyPkgA", "MyPkgB"])))
end

end
