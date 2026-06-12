# SecureOps Pipeline — Build Guide

## Prerequisites
- Azure free trial account — portal.azure.com
- Azure CLI installed — learn.microsoft.com/cli/azure/install-azure-cli
- Docker Desktop installed — docker.com
- Azure DevOps free account — dev.azure.com
- GitHub account — github.com

---

## DAY 1 — Infrastructure + Linux + Docker

### Step 1 — Login to Azure

Open terminal and run:

az login

az group create --name secureops-rg --location uksouth

### Step 2 — Get Your IP Address

MY_IP=$(curl -s ifconfig.me)
echo "Your IP: $MY_IP"

### Step 3 — Deploy Infrastructure

az deployment group create \
  --resource-group secureops-rg \
  --template-file infra/bicep/main.bicep \
  --parameters adminIpAddress=$MY_IP

### Step 4 — Create Build Agent VM

az vm create \
  --resource-group secureops-rg \
  --name secureops-build-agent \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/id_rsa.pub \
  --vnet-name secureops-vnet \
  --subnet mgmt-subnet \
  --public-ip-sku Standard \
  --output table

### Step 5 — Get VM IP

VM_IP=$(az vm list-ip-addresses \
  --resource-group secureops-rg \
  --name secureops-build-agent \
  --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" \
  --output tsv)

echo "VM IP: $VM_IP"

### Step 6 — SSH Into VM and Harden

ssh azureuser@$VM_IP

scp scripts/linux-hardening/harden.sh azureuser@$VM_IP:~/

ssh azureuser@$VM_IP

chmod +x harden.sh

sudo ./harden.sh

### Step 7 — Verify Hardening

sudo lsattr /etc/passwd

sudo auditctl -l

sudo nft list ruleset

sudo sysctl kernel.dmesg_restrict

### Step 8 — Install Docker on VM

curl -fsSL https://get.docker.com -o get-docker.sh

sudo sh get-docker.sh

sudo usermod -aG docker azureuser

### Step 9 — Store Secrets in Key Vault

ACR_NAME=$(az acr list --resource-group secureops-rg --query "[0].name" -o tsv)

ACR_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)

KV_NAME=$(az keyvault list --resource-group secureops-rg --query "[0].name" -o tsv)

az keyvault secret set --vault-name $KV_NAME --name "ACR-LOGIN-SERVER" --value $ACR_SERVER

az keyvault secret set --vault-name $KV_NAME --name "ACR-NAME" --value $ACR_NAME

az keyvault secret set --vault-name $KV_NAME --name "APPROVER-EMAIL" --value "your-email@gmail.com"

### Step 10 — Test Docker Build Locally

docker build -t secureops-app:test -f docker/Dockerfile .

docker run -d -p 8080:80 --name secureops-test secureops-app:test

Open http://localhost:8080 in browser

docker stop secureops-test && docker rm secureops-test

---

## DAY 2 — Pipeline + Document + Publish

### Step 11 — Create Azure DevOps Project

1. Go to dev.azure.com
2. Create new project: SecureOps-Pipeline
3. Go to Pipelines and create pipeline
4. Connect to GitHub — select secureops-pipeline repo
5. Choose existing YAML file
6. Select pipeline/azure-pipelines.yml

### Step 12 — Create Variable Group

1. Pipelines — Library — Variable Groups
2. Create group: secureops-keyvault-secrets
3. Enable Link secrets from Azure Key Vault
4. Add variables: ACR-LOGIN-SERVER, ACR-NAME, APPROVER-EMAIL

### Step 13 — Create Service Connections

1. Project Settings — Service Connections
2. New — Azure Resource Manager
3. Name: secureops-azure-connection

4. New — Docker Registry
5. Name: secureops-acr-connection
6. Select your ACR

### Step 14 — Configure Approval Gate

1. Pipelines — Environments
2. Create: production
3. Approvals and checks — Add approval
4. Add your email as approver
5. Timeout: 24 hours

### Step 15 — Run Pipeline

1. Go to Pipelines — Run Pipeline
2. Branch: main
3. Watch all 5 stages run
4. Check email for approval request
5. Approve and watch final deploy

### Step 16 — Configure Azure Monitor

az monitor action-group create \
  --resource-group secureops-rg \
  --name secureops-alerts \
  --short-name soalerts \
  --email-receiver name=admin email=your-email@gmail.com

---

## Resume Bullet Points

SecureOps Pipeline — Azure DevOps CI/CD with Zero Trust Security

- Built a production-grade CI/CD pipeline on Azure deploying a containerised application via Azure DevOps with 5-stage pipeline including Trivy security scanning and manual approval gates
- Designed Zero Trust network architecture — 3-subnet VNet with separate NSGs enforcing default-deny inbound rules, applying CCNA subnetting knowledge directly to Azure VNet design
- Hardened Linux build agent using nftables firewall, chattr immutable file flags, auditctl kernel audit rules, and sysctl security parameters
- Eliminated hardcoded secrets using Azure Key Vault with Managed Identity — pipeline variables linked directly to Key Vault with zero service principal credentials
- Configured Azure Monitor with Log Analytics — alert rules covering pipeline failures, NSG changes, Key Vault access denials, and container resource thresholds
- Technologies: Linux, Docker, Azure DevOps, Azure VNet, NSG, Key Vault, Managed Identity, RBAC, Azure Monitor, Bicep IaC, Trivy
