# archie-infrastructure

To init helm

```
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update
helm install sealed-secrets-controller --namespace kube-system --version 1.16.1 sealed-secrets/sealed-secrets
```

Vault instalation

```
https://learn.hashicorp.com/tutorials/cloud/vault-eks?in=vault/cloud-ops
```

AWS Load Balancer Controller

```
https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/installation/
```
