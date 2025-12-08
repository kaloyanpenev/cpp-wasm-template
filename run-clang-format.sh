#!/bin/bash
set -e  # Exit immediately if any command fails

# This script runs clang-format on all C/C++ files in the current directory and its subdirectories.

# Configuration
clang_format_version="18" # Hardcoded clang-format version to use

# It takes in an optional argument --executable=<path_to_clang_format> to specify the clang-format executable.
# This argument is primarily used by run-clang-format.bat when running on Windows.
# If the executable is not provided, it installs clang-format-<version> using apt-get.
# The script also accepts additional arguments that are passed directly to clang-format.

# Default parameters
directory="." # Recursively search from the current directory
extension_regex="c|cpp|h|hpp|tpp" # All file types to format

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

echo "Using clang-format executable: $executable"
echo "Searching for files matching pattern: .*\.($extension_regex)"

# Run clang-format using find & xargs while passing additional arguments
find "$directory" \
  -regextype posix-extended \
  -iregex ".*\.($extension_regex)" \
  -type f \
  -print0 | \
xargs --null --max-procs=0 "$executable" -style=file -i "${extra_args[@]}"

echo "Clang-format completed."

