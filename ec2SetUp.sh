#!/bin/bash

#1.copy env 
echo "Listing /tmp before mv"
ls -al /tmp

sudo mv -f /tmp/webapp.env /opt/csye6225/webappFlask/app/

sudo chown csye6225_user:csye6225 /opt/csye6225/webappFlask/app/webapp.env

echo "After mv:"
ls -al /opt/csye6225/webappFlask/app/



#2.config cloudwatch agent(agent has been installed by pakcer)
#create log file
sudo mkdir -p /var/log/csye6225/webapp_log/
sudo touch  /var/log/csye6225/webapp_log/flaskapp.log
sudo chown -R csye6225_user:csye6225 /var/log/csye6225

sudo  touch  /var/A.txt


sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/csye6225/webappFlask/config/cloud_watch_agent.json -s


sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status

#enable agent
sudo systemctl enable amazon-cloudwatch-agent



#enable webapp
sudo systemctl enable webappFlask
sudo systemctl start webappFlask.service


