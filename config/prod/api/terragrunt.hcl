dependencies {
  paths = [
    "../namespaces",
  ]
}

dependency "db_document" {
  config_path = "../db_document"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../..//source/api"
}

inputs = {
  mongodb_connection_secret_key_url = dependency.db_document.outputs.mongodb_connection_secret_key_url
  mongodb_connection_secret_name    = dependency.db_document.outputs.mongodb_connection_secret_name
  mongodb_connection_secret_version = dependency.db_document.outputs.mongodb_connection_secret_version
}
