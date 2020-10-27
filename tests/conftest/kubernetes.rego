package kubernetes

is_deployment {
  input.kind = "Deployment"
}

is_namespace {
  input.kind = "Namespace"
}
