#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace

SCRIPT_DIR="$(dirname "$(readlink -f -- "${BASH_SOURCE[0]}")")"

# From https://github.com/bitnami/sealed-secrets/blob/main/docs/bring-your-own-certificates.md

CLUSTER="$1"
PRIVATE_KEY="sealed_secret_${CLUSTER}.key"
PUBLIC_KEY="sealed_secret_${CLUSTER}.crt"

openssl req -x509 -days 365 -nodes -newkey rsa:4096 -keyout "$PRIVATE_KEY" -out "$PUBLIC_KEY" -subj "/CN=sealed-secret/O=sealed-secret"

NAMESPACE="kube-system" \
SECRET_NAME="sealed-secrets-key-${CLUSTER}-initial" \
PRIVATE_KEY_BASE64="$(base64 --wrap=0 "${PRIVATE_KEY}")" \
PUBLIC_KEY_BASE64="$(base64 --wrap=0 "${PUBLIC_KEY}")" \
envsubst < "$SCRIPT_DIR/sealedsecret.template.yaml"  > "${CLUSTER}.key.yaml"


#kubeseal --cert "./${PUBLIC_KEY}" < mysecret.yaml | kubectl apply -f-
