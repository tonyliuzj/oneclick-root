# oneclick-root

一个通用的 Shell 脚本，用于在多种 Linux 发行版上启用 root 的 SSH 访问。也支持 Oracle OCI。

```bash
curl -fsSL -o root.sh "https://github.com/tonyliuzj/oneclick-root/releases/latest/download/root.sh" && chmod +x root.sh && sudo ./root.sh
```

```bash
wget -qO root.sh "https://github.com/tonyliuzj/oneclick-root/releases/latest/download/root.sh" && chmod +x root.sh && sudo ./root.sh
```

## 概述

该脚本可自动在全新 Linux 系统上完成 root SSH 访问的配置。它会检测包管理器，安装所需软件包，并配置 SSH 允许 root 使用密码登录。

## 支持的发行版

* Debian/Ubuntu（apt-get）
* Fedora/RHEL/CentOS（dnf/yum）
* openSUSE（zypper）
* Arch/Manjaro（pacman）
* Alpine（apk）

## 使用方法

使用 root 权限运行脚本：

```bash
sudo ./root.sh
```

脚本将会：

1. 检测你的包管理器
2. 更新软件包列表
3. 安装 sudo 和 openssh-server
4. 提示设置新的 root 密码
5. 配置 SSH 允许 root 使用密码认证登录
6. 重启 SSH 服务

## 需求

* Root/sudo 权限
* Bash shell
* 可用于安装软件包的互联网连接

## 安全警告

该脚本会启用 root 通过 SSH 使用**密码认证**登录，这可能带来安全风险。仅建议在受控环境中使用，例如：

* 开发/测试环境
* 实验室环境
* 可信网络

对于生产系统，建议改用基于 SSH 密钥的认证方式。

## 脚本做了什么

### 软件包安装

* 如未安装则安装 `sudo`
* 为你的发行版安装对应的 SSH 服务端软件包

### SSH 配置

* 在 `/etc/ssh/sshd_config` 中设置 `PermitRootLogin yes`
* 在 `/etc/ssh/sshd_config` 中设置 `PasswordAuthentication yes`
* 清理 `/etc/ssh/sshd_config.d/` 中可能冲突的覆盖配置
* 使用对应的 init 系统重启 SSH 服务

## 许可证

MIT
