# CONTAINERIZER

Scripts to automatically create and run a containerized version of your project.

## Requirements

These scripts require your project to have an `install.sh` script and a `run.sh` script located
in the root of your project directory. 

- The `install.sh` script is run when docker builds the container,
  and contains all the dependencies and setup work needed to run your project.
- The `run.sh` script runs your project and sets up the dev environment. We recommend making this start a tmux console.

## Installation

- Install [Docker](https://www.docker.com/) for your specific OS
- Clone this repository: `git clone https://github.com/Fabricate-IO/containerizer`
- Add this directory to your path, or reference the scripts directly when you want to run them.

If you're using windows, make sure you have MinGW, Cygwin, or Git shell available to run the build command.

## Usage

To build a container:

```shell
./build_docker.sh github-repository-folder
```

To run a container:

```shell
# Windows
run_docker.bat github-repository-folder

# OSX/Linux
./run_docker.sh github-repository-folder
```

## Notes

- Docker for windows doesn't publish inotify events made by the host, which causes
  file watches (e.g. with webpack) to not work if you're using sublime on the host
  to edit files. Solution is to switch to polling mode 
- A port is dynamically exposed (the first free port, starting at 8080 and working upwards).
  You'll need to point any external references (e.g. Google API redirect URIs) to the first
  few ports.