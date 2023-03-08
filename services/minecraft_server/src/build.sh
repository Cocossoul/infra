#!/bin/sh

set -e

mkdir -p config
cd config

paper_version='1.19.3'

# Fetch Paper Minecraft server from official website
LATEST_BUILD=$(curl -X GET "https://papermc.io/api/v2/projects/paper/versions/${paper_version}" -H  "accept: application/json" | jq '.builds[-1]')

curl -o paperclip.jar -X GET "https://papermc.io/api/v2/projects/paper/versions/${paper_version}/builds/${LATEST_BUILD}/downloads/paper-${paper_version}-${LATEST_BUILD}.jar" -H  "accept: application/java-archive" -JO

cd ..

docker build --tag cocopaps/minecraft_server:latest .

docker push cocopaps/minecraft_server:latest
