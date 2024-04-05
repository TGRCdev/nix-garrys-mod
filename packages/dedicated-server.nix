{
    lib,
    writeShellScriptBin,
    dedicated-server-unwrapped,
    bubblewrap,
    useBubblewrap ? true,
    bwrapNewSession ? false,
    defaultArgs ? {},
}: let
  args = {
    dataDir = "$PWD";
    extraPaths = [];
    consoleArgs = {};
  } // defaultArgs;
  consoleArgStr = with lib; strings.concatStringsSep " " (
    attrsets.mapAttrsToList (
        arg: val: "+${arg} ${strings.escapeShellArg (toString val)}"
    ) args.consoleArgs
  );
  warnNoBwrap = val: (lib.warn "`useBubblewrap=false` is intended for testing and debug purposes only." val);
in writeShellScriptBin "run-gmod-server" ''
DATADIR="${args.dataDir}"
EXTRA_PATHS="${lib.strings.concatStringsSep " " args.extraPaths}"

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
        echo "Checking for ${dedicated-server-unwrapped}/garrysmod/$1"
        if [ -d ${dedicated-server-unwrapped}/garrysmod/$1 -a ! -z "$(ls -A ${dedicated-server-unwrapped}/garrysmod/$1)" ]; then
            echo "Linking contents of $1"
            ln -s ${dedicated-server-unwrapped}/garrysmod/$1/* $DATADIR/$1
        fi
    fi
}

while true; do
    case $1 in
        -h | --help)
            printUsage
        ;;
        -d | --data-dir)
            DATADIR=$(realpath "$2")
            shift 2
        ;;
        -e | --extra-paths)
            EXTRA_PATHS=$2
            shift 2
        ;;
        --unsafe)
            UNSAFE=1
            shift
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
try_if_not_exist_mkdir logs

try_if_not_exist_mkdir cfg
echo "Checking for missing configurations"
cp --no-preserve=mode,ownership -L --no-clobber $cfg $DATADIR/cfg/ 2>/dev/null

try_if_not_exist_mkdir settings
echo "Checking for missing settings"
cp -rL --no-clobber --no-preserve=mode,ownership ${dedicated-server-unwrapped}/garrysmod/settings/* $DATADIR/settings 2>/dev/null

try_if_not_exist_mkdir data
echo "Checking for missing data files"
cp -rL --no-clobber --no-preserve=mode,ownership ${dedicated-server-unwrapped}/garrysmod/data/* $DATADIR/data 2>/dev/null

FAKEDIR=$(mktemp -d)
echo "Fake directory at $FAKEDIR. We will trick srcds into believing this is the write-able Garry's Mod dedicated server folder."

mkdir $FAKEDIR/garrysmod
touch $FAKEDIR/garrysmod/data $FAKEDIR/garrysmod/cache $FAKEDIR/steam_cache $FAKEDIR/logs

echo "Shadow-linking base server package contents"
cp -rs --no-preserve=ownership,mode ${dedicated-server-unwrapped}/* $FAKEDIR/ 2>/dev/null

if ! [ -z "$EXTRA_PATHS" ]; then
    echo "Clobbering with extra paths"
    for path in $EXTRA_PATHS; do
        printf "\t$path\n"
        if [[ -d "$path/data" ]]; then
            # Anything under `garrysmod/data` is assumed to be persistent. Copy it to stateful (DO NOT OVERWRITE)
            cp --no-preserve=mode,ownership --no-clobber -r $path/data/* $DATADIR/data 2>/dev/null
        else
            cp -rfs --no-preserve=ownership,mode $path/* $FAKEDIR/ 2>/dev/null
        fi
    done
fi

echo "Clobbering with stateful directory"
cp -rfs --no-preserve=ownership,mode $DATADIR/* $FAKEDIR/garrysmod 2>/dev/null

echo "Linking 'steam_cache', 'cache' and 'data' back to the stateful directory"
rm $FAKEDIR/garrysmod/cache $FAKEDIR/garrysmod/data $FAKEDIR/steam_cache $FAKEDIR/logs
ln -s $DATADIR/cache $DATADIR/data $DATADIR/logs $FAKEDIR/garrysmod/
ln -s $DATADIR/steam_cache $FAKEDIR/
touch $DATADIR/logs/console.log
ln -s $FAKEDIR/console.log $DATADIR/logs/console.log

echo "Running srcds_run ${if useBubblewrap then "with" else warnNoBwrap "WITHOUT"} bwrap";

${ if useBubblewrap && !bwrapNewSession then ''
# System check to make sure we can safely bwrap
# and avoid CVE-2017-5226
# https://github.com/containers/bubblewrap/issues/142
warn_vulnerable() {
    echo "ERROR: Unsafe bwrap usage."
    echo "Bubblewrap suffers from a vulnerability that could result in sandboxed programs escaping the sandbox."
    echo "See: https://github.com/containers/bubblewrap/issues/142"
    echo "To dismiss this message and continue running, perform one of these actions:"
    echo "    - Run \"sysctl $1\" to prevent unauthorized TIOCSTI usage during this boot"
    echo "    - Add \"$1\" to your boot arguments to prevent unauthorized TIOCSTI usage permanently"
    echo "    - Override \"bwrapNewSession = true\" in the \"garrys-mod.dedicated-server\" package. (May cause terminals to act funny)"
    echo "    - Pass \"--unsafe\" to this run script (NOT RECOMMENDED)"
    exit 1
}
if [ -z "$UNSAFE" ]; then
    if [ -f "/proc/sys/dev/tty/tiocsti_restrict" ]; then
        if [ "$(cat /proc/sys/dev/tty/tiocsti_restrict)" -ne 1 ]; then
            warn_vulnerable "dev.tty.tiocsti_restrict=1"
        fi
    elif [ -f "/proc/sys/dev/tty/legacy_tiocsti" ]; then
        if [ "$(cat /proc/sys/dev/tty/legacy_tiocsti)" -ne 0 ]; then
            warn_vulnerable "dev.tty.legacy_tiocsti=0"
        fi
    fi
else
    echo "WARN: Running with \"--unsafe\". Your system may be vulnerable to CVE-2017-5226. Caveat emptor."
fi
''
else ""}

${ if useBubblewrap then ''
    ${bubblewrap}/bin/bwrap ${if bwrapNewSession then "--new-session" else ""} \
        --ro-bind /nix/store /nix/store \
        --ro-bind /run/current-system/sw /run/current-system/sw \
        --ro-bind /proc /proc \
        --ro-bind /etc/ssl /etc/ssl \
        --ro-bind /etc/static/ssl /etc/static/ssl \
        --ro-bind /etc/resolv.conf /etc/resolv.conf \
        --tmpfs /tmp \
        --dev /dev \
        --dev-bind /dev/urandom /dev/urandom \
        --dev-bind /dev/tty /dev/tty \
        --bind $FAKEDIR $FAKEDIR \
        --ro-bind $DATADIR $DATADIR \
        --bind $DATADIR/cache $DATADIR/cache \
        --bind $DATADIR/steam_cache $DATADIR/steam_cache \
        --bind $DATADIR/data $DATADIR/data \
        --bind $DATADIR/logs $DATADIR/logs \
        $FAKEDIR/srcds_run ${consoleArgStr} "$@"
'' else ''
    $FAKEDIR/srcds_run ${consoleArgStr} "$@"
''
}
''