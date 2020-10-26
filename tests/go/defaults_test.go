package _go

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

var (
	testPath = "../../compiled/test/espejo"
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
