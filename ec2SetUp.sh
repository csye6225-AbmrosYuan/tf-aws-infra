#!/bin/bash

# 从长期存在的配置桶中下载配置文件(awscli 已安装)
#install aws cli
# sudo mkdir /opt/awscliInstall/
# sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/opt/awscliInstall/awscliv2.zip" && 
# sudo unzip /opt/awscliInstall/awscliv2.zip -d /opt/awscliInstall/ && 
# sudo /opt/awscliInstall/aws/install && 
touch /opt/C.txt
sudo aws s3 cp s3://configbucket261447/webapp.env /opt/csye6225/webappFlask/app/webapp.env 
sudo aws s3 cp s3://configbucket261447/cloud_watch_agent.json /opt/csye6225/webappFlask/config/cloud_watch_agent.json && 

# /usr/local/bin/aws --version

# 将 .env 文件移动到应用目录，并设置权限
# sudo mv -f /tmp/webapp.env /opt/csye6225/webappFlask/app/webapp.env
sudo chown csye6225_user:csye6225 /opt/csye6225/webappFlask/app/webapp.env

# 将 cloud_watch_agent.json 文件移动到配置目录，并设置权限
# sudo mv -f /tmp/cloud_watch_agent.json /opt/csye6225/webappFlask/config/cloud_watch_agent.json
sudo chown csye6225_user:csye6225 /opt/csye6225/webappFlask/config/cloud_watch_agent.json


sudo mkdir -p /var/log/csye6225/webapp_log/
sudo touch /var/log/csye6225/webapp_log/flaskapp.log
sudo chown -R csye6225_user:csye6225 /var/log/csye6225

# 启动 CloudWatch Agent 并检查状态
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/csye6225/webappFlask/config/cloud_watch_agent.json -s
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status



sudo systemctl enable amazon-cloudwatch-agent

# 启动 Web 应用服务
sudo systemctl enable webappFlask
sudo systemctl start webappFlask.service
