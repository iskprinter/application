# iskprinter/application

Terraform configuration to deploy all application-layer ISK Printer components

## Local Development Instructions

1. Install `minikube`, start it, and enable the ingress extension
    ```
    brew install minikube
    minikube start
    minikube addons enable ingress
    ```

1. Deploy the application.
    ```
    terragrunt apply --terragrunt-working-dir ./config/local
    ```

1. Visit your local Hashicorp Vault and add the following credentials:
  * 
