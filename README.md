# my-terraform-project

Standard, environment-aware Terraform project structure for provisioning AWS
infrastructure — VPC, S3 + CloudFront, and EKS with control-plane logging
and IRSA — using reusable modules, per-environment configuration, and
baseline CloudWatch/SNS alerting.

Application workloads run as containers on EKS. Kubernetes Services/Ingress
manage their own load balancers (via the AWS Load Balancer Controller) - see
"How Users Reach the Application" below.

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
│       ├── main.tf                # SNS topic for alarm notifications
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
| `s3` | Private, encrypted, versioned S3 bucket used as a static asset origin. |
| `cloudfront` | CloudFront distribution in front of the S3 bucket via Origin Access Control (OAC), with a bucket policy restricting reads to that distribution. |
| `eks` | EKS control plane + one managed node group, with cluster/node IAM roles, control-plane logging to CloudWatch, and an IAM OIDC provider for IRSA (IAM Roles for Service Accounts). Deployed into the private subnets. |
| `monitoring` | SNS topic with an optional email subscription. Attach CloudWatch alarms to it (EKS Container Insights, S3/CloudFront metrics, etc.) as your monitoring needs grow. |

## File Purposes (root)

| File | Purpose |
|---|---|
| `main.tf` | Main configuration file. Calls each module (vpc, s3, cloudfront, eks, monitoring). |
| `variables.tf` | Input variables for the configuration, grouped by module. |
| `outputs.tf` | Output values exported after `terraform apply`. |
| `providers.tf` | Provider configuration. Defines the cloud provider and credentials/region. |
| `versions.tf` | Specifies required Terraform version and provider versions. |
| `environments/<env>/terraform.tfvars` | Environment-specific variable values (CIDR ranges, node counts, log retention, etc). |
| `environments/<env>/backend.tf` | Environment-specific remote state backend settings (S3 bucket, key, DynamoDB lock table). |
| `backend.tf` | Optional root backend stub; actual backend values are supplied per-environment at `init` time. |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6.0
- AWS CLI configured with valid credentials (`aws configure`)
- An S3 bucket + DynamoDB table for remote state locking (per environment),
  or update `backend.tf` files to match your chosen backend.
- `kubectl` and `aws eks update-kubeconfig` to interact with the cluster
  after apply.
- The [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
  installed into the cluster (via Helm) if you want Kubernetes Services/
  Ingress to provision ALBs/NLBs automatically - see below.

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

> Tip: for larger teams, consider Terraform Workspaces or separate state
> per environment (as modeled here) — this layout uses the latter, which is
> generally safer for prod isolation.

## How Users Reach the Application

This project provisions the EKS cluster itself; it does not deploy
application workloads. Once the cluster exists:

```bash
aws eks update-kubeconfig --name my-terraform-project-dev-eks --region us-east-1
kubectl get nodes
```

To expose an app publicly, deploy it to the cluster and create a Kubernetes
`Service` of type `LoadBalancer` or an `Ingress` resource. If the AWS Load
Balancer Controller is installed, it will automatically provision an
ALB/NLB and route traffic to your pods - this is managed by Kubernetes
manifests (or Helm charts), not by this Terraform project. Pods can assume
scoped IAM roles via IRSA using `eks_oidc_provider_arn` as the trust
principal, instead of relying on the node's IAM role.

Static assets (a frontend build, images, etc.) are served separately via
CloudFront, at the `cloudfront_domain_name` output.

## Adding a New Module

1. Create a new folder under `modules/<module-name>/`.
2. Add `main.tf`, `variables.tf`, `outputs.tf`, and `versions.tf` inside it.
3. Reference it from the root `main.tf` via a `module` block.

## Notes on Included Resources

- **S3 + CloudFront**: the bucket has all public access blocked; only the
  CloudFront distribution (via OAC + bucket policy) can read from it.
- **EKS** node group and control plane run in the **private** subnets;
  the cluster API endpoint is public by default (`endpoint_public_access`)
  for simplicity — restrict or disable this for production. Control-plane
  logs (api, audit, authenticator, etc.) ship to CloudWatch Logs, and an
  IAM OIDC provider is created so you can attach IRSA roles to Kubernetes
  ServiceAccounts (create the per-workload roles separately, trusting
  `eks_oidc_provider_arn`).
- **Monitoring**: a single SNS topic (`sns_alerts_topic_arn`) is ready to
  receive alarm notifications. Set `alarm_email` in tfvars to get an email
  subscription (AWS sends a confirmation link you must click). No alarms
  are wired up by default since there are no EC2/ALB metrics to alarm on -
  add EKS Container Insights alarms, S3 request-error alarms, or CloudFront
  error-rate alarms as needed and point their `alarm_actions` at
  `module.monitoring.sns_topic_arn`.
- Node counts / log retention / alarm settings scale from `dev` →
  `staging` → `prod` in the provided `terraform.tfvars` files; adjust to
  your actual workload and budget.

## Still Missing for Full Enterprise-Grade Use

This project covers networking, static content delivery, and a logged/
IRSA-ready EKS cluster, but a platform team would typically still add:

- Application deployment tooling for EKS (Helm charts, ArgoCD/Flux, the
  AWS Load Balancer Controller itself, cluster autoscaler)
- Multiple NAT gateways (one per AZ) for high availability
- WAF in front of CloudFront / the ALB Ingress creates
- Container Insights / Prometheus + Grafana for cluster observability
- CI/CD for Terraform (plan/apply pipeline, policy checks with
  `tflint`/`tfsec`/`checkov`)
- Module registry + semantic versioning for the modules
- Multi-account structure (separate AWS accounts per environment)
- Secrets management (AWS Secrets Manager / SSM Parameter Store, or
  External Secrets Operator in-cluster) for application config

## Conventions

- All resources are tagged with `Project`, `Environment`, and `ManagedBy` by
  default (see `providers.tf`).
- Variable and resource names use `snake_case`.
- Sensitive values (credentials, secrets) should never be committed —
  use environment variables, `TF_VAR_*`, or a secrets manager instead.
- Run `terraform fmt -recursive` and `terraform validate` before committing.

## License

Internal use / adapt as needed for your organization.
