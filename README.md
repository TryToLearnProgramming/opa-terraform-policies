terraform plan --out tfplan.binary
terraform show -json tfplan.binary > tfplan.json


opa exec --decision terraform/analysis/authz_reason --bundle policy/ tfplan.json | jq -r '.result[].result | split(", ") | .[]'