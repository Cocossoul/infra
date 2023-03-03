# Infra

## Specifications

The specifications for designing the infrastructure, the most important first:

- Should be testable (deployment + applications)
- Should be resilient (state stored in safe places, easy to redeploy, save important data)
- Should be easy to add other services and machines to the infrastructure
- Should be entirely automated (one command to deploy, update and destroy)
- Should be easy to understand
- Should be updatable and destroyable in one command
- Should not have a loooot of secrets and variables

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
