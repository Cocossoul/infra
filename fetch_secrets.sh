RESOURCE_LIST="$(go-passbolt-cli list resource)"

fetch_secret() {
    SECRET_TO_FETCH="$1"
    # Get passbolt resource ID from passbolt resource name and username
    ID="$(echo $RESOURCE_LIST\
    | grep "${SECRET_TO_FETCH}" | head -n1 | awk '{print $1}')"

    # Get passbolt resource password from its ID
    PASSWORD=$(go-passbolt-cli get resource --id "${ID}" | grep Password | sed 's/^Password: //g')
    echo ${PASSWORD}
}

export TF_VAR_cloudflare_token="$(fetch_secret cloudflare_token)"
export VULTR_API_KEY="$(fetch_secret vultr_api_key)"
export TF_VAR_dyndns_token="$(fetch_secret dyndns_token)"
export TF_VAR_owncloud_admin_username="$(fetch_secret owncloud_admin_username)"
export TF_VAR_owncloud_admin_password="$(fetch_secret owncloud_admin_password)"
export TF_VAR_owncloud_db_password="$(fetch_secret owncloud_db_password)"
export AWS_ACCESS_KEY_ID="$(fetch_secret AWS_ACCESS_KEY_ID)"
export AWS_SECRET_ACCESS_KEY="$(fetch_secret AWS_SECRET_ACCESS_KEY)"
export TF_VAR_gamerpc_mac_address="$(fetch_secret gamerpc_mac_address)"
export TF_VAR_rcon_password="$(fetch_secret rcon_password)"
export TF_VAR_discord_webhook_vultr="$(fetch_secret discord_webhook_vultr)"
export TF_VAR_discord_webhook_homeserver="$(fetch_secret discord_webhook_homeserver)"
