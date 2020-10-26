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

COMPONENT_NAME ?= espejo
COMMODORE_CMD ?= docker run --rm --user="$(shell id -u)" --volume "${PWD}/../../:/app/data" --workdir /app/data projectsyn/commodore:latest component compile dependencies/$(COMPONENT_NAME)

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
	$(COMMODORE_CMD)

test: compile test_go

test_go:
	cd tests/go && go test ./...
