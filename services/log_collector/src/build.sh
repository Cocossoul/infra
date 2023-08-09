#!/bin/sh

set -e

docker build --tag cocopaps/log_collector:latest .

docker push cocopaps/log_collector:latest
