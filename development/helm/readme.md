## Vault

1. Install helm chart
2. Key shares
3. Enable automatic backups

https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-minikube-raft



## Setup new microservice secrets

Create new service account
```
kubectl create sa <service_name>
```
SSH into vault
```
vault write auth/kubernetes/role/<service_name> \
    bound_service_account_names=<service_name> \
    bound_service_account_namespaces=default \
    policies=<service_name> \
    ttl=24h

vault write database/config/<service_name> \
    plugin_name=postgresql-database-plugin \
    allowed_roles="*" \
    connection_url="postgresql://{{username}}:{{password}}@archie-development-postgres.cxquhakfp0gl.us-east-1.rds.amazonaws.com:5432/<database_name>?sslmode=disable" \
    username="" \
    password=""

vault write database/roles/<service_name> \
    db_name=<service_name> \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    revocation_statements="ALTER ROLE \"{{name}}\" NOLOGIN;"\
    default_ttl="1h" \
    max_ttl="720h"

```