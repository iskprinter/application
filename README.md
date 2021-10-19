# iskprinter/application

The stateless application layer

## How to use

Prerequisite: **The namespace set in `variables.tf` must already exist.**

If running from within a kuberentes cluster, you don't need to provide authentication manually. For local use, the simplest approach is to provide the path to your `.kube/config`.

```
export "KUBE_CONFIG_PATH=${HOME}/.kube/config"
```

Provide secret inputs.
```
export TF_VAR_api_client_secret_base64=$(echo -n '<secret>' | base64)

MONGODB_HOSTNAME='mongodb-svc.database.svc.cluster.local'
MONGODB_USERNAME='...'
MONGODB_PASSWORD='...'

mongodb_password_urlencoded=$(echo "$MONGODB_PASSWORD" | jq -Rr '@uri')
export TF_VAR_mongodb_connection_url_base64=$(echo -n "mongodb+srv://${MONGODB_USERNAME}:${mongodb_password_urlencoded}@${MONGODB_HOSTNAME}/?ssl=false" | base64)
```

Apply.
```
terraform apply
```
