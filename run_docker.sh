#!/bin/bash

if [ "$2" != "" ]; then
	PORT=$2

	if [ "$3" != "" ]; then
		PORT2=$3
	else
		PORT2=0
	fi
else 
	# Select PORTs
	PORT=8080
	while netstat -atwn | grep "^.*:${PORT}.*:\*\s*LISTEN\s*$"
	do
	PORT=$(( ${PORT} + 1 ))
	done

	PORT2=$(( ${PORT} + 1 ))
	while netstat -atwn | grep "^.*:${PORT2}.*:\*\s*LISTEN\s*$"
	do
	PORT2=$(( ${PORT2} + 1 ))
	done
fi


# TODO: Resolve path
RESOLVE_PATH=$(cd $1; pwd)
BASE=$(basename $RESOLVE_PATH)

echo "Publishing on $PORT"

echo "docker run --restart=always -e DOCKER_PORT=$PORT -e DOCKER_PORT2=$PORT2 -e WATCH_POLL=1 -v $RESOLVE_PATH:/volume -p $PORT:$PORT -p $PORT2:$PORT2 -it $BASE/dev:latest"
docker run -e DOCKER_PORT=$PORT -e DOCKER_PORT2=$PORT2 -e WATCH_POLL=1 -v $RESOLVE_PATH:/volume -p $PORT:$PORT -p $PORT2:$PORT2 -it $BASE/dev:latest
