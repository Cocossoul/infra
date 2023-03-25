#!/bin/sh

set -e

IMAGE_NAME="cocopaps/vault"

docker build --tag "${IMAGE_NAME}" .

docker push "${IMAGE_NAME}"
