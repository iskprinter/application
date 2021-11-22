remote_state {
  backend = "gcs"
  generate = {
    path      = "terragrunt_generated_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    project = "cameronhudson8"
    location = "us-west1"
    bucket = "iskprinter-tf-state"
    prefix = get_env("TF_VAR_env_name")
    skip_bucket_creation = false
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
  source = "../..//."
}

inputs = {}
