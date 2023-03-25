# Infra

## Usage

- bootstrap Terraform (see the [bootstrap folder](./bootstrap/))
- `./deploy.sh` to deploy configuration (can add `-auto-approve` for automated deployments)

## Manual intervention

- Bootstrap Terraform by modifying the backend (first local, then S3)
- Setup the dyndns on [duckdns](duckdns.org)
- Wiring the machines and flashing the OSes (except the Vultr one)

## Service deployment

Services are containerized with their configuration files in a Docker image
pushed on Docker Hub, before being deployed on a machine with Terraform.

Configuration changes are (more or less) detected with Terraform.

## Reverse-proxying

I'm using Traefik dynamic configuration capabilities, to have the proxy
configuration in each service's config instead of a global config.

Each machine basically has a Traefik container running, which figures out the
needed proxy configuration using the Docker provider (the Traefik provider).

That way it is easy to move services around, duplicate them and to deploy new
ones and there is only one Traefik service configuration.

## Kubernetes

I think that most of the features above could be managed by Kubernetes,
so in the future I will probably use it.

## Resources

### Machines

- Home Server: okey CPU, lot of storage, not resilient
- Gamer PC Raspi: not resilient, no CPU no storage
- AWS S3 / DynamoDB: very resilient, little storage
- Vultr VPS: okey resilient, bad CPU, not much storage

### DNS servers

- Cloudflare

## Technologies

CI/CD pipeline:

- Terraform: server provisionning and DNS configuration
- Ansible: server configuration
- Docker: containerize apps
- Terraform: deploy apps
- Github actions: run the pipeline

Netdata: monitoring
Dockerhub: storing images to be deployed

## Secrets

The following secrets should be exported in the env:

- TF_VAR_cloudflare_token
- VULTR_API_KEY
- TF_VAR_dyndns_token
- TF_VAR_owncloud_admin_username
- TF_VAR_owncloud_admin_password
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- TF_VAR_mosquitto_user
- TF_VAR_mosquitto_password
- TF_VAR_gamerpc_mac_address

## Architecture

    infra/
    ├─ services/
    │  ├─ gatus/
    │  │  ├─ Dockerfile
    │  │  ├─ default.tf
    │  │  ├─ config/
    │  │  │  ├─ config.yaml
    │  ├─ owncloud/
    │  │  ├─ default.tf
    ├─ machines/
    │  ├─ homeserver/
    │  │  ├─ playbook.yml
    │  │  ├─ inventory.yml
    │  │  ├─ dns.tf
    │  │  ├─ configure.tf
    │  │  ├─ reverse-proxy.tf
    │  ├─ vultr/
    │  │  ├─ playbook.yml
    │  │  ├─ inventory.yml
    │  │  ├─ dns.tf
    │  │  ├─ configure.tf
    │  │  ├─ reverse-proxy.tf
    │  │  ├─ deploy.tf
    ├─ reverse-proxy/
    │  ├─ Dockerfile
    │  ├─ traefik.yml
    │  ├─ default.tf
    ├─ init.tf
    ├─ services.tf
    ├─ machines.tf
    ├─ ansible/
    │  ├─ roles/
    │  ├─ ansible.cfg
    ├─ bootstrap/
    │  ├─ tfstate_storage.tf
