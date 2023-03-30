#!/bin/sh

set -e

IMAGE_NAME="cocopaps/reverse-proxy-insecure"

docker build --tag "${IMAGE_NAME}" .

docker push "${IMAGE_NAME}"
