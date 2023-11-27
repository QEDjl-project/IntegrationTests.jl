module IntegrationTests

using Pkg
using PkgDependency

export depending_projects

"""
    depending_projects(
        package_name::AbstractString, 
        package_filter::Union{<:AbstractString,Regex}
        project_tree::AbstractDict=PkgDependency.builddict(Pkg.project().uuid, Pkg.project())
    ) -> Vector{String}

Returns a list of packages that have the package `package_name` as a dependency. 

# Arguments

- `package_name`: Name of the dependency
- `package_filter`: Ignore all packages that do not match `package_filter`. This includes the 
        top node package of the graph. Child nodes are always checked for `package_name`, but 
        they are not traversed if they do not match `package_filter`.
- `project_tree`: Project tree in which to search for dependent packages. Each (sub-)package 
        needs to be `AbstractDict{String, AbstractDict}`

# Returns

A `Vector{String}` containing the names of all packages that have the given dependency.

"""
function depending_projects(
    package_name::AbstractString,
    package_filter::Union{<:AbstractString,Regex},
    project_tree::AbstractDict=PkgDependency.builddict(Pkg.project().uuid, Pkg.project()),
)::Vector{String}
    packages::Vector{String} = []
    visited_packages::Vector{String} = []
    _traverse_tree!(package_name, package_filter, project_tree, packages, visited_packages)
    return packages
end

"""
    depending_projects(
        package_name::AbstractString, 
        package_filter::AbstractVector{<:AbstractString}, 
        project_tree::AbstractDict=PkgDependency.builddict(Pkg.project().uuid, Pkg.project())
    ) -> Vector{String}
"""
function depending_projects(
    package_name::AbstractString,
    package_filter::AbstractVector{<:AbstractString},
    project_tree::AbstractDict=PkgDependency.builddict(Pkg.project().uuid, Pkg.project()),
)::Vector{String}
    packages::Vector{String} = []
    visited_packages::Vector{String} = []

    if length(package_filter) == 0
        throw(ArgumentError("package_filter must not be empty"))
    end

    _traverse_tree!(package_name, package_filter, project_tree, packages, visited_packages)
    return packages
end

"""
    _match_package_filter(
        package_filter::Union{<:AbstractString,Regex}, 
        package::AbstractString
    )::Bool

Check if `package_filter` contains `package`. Wrapper function for `contains()` and `in()`.

# Returns

- `true` if it matches.

"""
function _match_package_filter(
    package_filter::Union{<:AbstractString,Regex}, package::AbstractString
)::Bool
    return contains(package, package_filter)
end

"""
    _match_package_filter(
        package_filter::AbstractVector{<:AbstractString}, 
        package::AbstractString
    )::Bool
"""
function _match_package_filter(
    package_filter::AbstractVector{<:AbstractString}, package::AbstractString
)::Bool
    return package in package_filter
end

"""
    _traverse_tree!(
        package_name::AbstractString, 
        package_filter::Union{<:AbstractString,Regex,AbstractVector{<:AbstractString}}, 
        project_tree::AbstractDict, 
        packages::AbstractVector{<:AbstractString},
        visited_packages::AbstractVector{<:AbstractString}
    )

Traverse the project tree and add any package to `packages` that has the package `package_name` as a dependency.

# Arguments
    
- `package_name`: Name of the dependency
- `package_filter`: Ignore all packages that do not match `package_filter`. This includes the 
        top node package of the graph. Child nodes always are checked for `package_name`, but 
        they are not traveres if they do not match `package_filter`.
- `project_tree`: Project tree, where to search the dependent packages. Each (sub-) package 
        needs to be AbstractDict{String, AbstractDict}
- `packages`: Packages which has `package_name` as dependency.
- `visited_packages`: List of packages that are not traveresed again. 
        Avoids circular, infinite traversing.
"""
function _traverse_tree!(
    package_name::AbstractString,
    package_filter::Union{<:AbstractString,Regex,AbstractVector{<:AbstractString}},
    project_tree::AbstractDict,
    packages::AbstractVector{<:AbstractString},
    visited_packages::AbstractVector{<:AbstractString},
)
    for project_name_version in keys(project_tree)
        # remove project version from string -> usual shape: `packageName.jl version`
        project_name = split(project_name_version)[1]

        # do not traverse packages further that we have already seen
        if project_name in visited_packages
            continue
        end

        # do not traverse packages that don't match the given filter
        if !_match_package_filter(package_filter, project_name)
            continue
        end

        push!(visited_packages, String(project_name))

        # independent of a match, traverse all dependencies because they can also have the package as dependency
        _traverse_tree!(
            package_name,
            package_filter,
            project_tree[project_name_version],
            packages,
            visited_packages,
        )

        # if the dependency is nothing, continue (I think this represents that the package was already set as dependency of a another package and therefore does not repeat the dependency)
        if isnothing(project_tree[project_name_version]) ||
            isempty(project_tree[project_name_version])
            continue
        end

        # search dependencies for the requested one
        if any(
            startswith(x, package_name) for x in keys(project_tree[project_name_version])
        )
            push!(packages, project_name)
        end
    end
end

end
