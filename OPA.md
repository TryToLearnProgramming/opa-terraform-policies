# Open Policy Agent (OPA) for Terraform

## Introduction

### Why SecOps Scanning for Terraform?
- OPA can enforce policies in Terraform, OpenTofu, Kubernetes, CI/CD pipelines (Jenkins, GitHub Actions), API gateways, and more
- Tests help individual developers sanity check their Terraform changes
- Tests can auto-approve infrastructure changes and reduce the burden of peer-review

### What is Open Policy Agent?
An engine that acts as a judge with given policies and values.

### Why is it used in industry?
For administration and evaluation purposes.

### Benefits of using OPA
- Validate values against queries
- Track changes effectively

## OPA Principles & Fundamentals
- Loves JSON
- Can check pre/post plan
- Can set score (%) for passing scripts

## Implementation

### Commands
```bash
# Generate Terraform plan
terraform plan --out tfplan.binary

# Convert plan to JSON
terraform show -json tfplan.binary > tfplan.json

# Execute OPA policies
opa exec --decision terraform/analysis/authz --bundle policy/ tfplan.json
opa exec --decision terraform/analysis/score --bundle policy/ tfplan.json
```

### Brainstorming Ideas
```
Brain Storming with Kartik{
    1. MAP tag policy
    2. Drift Detection using OPA
    3. Restricting deployments on certain days of the week (e.g., Fridays) to minimize risk during high-impact periods
    4.  A policy that denies plans using outdated Terraform versions or disallows specific cloud provider configurations
    5. A policy that ensures all S3 buckets have encryption enabled by default
}
```

## Current Challenges
- The commands are working in Windows, but not in Linux (WSL). Need to investigate why. =====> Fixed
- How to check the drift of the infrastructure?
- How to check the compliance of the infrastructure?
- If we apply the binary file, then the plan is applied and we cannot roll back using the same binary file.

## Scalable Implementation
(To be added)

## References
```
# to create deployment plan 
terraform plan --out=tfplan.binary

# to apply deployment plan
terraform apply tfplan.binary

# to create destroy plan
terraform plan -destroy -out=tfplan.binary

# to apply destroy plan
terraform apply -destroy tfplan.binary
```

## List of Rules
- Blast radius should be 30%
- All resources must have the [OPA-Resource, Environment, Project] tags
- Secucrity Groups should not have expose to 0.0.0.0/0, can by-pass this for specific security groups
- Blast redious is not applicable while 1st time deployment
- Region should be specificed in variables.tf file
- Deployment should not be on Friday or weekend
- S3 buckets should have encryption enabled by default (working on this)
- By pass the policy check for any ressources using tags (OPA = false) 
- EC2 

## Commands to check the policy
```bash
# Here terraform/analysis/authz is the policy name, which is defined in the policy/terraform.rego file. It here is used to check the authorization status. Other policies are used to check the score and the reason for authorization.

# To check Authorization Status
opa exec --decision terraform/analysis/authz --bundle policy/ tfplan.json

# To check Score
opa exec --decision terraform/blast_radius/score --bundle policy/ tfplan.json

# To check the Authorization Reason
opa exec --decision terraform/analysis/authz_reason --bundle policy/ tfplan.json

# To check the Drift Detection
opa exec --decision terraform/drift/detect_drift --bundle policy/ tfplan.json
```



###############################
# Check List of Rules
###############################

Blast Radius
Tags - working
Region - working
Deployment Day - working
S3 Encryption - working
Security Group - working
Tag Bypass - Tested (only working while bypass required tags are not present)



##

To create an Open Policy Agent (OPA) policy using Rego that evaluates whether an S3 bucket is encrypted and returns a custom success message, you can follow the structure outlined below. This example includes two parts: the S3 policy package and the main package that imports and invokes it.

## S3 Policy Package (`s3_policy.rego`)

This Rego policy checks if an S3 bucket is encrypted or not and returns a custom success message based on that evaluation.

```rego
package s3_policy

# Define a rule to check if the S3 bucket is encrypted
is_encrypted[message] {
    input.bucket.encryption == "AES256"  # Check for server-side encryption
    message = "The S3 bucket is encrypted."
}

is_not_encrypted[message] {
    input.bucket.encryption == null
    message = "The S3 bucket is not encrypted."
}
```

### Explanation:
- The package `s3_policy` contains two rules: `is_encrypted` and `is_not_encrypted`.
- Each rule checks the `input.bucket.encryption` field to determine if the bucket is encrypted.
- Depending on the result, it assigns a corresponding success message.

## Main Package (`main.rego`)

This main package imports the `s3_policy` package and invokes its rules to print the result.

```rego
package main

import data.s3_policy

default allow = false

# Main rule to evaluate S3 bucket encryption status
result[message] {
    s3_policy.is_encrypted[message]
}

result[message] {
    s3_policy.is_not_encrypted[message]
}
```

### Explanation:
- The `main` package imports the `s3_policy` package.
- It defines a default rule `allow`, which can be used for authorization purposes.
- The `result` rule checks both conditions from the imported package and collects messages accordingly.

## Running the Policies

To evaluate these policies, you would typically use OPA's command line interface. Here's how you can run it:

1. **Prepare Input**: Create a JSON input file (e.g., `input.json`) representing an S3 bucket configuration.

```json
{
    "bucket": {
        "encryption": "AES256"  // Change this value to null to test non-encrypted case
    }
}
```

2. **Evaluate the Policies**:
   Use the following command to evaluate your policies:

```bash
opa eval --data s3_policy.rego --data main.rego --input input.json "data.main.result"
```

### Expected Output:
If the bucket is encrypted, you should see:

```json
{
    "result": [
        {
            "message": "The S3 bucket is encrypted."
        }
    ]
}
```

If it's not encrypted, you would see:

```json
{
    "result": [
        {
            "message": "The S3 bucket is not encrypted."
        }
    ]
}
```

This setup allows you to modularly check for specific conditions regarding your AWS resources using OPA and Rego effectively.

Citations:
[1] https://github.com/nyalavarthi/opa-policies-s3-rds
[2] https://aws.amazon.com/blogs/mt/using-opa-to-create-aws-config-rules/
[3] https://www.styra.com/blog/securing-aws-s3-buckets-with-opa-and-object-lambda/
[4] https://www.infralovers.com/blog/2024-06-28-terraform-opa-policies/
[5] https://www.openpolicyagent.org/docs/latest/
[6] https://codilime.com/blog/leveraging-opa-and-rego-to-automate-compliance/
[7] https://www.openpolicyagent.org/docs/latest/management-bundles/
[8] https://stackoverflow.com/questions/68803593/opa-bundle-with-aws-s3-configuration


## other findings
- Use `opa run` when you need to start an OPA server, manage policies interactively, or expose an API for external services to query policy decisions.
- Use `opa exec` when you want to evaluate specific queries against your policies without setting up a full server environment, making it suitable for testing and automation scenarios.

- If your use case evolves to require centralized policy management or if you need to expose an API for other services to query decisions dynamically, you might consider using `opa run` at that point. However, for most CI/CD tasks focused on validation and compliance checks, `opa exec` will likely serve your needs better.