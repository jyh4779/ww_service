#!/bin/bash

APP_DIR="/app/ww_service"
LIC_DIR="/app/license"
SERVICE_DIR="/etc/systemd/system"
SERVICE_FILE="$SERVICE_DIR/ww_service.service"

systemctl stop $SERVICE_FILE
systemctl disable $SERVICE_FILE
systemctl daemon-reload

CMD="rm -rf $SERVICE_FILE"
eval $CMD

CMD="rm -rf $APP_DIR"
eval $CMD

CMD="rm -rf $LIC_DIR"
eval $CMD
