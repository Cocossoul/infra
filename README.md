# Infra

## Specifications

The specifications for designing the infrastructure, the most important first:

- [ ] Should be testable (deployment + applications)
- [ ] Should be resilient (state stored in safe places, easy to redeploy, save important data)
- [x] Should be easy to add other services and machines to the infrastructure
- [x] Should be entirely automated (one command to deploy, update and destroy)
- [ ] Should be easy to understand
- [x] Should be updatable and destroyable in one command
- [x] Should not have a loooot of secrets and variables

## Resources

### Machines

- home server: okey CPU, lot of storage, not resilient -> owncloud, minecraft server (if saved)
- gamer pc raspi: not resilient, no CPU no storage
- AWS S3 / DynamoDB: very resilient, little storage
- vultr VPS: okey resilient, bad CPU, not much storage

resilient: strong availability + low chances of losing data

### DNS servers

- Cloudflare

## Technologies

CI/CD pipeline:

- Terraform: server provisionning, DNS configuration (+ dyndns ?)
- Ansible: server configuration
- Docker: contenerize apps
- Terraform: deploy apps
- Github actions: run the pipeline

Netdata: monitoring
Dockerhub: cocopaps/apps private repo, with apps as tags

## Services

Gatus

## Pain points

One reverse proxy per machine -> should be solved by Kubernetes
Or easily use traefik with default config if everything is Docker (docker labels not on docker-compose) -> I like that better

## Secrets

To be exported to the env:

- TF_VAR_cloudflare_token
- VULTR_API_KEY
- TF_VAR_dyndns_token
- DOCKER_USERNAME
- DOCKER_PASSWORD
- TF_VAR_owncloud_admin_username
- TF_VAR_owncloud_admin_password

## Optim

Make modules for services to have a true PaaS

## Bugs

Dyndns not supported yet

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
