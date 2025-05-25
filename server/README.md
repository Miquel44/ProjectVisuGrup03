# Palestine Deaths Data Visualiation Server

This repository contains all files for a server to visualize information of  the deaths in Palestine.

The server works deploying a Docker container. And launching the server in it, using the port `8080`.

The process of public IP, DNS set up and machine deployment is left to the end user, is not provided here.

## Installation Guide

To deploy the server, execute the following command in a bash console, in the directory containing this repository:

```bash
bash deploy_container.sh
```

If the machine does not have Docker, you can install it executing the following command in a bash console, in the directory containing this repository:

```bash
bash install_docker.sh
```

To get the repository into the machine, simply execute the following command in a bash console:

```bash
git clone https://github.com/Miquel44/ProjectVisuGrup03
```

Alternatively, create a `server.sh` file, paste the following code:

```bash
#!/bin/bash

echo "Preparing environment."
if [ -d "ProjectVisuGrup03" ];
then
    echo "Directory already exists. Removing."
    rm -d -f -r ProjectVisuGrup03
    echo "Directory removed."
fi

if command -v git > /dev/null 2>&1; then
    echo "Git is already installed."
else
    echo "Git is not installed. Installing git."
    sudo apt-get update -y
    sudo apt-get install -y git
    echo "Git has been installed."
fi

echo "Cloning repository with the server infrastructure."
git clone https://github.com/Miquel44/ProjectVisuGrup03
echo "Repository cloned."

echo "Setting working directory."
cd ProjectVisuGrup03/server
echo "Working directory set."

echo "Execute install docker."
bash install_docker.sh
echo "Environment prepared."

echo "Execute deploy."
bash deploy_container.sh
```

and execute the following command in a bash console:

```bash
bash server.sh
```

All the steps needed will be performed automatically, ending with the server deployed.

## Contents

### `install_docker.sh`

Bash shell script that detects if Docker is installed in the machine, if it is not, installs it using `apt-get`.

### `deploy_container-sh`

Bash shell script that deploys the container with the server. 

In its process, it runs `build_container.sh` and `run_container.sh`.

### `build_container.sh`

Bash shell script that builds a new docker image with the name `server` and the tag `latest`, from the Dockerfile.

### `Dockerfile`

The container is based upon a basic `Linux` OS with `Python 3.12` installed, called `python:3.12-alpine`.

We set up the `HOME` directory of the container as `/root`, create a directory `/server` and set this one as the working directory from now on.

We copy the file `requirements.txt` into this directory and run `pip install -r requirements.txt` to install all the dependencies of Python that are used by our server.

Furthermore, we proceed to copy all the necessary files into the `/server` folder, this includes: `server.py` (Python script with the HTTP server), `environment.py` (Python script to initiate and check the environment) and `utils.py` (Python script with general purpose functions used by the other files oftenly).

Following up, we make another directory, `/server/public`, where we copy the files all the server files, HTML, CSS and photos.

Lastly, we give permission to the file `server.py` to be executed, expose the port `8080` and create the entry point to the container that will be executing with Python 3, the file `server.py`.

### `requirements.txt`

Text file with all the python dependencies of our server so `pip` can install them in the container.

### `server.py`

Python script with the HTTP server. It binds to `0.0.0.0` and the port `8080`. Logs into `stdout` and a logging file all information of the server, like the deployment of it, the request received, when and from what IP, the errors, etc. The logging level can be changed, by default is `INFO`.

The server has:

- Any other page will return a `404` HTTP code.

### `environment.py`

Python script with the loading of all Python modules used, setting up environtment like time of start, path to the directories with all files, checks the versions are all the proper one and intilializes de logging file.

### `utils.py`

Python script with general pupose functions like:

- `print_message`: That prints a message to `stdout` and logs it into the logging file with `INFO` level.
- `print_error`: That prints an error to`stdout` and logs it into the logging file with`ERROR` level. Optionally can print and log the full `traceback`.
- `formated_traceback_stack`: Formats the traceback to be print and logged.

### `run_container.sh`

Bash shell script that runs the container with the server, binds the container `8080` port to the host's `8080` port, the container is named `server`. 

In its process, it runs `delete_container.sh` to delete any container created before with the same name.

### `delete_container.sh`

Bash shell script that searches if there is any container named `server` that has been stopped (status `exited`), and if there is, remove it.

In its process, it runs `stop_container.sh` to stop any container that is running with the same name.

### `stop_container.sh`

Bash shell script that searches if there is any container named `server` that is running (status `running`), and if there is, stop it.th
