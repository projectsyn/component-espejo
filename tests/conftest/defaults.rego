package main

import data.kubernetes

name = input.metadata.name
container = input.spec.template.spec.containers[0]

deny_deployment[msg] {
  kubernetes.is_deployment
  not container.args = ["--enable-leader-election=true", "--metrics-addr=:8080", "--reconcile-interval=10m", "--verbose=false"]

  msg = sprintf("Container '%s' in Deployment '%s' has invalid args: %s", [container.name, name, container.args])
}

deny_namespace[msg] {
  kubernetes.is_namespace
  input.metadata.name != "syn-espejo"

  msg = "Namespace is not syn-espejo"
}
