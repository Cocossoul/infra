# Test services and deployment

Using Terraform to quickly create cheap instance to test services and deployment during development.

## Usage

Export the following variables in your Shell :

- DOMAIN: the domain name the test services will use (mainly for Traefik, though not sure it is needed).
- VULTR_API_KEY: your Vultr API key.

Init Terraform with `terraform init`.
Deploy the infrastructure with `terraform apply`.
Wait for it to be deployed successfully.
While you're waiting, you can configure your DNS (TODO: create name.com Terraform Provider) to point the test domain name to the IPs in inventory.yml.
When the servers are successfully deployed (you can set `activation_email` to `true` to receive an notification by email), you can use the newly created `inventory.yml` file to test the Ansible playbooks.
Once you're done, you can use `terraform destroy` to free all ressources.
