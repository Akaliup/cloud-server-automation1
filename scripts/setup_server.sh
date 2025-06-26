#!/bin/bash
# 阿里云服务器初始化脚本
# 功能：更新系统、安装基础软件、配置防火墙、创建运维用户

# 确保脚本以root权限运行
if [ "$(id -u)" -ne 0 ]; then
   echo "请使用root权限运行此脚本"
   exit 1
fi

echo "开始服务器初始化..."

# 更新系统
echo "正在更新系统软件包..."
yum update -y

# 安装基础软件
echo "正在安装基础软件..."
yum install -y vim git wget curl net-tools htop nmap

# 配置防火墙
echo "正在配置防火墙..."
systemctl enable firewalld
systemctl start firewalld

# 开放常用端口
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --permanent --add-port=3306/tcp  # MySQL
firewall-cmd --permanent --add-port=5432/tcp  # PostgreSQL
firewall-cmd --permanent --add-port=9090/tcp  # Prometheus
firewall-cmd --permanent --add-port=3000/tcp  # Grafana

firewall-cmd --reload

# 创建运维用户
echo "正在创建运维用户..."
USERNAME="opsuser"
PASSWORD=$(openssl rand -base64 12)

useradd $USERNAME
echo $PASSWORD | passwd --stdin $USERNAME

# 添加用户到sudoers
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME

# 配置SSH
echo "正在配置SSH..."
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

echo "服务器初始化完成！"
echo "运维用户: $USERNAME"
echo "密码: $PASSWORD"
echo "请务必记录以上信息，并为用户配置SSH密钥！"    