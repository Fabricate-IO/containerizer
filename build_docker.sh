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

echo "Creating docker_context directory:"

cd $1
mkdir docker_context

cp ./install.sh ./docker_context/install.sh
cp ./run.sh ./docker_context/run.sh
RUN chmod a+x ./docker_context/*.sh

printf "%s\n" "FROM ubuntu:16.04" "MAINTAINER $NAME <$EMAIL>" "RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections" "RUN apt-get update && apt-get install -y dos2unix" "ADD ./install.sh /install.sh" "ADD ./run.sh /run.sh" "RUN dos2unix /install.sh /run.sh" "RUN /install.sh" "ENTRYPOINT /run.sh" "RUN echo 'Docker container setup complete'" > ./docker_context/Dockerfile

cd ./docker_context

echo "=============="
cat ./Dockerfile
echo "=============="

echo "Building Dockerfile (as image $IMAGE):"
docker build --tag="$IMAGE" .

echo "To run, use run.sh or run.bat"
