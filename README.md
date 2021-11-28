# iskprinter/application

Terraform configuration to deploy all application-layer ISK Printer components

## Local Development Instructions

1. Ask your friendly neighborhood DevOps engineer to create a GCP service account for you, with permission to pull images.

1. Install `minikube`, start it, and enable the ingress extension
    ```
    brew install minikube
    minikube start
    minikube addons enable ingress
    ```

1. Create the `iskprinter-local` namespace.
    ```
    kubectl --context minikube create namespace iskprinter-local
    ```

1. Create a default imagePullSecret and attach it to the default service account.
    ```
    SERVICE_ACCOUNT_ID=<service-account-id>  # for example, 'cameronhudson'
    SERVICE_ACCOUNT_JSON_KEY_FILE=<service-account-key-file>

    kubectl create secret docker-registry image-pull-secret \
        -n iskprinter-local \
        --docker-server=https://us-west1-docker.pkg.dev \
        --docker-email="${SERVICE_ACCOUNT_ID}@cameronhudson8.iam.gserviceaccount.com" \
        --docker-username=_json_key \
        --docker-password="$(cat "$SERVICE_ACCOUNT_JSON_KEY_FILE")"

    kubectl patch serviceaccount default \
        -n iskprinter-local \
        -p '{"imagePullSecrets": [{"name": "image-pull-secret"}]}'
    ```

1. Export credentials.
    ```
    export TF_VAR_api_client_id='<api_client_id>'
    export TF_VAR_api_client_secret='<api_client_secret>'
    ```

1. Deploy the application.
    ```
    terragrunt apply --terragrunt-working-dir ./config/local
    ```

1. Set your `/etc/hosts` file as shown below.
   ```
   127.0.0.1 local.iskprinter.com
   127.0.0.1 api.local.iskprinter.com
   ```

1. Start the minikube tunnel.
   ```
   nohup minikube tunnel </dev/null >/dev/null &
   ```
