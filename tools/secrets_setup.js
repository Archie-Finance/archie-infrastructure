function printSecretCommands() {
  const serviceName = process.argv[2];
  const databaseName = process.argv[3];

  const databaseUsername = process.argv[4];

  if (serviceName === undefined || databaseName === undefined || databaseUsername === undefined) {
    throw new Error('Invalid arguments');
  }

  console.log(`
kubectl create sa ${serviceName}
`)

  console.log(`
vault write auth/kubernetes/role/${serviceName} \\
  bound_service_account_names=${serviceName} \\
  bound_service_account_namespaces=default \\
  policies=${serviceName} \\
  ttl=24h
`)

  console.log(`
vault write database/config/${serviceName} \\
  plugin_name=postgresql-database-plugin \\
  allowed_roles="*" \\
  connection_url="postgresql://{{username}}:{{password}}@archie-development-postgres.cxquhakfp0gl.us-east-1.rds.amazonaws.com:5432/${databaseName}?sslmode=disable" \\
  username="${databaseUsername}" \\
  password="<password>"
`)

  console.log(`
vault write database/roles/${serviceName} \\
  db_name=${serviceName} \\
  creation_statements="CREATE ROLE \\"{{name}}\\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \\
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO \\"{{name}}\\";" \\
  revocation_statements="ALTER ROLE \\"{{name}}\\" NOLOGIN;" \\
  default_ttl="1h" \\
  max_ttl="720h"
`)
}

printSecretCommands()