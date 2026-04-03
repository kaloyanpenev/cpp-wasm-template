set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NPM_DIR="$PROJECT_ROOT/build-wasm/web"

echo "=== Serving WebAssembly build with Vite ==="

cd "$NPM_DIR"
npm install
npm run dev