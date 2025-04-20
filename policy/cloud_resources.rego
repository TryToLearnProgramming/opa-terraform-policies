package terraform.cloud_resources

import rego.v1
# import future.keywords
import input as tfplan
import data.parameters

######################################################################
## S3
######################################################################
# Rule to check if all S3 buckets are encrypted with KMS
s3_buckets_encrypted if {
    all_s3_buckets_encrypted
}

# Helper rule to check if all S3 buckets are encrypted with KMS
all_s3_buckets_encrypted if {
    count(unencrypted_buckets) == 0
}

# Find unencrypted S3 buckets or buckets not using KMS
unencrypted_buckets[bucket_name] if {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_s3_bucket"
    bucket_name := resource.change.after.bucket

    not bucket_has_kms_encryption(resource)
}

# Check if a bucket has KMS encryption
bucket_has_kms_encryption(resource) if {
    encryption := resource.change.after.server_side_encryption_configuration[_].rule[_].apply_server_side_encryption_by_default
    encryption.sse_algorithm == "aws:kms"
    encryption.kms_master_key_id != null
}

# Violation message for unencrypted buckets
s3_violation[msg] if {
    bucket := unencrypted_buckets[_]
    msg := sprintf("S3 bucket '%v' is not encrypted with KMS", [bucket])
}

######################################################################
## Security group rules
######################################################################
open_security_group_rules if {
    res := tfplan.resource_changes[_]
    res.type in ["aws_security_group_rule", "aws_security_group"]
    not has_bypass_tag(res)
    valid_port(res.change.after.ingress[_])
    invalid_cidr(res.change.after.ingress[_])
}

valid_port(ingress) if {
    some port in parameters.disallowed_ports
    ingress.from_port == port
}

valid_port(ingress) if {
    some port in parameters.disallowed_ports
    ingress.to_port == port
}

invalid_cidr(ingress) if ingress.cidr_blocks[_] in parameters.disallowed_cidrs
invalid_cidr(ingress) if ingress.ipv6_cidr_blocks[_] in parameters.disallowed_cidrs

# Helper function to check for opa-bypass tag
has_bypass_tag(resource) if {
    resource.change.after.tags["opa-bypass"] == "true"
}
