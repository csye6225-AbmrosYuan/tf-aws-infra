#!/bin/bash


touch /tmp/A.jpg

sudo touch /opt/csye6225/B.jpg 

sudo mv -f /tmp/webapp.env /opt/csye6225/webappFlask/app/

sudo chown csye6225_user:csye6225 /opt/csye6225/webappFlask/app/webapp.env

sudo systemctl enable webappFlask
sudo systemctl start webappFlask.service
sudo apt install mysql-client -y

