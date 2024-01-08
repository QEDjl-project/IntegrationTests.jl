module prepareIntegrationTest

using Pkg

function create_package_eco_system(base_path)
    cd(base_path)
    Pkg.generate("MyPkgA")
    Pkg.generate("MyPkgB")
    Pkg.generate("MyPkgC")
    Pkg.generate("MyPkgD")
    Pkg.generate("MyPkgE")
    Pkg.generate("MyPkgMeta")

    Pkg.activate("MyPkgE")
    Pkg.add("JSON")
    Pkg.add("Pkg")
    Pkg.add("Test")

    Pkg.activate("MyPkgD")
    Pkg.develop(; path=joinpath(base_path, "MyPkgE"))

    Pkg.activate("MyPkgC")
    Pkg.add("JSON")
    Pkg.develop(; path=joinpath(base_path, "MyPkgE"))

    Pkg.activate("MyPkgB")
    Pkg.develop(; path=joinpath(base_path, "MyPkgE"))
    Pkg.develop(; path=joinpath(base_path, "MyPkgC"))
    Pkg.add("PkgTemplates")

    Pkg.activate("MyPkgA")
    Pkg.develop(; path=joinpath(base_path, "MyPkgE"))
    Pkg.develop(; path=joinpath(base_path, "MyPkgD"))
    Pkg.develop(; path=joinpath(base_path, "MyPkgC"))
    Pkg.develop(; path=joinpath(base_path, "MyPkgB"))
    Pkg.add("YAML")

    Pkg.activate("MyPkgMeta")
    Pkg.develop(; path=joinpath(base_path, "MyPkgA"))

    return Nothing
end

end
