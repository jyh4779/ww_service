#!/bin/bash

SRC_DIR="/storenext/Applications/ww_service"

APP_DIR="/app/ww_service"
DATA_DIR="$APP_DIR/data"

SERVICE_DIR="/etc/systemd/system"
SERVICE_FILE="ww_service.service"

run_cmd() {
	local CMD="$1"
	echo "Executing: $CMD"
	eval "$CMD"
	if [ $? -eq 0 ]; then
		echo "Command executed successfully: $CMD"
	else
		echo "Command failed: $CMD"
		exit 1
	fi
}

echo "Westworld Linux Managemnet Service Install Start"

mkdir -p $DATA_DIR

run_cmd "cp -r $SRC_DIR/* $APP_DIR"

run_cmd "cp $DATA_DIR/$SERVICE_FILE $SERVICE_DIR/"

run_cmd "systemctl daemon-reload"
run_cmd "systemctl enable $SERVICE_FILE"
run_cmd "systemctl start $SERVICE_FILE"

run_cmd "chmod -R 755 $APP_DIR"

run_cmd "find "$APP_DIR" -type f -exec chmod 711 {} \;;"

echo "Service installation completed successfully."
