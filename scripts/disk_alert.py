#!/usr/bin/env python3
# 磁盘空间监控告警脚本
import subprocess
import smtplib
from email.mime.text import MIMEText

# 配置参数
THRESHOLD = 80  # 磁盘使用率阈值(%)
SMTP_SERVER = "smtp.example.com"
SMTP_PORT = 587
SMTP_USER = "alert@example.com"
SMTP_PASSWORD = "your_password"
RECIPIENTS = ["admin@example.com"]

def get_disk_usage():
    """获取磁盘使用情况"""
    result = subprocess.run(['df', '-h'], capture_output=True, text=True)
    return result.stdout

def check_disk_usage():
    """检查磁盘使用率并返回超过阈值的分区"""
    output = get_disk_usage()
    high_usage = []
    
    for line in output.split('\n')[1:]:
        if not line:
            continue
            
        parts = line.split()
        if len(parts) < 5:
            continue
            
        try:
            mount_point = parts[-1]
            usage_percent = int(parts[-2].strip('%'))
            
            if usage_percent > THRESHOLD:
                high_usage.append(f"分区 {mount_point} 使用率: {usage_percent}%")
        except ValueError:
            continue
            
    return high_usage

def send_alert_email(alert_message):
    """发送告警邮件"""
    msg = MIMEText(f"警告: 服务器磁盘空间不足!\n\n{alert_message}\n\n详细信息:\n{get_disk_usage()}")
    msg['Subject'] = "服务器磁盘空间告警"
    msg['From'] = SMTP_USER
    msg['To'] = ", ".join(RECIPIENTS)
    
    try:
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(SMTP_USER, SMTP_PASSWORD)
            server.send_message(msg)
        print("告警邮件发送成功")
    except Exception as e:
        print(f"发送邮件失败: {e}")

if __name__ == "__main__":
    high_usage = check_disk_usage()
    if high_usage:
        alert_msg = "\n".join(high_usage)
        print(f"发现磁盘空间问题:\n{alert_msg}")
        send_alert_email(alert_msg)
    else:
        print("磁盘空间正常")    