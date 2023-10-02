# iskprinter/application

Terraform configuration to deploy all application-layer ISK Printer components

## Local Development Instructions

1. Create a `docker-registry` secret to allow image pulling from GCP Artifact Registry. The file `minikube-image-puller-key.json` 
    ```
    gcloud iam service-accounts keys create \
            "${HOME}/.ssh/minikube-image-puller-key.json" \
            --iam-account=minikube-image-puller@cameronhudson8.iam.gserviceaccount.com
    kubectl create secret docker-registry image-pull-secret \
        --context minikube \
        -n iskprinter \
        --docker-server='https://us-west1-docker.pkg.dev' \
        --docker-email='minikube-image-puller@cameronhudson8.iam.gserviceaccount.com' \
        --docker-username='_json_key' \
        --docker-password="$(cat "${HOME}/.ssh/minikube-image-puller-key.json")"
    ```

1. Patch the default serviceaccount in the `iskprinter` namespace.
    ```
    kubectl patch serviceaccount default \
        --context minikube \
        -n iskprinter \
        -p '{"imagePullSecrets": [{"name": "image-pull-secret"}]}'
    ```

1. Clone the repo(s) of the components that you want to develop, and build their container(s). Refer to `./config/dev/terragrunt.hcl` for the the supported images and their corresponding environment variables. 
    ```
    pushd ../api
    export API_IMAGE='iskprinter-api'
    minikube image build . -t "$API_IMAGE"
    popd

    pushd ../frontend
    export FRONTEND_IMAGE='iskprinter-frontend'
    minikube image build . -t "$FRONTEND_IMAGE"
    popd

    ...
    ```

1. Deploy the application.
    ```
    ENV_NAME='dev'  # or 'prod'
    terragrunt apply --terragrunt-working-dir "./config/${ENV_NAME}"
    ```

1. Get the certificate contents and save it locally.
    ```
    kubectl get secret tls-frontend \
        --context minikube \
        -n iskprinter \
        -o json \
        | jq -r '.data["tls.crt"]' \
        | base64 -d \
        >~/Desktop/iskprinter-dev.com.pem
    kubectl get secret tls-api \
        --context minikube \
        -n iskprinter \
        -o json \
        | jq -r '.data["tls.crt"]' \
        | base64 -d \
        >~/Desktop/api.iskprinter-dev.com.pem
    ```

1. Add each of the certificates to your `login` keychain. Then, inside Keychain Access, double-click on each certificate and set the trust level as "Always Trusted".

1. In a separate shell, start the minikube tunnel.
   ```
   minikube tunnel
   ```

1. Visit https://iskprinter-dev.com to confirm that the page is visible and the certificate is trusted.
