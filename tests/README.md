# Test services and deployment

Using Terraform to quickly create cheap instance to test services and deployment during development.

It only provides test environment for homeserver yet.

## Usage

### Environment

Export the following variables in your Shell :

- DOMAIN: the domain name the test services will use. You should setup it as a CNAME record that points to your DynDNS record/zone.
- VULTR_API_KEY: your Vultr API key.
- DYNDNS_HOMESERVERTEST_DOMAIN: the DynDNS domain
- DYNDNS_HOMESERVERTEST_TOKEN: the HTTP token to the dynv6 API to auto link your test domain to the server's IP

### Steps

- init Terraform with `terraform init`
- deploy the infrastructure with `terraform apply`
- wait for it to be deployed successfully
- while you're waiting, you can configure your DNS (TODO: create name.com Terraform Provider) to point the test domain name to the IPs in inventory.yml. Note: this step can be and in my case has been automated by the use of DynDNS (see the DynDNS Ansible role).
- when the servers are successfully deployed (you can set `activation_email` to `true` to receive an notification by email), you can use the newly created `inventory.yml` file to test the Ansible playbooks.
- once you're done, you can use `terraform destroy` to free all ressources (except DNS records)
