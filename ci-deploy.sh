#!/bin/sh

set -e
set -v

# Configure SSH
echo "Configure SSH"
mkdir -p ~/.ssh
SSH_KEY_PATH=~/.ssh/ssh_key
printf "%s" "$SSH_CI_PRIVATEKEY_BASE64" | base64 -d > "$SSH_KEY_PATH"
chmod 0400 "$SSH_KEY_PATH"
echo "IdentityFile $SSH_KEY_PATH" >> ~/.ssh/config

# Configure Passbolt CLI
echo "Configure Passbolt CLI"
printf "%s" "$PASSBOLT_CI_ACS_BASE64" | base64 -d > passbolt_ci_user.acs
go-passbolt-cli configure --serverAddress https://passbolt.cocopaps.com --userPassword "$PASSBOLT_CI_PASSWORD" --userPrivateKeyFile 'passbolt_ci_user.acs'

# Fetch secrets from Passbolt
echo "Fetch secrets from Passbolt"
source fetch_secrets.sh

# Docker login
echo "Login to Dockerhub"
docker login -u cocopaps -p "$DOCKER_PASSWORD"

echo "Start deployment"
./deploy.sh -auto-approve
