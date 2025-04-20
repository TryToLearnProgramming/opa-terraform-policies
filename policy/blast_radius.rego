package terraform.blast_radius

import rego.v1
import data.parameters
import data.terraform.analysis

resource_types := parameters.resource_types
# Compute the score for a Terraform plan as the weighted sum of deletions, creations, modifications
score := s if {
    all := [x |
        some resource_type
        crud := parameters.blast_radius_weights[resource_type]
        del := crud["delete"] * analysis.num_deletes[resource_type]
        new := crud["create"] * analysis.num_creates[resource_type]
        mod := crud["modify"] * analysis.num_modifies[resource_type]
        x := del + new + mod
    ]
    s := sum(all)
}

# Helper functions for num_deletes, num_creates, and num_modifies should be defined here
# or imported from another package if they're defined elsewhere
# Define a message for the score and blast radius comparison
message contains msg if {
    threshold := parameters.blast_radius_threshold
    status := score < threshold
    msg := sprintf("Blast radius score is %.2f. Threshold is %.2f. %s", [
        score,
        threshold,
        status_message(status)
    ])
}

# Helper function to determine the status message
status_message(status) := "Score is within acceptable limits." if status
status_message(status) := "Score exceeds the threshold." if not status
