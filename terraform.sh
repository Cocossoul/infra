#!/bin/sh

set -e

cd machines
terraform init
terraform $@
cd ..
cd services
terraform init
terraform $@
cd ..
