#!/bin/bash

source /app/ww_service/bin/env.sh

CONTAINERS=("houdini" "clarisse" "foundry" "license")

CMD_LOG_FLAG=0

if [[ $CMD_LOG_FLAG -eq 1 ]];then
        CMD_LOG=">> $LOG_FILE 2>&1"
else
        CMD_LOG="> /dev/null 2>> $LOG_FILE"
fi

set_con() {
	local SERVICE="$1"

	if [ -z "$SERVICE" ]; then
		log_message "No specific service specified. Starting all services."
		SERVICE="all"
	fi

	if [[ $SERVICE == "all" ]]; then
		log_message "Starting all services using Docker Compose."
		#CMD="$REZ_DOCKER_COMPOSE up -d $CMD_LOG"
		CMD="$LIC_SH_CMD $SERVICE $CMD_LOG"
		log_message "CMD=[$CMD]"
		eval $CMD
	else
		log_message "Starting service [$SERVICE] using Docker Compose."
		#CMD="$REZ_DOCKER_COMPOSE up -d "$SERVICE" $CMD_LOG"
		CMD="$LIC_SH_CMD $SERVICE $CMD_LOG"
		log_message "CMD=[$CMD]"
		eval $CMD
	fi
	log_message "Docker Compose command executed for [$SERVICE]."
}

stop_containers() {
	log_message "Stopping and removing all containers using Docker Compose."
	$REZ_DOCKER_COMPOSE down $CMD_LOG
	log_message "All containers stopped and removed."
}

chk_con() {
	for container_name in "${CONTAINERS[@]}"; do
		CHK_CMD="docker ps --filter name=$container_name |grep $container_name|wc -l"
		CHK_RESULT=`eval "$CHK_CMD"`
		if [ $CHK_RESULT -eq 0 ]; then
			log_message "$container_name is not running. Attempting to restart"
			set_con "$container_name"
		else
			log_message "$container_name is running"
		fi
	done
	return 0
}

chk_daemon() {
	local MAX_CNT=6
	local CNT=$1

	log_message "[Chk_daemon] Check Docker Service Start ($CNT/$MAX_CNT)"
	if (( $CNT >= $MAX_CNT )); then
		log "[Chk_daemon] Docker daemon failed to start after $MAX_CNT attempts.Exiting."
		exit 1
	fi

	if ! systemctl is-active --quiet docker; then
		log_message "[Chk_daemon] Starting Docker deamon."
		CMD="systemctl start docker"
		log_message "[Chk_daemon] CMD=[$CMD]"
		eval $CMD

		sleep 2
		
		chk_daemon $((CNT + 1))
	else
		log_message "[Chk_daemon] Docker daemon is already running"
	fi
}
#cd $DOCKER_COMPOSE_DIR

chk_daemon 1

chk_con
