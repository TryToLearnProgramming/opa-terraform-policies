package parameters

# Resource types to consider in calculations
resource_types := {
    "aws_vpc", "aws_subnet", "aws_instance", "aws_security_group",
    "aws_nat_gateway", "aws_vpn_gateway", "aws_s3_bucket"
}

# List of resource types that require the opa-resource tag
resources_requiring_opa_tag := [
    "aws_vpc",
    "aws_subnet",
    "aws_instance",
    "aws_security_group",
    "aws_nat_gateway",
    "aws_vpn_gateway",
    "aws_s3_bucket",
    "aws_codestarconnections_connection.bitbucket_connection"
    # Add more resource types here as needed
]

# List of required tags
required_tags := [
    "OPA-Resource",
    "Environment",
    "Project",
    "Map-Resource",
    # "OU",
    # "Terraform",
    # "Test"
    # Add more required tags here as needed
]

# Define restricted deployment days
restricted_days := ["Friday", "Saturday", "Sunday"]

# List of valid regions for resources
valid_regions := [
    "eu-west-1"
    # Add more valid regions here as needed
]

# Blast radius threshold
blast_radius_threshold := 30

# Weights for blast radius calculation
blast_radius_weights := {
    "aws_vpc": {"delete": 100, "create": 50, "modify": 10},
    "aws_subnet": {"delete": 50, "create": 25, "modify": 5},
    "aws_instance": {"delete": 40, "create": 20, "modify": 5},
    "aws_security_group": {"delete": 30, "create": 15, "modify": 3},
    "aws_nat_gateway": {"delete": 50, "create": 25, "modify": 5},
    "aws_vpn_gateway": {"delete": 70, "create": 35, "modify": 7},
    "aws_s3_bucket": {"delete": 60, "create": 30, "modify": 6},
    "aws_iam_role": {"delete": 80, "create": 40, "modify": 8},
    "aws_iam_policy": {"delete": 75, "create": 35, "modify": 7},
    "aws_cloudfront_distribution": {"delete": 90, "create": 45, "modify": 9},
}

# Define a list of disallowed IPs and disallowed ports
disallowed_ports := [22, 80]
disallowed_cidrs := ["0.0.0.0/0", "::/0"]
