#!/bin/bash

source /app/ww_service/bin/env.sh

#DIR="/storenext/inhouse/rez/ww_bin"
#CMD="$DIR/lic_test"
CONTAINERS=("houdini" "clarisse" "foundry" "license")

CMD_LOG_FLAG=0

if [[ $CMD_LOG_FLAG -eq 1 ]];then
        CMD_LOG=">> $LOG_FILE 2>&1"
else
        CMD_LOG="> /dev/null 2>> $LOG_FILE"
fi

run_license() {
        log "Start Running [license] container"
        CMD="$REZ_DOCKER run -d \
                -p 6200:6200 \
                -p 11668:11668 \
                -p 9011:9010 \
                -p 8081:8080 \
                -p 1074:1074 \
                -p 1075:1075 \
                -p 7096:7096 \
                -p 5054:5054 \
                -p 57625:57625 \
                -p 5053:5053 \
                -v $LIC_DIR/yeti_pixar:$DOCKER_DIR \
                -h license --mac-address D0:67:E5:F1:CD:65 \
                --name license --net license --ip 172.19.0.3 \
                $DOCKER_SERVER/yeti_pixar $CMD_LOG"
        log "CMD=[$CMD]"
        eval $CMD
}

run_foundry() {
        log "Start Running [foundry] container"
        CMD="$REZ_DOCKER run -d \
                -p 8051:8050 \
                -p 50053:50053 \
                -p 3053:3053 \
                -p 3054:3054 \
                -p 45412:45412 \
                -p 9053:9053 \
                -p 9054:9054 \
                -p 9010:9010 \
                -p 47200:47200 \
                -p 2080:2080 \
                -p 6058:5058 \
                -p 36918:36918 \
                -p 6057:5057 \
                -p 4054:5054 \
                -p 36917:36917 \
                -p 6053:2053 \
                -p 4101:4101 \
                -p 36914:36914 \
                -p 6102:4102 \
                -p 7053:7053 \
                -p 36915:36915 \
                -p 7054:7054 \
                -p 9412:9412 \
                -p 5066:5066 \
                -p 5067:5067 \
                -p 2102:2102 \
                -v $LIC_DIR/foundry/opt:$DOCKER_DIR \
                -v $LIC_DIR/foundry/etc/opt:/etc/opt \
                -v $LIC_DIR/foundry/opt/rsmb/revision:/usr/local/revision \
                --mac-address 0C:C4:7A:7D:C3:36 \
                --hostname localhost \
                --name foundry \
                $DOCKER_SERVER/foundry $CMD_LOG"
        log "CMD=[$CMD]"
        eval $CMD
}

run_clarisse() {
        log "Start Running [clarisse] container"
        CMD="$REZ_DOCKER run -d \
                -p 40500:40500 \
                -v $LIC_DIR/clarisse:$DOCKER_DIR/clarisse \
                --mac-address FE:45:7E:C4:7B:45 \
                --hostname License \
                --name clarisse \
                $DOCKER_SERVER/clarisse $CMD_LOG"
        log "CMD=[$CMD]"
        eval $CMD
}

run_houdini() {
        log "Start Running [houdini] container"
        CMD="$REZ_DOCKER run -d \
                -p 2714:1714 \
                -p 1715:1715 \
                -v $LIC_DIR/houdini:$DOCKER_DIR/houdini \
                --mac-address 0C:C4:7A:7D:C3:36 \
                --hostname license \
                --net license \
                --ip 172.19.0.2 \
                --name houdini \
                $DOCKER_SERVER/houdini $CMD_LOG"
        log "CMD=[$CMD]"
        eval $CMD
}


run_lic() {
	ARG=$1
	if [ -z "$ARG" ]; then
        	log "No specific process specified. Running all containers."
	        ARG="all"
	fi
	log "Arguments is [$ARG]"

	# Docker 데몬을 백그라운드에서 실행
	if ! $REZ_DOCKER info > /dev/null 2>&1; then
	        log "Starting Docker deamon."
	        CMD="$REZ_DOCKERD --insecure-registry $DOCKER_SERVER $CMD_LOG &"
	        log "CMD=[$CMD]"
	        eval $CMD

	        while ! $REZ_DOCKER info > /dev/null 2>&1; do
	                echo "Waiting for Docker daemon to start..."
	                sleep 1
	        done
	else	
        	log "Docker daemon is already running"
	fi

	# Docker 이미지를 풀링
	for LICENSE in "${LICENSE_ARRAY[@]}"; do
		if [[ $ARG == "license" ]]; then
			log "Start Docker Image Pulling. Process=[yeti_pixar]"
			CMD="$REZ_DOCKER pull $DOCKER_SERVER/yeti_pixar $CMD_LOG"
			log "CMD=[$CMD]"
			eval $CMD
			break
		fi
		if [[ $ARG == "all" || $ARG == $LICENSE ]]; then
			log "Start Docker Image Pulling. Process=[$LICENSE]"
			CMD="$REZ_DOCKER pull $DOCKER_SERVER/$LICENSE $CMD_LOG"
			log "CMD=[$CMD]"
			eval $CMD
		fi
	done	

	# 기존 컨테이너 중지 및 제거
	for LICENSE in "${CONTAINER_NAMES[@]}"; do
		if [[ $ARG == "all" || $ARG == $LICENSE ]]; then
			if $REZ_DOCKER ps -a --format '{{.Names}}' | grep -Eq "^${LICENSE}\$"; then
				log "Start Docker Process Stopping & Remove. Process=[$LICENSE]"
				CMD="$REZ_DOCKER stop $LICENSE $CMD_LOG;$REZ_DOCKER rm $LICENSE $CMD_LOG"
				log "CMD=[$CMD]"
				eval $CMD
			fi
		fi
	done

	if ! $REZ_DOCKER network inspect license > /dev/null 2>&1; then
		log "Docker network 'license' not found."
		log "Start Docker Network Removing."
		CMD="$REZ_DOCKER network rm license $CMD_LOG"
		log "CMD=[$CMD]"
		eval $CMD
	else
		log "Docker network 'license' already exists. Skipping creation."
	fi

	case $ARG in
		"all")
			run_license
			run_foundry
			run_clarisse
			run_houdini
			;;
		"license")
			run_license
			;;
		"foundry")
			run_foundry
			;;
		"clarisse")
			run_clarisse
			;;
		"houdini")
			run_houdini
			;;
		*)
			log "Invalid argument. Please specify one of: all, license, foundry, clarisse, houdini."
		exit 1
		;;
	esac

	# 실행 중인 컨테이너 확인 및 상태 출력
	for LICENSE in "${CONTAINER_NAMES[@]}"; do
		if $REZ_DOCKER ps --format '{{.Names}}' | grep -Eq "^${LICENSE}\$"; then
			log "$LICENSE OK"
		fi
	done
}

check_container() {
	for container_name in "${CONTAINERS[@]}"; do
		CHK_CMD="rez-env docker -- docker ps --filter name=$container_name |grep $container_name|wc -l"
		#log "CHK_CMD=[$CHK_CMD]"
		CHK_RESULT=`eval "$CHK_CMD"`
		#log "CHK_RESULT = $CHK_RESULT"		
		if [ $CHK_RESULT -eq 0 ]; then
			log "$container_name is not running. Attempting to restart"
			run_lic "$container_name"
		else
			log "$container_name is running"
		fi
	done
	return 0
}

# Docker 데몬을 백그라운드에서 실행
if ! $REZ_DOCKER info > /dev/null 2>&1; then
	log "Starting Docker deamon."
	CMD="$REZ_DOCKERD --insecure-registry $DOCKER_SERVER $CMD_LOG &"
	log "CMD=[$CMD]"
	eval $CMD

	while ! $REZ_DOCKER info > /dev/null 2>&1; do
		echo "Waiting for Docker daemon to start..."
		sleep 1
	done
else
	log "Docker daemon is already running"
fi


check_container
