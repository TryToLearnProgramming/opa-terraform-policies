package terraform.success_message

import rego.v1

# Import all policy packages that contain messages
import data.terraform.tags
import data.terraform.region
# Add more imports for other policy files as needed

# Collect all success messages from all policies
messages = msgs if {
    # Initialize an empty array for messages
    msgs := region.message
   
}

# You can keep the existing 'massage' rule if needed, or remove it

