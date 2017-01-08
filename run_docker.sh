#!/bin/bash

# Select PORT
PORT=8080
while netstat -atwn | grep "^.*:${PORT}.*:\*\s*LISTEN\s*$"
do
PORT=$(( ${PORT} + 1 ))
done

# TODO: Resolve path
RESOLVE_PATH=$(cd $1; pwd)
BASE=$(basename $RESOLVE_PATH)

echo "Publishing on $PORT"

echo "docker run -e DOCKER_PORT=$PORT -e WATCH_POLL=1 -v $RESOLVE_PATH:/volume -p $PORT:$PORT -it $BASE/dev:latest"
docker run -e DOCKER_PORT=$PORT -v $RESOLVE_PATH:/volume -p $PORT:$PORT -it $BASE/dev:latest
