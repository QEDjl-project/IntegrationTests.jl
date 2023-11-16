module IntegrationTests

using Pkg
using PkgDependency

"""
    depending_projects(package_name, package_prefix, project_tree)

Return a list of packages, which have the package `package_name` as a dependency. Ignore all packages, which do not start with `package_prefix`.

# Arguments
- `package_name::String`: Name of the dependency
- `package_filter`: If the package name is not included in package_filter, the dependency is not checked.
- `project_tree=PkgDependency.builddict(Pkg.project().uuid, Pkg.project())`: Project tree, where to search the dependent packages. Needs to be a nested dict.
                                                                             Each (sub-) package needs to be AbstractDict{String, AbstractDict}

# Returns
- `::AbstractVector{String}`: all packages which have the search dependency

"""
function depending_projects(
    package_name::String,
    package_filter,
    project_tree::AbstractDict=PkgDependency.builddict(Pkg.project().uuid, Pkg.project()),
)::AbstractVector{String}
    packages::AbstractVector{String} = []
    visited_packages::AbstractVector{String} = []
    traverse_tree!(package_name, package_filter, project_tree, packages, visited_packages)
    return packages
end

"""
    traverse_tree!(package_name::String, package_filter, project_tree, packages::AbstractVector{String}, visited_packages::AbstractVector{String})

Traverse a project tree and add any package to `packages`, that has the package `package_name` as a dependency. Ignore all packages that are not included in `package_filter`.
See [`depending_projects`](@ref)

"""
function traverse_tree!(
    package_name::String,
    package_filter,
    project_tree,
    packages::AbstractVector{String},
    visited_packages::AbstractVector{String},
)
    for project_name_version in keys(project_tree)
        # remove project version from string -> usual shape: `packageName.jl version`
        project_name = split(project_name_version)[1]
        # fullfil the requirements
        # - package starts with the prefix
        # - the dependency is not nothing (I think this representate, that the package was already set as dependency of a another package and therefore do not repead the dependencies)
        # - has dependency
        # - was not already checked
        if project_name in package_filter &&
            project_tree[project_name_version] !== nothing &&
            !isempty(project_tree[project_name_version]) &&
            !(project_name in visited_packages)
            # only investigate each package one time
            # assumption: package name with it's dependency is unique
            push!(visited_packages, project_name)
            for dependency_name_version in keys(project_tree[project_name_version])
                # dependency matches, add to packages
                if startswith(dependency_name_version, package_name)
                    push!(packages, project_name)
                    break
                end
            end
            # independent of a match, under investigate all dependencies too, because they can also have the package as dependency
            traverse_tree!(
                package_name,
                package_filter,
                project_tree[project_name_version],
                packages,
                visited_packages,
            )
        end
    end
end

end
