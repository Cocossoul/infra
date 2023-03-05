#!/bin/sh

set -e

cd machines
terraform plan
cd ..
cd services
terraform plan
cd ..
