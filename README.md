# OPA Terraform Policies

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)

## 🎯 Description

A comprehensive collection of policy-as-code examples for integrating Open Policy Agent (OPA) with Terraform. This project helps you enforce security and compliance standards, automate policy checks, and ensure best practices in your cloud infrastructure deployments.

## ✨ Key Features

- 🛡️ **Security Controls**: Prevent misconfigured security groups and enforce encryption
- 🏷️ **Resource Tagging**: Ensure consistent tagging across all resources
- 📊 **Blast Radius Control**: Limit the scope of infrastructure changes
- ⏰ **Deployment Scheduling**: Restrict deployments during critical periods
- 🔄 **Drift Detection**: Identify unauthorized infrastructure changes
- 🌐 **Region Restrictions**: Control where resources can be deployed

## 🚀 Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 or later)
- [Open Policy Agent](https://www.openpolicyagent.org/docs/latest/#1-download-opa) (latest version)
- [AWS CLI](https://aws.amazon.com/cli/) (configured with appropriate credentials)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/opa-terraform-policies.git
   ```

2. Navigate to the project directory:
   ```bash
   cd opa-terraform-policies
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

## 📖 Usage

### Policy Evaluation Workflow

1. Generate a Terraform plan:
   ```bash
   terraform plan --out tfplan.binary
   ```

2. Convert the plan to JSON:
   ```bash
   terraform show -json tfplan.binary > tfplan.json
   ```

3. Evaluate policies:
   ```bash
   # Check Authorization Status
   opa exec --decision terraform/analysis/authz --bundle policy/ tfplan.json

   # Check Score (Blast Radius)
   opa exec --decision terraform/blast_radius/score --bundle policy/ tfplan.json

   # Check Authorization Reason
   opa exec --decision terraform/analysis/authz_reason --bundle policy/ tfplan.json

   # Check Drift Detection
   opa exec --decision terraform/drift/detect_drift --bundle policy/ tfplan.json
   ```

### Implemented Policies

| Policy | Description | Status |
|--------|-------------|--------|
| Blast Radius | Limits the scope of changes | ✅ Working |
| Resource Tags | Enforces required tags | ✅ Working |
| Region Restriction | Limits resource creation to specific regions | ✅ Working |
| Deployment Schedule | Prevents deployments on restricted days | ✅ Working |
| S3 Encryption | Ensures S3 buckets are encrypted | ✅ Working |
| Security Groups | Prevents overly permissive rules | ✅ Working |
| Tag Bypass | Allows exceptions with specific tags | ✅ Working |

## 📝 Policy Examples

### Security Group Policy
```rego
# Prevent security groups with wide-open access
open_security_group_rules {
    sg := input.resource_changes[_]
    sg.type == "aws_security_group"
    
    rule := sg.change.after.ingress[_]
    rule.cidr_blocks[_] == "0.0.0.0/0"
    rule.from_port <= 22
    rule.to_port >= 22
}
```

### Deployment Schedule Policy
```rego
# No deployments on weekends or Fridays
restricted_days := ["Friday", "Saturday", "Sunday"]

is_restricted_day {
    day := time.weekday(time.now_ns())
    restricted_days[_] == day
}
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create your feature branch:
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. Commit your changes:
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. Push to the branch:
   ```bash
   git push origin feature/AmazingFeature
   ```
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Open Policy Agent Documentation](https://www.openpolicyagent.org/docs/latest/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- The amazing DevOps community

---
⭐ Found this project useful? Please star it on GitHub!