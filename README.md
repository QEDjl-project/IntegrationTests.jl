# IntegrationTests

[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

`IntegrationTests` takes a `Project.toml`, searches for a specific package in the dependency graph and returns a list of packages that use the specified package.

⚠️ DISCLAIMER ⚠️

This project moves the project independent part of the [integTestGen.jl](https://github.com/QEDjl-project/QED.jl/tree/dev/.ci/integTestGen) script to an external project to make it reusable. If we can use this package in our CI of our QED projects, it is ready for Julia registry and can be used by other projects.

# Roadmap

1. support GitLab CI (version 0.1)
2. support GitHub Workflows (version 0.2)
