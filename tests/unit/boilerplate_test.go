package main

import (
	"github.com/stretchr/testify/require"
	"io/ioutil"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/serializer"
	clientgoscheme "k8s.io/client-go/kubernetes/scheme"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

// TODO: Add possibility to decode objects from YAML that contain multiple documents

func DecodeDeployment(t *testing.T, path string) *appsv1.Deployment {
	subject := &appsv1.Deployment{}
	scheme := NewSchemeWithDefault(t)
	require.NoError(t, appsv1.AddToScheme(scheme))
	return DecodeWithSchema(t, path, subject, scheme).(*appsv1.Deployment)
}

func DecodeNamespace(t *testing.T, path string) *corev1.Namespace {
	subject := &corev1.Namespace{}
	scheme := NewSchemeWithDefault(t)
	require.NoError(t, appsv1.AddToScheme(scheme))
	return DecodeWithSchema(t, path, subject, scheme).(*corev1.Namespace)
}

func DecodeWithSchema(t *testing.T, path string, into runtime.Object, schema *runtime.Scheme) runtime.Object {
	data, err := ioutil.ReadFile(path)
	require.NoError(t, err)
	kind := into.GetObjectKind().GroupVersionKind()
	decode, _, err := serializer.NewCodecFactory(schema).UniversalDeserializer().Decode(data, &kind, into)
	require.NoError(t, err)
	return decode
}

func NewSchemeWithDefault(t *testing.T) *runtime.Scheme {
	scheme := runtime.NewScheme()
	require.NoError(t, clientgoscheme.AddToScheme(scheme))
	return scheme
}

func ScanFiles(path string) (files []string, retErr error) {
	err := filepath.Walk(path, func(path string, info os.FileInfo, err error) error {
		if info.IsDir() {
			return nil
		}
		if strings.HasSuffix(info.Name(), ".yaml") {
			files = append(files, path)
		}
		return nil
	})
	return files, err
}
