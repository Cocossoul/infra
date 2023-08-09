#!/bin/sh

curl -H "Accept: application/vnd.github+json" \
    -H "Authorization: token ${ deploy_workflow_token }" \
    --request POST \
    --data '{"event_type": "nightly_maintenance_deploy"}' \
    https://api.github.com/repos/Cocossoul/infra/dispatches
