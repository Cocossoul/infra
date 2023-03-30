#!/bin/sh

set -e

IMAGE_NAME="cocopaps/reverse-proxy-internal-bridge"

docker build --tag "${IMAGE_NAME}" .

docker push "${IMAGE_NAME}"
