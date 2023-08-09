#!/bin/sh

set -e

docker build --tag cocopaps/nightly_maintenance:latest .

docker push cocopaps/nightly_maintenance:latest
