[![ci](https://github.com/kaloyanpenev/cpp-wasm-template/actions/workflows/ci.yml/badge.svg)](https://github.com/kaloyanpenev/cpp-wasm-template/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/kaloyanpenev/cpp-wasm-template/branch/main/graph/badge.svg)](https://codecov.io/gh/kaloyanpenev/cpp-wasm-template)
[![CodeQL](https://github.com/kaloyanpenev/cpp-wasm-template/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/kaloyanpenev/cpp-wasm-template/actions/workflows/codeql-analysis.yml)

**Note**: Point the badge links to your own repository after cloning.

## [Run it in your browser](https://penev.me/cpp-wasm-template/)

## What’s in this repo

C++23 starter template that can build a native binary and a WebAssembly target, with a minimal web UI to load and exercise the WASM module. It has full static analysis, CI and automatic github-pages deployment.

Tooling includes: 
- CMake
- Emscripten (C++ to wasm compiler)
- Vite (to package and serve the wasm module)
- Code Sanitizers (ASan, UBSan, MSan, LSan, TSan)
- Clang-tidy
- Cppcheck
- Clang-format (my personal preferences)
- GoogleTest
- Automatic project naming
- Automatic Code Coverage with codecov (per-commit CI)
- Build validation for all platforms/compilers (per-commit CI)
- Automatic GitHub Pages deployment (per-commit CI)

### Layout
- `project.json` — single source of truth for project name and display name (consumed by CMake and Vite).
- `src/main.cpp` — sample “Hello, world!” entry point for the native/WASM build.
- `test/` — GoogleTest example and CTest wiring.
- `cmake/` — shared options, warnings, sanitizers, cache, static analysis, and Emscripten configuration.
- `web/` — Vite app that loads the generated WASM module and shows console output/status.
- `web/build-wasm.sh` — helper script to configure and build the Emscripten target.
- `web/run-wasm.sh` — helper script to locally run the built WASM module with the web UI.
- `run-clang-format.sh` — helper script to run clang-format on all C++ files in the current directory.
- `run-clang-format.bat` — helper script to invoke run-clang-format.sh on Windows. Requires path to clang-format.exe passed in as first arg.

## Quick start (native)
```bash
cmake -S . -B build
cmake --build build
ctest --test-dir build
./build/your_project_name            # executable name follows project.json
```

## Build for WebAssembly
Prerequisites: 
- Emscripten SDK installed and `emcmake`/`emmake` available (`source /path/to/emsdk_env.sh`)
- Node.js 18.0.0 or higher (required for Vite 6)
```bash
cd web/
./build-wasm.sh Release         # outputs to build-wasm/web/
./run-wasm.sh                   # serves the wasm demo UI at http://localhost:3000
```
The Vite config injects `project.json` values and points the UI at the generated `<name>.js` module.

## Project configuration
Update `project.json` to rename the project and UI:
```json
{
  "name": "your_project_name",
  "display_name": "Your Project Name"
}
```
If you plan to publish the web package to npm, also update `web/package.json` and `web/package-lock.json`; CI replaces the placeholder name automatically, local builds do not.
