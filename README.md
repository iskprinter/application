# iskprinter/application

Terraform configuration to deploy all application-layer ISK Printer components

## Local Development Instructions

1. Deploy the application.
    ```
    ENV_NAME=test  # or 'prod'
    terragrunt apply --terragrunt-working-dir "./config/${ENV_NAME}"
    ```

1. Get the certificate contents and save it locally.
    ```
    kubectl get secret tls-frontend \
        -n iskprinter \
        -o json \
        | jq -r '.data["tls.crt"]' \
        | base64 -d \
        >~/Desktop/iskprinter-test.com.pem
    kubectl get secret tls-api \
        -n iskprinter \
        -o json \
        | jq -r '.data["tls.crt"]' \
        | base64 -d \
        >~/Desktop/api.iskprinter-test.com.pem
    ```

1. Add each of the certificates to your `login` keychain. Then, inside Keychain Access, double-click on each certificate and set the trust level as "Always Trusted".

1. In a separate shell, start the minikube tunnel.
   ```
   minikube tunnel
   ```

1. Visit https://iskprinter-test.com to confirm that the page is visible and the certificate is trusted.
