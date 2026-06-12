# SecureOps Pipeline — Architecture Decisions

## Why these technology choices?

### Why Azure Container Instance over Azure App Service?
ACI gives direct control over the container runtime and network placement.
For a project demonstrating AZ-104 and AZ-204 knowledge — showing VNet integration
with ACI demonstrates deeper understanding than App Service defaults.

### Why Bicep over ARM Templates?
Bicep is the modern IaC language for Azure — cleaner syntax, better tooling,
compiles to ARM. Demonstrates AZ-400 IaC knowledge without ARM JSON verbosity.

### Why multi-stage Dockerfile?
Multi-stage builds produce smaller, cleaner production images.
The build stage includes Node.js. The production stage is Alpine nginx only.
Final image size is approximately 25MB vs 900MB for a single-stage build.

### Why nftables over iptables?
RHEL 8/9 and Ubuntu 22+ use nftables as the default firewall backend.
Demonstrating nftables knowledge shows awareness of current Linux standards.

### Why Trivy for container scanning?
Trivy is the industry standard for container vulnerability scanning.
Used natively in Azure Defender for Containers and GitHub Advanced Security.

### Why Managed Identity over Service Principal?
Managed Identity means zero credentials to manage, rotate, or accidentally expose.
No passwords in pipeline variables. No secrets to rotate.
This is the correct Azure-native approach for AZ-204 and AZ-400.

### Why approval gates?
Zero Trust principle applied to deployments.
No automated production deployment — human verification required every time.
Demonstrates AZ-400 environment and approval gate configuration.
## Network Architecture

| Subnet | CIDR | Purpose |
|--------|------|---------|
| VNet | 10.0.0.0/16 | Main network |
| web-subnet | 10.0.1.0/24 | Container instances |
| mgmt-subnet | 10.0.2.0/24 | Build agent VM |
| ops-subnet | 10.0.3.0/24 | Key Vault and Monitor |

## Security Layers
| Layer | Technology | Purpose |
|-------|-----------|---------|
| 1 | Azure NSG | Network perimeter |
| 2 | nftables | OS firewall |
| 3 | RBAC | Identity and access |
| 4 | Key Vault | Secret management |
| 5 | Managed Identity | Passwordless auth |
| 6 | Trivy scan | Container vulnerability check |
| 7 | Audit rules | Activity monitoring |
| 8 | Azure Monitor | Observability and alerting |

Eight distinct security layers — Zero Trust applied end to end.

## Cert Coverage

AZ-900 — cloud models, shared responsibility model
AZ-104 — VNet, NSG, RBAC, Azure Monitor, VM management
AZ-204 — Key Vault, Managed Identity, ACI deployment
AZ-400 — Pipeline stages, approval gates, IaC, security scanning
CCNA   — subnet design, NSG rules, routing, network architecture
RHCSA  — Linux hardening, nftables, auditctl, sysctl, chattr
