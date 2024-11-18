#!/bin/bash

source /app/ww_service/bin/env.sh

log "Staring Service [$PROCESS_NAME]"

log "Running initial [cli] command"
#$CLI_CMD

while true; do
	log "WLMS is running"
	log "LICENSE CHECK Start!!"
	$LIC_CMD
	sleep 60
done	
