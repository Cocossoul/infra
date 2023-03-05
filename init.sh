#!/bin/sh

set -e

cd machines
terraform init
cd ..

cd services
terraform init
cd ..
