#!/usr/bin/env bash
set -euo pipefail
helm lint helm/hello-app
helm template hello-app helm/hello-app --namespace hello-app
