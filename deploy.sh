#!/bin/sh

set -e

cd machines
terraform init
terraform apply $@
cd ..
cd services
terraform init
terraform apply $@
cd ..
