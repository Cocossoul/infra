#!/bin/sh

set -e

cd services
terraform destroy
cd ..
cd machines
terraform destroy
cd ..
