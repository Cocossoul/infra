#!/bin/sh

set -e

cd machines
terraform init
cd ..

docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}

cd services
terraform init
cd ..
