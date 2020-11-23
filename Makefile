MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

# Commodore takes the root dir name as the component name
COMPONENT_NAME ?= $(shell basename ${PWD} | sed s/component-//)

DOCKER_CMD   ?= docker
DOCKER_ARGS  ?= run --rm --user "$$(id -u)" -v "$${PWD}:/$(COMPONENT_NAME)" --workdir /$(COMPONENT_NAME)

JSONNET_FILES   ?= $(shell find . -type f -name '*.*jsonnet' -or -name '*.libsonnet')
JSONNETFMT_ARGS ?= --in-place
JSONNET_IMAGE   ?= quay.io/bitnami/jsonnet:latest
JSONNET_DOCKER  ?= $(DOCKER_CMD) $(DOCKER_ARGS) --entrypoint=jsonnetfmt $(JSONNET_IMAGE)

YAML_FILES      ?= $(shell find . -type f -name '*.yaml' -or -name '*.yml')
YAMLLINT_ARGS   ?= --no-warnings
YAMLLINT_CONFIG ?= .yamllint.yml
YAMLLINT_IMAGE  ?= docker.io/cytopia/yamllint:latest
YAMLLINT_DOCKER ?= $(DOCKER_CMD) $(DOCKER_ARGS) $(YAMLLINT_IMAGE)

COMMODORE_CMD  ?= $(DOCKER_CMD) $(DOCKER_ARGS) projectsyn/commodore:latest component compile . -f tests/test.yml
JB_CMD         ?= $(DOCKER_CMD) $(DOCKER_ARGS) --entrypoint /usr/local/bin/jb projectsyn/commodore:latest install

CONFTEST_CMD   ?= $(DOCKER_CMD) $(DOCKER_ARGS) --volume "${PWD}/tests/policies:/policy" openpolicyagent/conftest:latest test --policy /policy

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

.PHONY: compile
compile:
	$(JB_CMD)
	$(COMMODORE_CMD)

.PHONY: test
test: compile test_go test_conftest

.PHONY: test_go
test_go:
	@echo "===> Running Go unit tests"
	cd tests/unit && go test -v ./...

.PHONY: test_conftest
test_conftest:
	@echo "===> Running Conftest policies";
	@$(CONFTEST_CMD) $(shell find . -type f -wholename './compiled/$(COMPONENT_NAME)/*.yaml')

.PHONY: clean
clean:
	rm -r compiled manifests dependencies vendor || true
