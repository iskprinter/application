dependencies {
  paths = [
    "../namespaces"
  ]
}

dependency "api" {
  config_path = "../api"
}

dependency "frontend" {
  config_path = "../frontend"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../..//source/ingress"
}

inputs = {
  api_service_name      = dependency.api.outputs.service_name
  api_service_port      = dependency.api.outputs.service_port
  frontend_service_name = dependency.frontend.outputs.service_name
  frontend_service_port = dependency.frontend.outputs.service_port
}
