#!/usr/bin/env bash
# Build script for Emscripten/WebAssembly target
#
# Prerequisites:
#   - Install Emscripten SDK: https://emscripten.org/docs/getting_started/downloads.html
#   - Source the emsdk_env.sh before running this script:
#     source /path/to/emsdk/emsdk_env.sh
#
# Usage:
#   ./scripts/build-wasm.sh [build_type]
#
# Arguments:
#   build_type - Release (default), Debug, RelWithDebInfo, MinSizeRel

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_TYPE="${1:-Release}"
BUILD_DIR="$PROJECT_ROOT/build-wasm"

# Check if emcmake is available
if ! command -v emcmake &> /dev/null; then
    echo "Error: emcmake not found. Please install and activate the Emscripten SDK:"
    echo ""
    echo "  # Install Emscripten SDK"
    echo "  git clone https://github.com/emscripten-core/emsdk.git"
    echo "  cd emsdk"
    echo "  ./emsdk install latest"
    echo "  ./emsdk activate latest"
    echo ""
    echo "  # Activate for current shell"
    echo "  source ./emsdk_env.sh"
    echo ""
    exit 1
fi

echo "=== Building order-engine for WebAssembly ==="
echo "Build type: $BUILD_TYPE"
echo "Build directory: $BUILD_DIR"
echo ""

# Configure
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

emcmake cmake "$PROJECT_ROOT" \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DBUILD_TESTING=OFF

# Build
emmake make -j"$(nproc)"

echo ""
echo "=== Build complete ==="
echo "Output files in: $BUILD_DIR/web/"
ls -la "$BUILD_DIR/web/" 2>/dev/null || echo "(no output yet)"

