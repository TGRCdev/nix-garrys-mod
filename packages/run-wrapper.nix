{
    writeShellScriptBin,
    dedicated-server,
}: writeShellScriptBin "run-gmod-server" ''
DATADIR="$PWD"
EXTRA_PATHS=""

printUsage() {
echo "Usage: $0 -d /path/to/garrysmod-server-data -- <srcds_run args>"
echo "Flags:"
printf "\t--help || -h : Print usage and flags\n"
printf "\t--data-dir || -d : Path to a writable data folder of a Garry's Mod server\n"
exit 127
}

try_command() {
    if ! $@; then
        echo "ERROR: Failed to run command. Please check that the data directory is write-able".
        exit 1
    fi
}

try_mkdir() {
    try_command mkdir -p $DATADIR/$1
}

try_if_not_exist_mkdir() {
    if [ ! -d $DATADIR/$1 ]; then
        echo "Creating $1 dir"
        try_mkdir $1
    fi
}

try_if_not_exist_mkdir_and_link_contents() {
    if [ ! -d $DATADIR/$1 ]; then
        echo "Creating $1 dir"
        try_mkdir $1
        echo "Checking for ${dedicated-server}/garrysmod/$1"
        if [ -d ${dedicated-server}/garrysmod/$1 -a ! -z "$(ls -A ${dedicated-server}/garrysmod/$1)" ]; then
            echo "Linking contents of $1"
            ln -s ${dedicated-server}/garrysmod/$1/* $DATADIR/$1
        fi
    fi
}

while true; do
case $1 in
    -h | --help)
        printUsage
        shift
    ;;
    -d | --data-dir)
        DATADIR=$(realpath "$2")
        shift 2
    ;;
    -e | --extra-paths)
        EXTRA_PATHS=$2
        shift 2
        break;
    ;;
    --)
        shift
        break;
    ;;
    *)
        if [ -z "$1" ]; then shift; break; fi
        echo "Unknown argument \"$1\""
        printUsage
    ;;
esac
done

echo "State dir: $DATADIR"
echo "Setting up stateful directories. We will make required directories and, if needed, copy default configuration files."
try_if_not_exist_mkdir maps
try_if_not_exist_mkdir backgrounds
try_if_not_exist_mkdir gamemodes
try_if_not_exist_mkdir materials
try_if_not_exist_mkdir lua
try_if_not_exist_mkdir scenes
try_if_not_exist_mkdir models
try_if_not_exist_mkdir scripts/vehicles
try_if_not_exist_mkdir particles
try_if_not_exist_mkdir sound
try_if_not_exist_mkdir resource/fonts
try_if_not_exist_mkdir resource/localization
try_if_not_exist_mkdir addons
try_if_not_exist_mkdir cache
try_if_not_exist_mkdir steam_cache

try_if_not_exist_mkdir cfg
echo "Checking for missing configurations"
cp --no-preserve=mode,ownership -L --no-clobber $cfg $DATADIR/cfg/ 2>/dev/null

try_if_not_exist_mkdir settings
echo "Checking for missing settings"
cp -rL --no-clobber --no-preserve=mode,ownership ${dedicated-server}/garrysmod/settings/* $DATADIR/settings 2>/dev/null

try_if_not_exist_mkdir data
echo "Checking for missing data files"
cp -rL --no-clobber --no-preserve=mode,ownership ${dedicated-server}/garrysmod/data/* $DATADIR/data 2>/dev/null

FAKEDIR=$(mktemp -d)
echo "Fake directory at $FAKEDIR. We will trick srcds into believing this is the write-able Garry's Mod dedicated server folder."

mkdir $FAKEDIR/garrysmod
touch $FAKEDIR/garrysmod/data $FAKEDIR/garrysmod/cache $FAKEDIR/steam_cache

echo "Shadow-linking base server package contents"
cp -rs --no-preserve=ownership,mode ${dedicated-server}/* $FAKEDIR/

if ! [ -z "$EXTRA_PATHS" ]; then
    echo "Clobbering with extra paths"
    for path in $EXTRA_PATHS; do
        printf "\t$path\n"
        if [[ -d "$path/data" ]]; then
            # Anything under `garrysmod/data` is assumed to be persistent. Copy it to stateful (DO NOT OVERWRITE)
            cp --no-preserve=mode,ownership --no-clobber -r $path/data/* $DATADIR/data 2>/dev/null
        else
            cp -rfs --no-preserve=ownership,mode $path/* $FAKEDIR/
        fi
    done
fi

echo "Clobbering with stateful directory"
cp -rfs --no-preserve=ownership,mode $DATADIR/* $FAKEDIR/garrysmod

echo "Linking 'steam_cache', 'cache' and 'data' back to the stateful directory"
rm $FAKEDIR/garrysmod/cache $FAKEDIR/garrysmod/data $FAKEDIR/steam_cache
ln -s $DATADIR/cache $DATADIR/data $FAKEDIR/garrysmod/
ln -s $DATADIR/steam_cache $FAKEDIR/

echo "Running srcds_run"

$FAKEDIR/srcds_run "$@"
''