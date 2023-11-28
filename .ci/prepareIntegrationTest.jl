module prepareIntegrationTest

using Pkg

"""
    create_package_eco_system(base_path)

Creates a Julia package ecosystem in the `base_path` folder for testing purposes.

# Arguments

- `base_path`: Path to folder where ecosystem is created.

"""
function create_package_eco_system(base_path)
    # A graphical representation of the dependencies between the packages can be found in the 
    # README.md.

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
