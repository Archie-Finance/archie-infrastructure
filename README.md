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


Secret commands

```
kubeseal -o yaml < templates/unsealed_secrets/queue-secrets.yaml > templates/queue-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/api-shared-secrets.yaml > templates/api-shared-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/asset-price-api-secrets.yaml > templates/asset-price-api-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/auth0-secrets.yaml > templates/auth0-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/collateral-api-secrets.yaml > templates/collateral-api-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/credit-limit-api-secrets.yaml > templates/credit-limit-api-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/credit-api-secrets.yaml > templates/credit-api-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/internal-api-secrets.yaml > templates/internal-api-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/ltv-api-secrets.yaml > templates/ltv-api-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/mail-api-secrets.yaml > templates/mail-api-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/margin-api-secrets.yaml > templates/margin-api-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/onboarding-api-secrets.yaml > templates/onboarding-api-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/paypal-api-secrets.yaml > templates/paypal-api-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/peach-api-secrets.yaml > templates/peach-api-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/queue-secrets.yaml > templates/queue-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/referral-system-api-secrets.yaml > templates/referral-system-api-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/user-api-secrets.yaml > templates/user-api-secrets.yaml --controller-name=sealed-secrets
kubeseal -o yaml < templates/unsealed_secrets/webhook-api-secrets.yaml > templates/webhook-api-secrets.yaml --controller-name=sealed-secrets
```