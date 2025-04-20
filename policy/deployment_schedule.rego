package terraform.deployment_schedule

import rego.v1

import data.parameters

# Define restricted deployment days
# restricted_days := ["Friday", "Saturday", "Sunday"]

# Check if the current day is a restricted day
is_restricted_day if {
    current_day := time.weekday(time.now_ns())
    current_day in parameters.restricted_days
}
