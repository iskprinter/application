remote_state {
  backend = "gcs"
  generate = {
    path      = "terragrunt_generated_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    project = "cameronhudson8"
    location = "us-west1"
    bucket = "iskprinter-tf-state-${dirname(path_relative_to_include())}"
    prefix = "application/${basename(path_relative_to_include())}"
    skip_bucket_creation = true
  }
}

terraform {
  extra_arguments "init_args" {
    commands = [
      "init"
    ]
    arguments = [
      "-lockfile=readonly",
    ]
  }
}

inputs = {
  api_client_credentials_secret_namespace    = "secrets"
  api_client_credentials_secret_key_id       = "id"
  api_client_credentials_secret_key_secret   = "secret"
  api_client_credentials_secret_name         = "api-client-credentials"
  cicd_namespace                             = "tekton-pipelines"
  cicd_bot_name                              = "cicd-bot"
  gcp_project                                = "cameronhudson8"
  google_dns_managed_zone_name               = "iskprinter-com"
  image_acceptance_test                      = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/acceptance-test:6dca43ce9b0e32918f1189670d674598d7840442"
  image_api                                  = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/api:e5d7964adf20580021692bd7be1ae1b0301e48a3"
  image_frontend                             = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/frontend:e5b147c59acc0989555528d3117f69de87cb3d54"
  image_weekly_download                      = "us-west1-docker.pkg.dev/cameronhudson8/iskprinter/weekly-download:90edfe1c7757c4e701973166af53c77384013e16"
  mongodb_replicas                           = 2
  neo4j_persistent_volume_size               = "10Gi"
  neo4j_release_name                         = "neo4j"
  neo4j_replicas                             = 2
  neo4j_version                              = "4.3.4" # The Neo4j version.
  region                                     = "us-west1"
}
