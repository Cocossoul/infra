#!/bin/sh

set -e

docker build --tag cocopaps/ru19h:latest .

docker push cocopaps/ru19h:latest
