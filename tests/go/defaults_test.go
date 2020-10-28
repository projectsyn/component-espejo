package _go

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"strings"
	"testing"
)

var (
	testPath = "../../compiled/espejo/espejo"
)

func Test_DefaultParameters(t *testing.T) {

	subject := DecodeDeployment(t, testPath+"/10_deployment.yaml")
	container := subject.Spec.Template.Spec.Containers[0]

	assert.Contains(t, container.Args, "--verbose=false")
	assert.Contains(t, container.Args, "--reconcile-interval=10m")
	assert.Contains(t, container.Args, "--metrics-addr=:8080")
	assert.Contains(t, container.Args, "--enable-leader-election=true")

	env := container.Env[0]
	assert.Equal(t, "WATCH_NAMESPACE", env.Name)
	assert.Equal(t, "metadata.namespace", env.ValueFrom.FieldRef.FieldPath)
}

func Test_Labels(t *testing.T) {
	files, err := ScanFiles(testPath)
	assert.NoError(t, err)
	label := "app.kubernetes.io/managed-by"
	var objectsWithMissingLabels []string
	for _, file := range files {
		obj := unstructured.Unstructured{}
		_ = DecodeWithSchema(t, file, &obj, NewSchemeWithDefault(t))
		// TODO: Some files contain multiple documents in YAML, how to deserialize all of them, not just the first entry?
		if obj.GetKind() == "CustomResourceDefinition" {
			continue
		}
		labels := obj.GetLabels()
		if labels[label] == "" {
			objectsWithMissingLabels = append(objectsWithMissingLabels, fmt.Sprintf("%s/%s", obj.GetKind(), obj.GetName()))
		}
	}
	if len(objectsWithMissingLabels) > 0 {
		t.Skipf("WARNING: Following objects are missing recommended label '%s': %s", label, strings.Join(objectsWithMissingLabels, ", "))
	}
}
