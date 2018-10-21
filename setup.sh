#!/bin/bash
WHITE=$(tput setaf 7)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)
source .env
echo "${WHITE}[Docker Container Creation Started][${COMPOSE_PROJECT_NAME}]${NORMAL}"
DATAVOLUME="${HOME}/${NODEOS_VOLUME_NAME}"
# Create data volume if it doesn't exist
if [ ! -d "${DATAVOLUME}" ]; then
        mkdir $DATAVOLUME
        echo "${GREEN}+ Created ${DATAVOLUME}${NORMAL}"
fi
# If genesis.json is missing, don't allow this to run (adding it later breaks the chain)
if [ ! -e "${DATAVOLUME}/genesis.json" ]; then
        printf "${RED}- Place your genesis.json file into ${DATAVOLUME} and run this again.${NORMAL}\n\n"
        exit
fi
if [ -z "$(docker volume ls | grep ${NODEOS_VOLUME_NAME})" ]; then
    docker volume create --name=$NODEOS_VOLUME_NAME 1> /dev/null
    printf "${GREEN}+ Created ${NODEOS_VOLUME_NAME}${NORMAL}\n"
fi
if [ -z "$(docker volume ls | grep ${KEOSD_VOLUME_NAME})" ]; then
    docker volume create --name=$KEOSD_VOLUME_NAME 1> /dev/null
    printf "${GREEN}+ Created ${KEOSD_VOLUME_NAME}${NORMAL}\n"
fi
# KEOSD can share nodeos' data volume
if [ ! -h "${HOME}/${KEOSD_VOLUME_NAME}" ]; then ln -s $DATAVOLUME $HOME/$KEOSD_VOLUME_NAME; fi

docker-compose up -d
echo "${WHITE}[Docker Container Creation Complete][${COMPOSE_PROJECT_NAME}]"
