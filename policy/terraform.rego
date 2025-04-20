package terraform.analysis

import rego.v1

import input as tfplan

import data.terraform.blast_radius
import data.terraform.tags
import data.terraform.cloud_resources
import data.terraform.deployment_schedule
import data.terraform.region
import data.parameters
# import data.terraform.tags_bypass

# Authorization holds if all checks pass
default authz := false
default authz_reason := "Authorization failed"

authz if {
	blast_radius.score < parameters.blast_radius_threshold
	region.is_valid_region
	cloud_resources.s3_buckets_encrypted
	tags.resources_have_required_tags
	not deployment_schedule.is_restricted_day
	not cloud_resources.open_security_group_rules
}

authz if {
	blast_radius.score < parameters.blast_radius_threshold
	region.is_valid_region
	cloud_resources.s3_buckets_encrypted
	tags.resources_have_required_tags
	not deployment_schedule.is_restricted_day
	not cloud_resources.open_security_group_rules
}

authz if {
	is_first_time_deployment
	region.is_valid_region
	cloud_resources.s3_buckets_encrypted
	tags.resources_have_required_tags
	not deployment_schedule.is_restricted_day
	not cloud_resources.open_security_group_rules
}

# Provide reasons for authorization failure or success
authz_reason := reason if {
    not authz
    reasons := array.concat(
        [r | r := not_valid_score; r != ""],
        array.concat(
            [r | r := not_valid_region; r != ""],
            array.concat(
                [r | r := not_buckets_encrypted; r != ""],
                array.concat(
                    [r | r := not_first_time_deployment; r != ""],
                    array.concat(
                        [r | r := not_resources_have_required_tags; r != ""],
                        array.concat(
                            [r | r := is_restricted_day_reason; r != ""],
                            [r | r := open_security_group_rules_reason; r != ""]
                        )
                    )
                )
            )
        )
    )
    count(reasons) > 0
    reason := concat(", ", reasons)
}

authz_reason := "Authorization successful" if {
    authz
}

# Helper functions to provide specific reasons
not_valid_score := "Score exceeds blast radius" if {
	blast_radius.score >= parameters.blast_radius_threshold
}

not_valid_region := "Invalid region" if {
    not region.is_valid_region
}

not_buckets_encrypted := "Not all buckets are encrypted with KMS" if {
    not cloud_resources.s3_buckets_encrypted
}

not_first_time_deployment := "Not a first-time deployment" if {
    not is_first_time_deployment
    not (blast_radius.score < parameters.blast_radius_threshold)
}

not_resources_have_required_tags := "Some resources are missing the required tags" if {
    not tags.resources_have_required_tags
}

is_restricted_day_reason := "Deployment not allowed on restricted days" if {
    deployment_schedule.is_restricted_day
}

open_security_group_rules_reason := "Security groups have non-compliant ingress rules" if {
    cloud_resources.open_security_group_rules
}

# Check if this is a first-time deployment
is_first_time_deployment if {
	count([res | res := tfplan.resource_changes[_]; res.change.actions[_] != "create"]) == 0
	count(tfplan.resource_changes) > 0
}

# Terraform Library functions
resources[resource_type] := all if {
	some resource_type
	parameters.resource_types[resource_type]
	all := [name |
		name := tfplan.resource_changes[_]
		name.type == resource_type
	]
}

num_creates[resource_type] := num if {
	some resource_type
	parameters.resource_types[resource_type]
	all := resources[resource_type]
	creates := [res | res := all[_]; res.change.actions[_] == "create"]
	num := count(creates)
}

num_deletes[resource_type] := num if {
	some resource_type
	parameters.resource_types[resource_type]
	all := resources[resource_type]
	deletions := [res | res := all[_]; res.change.actions[_] == "delete"]
	num := count(deletions)
}

num_modifies[resource_type] := num if {
	some resource_type
	parameters.resource_types[resource_type]
	all := resources[resource_type]
	modifications := [res | res := all[_]; res.change.actions[_] == "modify"]
	num := count(modifications)
}
