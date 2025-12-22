# oneclick-root

A universal shell script for enabling root SSH access across multiple Linux distributions. Works with Oracle OCI as well.

## Overview

This script automates the setup of root SSH access on fresh Linux systems. It detects the package manager, installs required packages, and configures SSH for root login with password authentication.

## Supported Distributions

- Debian/Ubuntu (apt-get)
- Fedora/RHEL/CentOS (dnf/yum)
- openSUSE (zypper)
- Arch/Manjaro (pacman)
- Alpine (apk)

## Usage

Run the script with root privileges:

```bash
sudo ./root.sh
```

The script will:
1. Detect your package manager
2. Update package lists
3. Install sudo and openssh-server
4. Prompt for a new root password
5. Configure SSH to allow root login with password authentication
6. Restart the SSH service

## Requirements

- Root/sudo access
- Bash shell
- Internet connection for package installation

## Security Warning

This script enables root login via SSH with password authentication, which may pose security risks. Use this only in controlled environments such as:
- Development/testing environments
- Lab setups
- Trusted networks

For production systems, consider using SSH key-based authentication instead.

## What It Does

### Package Installation
- Installs `sudo` if not present
- Installs the appropriate SSH server package for your distribution

### SSH Configuration
- Sets `PermitRootLogin yes` in `/etc/ssh/sshd_config`
- Sets `PasswordAuthentication yes` in `/etc/ssh/sshd_config`
- Clears any conflicting overrides in `/etc/ssh/sshd_config.d/`
- Restarts the SSH service using the appropriate init system

## License

This project is provided as-is for educational and testing purposes.
