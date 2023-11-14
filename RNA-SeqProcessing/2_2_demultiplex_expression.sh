#!/opt/homebrew/bin/bash -i
# Find working directiory


# Function to display script usage
usage() {
 echo "Usage: $0 [OPTIONS]"
 echo "Options:"
 echo " -h, --help    Display this help message"
 echo " -i, --reads   File path to filtered reads "
 echo " -n, --index   File path to gene index"
 echo " -g, --growth  File path to indexes for Growth Conditions"
 echo " -o, --out     File path to output"
}

has_argument() {
    [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*)  ]];
}

extract_argument() {
  echo "${2:-${1#*=}}"
}

handle_options() {
  while [ $# -gt 0 ]; do
    case $1 in
      -h | --help)
        usage
        exit 0
        ;;

      -i | --reads*)
        if ! has_argument $@; then
          echo "Read file not specified." >&2
          usage
          exit 1
        fi

        READ_REL=$(extract_argument $@)
        READ=$(realpath $READ_REL)
        shift
        ;;
      -n | --index*)
        if ! has_argument $@; then
          echo "Gene index file not specified." >&2
          usage
          exit 1
        fi

        INDEX_REL=$(extract_argument $@)
        INDEX=$(realpath $INDEX_REL)
        shift
        ;;
      -g | --growth*)
        if ! has_argument $@; then
          echo "Growth condition index file not specified." >&2
          usage
          exit 1
        fi

        GROWTH_REL=$(extract_argument $@)
        GROWTH=$(realpath $GROWTH_REL)
        shift
        ;;
      -o | --out*)
        if ! has_argument $@; then
          echo "Output directory not specified." >&2
          usage
          exit 1
        fi

        OUT_FOLDER_REL=$(extract_argument $@)
        if [ ! -d $OUT_FOLDER_REL ]
            then 
             mkdir $OUT_FOLDER_REL
        fi  
        OUT_FOLDER=$(realpath $OUT_FOLDER_REL)

        shift
        ;;
      *)
        echo "Invalid option: $1" >&2
        usage
        exit 1
        ;;
    esac
    shift
  done
}

# Main script execution
handle_options "$@"

# mandatory arguments
if [ ! "$READ" ] || [ ! "$INDEX" ] || [ ! "$GROWTH" ] || [ ! "$OUT_FOLDER" ]; then
  echo "arguments -i, -n, -g and -o must be provided" >&2;
  usage; exit 1
fi

# make output folder if not existing
if [ ! -d $OUT_FOLDER ] 
then 
    mkdir $OUT_FOLDER
fi

## Make temporary directory
# the directory of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# omit the -p parameter to create a temporal directory in the default location
WORK_DIR=$(mktemp -d "$DIR"/tmpXXXXX)

# check if tmp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

# deletes the temp directory
function cleanup {      
  rm -rf "$WORK_DIR"
  echo "Deleted temp working directory $WORK_DIR"
}

# register the cleanup function to be called on the EXIT signal
trap cleanup EXIT


declare -A dict_group
while IFS=' ' read -r value key; do
    dict_group[$key]=$value
done < $INDEX


declare -A dict_gc

while IFS=' ' read -r key value; do
    dict_gc[$key]=$value
done < $GROWTH
echo $WORK_DIR

echo "Filtering..."
cat $READ | awk '/TATTAGGCTTCTCCTCAGCG/' | awk '/TCACTGGCCGTCGTTTTACATGACTGACTGA/' | awk -v o=$OUT_FOLDER 'FNR==1{++f} \
f==1 {a[$2]=$1} \
f==2 {b[$1]=$2} \
f==3 {ind1=substr($0, 0, 4); bc=substr($0,60,20); group=substr($0, 25, 4); if((group in a) && (ind1 in b)){str = sprintf("%s%s", o, "/"b[ind1]"_"a[group]".txt")
printf "%s\n", bc >>str}}' $INDEX $GROWTH -


echo "Counting unique barcodes..."
OUT=$OUT_FOLDER"/*.txt"
for FILE in $OUT;do
    echo $FILE
    filename="${FILE##*/}"
    filename="${filename%.*}"
    echo $filename
    sort --parallel 20 -T ./ $FILE | uniq -c | sort --parallel 20  -bgr -T ./|  awk -v OFS="\t" '$1=$1' > $OUT_FOLDER"/"$filename"_expression_counted.csv";
done
