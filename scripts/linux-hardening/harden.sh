#!/bin/bash
# ════════════════════════════════════════════════
# SecureOps Pipeline — Linux Hardening Script
# Hardens Ubuntu/RHEL build agent for CI/CD use
# Run as root: sudo ./harden.sh
# ════════════════════════════════════════════════

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
info() { echo -e "${CYAN}[->]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

echo ""
echo "SecureOps — Linux Hardening Script"
echo "===================================="

[[ $EUID -ne 0 ]] && fail "Run as root: sudo ./harden.sh"
log "Running as root"

if [ -f /etc/redhat-release ]; then
    OS="rhel"
    PKG="dnf"
elif [ -f /etc/debian_version ]; then
    OS="ubuntu"
    PKG="apt-get"
else
    fail "Unsupported OS"
fi
log "Detected OS: $OS"

# 1. SYSTEM UPDATE
info "Updating system packages..."
$PKG update -y -q
$PKG upgrade -y -q
log "System updated"

# 2. SSH HARDENING
info "Hardening SSH configuration..."
SSH_CONFIG="/etc/ssh/sshd_config"
cp $SSH_CONFIG ${SSH_CONFIG}.backup.$(date +%Y%m%d)

cat >> $SSH_CONFIG << 'SSHEOF'
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
X11Forwarding no
MaxAuthTries 3
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2
AllowAgentForwarding no
AllowTcpForwarding no
SSHEOF

systemctl restart sshd
log "SSH hardened"

# 3. FIREWALL — nftables
info "Configuring nftables firewall..."
$PKG install -y nftables -q

cat > /etc/nftables.conf << 'NFTEOF'
#!/usr/sbin/nft -f
flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        ct state established,related accept
        iifname "lo" accept
        tcp dport 22 ip saddr 10.0.2.0/24 accept
        tcp dport { 80, 443 } accept
        ip protocol icmp accept
        log prefix "nftables-drop: " drop
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
NFTEOF

systemctl enable nftables
systemctl start nftables
log "nftables firewall configured"

# 4. IMMUTABLE FILES
info "Setting immutable flags on critical files..."

IMMUTABLE_FILES=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/group"
    "/etc/sudoers"
    "/etc/hosts"
    "/etc/resolv.conf"
)

for f in "${IMMUTABLE_FILES[@]}"; do
    if [ -f "$f" ]; then
        chattr +i "$f"
        log "Immutable: $f"
    fi
done

# 5. AUDIT RULES
info "Configuring kernel audit rules..."
$PKG install -y auditd -q
systemctl enable auditd
systemctl start auditd

cat > /etc/audit/rules.d/secureops.rules << 'AUDITEOF'
-w /etc/passwd -p wa -k identity_changes
-w /etc/shadow -p wa -k identity_changes
-w /etc/sudoers -p wa -k sudoers_changes
-w /etc/ssh/sshd_config -p wa -k ssh_config_change
-a always,exit -F arch=b64 -S setuid -S setgid -k privilege_escalation
-w /usr/bin/docker -p x -k docker_activity
-w /etc/nftables.conf -p wa -k firewall_change
AUDITEOF

service auditd restart
log "Audit rules configured"

# 6. DISABLE UNUSED SERVICES
info "Disabling unused services..."
DISABLE_SERVICES=("cups" "bluetooth" "avahi-daemon" "rpcbind")

for svc in "${DISABLE_SERVICES[@]}"; do
    if systemctl is-active --quiet $svc 2>/dev/null; then
        systemctl stop $svc
        systemctl disable $svc
        log "Disabled: $svc"
    fi
done

# 7. KERNEL HARDENING — sysctl
info "Applying kernel security parameters..."

cat > /etc/sysctl.d/99-secureops.conf << 'SYSCTLEOF'
net.ipv4.ip_forward = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
fs.suid_dumpable = 0
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.randomize_va_space = 2
SYSCTLEOF

sysctl -p /etc/sysctl.d/99-secureops.conf
log "Kernel parameters applied"

# 8. FILE PERMISSIONS
info "Correcting file permissions..."
chmod 600 /etc/shadow
chmod 644 /etc/passwd
chmod 440 /etc/sudoers
chmod 700 /root
log "File permissions corrected"

echo ""
echo "===================================="
echo "Hardening Complete — Summary"
echo "===================================="
echo "[OK] System updated"
echo "[OK] SSH hardened"
echo "[OK] nftables firewall configured"
echo "[OK] Critical files set immutable"
echo "[OK] Audit rules configured"
echo "[OK] Unused services disabled"
echo "[OK] Kernel parameters hardened"
echo "[OK] File permissions corrected"
echo ""
warn "IMPORTANT: Reboot recommended"
warn "Verify SSH access BEFORE closing this session"
