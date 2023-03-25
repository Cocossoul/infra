FROM hashicorp/vault:1.12

COPY config/config.hcl /config.hcl

ENTRYPOINT [ "vault", "server", "-config=/config.hcl" ]
