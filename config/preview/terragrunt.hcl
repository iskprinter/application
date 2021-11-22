remote_state {
  backend = "gcs"
  generate = {
    path      = "terragrunt_generated_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    project              = "cameronhudson8"
    location             = "us-west1"
    bucket               = "iskprinter-tf-state"
    prefix               = "application/pr-${get_env("PR_NUMBER")}"
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

inputs = {
  api_host      = "api.pr-${get_env("PR_NUMBER")}.iskprinter.com"
  namespace     = "iskprinter-pr-${get_env("PR_NUMBER")}"
  frontend_host = "pr-${get_env("PR_NUMBER")}.iskprinter.com"
}
