# EOSIO Docker Setup

This guide explains how to get up and running with Docker.
Docker Hub image available from [docker hub](https://hub.docker.com/r/eosio/eos/).

## Install Dependencies

- [Docker](https://docs.docker.com) Docker 17.05 or higher is required
- [docker-compose](https://docs.docker.com/compose/) version >= 1.10.0

## Requirements

- At least 7GB RAM (Docker -> Preferences -> Advanced -> Memory -> 7GB or above).
- Ability to edit the .env file and execute a bash script.

## Building The EOS Containers:

If you look at the .env file, you'll see:

```bash
$ cat ~/eosio-docker/.env
# GITHUB
GITHUB_BRANCH=master
# You can find this on the github url: https://github.com/EOSIO
GITHUB_ORG=EOSIO
# COMPOSE / BUILD
DOCKERHUB_USERNAME=eosio
IMAGE_NAME=eos
# List of available tags: https://hub.docker.com/r/eosio/eos/tags/
IMAGE_TAG=latest
# Token name
BUILD_SYMBOL=SYS
NODEOS_VOLUME_NAME=nodeos-data-volume
NODEOS_PORT=9876
NODEOS_API_PORT=8888
KEOSD_VOLUME_NAME=keosd-data-volume
KEOSD_API_PORT=8900
COMPOSE_PROJECT_NAME=main
```

These are variables used throughout the docker scripts. If you modify these values (like the BUILD_SYMBOL=SYS to BUILD_SYMBOL=EOS), running `./setup.sh` will set your containers up with that as the "CORE symbol name".

To setup and start the containers, you can run:

```bash
$ cd ~/eosio-docker
$ ./setup.sh
```

After running the setup script, two containers named `main-nodeos` and `main-keosd` (if you have `COMPOSE_PROJECT_NAME=main`) will be started in the background.
-- The nodeos container/service will expose ports 8888 and 9876.
-- The keosd container/service does not expose any port to the host from your local machine. It does however allow you to alias and run cleos from the local machine into the keosd container and connect to the linked nodeos container: `alias cleos='docker exec main-keosd /opt/eosio/bin/cleos -u http://main-nodeos:8888 --wallet-url http://127.0.0.1:8900'


### Verifying The Installation

```bash
curl http://127.0.0.1:8888/v1/chain/get_info
```

Alternatively, after you've created the bash alias explained above, you can run:

```bash
cleos get info
cleos get account eosio
```

## Develop/Build Custom Contracts:

Due to the fact that the eosio/eos image does not contain the required dependencies for contract development (this is by design, to keep the image size small), you will need to utilize the eosio/eos-dev image. This image contains both the required binaries and dependencies to build contracts using eosiocpp.

To accomplish this, you need to modify the .env file, changing `IMAGE_NAME=eos` to `IMAGE_NAME=eos-dev`.

## Change Default Configuration

You can modify the docker-compose.yml file to change the default configurations. For example, add a new local file: `config2.ini`, and ensure it's added to the eosio/data-dir in the container. You'll need to use the docker-reset script to remove your previous containers and run the `setup.sh` again.

```yaml
services:
  nodeos:
. . .
    expose:
      - "8888"
    volumes:
      - ~/$NODEOS_VOLUME_NAME:/opt/eosio/bin/data-dir
      - /Volumes/OS Sierra/Users/macuser/config2.ini:/opt/eosio/data-dir/config.ini
```

Now, when you modify the config2.ini locally, the changes will automatically end up in the container. This requires a rebuild of the containers:

```bash
$ cd ~/eosio-docker
$ docker-compose down
$ docker-compose up -d
```

Remember that docker-compose requires a docker-compose.yml in the same directory. You can use `docker-compose -f docker-compose-new.yml` if you want to specify a different file.

## Docker Environment Reset / Cleanup

By default, all data is persisted in a docker volume under ~/. There is a script available for an entire reset of your docker environment: `./docker-reset.sh`.


## Miscellaneous / Notes
- Take regular backups of your local volume directories (~/nodeos-data-volume, etc)
- If using a public blockchain, you need to wait for the entire blockchain to catch up/sync to the latest blocks before you can perform transactions. Alternatively, you can run keosd on its own and set the cleos `-u` to a public api of an up to date/synced producer.
