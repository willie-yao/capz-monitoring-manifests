#!/usr/bin/env bash

# This script uses arg $1 (name of *.jsonnet file to use) to generate the manifests/*.yaml files.

set -e
set -x
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

# Make sure to use project tooling
PATH="$(pwd)/tmp/bin:${PATH}"

# Make sure to start with a clean 'manifests' dir
rm -rf manifests
mkdir -p manifests/setup

# Calling gojsontoyaml is optional, but we would like to generate yaml, not json
jsonnet --ext-str azure_client_id="${AZURE_ENTRA_CLIENT_ID}" \
  --ext-str azure_client_secret="${AZURE_ENTRA_CLIENT_SECRET}" \
  --ext-str azure_organization_id="${AZURE_ENTRA_MSFT_ORGANIZATION_ID}" \
  --ext-str azure_auth_url="${AZURE_ENTRA_AUTH_URL}" \
  --ext-str azure_token_url="${AZURE_ENTRA_TOKEN_URL}" \
  -J vendor -m manifests "${1-main.jsonnet}" | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml' -- {}

# Make sure to remove json files
find manifests -type f ! -name '*.yaml' -delete
rm -f kustomization

