# archie-infrastructure

To init helm

```
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update
helm install sealed-secrets-controller --namespace kube-system --version 1.16.1 sealed-secrets/sealed-secrets
```