#!/bin/sh

set -e

cd machines
terraform apply
cd ..
cd services
terraform apply
cd ..
