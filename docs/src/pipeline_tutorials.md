# Pipeline Tutorials

This section shows how to set up CI tests for different platforms with `IntegrationTests.jl`. In general, any CI platform can use `IntegrationTests.jl` if it fulfills a requirement. It must be possible to generate new jobs during the runtime of a CI pipeline depending on the output of a Julia script.

## GitLab CI

GitLab CI offers the [parent-child-pipeline](https://docs.gitlab.com/ee/ci/pipelines/downstream_pipelines.html#parent-child-pipelines) function. This allows you to generate GitLab CI job yaml code in a GitLab CI job and start the generated jobs in the same pipeline.


For our example, let's assume that we use a Julia script called `generateIntegrationTests.jl` that uses `IntegrationTests::depending_projects()` to generate the integration tests. This script generates valid GitLab CI yaml code and outputs it to stdout. The GitLab CI code in `.gitlab-ci.yml` could look like this:

```yaml
stages:
  - generator
  - runTests

generateIntegrationTests:
  stage: generator
  image: "julia:1.10"
  script:
    - julia --project=. -e 'import Pkg; Pkg.instantiate()'
    - julia --project=. generateIntegrationTests.jl 2> /dev/null 1> jobs.yaml
    - cat jobs.yaml
  interruptible: true
  artifacts:
    paths:
      - jobs.yaml
    expire_in: 1 week

runIntegrationTests:
  stage: runTests
  trigger:
    include:
    - artifact: jobs.yaml
      job: generateIntegrationTests
    strategy: depend
```

The content of the dynamically generated `jobs.yaml` could look as follows for the example packages `MyPkgA` and `MyPkgB`:

```yaml
integrationTestMyPkgB:
    image: alpine:latest
    script:
        - echo "run Integration Test for package MyPkgB"

integrationTestMyPkgA:
    image: alpine:latest
    script:
        - echo "run Integration Test for package MyPkgA"

```

## GitHub Actions

GitHub provides the [matrix](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs) mechanism to automatically generate jobs from a given input. Normally, the input is hardcoded as one or more `JSON` arrays in the Github Actions `yaml` file. A small workaround allows the input of a `JSON` array to be generated during the runtime of a Github Actions job. This makes it possible to dynamically create new jobs during the runtime of the CI pipeline.

For our example, let's assume that we use a Julia script named `generateIntegrationTests.jl` that uses `IntegrationTests::depending_projects()` to generate the integration tests. The GitHub Actions workflow looks like this:

```yaml
name: IntegrationTest
on:
  push:
    branches:
      - main
      - dev
    tags: ['*']
  pull_request:
  workflow_dispatch:
concurrency:
  # Skip intermediate builds: always.
  # Cancel intermediate builds: only if it is a pull request build.
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ startsWith(github.ref, 'refs/pull/') }}
jobs:
    generate:
        name: Github Action - Generator Integration Jobs
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v3
        - uses: julia-actions/setup-julia@v1
            with:
            version: "1.10"
            arch: x64
        - uses: julia-actions/cache@v1
        - uses: julia-actions/julia-buildpkg@v1
        - id: set-matrix
            run: echo "matrix=$(julia --project=${GITHUB_WORKSPACE} generateIntegrationTests.jl 2> /dev/null)" >> $GITHUB_OUTPUT
        outputs:
            matrix: ${{ steps.set-matrix.outputs.matrix }}

    run-matrix:
        needs: generate
        runs-on: ubuntu-latest
        strategy:
            matrix:
                package: ${{ fromJson(needs.generate.outputs.matrix) }}
        steps:
            # define the job body of your integration test here depending on the `matrix.package` parameter
            - run: echo "run Integration Test for package ${{ matrix.package }}"
```

The workflow contains two jobs. The first job is the `generate` job, which generates a list of package names to be tested as an integration test. The `run-matrix` job is a template that takes a package name and runs an integration test job for the specific package name. Therefore, the `run-matrix` is executed `N` times.

!!! note

    `matrix: ${{ steps.set-matrix.outputs.matrix }}` expects a `JSON` array. Fortunately, when we print a Julia vector, the output is in the form of a `JSON` array. Therefore, you can simply use `print(depending_projects())` to generate the output of `generateIntegrationTests.jl`. But be careful not to print any other output, for example, the activation message of `Pkg.activate`. This output can be redirected to `2> /dev/null` for example.

Source: https://tomasvotruba.com/blog/2020/11/16/how-to-make-dynamic-matrix-in-github-actions/

# Real World Example

The `IntegrationTest.jl` package uses the GitLab CI `parent-child-pipeline` and the GitHub Action `matrix` function for its own CI tests to check the functionality. The generator scripts can be found in the `.ci` folder. The GitLab CI Job yaml code is written in the `.gitlab-ci.yml` and the GitHub Action Code is written in the `.github/workflows/integrationTests.yml`.
