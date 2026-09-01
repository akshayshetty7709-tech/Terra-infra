# my-terraform-project

Standard, environment-aware Terraform project structure for provisioning AWS
infrastructure — VPC, EC2 behind an ALB, S3 + CloudFront, and EKS with
control-plane logging and IRSA — using reusable modules, per-environment
configuration, and baseline CloudWatch monitoring.

## Project Structure

```
my-terraform-project/
├── main.tf                      # Root module - wires together child modules
├── variables.tf                  # Root input variables
├── outputs.tf                    # Root output values
├── providers.tf                   # Provider configuration (AWS)
├── versions.tf                    # Required Terraform & provider versions
├── backend.tf                     # Backend placeholder (configured per-env)
├── modules/
│   ├── vpc/
│   │   ├── main.tf                # VPC, subnets, IGW, NAT, route tables
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── alb/
│   │   ├── main.tf                # Internet-facing ALB, target group, listener(s)
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── ec2/
│   │   ├── main.tf                # Security group + EC2 instance(s), registered to ALB
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── s3/
│   │   ├── main.tf                # Encrypted, versioned, private S3 bucket
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── cloudfront/
│   │   ├── main.tf                # CDN distribution + OAC + bucket policy
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── eks/
│   │   ├── main.tf                # EKS cluster + node group + IAM + logging + IRSA
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── monitoring/
│       ├── main.tf                # SNS topic + CloudWatch alarms (EC2 CPU, ALB errors)
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── environments/
│   ├── dev/
│   │   ├── terraform.tfvars       # Dev-specific variable values
│   │   └── backend.tf             # Dev remote state backend config
│   ├── staging/
│   │   ├── terraform.tfvars       # Staging-specific variable values
│   │   └── backend.tf             # Staging remote state backend config
│   └── prod/
│       ├── terraform.tfvars       # Prod-specific variable values
│       └── backend.tf             # Prod remote state backend config
└── README.md                      # This file
```

## Modules

| Module | Purpose |
|---|---|
| `vpc` | VPC, public/private subnets, internet gateway, NAT gateway, route tables. |
| `alb` | Internet-facing Application Load Balancer, target group, and HTTP/HTTPS listener(s). This is the public "front door" for the EC2 app. |
| `ec2` | Security group + one or more EC2 instances (latest Amazon Linux 2023 AMI) in the public subnets, registered as ALB targets. HTTP ingress is restricted to the ALB's security group instead of the open internet. |
| `s3` | Private, encrypted, versioned S3 bucket used as a static asset origin. |
| `cloudfront` | CloudFront distribution in front of the S3 bucket via Origin Access Control (OAC), with a bucket policy restricting reads to that distribution. |
| `eks` | EKS control plane + one managed node group, with cluster/node IAM roles, control-plane logging to CloudWatch, and an IAM OIDC provider for IRSA (IAM Roles for Service Accounts). Deployed into the private subnets. |
| `monitoring` | SNS topic + CloudWatch alarms for EC2 CPU utilization, ALB 5xx errors, and unhealthy ALB targets. Optional email subscription. |

## File Purposes (root)

| File | Purpose |
|---|---|
| `main.tf` | Main configuration file. Calls each module (vpc, ec2, s3, cloudfront, eks). |
| `variables.tf` | Input variables for the configuration, grouped by module. |
| `outputs.tf` | Output values exported after `terraform apply`. |
| `providers.tf` | Provider configuration. Defines the cloud provider and credentials/region. |
| `versions.tf` | Specifies required Terraform version and provider versions. |
| `environments/<env>/terraform.tfvars` | Environment-specific variable values (CIDR ranges, instance sizes, node counts, etc). |
| `environments/<env>/backend.tf` | Environment-specific remote state backend settings (S3 bucket, key, DynamoDB lock table). |
| `backend.tf` | Optional root backend stub; actual backend values are supplied per-environment at `init` time. |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6.0
- AWS CLI configured with valid credentials (`aws configure`)
- An S3 bucket + DynamoDB table for remote state locking (per environment),
  or update `backend.tf` files to match your chosen backend.
- `kubectl` and the AWS CLI's `aws eks update-kubeconfig` if you plan to
  interact with the EKS cluster after apply.

## Usage

Each environment is initialized separately so it uses its own backend and
variable values.

### 1. Initialize for an environment

```bash
terraform init -backend-config=environments/dev/backend.tf
```

### 2. Plan

```bash
terraform plan -var-file=environments/dev/terraform.tfvars
```

### 3. Apply

```bash
terraform apply -var-file=environments/dev/terraform.tfvars
```

### Switching environments

Re-run `init` with `-reconfigure` when switching between environments so
Terraform points at the correct backend:

```bash
terraform init -reconfigure -backend-config=environments/staging/backend.tf
terraform plan -var-file=environments/staging/terraform.tfvars
```

### Connecting to the EKS cluster after apply

```bash
aws eks update-kubeconfig --name my-terraform-project-dev-eks --region us-east-1
kubectl get nodes
```

> Tip: for larger teams, consider Terraform Workspaces or separate state
> per environment (as modeled here) — this layout uses the latter, which is
> generally safer for prod isolation.

## Adding a New Module

1. Create a new folder under `modules/<module-name>/`.
2. Add `main.tf`, `variables.tf`, `outputs.tf`, and `versions.tf` inside it.
3. Reference it from the root `main.tf` via a `module` block.

## Notes on Included Resources

- **ALB**: internet-facing, terminates HTTP (and HTTPS if you set
  `alb_certificate_arn` to an ACM certificate). Users hit the ALB's DNS name
  (`alb_dns_name` output) — not the EC2 instances directly.
- **EC2** instances are placed in **public** subnets but only accept HTTP
  traffic from the ALB's security group, not the open internet. Adjust
  `ec2_allowed_ssh_cidrs` to lock down SSH access — it's empty (closed) by
  default in staging/prod.
- **S3 + CloudFront**: the bucket has all public access blocked; only the
  CloudFront distribution (via OAC + bucket policy) can read from it.
- **EKS** node group and control plane run in the **private** subnets;
  the cluster API endpoint is public by default (`endpoint_public_access`)
  for simplicity — restrict or disable this for production. Control-plane
  logs (api, audit, authenticator, etc.) ship to CloudWatch Logs, and an
  IAM OIDC provider is created so you can attach IRSA roles to Kubernetes
  ServiceAccounts (create the per-workload roles separately, trusting
  `eks_oidc_provider_arn`).
- **Monitoring**: a single SNS topic (`sns_alerts_topic_arn`) receives
  CloudWatch alarm notifications for EC2 CPU, ALB 5xx rate, and unhealthy
  ALB targets. Set `alarm_email` in tfvars to get an email subscription
  (AWS will send a confirmation link you must click).
- Instance sizes / node counts / alarm thresholds scale from `dev` →
  `staging` → `prod` in the provided `terraform.tfvars` files; adjust to
  your actual workload and budget.

## Still Missing for Full Enterprise-Grade Use

This project now covers load balancing, EKS logging/IRSA, and baseline
alarms, but a platform team would typically still add:

- Auto Scaling Groups (currently EC2 is a fixed instance count, not
  self-healing/elastic)
- Multiple NAT gateways (one per AZ) for high availability
- WAF in front of the ALB / CloudFront
- Centralized logging (e.g., CloudWatch Logs → S3/OpenSearch) and
  distributed tracing
- CI/CD for Terraform (plan/apply pipeline, policy checks with
  `tflint`/`tfsec`/`checkov`)
- Module registry + semantic versioning for the modules
- Multi-account structure (separate AWS accounts per environment)
- Secrets management (AWS Secrets Manager / SSM Parameter Store)
  integration for application config

## Conventions

- All resources are tagged with `Project`, `Environment`, and `ManagedBy` by
  default (see `providers.tf`).
- Variable and resource names use `snake_case`.
- Sensitive values (credentials, secrets) should never be committed —
  use environment variables, `TF_VAR_*`, or a secrets manager instead.
- Run `terraform fmt -recursive` and `terraform validate` before committing.

## License

Internal use / adapt as needed for your organization.
