#!/bin/sh

set -e

docker build --tag cocopaps/portfolio:test .
docker run -t -p 8080:8080 cocopaps/portfolio:test
