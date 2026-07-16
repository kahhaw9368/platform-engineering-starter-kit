# Foundation — one-time bootstrap (ADR-0004)

Engagement tooling, not a platform capability. Developers and APEX never touch this.

Provisions (format TBD, low stakes): VPC, nonprod + prod EKS Auto Mode clusters (ADR-0001/0007),
EKS Capabilities enablement (managed Argo CD hub-and-spoke, ACK, KRO), IAM Identity Center
wiring, ECR, GitOps repo bootstrap.

- [ ] Decide bootstrap format with container specialist team (eksctl / CFN / Terraform)
- [ ] Author bootstrap stack
- [ ] Validate managed-capability enablement steps against current EKS docs
