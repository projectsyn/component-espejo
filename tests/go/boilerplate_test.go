package _go

import (
	"github.com/stretchr/testify/assert"
	"io/ioutil"
	appsv1 "k8s.io/api/apps/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/serializer"
	clientgoscheme "k8s.io/client-go/kubernetes/scheme"
	"testing"
)

func DecodeDeployment(t *testing.T, path string) *appsv1.Deployment {
	subject := &appsv1.Deployment{}
	scheme := runtime.NewScheme()
	assert.NoError(t, appsv1.AddToScheme(scheme))
	assert.NoError(t, clientgoscheme.AddToScheme(scheme))
	return DecodeWithSchema(t, path, subject, scheme).(*appsv1.Deployment)
}

func DecodeWithSchema(t *testing.T, path string, into runtime.Object, schema *runtime.Scheme) runtime.Object {
	data, err := ioutil.ReadFile(path)
	assert.NoError(t, err)
	kind := into.GetObjectKind().GroupVersionKind()
	decode, _, err := serializer.NewCodecFactory(schema).UniversalDeserializer().Decode(data, &kind, into)
	assert.NoError(t, err)
	return decode
}
