#!/bin/bash

# When pointed to a repository, this script creates a Dockerfile container that:
# - automatically sets the maintainer from git config
# - automatically generates the image label based on the repository folder ("repofolder/dev:latest")
# - runs ./install.sh from the repository base
# - uses ./run.sh from the repostiory base as an entry point

NAME=`git config user.name`
EMAIL=`git config user.email`
SRC_DIRNAME=`cd $1; pwd | xargs basename`
IMAGE=$SRC_DIRNAME/dev:latest

# Check that install & run scripts exist
if ! [[ -f "$SRC_DIRNAME/install.sh" ]]; then
  echo "File $SRC_DIRNAME/install.sh does not exist - aborting"
  exit 1
fi
if ! [[ -f "$SRC_DIRNAME/run.sh" ]]; then
  echo "File $SRC_DIRNAME/run.sh does not exist - aborting"
  exit 1
fi

# Remove any existing docker_context
if [ -d "$SRC_DIRNAME/docker_context" ]; then
  echo "Removing existing docker_context directory and files"
  rm -Rf "$SRC_DIRNAME/docker_context";
fi

echo "Creating docker_context directory:"

cd $1
mkdir docker_context

cp ./install.sh ./docker_context/install.sh
cp ./run.sh ./docker_context/run.sh

chmod a+x ./docker_context/install.sh
chmod a+x ./docker_context/run.sh

printf "%s\n" "FROM ubuntu:16.04" "MAINTAINER $NAME <$EMAIL>" "RUN apt-get update && apt-get install -y dos2unix" "ADD ./install.sh /install.sh" "ADD ./run.sh /run.sh" "RUN dos2unix /install.sh /run.sh" "RUN /install.sh" "ENTRYPOINT /run.sh" > ./docker_context/Dockerfile

cd ./docker_context

echo "=============="
cat ./Dockerfile
echo "=============="

echo "Building Dockerfile (as image $IMAGE):"
docker build --tag="$IMAGE" .

echo "To run, use run.sh or run.bat"
