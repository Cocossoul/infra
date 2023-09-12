#!/bin/sh

set -e
set -o pipefail
set -v

# Configure SSH
mkdir -p "/root/.ssh"
SSH_KEY_PATH="/root/.ssh/ssh_key"
printf "%s" "$SSH_CI_PRIVATEKEY_BASE64" | base64 -d > "$SSH_KEY_PATH"
chmod 0400 "$SSH_KEY_PATH"
echo "IdentityFile $SSH_KEY_PATH" >> "/root/.ssh/config"

# Configure Passbolt CLI
printf "%s" "$PASSBOLT_CI_ACS_BASE64" | base64 -d > passbolt_ci_user.acs
go-passbolt-cli configure --serverAddress https://passbolt.cocopaps.com --userPassword "$PASSBOLT_CI_PASSWORD" --userPrivateKeyFile 'passbolt_ci_user.acs'
rm passbolt_ci_user.acs

# Fetch secrets from Passbolt
source fetch_secrets.sh

# Fetch Kube config from machines
scp "coco@${TF_VAR_vultr_dyndns_address}:/home/coco/.kube/config" services/vultr_k3s.config
sed -E "s/server: https:\/\/[0-9.]+:[0-9]+/server: https:\/\/${TF_VAR_vultr_dyndns_address}:6443/g" -i.bak services/vultr_k3s.config
rm services/vultr_k3s.config.bak
#scp -P 1844 "coco@${TF_VAR_homeserver_dyndns_address}:/home/coco/.kube/config" services/homeserver_k3s.config
#sed -E "s/server: https:\/\/[0-9.]+:[0-9]+/server: https:\/\/${TF_VAR_homeserver_dyndns_address}:1843/g" -i.bak services/homeserver_k3s.config
rm services/homeserver_k3s.config.bak

# Docker login
docker login -u cocopaps -p "$DOCKER_PASSWORD"

# Start deployment
./terraform.sh $@
