module getDeps

using IntegrationTests
using Pkg
using PkgDependency

# see getDeps.jl
if !isinteractive()
    main_project_path = Base.Filesystem.joinpath(
        Base.Filesystem.dirname(Base.source_path()), "example_project/MetaTestPkg/"
    )

    # extra Project.toml to generate dependency graph for the whole project
    Pkg.activate(main_project_path)
    depending_packages = IntegrationTests.depending_projects("MyPkgFields", r"^MyPkg*")

    print(depending_packages)
end

end
