#!/bin/bash

echo "Installing autocompletion with Gcloud"
. /usr/local/gcloud/google-cloud-sdk/completion.bash.inc

echo "Installing pre-commit hooks"
$(which pre-commit) install -f --install-hooks
