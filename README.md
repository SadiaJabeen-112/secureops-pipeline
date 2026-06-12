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

| Category | Tools |
|----------|-------|
| OS | Linux — RHEL · Ubuntu |
| Containers | Docker · Nginx Alpine |
| Cloud | Microsoft Azure |
| Networking | VNet · NSG · Subnets · CCNA |
| Security | Key Vault · Managed Identity · RBAC · Zero Trust |
| CI/CD | Azure DevOps · Trivy · Approval Gates |
| IaC | Bicep · ARM |
| Monitoring | Azure Monitor · Log Analytics |

---

## Cert Coverage

| Cert | What it contributed |
|------|-------------------|
| AZ-900 | Cloud models · Shared responsibility |
| AZ-104 | VNet · NSG · RBAC · Azure Monitor · VM |
| AZ-204 | Key Vault · Managed Identity · ACI |
| AZ-400 | Pipeline · Approval gates · IaC · Trivy |
| CCNA | Subnet design · Routing · Network architecture |
| RHCSA | Linux hardening · nftables · auditctl · sysctl |

---

## Author

**Sadia Jabeen**
Cloud and DevOps Professional — Hyderabad, India
4x Microsoft Azure Certified — CCNA

[

![LinkedIn](https://img.shields.io/badge/LinkedIn-sadiajabeen112-blue?style=flat&logo=linkedin)

](https://linkedin.com/in/sadiajabeen112)
[

![Portfolio](https://img.shields.io/badge/Portfolio-sadiajabeen112.github.io-green?style=flat&logo=github)

](https://sadiajabeen112.github.io)
