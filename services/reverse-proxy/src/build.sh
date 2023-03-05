#!/bin/sh

set -e

IMAGE_NAME="cocopaps/reverse-proxy${MACHINE_NAME}"

docker build --tag "${IMAGE_NAME}" .

docker push "${IMAGE_NAME}"
