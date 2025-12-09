#!/bin/bash
set -e  # Exit immediately if any command fails

# This script runs clang-format on all C/C++ files in the current directory and its subdirectories.

# Configuration
clang_format_version="18" # Hardcoded clang-format version to use

# It takes in an optional argument --executable=<path_to_clang_format> to specify the clang-format executable.
# This argument is primarily used by run-clang-format.bat when running on Windows.
# If the executable is not provided, it installs clang-format-<version> using apt-get.
# The script also accepts additional arguments that are passed directly to clang-format for CI purposes.

# Default parameters
directory="." # Recursively search from the repository root (script location)

# Directories to exclude from formatting (contain generated/build files)
exclude_dirs=("build" "build-wasm" "node_modules" ".git")

# File extensions to format
format_extensions=("*.c" "*.cpp" "*.h" "*.hpp" "*.tpp")

# Parse command-line arguments for --executable=... and collect the rest
executable=""
extra_args=()  # Array for additional arguments

for arg in "$@"; do
    case $arg in
        --executable=*)
            executable="${arg#*=}" # Path to executable (primarily used by .bat script)
            ;;
        *)
            extra_args+=("$arg")  # Collect arguments for clang-format
            ;;
    esac
done

# If no executable provided, install clang-format via apt-get
if [ -z "$executable" ]; then
    echo "No executable provided via command-line argument --executable."
    echo "Installing clang-format-${clang_format_version} using apt..."

    if [ "$(id -u)" -eq 0 ]; then
        # Running as root, install without sudo
        apt update
        apt install -y clang-format-${clang_format_version}
    else
        # Running as a non-root user, use sudo
        if command -v sudo >/dev/null 2>&1; then
            sudo apt update
            sudo apt install -y clang-format-${clang_format_version}
        else
            echo "Error: sudo is not available. Run as root or install clang-format manually." >&2
            exit 1
        fi
    fi

    executable="clang-format-${clang_format_version}"
fi

# Verify the executable is available:
if [[ "$executable" == *"/"* ]]; then
    if [ ! -f "$executable" ]; then
        echo "Error: clang-format executable not found at '$executable'." >&2
        exit 1
    fi
else
    if ! command -v "$executable" >/dev/null 2>&1; then
        echo "Error: clang-format not found in PATH." >&2
        exit 1
    fi
fi

echo "Formatting directory: $(pwd)"
echo "Using clang-format executable: $executable"
echo "Searching for files with extensions: ${format_extensions[*]}"

# Build prune conditions for excluded directories
prune_conditions=""
for dir in "${exclude_dirs[@]}"; do
    prune_conditions="${prune_conditions} -name ${dir} -o"
done
prune_conditions="${prune_conditions% -o}"  # Remove trailing " -o"

# Build name conditions for file extensions
name_conditions=""
for ext in "${format_extensions[@]}"; do
    name_conditions="${name_conditions} -name ${ext} -o"
done
name_conditions="${name_conditions% -o}"  # Remove trailing " -o"

# Run clang-format using find & xargs while passing additional arguments
# Exclude build directories and other generated directories for better performance
find "$directory" \
  \( ${prune_conditions} \) -prune -o \
  -type f \
  \( ${name_conditions} \) \
  -print0 | \
xargs -r --null --max-procs=0 "$executable" -style=file -i "${extra_args[@]}"

echo "Clang-format completed."

