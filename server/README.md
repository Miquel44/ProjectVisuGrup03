# Palestine Deaths Data Visualiation Server

This repository contains all files for a server to visualize information of  the deaths in Palestine.

The server works deploying a Docker container. And launching the server in it, using the port `8080`.

The process of public IP, DNS set up and machine deployment is left to the end user. We wil, however, explain how we did it to have it woring at [deathinpalestine.me](https://www.deathinpalestine.me).

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

## Deployment in Web

We start deploying a [DigitalOcean](https://www.digitalocean.com/) [Ubuntu](https://ubuntu.com/download/server) [droplet](https://cloud.digitalocean.com/droplets/), assigning to it a [reserved IP](https://cloud.digitalocean.com/networking/reserved_ips), in our case `129.212.142.138`. We proceed creating a [firewall](https://cloud.digitalocean.com/networking/reserved_ips) and assigning it to the dropled. The firewall has the following rules:

###### Inbound Rules

| Type  | Protocol | Port Range | Sources               |
| ----- | -------- | ---------- | --------------------- |
| SSH   | TCP      | 22         | `All IPv4` `All IPv6` |
| HTTP  | TCP      | 80         | `All IPv4` `All IPv6` |
| HTTPS | TCP      | 443        | `All IPv4` `All IPv6` |

###### Outbound Rules

| Type | Protocol | Port Range | Sources |
| ---- | -------- | ---------- | ------- |

We set up the server inside the dropled with the `server.sh` code.

We proceed to register the domain [deathinpalestine.me](deathinpalestine.me) using [NameCheap](https://ap.www.namecheap.com/domains). In [DeepOcean's domain](https://cloud.digitalocean.com/networking/domains) settings we add the registered domain and set up the Following DNS records:

| Type  | Hostname                | Value                |
| ----- | ----------------------- | -------------------- |
| A     | deathinpalestine.me     | 129.212.142.138      |
| CNAME | www.deathinpalestine.me | deathinpalestine.me  |
| NS    | deathinpalestine.me     | ns1.digitalocean.com |
| NS    | deathinpalestine.me     | ns2.digitalocean.com |
| NS    | deathinpalestine.me     | ns3.digitalocean.com |

And add them to [NameSpace NameServer](https://ap.www.namecheap.com/Domains/DomainControlPanel/). And let the changes propagate.

Meanwhile we create a file `interface_layer.sh` to set up [nginx](https://nginx.org/) and [certbot](https://certbot.eff.org/):

```bash
#!/bin/bash

if command -v nginx > /dev/null 2>&1
then
    echo "Nginx is already installed."
else
    echo "Nginx is not installed. Installling nginx."
    sudo apt-get update -y
    sudo apt install -y nginx
    echo "Nginx has been installed."
fi

if command -v certbot > /dev/null 2>&1
then
    echo "Cerbot is already installed."
else
    echo "Cerbot is not installed. Installling cerbot."
    sudo apt-get update -y
    sudo apt install -y certbot python3-certbot-nginx
    echo "Cerbot has been installed."
fi

echo "Setting working directory."
cd ProjectVisuGrup03/server
echo "Working directory set."

echo "Generating SSL certificates with cerbot."
sudo certbot --nginx -d deathinpalestine.me -d www.deathinpalestine.me
echo "SSL certificates generated."

echo "Setting nginx default configuration file."
sudo cp nginx_default /etc/nginx/sites-available/default
echo "Nginx default configuration file has been set."

echo "Checking nginx default configuration file."
if sudo nginx -t 2>/dev/null; then
    echo "Nginx default configuration file is valid."
else
    echo "Nginx default configuration file has errors."
fi

echo "Reload nginx with new default configuration file."
sudo systemctl reload nginx
echo "Nginx has been reloaded."

echo "Setting cerbot auto-renewal."
sudo systemctl list-timers | grep certbot
# Manually:
# sudo certbot renew --dry-run
sudo "Cerbot auto-renewal has been set."
```

and execute the following command in a bash console:

```bash
bash interface_layer.sh
```

Once done, we go to [CloudFare](https://dash.cloudflare.com/) and we follow the instructions changing the Name Servers in [DigitalOcean](https://cloud.digitalocean.com/networking/domains) and [NameSpace](https://ap.www.namecheap.com/Domains/DomainControlPanel/) to the ones provided by CloudFare (CloudFare should have detected the previously set up Name Servers if it hasn't yet, we await until it does). In our case we have assigned teh following NameServers from CloudFare:

| Type | Hostname            | Value                   |
| ---- | ------------------- | ----------------------- |
| NS   | deathinpalestine.me | jean.ns.cloudflare.com  |
| NS   | deathinpalestine.me | terin.ns.cloudflare.com |

It takes some time to update but once they do we go to CloudFare's DNS Dettings and activate DNSSEC. We go to NameSpace DNSSEC settings, activate it too and add the information CloudFare has given us.

Next, in CloudFare Security Security rules, we add a security rule to block all request targeted to URI paths that are not from out server:

```text
(not
  (
    http.request.uri.path eq "/" or
    http.request.uri.path eq "/graphs/infrastructure_loss" or
    http.request.uri.path eq "/css/global_styles.css" or
    http.request.uri.path eq "/static/android-chrome-512x512.png" or
    http.request.uri.path eq "/graphs/types_of_death/libs/typedarray-0.1/typedarray.min.js" or
    http.request.uri.path eq "/graphs/bloody_toll" or
    http.request.uri.path eq "/favicon.ico" or
    http.request.uri.path eq "/graphs/types_of_death/libs/jquery-3.5.1/jquery.min.js" or
    http.request.uri.path eq "/graphs/types_of_death/libs/plotly-binding-4.10.4/plotly.js" or
    http.request.uri.path eq "/static/favicon-16x16.png" or
    http.request.uri.path eq "/static/site.webmanifest" or
    http.request.uri.path eq "/main/local_styles.css" or
    http.request.uri.path eq "/static/apple-touch-icon.png" or
    http.request.uri.path eq "/graphs/types_of_death/libs/crosstalk-1.2.1/js/crosstalk.min.js" or
    http.request.uri.path eq "/graphs/body_count/body_count_files/jquery-3.5.1/jquery.min.js" or
    http.request.uri.path eq "/graphs/body_count/demographics_cum.json" or
    http.request.uri.path eq "/graphs/body_count/body_count_files/crosstalk-1.2.1/js/crosstalk.min.js" or
    http.request.uri.path eq "/graphs/body_count_view" or
    http.request.uri.path eq "/graphs/body_count/body_count_files/plotly-binding-4.10.4/plotly.js" or
    http.request.uri.path eq "/graphs/types_of_death/libs/htmlwidgets-1.6.4/htmlwidgets.js" or
    http.request.uri.path eq "/graphs/body_count/body_count_files/plotly-main-2.11.1/plotly-latest.min.js" or
    http.request.uri.path eq "/images/background_photo.jpeg" or
    http.request.uri.path eq "/graphs/body_count/body_count_files/htmlwidgets-1.6.4/htmlwidgets.js" or
    http.request.uri.path eq "/graphs/body_count/body_count_files/typedarray-0.1/typedarray.min.js" or
    http.request.uri.path eq "/graphs/types_of_death" or
    http.request.uri.path eq "/static/android-chrome-192x192.png" or
    http.request.uri.path eq "/static/favicon-32x32.png" or
    http.request.uri.path eq "/graphs/body_count" or
    http.request.uri.path eq "/graphs/types_of_death/libs/plotly-main-2.11.1/plotly-latest.min.js"
  )
)
```

And finally we activate all CloudFare Security Settings for DDoS attacks and Bot traffic.

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

Bash shell script that searches if there is any container named `server` that is running (status `running`), and if there is, stop it.

### `nginx_default`

File with the deafault configuration for nginx service.
