#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

OLM_VERSION="$1"

echo "OLM_VERSION: ${OLM_VERSION}"

curl -L "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/${OLM_VERSION}/install.sh" -o "${SCRIPT_DIR}/install.sh"
chmod +x "${SCRIPT_DIR}/install.sh"
"${SCRIPT_DIR}/install.sh" "${OLM_VERSION}"
rm "${SCRIPT_DIR}/install.sh"