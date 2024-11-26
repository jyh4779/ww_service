#!/bin/bash

SRC_DIR="/storenext/Applications/ww_service"

APP_DIR="/app/ww_service"
LOG_DIR="$APP_DIR/log"
DATA_DIR="$APP_DIR/data"

SERVICE_DIR="/etc/systemd/system"
SERVICE_FILE="ww_service.service"

DOCKER_INSTALL_SCRIPT="/storenext/Applications/docker/bin/install.sh"

run_cmd() {
	local CMD="$1"
	echo "Executing: $CMD"
	eval "$CMD"
	if [ $? -eq 0 ]; then
		echo "[INFO] Command executed successfully: $CMD"
	else
		echo "[ERR] Command failed: $CMD"
		exit 1
	fi
}

echo "Westworld Linux Managemnet Service Install Start"

if [ -f "$DOCKER_INSTALL_SCRIPT" ]; then
        echo "[INFO] Found Docker install script: $DOCKER_INSTALL_SCRIPT"
        run_cmd "bash $DOCKER_INSTALL_SCRIPT"
else
        echo "[ERR] Docker install script not found: $DOCKER_INSTALL_SCRIPT"
	exit 1
fi

mkdir -p $DATA_DIR
mkdir -p $LOG_DIR

run_cmd "cp -r $SRC_DIR/* $APP_DIR"

run_cmd "cp $DATA_DIR/$SERVICE_FILE $SERVICE_DIR/"

run_cmd "systemctl daemon-reload"
run_cmd "systemctl enable $SERVICE_FILE"
run_cmd "systemctl start $SERVICE_FILE"

run_cmd "chmod -R 755 $APP_DIR"

run_cmd "find "$APP_DIR" -type f -exec chmod 711 {} \;;"

echo "Service installation completed successfully."
