MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

DOCKER_CMD   ?= docker
DOCKER_ARGS  ?= run --rm --user "$$(id -u)" -v "$${PWD}:/component" --workdir /component

JSONNET_FILES   ?= $(shell find . -type f -name '*.*jsonnet' -or -name '*.libsonnet')
JSONNETFMT_ARGS ?= --in-place
JSONNET_IMAGE   ?= docker.io/bitnami/jsonnet:latest
JSONNET_DOCKER  ?= $(DOCKER_CMD) $(DOCKER_ARGS) --entrypoint=jsonnetfmt $(JSONNET_IMAGE)

YAML_FILES      ?= $(shell find . -type f -name '*.yaml' -or -name '*.yml')
YAMLLINT_ARGS   ?= --no-warnings
YAMLLINT_CONFIG ?= .yamllint.yml
YAMLLINT_IMAGE  ?= docker.io/cytopia/yamllint:latest
YAMLLINT_DOCKER ?= $(DOCKER_CMD) $(DOCKER_ARGS) $(YAMLLINT_IMAGE)

COMPONENT_NAME ?= $(shell basename ${PWD} | sed s/component-//)
COMMODORE_CMD  ?= docker run --rm --user="$(shell id -u)" --volume "${PWD}:/app/$(COMPONENT_NAME)" --workdir /app/$(COMPONENT_NAME) projectsyn/commodore:latest component compile . -f tests/test.yml

CONFTEST_CMD   ?= docker run --rm --volume "${PWD}/tests/conftest:/policy" --volume "${PWD}:/test" --workdir /test openpolicyagent/conftest:latest test --policy /policy

.PHONY: all
all: lint

.PHONY: lint
lint: lint_jsonnet lint_yaml

.PHONY: lint_jsonnet
lint_jsonnet: $(JSONNET_FILES)
	$(JSONNET_DOCKER) $(JSONNETFMT_ARGS) --test -- $?

.PHONY: lint_yaml
lint_yaml: $(YAML_FILES)
	$(YAMLLINT_DOCKER) -f parsable -c $(YAMLLINT_CONFIG) $(YAMLLINT_ARGS) -- $?

.PHONY: format
format: format_jsonnet

.PHONY: format_jsonnet
format_jsonnet: $(JSONNET_FILES)
	$(JSONNET_DOCKER) $(JSONNETFMT_ARGS) -- $?

compile:
	jb install
	$(COMMODORE_CMD)

test: compile test_go test_conftest

test_go:
	@if [ -f "tests/go/go.mod" ]; then cd tests/go && go test -v ./...; else echo "===> Skipping Go unit tests"; fi

test_conftest:
	@if [ -d "tests/conftest" ]; then $(CONFTEST_CMD) $(shell find . -type f -wholename './compiled/$(COMPONENT_NAME)/*.yaml'); else echo "===> Skipping Conftest policies"; fi

clean:
	rm -r compiled manifests dependencies || true
