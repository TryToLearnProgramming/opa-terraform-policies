package terraform.tags

import rego.v1

import input as tfplan
import data.parameters

# Define required tags (fetched from parameters)
required_tags = parameters.required_tags

# Add bypass tags definition
bypass_tags = ["OU"]

# Deny if required tags are missing
message contains msg if {
    resource := tfplan.resource_changes[_]
    action := resource.change.actions[count(resource.change.actions) - 1]
    action in ["create", "update"]
    
    missing := missing_tags(resource.change.after.tags)
    count(missing) > 0

    msg := sprintf(
        # "This resources may have BYPASS_TAG",
        "This resources may have BYPASS_TAG === Resource '%v' is missing required tags: %v. Existing tags: %v",
        [resource.address, missing, resource.change.after.tags]
    )
}

# Helper function to identify missing tags
missing_tags(tags) = missing if {
    # Convert tags to a set of keys
    existing_tags := {key | tags[key]}
    
    # Find missing tags
    missing := {tag | 
        tag := required_tags[_]
        not existing_tags[tag]
    }
}

# Check if all required tags are present or bypass tag exists
resources_have_required_tags = true if {
    resource := tfplan.resource_changes[_]
    action := resource.change.actions[count(resource.change.actions) - 1]
    action in ["create", "update"]
    
    # Check if bypass tag exists
    tags := resource.change.after.tags
    some bypass_tag in bypass_tags
    tags[bypass_tag]
}

resources_have_required_tags = true if {
    resource := tfplan.resource_changes[_]
    action := resource.change.actions[count(resource.change.actions) - 1]
    action in ["create", "update"]
    
    missing := missing_tags(resource.change.after.tags)
    count(missing) == 0
}

default resources_have_required_tags = false
