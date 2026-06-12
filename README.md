# SecureOps Pipeline

A production-grade secure CI/CD pipeline on Azure.

Containerised static site deployed via Azure DevOps with Zero Trust security
— Key Vault secrets, Managed Identity, NSG-hardened VNet, hardened Linux
build agent, and full Azure Monitor observability.

## What is inside

| File | Purpose |
|------|---------|
| app/index.html | Static site — the deployed application |
| docker/Dockerfile | Multi-stage build — Node builder to Alpine nginx |
| docker/nginx.conf | Hardened nginx with security headers |
| infra/bicep/main.bicep | IaC — VNet, NSGs, ACR, Key Vault, Log Analytics |
| pipeline/azure-pipelines.yml | 5-stage CI/CD pipeline |
| scripts/linux-hardening/harden.sh | Linux hardening script |
| docs/architecture.md | Architecture decisions |
| docs/BUILD-GUIDE.md | Step by step build guide + resume bullets |

## Technologies

Linux — Docker — Azure DevOps — Azure VNet — NSG — Key Vault
Managed Identity — RBAC — Azure Monitor — Bicep IaC — Trivy

## Cert Coverage

AZ-900 — AZ-104 — AZ-204 — AZ-400 — CCNA — RHCSA

## Author

Sadia Jabeen
Cloud and DevOps Professional — Hyderabad India
4x Microsoft Azure Certified — CCNA
linkedin.com/in/sadiajabeen112
sadiajabeen112.github.io
