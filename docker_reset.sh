#!/bin/bash
source .env
printf "This will delete ALL docker containers, images, and volumes. It will NOT delete your local data volumes! Are you sure you want to proceed?\n(Enter an integer)\n"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) docker stop $(docker ps -a | grep "${COMPOSE_PROJECT_NAME}_*" | awk '{print $1}'); \
              docker rm $(docker ps -a | grep "${COMPOSE_PROJECT_NAME}_*" | awk '{print $1}'); \
              docker images | grep "${IMAGE_NAME}" | awk '{print $3}' | xargs docker rmi; \
              docker volume ls | grep -E "${NODEOS_VOLUME_NAME}|${KEOSD_VOLUME_NAME}" | awk '{print $2}' | xargs docker volume rm; \
              exit;;
        No ) exit;;
    esac
done
