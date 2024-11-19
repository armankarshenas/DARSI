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


# Default values for optional flags
path_to_save=""
path_to_images=""
path_to_histograms=""
max_iter=10000
train_split=0.7
eval_split=0.15

# Function to display usage information
usage() {
    echo "Usage: $0 -i input_file [-s path_to_save] [-m path_to_images] [-h path_to_histograms] [-l max_iterations] [-t train_split] [-e eval_split]"
    echo
    echo "  -i           Input MPRA data file (CSV or Excel) [mandatory]"
    echo "  -s           Path to save output [optional]"
    echo "  -m           Path to save images [optional]"
    echo "  -h           Path to save histograms [optional]"
    echo "  -l           Maximum number of binning iterations [optional, default: 10000]"
    echo "  -t          Train split ratio [optional, default: 0.70]"
    echo "  -e          Evaluation split ratio [optional, default: 0.15]"
    exit 1
}

# Parse command-line options
while getopts ":i:s:m:h:l:t:e:" opt; do
    case $opt in
        i)
            input_file=$OPTARG
            ;;
        s)
            path_to_save=$OPTARG
            ;;
        m)
            path_to_images=$OPTARG
            ;;
        h)
            path_to_histograms=$OPTARG
            ;;
        l)
            max_iter=$OPTARG
            ;;
        t)
            train_split=$OPTARG
            ;;
        e)
            eval_split=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done

# Check if mandatory input flag -i is set
if [ -z "$input_file" ]; then
    echo "Error: Input file (-i) is required." >&2
    usage
fi

# Print out the provided arguments
echo "Input file: $input_file"
echo "Path to save: $path_to_save"
echo "Path to images: $path_to_images"
echo "Path to histograms: $path_to_histograms"
echo "Maximum binning iterations: $max_iter"
echo "Train split: $train_split"
echo "Evaluation split: $eval_split"

# Get the path to the current directory (where the bash script is located)
script_dir=$(dirname "$(realpath "$0")")

# Path to the Scripts subdirectory (where MATLAB functions are located)
scripts_dir="$script_dir/Scripts"

# Change directory to where MATLAB functions are located
cd "$scripts_dir" || exit

# Call MATLAB script with the provided arguments
matlab -nodisplay -nosplash -nodesktop -r "addpath(genpath(pwd)); fprintf('Running function 1: sequenceDataProcessing \n'); sequenceDataProcessing('$input_file','$path_to_save', '$path_to_histograms','$path_to_images', $max_iter, $train_split, $eval_split); fprintf('Running function 2: trainGeneSpecificCNN \n'); trainGeneSpecificCNN('$path_to_save',$train_split,$eval_split); fprint('Running function 3:saliencyMapsGenerator \n'); saliencyMapsGenerator('$path_to_images','$path_to_save'); fprint('Running function 4:findBindingSites \n'); findBindingSites('$path_to_save','$path_to_save');exit;"
