#!/bin/sh

set -e

docker build --tag cocopaps/tbeteouquoi:latest .

docker push cocopaps/tbeteouquoi:latest
