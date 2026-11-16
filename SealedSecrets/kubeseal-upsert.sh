#!/usr/bin/env bash

set -o errexit
#set -o pipefail
set -o nounset
#set -o xtrace

sealed_secret_file="$1"
shift

key="$1"
shift

# Anything starting with '-' is meant for kubeseal, not as the secret: `... KEY --cert f.pem`
# would otherwise seal "--cert" as the value and drop the flag. `shift` on an empty list
# returns non-zero, which errexit turns into a silent exit before anything is sealed.
if [ "$#" -gt 0 ] && [[ "$1" != -* ]]; then
  value="$1"
  shift
else
  # LC_ALL=C because tr aborts with "Illegal byte sequence" on /dev/urandom under UTF-8 locale.
  value="$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c64)"
fi


if [ -e "${sealed_secret_file}" ]; then

  secret_name="$(yq '.metadata.name' "${sealed_secret_file}")"
  secret_namespace="$(yq '.metadata.namespace' "${sealed_secret_file}")"

  kubectl create secret generic \
    "${secret_name}" \
    --namespace "$secret_namespace" \
    --dry-run=client \
    --from-literal="$key"="$value" \
    -o json | \
      kubeseal  --format yaml --merge-into "${sealed_secret_file}" $*

else
  secret_name="$(basename --suffix ".yaml" "${sealed_secret_file}")"
  secret_namespace="$(yq '.helmCharts[] | .namespace' "kustomization.yaml")"

  kubectl create secret generic \
    "${secret_name}" \
    --namespace "$secret_namespace" \
    --dry-run=client \
    --from-literal="$key"="$value" \
    -o json | \
      kubeseal  --format "yaml" --namespace "${secret_namespace}" --sealed-secret-file "${sealed_secret_file}" $*
fi

echo "Encoded '${key}'='${value}' into Sealed Secret '${secret_name}' in namespace '${secret_namespace}' with key from $* or '$(kubectl config current-context)'"
