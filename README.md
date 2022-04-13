# iskprinter/application

Terraform configuration to deploy all application-layer ISK Printer components

## Local Development Instructions

1. Ask your friendly neighborhood DevOps engineer to create a GCP service account for you, with permission to pull images.

1. Install `minikube`, start it, and enable the ingress extension
    ```
    brew install minikube
    brew install --cask docker
    brew install helm
    minikube start \
        --kubernetes-version=v1.21.9 \
        --cpus 4 \
        --memory 7951
    minikube addons enable ingress
    ```

1. Create a default imagePullSecret and attach it to the default service account.
    ```
    SERVICE_ACCOUNT_ID=<service-account-id>  # for example, 'cameronhudson'
    SERVICE_ACCOUNT_JSON_KEY_FILE=<service-account-key-file>

    kubectl create secret docker-registry image-pull-secret \
        --context minikube \
        -n iskprinter \
        --docker-server=https://us-west1-docker.pkg.dev \
        --docker-email="${SERVICE_ACCOUNT_ID}@cameronhudson8.iam.gserviceaccount.com" \
        --docker-username=_json_key \
        --docker-password="$(cat "$SERVICE_ACCOUNT_JSON_KEY_FILE")"

    kubectl patch serviceaccount default \
        --context minikube \
        -n iskprinter \
        -p '{"imagePullSecrets": [{"name": "image-pull-secret"}]}'
    ```

1. Export credentials.
    ```
    export TF_VAR_api_client_id='<api_client_id>'
    export TF_VAR_api_client_secret='<api_client_secret>'
    ```

1. Deploy the application. The acceptance test will fail because the certificates are not yet trusted.
    ```
    terragrunt apply --terragrunt-working-dir ./config/local
    ```

1. Set your `/etc/hosts` file as shown below.
   ```
   127.0.0.1 iskprinter-local.com
   127.0.0.1 api.iskprinter-local.com
   ```

1. Get the certificate contents and save it locally.
    ```
    kubectl get secret tls-frontend \
        -n iskprinter \
        -o json \
        | jq -r '.data["tls.crt"]' \
        | base64 -d \
        >~/Desktop/iskprinter-local.com.pem
    kubectl get secret tls-api \
        -n iskprinter \
        -o json \
        | jq -r '.data["tls.crt"]' \
        | base64 -d \
        >~/Desktop/api.iskprinter-local.com.pem
    ```

1. Add each of the certificates to your `login` keychain. Then, inside Keychain Access, double-click on each certificate and set the trust level as "Always Trusted".

1. In a separate shell, start the minikube tunnel.
   ```
   minikube tunnel
   ```

1. Visit https://iskprinter-local.com to confirm that the page is visible and the certificate is trusted.

1. Re-apply the terraform resources to confirm that the acceptance test passes.
    ```
    terragrunt apply --terragrunt-working-dir ./config/local
    ```
