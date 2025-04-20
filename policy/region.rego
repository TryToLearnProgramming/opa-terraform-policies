package terraform.region

import rego.v1

import input as tfplan
import data.parameters

is_valid_region if {
	tfplan.variables.region.value in parameters.valid_regions
}

# Define a message for valid region
valid_region_message := sprintf("Region '%s' is valid.", [tfplan.variables.region.value])

# Define a message for invalid region
invalid_region_message := sprintf("Region '%s' is not valid. Allowed regions are: %v", [tfplan.variables.region.value, parameters.valid_regions])

# Function to get the appropriate message based on region validity
get_region_message := valid_region_message if {
    is_valid_region
} else := invalid_region_message

# Add the region message to the overall messages
message contains msg if {
    msg := get_region_message
}
