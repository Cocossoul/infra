#!/bin/sh

set -e

docker build --tag cocopaps/portfolio:latest .

docker push cocopaps/portfolio:latest
