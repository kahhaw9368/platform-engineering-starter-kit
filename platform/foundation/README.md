# Foundation — one-time bootstrap (ADR-0004)

Engagement tooling, not a platform capability. Developers and APEX never touch this.

Provisions (format TBD, low stakes): VPC, nonprod + prod EKS Auto Mode clusters (ADR-0001/0007),
EKS Capabilities enablement (managed Argo CD hub-and-spoke, ACK, KRO), IAM Identity Center
wiring, ECR, GitOps repo bootstrap.

- [x] Format: eksctl + bootstrap.sh (PROVISIONAL — specialist team may substitute; smallest teachable surface, no state management, consistent with ADR-0004's 'low stakes' framing)
- [x] cluster.eksctl.yaml + bootstrap.sh authored (capability enablement commands PROVISIONAL)
- [ ] OPEN: validate capability enablement commands + eksctl Auto Mode syntax with specialist team (blocking for first engagement, not for kit development)
