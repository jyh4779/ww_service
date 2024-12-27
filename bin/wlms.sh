#!/bin/bash

source /app/ww_service/bin/env.sh

init() {
	mkdir -p $BIN_DIR
	mkdir -p $LOG_DIR
	mkdir -p $DATA_DIR
	touch $LOG_FILE
}

update_check() {
	local CHECK_PATH="$SRC_ROOT/bin"
	local ENV_FILE="$CHECK_PATH/env.sh"

	if [ ! -d "$CHECK_PATH" ]; then
		log "Version check failed: Directory [$CHECK_PATH] does not exist."
		return 0 
	fi

	if [ ! -f "$ENV_FILE" ]; then
		log "Version check failed: File [$ENV_FILE] does not exist."
		return 0
	fi
	
	local SOURCE_VER
	SOURCE_VER=$(grep '^VER=' "$ENV_FILE" | cut -d'=' -f2)

	if [ "$VER" == "$SOURCE_VER"  ]; then
		log "Version check passed: VER matches [$VER]."
		return 0
	else
		log "Version check failed: Mismatch between current VER [$VER] and source VER [$SOURCE_VER]."
		return 1
	fi
}

update() {
	if [ -f "$UPDATE_SH" ]; then
		log "Update script [$UPDATE_SH] found. Executing update."
		bash "$UPDATE_SH"
		log "Update completed. Sleeping for 120 seconds."
		sleep 120
	else
		log "Update script [$UPDATE_SH] not found. Skipping update."
	fi
}

cli_flag=false

cli() {
	if !$cli_flag; then
		log "Running initial [cli] command"
		
		local chk_client_file="/storenext/inhouse/rez/ww_bin/chk_client"

		if [ -f "$chk_client_file" ]; then
			log "File [$chk_client_file] found. Executing the file."

			"$chk_client_file"
			cli_flag=true
		else
			log "File [$chk_client_file] not found. Skipping execution."
		fi
	else
		log "[cli] command already executed. Skipping."
	fi	
}

log "Staring Service [$PROCESS_NAME]"

init

log "Check Update Start"
if update_check; then
	log "Update check passed."
else
	update
fi

log "Running initial [cli] command"
#$CLI_CMD

while true; do
	log "WLMS is running"
	log "LICENSE CHECK Start!!"
#	$LIC_CMD

	cli
	sleep 120
done	
