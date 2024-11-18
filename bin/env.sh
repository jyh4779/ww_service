ROOT="/app/ww_service"
#ROOT="/storenext/Applications/ww_service"

VER="1.0"

PROCESS_NAME="$(basename "$0" .sh)"

BIN_DIR="$ROOT/bin"
LOG_DIR="$ROOT/log"
DATA_DIR="$ROOT/data"
CLI_DIR="$DATA_DIR/client_data"

LOG_FILE="$LOG_DIR/$PROCESS_NAME.log"
LDIF_FILE="$DATA_DIR/cli.ldif"

CLI_CMD="$BIN_DIR/cli.sh"
LIC_CMD="$BIN_DIR/wwls.sh"

REZ_DOCKERD="rez-env docker -- dockerd"
REZ_DOCKER="rez-env docker -- docker"
DOCKER_SERVER="10.0.20.7:5000"
LICENSE_ARRAY=("yeti_pixar" "foundry" "clarisse" "houdini")
CONTAINER_NAMES=("license" "foundry" "clarisse" "houdini")
DOCKER_DIR="/opt"
LIC_DIR="/storenext2/new_Applications/license"

mkdir -p $BIN_DIR
mkdir -p $LOG_DIR
mkdir -p $DATA_DIR

log() {
        local MSG="$1"
        local TIMESTAMP=$(date "+%Y%m%d %H:%M:%S")
        echo "[$PROCESS_NAME][$TIMESTAMP] $MSG" >> "$LOG_FILE"
}

export PATH=$PATH:/westworld/inhouse/bin:/westworld/inhouse/rez/bin/rez
export REZ_PACKAGES_PATH=$REZ_PACKAGES_PATH:/westworld/inhouse/tool/rez-packages
