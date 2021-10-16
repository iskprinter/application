# iskprinter/helm

The helm chart for all IskPrinter components

![Build Status](https://iskprinter.com/jenkins/buildStatus/icon?job=helm%2Fmain)

## How to use

Deploy using helm. Example parameters are below

helm upgrade --install "$RELEASE_NAME" ./helm \
    --kube-context "$KUBE_CONTEXT" \
    -n "$NAMESPACE" \
    --set "secrets.apiClientCredentials.secretName=${API_CLIENT_CREDENTIALS_SECRET_NAME}" \
    --set "secrets.apiClientCredentials.id=${API_CLIENT_ID}" \
    --set "secrets.apiClientCredentials.secret=${API_CLIENT_SECRET}" \
    --set "secrets.mongodbConnection.secretName=${MONGODB_CONNECTION_SECRET_NAME}"
    --set "secrets.mongodbConnection.url=mongodb+srv://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@${MONGODB_HOSTNAME}/?ssl=false"
    --set 'hostname=iskprinter.com' \
    [--dry-run]
