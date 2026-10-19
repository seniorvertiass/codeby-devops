#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../terraform"
test -f backend.hcl || { echo "Create terraform/backend.hcl from backend.hcl.example first"; exit 1; }
terraform fmt -recursive
terraform init -backend-config=backend.hcl
terraform validate
terraform plan
