ROOT="/app/ww_service"
SRC_ROOT="/storenext/Applications/ww_service"

VER=1.2

PROCESS_NAME="$(basename "$0" .sh)"

BIN_DIR="$ROOT/bin"
LOG_DIR="$ROOT/log"
DATA_DIR="$ROOT/data"
DOCKER_COMPOSE_DIR="$ROOT/docker"
CLI_DIR="$DATA_DIR/client_data"

LOG_FILE="$LOG_DIR/ww_service.log"
LDIF_FILE="$DATA_DIR/cli.ldif"

UPDATE_SH="$BIN_DIR/update_$VER.sh"
CLI_CMD="$BIN_DIR/cli.sh"
LIC_CMD="$BIN_DIR/wwls.sh"

source $DATA_DIR/ip
DOCKER_SERVER=$IP

#REZ_DOCKER="rez-env docker_test -- docker"
REZ_DOCKER="docker"
REZ_DOCKERD="$REZ_DOCKER""d"
REZ_DOCKER_COMPOSE="$REZ_DOCKER"" compose"
DOCKER_COMPOSE_FILE="$DOCKER_COMPOSE_DIR/docker-compose.yml"
DOCKER_ENV_FILE="$DOCKER_COMPOSE_DIR/.env"

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
