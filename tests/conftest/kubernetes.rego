package kubernetes

is_deployment {
  input.kind = "Deployment"
}

is_namespace {
  input.kind = "Namespace"
}

contains(array, elem) = true {
  array[_] = elem
} else = false { true }

is_not_crd {
  input.kind != "CustomResourceDefinition"
}
