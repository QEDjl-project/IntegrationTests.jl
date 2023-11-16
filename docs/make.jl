
using Pkg

# targeting the correct source code
# this asumes the make.jl script is located in QEDbase.jl/docs
project_path = Base.Filesystem.joinpath(Base.Filesystem.dirname(Base.source_path()), "..")
Pkg.develop(; path=project_path)

using Documenter
using DocumenterMermaid
using IntegrationTests

readme_path = Base.Filesystem.joinpath(project_path, "README.md")
# Documenter.jl expect index.md as landing page
index_path = Base.Filesystem.joinpath(project_path, "docs/src/index.md")

# Copy README.md from the project base folder and use it as the start page
open(readme_path, "r") do readme_in
    readme_string = read(readme_in, String)

    # replace static links in the README.md with dynamic links, which are resolved by documenter.jl
    readme_string = replace(
        readme_string,
        "[Pipeline Tutorials](https://qedjl-project.github.io/IntegrationTests.jl/main/pipeline_tutorials.html)" => "[Pipeline Tutorials](@ref)",
        "[Integration Test Tool](https://qedjl-project.github.io/IntegrationTests.jl/main/integration_test_tool.html)" => "[Integration Test Tool](@ref)",
    )

    open(index_path, "w") do readme_out
        write(readme_out, readme_string)
    end
end

pages = [
    "Home" => "index.md",
    "Integration Test Tool" => "integration_test_tool.md",
    "Pipeline Tutorials" => "pipeline_tutorials.md",
    "References" => "api.md",
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

# delete README.md in the doc/src folder so that no one can accidentally edit the wrong file
rm(index_path)

deploydocs(; repo="github.com/QEDjl-project/IntegrationTests.jl.git", push_preview=false)
