package main

name := input.metadata.name
container := input.spec.template.spec.containers[0]

recommended_labels {
  input.metadata.labels["app.kubernetes.io/managed-by"]
}

is_not_crd {
  input.kind != "CustomResourceDefinition"
}

warn_labels[msg] {
  is_not_crd
  not recommended_labels

  msg = sprintf("%s/%s has not recommended labels", [input.kind, name])
}

deny_namespace[msg] {
  input.kind = "Namespace"
  ns := "syn-espejo"
  not input.metadata.name = ns

  msg = sprintf("Namespace is not %s", [ns])
}
