using IntegrationTests
using PkgDependency
using Pkg
import Term.Trees: Tree

# compare each node of both generated dependency graphs
# the test requires, that both algorithm processes the dependencies in Pkg.project().dependencies()
# and Pkg.dependencies()[uuid].dependencies() in the same order
function compare_nodes(integTest, pkgDep, origin_string = "graph: root")
    if isnothing(integTest) || isnothing(pkgDep)
        @test isnothing(integTest) == isnothing(pkgDep)
        return nothing
    end

    integ_test_keys = collect(keys(integTest))
    sort!(integ_test_keys)
    # PkgDependency stores the package name together with the version number
    # e.g. Term v1.0.1
    # therefore remove version number, that packages can be compared
    pkg_dep_keys = map(x -> split(x)[1], collect(keys(pkgDep)))
    sort!(pkg_dep_keys)

    @test length(integ_test_keys) == length(pkg_dep_keys)
    @test integ_test_keys == pkg_dep_keys
    # printing the whole graphs does provide useful debug information
    # print more clever debug information
    if length(integ_test_keys) != length(pkg_dep_keys) || integ_test_keys != pkg_dep_keys
        println(origin_string)
        println("IntegrationTests.build_dependency_graph()\n$(integ_test_keys)")
        println("PkgDependency.builddict()\n$(pkg_dep_keys)")
        return nothing
    end

    # check the dependencies of this node
    for child in integ_test_keys
        pkgDep_name = ""
        for name in keys(pkgDep)
            # for PkgDependency, we need the package name + version nummer as key
            if startswith(name, child)
                pkgDep_name = name
                break
            end
        end

        compare_nodes(integTest[child], pkgDep[pkgDep_name], origin_string * "->" * child)
    end
    return
end

@testset "compare build_dependency_graph() with reference implementation for PkgDependency" begin
    # The test takes the dependency graph of the test environment from IntegrationTest,
    # builds the dependency graph with IntegrationTests.build_dependency_graph() and the
    # reference implementation PkgDependency.builddict() and compares the graphs node by node.
    inteGrationTestsGraph = IntegrationTests.build_dependency_graph()
    pkgDependencyGraph::AbstractDict = PkgDependency.builddict(
        Pkg.project().uuid, Pkg.project()
    )

    compare_nodes(inteGrationTestsGraph, pkgDependencyGraph)
end
