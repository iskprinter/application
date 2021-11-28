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

1. Create the `iskprinter-local` namespace and the `cert-manager` namespaces.
    ```
    kubectl --context minikube create namespace iskprinter-local 
    kubectl --context minikube create namespace cert-manager
    ```

1. Install `cert-manager`.
    ```
    helm upgrade --install \
        cert-manager cert-manager \
        --repo https://charts.jetstack.io \
        -n cert-manager \
        --version v1.6.1 \
        --set prometheus.enabled=false \
        --set installCRDs=true
    ```

1. Create a self-signed issuer. (If copying this from a text editor into a shell, first de-indent the code, then copy).
    ```
    cat <<EOF | kubectl apply -f -
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
        name: self-signed
    spec:
        selfSigned: {}
    EOF
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

1. Deploy the application. The acceptance test will fail because the certificates are not yet trusted.
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

1. Get the certificate contents and save it locally.
    ```
    kubectl get secret tls-iskprinter-com \
        -n iskprinter-local \
        -o json \
        | jq -r '.data["tls.crt"]' \
        | base64 -d \
        > ~/Desktop/frontend.pem
    kubectl get secret tls-api-iskprinter-com \
        -n iskprinter-local \
        -o json \
        | jq -r '.data["tls.crt"]' \
        | base64 -d \
        > ~/Desktop/api.pem
    ```

1. Add each of the certificates to your keychain. Double-click on each and set the trust level as "Always Trusted".

1. Visit https://local.iskprinter.com to confirm that the page is visible and the certificate is trusted.
