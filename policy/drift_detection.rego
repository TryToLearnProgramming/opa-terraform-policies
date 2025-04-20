package terraform.drift

import future.keywords

# Import the Terraform plan
import input.tfplan as tfplan

# Import the current state (this would be provided by an external source)
import input.current_state as current_state

# Define the resources we want to check for drift
resource_types := {"aws_instance"}

# Main rule to detect drift
detect_drift := drift_report {
    resources := {r | r := tfplan.resource_changes[_]; r.type in resource_types}
    drift_items := [item |
        resource := resources[_]
        current := current_state[resource.address]
        item := check_drift(resource, current)
        item != null
    ]
    drift_report := {
        "has_drift": count(drift_items) > 0,
        "drift_items": drift_items
    }
}

# Helper function to check drift for a single resource
check_drift(planned, current) := drift_item if {
    # Check if the resource exists in the current state
    current != null

    # Compare attributes
    differences := [attr |
        attr := planned.change.after[key]
        current[key] != attr
    ]

    # If there are differences, create a drift item
    count(differences) > 0
    drift_item := {
        "address": planned.address,
        "type": planned.type,
        "differences": differences
    }
} else := null  # Return null if no drift detected

# Rule to determine if drift remediation is needed
needs_remediation {
    detect_drift.has_drift
}

# Rule to provide a summary of drift
drift_summary := summary {
    drift_report := detect_drift
    summary := sprintf(
        "Drift detected in %d resources. Remediation needed: %v",
        [count(drift_report.drift_items), needs_remediation]
    )
}