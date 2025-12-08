[![ci](https://github.com/kaloyanpenev/cpp-hacking/actions/workflows/ci.yml/badge.svg)](https://github.com/kaloyanpenev/cpp-hacking/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/kaloyanpenev/cpp-hacking/branch/main/graph/badge.svg)](https://codecov.io/gh/kaloyanpenev/cpp-hacking)
[![CodeQL](https://github.com/kaloyanpenev/cpp-hacking/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/kaloyanpenev/cpp-hacking/actions/workflows/codeql-analysis.yml)

NOTE:
You need to point the badges in this README.md to your own repository in order to correctly set it, as this is not a template project.

## Project Configuration

The project name is defined in `project.json` and is used by CMake, Vite, and the web frontend.

To rename the project, edit `project.json`:
```json
{
    "name": "your_project_name",
    "display_name": "Your Project Name"
}
```

> **Note**: If you plan to publish the web package to npm, you'll need to manually update the `name` field in `web/package.json` and `web/package-lock.json`. The placeholder name is automatically replaced during CI builds but not locally.

