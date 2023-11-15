
using Pkg

# targeting the correct source code
# this asumes the make.jl script is located in QEDbase.jl/docs
project_path = Base.Filesystem.joinpath(Base.Filesystem.dirname(Base.source_path()), "..")
Pkg.develop(; path=project_path)

using Documenter
using DocumenterMermaid
using IntegrationTests

pages = [
    "Home" => "index.md",
    "Integration Test Tool" => "integration_test_tool.md",
    "Pipeline Tutorials" => "pipeline_tutorials.md",
]

makedocs(;
    sitename="IntegrationTests.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://qedjl-project.gitlab.io/IntegrationTests.jl",
        assets=String[],
    ),
    modules=[IntegrationTests],
    authors="Simeon Ehrig",
    repo=Documenter.Remotes.GitHub("QEDjl-project", "IntegrationTests.jl "),
    pages=pages,
)
deploydocs(; repo="github.com/QEDjl-project/QEDbase.jl.git", push_preview=false)
