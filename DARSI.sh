#!/bin/bash

# Function to locate MATLAB
find_matlab() {
    # Determine the platform
    local platform=$(uname -s)

    # Paths for macOS installation
    if [[ "$platform" == "Darwin" ]]; then
        # Common installation directory for macOS
        local matlab_base="/Applications"

        # Find MATLAB .app bundles on macOS
        if [ -d "$matlab_base" ]; then
            latest_version=$(ls "$matlab_base" | grep -E "^MATLAB_R[0-9]{4}[a-z]\.app$" | sort -r | head -n 1)
            if [ -n "$latest_version" ]; then
                echo "$matlab_base/$latest_version/bin"
                return
            fi
        fi
    fi

    # Paths for Linux installation
    if [[ "$platform" == "Linux" ]]; then
        # Common installation directory for Linux
        local matlab_base="/usr/local/MATLAB"

        if [ -d "$matlab_base" ]; then
            latest_version=$(ls "$matlab_base" | grep -E "^R[0-9]{4}[a-z]" | sort -r | head -n 1)
            if [ -n "$latest_version" ]; then
                echo "$matlab_base/$latest_version/bin"
                return
            fi
        fi
    fi

    # If MATLAB is already in PATH, return its bin directory
    if command -v matlab &> /dev/null; then
        command -v matlab | xargs dirname
        return
    fi

    echo ""
}

# Find MATLAB installation directory
MATLAB_DIR=$(find_matlab)

# Check if MATLAB was found
if [ -z "$MATLAB_DIR" ]; then
    echo "MATLAB installation could not be found. Please ensure MATLAB is installed."
    exit 1
fi

# Add MATLAB to PATH
export PATH="$MATLAB_DIR:$PATH"

# Ensure MATLAB is accessible
if ! command -v matlab &> /dev/null; then
    echo "MATLAB could not be added to the PATH. Please check the installation."
    exit 1
fi

echo "MATLAB detected at $MATLAB_DIR"
