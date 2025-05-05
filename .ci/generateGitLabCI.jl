module getDeps

using IntegrationTests
using Pkg

include(joinpath(dirname(@__FILE__), "prepareIntegrationTest.jl"))

"""
    print_job_yaml(job_name::AbstractString)

Generate a GitLab CI job yaml file for a given package name and print it to stdout.

# Arguments

- `package_name`: Name of the package
"""
function print_job_yaml(package_name::AbstractString)
    # Do not use a YAML library, as the generated YAML code is too simple to justify
    # the additional runtime of installing the YAML package.
    job_yaml = """integrationTest$package_name:
        image: "alpine:latest"
        script:
            - echo "run Integration Test for package $package_name"

    """
    return print(job_yaml)
end

# see README.md
if !isinteractive()
    tmp_path = mktempdir()
    prepareIntegrationTest.create_package_eco_system(tmp_path)

    # extra Project.toml to generate dependency graph for the whole project
    Pkg.activate(joinpath(tmp_path, "MyPkgMeta"))
    depending_packages = IntegrationTests.depending_projects("MyPkgC", r"^MyPkg*")

    for dep in depending_packages
        print_job_yaml(dep)
    end
end

end
