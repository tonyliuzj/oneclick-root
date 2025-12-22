#!/bin/bash
set -e

# Must be run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g. sudo $0)"
  exit 1
fi

echo "[*] Detecting package manager..."

PKG_INSTALL=""
PKG_UPDATE=""
SSH_PKG="openssh-server"  # default, overridden for some distros

if command -v apt-get >/dev/null 2>&1; then
    # Debian / Ubuntu
    PKG_UPDATE="apt-get update -y"
    PKG_INSTALL="apt-get install -y"
    SSH_PKG="openssh-server"
elif command -v dnf >/dev/null 2>&1; then
    # Fedora / newer RHEL/CentOS
    PKG_UPDATE="dnf makecache -y"
    PKG_INSTALL="dnf install -y"
    SSH_PKG="openssh-server"
elif command -v yum >/dev/null 2>&1; then
    # Older RHEL/CentOS
    PKG_UPDATE="yum makecache -y"
    PKG_INSTALL="yum install -y"
    SSH_PKG="openssh-server"
elif command -v zypper >/dev/null 2>&1; then
    # openSUSE
    PKG_UPDATE="zypper refresh"
    PKG_INSTALL="zypper install -y"
    SSH_PKG="openssh"
elif command -v pacman >/dev/null 2>&1; then
    # Arch / Manjaro
    PKG_UPDATE="pacman -Sy --noconfirm"
    PKG_INSTALL="pacman -S --noconfirm"
    SSH_PKG="openssh"
elif command -v apk >/dev/null 2>&1; then
    # Alpine
    PKG_UPDATE="apk update"
    PKG_INSTALL="apk add --no-cache"
    SSH_PKG="openssh"
else
    echo "Unsupported or unknown Linux distribution (no known package manager)."
    exit 1
fi

echo "[*] Updating package lists..."
sh -c "$PKG_UPDATE"

echo "[*] Installing sudo and SSH server..."
sh -c "$PKG_INSTALL sudo $SSH_PKG"

SSH_CONFIG="/etc/ssh/sshd_config"

if [ ! -f "$SSH_CONFIG" ]; then
    echo "Cannot find $SSH_CONFIG even after installing SSH. Aborting."
    exit 1
fi

# Ask for root password (input hidden)
read -s -p "Enter new root password: " ROOTPASS
echo
read -s -p "Confirm root password: " ROOTPASS2
echo

if [ "$ROOTPASS" != "$ROOTPASS2" ]; then
    echo "Passwords do not match. Aborting."
    exit 1
fi

echo "[*] Setting root password..."
printf "root:%s\n" "$ROOTPASS" | chpasswd

echo "[*] Configuring SSH to allow root login and password auth..."

# Ensure PermitRootLogin yes
if grep -qi '^[#[:space:]]*PermitRootLogin' "$SSH_CONFIG"; then
    sed -i 's/^[#[:space:]]*PermitRootLogin.*/PermitRootLogin yes/' "$SSH_CONFIG"
else
    echo "PermitRootLogin yes" >> "$SSH_CONFIG"
fi

# Ensure PasswordAuthentication yes
if grep -qi '^[#[:space:]]*PasswordAuthentication' "$SSH_CONFIG"; then
    sed -i 's/^[#[:space:]]*PasswordAuthentication.*/PasswordAuthentication yes/' "$SSH_CONFIG"
else
    echo "PasswordAuthentication yes" >> "$SSH_CONFIG"
fi

# Optional: clear extra sshd_config.d snippets if present
if [ -d /etc/ssh/sshd_config.d ]; then
    echo "[*] Clearing /etc/ssh/sshd_config.d overrides..."
    rm -f /etc/ssh/sshd_config.d/*
fi

echo "[*] Restarting SSH service..."

RESTARTED=0

if command -v systemctl >/dev/null 2>&1; then
    if systemctl restart sshd 2>/dev/null; then
        echo "sshd restarted via systemctl."
        RESTARTED=1
    elif systemctl restart ssh 2>/dev/null; then
        echo "ssh restarted via systemctl."
        RESTARTED=1
    fi
fi

if [ "$RESTARTED" -eq 0 ]; then
    # Fallback to old-style service commands
    if command -v service >/dev/null 2>&1; then
        if service sshd restart 2>/dev/null; then
            echo "sshd restarted via service."
            RESTARTED=1
        elif service ssh restart 2>/dev/null; then
            echo "ssh restarted via service."
            RESTARTED=1
        fi
    fi
fi

if [ "$RESTARTED" -eq 0 ] && command -v rc-service >/dev/null 2>&1; then
    # Alpine / OpenRC style
    if rc-service sshd restart 2>/dev/null; then
        echo "sshd restarted via rc-service."
        RESTARTED=1
    elif rc-service ssh restart 2>/dev/null; then
        echo "ssh restarted via rc-service."
        RESTARTED=1
    fi
fi

if [ "$RESTARTED" -eq 0 ]; then
    echo "WARNING: Could not restart SSH automatically. Please restart it manually."
else
    echo "Root login enabled and password set."
fi
