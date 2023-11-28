module getDeps

using IntegrationTests
using Pkg
using PkgDependency

include(joinpath(dirname(@__FILE__), "prepareIntegrationTest.jl"))

# see README.md
if !isinteractive()
    tmp_path = mktempdir()
    prepareIntegrationTest.create_package_eco_system(tmp_path)

    # extra Project.toml to generate dependency graph for the whole project
    Pkg.activate(joinpath(tmp_path, "MyPkgMeta"))
    depending_packages = IntegrationTests.depending_projects("MyPkgC", r"^MyPkg*")

    print(depending_packages)
end

end
