package main

import data.kubernetes

name := input.metadata.name
container := input.spec.template.spec.containers[0]

recommended_labels {
  input.metadata.labels["app.kubernetes.io/managed-by"]
}

deny_deployment_name[msg] {
  input.kind = "Deployment"
  not name = "espejo"

  msg = sprintf("Deployment has invalid name: %s", [name])
}

deny_deployment_args[msg] {
  input.kind = "Deployment"
  arg := "--enable-leader-election=true"
  not kubernetes.contains(container.args, arg)

  msg = sprintf("Container '%s' in Deployment '%s' is missing arg: %s", [container.name, name, arg])
}

deny_deployment_args[msg] {
  input.kind = "Deployment"
  arg := "--metrics-addr=:8080"
  not kubernetes.contains(container.args, arg)

  msg = sprintf("Container '%s' in Deployment '%s' is missing arg: %s", [container.name, name, arg])
}

deny_deployment_args[msg] {
  input.kind = "Deployment"
  arg := "--reconcile-interval=10m"
  not kubernetes.contains(container.args, arg)

  msg = sprintf("Container '%s' in Deployment '%s' is missing arg: %s", [container.name, name, arg])
}

deny_deployment_args[msg] {
  input.kind = "Deployment"
  arg := "--verbose=false"
  not kubernetes.contains(container.args, arg)

  msg = sprintf("Container '%s' in Deployment '%s' is missing arg: %s", [container.name, name, arg])
}

warn_labels[msg] {
  kubernetes.is_not_crd
  not recommended_labels

  msg = sprintf("%s/%s has not recommended labels", [input.kind, name])
}

deny_namespace[msg] {
  input.kind = "Namespace"
  ns := "syn-espejo"
  not input.metadata.name = ns

  msg = sprintf("Namespace is not %s", [ns])
}
